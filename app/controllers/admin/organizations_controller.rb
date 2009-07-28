class Admin::OrganizationsController < Admin::AdminController
  def index
    # Bad idea, but it's admin only.
    order = params[:order] || 'name'
    @organizations = Organization.find(:all, :order => order, :include => :surveys).paginate(:page => params[:page])
  end
end
