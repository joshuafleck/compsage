class InvitationObserver < ActiveRecord::Observer
  
  def after_create(invitation)
    # send emails
    case invitation.class
    when ExternalNetworkInvitation
      Notifier.deliver_external_network_invitation_notification(invitation)
    when NetworkInvitation
      Notifier.deliver_network_invitation_notification(invitation)
    when ExternalInvitation
      Notifier.deliver_external_invitation_notification(invitation)
    end
    
  end
  
end
