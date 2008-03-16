require 'digest/sha1'
class ExternalInvitation < ActiveRecord::Base

  belongs_to :inviter, :class_name => "Organization", :foreign_key => "inviter_id"
  
  validates_presence_of :email
  validates_length_of   :email,  :within => 3..100
  validates_format_of   :email,  :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email"  
  validates_presence_of :inviter
  validates_length_of   :name,   :within => 3..100, :allow_nil => true
  
  attr_accessible :email, :name  
  
  before_save :create_key
  
  protected
  
    # before filter 
    def create_key
      	self.key = [Digest::SHA1.digest(Time.now.to_f.to_s + Array.new(){rand(256)}.pack('c*'))].pack("m")[0..19] if new_record?
    end
  
end
