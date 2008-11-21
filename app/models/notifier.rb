class Notifier < ActionMailer::Base

  # sent when an external network invitation is sent
  def external_network_invitation_notification(invitation)
    recipients invitation.email
    from       "CompSage <do-not-reply@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "#{invitation.inviter.name} invited you to join CompSage"
    body       :invitation => invitation, :network => invitation.network
  end
  
  # sent when a global external invitation is sent
  def external_invitation_notification(invitation)
    recipients invitation.email
    from       "CompSage <do-not-reply@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "#{invitation.inviter.name} invited you to join CompSage"
    body       :invitation => invitation    
  end
    
  # sent when an external survey invitation is sent
  def external_survey_invitation_notification(invitation)
    recipients invitation.email
    from       "CompSage <do-not-reply@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "#{invitation.inviter.name} invited you to participate in the survey \"#{invitation.survey.job_title}\""
    body       :invitation => invitation, :survey => invitation.survey  
  end

  # Sent when a network invitation is sent
  def network_invitation_notification(invitation)
    recipients invitation.invitee.email
    from       "CompSage <do-not-reply@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "#{invitation.inviter.name} invited you to the network \"#{invitation.network.name}\""
    body       :invitation => invitation
  end
    
  # Sent when a survey invitation is sent
  def survey_invitation_notification(invitation)
    recipients invitation.invitee.email
    from       "CompSage <do-not-reply@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "#{invitation.inviter.name} invited you to participate in the survey \"#{invitation.survey.job_title}\""
    body       :invitation => invitation, :survey => invitation.survey
  end
  
  def survey_stalled_notification(survey)
    recipients survey.sponsor.email
    from       "CompSage <do-not-reply@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "Your survey \"#{survey.job_title}\" is stalled"
    body       :survey => survey
  end
  
  def survey_results_available_notification(survey, participant)
    recipients participant.email
    from       "CompSage <do-not-reply@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "Survey results are available for \"#{survey.job_title}\""
    body       :survey => survey, :participant => participant
  end
  
  #sent when a user requests a key for resetting their password
  def reset_password_key_notification(organization)
    recipients organization.email
    from       "CompSage <do-not-reply@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "You have requested a password reset"
    body       :organization => organization
  end
end
