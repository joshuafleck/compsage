class Admin::BilledSurveysController < Admin::AdminController
  def index
    @surveys = Survey.with_aasm_state(:finished)
  end
end
