class Association::MembersController <  Association::AssociationController
  before_filter :association_owner_login_required
  before_filter :find_member, :only => [:edit, :update, :destroy]

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
  end

  def update
    if @member.association_can_update? && @member.update_attributes(params[:organization]) then
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
          flash.now[:notice] = "You must specify a CSV file to upload"
        else
          flash.now[:notice] = "The file you have tried to upload yielded no successful members. Follow the instructions 
          below regarding how to format your CSV file. If you have created this file in Excel, please choose
          the \"Save As\" option from the File menu, and choose the Format: Comma Separated Values (.csv) option."
        end
        
        render :upload
        return
      end

      render :upload_success
    end
  end

  def destroy
    @member.leave_association(current_association_by_owner)
    
    flash[:message] = "Member removed"
    redirect_to association_members_path
  end
  
  private 
  
  def find_member
    @member = current_association_by_owner.organizations.find(params[:id])
  end  
  
end
