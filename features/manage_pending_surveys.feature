Feature: Pending surveys

  Scenario: Delete
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a "pending" survey
    And I am on the edit survey page
    When I cancel the survey
    Then I should be on the survey index
  
  Scenario: Create
    Given I am testing javascript
    And I am logged in
    And I am on the new survey page
    When I create the survey
    Then I should be on the survey invitations page
    When I click back
    Then I should be on the new survey page
    
  Scenario: Invitations
    Given I am testing javascript
    And I am logged in  
    And I am sponsoring a "pending" survey
    And the survey has enough invitations
    And I am on the survey invitations page
    When I click next
    Then I should be on the survey preview page
    When I click back
    Then I should be on the survey invitations page
  
  Scenario: Not enough invitations
    Given I am logged in  
    And I am sponsoring a "pending" survey
    And I am on the survey invitations page
    When I click next
    Then I should see "You must invite at least 5 organizations"
  
  Scenario: Preview
    Given I am testing javascript
    And I am logged in  
    And I am sponsoring a "pending" survey
    And the survey has enough invitations
    When I am on the survey preview page
    And I preview the survey
    When I click next
    Then I should be on the survey billing page
    When I click back
    Then I should be on the survey preview page
  
  Scenario: Billing via credit card
    Given I am testing javascript
    And I am logged in  
    And I am sponsoring a "pending" survey
    And the survey has enough invitations
    When I am on the survey billing page
    When I pay via credit card
    Then I should see "Manage Your Survey"
  
  Scenario: Billing via credit card with errors
    Given I am testing javascript
    And I am logged in  
    And I am sponsoring a "pending" survey
    And the survey has enough invitations
    When I am on the survey billing page
    When I unsuccessfully pay via credit card
    Then I should see "Please try again."
  
  Scenario: Billing via invoice
    Given I am testing javascript
    And I am logged in  
    And I am sponsoring a "pending" survey
    And the survey has enough invitations
    When I am on the survey billing page
    When I pay via invoice
    Then I should see "Manage Your Survey"
  
  Scenario: Billing via invoice with errors
    Given I am testing javascript
    And I am logged in  
    And I am sponsoring a "pending" survey
    And the survey has enough invitations
    When I am on the survey billing page
    When I unsuccessfully pay via invoice
    Then I should see "Please try again."
