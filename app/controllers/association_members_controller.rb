class AssociationMembersController < ApplicationController
  layout 'front'
  filter_parameter_logging :password  
  ssl_required :sign_in
  before_filter :association_required
  
  # Association member login is handled here
  # This will also handle login creation for uninitialized association members
  def sign_in
  
    if logged_in?
      redirect_to surveys_path
    end
  
    @login = params[:email]
      
    # For a GET request, show the form  
    if request.get? then
    
      # TODO - fix host with subdomain
      @form_options = Rails.env.production? ? {
        :protocol => 'https://', 
        :host => 'www.compsage.com', 
        :only_path => false} : {} 
    
    # For a PUT or POST request, attempt to authenticate       
    else
    
      logout_keeping_session!
      
      password              = params[:password]
      password_confirmation = params[:password_confirmation]
      @remember_me          = params[:remember_me]
      @association_member   = current_association.organizations.find_by_email(@login)
      organization          = Organization.authenticate(@login, password)
      should_initialize     = @association_member && @association_member.is_uninitialized_association_member?
      
      if @association_member && (should_initialize || organization) then
                     
        if organization
        
          # Account is initialized; valid login
          login_organization(organization)
          new_cookie_flag = (@remember_me == "1")
          handle_remember_cookie! new_cookie_flag
          redirect_back_or_default('/')
          
        elsif @association_member.can_create_login?
        
          # Account is uninitialized, attempt to create the login
          if @association_member.create_login(current_association, 
            {
              :password => password, 
              :password_confirmation => password_confirmation
            }) then            
            
            # The login was created auccessfully
            render :action => 'login_received' 
             
          else
          
            # There was a problem updating the organization, 
            #  the view will display any errors on the organization      
            render :action => 'sign_in'  
            
          end 
          
        else
          
            # Possible email bomb            
            flash.now[:notice] = "You have already requested account initialization. If you did not receive an email containing a link to initialize your account, <a href=\"#{contact_path}\">let us know</a>."
            render :action => 'sign_in'  
            
        end       
                
      else
      
        # User provided bad email/password or incorrect association when attempting to log in
        note_failed_signin
        render :action => 'sign_in'   
      
      end
      
    end
   
    # TODO Prompt for email and password in view, auto expand link for 'First time loggin in?' the opens password confirmation box
  end
  
  def login_received
    # Show a view stating their login information was received, they need to check their email to activate account
  end
  
  # This will look up the organization by the provided key.
  # If an organization is found, it will be initialized and logged in
  def initialize_account
    association_member = current_association.organizations.find_by_association_member_initialization_key(params[:key])
    
    if association_member then
      
      # Attempt to initialize the organization, log them in
      association_member.is_uninitialized_association_member = false
      association_member.save!
      login_organization(association_member)
      redirect_back_or_default('/')  
          
    else
    
      # There was no one belonging to this association with a matching key
      flash.now[:notice] = "We are unable to initialize your account at this time. If the problem persists, <a href=\"#{contact_path}\">let us know</a>."
      render :action => 'sign_in'
      
    end
  end
  
  protected
  
  # TODO - remove duplication with session_controller methods

  # Track failed login attempts
  def note_failed_signin
    flash.now[:error] = "Incorrect email or password"
    logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
  
  # Saves the organization in the session, sets last login date
  def login_organization(organization)
      # Set first_login in the session so we can show a tutorial if the user is new.
      session[:first_login] = true if organization.last_login_at.nil?
      
      organization.last_login_at = Time.now
      organization.save

      self.current_organization = organization
  end  
  
  private
  
  # Will redirect to the new session page if an association cannot be found by the subdomain
  def association_required
    if !current_association then
      # TODO improve this message, strip subdomain off of URL?
      flash[:error] = "We do not know of the association: #{current_subdomain}"
      redirect_to new_session_path
    end
  end

end
