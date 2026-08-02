@business-partner @listing-actions
Feature: Business Partner Listing Flow and Row Actions
  As a verified Qawafel business owner
  I want to search, filter, sort, and manage business partner rows
  So that I can operate the list efficiently and manage partner status safely

  Background:
    Given the user is logged in as a verified X Trading business
    And the user is on the "Business Partners" page

  @listing @search @negative
  Scenario: Search shows an empty state when there are no matches
    When the user enters "NO_MATCH_ABC" in the list search input
    Then the empty result message should be "No business partners found. Try adjusting your search or filters."

  @listing @actions @negative
  Scenario: Actions menu does not allow deleting a business partner from listing
    Given a partner row with status "Active" is visible
    When the user opens the row "Actions" menu
    Then the menu should not contain "Delete"

  @listing @filter @negative
  Scenario: Verified filter excludes not-registered partners
    When the user selects "Verified on Qawafel" in the "Verification" filter
    Then all visible rows should show verification status "Verified on Qawafel"
    And no visible row should show "Not Registered on Qawafel"

  @listing @filter @negative
  Scenario: Not-registered filter excludes verified partners
    When the user selects "Not Registered on Qawafel" in the "Verification" filter
    Then all visible rows should show verification status "Not Registered on Qawafel"
    And no visible row should show "Verified on Qawafel"

  @listing @actions @edit @negative
  Scenario Outline: Edit partner blocks save when legal data format is invalid
    Given partner UNN "7001000001" is visible in the default active list
    When the user opens the row "Actions" menu for UNN "7001000001"
    And the user clicks "Edit Business Partner"
    And the user enters "<value>" in the "<field>" field
    And the user clicks "Save Changes"
    Then the edit form should not be submitted
    And the inline error "<message>" should appear on the "<field>" field

    Examples:
      | field                   | value      | message                                                                  |
      | VAT Registration Number | 12345      | Enter a valid VAT Registration Number - 15 digits, starting and ending with 3. |
      | ID Number               | CR-INVALID | Enter a valid identifier number for the selected ID type.                |

  @listing @actions @edit @negative
  Scenario: Edit partner blocks save when legal identifier already exists for another partner
    Given partner UNN "7001000001" is visible in the default active list
    And another partner already uses ID Number "CR-88991"
    When the user opens the row "Actions" menu for UNN "7001000001"
    And the user clicks "Edit Business Partner"
    And the user enters "CR-88991" in the "ID Number" field
    And the user clicks "Save Changes"
    Then the edit form should not be submitted
    And the inline error "This identifier is already used by another business partner." should appear on the "ID Number" field

  @listing @actions @state-change @negative
  Scenario: Active partner actions do not include Set Active
    Given partner UNN "7001000001" is visible in the default active list
    When the user opens the row "Actions" menu for UNN "7001000001"
    Then the menu should contain "Set Inactive"
    And the menu should not contain "Set Active"

  @listing @actions @state-change @negative
  Scenario: Inactive partner actions do not include Set Inactive
    Given partner UNN "7001000001" is visible in the "Inactive" status filter
    When the user opens the row "Actions" menu for UNN "7001000001"
    Then the menu should contain "Set Active"
    And the menu should not contain "Set Inactive"

  @listing @actions @state-change @negative
  Scenario: Cancelling Set Inactive keeps the partner in active status
    Given partner UNN "7001000001" is visible in the default active list
    When the user opens the row "Actions" menu for UNN "7001000001"
    And the user clicks "Set Inactive"
    And the user cancels the status change confirmation
    Then no status update confirmation should be shown
    And UNN "7001000001" should remain visible in the default active list

  @listing @actions @state-change @negative
  Scenario: Cancelling Set Active keeps the partner in inactive status
    Given partner UNN "7001000001" is visible in the "Inactive" status filter
    When the user opens the row "Actions" menu for UNN "7001000001"
    And the user clicks "Set Active"
    And the user cancels the status change confirmation
    Then no status update confirmation should be shown
    And UNN "7001000001" should remain visible in the "Inactive" status filter

  @listing @happy-path @actions @state-change
  Scenario: Manage a partner status end-to-end from active to inactive and back to active
    Given partner UNN "7001000001" is visible in the default active list
    When the user opens the row "Actions" menu for UNN "7001000001"
    Then the menu should contain "View Business Partner"
    And the menu should contain "Edit Business Partner"
    And the menu should contain "Set Inactive"
    When the user clicks "Set Inactive"
    Then a status update confirmation should be shown
    And UNN "7001000001" should not appear in the default active list
    When the user selects "Inactive" in the "Status" filter
    Then UNN "7001000001" should appear with status "Inactive"
    When the user opens the row "Actions" menu for UNN "7001000001"
    Then the menu should contain "Set Active"
    When the user clicks "Set Active"
    Then a status update confirmation should be shown
    And UNN "7001000001" should appear again in the default active list

  @listing @ui @positive
  Scenario: Business Partners listing screen shows search, filter, and sort controls
    Then the page title should be "Business Partners"
    And the subtitle should be "Manage your trading partners"
    And the search input "Search by business name or UNN..." should be visible
    And the "Status" filter should be visible with options "All Statuses", "Active", and "Inactive"
    And the "Verification" filter should be visible with options "All Verification", "Verified on Qawafel", and "Not Registered on Qawafel"
    And the "Business Name" column should display a sort indicator

  @listing @search @positive
  Scenario: Search filters the list by UNN
    When the user enters "7001000009" in the list search input
    Then only matching partner rows should remain visible
    And the visible result should include UNN "7001000009"

  @listing @filter @positive
  Scenario: Status filter shows inactive partners in inactive view
    Given at least one partner is in status "Inactive"
    When the user selects "Inactive" in the "Status" filter
    Then all visible rows should show status "Inactive"

  @listing @sort @positive
  Scenario: Business Name sort control is interactive
    When the user clicks the "Business Name" sort control
    Then the list should remain visible
    And the sort control should remain available for repeated clicks

  @listing @actions @positive
  Scenario: View action opens the selected business partner record
    Given partner UNN "7001000001" is visible in the default active list
    When the user opens the row "Actions" menu for UNN "7001000001"
    And the user clicks "View Business Partner"
    Then the user should be navigated to the Trading Partner Record detail view for UNN "7001000001"

  @listing @actions @positive
  Scenario: Edit action opens the selected business partner edit flow
    Given partner UNN "7001000001" is visible in the default active list
    When the user opens the row "Actions" menu for UNN "7001000001"
    And the user clicks "Edit Business Partner"
    Then the user should be navigated to the edit form for UNN "7001000001"
