class Association::SettingsController < Association::AssociationController
  before_filter :association_owner_login_required
  
  def show
    @association = current_association_by_owner
  end

  def update
    @association = current_association_by_owner
    @association.attributes = params[:association]

    if @association.save then
      flash[:notice] = "Settings updated"
      redirect_to association_settings_path
    else
      render :action => :show
    end
  end
end
