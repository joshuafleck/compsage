class AssociationsController < ApplicationController
  layout :logged_in_or_invited_layout
  ssl_required :sign_in
  before_filter :association_owner_login_required, :only => [:edit, :update, :show]
  
  #this is the association owner login
  def sign_in
    if logged_in_as_association_owner?
      redirect_to associations_path
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
  
  def show
    @association = current_association_by_owner
  end
  
  def edit
    @association = current_association_by_owner
  end
  
  def update
    
  end

  private
  # Track failed login attempts
  def note_failed_signin
    flash.now[:error] = "Incorrect email or password"
    logger.warn "Failed association owner login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

end
