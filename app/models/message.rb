class Message < ActiveRecord::Base
  
   belongs_to :sender, :class_name => "Organization", :foreign_key => "sender_id"
   belongs_to :receiver, :class_name => "Organization", :foreign_key => "receiver_id"   
   belongs_to :root, :foreign_key => "parent_id", :class_name => "Message"
   has_many :messages, :foreign_key => "parent_id", :dependent => :destroy
   
   validates_presence_of :sender
   validates_presence_of :receiver
   validates_length_of :title, :allow_nil => true, :maximum => 128
   validates_length_of :body, :allow_nil => true, :maximum => 1024
   
end
