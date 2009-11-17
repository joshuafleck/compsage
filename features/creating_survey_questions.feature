Feature: Creating survey questions

  Scenario: Default questions
    Given I am testing with firewatir
    And I am logged in
    And I am on the new survey page

    Then I should see "Average base salary"
    And I should see "Salary range minimum"
    And I should see "Salary range midpoint"
    And I should see "Salary range maximum"

  Scenario: Adding a PDQ
    Given I am testing with firewatir
    And I am logged in
    And I am on the new survey page

    When I add a predefined question

    Then I should see the new question
    
  Scenario: Adding a required PDQ
    Given I am testing with firewatir
    And I am logged in
    And I am on the new survey page
    And I check the required button

    When I add a predefined question

    Then I should see the new question
    And I should see required
  
  Scenario: Adding a custom question
    Given I am testing with firewatir
    And I am logged in
    And I am on the new survey page

    When I add a custom question

    Then I should see the new question
    
  Scenario: Adding a required custom question
    Given I am testing with firewatir
    And I am logged in
    And I am on the new survey page
    And I check the required button

    When I add a custom question

    Then I should see the new question
    And I should see required

  Scenario: Attempting to add an invalid question
    Given I am testing with firewatir
    And I am logged in
    And I am on the new survey page

    When I attempt to add an invalid custom question

    Then I should not see the new question
    And I should see an invalid question error

  Scenario: Moving a question
    Given I am testing with firewatir
    And I am logged in
    And I am on the new survey page

    When I move the first question down
    Then the question should be moved

    When I move the second question up
    Then the question should be moved

  Scenario: Editing a question
    Given I am testing with firewatir
    And I am logged in
    And I am on the new survey page

    When I edit the first question
    Then I should see the edited question

  Scenario: Editing a question but doing something stupid
    Given I am testing with firewatir
    And I am logged in
    And I am on the new survey page

    When I incorrectly edit the first question
    Then I should see an invalid question error

  Scenario: Deleting a question
    Given I am testing with firewatir
    And I am logged in
    And I am on the new survey page

    When I delete the first question
    Then I should not see the deleted question
