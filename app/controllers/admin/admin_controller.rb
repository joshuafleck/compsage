class Admin::AdminController < ApplicationController
  before_filter :login_required
  layout "admin"

  private

  def authorized?
    super && current_organization.admin?
  end
end
