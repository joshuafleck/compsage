class Association::SessionsController < ApplicationController
  layout :association_layout
  ssl_required :sign_in
  before_filter :association_owner_login_required, :only => [:edit, :update, :show]
  
  #this is the association owner login
  def new
    if logged_in_as_association_owner?
      redirect_to association_members_path
    end
    
    #show the form for get, authenticate post
    if request.post?
      logout_keeping_owner_session
      association = Association.authenticate(params[:email], params[:password])
      if association
        self.current_association_by_owner = association
        redirect_back_or_default('/')
        return
      else
        note_failed_signin
        @login       = params[:email]
        @remember_me = params[:remember_me]
      end
    end
    
  end
  

  private
  # Track failed login attempts
  def note_failed_signin
    flash.now[:error] = "Incorrect email or password"
    logger.warn "Failed association owner login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  def association_layout
    return logged_in_as_association_owner? ? 'association_owner_logged_in' : 'front'
  end

end
