require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe OrganizationsController do
  fixtures :organizations

  it 'allows signup' do
    lambda do
      create_organization
      response.should be_redirect      
    end.should change(Organization, :count).by(1)
  end

  it 'requires password on signup' do
    lambda do
      create_organization(:password => nil)
      assigns[:organization].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(Organization, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_organization(:password_confirmation => nil)
      assigns[:organization].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(Organization, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_organization(:email => nil)
      assigns[:organization].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(Organization, :count)
  end
  
  
  
  def create_organization(options = {})
    post :create, :organization => { :email => 'quire@example.com',
      :password => 'quire', :password_confirmation => 'quire' }.merge(options)
  end
end