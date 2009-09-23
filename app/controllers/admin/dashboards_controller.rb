class Admin::DashboardsController < Admin::AdminController
  def show
    @latest_surveys = Survey.without_aasm_state(:pending).find(:all, :order => 'created_at DESC', :limit => 10)
    @new_organizations = Organization.find(:all, :order => 'created_at DESC', :limit => 10)
    @reported_discussions = Discussion.reported.find(:all, :limit => 20)
  end
end
