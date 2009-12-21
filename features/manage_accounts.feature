Feature: Manage accounts
     
  Scenario: Register new account
    Given I am on the new account page
    When I add an account
    Then I should see "Welcome to CompSage!"   
 
  Scenario: Register new account as survey invitee
    Given I am logged in via survey invitation
    And I am on the new account page
    When I add an account
    Then I should see "Welcome to CompSage!"
    
  Scenario: Register new account as network invitee
    Given I am logged in via network invitation
    When I add an account
    Then I should see "Welcome to CompSage!"   

  Scenario: Register new account with error
    Given I am logged in via survey invitation
    And I am on the new account page
    When I unsuccessfully add an account
    Then I should see "Please try again."      
    
  Scenario: Edit account
    Given I am logged in
    And I am on the edit account page 
    When I edit the account        
    Then I should see "Your account was updated successfully."
    
  Scenario: Edit account with error
    Given I am logged in
    And I am on the edit account page 
    When I unsuccessfully edit the account        
    Then I should see "Please try again."    
    
  Scenario: Request a password reset
    Given I am on the login page
    And I follow "Forgot your password?"
    When I request a password reset
    Then I should see "An email containing a link to reset your password was sent to"
    
  Scenario: Request a password reset with error
    Given I am on the login page
    And I follow "Forgot your password?"
    When I unsuccuessfully request a password reset
    Then I should see "There was no account found for"    
    
  Scenario: Reset my password
    Given I have requested a password reset
    And I am on the reset password page
    When I reset my password
    Then I should see "Your password has been changed."
    
  Scenario: Reset my password with invalid key
    Given I am on the reset password page
    Then I should see "We do not have a record of a password reset request."    
    
  Scenario: Reset my password with expired key
    Given I have requested a password reset 
    And the password reset request is expired
    When I am on the reset password page
    Then I should see "You must change your password within 5 days of making the reset request."    
    
  Scenario: Reset my password with error
    Given I have requested a password reset
    And I am on the reset password page
    When I unsuccessfully reset my password 
    Then I should see "Please try again."    
    


