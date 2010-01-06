class Association::SettingsController < Association::AssociationController
  before_filter :association_owner_login_required
  
  def show
    @predefined_questions = current_association_by_owner.predefined_questions
  end
end
