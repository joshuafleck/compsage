class Discussion < ActiveRecord::Base

  belongs_to :survey
  belongs_to :responder, :polymorphic => true
  
  #Information on the usage of the nested set can be found here: http://wiki.rubyonrails.org/rails/pages/BetterNestedSet
  acts_as_nested_set :scope => 'survey_id = #{survey_id}'
  
  validates_length_of :title, :allow_nil => true, :maximum => 128
  validates_length_of :body, :allow_nil => true, :maximum => 1024
  validates_presence_of :title, :if => Proc.new { |discussion| discussion.body.blank?}
  validates_presence_of :body, :if => Proc.new { |discussion| discussion.title.blank?}
  validates_presence_of :responder
  validates_presence_of :survey
  
  after_create :set_parent
  
  #This will sort the posts by creation date
  def <=>(o)
    return self.created_at <=> o.created_at
  end
  
  attr_accessor :parent_discussion_id
  
  def set_parent
    if new_record? && !parent_discussion_id.blank? then
      parent_discussion = Discussion.find(parent_discussion_id)
      self.move_to_child_of(parent_discussion)
    end    
  end
end
