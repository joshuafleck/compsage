require 'rubygems'
require 'factory_girl'
require 'faker'

namespace :data_generator do
  task :finished_survey => :environment do
    sponsor = Organization.first
    survey = Factory(:survey, :job_title => Faker::Company.catch_phrase, :sponsor => sponsor)
    
    questions = []
    #anywhere between 3 and 8 questions
    (rand(5) + 3).times do
      
      question_type = case rand(3)
      when 0 # create numerical response
        'numerical_field'
      when 1 # create textual response
        'text_field'
      when 2 # create multiple choice
        'radio'
      end
      
      if question_type == 'radio' then
        options = ["option 1", "option 2", "option 3", "option 4"]
      else
        options = nil
      end

      question = Factory(:question, :survey => survey, :question_type => question_type, :options => options) 
      questions << question
    end

    invitations = []
    current_org = 1
    # between 5 and 10 invitations  
    (rand(5)+6).times do
      if current_org < Organization.count && rand(2) > 0 then
        invitee = Organization.all[current_org]
        invite = Factory(:survey_invitation, :inviter => sponsor, :invitee => invitee, :survey => survey)
        current_org += 1
      else
        invite = Factory(:external_survey_invitation, :inviter => sponsor, :survey => survey)
      end

      invitations << invite
    end

    participations = []
    invitations.each do |invitation|
      next if rand(5) == 0 # (80% chance of participation)
      
      # build responses.
      responses = []
      questions.each do |question|
        next if rand(5) == 0 # (80% chance of answering a question)
        
        case question.question_type
        when 'numerical_field'
          response = Factory.build(:response, :question => question, :numerical_response => 20000 + rand(60000))
        when 'radio'
          response = Factory.build(:response, :question => question, :numerical_response => rand(4))
        else
          response = Factory.build(:response, :question => question, :textual_response => Faker::Lorem.sentence, :numerical_response => nil)
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
end
