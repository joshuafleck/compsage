class PendingAccountsController < ApplicationController

  layout 'front'

  def new
    @pending_account = PendingAccount.new
  end
  
  def create
    @pending_account = PendingAccount.create!(params)
  
    respond_to do |wants|
      wants.html {         
        flash[:notice] = "Your signup request was received."
        redirect_to '/' }      
      wants.xml do
        render :status => :created
      end
    end
    rescue ActiveRecord::RecordInvalid
      respond_to do |wants|
        wants.html do
          render :action => 'new'
        end
        wants.xml do
          render :xml => @pending_account.errors.to_xml, :status => 422
        end
      end
	 end

end
