class PendingAccountsController < ApplicationController

  layout 'front'

  def new
    @pending_account = PendingAccount.new
  end
  
  def create
	  
    @pending_account = PendingAccount.new(params[:pending_account])
  
    if @pending_account.save then
      Notifier.deliver_pending_account_creation_notification
      respond_to do |wants|
        wants.html {         
          flash[:notice] = "Your signup request was received."
          redirect_to new_session_path }      
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
