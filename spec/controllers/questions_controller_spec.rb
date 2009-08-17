require File.dirname(__FILE__) + '/../spec_helper'


describe QuestionsController, "#route_for" do
  
  it "should map { :controller => 'questions', :action => 'index', :survey_id => '1' } to /surveys/1/questions" do
    route_for(:controller => "questions", :action => "index", :survey_id => '1').should == "/surveys/1/questions"
  end
  
  it "should map { :controller => 'questions', :action => 'preview', :survey_id => '1' } to /surveys/1/questions/preview" do
    route_for(:controller => "questions", :action => "preview", :survey_id => '1').should == "/surveys/1/questions/preview"
  end
  
  it "should map { :controller => 'questions', :action => 'create', :survey_id => '1' } to /surveys/1/questions" do
    route_for(:controller => "questions", :action => "create", :survey_id => '1').should == { :path => "/surveys/1/questions", :method => :post }
  end 
  
  it "should map { :controller => 'questions', :action => 'destroy', :survey_id => '1', :id => '1' } to /surveys/1/questions/1" do
    route_for(:controller => "questions", :action => "destroy", :survey_id => '1', :id => '1' ).should == { :path => "/surveys/1/questions/1", :method => :delete }
  end      
  
  it "should map { :controller => 'questions', :action => 'update', :survey_id => '1', :id => '1' } to /surveys/1/questions/1" do
    route_for(:controller => "questions", :action => "update", :survey_id => '1', :id => '1' ).should == { :path => "/surveys/1/questions/1", :method => :put }
  end 
  
  it "should map { :controller => 'questions', :action => 'move', :survey_id => '1', :id => '1' } to /surveys/1/questions/1/move" do
    route_for(:controller => "questions", :action => "move", :survey_id => '1', :id => '1' ).should == { :path => "/surveys/1/questions/1/move", :method => :put }
  end     
  
end

describe QuestionsController, "handling GET /questions" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:running_survey)    
    @participation = Factory.create(:participation, :survey => @survey, :participant => @current_organization)
  end
  
  def do_get
    get :index, :survey_id => @survey.id
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should assign the found survey to the view" do
    do_get
    assigns[:survey].should_not be_nil
  end
  
  it "should assign the participation to the view" do
    do_get
    assigns[:participation].should_not be_nil
  end  
  
  it "should render the questions view template" do
    do_get
    response.should render_template('index')
  end
  
  describe "with a survey that isn't running" do
    it "should raise a not found error" do 
      @survey = Factory(:finished_survey)    
      @participation = Factory.create(:participation, :survey => @survey, :participant => @current_organization)
      
      lambda { do_get }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

describe QuestionsController, "handling POST /questions" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:survey, :sponsor => @current_organization)
    @question = Factory(:question, :survey => @survey)
    @params = {:survey_id => @survey.id, :question => {:question_type => "Numeric response", 
                                                       :text => "How many licks does it take?",
                                                       :parent_question_id => ""} }
  end
  
  def do_post
    post :create, @params.merge(:format => 'js')
  end
  
  it "should be successful" do
    do_post
    response.should be_success
  end

  describe "when creating a predefined question" do
    before do
      @predefined_question = Factory(:predefined_question)
      @params = {:survey_id => @survey.id, :predefined_question_id => @predefined_question.id.to_s}
    end
    
    it "should add at least one question" do
      lambda { do_post }.should change(Question, :count).by(1)
    end
  end
  
  describe "when creating a custom question" do
    it "should create a new question" do
      lambda { do_post }.should change(Question, :count).by(1)
    end
    
  end  
    
  it "should render the questions partial" do
    do_post
    response.should render_template("questions/_question")
  end
    
end

describe QuestionsController, "handling PUT /questions/1" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:survey, :sponsor => @current_organization)
    @question = Factory(:question, :survey => @survey)
    
    @params = {:survey_id => @survey.id, :id => @question.id, :question => { :text => "Updated!"}}
  end
  
  def do_put
    put :update, @params.merge(:format => 'js')
    @question.reload
  end
  
  it "should be successful" do
    do_put
    response.should be_success
  end
  
  
  it "should update the question" do
    do_put
    @question.text.should == "Updated!"
  end   
  
  it "should render the questions partial" do
    do_put
    response.should render_template("questions/_question")
  end
  
  describe " when the user is not the sponsor" do 
    it "should raise a not found error" do
       @survey = Factory(:survey, :sponsor => Factory(:organization))
       @question = Factory(:question, :survey => @survey)
       @params = {:survey_id => @survey.id, :id => @question.id, :question => { :text => "Updated!"}}
       lambda { do_put }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
    
end

describe QuestionsController, "handling DELETE /questions/1" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:survey, :sponsor => @current_organization)
    @question = Factory(:question, :survey => @survey)
    @params = {:survey_id => @survey.id, :id => @question.id}
  end
  
  def do_delete
    delete :destroy, @params.merge(:format => 'js')
  end
  
  it "should delete the question" do
    lambda { do_delete }.should change(Question, :count).by(-1)
  end   
  
  describe " when the user is not the sponsor" do 
    it "should raise a not found error" do
       @survey = Factory(:survey, :sponsor => Factory(:organization))
       @question = Factory(:question, :survey => @survey)
       @params = {:survey_id => @survey.id, :id => @question.id}
       lambda { do_delete }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

describe QuestionsController, "handling PUT /questions/1/move" do
  before(:each) do
    @current_organization = Factory(:organization)
    login_as(@current_organization)
    
    @survey = Factory(:survey, :sponsor => @current_organization)
    @question = Factory(:question, :survey => @survey)
    @params = {:survey_id => @survey.id, :id => @question.id}
    @position = @question.position
  end
  
  def do_move
    put :move, @params.merge!(:format => 'js')
    @question.reload
  end
  
  it "should be successful" do
    do_move
    response.should be_success
  end
  
  describe "when moving the question higher" do
    before do
      @params.merge!({:direction => 'higher'})
    end
  
    it "should move the question higher" do
      do_move
      @question.position.should == @position - 1
    end   
    
  end

  describe "when moving the question lower" do
    before do
      @params.merge!({:direction => 'lower'})
    end
  
    it "should move the question lower" do
      do_move
      @question.position.should == @position + 1
    end   
    
  end
  
end  
  
