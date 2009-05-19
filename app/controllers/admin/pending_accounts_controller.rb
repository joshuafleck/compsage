class Admin::PendingAccountsController < Admin::AdminController
  def index
    @pending_accounts = PendingAccount.all
  end
  
  def approve
    
  end
  
  def deny
    
  end
end
