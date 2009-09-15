Feature: Manage pending accounts

  Scenario: Register new pending account
    Given I am on the new pending account page
    When I add a pending account
    Then I should see "We have received your signup request."
    
  Scenario: Register new pending account with error
    Given I am on the new pending account page
    When I unsuccessfully add a pending account
    Then I should see "Please try again."    
