class Admin::ReportedDiscussionsController < Admin::AdminController
  def reset
    d = Discussion.find(params[:id])
    d.times_reported = 0
    d.save

    redirect_to admin_dashboard_path
  end
end
