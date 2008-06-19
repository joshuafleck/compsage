class Notifier < ActionMailer::Base
  
  # Sent when an in-network network invitation is sent
  def network_invitation_notification(invitation)
    
  end
  
  # sent when an external network invitation is sent
  def external_network_invitation_notification(invitation)
    
  end
  
  # sent when a global external invitation is sent
  def external_invitation_notification(invitation)
     recipients invitation.email
     from       "system@huminsight.com"
     subject    "You have been invited to <product name here>"
     
     part :content_type => "text/html",
        :body => render_message("external_invitation_notification.text.html.erb", 
          :invitation => invitation, 
          :signup_link => url_for( :host => "localhost:3000", :controller => 'accounts', :action => 'new', :key => invitation.key))

      part "text/plain" do |p|
        p.body = render_message("external_invitation_notification.text.plain.erb", 
          :invitation => invitation, 
          :signup_link => url_for( :host => "localhost:3000", :controller => 'accounts', :action => 'new', :key => invitation.key))
        p.transfer_encoding = "base64"
      end
      
  end
  
end
