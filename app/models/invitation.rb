class Invitation < ActiveRecord::Base
  belongs_to :invitee, :class_name => "Organization", :foreign_key => "invitee_id"
  belongs_to :inviter, :class_name => "Organization", :foreign_key => "inviter_id"
  
  #validates_presence_of :invitee (this has been pushed down to lower classes due to external invites)
  validates_presence_of :inviter
  
  named_scope :recent, :order => 'invitations.created_at DESC', :limit => 10
  named_scope :pending, :conditions => {:aasm_state => 'pending'}
  named_scope :not_pending, :conditions => 'aasm_state <> "pending"'
  named_scope :sent, :conditions => {:aasm_state => 'sent'}
  
  #This will sort the invitations by invitee organization name, regardless of type
  def <=>(o)
    (self.kind_of?(ExternalInvitation) ? self.organization_name.to_s : self.invitee.name.to_s).casecmp(
     (o.kind_of?(ExternalInvitation) ? o.organization_name.to_s : o.invitee.name.to_s))
  end
  
  #This will locate invitees and send internal/external invitations
  def self.create_internal_or_external_invitations(external_invitees, invitees, networks, inviter, network_or_survey)
    invited_organizations = invitees
    sent_invitations = []
    invalid_invitations = []
    
    # find members of the invited networks, stripping out the inviter (he is already invited)
    networks.each do |network| invited_organizations += (network.organizations - [inviter]) end
    
    # make sure none of the external invitees are already members, send external invitations
    external_invitees.each do |external_invitee|       
      if !(organization_found = Organization.find_by_email(external_invitee[:email])).nil? then
        invited_organizations << organization_found
      else
        external_invitee[:inviter] = inviter
        invitation = network_or_survey.external_invitations.new(external_invitee)
        if invitation.save then
          sent_invitations << invitation
        else
          invalid_invitations << invitation
        end
      end
    end
    
    # send internal invitations
    invited_organizations.uniq.each do |invitee|      
      invitation = network_or_survey.invitations.new(:invitee => invitee, :inviter => inviter)
      if invitation.save then
        sent_invitations << invitation
      else
        invalid_invitations << invitation
      end
    end
    
    [sent_invitations, invalid_invitations]
    
  end
   
  # Makes a new external invitation, assuming the email address specified doesn't already belong to a compsage member.
  # If the email address specified is a compsage member, this method will return an internal invitation.
  #
  def self.new_external_invitation_to(network_or_survey, params = {})
    if organization = Organization.find_by_email(params[:email]) then
      # Organization with this contact email is already in our database. Create internal invitation.
      return network_or_survey.invitations.new(params.merge(:invitee => organization))
    else
      return network_or_survey.external_invitations.new(params)
    end
  end

end
