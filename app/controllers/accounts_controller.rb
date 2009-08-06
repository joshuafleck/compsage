class AccountsController < ApplicationController
  before_filter :login_required, :except => [ :new , :create, :forgot, :reset ]
  layout :logged_in_or_invited_layout 
  filter_parameter_logging :password
  
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
  
    # save the network invitation in the session, in case the user navigates away from this page
    session[:external_network_invitation] = ExternalNetworkInvitation.find_by_key(params[:key]) unless params[:key].blank?
    
    #The external invitation can be found in the session if it is an external survey invitation, 
    # otherwise, check the URL for a key
    @external_invitation = current_survey_invitation || session[:external_network_invitation]
    
    #if a key is provided, also check for a pending account
    @pending_account = PendingAccount.find_by_key(params[:key])
    
    if @external_invitation then
      #Prepopulate the name and email fields automagically
      @organization = Organization.new({
        :name => @external_invitation.organization_name,
        :email => @external_invitation.email
      }) 
    elsif @pending_account
      @organization = Organization.new({
        :name => @pending_account.organization_name,
        :email => @pending_account.email,
        :contact_name => @pending_account.contact_first_name + " " + @pending_account.contact_last_name,
      })
    else
      redirect_to new_session_path
    end
        
  end
  
  def edit
    @organization = current_organization
  end
  
  def create
  
    @external_invitation = ExternalInvitation.find_by_key(params[:key])
    @pending_account = PendingAccount.find_by_key(params[:key])
    
    @organization = Organization.new(params[:organization])
        
    #Save the organization and set the logo if there was a valid external invitation
    if @external_invitation && @organization.save then
          
      #If the user was invited via network invitation, add the organization to the network and delete the invite
      if @external_invitation.is_a?(ExternalNetworkInvitation) then
        @organization.networks << @external_invitation.network
        @external_invitation.destroy
        
      #If the user was invited via a survey invitation, move any objects created over to the new organization
      elsif @external_invitation.is_a?(ExternalSurveyInvitation) then
      
        # Move the participation to the new organization, and create a survey subscription
        @external_invitation.participations.each do |participation|
          @organization.participations << participation
          SurveySubscription.create!(
            :organization => @organization,
            :survey => @external_invitation.survey,
            :relationship => 'participant')        
        end
        
        # Move any discussions to the new organization
        @external_invitation.discussions.each do |discussion|
          @organization.discussions << discussion 
        end                
        
        #Convert the external invitation to a regular invitation, so the organization still shows as invited
        @external_invitation.type = 'SurveyInvitation'
        @external_invitation.save!
        @survey_invitation = SurveyInvitation.find(@external_invitation.id)
        @survey_invitation.aasm_state = @organization.participations.count > 0 ? 'fulfilled' : 'sent'
        @organization.survey_invitations << @survey_invitation                
      
      end
    
      #Clear the existing session (in case the user is logged in as an external survey invitation)
      logout_killing_session!
      
      respond_to do |wants|
        wants.html do
          #Log the user in, and bring them to the surveys page        
          organization = Organization.authenticate(@organization.email, params[:organization][:password])         
          # Set first_login in the session so we can show a tutorial if the user is new.
          session[:first_login] = true     
          organization.last_login_at = Time.now
          organization.save       
          self.current_organization = organization if organization
          redirect_to surveys_path
        end   
        wants.xml do
          render :status => :created
        end
      end
    #check for pending account
    elsif @pending_account && @organization.save then
      @pending_account.destroy
      respond_to do |wants|
        wants.html do
          #Log the user in, and bring them to the surveys page        
          organization = Organization.authenticate(@organization.email, params[:organization][:password])         
          # Set first_login in the session so we can show a tutorial if the user is new.
          session[:first_login] = true     
          organization.last_login_at = Time.now
          organization.save       
          self.current_organization = organization if organization
          redirect_to surveys_path
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
          
    if @organization.update_attributes(params[:organization]) then
      respond_to do |wants|
        wants.html do
          flash[:notice] = "Your account was updated successfully."
          redirect_to edit_account_path
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
            flash[:notice] = "Email sent to #{@organization.email}."
            redirect_to new_session_path 
          end
        end
      else
        flash.now[:notice] = "There was no account found for #{params[:email]}."
      end
    end
  end
  
  #allow user to update password if key is valid
  def reset
    @organization = Organization.find_by_reset_password_key(params[:key]) unless params[:key].blank?
    #if we have a post, attempt to reset the password    
    if request.post?
      if params[:password] == params[:password_confirmation]
        if @organization.update_attributes(:password => params[:password], :password_confirmation => params[:password_confirmation])
          @organization.delete_reset_key
          respond_to do |wants|
            wants.html do
              flash[:notice] = "Your password has been updated for #{@organization.email}!"
              redirect_to new_session_path
            end
          end
        else
          render :action => :reset
        end
      else
        flash.now[:notice] = "Password mismatch - Please try again."
      end
    #if we have a request, check to see if the key is valid, then grant access
    else
      #do not allow an invalid key, or an expired key.
      if @organization.nil?
        respond_to do |wants|
          wants.html do
            flash[:notice] = "We were not able to access this page."
            redirect_to new_session_path
          end
        end
      elsif @organization.reset_password_key_expires_at < Time.now
        respond_to do |wants|
          wants.html do
            flash[:notice] = "Your key has expired - please request a new key."
            @organization.delete_reset_key
            redirect_to new_session_path
          end
        end
      end
    end
  end

end
