class Discussion < ActiveRecord::Base

  belongs_to :survey
  belongs_to :organization
  #Information on the usage of the nested set can be found here: http://wiki.rubyonrails.org/rails/pages/BetterNestedSet
  acts_as_nested_set :scope => 'survey_id = #{survey_id}'
  
  validates_length_of :title, :maximum => 128, :message => "Title cannot exceed 128 characters"
  
end
