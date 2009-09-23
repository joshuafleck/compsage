class ContactFormSubmission
  include Validatable
  attr_accessor :name, :email, :phone, :phone_extension, :contact_preference, :message

  validates_presence_of :name, :message

  validates_presence_of   :email
  validates_format_of     :email, :with => Authentication::RE_EMAIL_OK, :message => Authentication::MSG_EMAIL_BAD,
    :if => Proc.new { |c| !c.email.blank? }

  def initialize(attributes = {})
    attributes ||= {}
    [:name, :email, :message, :phone, :phone_extension, :contact_preference].each do |attr|
      self.send("#{attr}=", attributes[attr])
    end

    @contact_preference ||= "email"
  end
end
