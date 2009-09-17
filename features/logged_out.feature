Feature: Logged Out

  Scenario: Log in successfully
    Given I am on the home page
    And I am logged in
    Then I should see "Sponsoring a survey"
    
  Scenario: Log in with error
    Given I am on the home page
    And I enter an invalid login
    Then I should see "Incorrect email or password"
  
  Scenario: Log in via survey invitation successfully
    Given I am logged in via survey invitation
    Then I should see "Sponsored by"
  
  Scenario: Log in via survey invitation with invalid error
    When I login with invalid invitation credentials
    Then I should see "We are unable to process your request at this time."
  
  Scenario: Access How it works
    Given I am on the home page
    When I click "How it works"
    Then I should see "Becoming a member"
    
  Scenario: Access Contact
    Given I am on the home page
    When I click "Contact"
    Then I should see "support@compsage.com"
    
  Scenario: Access Privacy
    Given I am on the home page
    When I click "Privacy"
    Then I should see "Compsage Privacy"
    
  Scenario: Access About
    Given I am on the home page
    When I click "About"
    Then I should see "Legal Disclaimer"