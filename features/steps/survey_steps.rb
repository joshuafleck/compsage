Given "I am on the survey response page" do
  goto(survey_questions_url(@survey))
end

Given /^I am sponsoring a running survey with a (.*) question/ do |type|
  @question = Factory.build((type.gsub(" ", "_") + "_question").intern)
  @survey = Factory(:survey,
                    :aasm_state => 'running',
                    :sponsor => @current_organization,
                    :questions => [
                      @question
                    ])
end


When /^I enter "([^"]*)"$/ do |text|
  @browser.text_field(:name, "participation[response][#{@question.id}][response]").set("") # Clear first
  @browser.text_field(:name, "participation[response][#{@question.id}][response]").set(text)
end

Then /^it should read "([^"]*)"$/ do |text|
  @browser.text_field(:name, "participation[response][#{@question.id}][response]").value.should == text
end

When /^I choose the (hourly|annual) pay type$/ do |type|
  type = type == "annual" ? "Annually" : "Hourly"
  @browser.select_list(:name, "participation[response][#{@question.id}][unit]").select(type)
end

Then "I should see a response warning" do
  @browser.div(:id, "warning_#{@question.id}").text.should_not be_blank
end

Then "I should not see a response warning" do
  @browser.div(:id, "warning_#{@question.id}").text.should be_blank
end
