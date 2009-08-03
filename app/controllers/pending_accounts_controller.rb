class PendingAccountsController < ApplicationController
  layout 'front'

  def new
    @pending_account = PendingAccount.new
  end
  
  def create
    @pending_account = PendingAccount.new(params[:pending_account])
  
    if @pending_account.save then
      flash[:notice] = "We have received your signup request. We will call you soon to verify your request and give" \
        " you further instruction."

      redirect_to new_session_path
    else
      render :action => 'new'
    end
  end
end
