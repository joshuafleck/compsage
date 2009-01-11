class Discussion < ActiveRecord::Base

  belongs_to :survey
  belongs_to :responder, :polymorphic => true
  
  #Information on the usage of the nested set can be found here: http://wiki.rubyonrails.org/rails/pages/BetterNestedSet
  acts_as_nested_set :scope => 'survey_id = #{survey_id}'
  
  validates_length_of :subject, :allow_nil => true, :maximum => 128
  validates_length_of :body, :allow_nil => true, :maximum => 1024
  validates_presence_of :subject, :if => :is_topic?
  validates_presence_of :body, :if => :is_not_topic?
  validates_presence_of :responder
  validates_presence_of :survey
  
  after_create :set_parent
  
  named_scope :within_abuse_threshold, lambda { {:conditions => ['times_reported < 3']} }
  
  #This returns true if the discussion is under the abuse threshold
  def is_not_abuse
    times_reported < 3
  end
  
  #This virtual method allows us to set the parent discusion id in the case of a reply
  attr_accessor :parent_discussion_id
  
  #This will sort the posts by creation date
  def <=>(o)
    return self.created_at <=> o.created_at
  end
  
  protected
  
  def is_topic?
    self.parent_id.blank? && self.parent_discussion_id.blank?
  end
  
  def is_not_topic?
    !self.is_topic?
  end
  
  
  private
  
  #After the creation of a discussion, this will assign the discussion to its parent in the case of a reply
  def set_parent
    if !parent_discussion_id.blank? then
      parent_discussion = Discussion.find(parent_discussion_id)
      self.move_to_child_of parent_discussion
    end    
  end
    
end
