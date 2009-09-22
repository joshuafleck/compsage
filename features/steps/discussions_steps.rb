And "the survey has a discussion topic" do
  @discussion = Factory(:discussion,
                        :subject => "Discussion topic!!", 
                        :survey => @survey, 
                        :responder => Factory(:organization))
end

And "I report abuse for a discussion" do
  @browser.startClicker("OK")
  click_link "discussion_#{@discussion.id}_abuse"
end

When "I click the discussion topic link" do
  click_link 'new_discussion_link'
end

When "I fill in the discussion topic" do
  wait_for_javascript
  fill_in 'discussion_subject', :with => 'Interesting topic'
  fill_in 'discussion_body', :with => 'Interesting subject matter. Free money!'
end

When "I submit a discussion" do
  click_button 'Post Discussion'
end

When "I click the reply link" do
  click_link "discussion_reply_#{@discussion.id}"
end

When "I fill in the reply" do
  wait_for_javascript
  fill_in "discussion_reply_#{@discussion.id}_body", :with => "Some reply text!!"
end

When "I submit a reply" do
  click_button 'Post'
end

Then "I should see the discussion topic" do
  wait_for_javascript
  response_body.should =~ /Interesting topic/
end

Then "I should see reply from survey sponsor" do
  wait_for_javascript
  response_body.should =~/Reply from the Survey Sponsor/
end

Then "I should see the reply text" do
  wait_for_javascript
  response_body.should =~ /Some reply text!!/
end

Then "I should see this discussion has been reported" do
  wait_for_javascript
  response_body.should =~ /The discussion was reported/
end

And "I should not see the discussion" do
  response_body.should_not =~ /@discussion.subject/
end