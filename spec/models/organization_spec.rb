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
    
  it 'should have many networks' do
    Organization.reflect_on_association(:networks).should_not be_nil
  end
  
  it 'should have many owned networks' do
    Organization.reflect_on_association(:owned_networks).should_not be_nil
  end
  
  it 'should have many surveys' do
    Organization.reflect_on_association(:surveys).should_not be_nil
  end

  it 'should have many responses' do
    Organization.reflect_on_association(:responses).should_not be_nil
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
    Organization.authenticate('brian.terlson@gmail.com', 'test').should == @organization
  end
  
  it "should be invalid when location is longer than 64 characters" do
  	pending
  end
  
  it "should be invalid when contact name is longer than 128 characters" do
  	pending
  end
  
  it "should be invalid when city is longer than 50 characters" do
  	pending
  end
  
  it "should be invalid when state is longer than 30 characters" do
  	pending
  end
  
  it "should be invalid when the organization name is longer than 100 characters" do
  	pending
  end
  
  it "should be invalid with an invalid email address" do
  	pending
  end
  
  it "should be invalid with a password shorter than 5 characters" do
  	pending
  end
  
  it "should be invalid with a zip_code not of length 5" do
  	pending
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
    Organization.authenticate('brian.terlson@gmail2.com', 'test').should == @organization
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
end
