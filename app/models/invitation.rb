class Invitation < ActiveRecord::Base
  belongs_to :invitee, :class_name => "Organization", :foreign_key => "invitee_id"
  belongs_to :inviter, :class_name => "Organization", :foreign_key => "inviter_id"
  
  validates_presence_of :inviter
  
  named_scope :pending, :conditions => {:aasm_state => 'pending'}
  named_scope :not_pending, :conditions => 'aasm_state <> "pending"'
  named_scope :sent, :conditions => {:aasm_state => 'sent'}
  named_scope :ordered_by, lambda { |o| {:order => o } }
  
  def to_s
    self.invitee.name_and_location
  end
    
  # This will sort the invitations by invitee organization name, regardless of type
  def <=>(o)
    self.to_s.casecmp(o.to_s)
  end
     
  # Makes a new external invitation, assuming the email address specified doesn't already belong to a compsage member.
  # If the email address specified is a compsage member, this method will return an internal invitation.
  # If the email address specified belongs to an uninitialized association member, this method will return an external invitation
  #
  def self.new_external_invitation_to(network_or_survey, params = {})
    if organization = Organization.is_not_uninitialized_association_member.find_by_email(params[:email]) then
      # Organization with this contact email is already in our database. Create internal invitation.
      return network_or_survey.invitations.new(params.merge(:invitee => organization))
    else
      return network_or_survey.external_invitations.new(params)
    end
  end
  
  # Makes a new internal invitation.
  # If the invitee is an uninitialized association member, this method will return an external invitation.
  # Uninitialized organizations do not have logins, and thus cannot receive internal invitations.
  def self.new_invitation_to(network_or_survey, params = {})
    invitee = params[:invitee]
    if invitee.is_uninitialized_association_member? then
      return network_or_survey.external_invitations.new(
        params.merge({
          :email => invitee.email,
          :organization_name => invitee.name
        })
      )
    else
      return network_or_survey.invitations.new(params)
    end
  end  

  protected
   
  def create_key
    self.key = KeyGen.random
  end
end
