require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Invoice do

  before(:each) do
    @invoice = Factory.build(:invoice)
  end  

  it "should be valid" do
    @invoice.should be_valid
  end
   
  it "should belong to a survey" do
    Invoice.reflect_on_association(:survey).should_not be_nil
  end
   
  it "should be invalid without a survey" do
    @invoice.survey = nil
    @invoice.should have(1).errors_on(:survey)
  end  
   
  it "should be invalid without an organization name" do
    @invoice.organization_name = nil
    @invoice.should have(2).errors_on(:organization_name)
  end  
    
  it "should be invalid without an address" do
    @invoice.address_line_1 = nil
    @invoice.should have(2).errors_on(:address_line_1)
  end  
      
  it "should be invalid without a city" do
    @invoice.city = nil
    @invoice.should have(2).errors_on(:city)
  end  
       
  it "should be invalid without a state" do
    @invoice.state = nil
    @invoice.should have(2).errors_on(:state)
  end  
        
  it "should be invalid without a zip code" do
    @invoice.zip_code = nil
    @invoice.should have(3).errors_on(:zip_code)
  end  
         
  it "should be invalid without an amount" do
    @invoice.amount = nil
    @invoice.should have(2).errors_on(:amount)
  end  
           
  it "should be invalid without a phone number" do
    @invoice.phone = nil
    @invoice.should have(3).errors_on(:phone)
  end  
             
  it "should have a default payment type" do
    @invoice.payment_type = nil
    @invoice.payment_type.should_not be_blank
  end  
              
  it "should be invalid without a purchase order number, if the user is not paying with a credit card" do
    @invoice.purchase_order_number = nil
    @invoice.payment_type = "invoice"
    @invoice.should have(1).errors_on(:purchase_order_number)
    @invoice.payment_type = "credit"
    @invoice.should have(0).errors_on(:purchase_order_number)
  end  
              
  it "should cleanse the phone number" do
    @invoice.phone = '(952) 393-1749'
    @invoice.save
    @invoice.phone.should eql('9523931749')
    @invoice.destroy
  end  
  
  it "should be invalid without a 5-digit zip code" do
    @invoice.zip_code = 'zzzzzz'
    @invoice.should have(2).errors_on(:zip_code)
  end 
  
  it "should be invalid if the organization name is shorter than 2 characters or longer than 100 characters" do
    @invoice.organization_name = 'z'
    @invoice.should have(1).errors_on(:organization_name)
    @invoice.organization_name = 'z'*101
    @invoice.should have(1).errors_on(:organization_name)
  end      

  it "should be invalid if the contact name is shorter than 2 characters or longer than 100 characters" do
    @invoice.contact_name = 'z'
    @invoice.should have(1).errors_on(:contact_name)
    @invoice.contact_name = 'z'*101
    @invoice.should have(1).errors_on(:contact_name)
  end  
  
  it "should be invalid if the address is shorter than 3 characters or longer than 100 characters" do
    @invoice.address_line_1 = 'zz'
    @invoice.should have(1).errors_on(:address_line_1)
    @invoice.address_line_1 = 'z'*101
    @invoice.should have(1).errors_on(:address_line_1)
    @invoice.address_line_2 = 'z'*101
    @invoice.should have(1).errors_on(:address_line_2)
  end  
 
  it "should be invalid if the city is shorter than 2 characters or longer than 100 characters" do
    @invoice.city = 'z'
    @invoice.should have(1).errors_on(:city)
    @invoice.city = 'z'*101
    @invoice.should have(1).errors_on(:city)
  end  
  
  it "should be invalid if the state is not 2 characters" do
    @invoice.state = 'z'
    @invoice.should have(1).errors_on(:state)
    @invoice.state = 'zzz'
    @invoice.should have(1).errors_on(:state)
  end  
  
  it "should be invalid if the phone number is not 10 numbers" do
    @invoice.phone = '9'*9
    @invoice.should have(1).errors_on(:phone)
    @invoice.phone = '9'*11
    @invoice.should have(1).errors_on(:phone)
    @invoice.phone = 'z'*10
    @invoice.should have(3).errors_on(:phone)
  end  
   
  it "should be invalid if the phone extension exceeds 6 characters" do
    @invoice.phone_extension = 'z'*7
    @invoice.should have(1).errors_on(:phone_extension)
  end  
     
  it "should be marked as a credit payment when the user pays with a credit card" do
    @invoice.payment_type = "credit"
    @invoice.paying_with_credit_card?.should be_true
  end  
      
  it "should not be marked for delivery when the user pays with a credit card" do
    @invoice.payment_type = "credit"
    @invoice.should_be_delivered?.should be_false
  end  
       
  it "should be marked for delivery when the user pays via invoice" do
    @invoice.payment_type = "invoice"
    @invoice.should_be_delivered?.should be_true
  end  
        
  it "should not be marked for delivery when the user pays via invoice and the invoice has been delivered" do
    @invoice.payment_type = "invoice"
    @invoice.set_delivered
    @invoice.should_be_delivered?.should be_false
    @invoice.destroy
  end  
       
  it "should have an invoice number" do
    @invoice.save
    @invoice.invoice_number.should_not be_blank
    @invoice.destroy
  end 
  
  it "should have a due date" do
    @invoice.save
    @invoice.survey.end_date = Time.now
    @invoice.due_date.should_not be_blank
    @invoice.destroy
  end     
                                 
end

describe Invoice, "built from a previous survey" do
  before(:each) do
    @organization = Factory.create(:organization)
    @previous_invoice = Factory.build(:invoice, :survey => nil)
    @previous_survey = Factory.create(:survey, :sponsor => @organization, :invoice => @previous_invoice, :end_date => Time.now)
    @current_survey = Factory.create(:survey, :sponsor => @organization)
    @invoice = Invoice.new(:survey_id => @current_survey.id, :payment_type => "credit")
  end
  
  after(:each) do
    @previous_invoice.destroy
    @previous_survey.destroy
    @current_survey.destroy
    @organization.destroy
  end
  
  it "should be valid" do
    @invoice.should be_valid
  end   

end

describe Invoice, "built from the sponsors' attributes" do
  before(:each) do
    @organization = Factory.create(:organization)
    @current_survey = Factory.create(:survey, :sponsor => @organization)
    @invoice = Invoice.new(:survey_id => @current_survey.id, :payment_type => "credit")
  end
  
  after(:each) do
    @current_survey.destroy
    @organization.destroy
  end
  
  it "should have the attributes from the survey sponsor" do
    @invoice.organization_name.should_not be_blank
    @invoice.contact_name.should_not be_blank
    @invoice.city.should_not be_blank
    @invoice.state.should_not be_blank
    @invoice.zip_code.should_not be_blank
  end 
  
  it "should have a price" do
    @invoice.amount.should_not be_blank
  end   
end
