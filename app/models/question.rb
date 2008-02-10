class Question < ActiveRecord::Base
  belongs_to :survey
  has_many :responses, :dependent => :delete_all
  
  acts_as_list :scope => :survey_id
  
  serialize :options
end
