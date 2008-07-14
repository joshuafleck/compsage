module AuthenticatedTestHelper
  # Sets the current organization in the session from the organization fixtures.
  def login_as(organization)
    @request.session[:organization_id] = organization ? organizations(organization).id : nil
  end

  def authorize_as(organization)
    @request.env["HTTP_AUTHORIZATION"] = organization ? ActionController::HttpAuthentication::Basic.encode_credentials(organizations(organization).login, 'monkey') : nil
  end
  
  # rspec
  def mock_organization
    organization = mock_model(Organization, :id => 1,
      :login  => 'user_name',
      :name   => 'U. Surname',
      :to_xml => "Organization-in-XML", :to_json => "Organization-in-JSON", 
      :errors => [])
    organization
  end  
end
