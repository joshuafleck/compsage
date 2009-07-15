class BillingController < ApplicationController
  before_filter :login_required, :find_invoice
  layout 'logged_in'
  
  filter_parameter_logging :credit_card_number
  
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
    
    input_is_valid = @invoice.valid?
    
    #TODO: validate cc information via Gateway
    if @invoice.paying_with_credit_card? then 
      input_is_valid = @credit_card.valid? && input_is_valid # see if there are credit card errors
    end
    
    if input_is_valid && @invoice.save then
      @survey.billing_info_received!
      respond_to do |wants|
        wants.html do
          redirect_to survey_path(@survey)
        end
      end
    else
      respond_to do |wants|
        wants.html do
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
  
  def find_invoice
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    @invoice = Invoice.find_or_initialize_by_survey_id(@survey.id)
  end

end 
