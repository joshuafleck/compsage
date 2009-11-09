class Association < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  
  has_and_belongs_to_many :organizations
  has_many :predefined_questions

  validates_presence_of   :name, :subdomain
  validates_uniqueness_of :name, :subdomain
  validates_length_of     :subdomain, :in => 3..20
  validates_format_of     :subdomain, :with => /^[A-Za-z0-9]*$/
  
  validates_presence_of     :owner_email
  validates_length_of       :owner_email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :owner_email,    :case_sensitive => false
  validates_format_of       :owner_email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD
  validates_length_of       :crypted_password, :maximum => 40, :allow_nil => :true
  validates_length_of       :salt, :maximum => 40, :allow_nil => :true
  
  attr_accessible :owner_email, :password, :password_confirmation, :name, :subdomain,
                  :logo

  # Authenticates an association by their login name and unencrypted password.  Returns the user or nil.
  #
  def self.authenticate(email, password)
    u = find_by_email(email) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
end
