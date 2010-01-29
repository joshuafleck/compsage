class Notifier < ActionMailer::Base
  helper :application

  # sent when an external network invitation is sent
  def external_network_invitation_notification(invitation)
    recipients invitation.email
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "#{invitation.inviter.name} invited you to join CompSage"
    body       :invitation => invitation, :network => invitation.network
  end
    
  # sent when an external survey invitation is sent
  def external_survey_invitation_notification(invitation)
    recipients invitation.email
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "#{invitation.inviter.name} invited you to participate in the survey \"#{invitation.survey.job_title}\""
    body       :invitation => invitation, :survey => invitation.survey  
  end

  # Sent when a network invitation is sent
  def network_invitation_notification(invitation)
    recipients invitation.invitee.email
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "#{invitation.inviter.name} invited you to the network \"#{invitation.network.name}\""
    body       :invitation => invitation
  end
    
  # Sent when a survey invitation is sent
  def survey_invitation_notification(invitation)
    recipients invitation.invitee.email
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "#{invitation.inviter.name} invited you to participate in the survey \"#{invitation.survey.job_title}\""
    body       :invitation => invitation, :survey => invitation.survey
  end
  
  def survey_stalled_notification(survey)
    recipients survey.sponsor.email
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "Your survey \"#{survey.job_title}\" is stalled"
    body       :survey => survey
  end
  
  def survey_results_available_notification(survey, participant)
    recipients participant.email
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "Survey results are available for \"#{survey.job_title}\""
    body       :survey => survey, :participant => participant
  end
  
  #sent when a user requests a key for resetting their password
  def reset_password_key_notification(organization)
    recipients organization.email
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "You have requested a password reset"
    body       :organization => organization
  end
  
  #sent when a user requests a key for resetting their password
  def association_member_initialization_notification(organization,association)
    recipients organization.email
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "CompSage.com account initialization"
    body       :organization => organization, :association => association
  end  
  
  #sent when a survey sponsor posts a new discussion
  def discussion_thread_notification(discussion, recipient)
    recipients recipient.email
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "#{discussion.survey.sponsor.name} has responded to \"#{discussion.root.subject}\""
    body       :discussion => discussion, :recipient => recipient
  end  
  
  #sent when a survey invitee posts a new discussion
  def discussion_sponsor_notification(discussion)
    recipients discussion.survey.sponsor.email
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "Clarification posted for \"#{discussion.survey.job_title}\""
    body       :discussion => discussion
  end  
  
  def survey_rerun_notification_participant(survey,recipient)
    recipients recipient.email
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "The response deadline has been extended for the survey \"#{survey.job_title}\""
    body       :survey => survey, :recipient => recipient
  end
  
  def survey_rerun_notification_non_participant(survey,recipient)
    recipients recipient.email
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "The response deadline has been extended for the survey \"#{survey.job_title}\""
    body       :survey => survey, :recipient => recipient
  end  
  
  def survey_not_rerunning_notification(survey,recipient)
    recipients recipient.email
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "The survey \"#{survey.job_title}\" did not receive enough responses"
    body       :survey => survey
  end
  
  def invoice(survey)
    recipients survey.sponsor.email
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "Invoice for \"#{survey.job_title}\""
    body       :survey => survey, :invoice => survey.invoice
  end    
  
  def new_organization_notification(organization)
    recipients organization.email
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "Your compsage.com account has been created"
    body       :organization => organization
  end
  
  def report_suspect_results_notification(survey, comment)
    recipients "CompSage <support@compsage.com>"
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "Suspect Results reported for survey #{survey.id.to_s}"
    body       :survey => survey, :comment => comment
  end

  def pending_account_creation_notification(organization)
    recipients "CompSage <support@compsage.com>"
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "A new account requiring manual verification was created" 
    body       :organization => organization   
  end
    
  def contact_form_submission(submission)
    recipients "CompSage <support@compsage.com>"
    from       "CompSage <support@compsage.com>"
    reply_to   submission.email
    subject    "Contact Form Submission"    
    body       :submission => submission
  end
  
  def report_pending_organization(organization)
    recipients "CompSage <support@compsage.com>"
    from       "CompSage <support@compsage.com>"
    reply_to   "support@compsage.com"
    subject    "Suspicious activity was reported for a pending account" 
    body       :organization => organization  
  end
end
