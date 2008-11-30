Feature: Manage Invitations

  Scenario: Decline survey invitation
    Given I am logged in
    And I am on the survey index page
    When I follow "Decline"
    Then I should not see "Decline"
    And I should see "Survey 1"
