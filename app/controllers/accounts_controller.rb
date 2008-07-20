class AccountsController < ApplicationController
  before_filter :login_required, :except => [ :new , :create ]
  layout :logged_in_or_invited_layout 
	
	def show
	
	  @organization = current_organization
	  
	  respond_to do |wants|
      wants.html
      wants.xml do
      	render :xml => @organization.to_xml 
      end
    end
	end
	
	def new
	  
	  #The external invitation can be found in the session if it is an external survey invitation, otherwise, check the URL for a key
	  @external_invitation = current_survey_invitation || Invitation.find_by_key(params[:key])
	   
	  @organization = Organization.new
	  
	  #Prepopulate the name and email fields automagically
	  @organization.contact_name = @external_invitation.name
	  @organization.email = @external_invitation.email
    
    respond_to do |wants|
      wants.html {
        #Show a different layout if the user is replying with an external survey invitation
        render :layout => 'survey_invitation_logged_in' if logged_in_from_survey_invitation?}
    end
	end
	
	def edit
	  
  	@organization = current_organization
	end
	
	def create
	
	  @external_invitation = Invitation.find_by_key(params[:key])
	  
	  @organization = Organization.new(params[:organization])
	  	
    #If the user was invited via ExternalNetworkInvitation, add the organization to the network
    if @external_invitation.is_a?(ExternalNetworkInvitation) then
      @organization.networks << @external_invitation.network
    end
        
    #Save the organization and set the logo
    if @organization.save && @organization.set_logo(params[:logo]) then
      #Clear the existing session (in case the user is logged in as an external survey invitation)
      logout_killing_session!
      
      respond_to do |wants|
        wants.html {         
          flash[:notice] = "Your account was created successfully."
          redirect_to new_session_path() }      
        wants.xml do
          render :status => :created
        end
      end
    else
      respond_to do |wants|
        wants.html do
          render :action => 'new'
        end
        wants.xml do
          render :xml => @organization.errors.to_xml, :status => 422
        end
      end
    end
	end
	
	def update
	
	  @organization = current_organization  
     	    
    if @organization.update_attributes(params[:organization]) && @organization.set_logo(params[:logo]) then
      respond_to do |wants|
        wants.html do
          flash[:notice] = "Your account was updated successfully."
          redirect_to account_path
        end
        wants.xml do
          render :status => :ok
        end
      end
    else
      respond_to do |wants|
        wants.html do
          render :action => 'edit'
        end
        wants.xml do
          render :xml => @organization.errors.to_xml, :status => 422
        end
      end
    end
	end

  private
    def logged_in_or_invited_layout
      logged_in_from_survey_invitation? ? "survey_invitation_logged_in" : (logged_in? ? "logged_in" : "front_with_invitation")
    end
      
end
