class Discussion < ActiveRecord::Base

  belongs_to :survey
  belongs_to :organization
  acts_as_nested_set
  
end
