require File.dirname(__FILE__) + '/../spec_helper'

describe NetworkInvitation do

  before(:each) do
    @network = Factory.create(:network)
    @invitation = Factory.build(:network_invitation, :network => @network)
  end
  
  after(:each) do
    @network.destroy
  end  
  
  it "should be valid" do
    @invitation.should be_valid
  end  
   
  it "should belong to a network" do
    NetworkInvitation.reflect_on_association(:network).should_not be_nil
  end
   
  it "should be invalid without a network" do
    @invitation.network = nil
    @invitation.should have(1).error_on(:network)
  end
   
  it "should be invalid without an invitee" do
    @invitation.invitee = nil
    @invitation.should have(1).error_on(:invitee)
  end

  it "should be invalid if the invitee is already invited" do
    @invitation.save!
    @invitation.reload
    @duplicate_invitation = @invitation.network.invitations.new(
      :inviter => @invitation.inviter, 
      :invitee => @invitation.invitee)
      
    @duplicate_invitation.should have(1).error_on(:base)
    @invitation.destroy
  end  
  
  it "should be invalid if the invitee is already a member" do
    @member = Factory.create(:organization)
    @network.organizations << @member
        
    @invitation.invitee = @member    
    @invitation.should have(1).error_on(:base)
  end    
  
  it "should be invalid if the invitee is the network owner" do        
    @invitation.invitee = @network.owner    
    @invitation.should have(1).error_on(:base)
  end    
  
  it "should destroy the invitation when it is accepted" do
    @invitation.save!
    @invitation.reload
    
    lambda{ @invitation.accept! }.should change(NetworkInvitation, :count).by(-1)
    
  end   
  
  it "should add the invitee as a network member when accepted" do
    @invitation.save!
    @invitation.reload
    
    lambda{ @invitation.accept! }.should change(@invitation.invitee.networks, :count).by(1)
    
    @invitation.destroy
  end    
  
  it "should send a notification email on create" do
    Notifier.should_receive(:deliver_network_invitation_notification)
    @invitation.save!
    @invitation.destroy
  end        
  
end 
