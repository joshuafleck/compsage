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
  
  after_create :set_parent, :send_notification
  
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
  
  #We are forced to send the notification from the model, rather than using an observer
  # for now, as observer callbacks take precedence over model callbacks and we need the discussion to be placed in
  # the nested set hierarchy before sending the notification. This looks like it will be fixed in the next rails version: 
  # see http://rails.lighthouseapp.com/projects/8994/tickets/230-fire-model-callbacks-before-notifying-observers
  # TODO: remove this and enable observer
  def send_notification
    sponsor = self.survey.sponsor
    
    # If the sponsor is replying to the discussion, notify the other
    #  organizations on the discussion chain of the event
    if self.responder == sponsor && self.level > 0 then
    
      # build the recipient list with a responders of that thread
      thread_members = []
      self.root.full_set.each do |sibling|
        thread_members << sibling.responder unless sibling.responder == sponsor || thread_members.include?(sibling.responder)
      end
    
      thread_members.each do |recipient|
        Notifier.deliver_discussion_thread_notification(
          self, 
          recipient
        ) 
      end
      
    # If an invitee is posting the discussion, notify the sponsor
    #  so that they can quickly respond
    elsif self.responder != sponsor
      Notifier.deliver_discussion_sponsor_notification(self)
    end  
  end
  
end
