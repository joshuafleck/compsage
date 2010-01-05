class Association::SettingsController < Association::AssociationController
  def show
    @predefined_questions = current_association_by_owner.predefined_questions
  end
end
