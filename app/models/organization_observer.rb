class OrganizationObserver < ActiveRecord::Observer
  
  def after_create(organization)
    
    Notifier.deliver_new_organization_notification(organization)
    
  end
  
end
