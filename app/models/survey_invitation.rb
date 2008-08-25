class SurveyInvitation < Invitation

  belongs_to :survey
  
  validates_presence_of :invitee
  validates_presence_of :survey
  
  named_scope :running, :include => :survey, :conditions => ["surveys.end_date > ?", Time.now ]
  
end
