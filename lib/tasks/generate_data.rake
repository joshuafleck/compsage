require 'rubygems'
require 'faker'

namespace :data_generator do
  desc "Generate a fake set of responses for a survey."
  task :finished_survey => :environment do
    sponsor = Organization.first
    survey = Factory(:survey, :job_title => Faker::Company.catch_phrase, :sponsor => sponsor, :description => Faker::Lorem.paragraph, :questions => generate_questions, :end_date => Time.now - 1.day)
    
    invitations = []
    current_org = 1
    # between 5 and 10 invitations  
    (rand(6)+5).times do
      if current_org < Organization.count && rand(2) > 0 then
        invitee = Organization.all[current_org]
        invite = Factory(:survey_invitation, :inviter => sponsor, :invitee => invitee, :survey => survey, :aasm_state => 'sent')
        current_org += 1
      else
        invite = Factory(:external_survey_invitation, :inviter => sponsor, :survey => survey, :aasm_state => 'sent')
      end

      invitations << invite
    end

    participations = []
    invitations.each do |invitation|
      next if rand(5) == 0 # (80% chance of participation)
      
      # build responses.
      responses = []
      survey.questions.each do |question|
        next if !question.required? && question.parent_question.nil? && rand(5) == 0 # (80% chance of answering a question)
        
        case question.response_type
        when 'NumericalResponse'
          response = Factory.build(:numerical_response, :question => question, :response => 20000 + rand(60000))
        when 'WageResponse'
          response = Factory.build(:wage_response, :question => question, :response => 20000 + rand(60000), :unit => 'Annually')
        when 'BaseWageResponse'
          response = Factory.build(:base_wage_response, :question => question, :response => 20000 + rand(60000), :unit => 'Annually')
        when 'PercentResponse'
          response = Factory.build(:percent_response, :question => question, :response => rand(100))
        when 'MultipleChoiceResponse'
          response = Factory.build(:multiple_choice_response, :question => question, :response => rand(question.options.size))
        else
          response = Factory.build(:textual_response, :question => question, :response => Faker::Lorem.sentence)
        end

        responses << response
      end

      if invitation.is_a?(SurveyInvitation)
        participation = Factory(:participation, :survey => survey, :participant => invitation.invitee, :responses => responses)
      else
        participation = Factory(:participation, :survey => survey, :participant => invitation, :responses => responses)
      end
      
      participations << participation
    end
    
    survey.finish!
  end  

  desc "Emtpy the database"
  task :clear, :needs => [:environment] do |task|
    clear_database
    Rake::Task["ts:index"].invoke
  end

  desc "Generate an external invitation link to respond to a survey"
  task :external_invitation, :survey_id, :needs => [:environment] do |task, args|
    if args[:survey_id] then
      survey = Survey.find(args[:survey_id])
    else
      survey = Survey.running.last
    end

    begin
      invite = Factory.create(:external_survey_invitation, :survey => survey, :inviter => survey.sponsor)
    rescue ActiveRecord::RecordInvalid => e
      if e.message == "Validation failed: That organization is already invited" then
        retry
      else
        raise
      end
    end
    puts "External invitation link: /survey_login?key=#{CGI.escape(invite.key)}&survey_id=#{survey.id}"
  end
  
  #usage: rake 'data_generator:association NAME="Manufacturers Alliance" SUBDOMAIN="mfrall" MEMBERS=20'
  desc "Generate an association with a given number of organizations"
  task :association, :name, :subdomain, :members, :needs => [:environment] do |task,args|
    members = (args[:members] || NUM_ORGANIZATIONS).to_i
    
    before

    generate_association_organizations(args.name, args.subdomain, members)
    after
  end

  # usage: rake 'data_generator:load_all[5]'
  desc "Generate a fake set of data for all types."
  task :load_all, :total, :needs => [:environment] do |task,args|
    before
    
    total = (args[:total] || NUM_ORGANIZATIONS).to_i

    generate_organizations(total)   
          
    generate_networks
    generate_network_memberships
    generate_network_invitations
    
    generate_surveys  
    generate_invoices
    generate_survey_invitations
    run_surveys
    generate_discussions  
    generate_responses_and_participations
    close_surveys
    
    after
  end
  
  # all of the tables for which we will be generating data
  TABLES = [
    'surveys',
    'survey_subscriptions',
    'participations',
    'responses',
    'invitations',
    'pending_accounts',
    'discussions',
    'logos',
    'networks',
    'network_memberships',
    'organizations',
    'questions',
    'invoices']
  
  # defaults
  NUM_ORGANIZATIONS = 5
    
  NETWORKS_PER_ORGANIZATION = 5
  
  SURVEYS_PER_ORGANIZATION = 7
  
  ORGANIZATIONS_PER_NETWORK = 5
  
  INVITATIONS_PER_NETWORK = 3
  
  EXTERNAL_INVITATIONS_PER_NETWORK = 3 
  
  INVITATIONS_PER_SURVEY = 7
  
  EXTERNAL_INVITATIONS_PER_SURVEY = 3
  
  QUESTIONS_PER_SURVEY = 5
  
  DISCUSSION_TOPICS_PER_SURVEY = 3
  
  DISCUSSIONS_PER_TOPIC = 3
  
  PARTICIPATION_RATE = 0.8
  
  CLOSE_RATE = 0.75 
    
  RESPONSE_RATE = 0.85 
  

  # prerequisites for loading data
  def before
    begin
      Rake::Task["ts:stop"].invoke
    rescue
    end    
    Rake::Task["beanstalk_dispatcher:stop"].invoke
    clear_database
  end
  
  # cleanup after loading data  
  def after
    optimize_database
    Rake::Task["ts:start"].invoke
    Rake::Task["ts:index"].invoke
    Rake::Task["beanstalk_dispatcher:start"].invoke
  end    
  
  def clear_database
    TABLES.each do |table|
      ActiveRecord::Base.connection.execute('TRUNCATE TABLE '+table)
    end      
  end
  
  def optimize_database
    ActiveRecord::Base.connection.execute('ANALYZE TABLE '+TABLES.join(','))
    ActiveRecord::Base.connection.execute('OPTIMIZE TABLE '+TABLES.join(','))
  end  
  
  def generate_organizations(total)    
    puts "generating #{total} organizations..."
    
    total.times do |index|
      print_percent_complete(index,total)
      Factory(
        :organization, 
        :password => 'test12', 
        :password_confirmation => 'test12', 
        :name => Faker::Company.name, 
        :email => Faker::Internet.email,
        :location => Faker::Address.city,
        :contact_name => Faker::Name.name,
        :city => Faker::Address.city,
        :state => Faker::Address.us_state_abbr,
        :zip_code => Faker::Address.zip_code.slice(0..4),
        :industry => AccountsHelper::INDUSTRIES[rand(53)])
    end
    
    puts "generating organizations complete"
  end
  
  def generate_association_organizations(name, subdomain, total)
    puts "creating association"
    association = Factory(:association, 
                          :name => name || Faker::Company.name,
                          :subdomain => subdomain || Faker::Internet.domain_word
                          )
    puts "Association created with subdomain #{association.subdomain}"
    puts "generating #{total} organizations..."
    
    Organization.suspended_delta do
      total.times do |index|
        print_percent_complete(index,total)
        organization = Factory(:organization, 
          :password => 'test12', 
          :password_confirmation => 'test12', 
          :name => Faker::Company.name, 
          :email => Faker::Internet.email,
          :location => Faker::Address.city,
          :contact_name => Faker::Name.name,
          :city => Faker::Address.city,
          :state => Faker::Address.us_state_abbr,
          :zip_code => Faker::Address.zip_code.slice(0..4),
          :industry => AccountsHelper::INDUSTRIES[rand(53)])
          
          association.organizations << organization
      end
    end
    
    puts "generating organizations complete"
  end
  
  # generates networks for each organization
  def generate_networks 
    organizations = Organization.all
    
    puts "generating #{NETWORKS_PER_ORGANIZATION} networks per organization (about #{NETWORKS_PER_ORGANIZATION*organizations.size})..." 
    
    organizations.each_with_index do |owner,index|
    
      print_percent_complete(index,organizations.size)    
      
      (rand(NETWORKS_PER_ORGANIZATION)+3).times do |index|
        Factory(
          :network,
          :name => Faker::Lorem.sentence,
          :description => Faker::Lorem.paragraph,
          :owner => owner)
      end    
    end

    puts "generating networks complete"     
  end
  
  # adds members to all networks
  def generate_network_memberships      
    networks = Network.all
    
    puts "generating #{ORGANIZATIONS_PER_NETWORK} organizations per network (about #{ORGANIZATIONS_PER_NETWORK*networks.size})..." 
    
    networks.each_with_index do |network,index|
    
      print_percent_complete(index,networks.size)    
          
      organizations = []
      (rand(ORGANIZATIONS_PER_NETWORK)+3).times do |index|
        organization = Organization.find :first, :offset => (Organization.count * rand).to_i
        Factory(:network_membership,:network => network, :organization => organization) unless network.owner == organization || organizations.include?(organization)
        organizations << organization
      end
    end
    
    puts "generating network organizations complete"    
  end
  
  # creates invitations for all networks
  def generate_network_invitations
    networks = Network.all    
    
    puts "generating #{INVITATIONS_PER_NETWORK} invitations per network (about #{INVITATIONS_PER_NETWORK*networks.size})" 
    puts "generating #{EXTERNAL_INVITATIONS_PER_NETWORK} external invitations per network (about #{EXTERNAL_INVITATIONS_PER_NETWORK*networks.size})..."     
    
    networks.each_with_index do |network,index|
     
      print_percent_complete(index,networks.size)    
           
      invitees = []
      (rand(INVITATIONS_PER_NETWORK)+2).times do |index|
        organization = Organization.find :first, :offset => (Organization.count * rand).to_i
        Factory(
          :network_invitation,
          :network => network,
          :inviter => network.owner,
          :invitee => organization) unless network.owner == organization || network.organizations.include?(organization) || invitees.include?(organization)
        invitees << organization
      end
      
      (rand(EXTERNAL_INVITATIONS_PER_NETWORK)+2).times do |index|
        Factory(
          :external_network_invitation,
          :network => network,
          :inviter => network.owner,
          :email => Faker::Internet.email,
          :organization_name => Faker::Company.name)
      end   
         
    end
    
    puts "generating network invitations complete"    
  end 
  
  # creates surveys for all organizations
  def generate_surveys  
    organizations = Organization.all
    
    puts "generating #{SURVEYS_PER_ORGANIZATION} surveys per organization (about #{SURVEYS_PER_ORGANIZATION*organizations.size})..."     
        
    organizations.each_with_index do |sponsor,index|
        
      print_percent_complete(index,organizations.size)    
        
      (rand(SURVEYS_PER_ORGANIZATION)+4).times do |index|
        Factory(
          :survey, 
          :job_title => Faker::Company.catch_phrase, 
          :sponsor => sponsor, 
          :description => Faker::Lorem.paragraph,
          :questions => generate_questions,
          :aasm_state => 'pending',
          :days_running => (3..14).to_a[rand(11)])
      end  
         
    end
    
    puts "generating surveys complete"     
  end
  
  # will put the surveys in a running state
  def run_surveys
    surveys = Survey.all
    
    puts "running #{surveys.size} surveys" 
    
    surveys.each_with_index do |survey, index| 
      print_percent_complete(index,surveys.size) 
      survey.billing_info_received!
    end
    
    puts "running surveys complete" 
  end
  
  # creates discussions for all surveys
  def generate_discussions
    surveys = Survey.all
        
    puts "generating #{DISCUSSION_TOPICS_PER_SURVEY} discussion topics per survey (about #{DISCUSSION_TOPICS_PER_SURVEY*surveys.size})..."     
            
    surveys.each_with_index do |survey, index|
    
      print_percent_complete(index,surveys.size)    
        
      (rand(DISCUSSION_TOPICS_PER_SURVEY)+2).times do |index|
        organization = Organization.find :first, :offset => (Organization.count * rand).to_i
        Factory(
          :discussion,
          :survey => survey,
          :subject => Faker::Lorem.sentence,
          :body => Faker::Lorem.paragraph,
          :responder => organization) 
      end
     
    end
    
    puts "generating discussion topics complete"  
         
    discussions = Discussion.all

    puts "generating #{DISCUSSIONS_PER_TOPIC} discussions per topic (about #{DISCUSSIONS_PER_TOPIC*discussions.size})..."     
            
    discussions.each_with_index do |discussion,index|

      print_percent_complete(index,discussions.size)    
            
      (rand(DISCUSSIONS_PER_TOPIC)+2).times do |index|
        organization = Organization.find :first, :offset => (Organization.count * rand).to_i
        Factory(
          :discussion,
          :survey => discussion.survey,
          :subject => Faker::Lorem.sentence,
          :body => Faker::Lorem.paragraph,
          :responder => organization,
          :parent_discussion_id => discussion.id) 
      end   
         
    end
    
    puts "generating discussions complete"  
  end
  
  # creates invoices for all surveys
  def generate_invoices
    surveys = Survey.all
        
    puts "generating #{surveys.size} invoices" 
        
    surveys.each_with_index do |survey, index|
    
      print_percent_complete(index,surveys.size) 
      
      invoice = Invoice.find_or_initialize_by_survey_id(survey.id)
      
      invoice.attributes = {
        :organization_name => Faker::Company.name, 
        :contact_name => Faker::Name.name,
        :city => Faker::Address.city,
        :state => Faker::Address.us_state_abbr,
        :zip_code => Faker::Address.zip_code.slice(0..4),
        :amount => survey.price,
        :address_line_1 => Faker::Address.street_address,
        :address_line_2 => Faker::Address.street_address,
        :payment_type => ['credit','invoice'][rand(2)],
        :phone => '%010d' % rand(9999999999),
        :phone_extension => rand(999999).to_s
        }
        
        invoice.save
      
    end
    
    puts "generating invoices complete"
  end   
  
  # creates invitations for all surveys
  def generate_survey_invitations
    surveys = Survey.all
        
    puts "generating #{INVITATIONS_PER_SURVEY} invitations per survey (about #{INVITATIONS_PER_SURVEY*surveys.size})" 
    puts "generating #{EXTERNAL_INVITATIONS_PER_SURVEY} external invitations per survey (about #{EXTERNAL_INVITATIONS_PER_SURVEY*surveys.size})..."     
            
    surveys.each_with_index do |survey, index|
    
      print_percent_complete(index,surveys.size)    
        
      invitees = []
      (rand(INVITATIONS_PER_SURVEY)+5).times do |index|
        organization = Organization.find :first, :offset => (Organization.count * rand).to_i
        Factory(
          :survey_invitation,
          :aasm_state => 'pending',
          :survey => survey,
          :inviter => survey.sponsor,
          :invitee => organization) unless survey.sponsor == organization || invitees.include?(organization)
        invitees << organization
      end
      
      (rand(EXTERNAL_INVITATIONS_PER_SURVEY)+2).times do |index|
        Factory(
          :external_survey_invitation,
          :aasm_state => 'pending',
          :survey => survey,
          :inviter => survey.sponsor,
          :email => Faker::Internet.email,
          :organization_name => Faker::Company.name)
      end      
    end
    
    puts "generating invitations complete"
  end 
  
  # returns array of questions
  def generate_questions     
    
    questions = []
    (rand(QUESTIONS_PER_SURVEY) + 3).times do |index|
      
      question_type = case rand(6)
      when 0 # create numerical response
        'Numeric response'
      when 1 # create textual response
        'Text response'
      when 2 # create wage response
        'Pay or wage response'
      when 3 # create radio response
        'Yes/No'
      when 4 # create agreement scale response
        'Agreement scale'
      when 5 # create percent response
        'Percent'
      end
      
      question = Factory.build(
        :question,
        :question_type => question_type, 
        :text => Faker::Lorem.sentence.gsub(/.$/, '?'), 
        :position => index)
      
      questions << question
    end
    
    questions
  end    
  
  # generates responses & participations for all surveys
  def generate_responses_and_participations
    invitations = SurveyInvitation.all + ExternalSurveyInvitation.all
    
    puts "generating responses (about #{(RESPONSE_RATE*invitations.size.to_f).floor})..."   
    
    invitations.each_with_index do |invitation,index|  
    
      next if rand > PARTICIPATION_RATE # ((PARTICIPATION_RATE*100)% chance of participation)
      
      print_percent_complete(index,invitations.size)    
        
      survey = invitation.survey
      questions = survey.questions
      
      # build responses.
      responses = []
      questions.each do |question|
        next if !question.required? && question.parent_question.nil? && rand > RESPONSE_RATE # ((RESPONSE_RATE*100)% chance of answering a question)
        
        case question.response_type
        when 'BaseWageResponse'
          response = Factory.build(
            :base_wage_response, 
            :question => question, 
            :response => 20000 + rand(60000),
            :unit => ['Annually', 'Hourly'][rand(2)],
            :comments => [nil,Faker::Lorem.sentence][rand(2)])
            
            response.response = WageResponse.units.convert(response.response, {:to => "Hourly", :from => "Annually"}) if response.unit == "Hourly"
        when 'WageResponse'
          response = Factory.build(
            :wage_response, 
            :question => question, 
            :response => 20000 + rand(60000),
            :unit => ['Annually', 'Hourly'][rand(2)],
            :comments => [nil,Faker::Lorem.sentence][rand(2)])
            
          response.response = WageResponse.units.convert(response.response, {:to => "Hourly", :from => "Annually"}) if response.unit == "Hourly"
        when 'MultipleChoiceResponse'
          response = Factory.build(
            :multiple_choice_response, 
            :question => question, 
            :response => 0 + rand(question.options.size),
            :comments => [nil,Faker::Lorem.sentence][rand(2)])
        when 'PercentResponse'
          response = Factory.build(
            :percent_response, 
            :question => question, 
            :response => 20000 + rand(60000),
            :comments => [nil,Faker::Lorem.sentence][rand(2)])
        when 'NumericalResponse'
          response = Factory.build(
            :numerical_response, 
            :question => question, 
            :response => 20000 + rand(60000),
            :comments => [nil,Faker::Lorem.sentence][rand(2)])
        else
          response = Factory.build(
            :textual_response, 
            :question => question, 
            :response => Faker::Lorem.sentence,
            :numerical_response => nil)
        end

        responses << response
      end

      if invitation.is_a?(SurveyInvitation)
        participation = Factory(
          :participation, 
          :survey => survey, 
          :participant => invitation.invitee, 
          :responses => responses)
      else
        participation = Factory(
          :participation, 
          :survey => survey, 
          :participant => invitation, 
          :responses => responses)
      end unless responses.size == 0
    end  
    
    puts "generating responses complete" 
  end
  
  # closes a portion of the surveys
  def close_surveys
    surveys = Survey.all
    
    puts "closing #{CLOSE_RATE*100.to_f}% of surveys (about #{(CLOSE_RATE*surveys.size.to_f).floor})..."      
    
    surveys.each_with_index do |survey, index|
      next if rand > CLOSE_RATE # ((CLOSE_RATE*100)% chance of survey closed)
      
      Survey.transaction do
        survey.end_date = Time.now - 1.minute
        survey.save
        survey.finish
        survey.save
      end
      
    end
    
    puts "closing surveys complete"
  end
  
  def print_percent_complete(index,total)
    puts "#{((index.to_f/total.to_f)*100).floor}% complete" if index % 10 == 0  
  end

end
