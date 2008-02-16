require File.dirname(__FILE__) + '/../spec_helper'
module OrganizationSpecHelper
  def valid_organization_attributes
    {
      :email => 'brian.terlson@gmail.com',
      :password => 'test',
      :password_confirmation => 'test'
    }
  end
end
describe Organization do
  include OrganizationSpecHelper
  
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
  
  it 'should have many networks' do
    Organization.reflect_on_association(:networks).should_not be_nil
  end
  
  it 'should have many surveys' do
    Organization.reflect_on_association(:surveys).should_not be_nil
  end
  
  it 'should have many sent messages' do
    Organization.reflect_on_association(:sent_messages).should_not be_nil
  end
  
  it 'should have many received messages' do
    Organization.reflect_on_association(:received_messages).should_not be_nil
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
    @organization.should have(2).errors_on(:email)
  end

  it 'should authenticate an organization by email and password' do
    @organization.attributes = valid_organization_attributes
    @organization.save
    Organization.authenticate('brian.terlson@gmail.com', 'test').should == @organization
  end
end

describe Organization, "that already exists" do
  fixtures :organizations
  it 'should reset password' do
    organizations(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    Organization.authenticate('quentin@example.com', 'new password').should == organizations(:quentin)
  end

  it 'should not rehash password when updating other attributes' do
    organizations(:quentin).update_attributes(:email => 'quentin2@quentin2.com')
    Organization.authenticate('quentin2@quentin2.com', 'test').should == organizations(:quentin)
  end

  it 'should set remember token' do
    organizations(:quentin).remember_me
    organizations(:quentin).remember_token.should_not be_nil
    organizations(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'should unset remember token' do
    organizations(:quentin).remember_me
    organizations(:quentin).remember_token.should_not be_nil
    organizations(:quentin).forget_me
    organizations(:quentin).remember_token.should be_nil
  end

  it 'should remember me for one week' do
    before = 1.week.from_now.utc
    organizations(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    organizations(:quentin).remember_token.should_not be_nil
    organizations(:quentin).remember_token_expires_at.should_not be_nil
    organizations(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'should remembers me until one week' do
    time = 1.week.from_now.utc
    organizations(:quentin).remember_me_until time
    organizations(:quentin).remember_token.should_not be_nil
    organizations(:quentin).remember_token_expires_at.should_not be_nil
    organizations(:quentin).remember_token_expires_at.should == time
  end

  it 'remember me should default to two weeks' do
    before = 2.weeks.from_now.utc
    organizations(:quentin).remember_me
    after = 2.weeks.from_now.utc
    organizations(:quentin).remember_token.should_not be_nil
    organizations(:quentin).remember_token_expires_at.should_not be_nil
    organizations(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

protected
  def create_organization(options = {})
    record = Organization.new({ :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    record.save
    record
  end
end
