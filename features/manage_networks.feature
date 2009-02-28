Feature: Manage Networks

  Scenario: Create network
    Given I am logged in
    And I am on the new network page
    When I fill in "Network Name" with "Network 1"
    And I fill in "Description" with "Network 1 Description"
    And I press "Create"
    Then I should see "Invitations to Network 1"
    
  Scenario: Edit network
    Given I am logged in
    And there is a network
    And I own the network
    And I am on the edit network page
    When I fill in "Network Name" with "Network 1.1"
    And I fill in "Description" with "Network 1.1 Description"
    And I press "Update"
    Then I should see "Network 1.1"
    
  Scenario: Change owner
    Given I am logged in
    And there is a network
    And I own the network
    And the network has members
    And I am on the edit network page
    And I choose "Organization 1"
    And I press "Update"
    Then I should see "Organization 1 contact"
  
  Scenario: Join network
    Given I am logged in
    And there is a network
    And I am invited to the network
    And I am on the network index page
    And I follow "Join Network"
    And I am on the network index page
    Then I should not see "Join Network"
    And I should see "Network 1"
    
  Scenario: Leave network
    Given I am logged in
    And there is a network
    And I own the network
    And I am on the network index page
    And I follow "Network 1"
    When I follow "Leave Network"
    Then I should not see "Network 1"
  
  Scenario: Survey network
    Given I am logged in
    And there is a network
    And I am a member of the network
    And the network has members
    And I am on the show network page
    And there is a predefined question
    When I follow "Survey Network"
    And I fill in "Job title" with "Survey network 1"
    And I check "Question 1"
    And I press "Create"
    And I follow "Continue"
    And I press "Send Invitations"
    And I follow "Maybe Later"
    Then I should see "Organization 1"
    And I should see "Organization 2"
    
  
  
