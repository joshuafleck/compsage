class Association < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  
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
                  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  def self.authenticate(owner_email, password)
    u = find_by_owner_email(owner_email) # need to get the salt
    
    u && u.authenticated?(password) ? u : nil
  end

  # Creates a new organization that is a member of this association. If the organization already exists in the
  # database, we just add the org to the association and return the existing org.
  #
  def new_member(attributes = {})
    if !attributes[:email].blank? && member = Organization.find_by_email(attributes[:email])
      return member
    end

    member = organizations.new
    member.attributes = attributes
    member.associations << self
    member.is_uninitialized_association_member = true

    return member
  end

  # Removes this member from the organization. If the org can be deleted (if it's uninitalized and only belongs to one
  # association), go ahead and delete it, otherwise just remove the association link.
  #
  def remove_member(member)
    return unless self.organizations.include?(member)

    if member.association_can_delete? then
      member.destroy
    else
      member.associations.delete(self)
    end
  end
end
