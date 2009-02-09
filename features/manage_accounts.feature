Feature: Manage accounts
  
  Scenario: Register new account as survey invitee
    Given there is a survey
    And I am externally invited to the survey
    And I am on the survey show page
    And I am on the new account page
    And I fill in "Email address" with "test@test.com"
    And I fill in "Name of Your Organization" with "test organization"
    And I fill in "Your Name" with "test name"
    And I fill in "Zip" with "12345"
    And I fill in "Password" with "123456"
    And I fill in "Confirm password" with "123456"
    And I press "Sign Up"
    Then I should see "Your account was created successfully."
    And I should see "Surveys"
    
  Scenario: Edit account
    Given I am logged in
    And I am on the edit account page 
    And I fill in "Email address" with "test@test.com"
    And I fill in "Your Name" with "test name"
    And I fill in "Zip" with "12345"
    And I fill in "Password" with "123456"
    And I fill in "Confirm password" with "123456"
    And I press "Update"        
    Then I should not see "There were problems with the following fields:"
    
  Scenario: Reset password
    Given there is an organization
    And I am on the login page
    And I follow "Forgot your password?"
    When I fill in "Email address" with "test@test.com"
    And I press "Reset My Password"
    Then I should see "Email sent to test@test.com."
    Given I am on the reset password page
    When I fill in "Password" with "test12"
    And I fill in "Confirm your password" with "test12"
    And I press "Reset My Password"
    Then I should see "Email"
    Given I am on the login page
    And I fill in "Email" with "test@test.com"
    And I fill in "Password" with "test12"
    And I press "Log in"
    Then I should not see "Password"
    


