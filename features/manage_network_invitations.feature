Feature: Manage network invitations

  Scenario: Sending a network invitation
    Given I am testing with firewatir
    And I am logged in
    And I own a network
    And I am on the network page

    When I type in an existing organization and select it from the dropdown

    Then I should see an invitation success message

  Scenario: Sending a network invitation by typing in an existing org's info
    Given I am logged in
    And I own a network
    And I am on the network page

    When I type in an existing organization and invite them

    Then I should see an invitation success message

  Scenario: Sending a network invitation to an external organization
    Given I am logged in
    And I own a network
    And I am on the network page

    When I create an external invitation

    Then I should see an invitation success message

  Scenario: Accepting a network invitation
    Given I am logged in
    And I am invited to a network
    And I am on the networks index

    When I click "Join Network"

    Then I should see "Leave Network"
  Scenario: Declining a network invitation
    Given I am logged in
    And I am invited to a network
    And I am on the networks index

    When I click "Decline"

    Then I should not see "Join Network"
