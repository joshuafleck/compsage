Feature: Manage finished surveys

  Scenario: View report
    Given I am logged in
    And I am participating in a "finished" survey
    And the survey has been invoiced
    When I am on the survey report page
    Then I should see "Report for"
    
  Scenario: View report when logged in via survey invitation
    Given I am logged in via survey invitation
    And the survey to which I am invited is "finished"
    And the survey has been invoiced
    When I am on the survey report page
    Then I should see "New Account"
    
  Scenario: View invoice
    Given I am logged in
    And I am sponsoring a "finished" survey
    And I am invoicing the survey
    When I am on the survey report page
    Then I should see "Invoice Number:"
    
  Scenario: View a report with insufficient responses
    Given I am logged in
    And I am participating in a "finished" survey
    When I am on the survey report page
    Then I should see "insufficient responses"
    
  Scenario: Report suspect results
    Given I am testing javascript
    And I am logged in
    And I am participating in a "finished" survey
    And the survey has been invoiced
    When I am on the survey report page
    And I report a suspect result
    Then I should not see the suspect results form
  
  Scenario: Change wage formatting
    Given I am testing javascript
    And I am logged in
    And I am participating in a finished survey
    And the report has a wage response
    And the survey has been invoiced
    When I am on the survey report page
    And I change the report wage formatting
    Then I should see the new wage format
    And I should not see the old wage format
    And the download link text should change
    
  Scenario: Download Excel
    Given I am logged in
    And I am participating in a "finished" survey
    And the survey has been invoiced
    When I am on the survey report page
    When I click "Excel"
    Then I should see "urn:schemas-microsoft-com:office:spreadsheet"
    
    When the report has a wage response
    And I download the hourly "xls" report
    Then I should see "urn:schemas-microsoft-com:office:spreadsheet"
    
  Scenario: Download Word
    Given I am logged in
    And I am participating in a "finished" survey
    And the survey has been invoiced
    When I am on the survey report page
    When I click "Word"
    Then I should see "schemas.microsoft.com/office/word/2003/wordml"
    
    When the report has a wage response
    And I download the hourly "doc" report
    Then I should see "schemas.microsoft.com/office/word/2003/wordml"
  
  Scenario: Download PDF
    Given I am logged in
    And I am participating in a "finished" survey
    And the survey has been invoiced
    When I am on the survey report page
    When I click "Pdf"
    Then I should see "PDF"
    
    When the report has a wage response
    And I download the hourly "pdf" report
    Then I should see "PDF"
