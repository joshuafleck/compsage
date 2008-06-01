class PendingAccountsController < ApplicationController

  layout 'front'

  def new
	  @page_title = "Signup"
	  
    @pending_account = PendingAccount.new
  end
  
  def create
	  @page_title = "Signup"
	  
    @pending_account = PendingAccount.new(params[:pending_account])
  
    if @pending_account.save then
      respond_to do |wants|
        wants.html {         
          flash[:notice] = "Your signup request was received."
          redirect_to '/' }      
        wants.xml do
          render :status => :created
        end
      end
    else
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
end
