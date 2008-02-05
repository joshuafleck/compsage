class Survey < ActiveRecord::Base

  belongs_to :organization
  has_many :discussions
  has_many :survey_invitations
end
