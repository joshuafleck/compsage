Feature: Manage Invitations

  Scenario: Decline survey invitation
    Given I am logged in
    And there is a survey
    And I am invited to the survey
    And I am on the survey index page
    When I follow "Decline Invitation"
    Then I should not see "Decline"
    And I should see "Survey 1"
    
  Scenario: Decline network invitation
    Given I am logged in
    And there is a network
    And I am invited to the network
    And I am on the network index page
    When I follow "Decline"
    Then I should not see "Decline"
    And I should not see "Network 1"    
