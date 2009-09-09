Feature: Input Masking and Range Checking of Survey Responses

  Scenario: Wage responses
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a running survey with a wage question
    And I am on the survey response page

    When I enter "1000"
    Then it should read "$1,000.00"

    When I enter "100.0001"
    Then it should read "$100.00"

    When I enter "asdf"
    Then it should read ""
    And I should see a response warning

    When I enter "10"
    And I choose the hourly pay type
    Then I should not see a response warning

    When I choose the annual pay type
    Then I should see a response warning

    When I enter "100000000"
    Then I should see a response warning

    When I enter "10000"
    Then I should not see a response warning
    
  Scenario: Numeric responses
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a running survey with a numerical question
    And I am on the survey response page

    When I enter "1"
    Then it should read "1"

    When I enter "a"
    Then it should read ""
    And I should see a response warning

    When I enter "10000"
    Then it should read "10,000"

  Scenario: Percent responses
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a running survey with a percent question
    And I am on the survey response page

    When I enter "2"
    Then it should read "2%"

    When I enter "2.5%"
    Then it should read "2.5%"

    When I enter "a"
    Then it should read ""
    And I should see a response warning

  Scenario: Text responses
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a running survey with a text question
    And I am on the survey response page

    When I enter "hi"
    Then it should read "hi"

    When I enter "1"
    Then it should read "1"
