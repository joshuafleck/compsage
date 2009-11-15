require File.dirname(__FILE__) + '/../spec_helper'

describe Invitation do
   
  before(:each) do
    @invitation = Factory.build(:invitation)
  end
  
  it "should be valid" do
    @invitation.should be_valid
  end  
     
  it "should belong to an invitee" do
    Invitation.reflect_on_association(:invitee).should_not be_nil
  end
  
  it "should belong to an inviter" do
    Invitation.reflect_on_association(:inviter).should_not be_nil
  end
  
  it "should be invalid without an inviter" do
    @invitation.inviter = nil
    @invitation.should have(1).errors_on(:inviter)
  end
 
end

describe Invitation, "creating an external invitation" do
   
  before(:each) do
    @inviter = Factory.create(:organization)
    @network = Factory.create(:network, :owner => @inviter)
    @survey = Factory.create(:survey, :sponsor => @inviter)
    @member = Factory.create(:organization)
    @uninitialized_member = Factory.create(:uninitialized_association_member)
    @external_invitation_params = {:email => "flec0025@umn.edu", :organization_name => "compsage", :inviter => @inviter}
    @uninitialized_invitation_params = {:email => @uninitialized_member.email, :organization_name => "compsage", :inviter => @inviter}
    @internal_invitation_params = {:email => @member.email, :inviter => @inviter}
  end
  
  after(:each) do
    @network.destroy
    @survey.destroy
    @inviter.destroy
    @member.destroy
    @uninitialized_member.destroy
  end  
  
  it "should create an internal invitation for a survey if the email address belongs to a member" do
    @invitation = Invitation.new_external_invitation_to(@survey, @internal_invitation_params)
    lambda{ @invitation.save! }.should change(@survey.invitations, :count).by(1)
  end 
  
  it "should create an internal invitation for a network if the email address belongs to a member" do
    @invitation = Invitation.new_external_invitation_to(@network, @internal_invitation_params)
    lambda{ @invitation.save! }.should change(@network.invitations, :count).by(1)
  end   
  
  it "should create an external invitation for a survey" do
    @invitation = Invitation.new_external_invitation_to(@survey, @external_invitation_params)
    lambda{ @invitation.save! }.should change(@survey.external_invitations, :count).by(1)
  end    
  
  it "should create an external invitation for a network" do
    @invitation = Invitation.new_external_invitation_to(@network, @external_invitation_params)
    lambda{ @invitation.save! }.should change(@network.external_invitations, :count).by(1)
  end  
  
  it "should create an external invitation for a network when the invitee is an uninitialized association member" do
    @invitation = Invitation.new_external_invitation_to(@network, @uninitialized_invitation_params)
    lambda{ @invitation.save! }.should change(@network.external_invitations, :count).by(1)
  end       
  
end

describe Invitation, "creating an internal invitation" do
   
  before(:each) do
    @inviter = Factory.create(:organization)
    @network = Factory.create(:network, :owner => @inviter)
    @survey = Factory.create(:survey, :sponsor => @inviter)
    @initialized_member = Factory.create(:organization)
    @uninitialized_member = Factory.create(:uninitialized_association_member)
    @internal_invitation_params = {:invitee => @initialized_member, :inviter => @inviter}
    @external_invitation_params = {:invitee => @uninitialized_member, :inviter => @inviter}
  end
  
  after(:each) do
    @network.destroy
    @survey.destroy
    @inviter.destroy
    @initialized_member.destroy
    @uninitialized_member.destroy
  end  
  
  it "should create an internal invitation for a survey if the member is not an uninitialized association member" do
    @invitation = Invitation.new_invitation_to(@survey, @internal_invitation_params)
    lambda{ @invitation.save! }.should change(@survey.invitations, :count).by(1)
  end 
  
  it "should create an internal invitation for a network if the member is not an uninitialized association member" do
    @invitation = Invitation.new_invitation_to(@network, @internal_invitation_params)
    lambda{ @invitation.save! }.should change(@network.invitations, :count).by(1)
  end   
  
  it "should create an external invitation for a survey if the member is an uninitialized association member" do
    @invitation = Invitation.new_invitation_to(@survey, @external_invitation_params)
    lambda{ @invitation.save! }.should change(@survey.external_invitations, :count).by(1)
  end    
  
  it "should create an external invitation for a network if the member is an uninitialized association member" do
    @invitation = Invitation.new_invitation_to(@network, @external_invitation_params)
    lambda{ @invitation.save! }.should change(@network.external_invitations, :count).by(1)
  end      
  
end
