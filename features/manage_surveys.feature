Feature: Manage surveys
  
  Scenario: Create new survey
    Given I am logged in
    And there is a predefined question
    And I am on the new survey page
    When I fill in "Job title" with "Hard Worker"
    When I fill in "Job description" with "Works Hard"
    And I select "3 days" from "Run length"
    And I check "Question 1"
    And I fill in "Question Text" with "Custom question 1"
    #And I press "Add Question"
    And I press "Create Survey"
    Then I should see "Survey Preview"
    When I follow "Continue"
    Then I should see "Invitations to Hard Worker"
    When I follow "Respond Now"
    Then I should see "Responding to Hard Worker"
    And I should see "Question 1 text"
    #And I should see "Custom question 1"
    
  Scenario: Create new survey with failure
    Given I am logged in
    And there is a predefined question
    And I am on the new survey page
    And I press "Create Survey"
    Then I should see "Job title can't be blank"
    And I should see "You must choose at least one question to ask"
    When I fill in "Job title" with "Hard Worker"
    And I check "Question 1"
    And I press "Create Survey"
    When I follow "Continue"
    When I follow "Respond Now"
    Then I should see "Responding to Hard Worker"
    And I should see "Question 1 text"  
    
  Scenario: Edit a survey
    Given I am logged in
    And there is a survey
    And I am the sponsor
    And I am on the edit survey page
    When I fill in "Job title" with "Hard Worker"
    And I check "Predefined Question unselected"
    And I uncheck "Predefined Question selected"
    And I uncheck "Custom Question 2 text"
    And I press "Update"   
    When I follow "Continue"
    When I follow "Respond Now"
    Then I should see "Predefined Question unselected text"
    And I should see "Custom Question 1 text"
    And I should not see "Predefined Question selected text"
    And I should not see "Custom Question 2 text"
    
  Scenario: Manage Invitations
    Given I am logged in
    And there is a survey
    And I am the sponsor
    And I own networks
    And I am on the survey invitations page
    And I check "Network 1"
    And I press "Send Invitations"
    Then I should see "Organization 1"
    And I should see "Organization 2"
    And I should not see "Organization 3"
    
  Scenario: Manage Discussions
    Given I am logged in
    And there is a survey
    And I am on the survey show page
    When I fill in "Subject" with "Discussion Subject"
    And I fill in "Body" with "Discussion Body"
    And I press "Post"
    Then I should see "Discussion Subject"
    And I should see "Discussion Body"
    
  Scenario: Manage Discussions As Invitee
    Given there is a survey
    And I am externally invited to the survey
    And I am on the survey show page
    When I fill in "Subject" with "Discussion Subject"
    And I fill in "Body" with "Discussion Body"
    And I press "Post"
    Then I should see "Discussion Subject"
    And I should see "Discussion Body"    
    
  Scenario: Respond to survey
    Given I am logged in
    And there is a survey
    And I am on the survey respond page
    When I fill in "Question 1" with "1"
    And I press "Submit My Responses"
    Then I should see "Thank you for participating in the survey!"
    And I should see "Participants: 1"
    When I follow "Surveys &amp; Results"
    Then I should not see "Decline"
    
  Scenario: Edit survey response
    Given I am logged in
    And there is a survey
    And I have responded to the survey
    And I am on the survey respond page
    Then I should see "1.4"
    When I fill in "Question 1" with "1"
    And I press "Submit My Responses"
    And I am on the survey respond page
    Then I should see "1.0"
    
  Scenario: Rerun survey
    Given I am logged in
    And there is a survey
    And I am the sponsor
    And the survey is stalled
    And I am on the survey show page
    When I press "Re-Run"
    Then I should see "Survey updated"
  
  Scenario: Not rerun survey
    Given I am logged in
    And there is a survey
    And I am the sponsor
    And the survey is stalled
    And I am on the survey show page
    When I follow "here"
    Then I should see "You currently don't have any survey results."  
    
  Scenario: Search for survey by title
    Given I am logged in
    And there is a survey
    And I am on the survey index page
    When I fill in "search_text" with "Survey 1"
    And I press the button with id "submit"
    Then I should see "Survey 1"
    
  Scenario: Finish stalled survey
    Given I am logged in
    And there is a survey
    And I am the sponsor
    And the survey has enough participants but partial report
    And the survey is stalled
    And I am on the survey show page
    When I follow "finish"
    Then I should see "Report on"
    
  Scenario: View survey report after responding
    Given I am logged in
    And there is a survey
    And I have responded to the survey
    And the survey has enough participants but partial report
    And the survey is stalled
    And the survey is finished
    And I am on the survey report page
    Then I should see "Question 1 text"
    And I should see "1.40"
    And I should see "Data hidden due to insufficient responses."
  
  Scenario: View survey report without responding
    Given I am logged in
    And there is a survey
    And the survey has enough participants but partial report
    And the survey is stalled
    And the survey is finished
    And I am on the survey report page
    Then I should see "The response deadline has passed. You may not view the results unless you have responded to the survey."

