Feature: Manage surveys

  Scenario: Search
    Given I am logged in
    When I search for a running survey by name
    Then I should see "Search Results"
    And I should see the survey I searched for
  
  Scenario: Index
    Given I am logged in
    And I have been invited, sponsored, participated, and finished surveys
    When I am on the surveys index
    Then I should see invited, sponsored, participated, and finished surveys
  
  Scenario: Results
    Given I am logged in
    And I am sponsoring a finished survey
    When I am on the survey reports index
    Then I should see "Trailer Park"
