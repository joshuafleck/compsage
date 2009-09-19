Feature: Responding to Surveys

  Scenario: Answering questions
    Given I am testing with firewatir
    And I am logged in
    And I am sponsoring a survey with every question type
    And I am on the survey response page

    When I answer the entire survey

    Then I should see the response success message

  Scenario: Leaving comments
    Given I am logged in
    And I am sponsoring a survey with every question type
    And I am on the survey response page
    
    When I answer the entire survey with comments

    Then I should see the response success message

    When I am on the survey response page

    Then I should see my comments

  Scenario: Cancelling a survey
    Given I am logged in
    And I am sponsoring a running survey
    And I am on the survey response page

    When I cancel the survey response

    Then I should be on the survey show page

  Scenario: Answering questions without javascript
    Given I am logged in
    And I am sponsoring a survey with every question type
    And I am on the survey response page
    
    When I answer the entire survey

    Then I should see the response success message

  Scenario: Editing responses
    Given I am logged in
    And I am sponsoring a survey with every question type
    And I have previously responded to the survey
    
    When I am on the survey response page

    Then I should see my previous responses

  Scenario: Responding with an external invitation
    Given I am logged in via survey invitation
    And I am on the survey response page

    When I answer the entire survey

    Then I should see the response success message
    And I should see "New Account"
