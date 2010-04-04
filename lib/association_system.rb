module AssociationSystem

  def self.included(base)
    base.send :helper_method, :current_association
  end

  def current_association
    return nil unless current_subdomain
    
    @association ||= Association.find_by_subdomain(current_subdomain)
  end
  
  
  module AssociationAuthenticatedSystem
    protected
    
    def association_owner_login_required
      logged_in_as_association_owner? || association_access_denied
    end
    
    def logged_in_as_association_owner?
      !!current_association_by_owner
    end
    
    def current_association_by_owner
      @current_association_by_owner ||= (login_owner_from_session || login_owner_from_basic_auth ) unless @current_association_owner == false
    end
    
    # Store the given association id in the session.
    def current_association_by_owner=(new_association_owner)
      session[:association_id] = new_association_owner ? new_association_owner.id : nil
      @current_association_owner = new_association_owner || false
    end
    
    def login_owner_from_basic_auth
      authenticate_with_http_basic do |login, password|
        self.current_association_by_owner = Association.authenticate(login, password)
      end
    end
    
    def login_owner_from_session
      self.current_association_by_owner = Association.find_by_id(session[:association_id]) if session[:association_id]
    end
    
    def logout_killing_owner_session
      logout_keeping_owner_session
      reset_session
    end
    
    def logout_keeping_owner_session
      @current_association_by_owner = false
      session[:association_id] = nil
    end
    
    def association_access_denied
      respond_to do |format|
        format.html do
          store_location
          redirect_to new_association_session_path
        end
      end
    end    
  
    # Will render 404 (not found) if the association cannot be found by the subdomain
    def association_required
      if !current_association then
        render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
      end
    end
    
    # Log a failed Association owner sign-in
    def note_failed_signin
      flash.now[:error] = "Incorrect email or password"
      logger.warn "Failed association owner login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
    end  
    
    def self.included(base)
      base.send :helper_method, :current_association_by_owner, :logged_in_as_association_owner?, :association_owner_login_required, :association_required  if base.respond_to? :helper_method
    end
  end
end
