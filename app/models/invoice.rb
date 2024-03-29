class Invoice < ActiveRecord::Base
  include PhoneNumberFormatter
  format_phone_fields :phone

  belongs_to :survey
  
  validates_presence_of :survey
  validates_presence_of :organization_name
  validates_presence_of :contact_name
  validates_presence_of :address_line_1
  validates_presence_of :city
  validates_presence_of :state
  validates_presence_of :zip_code
  validates_presence_of :amount
  validates_presence_of :phone
  validates_presence_of :payment_type
  validates_presence_of :purchase_order_number, :if => proc { |invoice| !invoice.paying_with_credit_card? }

  validates_numericality_of :amount, :allow_blank => true
  validates_numericality_of :phone, :allow_blank => true
  validates_numericality_of :zip_code, :allow_blank => true
  validates_length_of :organization_name, :within => 2..100, :allow_blank => true
  validates_length_of :contact_name, :within => 2..100, :allow_blank => true
  validates_length_of :address_line_1, :within => 3..100, :allow_blank => true
  validates_length_of :city, :within => 2..100, :allow_blank => true
  validates_length_of :state, :is => 2, :allow_blank => true
  validates_length_of :address_line_2, :maximum => 100, :allow_blank => true
  validates_length_of :zip_code, :is => 5, :allow_blank => true
  validates_length_of :phone, :is => 10, :allow_blank => true
  validates_length_of :phone_extension,  :maximum => 6, :allow_blank => true
  
  # this is the means by which a customer will reference an invoice
  def invoice_number
    id + 1000
  end  
  
  # true, if the sponsor should be presented with the invoice at report-time
  def should_be_delivered?
    invoiced_at.blank? && !paying_with_credit_card?
  end
  
  # mark the invoice as delivered, so we know the sponsor has seen it
  def set_delivered
    self.invoiced_at = Time.now
    self.save!
  end
  
  # true, if the user is paying via credit card
  def paying_with_credit_card?
    payment_type == "credit"
  end
  
  # TODO credit should be the default payment type (it is currently 'invoice' while surveys are free)
  def payment_type
    self[:payment_type] || "invoice"
  end
  
  # the date at which the payment in full for the amount of the invoice is due
  def due_date
    self.survey.end_date + 30.days
  end
  
  # overriding the default constructor in order to autofill some attributes
  def initialize(*params) 
    super
    
    # TODO remove the setting of purchase order number, once we accept PO number in invoice form
    self.purchase_order_number = '12345'
    
    if(self[:survey_id]) then
      survey = Survey.find(self[:survey_id])
      previous_survey = survey.sponsor.sponsored_surveys.most_recent.first    
      previous_invoice = previous_survey.invoice if previous_survey
      if previous_invoice then # if there was an existing invoice from a previous survey, use that
        self.organization_name = previous_invoice.organization_name
        self.contact_name = previous_invoice.contact_name
        self.address_line_1 = previous_invoice.address_line_1
        self.address_line_2 = previous_invoice.address_line_2
        self.phone = previous_invoice.phone
        self.phone_extension = previous_invoice.phone_extension
        self.city = previous_invoice.city
        self.state = previous_invoice.state
        self.zip_code = previous_invoice.zip_code
      else # otherwise, use the sponsor's contact information
        self.organization_name = survey.sponsor.name
        self.contact_name = survey.sponsor.contact_name
        self.city = survey.sponsor.city
        self.state = survey.sponsor.state
        self.zip_code = survey.sponsor.zip_code
      end  
      self.amount = survey.price  
    end 
    
  end
  
  private
  
  ##
  # Strip the extra characters out of the phone number.    
  def strip_phone
    phone.gsub!(/\D/, '') unless phone.blank?
  end  

end
