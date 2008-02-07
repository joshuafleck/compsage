class Survey < ActiveRecord::Base
  belongs_to :sponsor, :class_name => "Organization"
  has_many_and_belongs_to_many :organizations, :join_table => "organizations_surveys"
  has_many :discussions, :dependent => :destroy
  has_many :survey_invitations, :dependent => :destroy
end
