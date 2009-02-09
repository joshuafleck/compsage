Feature: Manage pending_accounts

  Scenario: Register new pending_account
    Given I am on the new pending_account page
    And I fill in "Name of Your Organization" with "test organization"
    And I fill in "First Name" with "test first name"
    And I fill in "Last Name" with "test last name"
    And I fill in "Email" with "test@test.com"
    And I fill in "phone" with "1234567890"
    And I press "Signup"
    Then I should see "Password"
