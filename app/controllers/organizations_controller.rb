class OrganizationsController < ApplicationController
  before_filter :login_required, :only => [ :index, :search, :invite_to_survey, :invite_to_network ]
  before_filter :login_or_survey_invitation_required, :except => [ :index, :search, :invite_to_survey, :invite_to_network ]
  layout :logged_in_or_invited_layout 

  def index
	  
    respond_to do |wants|
      wants.xml do
        @organizations = Organization.find(:all)
        render :xml => @organizations.to_xml 
      end
    end
  end
  
  def show 
  
    if params[:survey_id].blank?
      @organization = Organization.find(params[:id])   
    else # Logged in as a survey invitation- need to ensure the organization is invited/sponsoring that survey
      @survey = Survey.find(params[:survey_id])
      if params[:id] == @survey.sponsor.id.to_s then
        @organization = @survey.sponsor
      else 
        @organization = @survey.invitees.find(params[:id])
      end
    end
    
    if @organization == current_organization then
      redirect_to edit_account_path
    else
      respond_to do |wants|
        wants.html # render template
        wants.xml do
           render :xml => @organization.to_xml
        end
      end
    end
  end
  
  def search   
  
    @search_text = params[:search_text] || ""
    
    @esc_search_text = Riddle.escape(@search_text) 
    
    # this basically says, find everything that matches the query, and everything that matches the query and industry
    # this will give a higher score to organizations with the same industry, but will not allow irrelevant matches
    @search_query = "#{@esc_search_text}* #{@esc_search_text}* | @industry \"#{current_organization.industry}\""    
    
    @search_params = {
      :geo => [current_organization.latitude, current_organization.longitude],
      :conditions => {},
      :with => {},
      :match_mode => @esc_search_text.blank? ? :fullscan : :extended, # this allows us to use boolean operators in the search query, or forego the query all together if the search string was empty
      :order => '@weight desc, @geodist asc' # sort by relevance, then distance
    }
        
       
    respond_to do |wants|
      wants.html do
        @organizations = Organization.search @search_query, @search_params
      end
      wants.json do
        organizations = Organization.search @search_query, @search_params.merge(:per_page => 1000, :order => :name);
        render :json => organizations.to_json(:only => [:name, :location, :id, :contact_name],
                                               :methods => 'name_and_location')
      end
    end
  end
  
  #JS only functions for inviting an organization to survey and network
  def invite_to_survey
    @organization = Organization.find(params[:id]) 
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    @invitation = @survey.invitations.new(:inviter => current_organization, :invitee => @organization)
    
    @invitation.save
    respond_to do |wants|
      wants.js
    end
  end
  
  def invite_to_network
    @network = current_organization.owned_networks.find(params[:network_id]) 
    @organization = Organization.find(params[:id])
    @invitation = @network.invitations.new(:invitee => @organization, :inviter => current_organization)
    
    @invitation.save
    respond_to do |wants|
      wants.js
    end
  end
end
