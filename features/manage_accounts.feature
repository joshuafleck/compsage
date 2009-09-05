Feature: Manage accounts
  
  Scenario: Register new account as survey invitee
    Given I am logged in via survey invitation
    And I am on the new account page
    When I add an account
    Then I should see "Welcome to CompSage!"
    
  Scenario: Edit account
    Given I am logged in
    And I am on the edit account page 
    When I edit the account        
    Then I should see "Your account was updated successfully."
    
  Scenario: Request a password reset
    Given I am on the login page
    And I follow "Forgot your password?"
    When I request a password reset
    Then I should see "Email sent to"
    
  Scenario: Reset my password
    Given I have requested a password reset
    And I am on the reset password page
    When I reset my password
    Then I should see "Your password has been changed."
    


