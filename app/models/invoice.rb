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
  
  def purchase_order_number
    survey.id + 1000
  end
  
  def invoice_number
    self[:id] + 1000
  end
  
  def sent?
    !self[:invoiced_at].blank? || paying_with_credit_card?
  end
  
  def paying_with_credit_card?
    payment_type == "credit"
  end
  
  private
  
  ##
  # Strip the extra characters out of the phone number.    
  def strip_phone
    phone.gsub!(/\D/, '') unless phone.blank?
  end  

end
