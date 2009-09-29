
When "I report a suspect result" do
  click_link "suspect_result_form_link"
  wait_for_javascript
  fill_in :comment, :with => "This data is not correct. I will not stand for it!!"
  click_button "suspect_result_submit"
end

Then "I should not see the suspect results form" do
  wait_for_javascript
  div('suspect_report_form').hidden?
end

And "the report has a wage response" do
  wage_question = Factory(:question,
                      :survey => @survey,
                      :response_type => "WageResponse", 
                      :text => "How much does a hammer make per year?")
  5.times do
    Factory(:wage_response,
            :question => wage_question,
            :participation => Factory(:participation, :survey => @survey),
            :response => '$45,000.00',
            :unit => "Annually")
  end
end

And "I change the report wage formatting" do
  click_link "wage_format_link"
  wait_for_javascript
end

Then "I should see the new wage format" do
  assert(get_element_by_xpath("//dl[@class='WageResponse']//dd").text == '$21.63')
end

And "the download link text should change" do
  assert(get_element_by_xpath("//a[@class='print_link']").href.to_s == 'http://localhost:3001' + survey_report_path(@survey, :format => "pdf", :wage_format => "Hourly").to_s)
end

And "I should not see the old wage format" do
  assert(get_element_by_xpath("//dl[@class='WageResponse hidden']//dd").text == '$45,000.00')
end

When /^I download the hourly "([^\"]*)" report$/ do |format|
  visit survey_report_url(@survey, :format => format, :wage_format => "Hourly")
end

