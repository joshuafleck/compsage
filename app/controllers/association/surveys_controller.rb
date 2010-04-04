class Association::SurveysController < Association::AssociationController
  # Handles the observation and billing aspects for an association owner.
  before_filter :association_owner_login_required

  def index
    @surveys = current_association_by_owner.surveys.with_aasm_state(:finished).paginate(:page => params[:page], :order => 'association_billing_status DESC, end_date DESC')
  end

  # Handle AJAX post from the index page.
  def update
    @survey = current_association_by_owner.surveys.find(params[:id])
    @survey.association_billing_status = params[:survey][:association_billing_status]
    @survey.save

    head :ok
  end
end
