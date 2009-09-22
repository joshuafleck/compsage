Feature: Using discussions

  Scenario: Create a discussion topic successfully.
    Given I am testing javascript
    And I am logged in
    And I am participating in a "running" survey
    When I am on the survey show page
    And I click the discussion topic link
    And I fill in the discussion topic
    And I submit a discussion
    Then I should see the discussion topic
    
  Scenario: Create a discussion topic with error.
    Given I am testing javascript
    And I am logged in
    And I am participating in a "running" survey
    When I am on the survey show page
    And I click the discussion topic link
    And I submit a discussion
    Then I should see an error message
    
  Scenario: Create reply successfully.
    Given I am testing javascript
    And I am logged in
    And I am participating in a "running" survey
    And the survey has a discussion topic
    When I am on the survey show page
    And I click the reply link
    And I fill in the reply
    And I submit a reply
    Then I should see the reply text
    
  Scenario: Create reply with error.
    Given I am testing javascript
    And I am logged in
    And I am participating in a "running" survey
    And the survey has a discussion topic
    When I am on the survey show page
    And I click the reply link
    And I submit a reply
    Then I should see an error message
    
  Scenario: Report abuse.
    Given I am testing javascript
    And I am logged in
    And I am participating in a "running" survey
    And the survey has a discussion topic
    When I am on the survey show page
    And I report abuse for a discussion
    Then I should see this discussion has been reported
    And I should not see the discussion
    
  Scenario: Create a discussion topic via survey invitation.
    Given I am testing javascript
    And I am logged in via survey invitation
    And I click the discussion topic link
    And I fill in the discussion topic
    And I submit a discussion
    Then I should see the discussion topic
    
  Scenario: Create a discussion topic as the survey sponsor.
    Given I am testing javascript
    And I am logged in
    And I am sponsoring a "running" survey
    When I am on the survey show page
    And I click the discussion topic link
    And I fill in the discussion topic
    And I submit a discussion
    Then I should see the discussion topic
    And I should see reply from survey sponsor