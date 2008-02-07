class Message < ActiveRecord::Base
  
   belongs_to :sender, :class_name => "Organization", :foreign_key => "sender_id"
   belongs_to :receiver, :class_name => "Organization", :foreign_key => "receiver_id"   
   belongs_to :root, :foreign_key => "parent_id", :class_name => "Message"
   has_many :messages, :foreign_key => "parent_id", :dependent => :destroy
end
