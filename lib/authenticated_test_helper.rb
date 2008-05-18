module AuthenticatedTestHelper
  # Sets the current organization in the session from the organization fixtures.
  def login_as_organization(organization)
    @request.session[:organization_id] = organization ? organization.id : nil
    controller.stub!(:requires_login).and_return(true)
    controller.stub!(:login_or_invite_required).and_return(true)
    controller.stub!(:current_organization).and_return(organization)
    controller.stub!(:current_organization_or_invitation).and_return(organization)
  end
  
  # Sets the current invitation in the session from the invitation fixtures.
  def login_as_invitation(invitation)
    @request.session[:external_invitation_id] = invitation ? invitation.id : nil
    controller.stub!(:requires_login).and_return(true)
    controller.stub!(:requires_login_or_invite).and_return(true)
    controller.stub!(:current_invitation).and_return(invitation)
    controller.stub!(:current_organization_or_invitation).and_return(invitation)
  end
  
  #determines whether to login via invitation or organization
  def login_as(organization_or_invitation)
    if organization_or_invitation.is_a?(Organization)
      login_as_organization(organization_or_invitation)
    else
      login_as_invitation(organization_or_invitation)
    end
  end


  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'test') : nil
  end
end
