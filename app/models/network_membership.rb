class NetworkMembership < ActiveRecord::Base
  belongs_to :network
  belongs_to :organization
end
