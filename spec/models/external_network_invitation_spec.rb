require File.dirname(__FILE__) + '/../spec_helper'

describe ExternalNetworkInvitation do

  before(:each) do
    @invitation = Factory.build(:external_network_invitation)
  end
  
  it "should be valid" do
    @invitation.should be_valid
  end  
      
  it "should belong to a network" do
    ExternalNetworkInvitation.reflect_on_association(:network).should_not be_nil
  end
   
  it "should be invalid without a network" do
    @invitation.network = nil
    @invitation.should have(1).error_on(:network)
  end

  it "should be invalid if the invitee is already invited" do
    @invitation.save!
    @duplicate_invitation = @invitation.network.external_invitations.new(
      :inviter => @invitation.inviter, 
      :email => @invitation.email, 
      :organization_name => @invitation.organization_name)
      
    @duplicate_invitation.should have(1).error_on(:base)
    @invitation.destroy
  end  
  
  it "should send a notification email on create" do
    Notifier.should_receive(:deliver_external_network_invitation_notification)
    @invitation.save!
    @invitation.destroy
  end    
  
end  
