class Association::SettingsController < Association::AssociationController
  before_filter :association_owner_login_required
  
  def show
    @association = current_association_by_owner
    @predefined_questions = current_association_by_owner.predefined_questions
  end

  def update
    @association = current_association_by_owner
    @association.attributes = params[:association]

    if @association.save then
      flash[:notice] = "Settings updated"
      redirect_to association_settings_path
    else
      @predefined_questions = current_association_by_owner.predefined_questions
      render :action => :show
    end
  end
end
