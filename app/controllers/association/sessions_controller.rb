class Association::SessionsController < Association::AssociationController
  ssl_required :sign_in
  # Handles the authentication for association owners. This is seperate from a standard CompSage account.
  # Login is handled on the /association level via the email stored on the Association model.
  
  # Association owner login
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
  
end
