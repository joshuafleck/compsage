class Response < ActiveRecord::Base
  belongs_to :question
  belongs_to :organization
  belongs_to :external_survey_invitation
  
  validates_presence_of :question
  validates_presence_of :organization, :if => Proc.new { |response| response.external_survey_invitation.nil?}
  validates_presence_of :external_survey_invitation, :if => Proc.new { |response| response.organization.nil? }
  validates_presence_of :textual_response, :if => Proc.new { |response| response.numerical_response.blank?}
  validates_presence_of :numerical_response, :if => Proc.new { |response| response.textual_response.blank? }
  
end
