class PendingAccount < ActiveRecord::Base
  include PhoneNumberFormatter
  format_phone_fields :phone
  
  before_create :create_key
  after_save :send_account_creation_email
  
  validates_presence_of :email
  validates_length_of   :email, :within => 6..100
  validates_format_of   :email, :with => Authentication::RE_EMAIL_OK, :message => Authentication::MSG_EMAIL_BAD

  validates_presence_of :organization_name
  validates_length_of   :organization_name,  :within => 3..100
  validates_presence_of :contact_first_name
  validates_length_of   :contact_first_name,  :within => 2..100
  validates_presence_of :contact_last_name
  validates_length_of   :contact_last_name,  :within => 2..100
  validates_presence_of :phone
  validates_length_of   :phone,  :is =>10
  validates_length_of   :phone_extension,  :maximum =>6, :allow_nil => true
  
  attr_accessible :email, :organization_name, :contact_first_name, :contact_last_name, :phone, :phone_extension, :approved
  
  state_machine :approved, :initial => :pending do
    after_transition :pending => :approved, :do => :send_account_approval_email

    event :approve do
      transition :pending => :approved
    end

    state :pending, :value => false
    state :approved, :value => true
  end

  private

  def create_key
    self.key = KeyGen.random
  end

  def send_account_creation_email
    Notifier.deliver_pending_account_creation_notification
  end

  def send_account_approval_email
    Notifier.deliver_pending_account_approval_notification(self)
  end
end
