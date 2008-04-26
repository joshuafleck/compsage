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
  
  named_scope :recently_created, :order => 'created_at DESC', :limit => 10
  named_scope :open, lambda { {:conditions => ['end_date < ?', Time.now]} }
  named_scope :closed, lambda { {:conditions => ['end_date >= ?', Time.now]} }
  named_scope :recently_ended, lambda { {:conditions => ['end_date >= ?', Time.now], :order => 'end_date DESC', :limit => 10} }
  
  def closed?
    Time.now > end_date
  end
  
  def open?
    !closed?
  end
end
