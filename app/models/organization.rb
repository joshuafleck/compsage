require 'digest/sha1'

class Organization < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  define_index do
    indexes :name, :sortable => true
    
  end
  
  has_and_belongs_to_many :networks, :after_remove => :delete_empty_network
  has_many :owned_networks, :class_name => "Network", :foreign_key => "owner_id", :after_add => :join_created_network
  
  has_many :surveys, :foreign_key => "sponsor_id"
  has_many :participated_surveys, :class_name => "Survey", :through => :participations, :source => 'survey'
  #These are the surveys the user has sponsored or responded to
  has_many :my_surveys, :class_name => "Survey", :finder_sql => 'select surveys.* from surveys LEFT JOIN participations ON surveys.id = participations.survey_id WHERE sponsor_id=#{id} OR participant_id=#{id}'
  
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
      
    else    
      true
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

  protected
  
  # Destroy the network if it has zero members.
  def delete_empty_network(network)
    network.destroy if network.organizations.empty?
  end
  
  # Joins the network just created by this organization.
  def join_created_network(network)
    networks << network
  end
  
end
