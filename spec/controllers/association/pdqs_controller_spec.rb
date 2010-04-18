require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
valid_pdq_attributes = { :question => {
                :question_type => "Numeric response",
                :text => "The question text.", 
                :required => :false }, 
              :predefined_question => {
                :name => "My Question", 
                :default =>"true" }
              }
              
describe Association::PdqsController, "#route_for" do

  it "should map { :controller => 'association/pdqs', :action => 'new' } to /association/pdqs/new" do
    route_for(:controller => "association/pdqs", :action => "new").should == "/association/pdqs/new"
  end

  it "should map { :controller => 'association/pdqs', :action => 'edit', :id => '1' } to /association/pdqs/1/edit" do
    route_for(:controller => "association/pdqs", :action => "edit", :id => '1').should == "/association/pdqs/1/edit"
  end  
  
  it "should map { :controller => 'association/pdqs', :action => 'create' } to /association/pdqs" do
    route_for(:controller => "association/pdqs", :action => "create").should == { :path => "/association/pdqs", :method => :post }
  end

  it "should map { :controller => 'association/pdqs', :action => 'update', :id => '1'} to /association/pdqs/1" do
    route_for(:controller => "association/pdqs", :action => "update", :id => '1').should == { :path => "/association/pdqs/1", :method => :put }
  end

  it "should map { :controller => 'association/pdqs', :action => 'destroy', :id => '1'} to /association/pdqs/1" do
    route_for(:controller => "association/pdqs", :action => "destroy", :id => '1').should == { :path => "/association/pdqs/1", :method => :delete }
  end
end

describe Association::PdqsController, "handling GET /association/pdqs/new" do
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
  
  it "should require being an association" do
    controller.should_receive(:association_owner_login_required).and_return(true)
    do_get
  end
  
  it "should assign a predefined question to the view" do
    assigns[:predefined_question].should_not be_nil
  end
  
  it "should render the new template" do
    response.should render_template('new')
  end
end

describe Association::PdqsController, "handling POST /association/pdqs/create" do
  before(:each) do
    @association  = Factory(:association)
    login_as(@association)
  end

  def do_post
    post :create, @params
  end
  
  describe "with no validation errors" do
    before(:each) do
      @params = valid_pdq_attributes
    end
    
    it "should redirect to the settings view" do
      do_post
      response.should redirect_to(association_settings_path)
    end
    it "should create a new PDQ for the association" do
      lambda { do_post }.should change(@association.predefined_questions, :count).by(1)
    end
  end
  
  describe "with validation errors" do
    before(:each) do
      @params = valid_pdq_attributes.except(:predefined_question)
    end
    
    it "should be successful" do
      do_post
      response.should be_success
    end
    
    it "should render the new template" do
      do_post
      response.should render_template('new')
    end
    
    it "should not create a new PDQ" do
      lambda { do_post }.should_not change(@association.predefined_questions, :count).by(1)
    end
  end
end


describe Association::PdqsController, "handling GET /association/pdqs/1/edit" do
  before(:each) do
    @association  = Factory(:association)
    @pdq = Factory(:predefined_question, :association_id => @association.id)
    login_as(@association)

    do_get
  end

  def do_get
    get :edit, :id => @pdq.id
  end
  
  it "should be successful" do
    response.should be_success
  end
  
  it "should require an association owner login" do
    controller.should_receive(:association_owner_login_required).and_return(true)
    do_get
  end
  
  it "should assign the PDQ to the view" do
    assigns[:predefined_question].should == @pdq
  end
  
  it "should render the edit template" do
    response.should render_template('edit')
  end
end

describe Association::PdqsController, "handling POST /association/pdqs/1/update" do
  before(:each) do
    @association  = Factory(:association)
    @pdq = Factory(:predefined_question, :association_id => @association.id)
    login_as(@association)
    
    @params = {:id => @pdq.id}
  end

  def do_post
    post :update, @params
  end
  
  describe "with no validation errors" do
    before(:each) do
      @params.merge!(valid_pdq_attributes)
      do_post
      
      @pdq.reload
    end
    
    it "should redirect to the settings view" do
      response.should redirect_to(association_settings_path)
    end
    
    it "should update the question" do
      @pdq.name.should == "My Question"
    end
    
    it "should update the PDQ" do
      @pdq.question.text.should == "The question text."
    end
  end
  
  describe "with validation errors" do
    before(:each) do
      @params.merge!(valid_pdq_attributes.with(:predefined_question => {:name => "", :default => "false"}))
      do_post
    end
    
    it "should be successful" do
      response.should be_success
    end
    
    it "should render the edit template" do
      response.should render_template('edit')
    end
  end
end

describe Association::PdqsController, "handling /association/pdqs/1/delete" do
  before(:each) do
    @association  = Factory(:association)
    @pdq = Factory(:predefined_question, :association_id => @association.id)
    login_as(@association)
    
    @params = {:id => @pdq.id}
  end

  def do_delete
    delete :destroy, @params
  end
  
  it "should be remove the PDQ" do
    do_delete
    @association.predefined_questions.should_not include(@pdq)
  end
  
  it "should render the settings view" do
    do_delete
    response.should redirect_to(association_settings_path)
  end
end