module NewOrganizationHelper

  # Will deliver the welcome email to the new organization as well as move
  #  any existing external invitations to this organization
  def send_email_and_move_invitations_to_new_organization(organization, current_invitation)
  
    Notifier.deliver_new_organization_notification(organization) 
         
    # Accept the current invitation       
    current_invitation.accept!(organization) if current_invitation
    
    # Locate any other invitations tied to this organization's email and move them over
    move_external_invitations_to_organization(organization)
    
  end
  
  # Locates any external invitations tied to this organization's email
  #  and moves the invitations to the organization.
  #  Note that this only works for activated organizations, otherwise
  #  anyone off the street could take someone else's survey data.
  def move_external_invitations_to_organization(organization)
      
    if organization.activated? then  
      invitations = ExternalInvitation.find_all_by_email(organization.email)
      invitations.each do |invitation|
        invitation.accept!(organization)
      end    
    end
  end
  
end
