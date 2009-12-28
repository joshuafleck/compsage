class Association::MembersController <  Association::AssociationController
  before_filter :association_owner_login_required

  def index
    @members = current_association_by_owner.organizations.paginate(:order => 'name',
                                                                   :per_page => 50,
                                                                   :page => params['page'])
  end

  def new
    @member = current_association_by_owner.organizations.new
  end

  def create
    @member = current_association_by_owner.organizations.new
    @member.attributes = params[:organization]
    @member.associations << current_association_by_owner

    @member.is_uninitialized_association_member = true

    if @member.save then
      flash[:message] = "Member created" 
      redirect_to :action => :index
    else
      render :action => :new
    end
  end

  def edit
    @member = current_association_by_owner.organizations.find(params[:id])
  end

  def update
    @member = current_association_by_owner.organizations.find(params[:id])
    @member.attributes = params[:organization]

    if @member.save then
      flash[:message] = "Member updated" 
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end

  def destroy
    @member = current_association_by_owner.organizations.find(params[:id])

    @member.leave_association(current_association_by_owner)
    
    flash[:message] = "Member removed"
    redirect_to :action => :index
  end
end
