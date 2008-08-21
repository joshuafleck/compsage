class SurveySubscription < ActiveRecord::Base
  belongs_to :survey
  belongs_to :organization
  
  validates_presence_of :survey, :organization, :relationship
end
