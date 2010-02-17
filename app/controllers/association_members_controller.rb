class AssociationMembersController < ApplicationController
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
  
    @login = params[:email]
      
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
      
      password              = params[:password]
      password_confirmation = params[:password_confirmation]
      @remember_me          = params[:remember_me]
      @association_member   = current_association.organizations.find_by_email(@login)
      organization          = Organization.authenticate(@login, password)
      should_initialize     = @association_member && @association_member.is_uninitialized_association_member?
      
      # The email belongs to an association member that either provided a valid login, or needs initialization
      if @association_member && (should_initialize || organization) then
                     
        if should_initialize        

          # Account is uninitialized; attempt to create the login
          if @association_member.create_login(current_association, 
            {
              :password => password, 
              :password_confirmation => password_confirmation
            }) then   
            
            organization = @association_member
            
            Notifier.deliver_new_organization_notification(@association_member, current_association)         
            
          else
          
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
