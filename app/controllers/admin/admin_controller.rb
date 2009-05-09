class Admin::AdminController < ApplicationController
  before_filter :login_required

  private

  def authorized?
    super && current_organization.admin?
  end
end
