module NewOrganizationHelper

  # Will deliver the welcome email to the new organization as well as move
  #  any existing external invitations to this organization
  def send_email_and_move_invitations_to_new_organization(organization, current_invitation)
  
    Notifier.deliver_new_organization_notification(organization) 
    
    # If there is not a current invitation, do not attempt to move the external survey invitations
    #  this will be done upon activation        
    if current_invitation then
      current_invitation.accept!(organization)
      move_external_invitations_to_organization(organization)
    end
    
  end
  
  # Locates any external invitations tied to this organizations email
  # Note that this should only be called for non-activated organizations, otherwise
  #  anyone off the street could take someone else's survey data
  def move_external_invitations_to_organization(organization)
      
    if organization.activated? then  
      invitations = ExternalInvitation.find_all_by_email(organization.email)
      invitations.each do |invitation|
        invitation.accept!(organization)
      end    
    end
  end
  
end
