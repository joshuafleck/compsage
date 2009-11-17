class ExternalInvitation < Invitation
  include Authentication

  validates_presence_of :email
  validates_length_of   :email,    :within => 6..100 #r@a.wk
  validates_format_of   :email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD
  validates_presence_of :organization_name  
  validates_format_of   :organization_name,     :with => RE_NAME_OK,  :message => MSG_NAME_BAD
  validates_length_of   :organization_name,     :within => 3..100
  
  attr_accessible :email, :inviter, :organization_name
  
  before_create :create_key
  
  def to_s
    self.organization_name_and_email
  end
  
  def organization_name_and_email
    "#{self.organization_name} (#{self.email})"
  end

end
