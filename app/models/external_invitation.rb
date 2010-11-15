class ExternalInvitation < Invitation
  include Authentication

  validates_presence_of :email
  validates_length_of   :email,    :within => 6..100, :allow_blank => true #r@a.wk
  validates_format_of   :email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD, :allow_blank => true
  validates_presence_of :organization_name  
  validates_format_of   :organization_name,     :with => RE_NAME_OK,  :message => MSG_NAME_BAD, :allow_blank => true
  validates_length_of   :organization_name,     :within => 3..100, :allow_blank => true
  
  validate_on_create    :not_opted_out
  attr_accessible :email, :inviter, :organization_name
  
  before_create :create_key
  
  def to_s
    self.organization_name_and_email
  end
  
  def organization_name_and_email
    "#{self.organization_name} (#{self.email})"
  end

  private

  # Checks to make sure this email address hasn't opted out from our communications.
  def not_opted_out
    if !OptOut.find_by_email(self.email).nil?
      errors.add_to_base "We cannot send this invitation because #{self.email} has opted out of receiving email from CompSage."
    end
  end

end
