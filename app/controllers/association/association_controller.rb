class Association::AssociationController < ApplicationController
  layout :association_layout

  protected

  def association_layout
    return logged_in_as_association_owner? ? 'association_owner_logged_in' : 'front'
  end
end
