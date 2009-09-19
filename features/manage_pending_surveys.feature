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
    
  Scenario: Invitations
    Given I am logged in  
    And I am sponsoring a "pending" survey
    And the survey has enough invitations
    And I am on the survey invitations page
    When I am done with invitations
    Then I should be on the survey preview page
  
  Scenario: Not enough invitations
    Given I am logged in  
    And I am sponsoring a "pending" survey
    And I am on the survey invitations page
    When I am done with invitations
    Then I should see "You must invite at least 5 organizations"
  
  Scenario: Preview
    Given I am logged in  
    And I am sponsoring a "pending" survey
    And the survey has enough invitations
    When I am on the survey preview page
    And I preview the survey
    And I am done previewing the survey
    Then I should be on the survey billing page
  
  Scenario: Billing via credit card
  
  Scenario: Billing via credit card with errors
  
  Scenario: Billing via invoice
  
  Scenario: Billing via invoice with errors 
