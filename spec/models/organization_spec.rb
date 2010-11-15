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
  
  it 'should have many networks' do
    Organization.reflect_on_association(:networks).should_not be_nil
  end
  
  it 'should have many owned networks' do
    Organization.reflect_on_association(:owned_networks).should_not be_nil
  end
  
  it 'should have many surveys' do
    Organization.reflect_on_association(:surveys).should_not be_nil
  end
  
  it "should have many survey subscriptions" do
    Organization.reflect_on_association(:survey_subscriptions).should_not be_nil
  end
  
  it 'should have many sponsored_surveys' do
    Organization.reflect_on_association(:sponsored_surveys).should_not be_nil
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

  it "should have and belong to many associations" do
    Organization.reflect_on_association(:associations).should_not be_nil
  end

  it "should have and belong to a naics classification" do
    Organization.reflect_on_association(:naics_classification).should_not be_nil
  end
    
  it 'should require a password' do
    @organization.attributes = valid_organization_attributes.except(:password)
    @organization.should have(2).errors_on(:password)
  end

  it 'should require a password confirmation' do
    @organization.attributes = valid_organization_attributes.except(:password_confirmation)
    @organization.should have(1).error_on(:password_confirmation)
  end

  it 'should require an email' do
    @organization.attributes = valid_organization_attributes.except(:email)
    @organization.should have(1).errors_on(:email)
  end
  
  it 'should require a unique email' do
    @organization.attributes = valid_organization_attributes
    @organization.save
    @organization1 = Organization.new(valid_organization_attributes)
    @organization1.should have(1).errors_on(:email)
  end
  
  it 'should require a name' do
    @organization.attributes = valid_organization_attributes.except(:name)
    @organization.should have(1).errors_on(:name)
  end

  it 'should authenticate an organization by email and password' do
    @organization.attributes = valid_organization_attributes
    @organization.save
    Organization.authenticate(valid_organization_attributes[:email], valid_organization_attributes[:password]).should == @organization
  end
  
  it 'should not authenticate uninitialized association members' do
    @organization.attributes = valid_organization_attributes
    @organization.uninitialized_association_member = true
    @organization.save
    Organization.authenticate(valid_organization_attributes[:email], valid_organization_attributes[:password]).should be_nil
  end
  
  it "should be invalid when location is longer than 60 characters" do
  	@organization.attributes = valid_organization_attributes.with(:location => "0"*61)
    @organization.should have(1).errors_on(:location)
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

  it "should be invalid with a zip code that is not numbers" do
    @organization.attributes = valid_organization_attributes.with(:zip_code => 'adamm')
    @organization.should have(1).errors_on(:zip_code)
  end
  
  it "should not be an uninitialized association member" do
    @organization.uninitialized_association_member.should be_false
  end

  it "Should be invalid without accepting the Terms of Use" do
    @organization.attributes = valid_organization_attributes.with(:terms_of_use => false)
    @organization.should have(1).errors_on(:terms_of_use)
  end
  
  it 'should not require a password for uninitialized association members' do
    @organization.attributes = valid_organization_attributes.except(:password)
    @organization.uninitialized_association_member = true
    @organization.should have(0).errors_on(:password)
  end  
  
  it "should have a deactivation key" do
    @organization.deactivation_key.should_not be_nil
  end
  
  it "should not be deactivated" do
    @organization.deactivated?.should be_false
  end  
  
end

describe Organization, "that already exists" do
  before(:each) do
    @organization = Factory.build(:organization)
  end
  
  it 'should reset password' do
    email    = 'brian.terlson@gmail.com'
    password = 'new password'
    @organization.save
    @organization.update_attributes(:password => password, :password_confirmation => password, :email => email)
    Organization.authenticate(email, password).should == @organization
  end
  
  it "should create a reset password key" do    
    lambda{ @organization.create_reset_key_and_send_reset_notification }.should change(@organization, :reset_password_key).from(nil)
  end
   
  it "should set an expiration time for the password reset" do    
    lambda{ @organization.create_reset_key_and_send_reset_notification }.should change(@organization, :reset_password_key_expires_at).from(nil)
  end

  it "should delete the password key" do    
    @organization.create_reset_key_and_send_reset_notification
    lambda{ @organization.delete_reset_key }.should change(@organization, :reset_password_key).to(nil)
  end
 
  it "should delete the expiration time for the password reset" do    
    @organization.create_reset_key_and_send_reset_notification
    lambda{ @organization.delete_reset_key }.should change(@organization, :reset_password_key_expires_at).to(nil)
  end
  
  it "should not be allowed to request a password reset within 1 minute of a previous request" do   
    lambda{ @organization.create_reset_key_and_send_reset_notification }.should change(@organization, :can_request_password_reset?).from(true).to(false)
  end
  
  it "should be allowed to request a password reset 1 minute after a previous request" do 
    @organization.create_reset_key_and_send_reset_notification      
    lambda{ @organization.reset_password_key_created_at = Time.now - 2.minutes }.should change(@organization, :can_request_password_reset?).from(false).to(true)
  end  
         
  it "should send a notification email when resetting the password" do   
    Notifier.should_receive(:deliver_reset_password_key_notification) 
    @organization.create_reset_key_and_send_reset_notification
  end
      
  it "should determine when the password reset has expired" do    
    @organization.create_reset_key_and_send_reset_notification
    @organization.reset_password_key_expired?.should be_false
    @organization.reset_password_key_expires_at = Time.now - 1.minute
    @organization.reset_password_key_expired?.should be_true
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
  
  it 'should promote a new owner if the owner leaves the network' do
    @organization.save
    @network = @organization.owned_networks.create(:name => "test")  
    @organization2 = Factory.create(:organization)
    @network.organizations << @organization2
    @organization.networks.delete(@network)
    @network.owner.should eql(@organization2)
  end  
  
  it "Should notify us when a pending account has been created" do
    @organization.pending = true
    Notifier.should_receive(:deliver_pending_account_creation_notification)
    @organization.save!
  end 
  
  it "Should destroy any sponsored surveys" do
    @organization.save
    @survey = Factory(:running_survey, :sponsor => @organization)
    @question = Factory(:question, :survey => @survey)
    @participation = Factory.build(:participation, :survey => @survey, :participant => @organization, :responses => [])
    
    @participation.responses << Factory.build(:response, :question => @question)
    @participation.save
    
    lambda{ @organization.destroy }.should change(@organization.sponsored_surveys, :count).from(1).to(0)
  end 
  
  it "should expire any opt outs" do
    Factory.create(:opt_out, :email => @organization.email)
    OptOut.find_by_email(@organization.email).should_not be_nil

    @organization.save

    OptOut.find_by_email(@organization.email).should be_nil
  end
end

describe Organization, "built from an invitation" do
  before(:each) do
    @invitation = Factory.create(:external_invitation)
    @organization = Organization.new(:invitation => @invitation)
  end
  
  after(:each) do
    @invitation.destroy
  end
  
  it "should have a name" do
    @organization.name.should == @invitation.organization_name
  end   
  
  it "should have an email" do
    @organization.email.should == @invitation.email
  end   
  
  it "should be activated" do
    @organization.activated?.should be_true
  end
  
  it "should not be pending" do
    @organization.pending?.should be_false
  end  

end

describe Organization, "not built from an invitation" do
  before(:each) do
    @organization = Organization.new
  end
    
  it "should be pending" do
  # Checks to make sure this email address hasn't opted out from our communications.
  def not_opted_out
    if !OptOut.find_by_email(self.email).nil?
      errors.add_to_base "We cannot send this invitation because #{self.email} has opted out of receiving email from CompSage."
    end
  end
    @organization.pending?.should be_true
  end   
  
  it "should not be activated" do
    @organization.activated?.should be_false
  end   
  
  it "should have an activation key" do
    @organization.activation_key.should_not be_nil
  end
  
  it "should have an activation key created at" do
    @organization.activation_key_created_at.should_not be_nil
  end  

end

describe Organization, "that is pending and requires activation" do

  before(:each) do
    @organization = Factory(:pending_organization)
  end
 
  it "Should be activated after activation" do
    lambda{ @organization.activate }.should change(@organization, :activated?).from(false).to(true)
  end
  
  it "Should not have exceeded the reporting threshold" do
    @organization.has_exceeded_reporting_threshold?.should be_false
  end
  
  it "Should exceed the reporting threshold after being reported" do
    lambda{ @organization.increment(:times_reported) }.should change(@organization, :has_exceeded_reporting_threshold?).from(false).to(true)
  end
  
  it "Should not have an expired activation window" do
    @organization.activation_window_has_expired?.should be_false
  end
  
  it "Should have an expired activation window after 3 days without activation" do
    @organization.activation_key_created_at = 4.days.ago
    @organization.activation_window_has_expired?.should be_true
  end 
  
  it "Should not be disabled" do
    @organization.disabled?.should be_false
  end
  
  it "Should be disabled after exceeding the times reported threshold" do
    lambda{ @organization.increment(:times_reported) }.should change(@organization, :disabled?).from(false).to(true)
  end
  
  it "Should be disabled after exceeding the activation window" do
    @organization.activation_key_created_at = 4.days.ago
    @organization.disabled?.should be_true
  end  
  
  it "Should increment the times reported flag when reported" do
    lambda{ @organization.report }.should change(@organization, :times_reported).from(0).to(1)
  end
  
  it "Should deliver a notification email when reported" do
    Notifier.should_receive(:deliver_report_pending_organization)
    @organization.report
  end  

end

describe Organization, "that is going to be an uninitialized association member" do
  before(:each) do
    @association  = Factory.create(:association)
  end
  
  after(:each) do
    @association.destroy
  end  

  it "should be invalid if the org has opted out" do
    opt_out = Factory.create(:opt_out)
    org = Factory.build(:uninitialized_association_member, :email => opt_out.email)

    org.should_not be_valid
  end

end

describe Organization, "that is an uninitialized association member" do
  
  before(:each) do
    @organization = Factory.create(:uninitialized_association_member)
    @association  = Factory.create(:association)
  end
  
  after(:each) do
    @organization.destroy
    @association.destroy
  end  
  
  it "should not allow a blank password when creating the login" do
    @organization.create_login(@association, {
      :password => "",
      :password_confirmation => ""
    }).should be_false  
    
    @organization.should have(1).errors_on(:password)
  end
  
  it "should not allow a mismatched password when creating the login" do
    @organization.create_login(@association, {
      :password => "test12",
      :password_confirmation => ""
    }).should be_false  
    
    @organization.should have(1).errors_on(:password)
  end  
    
  it "should no longer be uninitialized" do   
    lambda{ @organization.create_login(@association, {
      :password => "test12",
      :password_confirmation => "test12"
    }) }.should change(@organization, :uninitialized_association_member).from(true).to(false)
  end  
  
  it "should delete itself when removed as an association member" do
    @organization.should_receive(:destroy).twice # once in leave, once in cleanup.
    @organization.associations << @association
    @organization.leave_association(@association)
  end
  
  it "should be deletable and updatable by association" do
    @organization.association_can_update?.should be_true
  end

end


describe Organization, "That is in an association (and is initialized)" do
  before(:each) do
    @organization = Factory.create(:organization)
    @association  = Factory.create(:association)
    @association.organizations << @organization
  end
  
  after(:each) do
    @organization.destroy
    @association.destroy
  end

  it "should not delete itself when leaving the association" do
    @organization.leave_association(@association)
    @organization.should_receive(:destroy).once # In cleanup.
  end

  it "should no longer be a member of the association after leaving" do
    @organization.leave_association(@association)
    @organization.associations.should_not include(@association)
  end
  
  it "should not be deletable and updatable by association" do
    @organization.association_can_update?.should be_false
  end
end

describe Organization, "that has been deactivated" do
  before(:each) do
    @organization = Factory.build(:organization)
    @organization.deactivate
  end
  
  it "should be deactivated" do
    @organization.deactivated?.should be_true
  end  
  
  it "should be disabled" do
    @organization.disabled?.should be_true
  end  
  
end  
