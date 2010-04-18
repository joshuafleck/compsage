class Admin::PendingAccountsController < Admin::AdminController
  def index
    @pending_accounts = Organization.pending.all
  end
  
  def approve
    @pending_account = Organization.pending.find(params[:id])

    #update the account status to approved
    @pending_account.pending = false
    @pending_account.save!
    
    respond_to do |wants|
      wants.html {redirect_to admin_pending_accounts_path}
    end
  end
  
  def deny
    @pending_account = Organization.pending.find(params[:id])
    #notify the user that they were rejected
    @pending_account.destroy
    
    respond_to do |wants|
      wants.html {redirect_to admin_pending_accounts_path}
    end
  end
end
