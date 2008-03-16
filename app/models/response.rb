class Response < ActiveRecord::Base
  belongs_to :question
  belongs_to :organization
  belongs_to :external_survey_invitation
end
