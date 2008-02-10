class Response < ActiveRecord::Base
  belongs_to :question
  belongs_to :organization
end
