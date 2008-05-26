class Notifier < ActionMailer::Base
  
  # Sent when an in-network network invitation is sent
  def network_invitation_notification(invitation)
    
  end
  
  # sent when an external network invitation is sent
  def external_network_invitation_notification(invitation)
    
  end
end
