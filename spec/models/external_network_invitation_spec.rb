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
    
  describe "accepting the invitation" do  
  
    before(:each) do
      @invitee = Factory.create(:organization)
      @invitation.save!
    end
    
    after(:each) do
      @invitation.destroy
      @invitee.destroy
    end 
    
    
    it "should destroy the invitation when it is accepted" do      
      lambda{ @invitation.accept!(@invitee) }.should change(ExternalNetworkInvitation, :count).by(-1)
    end   
    
    it "should add the invitee as a network member when accepted" do
      lambda{ @invitation.accept!(@invitee) }.should change(@invitee.networks, :count).by(1)
    end    
   
  end 
  
end  
