class Organization < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include PhoneNumberFormatter
  format_phone_fields :phone  
  
  xss_terminate :except => [ :naics_code ]

  before_save :assign_latitude_and_longitude
  after_create :send_pending_account_notification
  before_destroy :remove_sponsored_surveys
  
  has_many :networks, :through => :network_memberships, :after_remove => :delete_empty_network_or_promote_owner
  has_many :network_memberships, :dependent => :destroy
  has_many :owned_networks, :class_name => "Network", :foreign_key => "owner_id", :after_add => :join_created_network, :dependent => :destroy
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
  
  has_many :participations, :as => :participant, :dependent => :destroy
  has_many :discussions, :as => :responder, :dependent => :destroy
  has_many :responses, :through => :participations
  
  has_many :network_invitations, :class_name => "NetworkInvitation", :foreign_key => "invitee_id", :dependent => :destroy
  has_many :survey_invitations, :class_name => "SurveyInvitation", :foreign_key => "invitee_id", :dependent => :destroy  
  has_many :invitations, :class_name => "Invitation", :foreign_key => "invitee_id", :dependent => :destroy

  has_and_belongs_to_many :associations
  
  belongs_to :naics_classification, :foreign_key => :naics_code
  
  named_scope :is_not_uninitialized_association_member, :conditions => {:uninitialized_association_member => false}  
  
  validates_presence_of     :name
  validates_format_of       :name,     :with => RE_NAME_OK,  :message => MSG_NAME_BAD, :allow_blank => true
  validates_length_of       :name,     :within => 3..100, :allow_blank => true

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100, :allow_blank => true #r@a.wk
  validates_uniqueness_of   :email,    :case_sensitive => false, :allow_blank => true
  validates_format_of       :email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD, :allow_blank => true

  validates_format_of       :zip_code, :with => /^\d{5}$/, :allow_blank => true
  validates_length_of       :location, :maximum => 60, :allow_blank => true
  validates_presence_of     :contact_name, :if => Proc.new { |user| user.pending? }
  validates_length_of       :contact_name, :maximum => 100, :allow_blank => true
  validates_length_of       :city, :maximum => 50, :allow_blank => true
  validates_length_of       :state, :maximum => 30, :allow_blank => true
  validates_length_of       :crypted_password, :maximum => 40, :allow_blank => true
  validates_length_of       :salt, :maximum => 40, :allow_blank => true
  validates_presence_of     :phone, :if => Proc.new { |user| user.pending? }
  validates_length_of       :phone,  :is =>10, :allow_blank => true
  validates_length_of       :phone_extension,  :maximum => 6, :allow_blank => true
  validates_numericality_of :size, :allow_blank => true
  
  validates_acceptance_of :terms_of_use, :on => :create  
  attr_accessor :terms_of_use

  attr_accessible :email, :password, :password_confirmation, :name, :location, :city, :state, :zip_code, :contact_name,
                  :terms_of_use, :phone, :phone_extension, :size, :naics_code

  # Constant definition
  METERS_PER_MILE = 1609.344
  ACTIVATION_WINDOW_IN_DAYS = 3
  
  named_scope :pending, :conditions => {:pending => true}        
  
  # Sphinx setup
  define_index do
    indexes :name, :sortable => true
    indexes :contact_name
    indexes :email
    
    has uninitialized_association_member
    has associations(:id), :as => :association_ids
    has naics_classification(:code), :as => :naics_code
    
    has 'latitude', :as => :latitude, :type => :float
    has 'longitude', :as => :longitude, :type => :float
    has 'size', :as => :size, :type => :integer

    set_property :latitude_attr   => "latitude"
    set_property :longitude_attr  => "longitude"
    
    # This will cause any changes to surveys between index rebuilds to be 
    #  stored in a delta index until the next rebuild
    set_property :delta => true
  end
      
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
    u = Organization.is_not_uninitialized_association_member.find_by_email(email) # need to get the salt
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
 
  # If the activated_at column is set, we know the organization is activated
  #
  def activated?
    !!self.activated_at
  end

  # Sets the activated_at time to signify the organization has activated their account
  #
  def activate
    self.activated_at = Time.now
    self.save!
  end
  
  # If true, the user has waited too long before activating their account and will be prevented from logging in
  #
  def activation_window_has_expired?
    !activated? && (Time.now - activation_key_created_at) > ACTIVATION_WINDOW_IN_DAYS.days
  end
  
  # An organization is deactivated when a user determines that an account was 
  #  created using their email address without their knowledge
  def deactivated?
    !!self.deactivated_at
  end
  
  # This will mark an organization as deactivated, which disables the account
  def deactivate
    self.deactivated_at = Time.now
    self.save!
  end  
    
  # Will increment the times_reported flag and notify the admin that the organization was reported
  #
  def report
    if !has_exceeded_reporting_threshold? then
      self.increment(:times_reported)
      self.save!
      Notifier.deliver_report_pending_organization(self)
    end
  end
  
  # If true, the user was reported while in the pending state, and will be prevented from logging in
  #
  def has_exceeded_reporting_threshold?
    pending? && times_reported > 0
  end
  
  # If true, the user's account has been disabled and will not be able to log in
  #
  def disabled?
    activation_window_has_expired? || has_exceeded_reporting_threshold? || deactivated?
  end

  # Will attempt to set the password for an uninitialized association member
  # If successful, the organization will now have login credentials
  # If unsuccessful, the organization will have errors
  def create_login(association, params = {})
  
    # Hack to ensure authentication will check the password in the chance that the user forgot to enter one
    if params[:password].blank? then
      params[:password] = "*"
      params[:password_confirmation] = params[:password]
    end
  
    # Attempt to set password
    if self.update_attributes(params) then
    
      self.uninitialized_association_member = false
      self.save!
      
      return true
      
    end  
      
    return false
    
  end
  
  # overriding the default constructor in order to autofill some attributes
  def initialize(params = nil) 
    super
    
    invitation = params[:invitation] if params
    
    if invitation then 
      # If the organization was built from an invitation, activate the account, 
      #  as we have already verified their email. Use the organization name and email from the invitation,
      #  unless they have overridden that information.
      self.activated_at = Time.now      
      self.name         = invitation.organization_name unless self[:name]
      self.email        = invitation.email             unless self[:email]
            
    else
      # If the organization was not built from an invitation, we need to verify the user's email (activation),
      #  as well as set them as pending so that we may review their account details.
      self.pending                = true
      self.activated_at              = nil
      self.activation_key            = KeyGen.random
      self.activation_key_created_at = Time.now
      
    end
    
    self.deactivation_key = KeyGen.random
        
  end  

  # Leaves the given association. If this org is uninitialized (eg. the user has not created their account), we simply
  # delete the organization. Otherwise, we remove the association affiliation.
  #
  def leave_association(association)
    return unless self.associations.include?(association)

    if self.uninitialized_association_member?
      destroy
    else
      self.associations.delete(association)
    end
  end

  # Whether an association can update this org's information
  def association_can_update?
    return self.uninitialized_association_member?
  end

  # Whether an association can just delete this org
  def association_can_delete?
    return self.uninitialized_association_member? && self.associations.count == 1
  end

  # See if the user entered a 10 digit zip code, and if so, just parse out the first 5 digits and call it a day.
  def zip_code=(value)
    if value.length == 10 && value.index("-") == 5 then
      super(value[0, 5])
    else
      super
    end
  end
  
  # Used to locate an organization's default association.
  # Currently defined as the first association.
  def association
    self.associations.first
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
  
  # If the organization is pending, it will notify the admins so that they may verify the account
  # 
  def send_pending_account_notification
    Notifier.deliver_pending_account_creation_notification(self) if self.pending?
  end
  
  # Sponsored surveys must be destroyed before their sponsor is destroyed.
  # 
  def remove_sponsored_surveys
    self.sponsored_surveys.each do |survey|
      survey.destroy
    end
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
