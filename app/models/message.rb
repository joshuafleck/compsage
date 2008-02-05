class Message < ActiveRecord::Base
  
   belongs_to :organization, :foreign_key => "sender_id"
   belongs_to :organization, :foreign_key => "receiver_id"   
   belongs_to :message, :foreign_key => "parent"   
   has_many :messages
end
