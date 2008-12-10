class AccountsController < ApplicationController
  before_filter :login_required, :except => [ :new , :create, :forgot, :reset ]
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
	   
	  #Prepopulate the name and email fields automagically
	  @organization = Organization.new({
	    :name => @external_invitation.organization_name,
	    :contact_name => @external_invitation.name,
	    :email => @external_invitation.email
	  })
	      
	end
	
	def edit
	  
  	@organization = current_organization
  	
	end
	
	def create
	
	  @external_invitation = Invitation.find_by_key(params[:key])
	  
	  @organization = Organization.new(params[:organization])
        
    #Save the organization and set the logo
    if @organization.save && @organization.set_logo(params[:logo]) then
    	  	
      #If the user was invited via network invitation, add the organization to the network
      if @external_invitation.is_a?(ExternalNetworkInvitation) then
        @organization.networks << @external_invitation.network
        
      #If the user was invited via a survey invitation and has completed the survey, 
      # attribute their participation to their organization
      elsif @external_invitation.is_a?(ExternalSurveyInvitation) && @external_invitation.participations.count > 0 then
      
        @organization.participations << @external_invitation.participations.find(:first)
        SurveySubscription.create!(
          :organization => @organization,
          :survey => @external_invitation.survey,
          :relationship => 'participant'
        )
        
        #Convert the external invitation to a regular invitation, so the organization still shows as invited
        @external_invitation.type = 'SurveyInvitation'
        @external_invitation.save!
        @survey_invitation = SurveyInvitation.find(@external_invitation.id)
        @organization.survey_invitations << @survey_invitation
        
      end
    
      #Clear the existing session (in case the user is logged in as an external survey invitation)
      logout_killing_session!
      
      respond_to do |wants|
        wants.html do         
          flash[:notice] = "Your account was created successfully."
          redirect_to new_session_path()
        end   
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
	
	#forgot password functionality
	def forgot
	  if request.post?
	    @organization = Organization.find_by_email(params[:email])
	    if !@organization.nil? then
        @organization.create_reset_key
        Notifier.deliver_reset_password_key_notification(@organization)
        respond_to do |wants|
          wants.html do
            flash[:notice] = "Password reset email successfully sent to #{@organization.email}."
          end
        end
      else
        flash[:notice] = "There was no account found for #{params[:email]}."
      end
    end
  end
  
  #allow user to update password if key is valid
  def reset
    @organization = Organization.find_by_reset_password_key(params[:key]) unless params[:key].nil?
    #if we have a post, attempt to reset the password    
    if request.post?
      if params[:password] == params[:password_confirmation]
        if @organization.update_attributes(:password => params[:password], :password_confirmation => params[:password_confirmation])
          @organization.delete_reset_key
          respond_to do |wants|
            wants.html do
              flash[:notice] = "Your password has been successfully updated for #{@organization.email}!"
              redirect_back_or_default('/')
            end
          end
        else
          render :action => :reset
        end
      else
        respond_to do |wants|
          flash[:notice] = "Password mismatch - Please try again."
        end
      end
    #if we have a request, check to see if the key is valid, then grant access
    else
      #do not allow an invalid key, or an expired key.
      if @organization.nil?
        respond_to do |wants|
          wants.html do
            flash[:notice] = "We were not able to access this page."
            redirect_back_or_default('/')
          end
        end
      elsif @organization.reset_password_key_expires_at < Time.now
        respond_to do |wants|
          wants.html do
            flash[:notice] = "Your key has expired - please request a new key."
            @organization.delete_reset_key
            redirect_back_or_default('/')
          end
        end
      end
    end
  end

  private
  
  #Use a different layout depending on how the user has entered the application
  def logged_in_or_invited_layout
    logged_in_from_survey_invitation? ? "survey_invitation_logged_in" : (logged_in? ? "logged_in" : "front_with_invitation")
  end
end
