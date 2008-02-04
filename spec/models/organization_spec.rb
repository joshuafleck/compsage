require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe Organization do
  fixtures :organizations

  describe 'being created' do
    before do
      @organization = nil
      @creating_organization = lambda do
        @organization = create_organization
        violated "#{@organization.errors.full_messages.to_sentence}" if @organization.new_record?
      end
    end
    
    it 'increments User#count' do
      @creating_organization.should change(Organization, :count).by(1)
    end
  end
  
  it 'should have many discussions' do
    Organization.reflect_on_association(:discussions).should_not be_nil
  end
  
  it 'should have many invitations' do
    Organization.reflect_on_association(:invitations).should_not be_nil
  end
  
  it 'should have many networks' do
    Organization.reflect_on_association(:networks).should_not be_nil
  end
  
  it 'should have many surveys' do
    Organization.reflect_on_association(:surveys).should_not be_nil
  end
  
  it 'should have many messages' do
    Organization.reflect_on_association(:messages).should_not be_nil
  end
  
  it 'requires password' do
    u = create_organization(:password => nil)
    u.errors.on(:password).should_not be_nil
  end

  it 'requires password confirmation' do
    u = create_organization(:password_confirmation => nil)
    u.errors.on(:password_confirmation).should_not be_nil
  end

  it 'requires email' do
    u = create_organization(:email => nil)
    u.errors.on(:email).should_not be_nil
  end

  it 'resets password' do
    organizations(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    Organization.authenticate('quentin@example.com', 'new password').should == organizations(:quentin)
  end

  it 'does not rehash password when updating other attributes' do
    organizations(:quentin).update_attributes(:email => 'quentin2@quentin2.com')
    Organization.authenticate('quentin2@quentin2.com', 'test').should == organizations(:quentin)
  end

  it 'authenticates an organization' do
    Organization.authenticate('quentin@example.com', 'test').should == organizations(:quentin)
  end

  it 'sets remember token' do
    organizations(:quentin).remember_me
    organizations(:quentin).remember_token.should_not be_nil
    organizations(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    organizations(:quentin).remember_me
    organizations(:quentin).remember_token.should_not be_nil
    organizations(:quentin).forget_me
    organizations(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    organizations(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    organizations(:quentin).remember_token.should_not be_nil
    organizations(:quentin).remember_token_expires_at.should_not be_nil
    organizations(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    organizations(:quentin).remember_me_until time
    organizations(:quentin).remember_token.should_not be_nil
    organizations(:quentin).remember_token_expires_at.should_not be_nil
    organizations(:quentin).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
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
