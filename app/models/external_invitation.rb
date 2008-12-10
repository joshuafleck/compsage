require 'digest/sha1'
class ExternalInvitation < Invitation
  include Authentication

  belongs_to :inviter, :class_name => "Organization", :foreign_key => "inviter_id"
  
  validates_presence_of :email,    :message => PRESENCE_OF_ERROR_MESSAGE
  validates_length_of   :email,    :within => 6..100 #r@a.wk
  validates_format_of   :email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD
  validates_format_of   :organization_name,     :with => RE_NAME_OK,  :message => MSG_NAME_BAD, :allow_nil => true
  validates_length_of   :organization_name,     :within => 3..100,    :allow_nil => true
  validates_length_of   :name, :maximum => 100, :allow_nil => :true
  
  attr_accessible :email, :name, :inviter, :message, :organization_name
  
  attr_accessor :message
  
  before_create :create_key
  
  protected
   
    def create_key
      self[:key] = [Digest::SHA1.digest(Time.now.to_f.to_s + Array.new(){rand(256)}.pack('c*'))].pack("m")[0..19]
    end
  
end
