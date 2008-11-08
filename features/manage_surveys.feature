Feature: Manage surveys
  
  Scenario: Create new survey
    Given I am logged in
    And I am on the new survey page
    When I fill in "Job title" with "Hard Worker"
    When I fill in "Job description" with "Works Hard"
    And I select "3 days" from "Run length"
    And I check "Question 1"
    And I fill in "Question Text" with "Custom question 1"
    #And I press "Add Question"
    And I press "Create Survey"
    Then I should see "Invitations to Hard Worker"
    When I follow "Respond Now"
    Then I should see "Responding to Hard Worker"
    And I should see "Question 1 text"
    #And I should see "Custom question 1"
    
  Scenario: Create new survey with failure
    Given I am logged in
    And I am on the new survey page
    And I check "Question 1"
    And I press "Create Survey"
    Then I should see "Job title can't be blank"
    When I fill in "Job title" with "Hard Worker"
    And I press "Create Survey"
    When I follow "Respond Now"
    Then I should see "Responding to Hard Worker"
    And I should see "Question 1 text"  
    
  Scenario: Edit a survey
    Given I am logged in
    And I am on the edit survey page
    When I fill in "Job title" with "Hard Worker"
    And I check "Predefined Question unselected"
    And I uncheck "Predefined Question selected"
    And I uncheck "Custom Question 2 text"
    And I press "Update"    
    Then I should see "Survey was successfully updated."
    When I follow "Respond_button"
    Then I should see "Predefined Question unselected text"
    And I should see "Custom Question 1 text"
    And I should not see "Predefined Question selected text"
    And I should not see "Custom Question 2 text"

