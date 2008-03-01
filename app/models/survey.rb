class Survey < ActiveRecord::Base
  belongs_to :sponsor, :foreign_key => "sponsor_id", :class_name => "Organization"
  has_and_belongs_to_many :organizations, :join_table => "organizations_surveys"
  has_many :discussions, :dependent => :destroy
  has_many :survey_invitations, :dependent => :destroy
  has_many :questions
  has_many :responses, :through => :questions
  
  validates_length_of :title, :maximum => 128, :message => "Title must be less then 128 characters"
  validates_presence_of :end_date, :on => :create, :message => "An end date must be specified."
end
