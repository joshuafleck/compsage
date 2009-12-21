class Association::MembersController <  Association::AssociationController
  before_filter :association_owner_login_required

  def index
    @members = current_association_by_owner.organizations
  end
end
