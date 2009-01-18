Feature: Manage Contacts

  Scenario: Search contacts
    Given I am logged in
    And I am on the network index page
    When I fill in "Find CompSage Members" with "Organization 1"
    And I press "Search"
    Then I should see "Organization 1"
