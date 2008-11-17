Feature: Manage accounts
  
  Scenario: Register new account as survey invitee
    Given I am invited to the survey
    And I am on the new account page
    And I fill in "Email" with "test@test.com"
    And I fill in "Name of Your Organization" with "test organization"
    And I fill in "Your Name" with "test name"
    And I fill in "Zip Code" with "12345"
    And I fill in "Password" with "123456"
    And I fill in "Password Confirmation" with "123456"
    And I press "Create"
    Then I should see "Your account was created successfully."
    And I fill in "Email" with "test@test.com"
    And I fill in "Password" with "123456"
    And I press "Log In"
    Then I should not see "Password"
    
  Scenario: Edit account
    Given I am logged in
    And I am on the edit account page 
    And I fill in "Email" with "test@test.com"
    And I fill in "Name of Your Organization" with "test organization"
    And I fill in "Your Name" with "test name"
    And I fill in "Zip Code" with "12345"
    And I fill in "Password" with "123456"
    And I fill in "Password Confirmation" with "123456"
    And I press "Update"        
    Then I should see "test organization"
    And I should not see "There were problems with the following fields:"
    

