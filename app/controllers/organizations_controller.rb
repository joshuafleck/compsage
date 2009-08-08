class OrganizationsController < ApplicationController
  before_filter :login_required, :except => [ :show ]
  before_filter :login_or_survey_invitation_required, :only => [ :show ]
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
    
    @esc_search_text = Riddle.escape(@search_text) 
    
    # This basically says, find everything that matches the query, and everything that matches the query and industry
    #  this will give a higher score to organizations with the same industry, but will not allow irrelevant matches
    @search_query = "#{@esc_search_text}* #{@esc_search_text}* | @industry \"#{current_organization.industry}\""    
    
    # @geo: required for geodistance searching, which enables us tell how far away the organization is from the user
    # @match_mode: 
    #   fullscan, used if the search string is empty, this will bring back all organizations (similar to browse, but with sorting)
    #     TODO we lose industry ranking in fullscan mode, we need to still give higher rank to industry matches
    #   extended, allows us to use boolean operators in the search query
    # @order: sorts the organizations by relevance (e.g. name and industry), then distance
    @search_params = {
      :geo        => [current_organization.latitude, current_organization.longitude],
      :conditions => {},
      :with       => {},
      :match_mode => @esc_search_text.blank? ? :fullscan : :extended,
      :order      => '@weight desc, @geodist asc' 
    }
        
       
    respond_to do |wants|
    
      wants.json do
      
        organizations = Organization.search @search_query, @search_params.merge(:per_page => 1000, :order => :name);
        
        # When rendering the organizations as json, we only want to render certain attributes/methods. Rendering
        #  all of the attributes hurts performance as well as exposes sensitive information that
        #  should not be shared.
        render :json => organizations.to_json(:only => [:name, :location, :id, :contact_name],
                                               :methods => 'name_and_location')
                                               
      end
      
    end
    
  end
  
  # JS only function for inviting an organization to a survey
  def invite_to_survey
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    find_invitee_and_create_invitation(@survey)
    
    respond_to do |wants|
      wants.js
    end
  end
  
  # JS only function for inviting an organization to a network
  def invite_to_network
    @network = current_organization.owned_networks.find(params[:network_id]) 
    find_invitee_and_create_invitation(@network)
    
    respond_to do |wants|
      wants.js
    end
  end
  
  private 
  
  # This will locate the invitee and create an invitation from the current organization
  #  to the specified network or survey.
  #
  def find_invitee_and_create_invitation(network_or_survey)
    @organization = Organization.find(params[:id])
    @invitation = network_or_survey.invitations.create(:invitee => @organization, :inviter => current_organization)
  end
end
