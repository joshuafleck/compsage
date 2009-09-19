Feature: Manage running survey

  Scenario: Edit 
    Given I am logged in
    And I am sponsoring a running survey
    When I am on the edit survey page
    And I edit the survey
    Then I should see "Responding to"
  
  Scenario: Edit with error
    Given I am logged in
    And I am sponsoring a running survey
    When I am on the edit survey page
    And I unsuccessfully edit the survey
    Then I should see "Please try again."
  
  Scenario: Invite
    Given I am logged in
    And I am sponsoring a running survey
    When I am on the survey invitations page
    Then I should see "Invitation List"
    Then I should see "Organization"
    
