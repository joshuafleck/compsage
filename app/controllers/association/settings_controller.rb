class Association::SettingsController < Association::AssociationController
  def show
    @association = current_association_by_owner
  end
end
