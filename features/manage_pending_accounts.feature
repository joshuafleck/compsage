Feature: Manage pending accounts

  Scenario: Register new pending_account
    Given I am on the new pending account page
    When I add a pending account
    Then I should see "We have received your signup request."
