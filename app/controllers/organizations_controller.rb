class OrganizationsController < ApplicationController
  before_filter :login_required, :except => [ :show, :report_pending ]
  before_filter :login_or_survey_invitation_required, :only => [ :show, :report_pending ]
  layout :logged_in_or_invited_layout 

  def show 

    if logged_in?
      @organization = Organization.find(params[:id])  
       
    else 
      # The user is logged in as a survey invitation- we need to ensure the organization requested is 
      #  invited to/sponsoring that survey as do not want to expose all users to external survey invitees
      
      @survey = Survey.find(params[:survey_id])
      
      if params[:id] == @survey.sponsor.id.to_s then  
        # the requested organization is the survey sponsor
        @organization = @survey.sponsor
      else 
        # the requested organization is invited to the survey
        @organization = @survey.invitees.find(params[:id]) 
      end
    end
    
    # if a user attempts to view their own show page, instead show them their account edit page
    if @organization == current_organization then
      redirect_to edit_account_path
    else
      respond_to do |wants|
        wants.html # render template
      end
    end
  end
  
  # Search is called from the invitation forms; it retrieves results for the auto-suggest box.
  def search   
  
    @search_text = params[:search_text] || ""
    
    escaped_search_text = Riddle.escape(@search_text) 
    
    # Search only non-uninitialized association members
    organizations = Organization.search escaped_search_text,
      :with     => { :uninitialized_association_member => 0 },
      :per_page => 1000,
      :star     => true      
    
    if current_association then
      
      # Search uninitialized association members
      association_organizations = Organization.search escaped_search_text, 
        :with     => { 
          :association_ids                     => current_association.id, 
          :uninitialized_association_member => 1 
        },
        :per_page => 1000,
        :star     => true
      
      # Join the association/non-association member results together
      organizations = organizations.concat(association_organizations)
    end
               
    respond_to do |wants|
    
      wants.json do
      
        # When rendering the organizations as json, we only want to render certain attributes/methods. Rendering
        #  all of the attributes hurts performance as well as exposes sensitive information that
        #  should not be shared.
        render :json => organizations.sort {|x,y| x.name <=> y.name }.to_json(
          :only    => [:name, :location, :id, :contact_name],
          :methods => 'name_and_location')
                                               
      end
      
    end
    
  end
  
  def search_for_association_list
    search_text = params[:search_text] || ""
    
    escaped_search_text = Riddle.escape(search_text)
    distance = params[:distance] || ""
    size = params[:size] || ""
    naics = params[:naics] || ""
    
    search_options = {
    :per_page  => 1000,
    :star      => :true
    }
    
    with_params = {
      :association_ids => current_association.id
    }
    if distance != "" then
      search_options.merge!(:geo       => [current_organization.latitude, current_organization.longitude])
      with_params.merge!("@geodist" => 0.0..(distance.to_f * Organization::METERS_PER_MILE) )
    end
    
    if size != "" then
      size_array = size.split(",")
      with_params.merge!(:size => size_array[0].to_i..size_array[1].to_i)
    end
    
    if naics != "" then
      with_params.merge!(:naics_code => NaicsClassification.find(naics).full_set)
    end

    organizations = Organization.search escaped_search_text, search_options.merge!(:with => with_params)
    respond_to do |wants|
      wants.json do
        # Remove the current organization, as returning it in the search tricks the JS into thinking there are valid search results
        render :json => organizations.delete_if{|x| x == current_organization}.sort {|x,y| x.name <=> y.name }.to_json(
          :only    => [:id])
      end
    end
  end
  
  # Action taken if a user reports suspicious activity related to a pending organization
  def report_pending
    organization = Organization.pending.find(params[:id])  
    organization.report 
    
    flash[:notice] = "This user has been reported."
    # Show the same page, or redirect to surveys path, if the user clicked an email link
    redirect_to request.env['HTTP_REFERER'] || surveys_path
  end
  
  # JS only function for inviting an organization to a survey
  def invite_to_survey
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    @invitation = find_invitee_and_create_invitation(@survey)
    @invitation.send_invitation! if @invitation.valid?
    
    respond_to do |wants|
      wants.js
    end
  end
  
  # JS only function for inviting an organization to a network
  def invite_to_network
    @network = current_organization.owned_networks.find(params[:network_id]) 
    @invitation = find_invitee_and_create_invitation(@network)
    
    respond_to do |wants|
      wants.js
    end
  end
  
  private 
  
  # This will locate the invitee and create an invitation from the current organization
  #  to the specified network or survey.
  #
  def find_invitee_and_create_invitation(network_or_survey)
    organization = Organization.find(params[:id])
    return network_or_survey.invitations.create(:invitee => organization, :inviter => current_organization)
  end
end
