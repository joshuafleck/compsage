Feature: The Contact Us Form
  Scenario: Submitting the form
    Given I am on the home page
    And I click "Contact"

    When I fill in the contact form

    Then I should see "Thank You!"

  Scenario: Forgetting some details
    Given I am on the home page
    And I click "Contact"

    When I fill in the contact form incompletely

    Then I should see "Please try again"
