require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

valid_member_attributes = {
  :name => "Test Company",
  :email => "contact@testcompany.com",
  :zip_code => "55311"
}

describe Association::MembersController, "#route_for" do
  it "should map { :controller => 'association/members', :action => 'index' } to association/members" do
    route_for(:controller => "association/members", :action => "index").should == "/association/members"
  end

  it "should map { :controller => 'association/members', :action => 'new' } to /association/members/new" do
    route_for(:controller => "association/members", :action => "new").should == "/association/members/new"
  end

  it "should map { :controller => 'association/members', :action => 'show', :id => '1' } to /association/members/1" do
    route_for(:controller => "association/members", :action => "show", :id => '1').should == "/association/members/1"
  end

  it "should map { :controller => 'association/members', :action => 'edit', :id => '1' } to /association/members/1/edit" do
    route_for(:controller => "association/members", :action => "edit", :id => '1').should == "/association/members/1/edit"
  end

  it "should map { :controller => 'association/members', :action => 'update', :id => '1'} to /association/members/1" do
    route_for(:controller => "association/members", :action => "update", :id => '1').should == { :path => "/association/members/1", :method => :put }
  end

  it "should map { :controller => 'association/members', :action => 'destroy', :id => '1'} to /association/members/1" do
    route_for(:controller => "association/members", :action => "destroy", :id => '1').should == { :path => "/association/members/1", :method => :delete }
  end

  it "should map { :controller => 'association/members', :action => 'upload'} to /association/members/upload" do
    route_for(:controller => "association/members", :action => "upload").should == "/association/members/upload"
  end
end

describe Association::MembersController, "handling index" do
  before(:each) do
    @association  = Factory(:association)
    @organization = Factory(:organization)
    @association.organizations << @organization
    login_as(@association)

    do_get
  end

  def do_get
    get :index
  end

  it "should be successful" do
    response.should be_success
  end

  it "should show the index template" do
    response.should render_template('index')
  end

  it "should assign the association members to the view" do
    assigns[:members].should == [@organization]
  end

  it "should require being an association" do
    controller.should_receive(:association_owner_login_required).and_return(true)
    do_get
  end
end

describe Association::MembersController, "handling new" do
  before(:each) do
    @association  = Factory(:association)
    login_as(@association)

    do_get
  end

  def do_get
    get :new
  end

  it "should be successful" do
    response.should be_success
  end

  it "should render the new template" do
    response.should render_template('new')
  end

  it "should assign a new organization to the view" do
    assigns[:member].is_a?(Organization).should be_true
  end
end

describe Association::MembersController, "handling create" do
  before(:each) do
    @association  = Factory(:association)
    login_as(@association)
  end

  def do_post
    post :create, @params
  end

  describe "with no validation errors" do
    before do
      @params = {:organization => valid_member_attributes}
    end

    it "should redirect to the index page" do
      do_post
      response.should redirect_to(association_members_path)
    end

    it "should create a new member" do
      lambda { do_post }.should change(Organization, :count).by(1)
    end

    it "should create a new member that is uninitialized" do
      do_post
      Organization.last.is_uninitialized_association_member.should == true
    end

    it "should create a new org that is an association member" do
      lambda { do_post }.should change(@association.organizations, :count).by(1)
    end
  end

  describe "with validation errors" do
    before do
      @params = {:organization => valid_member_attributes.except(:name)}
      do_post
    end

    it "should be successful" do
      do_post
      response.should be_success
    end

    it "should render to the new page" do
      do_post
      response.should render_template('new')
    end

    it "should not create a new member" do
      lambda { do_post }.should_not change(Network, :count).by(1)
    end
  end
end

describe Association::MembersController, "handling edit" do
  before(:each) do
    @association  = Factory(:association)
    @organization = Factory(:organization)
    @association.organizations << @organization

    @params = {:id => @organization.id}
    login_as(@association)

    do_get
  end

  def do_get
    get :edit, @params
  end

  it "should be successful" do
    response.should be_success
  end

  it "should render the edit template" do
    response.should render_template('edit')
  end

  it "should assign the organization to the view" do
    assigns[:member].should == @organization
  end
end


describe Association::MembersController, "handling update" do
  before(:each) do
    @association  = Factory(:association)
    @organization = Factory(:organization)
    @association.organizations << @organization

    @params = {:id => @organization.id}

    login_as(@association)
  end

  def do_post
    post :update, @params
  end

  describe "with no validation errors" do
    before do
      @params[:organization] = valid_member_attributes.with(:name => "New Name")
    end

    it "should redirect to the index page" do
      do_post
      response.should redirect_to(association_members_path)
    end

    it "should update the organization" do
      do_post
      @organization.reload
      @organization.name.should == "New Name"
    end
  end

  describe "with validation errors" do
    before do
      @params[:organization] = valid_member_attributes.with(:name => "")
      do_post
    end

    it "should be successful" do
      do_post
      response.should be_success
    end

    it "should render to the edit page" do
      do_post
      response.should render_template('edit')
    end
  end
end

describe Association::MembersController, "handling delete" do
  before(:each) do
    @association  = Factory(:association)
    @organization = Factory(:organization)
    @association.organizations << @organization

    @params = {:id => @organization.id}

    login_as(@association)
  end

  def do_delete
    delete :destroy, @params
  end

  it "should remove the organization from the association" do
    do_delete
    @organization.associations.should_not include(@association)
  end
end

describe Association::MembersController, "handling upload" do
  before(:each) do
    @association  = Factory(:association)
    @organization = Factory(:organization)

    login_as(@association)
  end

  def do_upload
    upload :upload, @params
  end

  describe "with a valid CSV file" do
    
    describe "with all valid parameters" do
      it "should be successful"
      it "should render the upload successful page"
      it "should change the number of firms in the association"
    end
    
    describe "with an invalid format" do
      it "should give an error message"
    end
    
  end
  
  describe "with an invalid file" do
    it "should give an error message"
  end
end
