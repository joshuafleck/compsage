class DiscussionObserver < ActiveRecord::Observer
  
  def after_create(discussion)
    
    sponsor = discussion.survey.sponsor
    responder = discussion.responder
    
    # If the sponsor is replying to the discussion, notify the other
    #  organizations on the discussion chain of the event
    if responder == sponsor && discussion.level > 0 then
    
      # build the recipient list with a responders of that thread
      thread_members = []
      discussion.root.full_set.each do |sibling|
        thread_members << sibling.responder unless sibling.responder == sponsor || thread_members.include?(sibling.responder)
      end
    
      thread_members.each do |recipient|
        Notifier.deliver_discussion_thread_notification(
          discussion, 
          recipient
        ) 
      end
      
    # If an invitee is posting the discussion, notify the sponsor
    #  so that they can quickly respond
    elsif responder != sponsor
      Notifier.deliver_discussion_sponsor_notification(discussion)
    end
    
  end
  
end
