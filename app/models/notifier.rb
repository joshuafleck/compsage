class Notifier < ActionMailer::Base
  
  # Sent when an in-network network invitation is sent
  def network_invitation_notification(invitation)
    
  end
  
  # sent when an external network invitation is sent
  def external_network_invitation_notification(invitation)
    
  end
  
  # sent when a global external invitation is sent
  def external_invitation_notification(invitation)
     recipients invitation.email
     from       "system@huminsight.com"
     subject    "You have been invited to <product name here>"
     
     body :invitation => invitation    
  end
  
end
