class InvitationObserver < ActiveRecord::Observer
  
  def after_save(invitation)
    # send emails
    if invitation.is_a?(ExternalNetworkInvitation)
      Notifier.deliver_external_network_invitation_notification(invitation)
    elsif invitation.is_a?(NetworkInvitation)
      Notifier.deliver_network_invitation_notification(invitation)
    elsif invitation.is_a?(ExternalInvitation)
      Notifier.deliver_external_invitation_notification(invitation)
    end
    
    # TODO: Survey Invitation stuff.
  end
  
end
