class BillingController < ApplicationController
  before_filter :login_required
  before_filter :find_survey
  before_filter :association_required, :only => [:instructions, :skip]
  before_filter :find_or_initialize_invoice, :except => [:instructions, :skip]
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
        if (!@invoice.paying_with_credit_card? || @credit_card.valid?) && @invoice.save then      
        
          @survey.billing_info_received!(current_association)

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
  
  # displays the billing instructions provided by the association
  def instructions
  
  end
  
  # bypasses billing for an association survey
  def skip  
    if @survey.pending? then
      # At this time, set the association to the users current association.
      @survey.association = current_association
      @survey.save
      @survey.association_billing_bypass
    end
    redirect_to survey_path(@survey)
  end
  
  private
  
  # finds or initializes the invoice by survey id
  def find_or_initialize_invoice
    @invoice = Invoice.find_or_initialize_by_survey_id(@survey.id)
  end
  
  # finds the survey
  def find_survey
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
  end  
  
end 
