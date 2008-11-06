Feature: Manage surveys
  
  Scenario: Create new survey
    Given I am logged in
    Given I am on the new survey page
    When I fill in "Job title" with "Hard Worker"
    When I select "3 days" from "Run length"
    And I press "Create Survey"
    Then I should see "Invitations to Hard Worker"

