class Discussion < ActiveRecord::Base

  belongs_to :survey
  belongs_to :organization
  belongs_to :discussion, :foreign_key => "parent"
  has_many :discussions
  
end
