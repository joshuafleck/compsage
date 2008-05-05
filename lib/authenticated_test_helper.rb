module AuthenticatedTestHelper
  # Sets the current organization in the session from the organization fixtures.
  def login_as(organization)
    @request.session[:organization_id] = organization ? organization.id : nil
    controller.stub!(:requires_login).and_return(true)
    controller.stub!(:current_organization).and_return(organization)
    controller.stub!(:current_organization_or_invitation).and_return(organization)
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'test') : nil
  end
end
