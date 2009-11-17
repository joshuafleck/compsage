class Discussion < ActiveRecord::Base
  belongs_to :survey
  belongs_to :responder, :polymorphic => true
  
  # Information on the usage of the nested set can be found here:
  #   http://wiki.rubyonrails.org/rails/pages/BetterNestedSet
  acts_as_nested_set :scope => 'survey_id = #{survey_id}'
  
  validates_length_of :subject, :allow_nil => true, :maximum => 128
  validates_length_of :body, :allow_nil => true, :maximum => 1024
  validates_presence_of :subject, :if => :topic?
  validates_presence_of :body, :if => lambda { |d| !d.topic? }
  validates_presence_of :responder
  validates_presence_of :survey
  
  after_create :set_parent
  
  # The number of abuse reports before a dicussion will be suppressed
  ABUSE_THRESHOLD = 1
  
  named_scope :within_abuse_threshold, lambda { {:conditions => ["times_reported < #{ABUSE_THRESHOLD}"]} }
  named_scope :reported, lambda { {:conditions => ["times_reported >= #{ABUSE_THRESHOLD}"]} }
  
  # Allows us to set the parent discusion id when replying to another discussion. The relationship is set up after save
  # so we must store thie parent discussion id for then. This is also used to determine if the topic is a reply for
  # validation purposes.
  attr_accessor :parent_discussion_id

  # Whether the discussion is under the abuse threshold
  #
  def not_abuse?
    times_reported < ABUSE_THRESHOLD
  end
  
  # Sort posts by creation date
  #
  def <=>(o)
    return self.created_at <=> o.created_at
  end
  
  # Whether the discussion is a root level
  #
  def topic?
    self.parent_id.nil? && self.parent_discussion_id.nil?
  end
  
  # determines if the discussion is editable
  def visible_errors?(discussion_topic = nil)
    if discussion_topic.nil? then
      return self.errors.size > 0 && self.topic?
    else
      return self.errors.size > 0 && self.parent_discussion_id.to_s == discussion_topic.id.to_s
    end
  end
  
  private

  # After the creation of a discussion, this will assign the discussion to its parent in the case of a reply
  #
  def set_parent
    if !parent_discussion_id.blank? then
      parent_discussion = Discussion.find(parent_discussion_id)
      self.move_to_child_of parent_discussion
    end    
  end
    
end
