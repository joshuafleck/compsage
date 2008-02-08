class Invitation < ActiveRecord::Base
  belongs_to :invitee, :class_name => "Organization", :foreign_key => "invitee_id"
  belongs_to :inviter, :class_name => "Organization", :foreign_key => "inviter_id"
end
