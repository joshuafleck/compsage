Visitors should be in control of creating an account and of proving their
essential humanity/accountability or whatever it is people think the
id-validation does.  We should be fairly skeptical about this process, as the
identity+trust chain starts here.

Story: Creating an account
  As an anonymous organization
  I want to be able to create an account
  So that I can be one of the cool kids

  #
  # Account Creation: Get entry form
  #
  Scenario: Anonymous organization can start creating an account
    Given an anonymous organization
    When  she goes to /signup
    Then  she should be at the 'organizations/new' page
     And  the page should look AWESOME
     And  she should see a <form> containing a textfield: Login, textfield: Email, password: Password, password: 'Confirm Password', submit: 'Sign up'

  #
  # Account Creation
  #
  Scenario: Anonymous organization can create an account
    Given an anonymous organization
     And  no organization with login: 'Oona' exists
    When  she registers an account as the preloaded 'Oona'
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'Thanks for signing up!'
     And  a organization with login: 'oona' should exist
     And  the organization should have login: 'oona', and email: 'unactivated@example.com'

     And  oona should be logged in


  #
  # Account Creation Failure: Account exists
  #

     
  Scenario: Anonymous organization can not create an account replacing an activated account
    Given an anonymous organization
     And  an activated organization named 'Reggie'
     And  we try hard to remember the organization's updated_at, and created_at
    When  she registers an account with login: 'reggie', password: 'monkey', and email: 'reggie@example.com'
    Then  she should be at the 'organizations/new' page
     And  she should     see an errorExplanation message 'Login has already been taken'
     And  she should not see an errorExplanation message 'Email has already been taken'
     And  a organization with login: 'reggie' should exist
     And  the organization should have email: 'registered@example.com'

     And  the organization's created_at should stay the same under to_s
     And  the organization's updated_at should stay the same under to_s
     And  she should not be logged in

  #
  # Account Creation Failure: Incomplete input
  #
  Scenario: Anonymous organization can not create an account with incomplete or incorrect input
    Given an anonymous organization
     And  no organization with login: 'Oona' exists
    When  she registers an account with login: '',     password: 'monkey', password_confirmation: 'monkey' and email: 'unactivated@example.com'
    Then  she should be at the 'organizations/new' page
     And  she should     see an errorExplanation message 'Login can't be blank'
     And  no organization with login: 'oona' should exist
     
  Scenario: Anonymous organization can not create an account with no password
    Given an anonymous organization
     And  no organization with login: 'Oona' exists
    When  she registers an account with login: 'oona', password: '',       password_confirmation: 'monkey' and email: 'unactivated@example.com'
    Then  she should be at the 'organizations/new' page
     And  she should     see an errorExplanation message 'Password can't be blank'
     And  no organization with login: 'oona' should exist
     
  Scenario: Anonymous organization can not create an account with no password_confirmation
    Given an anonymous organization
     And  no organization with login: 'Oona' exists
    When  she registers an account with login: 'oona', password: 'monkey', password_confirmation: ''       and email: 'unactivated@example.com'
    Then  she should be at the 'organizations/new' page
     And  she should     see an errorExplanation message 'Password confirmation can't be blank'
     And  no organization with login: 'oona' should exist
     
  Scenario: Anonymous organization can not create an account with mismatched password & password_confirmation
    Given an anonymous organization
     And  no organization with login: 'Oona' exists
    When  she registers an account with login: 'oona', password: 'monkey', password_confirmation: 'monkeY' and email: 'unactivated@example.com'
    Then  she should be at the 'organizations/new' page
     And  she should     see an errorExplanation message 'Password doesn't match confirmation'
     And  no organization with login: 'oona' should exist
     
  Scenario: Anonymous organization can not create an account with bad email
    Given an anonymous organization
     And  no organization with login: 'Oona' exists
    When  she registers an account with login: 'oona', password: 'monkey', password_confirmation: 'monkey' and email: ''
    Then  she should be at the 'organizations/new' page
     And  she should     see an errorExplanation message 'Email can't be blank'
     And  no organization with login: 'oona' should exist
    When  she registers an account with login: 'oona', password: 'monkey', password_confirmation: 'monkey' and email: 'unactivated@example.com'
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'Thanks for signing up!'
     And  a organization with login: 'oona' should exist
     And  the organization should have login: 'oona', and email: 'unactivated@example.com'

     And  oona should be logged in

     

