Feature: Manage Networks

  Scenario: Networks index
    Given I am logged in
    And I own a network
    And I am in a network
    And I am invited to a network
    When I am on the networks index
    Then I should see "Owned network"
    And I should see "Belonged network"
    And I should see "Invited network"
    
  Scenario: Create 
    Given I am logged in
    And I am on the new network page
    When I add a network
    Then I should see "My network"
    
  Scenario: Create with error
    Given I am logged in
    And I am on the new network page
    When I unsuccessfully add a network
    Then I should see "Please try again."    
    
  Scenario: Edit 
    Given I am logged in
    And I own a network
    And I am on the edit network page
    When I edit the network
    Then I should see "My network edited"
    
  Scenario: Edit with error
    Given I am logged in
    And I own a network
    And I am on the edit network page
    When I unsuccessfully edit the network
    Then I should see "Please try again."  
    
  Scenario: Leave as owner 
    Given I am logged in
    And I own a network
    And I am on the network page
    When I follow "Leave Network"
    Then I should not see "Owned network"  
    
  Scenario: Leave 
    Given I am logged in
    And I am in a network
    And I am on the network page
    When I follow "Leave Network"
    Then I should not see "Belonged network"  
    
  Scenario: Survey
    Given I am logged in
    And I am in a network
    And the network has members
    And I am on the network page
    When I follow "Survey Network"
    And the netwok survey has a question
    And I fill in "Job title" with "Test"
    And I press "form_submit"
    Then I should see "network member"
    
