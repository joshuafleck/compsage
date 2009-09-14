Feature: Manage stalled surveys

  Scenario: Rerun
    Given I am logged in
    And I am sponsoring a "stalled" survey
    When I am on the survey show page
    And I press "Submit"
    Then I should see "Invitation List"
    
  Scenario: Cancel
    Given I am logged in
    And I am sponsoring a "stalled" survey
    When I am on the survey show page
    And I follow "Cancel the survey"
    Then I should not see "Stalled"  
    
  Scenario: View
    Given I am logged in via survey invitation
    And the survey to which I am invited is stalled
    When I am on the survey show page
    Then I should see "insufficient participation" 
    
  Scenario: Finish partial
    Given I am logged in
    And I am sponsoring a "stalled" survey
    And the survey has a partial response
    When I am on the survey show page
    And I follow "finish"
    Then I should see "Report for"           
    
  
