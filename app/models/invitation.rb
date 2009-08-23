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
