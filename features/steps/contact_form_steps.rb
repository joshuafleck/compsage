When "I fill in the contact form" do
  fills_in 'contact_form_submission_name', :with => "Brian Terlson"
  fills_in 'contact_form_submission_email', :with => "brian.terlson@gmail.com"
  fills_in 'contact_form_submission_message', :with => "My Message"

  click_button 'Send!'
end

When "I fill in the contact form incompletely" do
  fills_in 'contact_form_submission_name', :with => "Brian Terlson"
  fills_in 'contact_form_submission_email', :with => "brian.terlson@gmail.com"

  click_button 'Send!'
end
