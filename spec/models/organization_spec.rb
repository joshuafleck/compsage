require File.dirname(__FILE__) + '/../spec_helper'

describe Organization do
  before(:each) do
    @organization = Organization.new
  end
  
  it 'should be valid' do
    @organization.attributes = valid_organization_attributes 
    @organization.should be_valid
  end
  
  it 'should have many discussions' do
    Organization.reflect_on_association(:discussions).should_not be_nil
  end
  
  it 'should have many network invitations' do
    Organization.reflect_on_association(:network_invitations).should_not be_nil
  end
  
  it 'should have one logo' do
    Organization.reflect_on_association(:logo).should_not be_nil
  end
  
  it 'should have many survey invitations' do
    Organization.reflect_on_association(:survey_invitations).should_not be_nil
  end
  
  it 'should have many sent network invitations' do
    Organization.reflect_on_association(:sent_network_invitations).should_not be_nil
  end
  
  it 'should have many sent survey invitations' do
    Organization.reflect_on_association(:sent_survey_invitations).should_not be_nil
  end
  
  it 'should have many sent external network invitations' do
    Organization.reflect_on_association(:sent_external_network_invitations).should_not be_nil
  end
  
  it 'should have many sent external survey invitations' do
    Organization.reflect_on_association(:sent_external_survey_invitations).should_not be_nil
  end
   
  it 'should have many sent global invitations' do
    Organization.reflect_on_association(:sent_global_invitations).should_not be_nil
  end
    
  it 'should have many networks' do
    Organization.reflect_on_association(:networks).should_not be_nil
  end
  
  it 'should have many owned networks' do
    Organization.reflect_on_association(:owned_networks).should_not be_nil
  end
  
  it 'should have many surveys' do
    Organization.reflect_on_association(:surveys).should_not be_nil
  end
  
  it 'should have many participated surveys' do
    Organization.reflect_on_association(:participated_surveys).should_not be_nil
  end
  
  it 'should have many responses' do
    Organization.reflect_on_association(:responses).should_not be_nil
  end
  
  it "should have many participations" do
    Organization.reflect_on_association(:participations).should_not be_nil
  end
  
  it 'should require a password' do
    @organization.attributes = valid_organization_attributes.except(:password)
    @organization.should have(3).errors_on(:password)
  end

  it 'should require a password confirmation' do
    @organization.attributes = valid_organization_attributes.except(:password_confirmation)
    @organization.should have(1).error_on(:password_confirmation)
  end

  it 'should require an email' do
    @organization.attributes = valid_organization_attributes.except(:email)
    @organization.should have(3).errors_on(:email)
  end
  
  it 'should require a unique email' do
    @organization.attributes = valid_organization_attributes
    @organization.save
    @organization1 = Organization.new(valid_organization_attributes)
    @organization1.should have(1).errors_on(:email)
  end
  
  it 'should require a zip code' do
    @organization.attributes = valid_organization_attributes.except(:zip_code)
    @organization.should have(2).errors_on(:zip_code)
  end

  it 'should require a name' do
    @organization.attributes = valid_organization_attributes.except(:name)
    @organization.should have(2).errors_on(:name)
  end

  it 'should authenticate an organization by email and password' do
    @organization.attributes = valid_organization_attributes
    @organization.save
    Organization.authenticate(valid_organization_attributes[:email], valid_organization_attributes[:password]).should == @organization
  end
  
  it "should be invalid when location is longer than 60 characters" do
  	@organization.attributes = valid_organization_attributes.with(:location => "0"*61)
    @organization.should have(1).errors_on(:location)
  end
  
  it "should be invalid when industry is longer than 100 characters" do
  	@organization.attributes = valid_organization_attributes.with(:industry => "0"*101)
    @organization.should have(1).errors_on(:industry)
  end
  
  it "should be invalid when contact name is longer than 100 characters" do
  	@organization.attributes = valid_organization_attributes.with(:contact_name => "0"*101)
    @organization.should have(1).errors_on(:contact_name)
  end
  
  it "should be invalid when city is longer than 50 characters" do
  	@organization.attributes = valid_organization_attributes.with(:city => "0"*51)
    @organization.should have(1).errors_on(:city)
  end
  
  it "should be invalid when state is longer than 30 characters" do
  	@organization.attributes = valid_organization_attributes.with(:state => "0"*31)
    @organization.should have(1).errors_on(:state)
  end
  
  it "should be invalid when the name is longer than 100 characters" do
  	@organization.attributes = valid_organization_attributes.with(:name => "0"*101)
    @organization.should have(1).errors_on(:name)
  end
  
  it "should be invalid when the name is shorter than 3 characters" do
  	@organization.attributes = valid_organization_attributes.with(:name => '12')
    @organization.should have(1).errors_on(:name)
  end
  
  it "should be invalid with a email shorter than 5 characters" do
  	@organization.attributes = valid_organization_attributes.with(:email => '1234')
    @organization.should have(2).errors_on(:email)
  end
  
  it "should be invalid with a email longer than 100 characters" do
  	@organization.attributes = valid_organization_attributes.with(:email => "0"*101)
    @organization.should have(2).errors_on(:email)
  end
  
  it "should be invalid with an invalid email address" do
  	@organization.attributes = valid_organization_attributes.with(:email => '@johnson@.com')
    @organization.should have(1).errors_on(:email)
  end
  
  it "should be invalid with a password shorter than 5 characters" do
  	@organization.attributes = valid_organization_attributes.with(:password => '1234', :password_confirmation => '1234')
    @organization.should have(1).errors_on(:password)
  end
  
  it "should be invalid with a password longer than 40 characters" do
  	@organization.attributes = valid_organization_attributes.with(:password => "0"*41, :password_confirmation => "0"*41)
    @organization.should have(1).errors_on(:password)
  end
  
  it "should be invalid with a zip_code not of length 5" do
  	@organization.attributes = valid_organization_attributes.with(:zip_code => '123456')
    @organization.should have(1).errors_on(:zip_code)
  	@organization.attributes = valid_organization_attributes.with(:zip_code => '1234')
    @organization.should have(1).errors_on(:zip_code)
  end
  
  it 'should set the logo if a logo is available' do
    @logo = mock_model(Logo, :[]= => true, :organization => @organization)
    @logo.stub!(:destroy)    
    @organization.logo = @logo  
      
    @logo_new = mock_model(Logo)
    @logo_new.stub!(:organization=)
    @logo_new.stub!(:save!)
    Logo.stub!(:new).and_return(@logo_new)
    
    @organization.set_logo({:uploaded_data => "test"})
    
    @organization.logo.should eql(@logo_new)
  end
  
  it 'should not set the logo if a logo is not available' do
    @logo = mock_model(Logo, :[]= => true, :organization => @organization)
    @organization.logo = @logo  
     
    @organization.set_logo({})
    
    @organization.logo.should eql(@logo)
  end
end

describe Organization, "that already exists" do
  before(:each) do
    @organization = Organization.new(valid_organization_attributes)
  end
  
  it 'should reset password' do
    @organization.save
    @organization.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    Organization.authenticate('brian.terlson@gmail.com', 'new password').should == @organization
  end

  it 'should not rehash password when updating other attributes' do
    @organization.save
    @organization.update_attributes(:email => 'brian.terlson@gmail2.com')
    Organization.authenticate('brian.terlson@gmail2.com', valid_organization_attributes[:password]).should == @organization
  end

  it 'should set remember token' do
    @organization.remember_me
    @organization.remember_token.should_not be_nil
    @organization.remember_token_expires_at.should_not be_nil
  end

  it 'should unset remember token' do
    @organization.remember_me
    @organization.remember_token.should_not be_nil
    @organization.forget_me
    @organization.remember_token.should be_nil
  end

  it 'should remember me for one week' do
    before = 1.week.from_now.utc
    @organization.remember_me_for 1.week
    after = 1.week.from_now.utc
    @organization.remember_token.should_not be_nil
    @organization.remember_token_expires_at.should_not be_nil
    @organization.remember_token_expires_at.between?(before, after).should be_true
  end

  it 'should remembers me until one week' do
    time = 1.week.from_now.utc
    @organization.remember_me_until time
    @organization.remember_token.should_not be_nil
    @organization.remember_token_expires_at.should_not be_nil
    @organization.remember_token_expires_at.should == time
  end

  it 'remember me should default to two weeks' do
    before = 2.weeks.from_now.utc
    @organization.remember_me
    after = 2.weeks.from_now.utc
    @organization.remember_token.should_not be_nil
    @organization.remember_token_expires_at.should_not be_nil
    @organization.remember_token_expires_at.between?(before, after).should be_true
  end
  
  it 'should join networks that are created by the organization' do
    @organization.save
    network = @organization.owned_networks.create(:name => 'test')
    @organization.networks.should include(network)
  end
  
  it 'should delete empty networks when the organization leaves the network' do
    @organization.save
    @network = @organization.owned_networks.create(:name => "test")
    @organization.networks.destroy(@organization.networks.first)
    lambda { Network.find(@network.id) }.should raise_error(ActiveRecord::RecordNotFound)
  end
  
end
