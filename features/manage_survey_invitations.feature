Feature: Manage Survey Invitations

  Scenario: Adding an invitation message
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a "pending" survey
    And I am on the survey invitations page
    And I add a custom invitation message

    When I click next

    Then I should see "Custom message from sponsor."
  Scenario: Accepting a survey invitation
    Given I am logged in
    And I have a survey invitation
    And I am on the surveys index
    When I respond to the invited survey
    Then I should see the response success message

  Scenario: Declining a survey invitation
    Given I am logged in
    And I have a survey invitation
    And I am on the surveys index
    When I decline the survey invitation
    Then I should not see the survey invitation

  Scenario: Viewing the invitation list
    Given I am logged in
    And I am sponsoring a "pending" survey
    When I am on the survey invitations page
    Then I should see the survey sponsor in the invitation list
    
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
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a "pending" survey
    And I am on the survey invitations page
    When I type in an invalid invitation
    Then I should not see the invitation
    And I should see an error message

  Scenario: Inviting someone already invited
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a "pending" survey
    And I am on the survey invitations page
    When I send a duplicate invitation
    Then I should see an error message
    
  Scenario: Removing a survey invitation
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a "pending" survey
    And I have created a survey invitation
    And I am on the survey invitations page
    When I remove the invitation
    Then I should not see the invitation
    
  Scenario: Using association member live search
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a "pending" survey
    And I belong to an association with members
    And I am on the survey invitations page
    When I enter an organization name "ASDF" and location "10"
    Then I should see no association members

  Scenario: Inviting association member
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a "pending" survey
    And I belong to an association with members
    And I am on the survey invitations page
    When I enter an organization name "Exist" and location "10"
    And I click the invite button for an organization
    Then I should see the invitation
    
  Scenario: Inviting association member whom you have already invited without saving
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a "pending" survey
    And I belong to an association with members    
    And I am on the survey invitations page
    When I enter an organization name "Exist" and location "10"
    And I click the invite button for an organization
    And I click the invite button for an organization
    Then I should see an error message
    
  Scenario: Inviting association member whom you have already invited with saving
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a "pending" survey
    And I belong to an association with members
    And an organization has already been invited to the survey
    And I am on the survey invitations page
    Then I should not see the organization  
    
  Scenario: Inviting all association member after using association member live search
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a "pending" survey
    And I belong to an association with members
    And I am on the survey invitations page
    When I click invite all
    Then I should see the organizations in the invited list
    
