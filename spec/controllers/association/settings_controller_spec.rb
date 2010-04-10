require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
valid_association_attributes = {
  :association => {
    :member_greeting => 'This is the member greeting!',
    :billing_instructions => 'These are the billing instructions!',
    :contact_name => 'Aziz Ansari',
    :contact_email => 'my@email.com',
    :contact_phone => '1234567890',
    :contact_phone_extension => '1234'
  }
}

describe Association::SettingsController, "handling GET /association/settings" do
  def do_get
    get :show
  end
  
  describe "with a logged in association" do
    before(:each) do
      @association  = Factory(:association)
      login_as(@association)
      
      do_get
    end
    
    it "should be successful" do
      response.should be_success
    end
  end
  
  describe "with out logging in"
  it "should require an association owner login" do
    do_get
    
    response.should redirect_to(new_association_session_path)
  end  
end


describe Association::SettingsController, "handling POST /association/settings" do
  before(:each) do
    @association  = Factory(:association)
    login_as(@association)
  end
  
  def do_post
    post :update, @params
  end
  
  it "should require an association owner login" do
    controller.should_receive(:association_owner_login_required).and_return(true)
    do_post
  end
  
  describe "with valid association params" do
    before(:each) do
      @params = valid_association_attributes
      do_post
    end

    it "should update the to the posted params" do
      valid_association_attributes[:association].keys.each do |key|
        @association[key].should == valid_association_attributes[:association][key]
      end
    end
    
    it "should show the message 'Settings updated'" do
      flash[:notice].should == "Settings updated"
    end
    
    it "should redirect to association settings" do
      response.should redirect_to(association_settings_path)
    end
  end
  
  describe "without an email" do
    before(:each) do
      @params = valid_association_attributes.with(:contact_email => '')
      do_post
    end
    
    it "should not change the association the email param" do
      @association.contact_email.should_not == ''
    end
    
    it "should not redirect to assocation settings" do
      response.should redirect_to(association_settings_path)
    end
  end
end

