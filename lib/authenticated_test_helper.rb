module AuthenticatedTestHelper
  # Sets the current organization in the session from the organization fixtures.
  def login_as_organization(organization)
    @request.session[:organization_id] = organization ? organization.object_id : nil
    controller.stub!(:requires_login).and_return(true)
    controller.stub!(:login_or_survey_invitation_required).and_return(true)
    controller.stub!(:current_organization).and_return(organization)
    controller.stub!(:current_organization_or_survey_invitation).and_return(organization)
  end
  
  # Sets the current invitation in the session from the invitation fixtures.
  def login_as_survey_invitation(invitation)
    @request.session[:external_survey_invitation_id] = invitation ? invitation.object_id : nil
    controller.stub!(:requires_login).and_return(true)
    controller.stub!(:requires_login_or_survey_invitation).and_return(true)
    controller.stub!(:current_survey_invitation).and_return(invitation)
    controller.stub!(:current_organization_or_survey_invitation).and_return(invitation)
  end
  
  def login_as_association(association)
    @request.session[:association_id] = association.id
    controller.stub!(:association_owner_login_required).and_return(true)
    controller.stub!(:current_association_by_owner).and_return(association)
  end

  # Logs in as the specified entity, depending on the type.
  def login_as(entity)
    if entity.is_a?(Organization)
      login_as_organization(entity)
    elsif entity.is_a?(Association)
      login_as_association(entity)
    else
      login_as_survey_invitation(entity)
    end
  end


  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'test') : nil
  end
end
