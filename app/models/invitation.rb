class Invitation < ActiveRecord::Base
  belongs_to :invitee, :class_name => "Organization", :foreign_key => "invitee_id"
  belongs_to :inviter, :class_name => "Organization", :foreign_key => "inviter_id"
  
  #validates_presence_of :invitee (this has been pushed down to lower classes due to external invites)
  validates_presence_of :inviter
  
  named_scope :recent, :order => 'invitations.created_at DESC', :limit => 10
  
  #This will sort the invitations by invitee organization name, regardless of type
  def <=>(o)
    (self.kind_of?(ExternalInvitation) ? self.organization_name.to_s : self.invitee.name.to_s).casecmp(
     (o.kind_of?(ExternalInvitation) ? o.organization_name.to_s : o.invitee.name.to_s))
  end
  
end
