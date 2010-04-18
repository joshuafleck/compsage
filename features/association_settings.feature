Feature: Changing Association Settings
  
  Scenario: Creating a new PDQ
    Given I am logged in as an association owner
    And I am on the settings page
    
    When I click "Create a new  standard question."
    And I enter the predefined question information
    And I press "Create"
    
    Then I should see "My PDQ"
    And I should see "My question text"
    
  Scenario: Creating a new PDQ with errors
    Given I am logged in as an association owner
    And I am on the settings page
  
    When I click "Create a new  standard question."
    And I press "Create"
  
    Then I should not see "My PDQ"
    And I should not see "My question text"
    And I should see "Please try again."
    
  Scenario: Editting a PDQ
    Given I am logged in as an association owner
    And I have created a standard PDQ
    And I am on the settings page
    
    When I click "My Current PDQ"
    And I enter the predefined question information
    And I press "Update"
    
    Then I should see "My PDQ"
    And I should see "My question text"
  
  Scenario: Deleting a PDQ
    Given I am testing javascript 
    And I am logged in as an association owner
    And I have created a standard PDQ
    And I am on the settings page

    When I confirm I want to delete the predefined question
    
    Then I should not see "My Current PDQ"
    