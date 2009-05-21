class Admin::PendingAccountsController < Admin::AdminController
  def index
    @pending_accounts = PendingAccount.all
  end
  
  def approve
    @pending_account = PendingAccount.find(params[:id])
    #email the user an official invitation
    Notifier.deliver_pending_account_approval_notification(@pending_account)
    #update the account status to approved
    @pending_account.approve
    
    respond_to do |wants|
      wants.html {redirect_to admin_pending_accounts_path}
    end
  end
  
  def deny
    @pending_account = PendingAccount.find(params[:id])
    #notify the user that they were rejected
    @pending_account.destroy
    
    respond_to do |wants|
      wants.html {redirect_to admin_pending_accounts_path}
    end
  end
end
