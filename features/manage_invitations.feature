Feature: Manage Invitations

  Scenario: Creating an internal survey invitation
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a "pending" survey
    And I am on the survey invitations page
    When I create an invitation
    Then I should be able to see the invitation
