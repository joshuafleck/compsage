class PendingAccountsController < ApplicationController
  layout 'front'

  def new
    @pending_account = PendingAccount.new
  end
  
  def received
  
  end
  
  def create
    @pending_account = PendingAccount.new(params[:pending_account])
  
    if @pending_account.save then
      render :action => 'received'
    else
      render :action => 'new'
    end
  end
end
