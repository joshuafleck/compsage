require File.dirname(__FILE__) + '/../spec_helper'

describe BillingController, "#route_for" do

  it "should map { :controller => 'billing', :action => 'show' } to /surveys/1/billing" do
    route_for(:controller => "billing", :action => "show", :survey_id => '1').should == "/surveys/1/billing"
  end
 
  it "should map { :controller => 'billing', :action => 'new' } to /surveys/1/billing/new" do
    route_for(:controller => "billing", :action => "new", :survey_id => '1').should == "/surveys/1/billing/new"
  end
  
  it "should map { :controller => 'billing', :action => 'invoice' } to /surveys/1/billing/invoice" do
    route_for(:controller => "billing", :action => "invoice", :survey_id => '1').should == "/surveys/1/billing/invoice"
  end
    
end  

describe BillingController, " handling GET /surveys/1/billing" do

  before(:each) do
    @current_organization = Factory.create(:organization)
    login_as(@current_organization)    
    
    @survey = Factory.create(:survey, :sponsor => @current_organization)
    @invoice = Factory.create(:invoice, :survey => @survey)  
  end
  
  after(:each) do
    @invoice.destroy
    @survey.destroy
    @current_organization.destroy   
  end  
  
  def do_get
    get :show, :survey_id => @survey.id.to_s
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end  
  
  it "should render show template" do
    do_get
    response.should render_template("show")
  end  
  
  it "should assign the survey to the view" do
    do_get
    assigns[:survey].should == @survey
  end
  
  it "should assign the invoice to the view" do
    do_get
    assigns[:invoice].should == @invoice
  end
      
   
end  

describe BillingController, " handling GET /surveys/1/billing/new" do

  before(:each) do
    @current_organization = Factory.create(:organization)
    login_as(@current_organization)    
    
    @survey = Factory.create(:survey, :sponsor => @current_organization)
  end
  
  after(:each) do
    @survey.destroy
    @current_organization.destroy   
  end  
  
  def do_get
    get :new, :survey_id => @survey.id.to_s
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end  
  
  it "should render new template" do
    do_get
    response.should render_template("new")
  end  
  
  it "should assign the survey to the view" do
    do_get
    assigns[:survey].should == @survey
  end
  
  it "should initialize an invoice for the survey" do
    do_get
    assigns[:invoice].new_record?.should be_true
    assigns[:invoice].survey.should == @survey
  end      
  
  it "should assign the invoice to the view" do
    do_get
    assigns[:invoice].should_not be_nil
  end   
   
end

describe BillingController, " handling GET /surveys/1/billing/invoice" do

  before(:each) do
    @current_organization = Factory.create(:organization)
    login_as(@current_organization)    
    
    @survey = Factory.create(:survey, :sponsor => @current_organization)
    @invoice = Factory.create(:invoice, :survey => @survey, :payment_type => "invoice")  
  end
  
  after(:each) do
    @invoice.destroy
    @survey.destroy
    @current_organization.destroy   
  end  
  
  def do_get
    get :invoice, :survey_id => @survey.id.to_s
    @invoice.reload
  end
  
  it "should redirect to the survey report" do
    do_get
    response.should redirect_to(survey_report_path(@survey))
  end  
  
  it "should mark the invoice as delivered" do  
    lambda{ do_get }.should change(@invoice, :should_be_delivered?).from(true).to(false)
  end    
   
end

describe BillingController, " handling POST /surveys/1/billing" do

  before(:each) do
    @current_organization = Factory.create(:organization)
    login_as(@current_organization)    
    
    @survey = Factory.create(:survey, :sponsor => @current_organization, :aasm_state => "pending")
    @invoice = Factory.build(:invoice, :payment_type => "invoice", :survey_id => @survey.id)
    @params = {:survey_id => @survey.id.to_s, :invoice => @invoice.attributes, :active_merchant_billing_credit_card => {}}
  end
  
  after(:each) do
    @survey.destroy
    @current_organization.destroy   
  end  
  
  def do_get
    post :create, @params
    @survey.reload
  end

  it "should place the survey in a running state" do
    lambda{ do_get }.should change(@survey, :aasm_state).from("pending").to("running")
  end  
 
  it "should create an invoice" do
    lambda{ do_get }.should change(Invoice, :count).by(1)
  end  
     
  it "should redirect to the survey" do
    do_get
    response.should redirect_to(survey_path(@survey))
  end  
  
  describe "with an invalid credit card" do
  
    before(:each) do
      @invoice.payment_type = "credit"
      @params = {:survey_id => @survey.id.to_s, :invoice => @invoice.attributes, :active_merchant_billing_credit_card => {}}
    end
    
    it "should render the new template" do
      do_get
      response.should render_template(:new)
    end
    
    it "should not create an invoice" do
      do_get
    lambda{ do_get }.should_not change(Invoice, :count)
    end    
      
  end
  
  describe "with an invalid invoice" do  
  
    before(:each) do
      @params = {:survey_id => @survey.id.to_s, :invoice => nil}
    end
    
    it "should render the new template" do
      do_get
      response.should render_template(:new)
    end
     
    it "should not create an invoice" do
      do_get
    lambda{ do_get }.should_not change(Invoice, :count)
    end    
        
  end
   
end
    
