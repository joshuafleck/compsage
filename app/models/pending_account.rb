class PendingAccount < ActiveRecord::Base
  
  before_validation :strip_phone
  before_create :create_key
  
  validates_presence_of :email
  validates_length_of   :email,  :within => 3..100
  validates_format_of   :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email"  
  validates_presence_of :organization_name
  validates_length_of   :organization_name,  :within => 3..100
  validates_presence_of :contact_first_name
  validates_length_of   :contact_first_name,  :within => 2..100
  validates_presence_of :contact_last_name
  validates_length_of   :contact_last_name,  :within => 2..100
  validates_presence_of :phone
  validates_length_of   :phone,  :is =>10
  validates_length_of   :phone_extension,  :maximum =>6, :allow_nil => true
  
  attr_accessible :email, :organization_name, :contact_first_name, :contact_last_name, :phone, :phone_extension, :approved
  attr_accessor :approved
  
  def approve
    self[:approved] = "1"
    self.save  
  end
  
  private
  
  ##
  # Strip the extra characters out of the phone number.
  
  def strip_phone
    phone.gsub!(/\D/, '') unless phone.blank?
  end
  
  protected
   
  def create_key
    self.key = KeyGen.random
  end
end
