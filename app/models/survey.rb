class Survey < ActiveRecord::Base
  belongs_to :sponsor, :class_name => "Organization"
  has_many :discussions, :dependent => :destroy
  has_many :survey_invitations, :dependent => :destroy
  has_many :external_survey_invitations, :dependent => :destroy
  has_many :questions
  has_many :responses, :through => :questions
  
  validates_presence_of :job_title
  validates_length_of :job_title, :maximum => 128
  validates_presence_of :end_date, :on => :create
  validates_presence_of :sponsor
  
  def closed?
    Time.now > end_date
  end
  
  def open?
    !closed?
  end
end
