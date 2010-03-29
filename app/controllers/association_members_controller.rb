class AssociationMembersController < ApplicationController
  include NewOrganizationHelper
  layout 'front'
  filter_parameter_logging :password  
  ssl_required :sign_in
  before_filter :association_required
  
  # Association member login is handled here
  # This will also handle login creation for uninitialized association members
  def sign_in
        
    # If they are already logged in, send them to the surveys page
    if logged_in?
      redirect_to surveys_path
    end
  
    @login         = params[:email]
    invitation_key = params[:key]
    
    # If there was a redirect from account#new, the session may have been lost.
    # Check to see if the user has an invitation, if so, we can activate the account.
    # Save the invitation in the session, in case the key is lost (such as with a failed login)
    session[:invitation] = ExternalInvitation.find_by_key(invitation_key) unless invitation_key.blank?
    
    # For a GET request, show the sign in form  
    if request.get? then
    
      # Be sure the sign in request is submitted with https
      @form_options = Rails.env.production? ? {
        :protocol => 'https://', 
        :host => "www.#{current_subdomain}.compsage.com", 
        :only_path => false} : {} 
    
    # For a PUT or POST request, attempt to authenticate and/or create a login    
    else
    
      logout_keeping_session!
      
      password                      = params[:password]
      password_confirmation         = params[:password_confirmation]
      submitted_returning_firm_form = !params[:submitted_returning_firm_form].blank?
      @remember_me                  = params[:remember_me]
      @association_member           = current_association.organizations.find_by_email(@login)
      organization                  = Organization.authenticate(@login, password)
      should_initialize             = @association_member && @association_member.is_uninitialized_association_member?
      
      # The email belongs to an association member that either provided a valid login, or needs initialization
      if @association_member && (should_initialize || organization) then
                     
        if should_initialize

          # Account is uninitialized; attempt to create the login
          if !submitted_returning_firm_form && @association_member.create_login(
            current_association, 
            {
              :password => password, 
              :password_confirmation => password_confirmation
            }) then   
            
            organization = @association_member
            
            # Accepts the invitation, which will add the survey/network to the newly created organization
            send_email_and_move_invitations_to_new_organization(organization, session[:invitation])
            
          else
          
            # It is the user's first time logging in, but they did not enter their information
            #  in the 'Firt Time Logging In' form
            if submitted_returning_firm_form then
              flash.now[:error] = "Create a new password by filling in the 'First Time Logging In' section at the bottom right."
            end
          
            # There was a problem updating the organization, 
            #  the view will display any errors on the organization      
            render :action => 'sign_in'  
            return
            
          end                   
        
        end
        
        # Account is initialized; valid login
        new_cookie_flag = (@remember_me == "1")
        login_organization({
        :organization => organization, 
        :new_cookie_flag => new_cookie_flag, 
        :url => '/'})
              
      else
      
        # User provided bad email/password or incorrect association when attempting to log in
        note_failed_signin
        render :action => 'sign_in'   
      
      end
      
    end
   
  end
  
end
