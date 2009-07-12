class BillingController < ApplicationController
	before_filter :login_required, :find_invoice
	layout 'logged_in'
	
	filter_parameter_logging :credit_card_number
	
	# viewing an invoice
	def show
	end
	
	# making a new invoice
	def new

	end
	
	# creates a new invoice, last step in the survey creation process
	def create
	  @invoice.attributes = params[:invoice]
	  @invoice.amount = @survey.price
	  
	  #TODO: validate cc information via Gateway
	  if @invoice.paying_with_credit_card? then
	    credit_card_number = params[:credit_card_number]
	    expiration_month = params[:expiration_month]
	    expiration_year = params[:expiration_year]
	  end
	  
	  if @invoice.save then
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
        redirect_to survey_report_path(@survey, :format => :html)
      end
    end
	end	
	
  private
  
  def find_invoice
    @survey = current_organization.sponsored_surveys.find(params[:survey_id])
    @invoice = Invoice.find_or_initialize_by_survey_id(@survey.id)
  end

end	
