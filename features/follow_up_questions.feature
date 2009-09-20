Feature: Questions with follow-ups

  Scenario: Responding to follow-ups of yes/no
    Given I am testing with firewatir
    And I am logged in
    And I am sponsoring a survey with a follow-up to a yes/no question
    And I am on the survey response page

    Then the follow-up question should be disabled
  
    When I respond to the parent question
    Then the follow-up question should not be disabled

    When I change my response to the parent question
    Then the follow-up question should be disabled

  Scenario: Responding to follow-ups of multiple choice
    Given I am testing with firewatir
    And I am logged in
    And I am sponsoring a survey with a follow-up to a multiple choice question
    And I am on the survey response page

    Then the follow-up question should be disabled

    When I respond to the parent question
    Then the follow-up question should not be disabled

    When I change my response to the parent question
    Then the follow-up question should not be disabled

  Scenario: Responding to follow-ups of text input
    Given I am testing with firewatir
    And I am logged in
    And I am sponsoring a survey with a follow-up to a text question
    And I am on the survey response page

    Then the follow-up question should be disabled

    When I respond to the parent question
    Then the follow-up question should not be disabled

    When I remove my response to the parent question
    Then the follow-up question should be disabled

  Scenario: Responding to follow-ups without answering parent question
    Given I am logged in
    And I am sponsoring a survey with a follow-up to a text question
    And I am on the survey response page

    When I respond to just the follow-up question

    Then I should see "Please try again." 
