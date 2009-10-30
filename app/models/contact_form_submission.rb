class ContactFormSubmission
  include Validatable
  attr_accessor :name, :email, :phone, :phone_extension, :contact_preference, :message, :stripped_phone

  validates_presence_of :name, :message

  validates_presence_of   :email, :if => Proc.new { |c| c.contact_preference == 'email' }
  validates_format_of     :email, :with => Authentication::RE_EMAIL_OK, :message => Authentication::MSG_EMAIL_BAD,
    :if => Proc.new { |c| !c.email.blank? }

  validates_presence_of   :phone, :if => Proc.new { |c| c.contact_preference == 'phone' }
  # This validation is in the category of 'good enough'. It will accept any format so long as it includes 10 numbers
  # with no more than two non-numeric characters in between the numbers. The phone number is allowed to be blank.
  validates_format_of     :phone, :with => /^([^\d]?\d[^\d]?){10}$/, :if => Proc.new { |c| !c.phone.blank? }, 
                          :message => "doesn't appear valid. Be sure to include your area code."

  def initialize(attributes = {})
    attributes ||= {}
    [:name, :email, :message, :phone, :phone_extension, :contact_preference].each do |attr|
      self.send("#{attr}=", attributes[attr])
    end

    @contact_preference ||= "email"
  end
end
