Feature: Organization page

  Scenario: View an organization with no networks or surveys
    Given I am logged in
    And I am on the organization page
    Then I should see "Contact"
    And I should not see "Invite to a Survey"
    And I should not see "Invite to a Network"
    
  Scenario: View as organization with a network
    Given I am logged in
    And I own a network
    And I am on the organization page
    Then I should see "Contact"
    And I should not see "Invite to a Survey"
    And I should see "Invite to a Network"
    
  Scenario: View as organization with a survey
    Given I am logged in
    And I am sponsoring a "running" survey
    And I am on the organization page
    Then I should see "Contact"
    And I should see "Invite to a Survey"
    And I should not see "Invite to a Network"

  Scenario: View as organization with a survey and a network
    Given I am logged in
    And I own a network
    And I am sponsoring a "running" survey
    And I am on the organization page
    Then I should see "Contact"
    And I should see "Invite to a Survey"
    And I should see "Invite to a Network"
    
  Scenario: View as survey invitation
    Given I am logged in via survey invitation
    And I am on the organization page of a survey sponsor
    Then I should see "Contact"
    
  Scenario: View non-invitee as survey invitation
    Given I am logged in via survey invitation
    And I am on the organization page
    Then I should see "Remember me"
    
  Scenario: Invite to survey
    Given I am testing javascript
    And I am logged in
    And I own a network
    And I am sponsoring a "running" survey
    And I am on the organization page
    When I invite the organization to a survey
    Then I should see "survey" success message
    
  Scenario: Invite to survey already invited
    Given I am testing javascript
    And I am logged in
    And I own a network
    And I am sponsoring a "running" survey
    And I am on the organization page
    When I invite the organization to a survey
    And I invite the organization to a survey
    Then I should see "survey" error message
    
  Scenario: Invite to network
    Given I am testing javascript
    And I am logged in
    And I own a network
    And I am sponsoring a "running" survey
    And I am on the organization page
    When I invite the organization to a network
    Then I should see "network" success message
    
  Scenario: Invite to network already invited
    Given I am testing javascript
    And I am logged in
    And I own a network
    And I am sponsoring a "running" survey
    And I am on the organization page
    When I invite the organization to a network
    And I invite the organization to a network
    Then I should see "network" error message
