Feature: Manage pending accounts

  Scenario: Register new pending account
    Given I am on the new pending account page
    When I add a pending account
    Then I should see "Thanks! We have received your information."
    
  Scenario: Register new pending account with error
    Given I am on the new pending account page
    When I unsuccessfully add a pending account
    Then I should see "Please try again."    
