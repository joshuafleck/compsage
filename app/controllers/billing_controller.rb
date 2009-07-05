class BillingController < ApplicationController
	before_filter :login_required, :find_invoice
	layout 'logged_in'
	
	filter_parameter_logging :credit_card_number
	
	def show
	end
	
	def new
	  
	  # see if we can auto fill some fields based on existing information
  	invoice_params = {}
  	
	  @previous_survey = @current_organization.sponsored_surveys.find :first, :order => 'end_date DESC', :conditions => 'end_date IS NOT NULL'
	  
	  @previous_invoice = Invoice.find_by_survey_id(@previous_survey.id) if @previous_survey
	  if @previous_invoice then
	    invoice_params[:organization_name] = @previous_invoice.organization_name
	    invoice_params[:contact_name] = @previous_invoice.contact_name
	    invoice_params[:address_line_1] = @previous_invoice.address_line_1
	    invoice_params[:address_line_2] = @previous_invoice.address_line_2
	    invoice_params[:phone] = @previous_invoice.phone
	    invoice_params[:phone_extension] = @previous_invoice.phone_extension
	    invoice_params[:city] = @previous_invoice.city
	    invoice_params[:state] = @previous_invoice.state
	    invoice_params[:zip_code] = @previous_invoice.zip_code
	  else
	    invoice_params[:organization_name] = current_organization.name
	    invoice_params[:contact_name] = current_organization.contact_name
	    invoice_params[:city] = current_organization.city
	    invoice_params[:state] = current_organization.state
	    invoice_params[:zip_code] = current_organization.zip_code
	  end
	  
	  @invoice.attributes = invoice_params
	end
	
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
	
	def invoice
	  if !@invoice.sent? then
  	  @invoice.invoiced_at = Time.now
  	  @invoice.save!	  
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
