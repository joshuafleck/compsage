class BillingController < ApplicationController
  before_filter :login_required, :find_or_initialize_invoice
  layout 'logged_in'
  
  # don't allow the credit card information to be logged
  filter_parameter_logging :active_merchant_billing_credit_card
  
  # viewing an invoice
  def show
  end
  
  # making a new invoice
  def new
    @credit_card = ActiveMerchant::Billing::CreditCard.new
  end
  
  # creates a new invoice, last step in the survey creation process
  def create
    @invoice.attributes = params[:invoice]
    @credit_card = ActiveMerchant::Billing::CreditCard.new(params[:active_merchant_billing_credit_card])

    respond_to do |wants| 
      wants.html do

        if (@credit_card.valid? || !@invoice.paying_with_credit_card?) && @invoice.save then        
          @survey.billing_info_received!               
          redirect_to survey_path(@survey)          
        else        
          render :action => :new                  
        end
        
      end      
    end
  end
  
  # marks the invoice as delivered, directs sponsor to the report
  def invoice
    if @invoice.should_be_delivered? then
      @invoice.set_delivered 
    end
    
    respond_to do |wants|
      wants.html do
        redirect_to survey_report_path(@survey)
      end
    end
  end 
  
  private
  
  # finds the survey and finds or initializes the invoice by survey id
  def find_or_initialize_invoice
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    @invoice = Invoice.find_or_initialize_by_survey_id(@survey.id)
  end

end 
