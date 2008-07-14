class PredefinedQuestion < ActiveRecord::Base
  #position field included to leverage acts_as_list
  acts_as_list
  serialize :question_hash
  attr_accessor :included
end
