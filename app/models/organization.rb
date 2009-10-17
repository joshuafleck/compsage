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
    
    # This will cause any changes to surveys between index rebuilds to be stored in a delta index until the next rebuild
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
  
  has_many :network_invitations, :class_name => "NetworkInvitation", :foreign_key => "invitee_id", :dependent => :destroy
  has_many :survey_invitations, :class_name => "SurveyInvitation", :foreign_key => "invitee_id", :dependent => :destroy  
  has_many :invitations, :class_name => "Invitation", :foreign_key => "invitee_id", :dependent => :destroy
  
  validates_presence_of     :name
  validates_format_of       :name,     :with => RE_NAME_OK,  :message => MSG_NAME_BAD, :allow_nil => true
  validates_length_of       :name,     :within => 3..100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD

  validates_presence_of     :zip_code
  validates_format_of       :zip_code, :with => /^\d{5}$/
  validates_length_of       :location, :maximum => 60, :allow_nil => :true
  validates_length_of       :industry, :maximum => 100, :allow_nil => :true
  validates_length_of       :contact_name, :maximum => 100, :allow_nil => :true
  validates_length_of       :city, :maximum => 50, :allow_nil => :true
  validates_length_of       :state, :maximum => 30, :allow_nil => :true
  validates_length_of       :crypted_password, :maximum => 40, :allow_nil => :true
  validates_length_of       :salt, :maximum => 40, :allow_nil => :true
  
  validates_acceptance_of :terms_of_use, :on => :create  
  attr_accessor :terms_of_use

  attr_accessible :email, :password, :password_confirmation, :name, :location, :city, :state, :zip_code, :contact_name,
                  :industry, :logo, :terms_of_use
  
  # This organization's name and location if they have one.
  #
  def name_and_location
    if location.blank?
      name
    else
      "#{name} " + "–" + " #{location}"
    end
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  def self.authenticate(email, password)
    u = find_by_email(email) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  # Creates a random key that expires 5 days from now that the user can use to reset his password.
  #
  def create_reset_key_and_send_reset_notification
    self.reset_password_key = KeyGen.random
    self.reset_password_key_created_at = Time.now
    self.reset_password_key_expires_at = Time.now + 5.days
    self.save!
    
    Notifier.deliver_reset_password_key_notification(self)
  end
  
  # True, if the reset password key expiration date is in the past.
  #
  def reset_password_key_expired?
    self.reset_password_key_expires_at < Time.now
  end
  
  # True, if the user has not requested a password reset in the last minute
  #
  def can_request_password_reset?
    reset_password_key_created_at.nil? || ((Time.now - reset_password_key_created_at) > 1.minute)
  end
  
  # Removes the reset key and expiry date.
  #
  def delete_reset_key
    self.reset_password_key = nil
    self.reset_password_key_created_at = nil
    self.reset_password_key_expires_at = nil
    self.save!
  end
  
  # overriding the default constructor in order to autofill some attributes
  def initialize(params = nil) 
    super
    
    invitation_or_pending_account = params[:invitation_or_pending_account] if params
    
    if invitation_or_pending_account then 
    
      self.name = invitation_or_pending_account.organization_name
      self.email = invitation_or_pending_account.email
      
      if invitation_or_pending_account.is_a? PendingAccount then
        self.contact_name = invitation_or_pending_account.contact_first_name + 
          " " + invitation_or_pending_account.contact_last_name
      end
      
    end
    
  end  

  private
  
  # Destroy the network if it has zero members.
  #
  def delete_empty_network_or_promote_owner(network)
    if network.organizations.empty? then
      network.destroy 
    elsif self == network.owner then
      network.promote_new_owner
    end
  end
  
  # Joins the network just created by this organization.
  #
  def join_created_network(network)
    networks << network
  end
  
  # Finds the closest zipcode we have in our DB to the one they changed to. Convert the degrees to radians to facilitate
  # geodistance searching.
  #
  # Fuzzy is how many zipcodes away the routine is searching for a matching zipcode in our database. Because our zipcode
  # data is not up-to-date, there are lots of gaps, so sometimes we may have to search a ways away to find a zipcode
  # with a known geolocation. Increasing the fuzzy threshold will increase the odds of finding a valid geolocation for
  # an organization also increasing the error in geolocation. Reducing the fuzzy threshold will reduce the amount of
  # error in the geolocation, but increases the chances of not finding an actual geolocation at all.
  #
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
