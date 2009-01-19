require 'digest/sha1'

class Organization < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  before_save :assign_latitude_and_longitude
  
  define_index do
    indexes :name, :sortable => true
    indexes :contact_name
    indexes :email
    indexes :industry
    
    has 'latitude', :as => :latitude, :type => :float
    has 'longitude', :as => :longitude, :type => :float

    set_property :latitude_attr   => "latitude"
    set_property :longitude_attr  => "longitude"
    
    # this will cause any changes to surveys between index rebuilds to be stored in a delta index until the next rebuild
    set_property :delta => true
  end
    
  has_many :networks, :through => :network_memberships, :after_remove => :delete_empty_network_or_promote_owner
  has_many :network_memberships, :dependent => :destroy
  
  has_many :owned_networks, :class_name => "Network", :foreign_key => "owner_id", :after_add => :join_created_network
  
  has_many :sponsored_surveys, :class_name => 'Survey',
    :foreign_key => "sponsor_id"
    
  has_many :participated_surveys, :class_name => "Survey",
    :through => :participations,
    :source => 'survey'
    
  has_many :invited_surveys, :class_name => "Survey",
    :through => :survey_invitations,
    :source => 'survey'
    
  has_many :invited_networks, :class_name => "Network",
    :through => :network_invitations,
    :source => 'network'    
    
  has_many :survey_subscriptions, :dependent => :destroy
  has_many :surveys, :through => :survey_subscriptions, :order => 'created_at DESC'
  
  has_many :participations, :as => :participant
  has_many :discussions, :as => :responder
  has_many :responses, :through => :participations
  
  has_many :sent_network_invitations, :class_name => "NetworkInvitation", :foreign_key => "inviter_id"
  has_many :sent_external_network_invitations, :class_name => "ExternalNetworkInvitation", :foreign_key => "inviter_id"
  has_many :sent_survey_invitations, :class_name => "SurveyInvitation", :foreign_key => "inviter_id"
  has_many :sent_external_survey_invitations, :class_name => "ExternalSurveyInvitation", :foreign_key => "inviter_id"
  has_many :network_invitations, :class_name => "NetworkInvitation", :foreign_key => "invitee_id", :dependent => :destroy
  has_many :survey_invitations, :class_name => "SurveyInvitation", :foreign_key => "invitee_id", :dependent => :destroy  
  has_many :invitations, :class_name => "Invitation", :foreign_key => "invitee_id", :dependent => :destroy
  has_many :sent_global_invitations, :class_name => "ExternalInvitation", :foreign_key => "inviter_id"
  
  has_one :logo, :dependent => :destroy

  validates_presence_of     :name
  validates_format_of       :name,     :with => RE_NAME_OK,  :message => MSG_NAME_BAD, :allow_nil => true
  validates_length_of       :name,     :within => 3..100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD

  validates_presence_of     :zip_code
  validates_length_of       :zip_code, :is => 5
  validates_length_of       :location, :maximum => 60, :allow_nil => :true
  validates_length_of       :industry, :maximum => 100, :allow_nil => :true
  validates_length_of       :contact_name, :maximum => 100, :allow_nil => :true
  validates_length_of       :city, :maximum => 50, :allow_nil => :true
  validates_length_of       :state, :maximum => 30, :allow_nil => :true
  validates_length_of       :crypted_password, :maximum => 40, :allow_nil => :true
  validates_length_of       :salt, :maximum => 40, :allow_nil => :true
  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :email, :password, :password_confirmation, :name, :location, :city, :state, :zip_code, :contact_name, :industry, :logo
  
  # build the logo based on its attributes
  def logo=(logo_attr)
    # check for existing logo and remove it if it is being replaced
    if !logo_attr[:uploaded_data].blank? then
      if !self.new_record? then
        old_logo = Logo.find_by_organization_id(self[:id])
        old_logo.destroy unless old_logo.nil?
      end
      self.build_logo(logo_attr)    
    end
  end
  
  # returns the organization's name and location if they have one.
  def name_and_location
    if location.blank?
      name
    else
      "#{name} &ndash; #{location}"
    end
  end
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(email, password)
    u = find_by_email(email) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  #code for reset password
   def create_reset_key
     self[:reset_password_key] = [Digest::SHA1.digest(Time.now.to_f.to_s + Array.new(){rand(256)}.pack('c*'))].pack("m")[0..19]
     self.reset_password_key_expires_at = Time.now + 5.days
     self.save!
   end
  
  def delete_reset_key
    self.reset_password_key = nil
    self.reset_password_key_expires_at = nil
    self.save!
  end

  protected
  
  # Destroy the network if it has zero members.
  def delete_empty_network_or_promote_owner(network)
    if network.organizations.empty? then
      network.destroy 
    elsif self == network.owner then
      network.promote_new_owner
    end
  end
  
  # Joins the network just created by this organization.
  def join_created_network(network)
    networks << network
  end
  
  # Creates a survey subscription for a sponsored survey
  def subscribe_to_sponsored_survey(survey)
    survey_subscriptions.create(:survey => survey, :type => 'sponsor')
  end
  
  # Creates a survey subscription of a participated survey
  def subscribe_to_participated_survey(survey)
    survey_subscriptions.create(:survey => survey, :type => 'participant')
  end
  
  # finds the closest zipcode we have in our DB to the one they changed to.  Convert the
  # degrees to radians to facilitate geodistance searching.
  def assign_latitude_and_longitude
    if zip_code_changed? then
      current_code = zip_code.to_i
      fuzzy = 0
      while !((zip = ZipCode.find_by_zip(current_code + fuzzy)) ||
               ((zip = ZipCode.find_by_zip(current_code - fuzzy)) && fuzzy > 0)
              ) do
        fuzzy += 1
        if fuzzy > 10 then
          zip = ZipCode.new(:latitude => 44.935465, :longitude => -93.254023)
          break
        end
      end
      
      self[:latitude] = zip.latitude * (Math::PI / 180)
      self[:longitude] = zip.longitude * (Math::PI / 180)
    end
  end
end
