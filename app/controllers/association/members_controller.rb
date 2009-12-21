class Association::MembersController <  Association::AssociationController
  before_filter :association_owner_login_required

  def index
    @members = current_association_by_owner.organizations.paginate(:order => 'name',
                                                                   :per_page => 50,
                                                                   :page => params['page'])
  end
end
