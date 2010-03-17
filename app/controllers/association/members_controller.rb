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
    begin
      @member = current_association_by_owner.new_member(params[:organization])
    rescue Association::MemberExists
      flash[:message] = "Firm is already a member of the association" 
      redirect_to association_members_path
      return
    end

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
      @importer.file = params[:csv_file]

      begin
        Organization.suspended_delta do
          @importer.import!
        end
      #The handle various errors the importer might throw
      rescue AssociationMemberImport::NoImportFile, AssociationMemberImport::MalformedCSV,
        FasterCSV::MalformedCSVError => e
        if e.is_a? AssociationMemberImport::NoImportFile then
          flash[:notice] = "You must specify a CSV file to upload"
        else
          flash[:notice] = "The file you have tried to upload yielded no successful members. Follow the instructions 
          below regarding how to format your CSV file. You could also try using the example file. If you created
          the file in Excel, make sure to choose the \"Save As\" option and select Format: Comma Seperated Values (.csv)"
        end
        
        render :upload
        return
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
