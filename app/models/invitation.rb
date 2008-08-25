class Invitation < ActiveRecord::Base
  belongs_to :invitee, :class_name => "Organization", :foreign_key => "invitee_id"
  belongs_to :inviter, :class_name => "Organization", :foreign_key => "inviter_id"
  
  #validates_presence_of :invitee (this has been pushed down to lower classes due to external invites)
  validates_presence_of :inviter
  
  named_scope :recent, :order => 'invitations.created_at DESC', :limit => 10
  
end
