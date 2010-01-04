class Association::SessionsController < Association::AssociationController
  ssl_required :sign_in
  
  # This is the association owner login
  def new
    if logged_in_as_association_owner?
      redirect_to association_members_path
    end
  end

  def create
    logout_keeping_owner_session
    association = Association.authenticate(params[:email], params[:password])
    if association
      self.current_association_by_owner = association
      redirect_back_or_default('/association')
      return
    else
      note_failed_signin
      @login       = params[:email]
      @remember_me = params[:remember_me]

      render :action => 'new'
    end 
  end

  def destroy
    logout_killing_session!
    redirect_back_or_default('/association')
  end
 

  private
  # Track failed login attempts
  def note_failed_signin
    flash.now[:error] = "Incorrect email or password"
    logger.warn "Failed association owner login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

end
