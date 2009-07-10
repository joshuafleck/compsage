class Invoice < ActiveRecord::Base

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

  before_validation :strip_phone

  validates_format_of :zip_code, :with => /^\d{5}$/  
  validates_numericality_of :amount
  validates_length_of :organization_name, :within => 2..100
  validates_length_of :contact_name, :within => 2..100
  validates_length_of :address_line_1, :within => 3..100
  validates_length_of :city, :within => 2..100
  validates_length_of :state, :within => 2..100
  validates_length_of :address_line_2, :maximum => 100, :allow_nil => true
  validates_length_of :zip_code, :is => 5
  validates_length_of :phone, :is => 10
  validates_length_of :phone_extension,  :maximum => 6, :allow_nil => true
  
  CREDIT = "credit"
  
  # use the survey id as the base for the po number
  def purchase_order_number
    survey.id + 1000
  end
  
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
  
  def paying_with_credit_card?
    payment_type == CREDIT
  end
  
  # credit should be the default payment type
  def payment_type
    self[:payment_type] || CREDIT
  end
  
  private
  
  ##
  # Strip the extra characters out of the phone number.    
  def strip_phone
    phone.gsub!(/\D/, '') unless phone.blank?
  end  

end
