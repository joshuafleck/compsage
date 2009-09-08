Feature: Manage Invitations

  Scenario: Creating an external survey invitation
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a "pending" survey
    And I am on the survey invitations page
    When I create an external invitation
    Then I should be able to see the invitation

  Scenario: Creating an internal survey invitation
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a "pending" survey
    And I am on the survey invitations page
    When I type in an existing organization and select it from the dropdown
    Then I should be able to see the invitation
