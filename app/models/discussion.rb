class Discussion < ActiveRecord::Base

  belongs_to :survey
  belongs_to :responder, :polymorphic => true
  
  #Information on the usage of the nested set can be found here: http://wiki.rubyonrails.org/rails/pages/BetterNestedSet
  acts_as_nested_set :scope => 'survey_id = #{survey_id}'
  
  validates_length_of :subject, :allow_nil => true, :maximum => 128
  validates_length_of :body, :allow_nil => true, :maximum => 1024
  validates_presence_of :subject, :if => Proc.new { |discussion| discussion.body.blank?}
  validates_presence_of :body, :if => Proc.new { |discussion| discussion.subject.blank?}
  validates_presence_of :responder
  validates_presence_of :survey
  
  after_save :set_parent
  
  #This virtual method allows us to set the parent discusion id in the case of a reply
  attr_accessor :parent_discussion_id
  
  #This will sort the posts by creation date
  def <=>(o)
    return self.created_at <=> o.created_at
  end
  
  #After the creation of a discussion, this will assign the discussion to its parent in the case of a reply
  def set_parent
    if !parent_discussion_id.blank? then
      parent_discussion = Discussion.find(parent_discussion_id)
      self.move_to_child_of parent_discussion
    end    
  end
end
