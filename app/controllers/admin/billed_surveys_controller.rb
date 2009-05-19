class Admin::BilledSurveysController < Admin::AdminController
  def index
    @surveys = Survey.closed
  end
end
