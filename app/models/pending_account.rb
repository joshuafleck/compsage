require 'digest/sha1'
class PendingAccount < ActiveRecord::Base

  validates_presence_of :email
  validates_length_of   :email,  :within => 3..100
  validates_format_of   :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email"  
  validates_presence_of :name
  validates_length_of   :name,  :within => 3..100
  validates_presence_of :contact_first_name
  validates_length_of   :contact_first_name,  :within => 3..100
  validates_presence_of :contact_last_name
  validates_length_of   :contact_last_name,  :within => 3..100
  validates_presence_of :phone_area
  validates_length_of   :phone_area,  :is =>10
  validates_length_of   :phone_extension,  :maximum =>4, :allow_nil => true
  
  attr_accessible :email, :name, :contact_first_name, :contact_last_name, :phone_area, :phone_pre, :phone_post, :phone_ext
  	

end
