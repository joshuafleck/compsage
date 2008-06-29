require 'digest/sha1'
class Organization < ActiveRecord::Base

	is_indexed :fields => [:name]

  has_and_belongs_to_many :networks, :after_remove => :delete_empty_network
  has_many :owned_networks, :class_name => "Network", :foreign_key => "owner_id", :after_add => :join_created_network
  
  has_many :surveys, :foreign_key => "sponsor_id"
  has_many :participated_surveys, :class_name => "Survey", :through => :participations, :source => 'survey'
  
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
  
  has_one :logo
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :email
  validates_format_of       :email,  :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email"  
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 5..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :email,    :within => 5..100
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_presence_of     :name
  validates_length_of       :name,     :within => 3..100
  validates_presence_of     :zip_code
  validates_length_of       :zip_code, :is => 5
  validates_length_of       :location, :maximum => 60, :allow_nil => :true
  validates_length_of       :industry, :maximum => 100, :allow_nil => :true
  validates_length_of       :contact_name, :maximum => 100, :allow_nil => :true
  validates_length_of       :city, :maximum => 50, :allow_nil => :true
  validates_length_of       :state, :maximum => 30, :allow_nil => :true
  validates_length_of       :crypted_password, :maximum => 40, :allow_nil => :true
  validates_length_of       :salt, :maximum => 40, :allow_nil => :true
  
  before_save :encrypt_password
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :email, :password, :password_confirmation, :name, :location, :city, :state, :zip_code, :contact_name, :industry
  
  #Sets the organizations logo, replaces any existing logo
  def set_logo(logo_params)
  
    if !logo_params[:uploaded_data].blank? then
    
      if self.logo then
        self.logo.destroy
      end
      
      self.logo = Logo.new(logo_params)
      self.logo.organization = self
      self.logo.save!
    end
  end
  
  # Authenticates a user by their email address and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    u = find_by_email(email) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    # Destroy the network if it has zero members.
    def delete_empty_network(network)
      network.destroy if network.organizations.empty?
    end
    
    # Joins the network just created by this organization.
    def join_created_network(network)
      networks << network
    end
end
