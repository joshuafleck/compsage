class Discussion < ActiveRecord::Base

  belongs_to :survey
  belongs_to :organization
  belongs_to :external_survey_invitation
  #Information on the usage of the nested set can be found here: http://wiki.rubyonrails.org/rails/pages/BetterNestedSet
  acts_as_nested_set :scope => 'survey_id = #{survey_id}'
  
  validates_length_of :title, :allow_nil => true, :maximum => 128
  validates_length_of :body, :allow_nil => true, :maximum => 1024
  validates_presence_of :title, :if => Proc.new { |discussion| discussion.body.blank?}
  validates_presence_of :body, :if => Proc.new { |discussion| discussion.title.blank?}
  validates_presence_of :organization, :if => Proc.new { |discussion| discussion.external_survey_invitation.nil?}
  validates_presence_of :external_survey_invitation, :if => Proc.new { |discussion| discussion.organization.nil? }
  validates_presence_of :survey
  
end
