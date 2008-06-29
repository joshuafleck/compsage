class Participation < ActiveRecord::Base
  belongs_to :participant, :polymorphic => true
  belongs_to :survey
  
  has_many :responses
end
