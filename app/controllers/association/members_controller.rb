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
    @member = current_association_by_owner.new_member(params[:organization])

    if @member.save then
      flash[:message] = "Member created" 
      redirect_to association_members_path
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
      redirect_to association_members_path
    else
      render :action => :edit
    end
  end

  def upload
    if request.post? then
      @importer = AssociationMemberImport.new(params[:flags])
      @importer.association = current_association_by_owner
      
      # ensure presence of some file
      if params[:csv_file].nil? || params[:csv_file] == "" then
        flash[:notice] = "You must specify a CSV file to upload"
        render :upload
        return # do not try to import, no file!
      end
      
      @importer.file = params[:csv_file]

      Organization.suspended_delta do
        @importer.import!
      end

      render :upload_success
    end
  end

  def destroy
    @member = current_association_by_owner.organizations.find(params[:id])

    @member.leave_association(current_association_by_owner)
    
    flash[:message] = "Member removed"
    redirect_to association_members_path
  end
end
