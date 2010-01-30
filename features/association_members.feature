Feature: Managing association members

Scenario: Viewing the association list
  Given I am logged in as an association owner
  And I am on the members page
  
  Then I should see "Members"

Scenario: Adding a firm
  Given I am logged in as an association owner
  And I am on the members page
  
  When I click "Add Firm"
  And I enter "good" firm information
  And I press "Add Association Member"
  
  Then I should see "Member created"

Scenario: Adding a firm but not doing a very good job at it
  Given I am logged in as an association owner
  And I am on the members page
  
  When I click "Add Firm"
  And I enter "bad" firm information
  And I press "Add Association Member"
  
  Then I should see "Please try again."

Scenario: Editing a firm
  Given I am logged in as an association owner
  And I am on the members page
  
  When I click "Add Firm"
  And I enter "good" firm information
  And I press "Add Association Member"
  
  When I click "Firm"
  And I enter "good" firm information
  And I press "Save Changes"
  
  Then I should see "Member updated"

Scenario: Editing a firm but not doing a very good job at it
  Given I am logged in as an association owner
  And I am on the members page
  
  When I click "Add Firm"
  And I enter "good" firm information
  And I press "Add Association Member"
  
  And I click "Firm"
  And I enter "bad" firm information
  And I press "Save Changes"
  
  Then I should see "Please try again."  

Scenario: Removing a firm
  Given I am testing javascript
  And I am logged in as an association owner
  And I am on the members page
  And I have added firms to my association
  
  When I click the firm link
  And I press the remove button
  
  Then I should see "Member removed"