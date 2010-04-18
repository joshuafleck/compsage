Feature: Authenticating association members

Scenario: Uninitialized association member login with returning user form
  Given I am testing with firewatir
  And there is an uninitialized association member
  When I log into the association
  Then I should see "Create a new password"

Scenario: Uninitialized association member login
  Given I am testing with firewatir
  And there is an uninitialized association member
  When I fill in the confirmation
  When I sign up into the association
  Then I should see "Welcome to CompSage!"

Scenario: Uninitialized association member failed login
  Given I am testing with firewatir
  And there is an uninitialized association member
  When I sign up into the association
  Then I should see "Please try again"

Scenario: Initialized association member login
  Given I am testing with firewatir
  And there is an initialized association member
  When I log into the association
  Then I should see "Welcome to CompSage!"
  
