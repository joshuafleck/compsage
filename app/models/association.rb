class Association < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include PhoneNumberFormatter
  format_phone_fields :contact_phone
  
  has_attached_file :logo, :styles => {:normal => '512>'}, :default_style => :normal
 
  has_and_belongs_to_many :organizations
  has_many :predefined_questions
  has_many :surveys

  validates_presence_of   :name, :subdomain
  validates_uniqueness_of :name, :subdomain
  validates_length_of     :subdomain, :in => 3..20
  validates_format_of     :subdomain, :with => /^[A-Za-z0-9]*$/
  
  validates_presence_of     :contact_email
  validates_length_of       :contact_email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :contact_email,    :case_sensitive => false
  validates_format_of       :contact_email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD
  validates_length_of       :crypted_password, :maximum => 40, :allow_nil => :true
  validates_length_of       :salt, :maximum => 40, :allow_nil => :true
  
  validates_length_of       :contact_phone,  :is =>10, :allow_blank => true
 
  attr_accessible :contact_email, :password, :password_confirmation, :name, :subdomain, :member_greeting,
                  :contact_person, :contact_name, :contact_phone, :contact_phone_extension, :logo, :billing_instructions
                  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  def self.authenticate(contact_email, password)
    u = find_by_contact_email(contact_email) # need to get the salt
    
    u && u.authenticated?(password) ? u : nil
  end
  
   class MemberExists < RuntimeError; end

  # Creates a new organization that is a member of this association. If the organization already exists in the
  # database, we just add the org to the association and return the existing org.
  #
  def new_member(attributes = {})
    if !attributes[:email].blank? && member = Organization.find_by_email(attributes[:email])
      #check if the member is already part of the association
      if member.associations.include?(self) then
        raise MemberExists
      # not already a member, add them to the association.
      else
        member.associations << self
      end
      return member
    end

    member = organizations.new
    member.attributes = attributes
    member.associations << self
    member.uninitialized_association_member = true
    member.pending = false
    member.activated_at = Time.now

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
