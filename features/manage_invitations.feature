Feature: Manage Invitations

  Scenario: Creating an external survey invitation
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a "pending" survey
    And I am on the survey invitations page
    When I create an external invitation
    Then I should see the invitation

  Scenario: Creating an internal survey invitation by selecting from dropdown
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a "pending" survey
    And I am on the survey invitations page
    When I type in an existing organization and select it from the dropdown
    Then I should see the invitation

  Scenario: Creating an internal survey invitation by typing in an existing email
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a "pending" survey
    And I am on the survey invitations page
    When I type in an existing organization and invite them
    Then I should see the invitation

  Scenario: Inviting a network to a survey
    Given I am testing javascript
    And I am logged in
    And I am in a network
    And I am sponsoring a "pending" survey
    And I am on the survey invitations page
    When I invite the network
    Then I should see the invitation

  Scenario: Sending an invalid invitation

  Scenario: Inviting someone already invited

  Scenario: Removing a survey invitation
