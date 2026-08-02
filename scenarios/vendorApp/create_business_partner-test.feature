@business-partner @create-partner
Feature: Create Business Partner - Creation Flow
  As a verified Qawafel business owner
  I want to add a business partner by UNN
  So that I can manage private trading partner relationships on the platform

  Background:
    Given the user is logged in as a verified X Trading business
    And the user is on the "Business Partners" page

  # Validation scenarios

  @validation @ui @positive
  Scenario: Add Business Partner page opens with only the UNN field active
    When the user clicks "+ Add Business Partner"
    Then the "Add Business Partner" page should open
    And the "Business Identity" section should be visible
    And the "Contact Information" section should be visible
    And the "National Address" section should be visible
    And only the "Unified National Number (UNN)" field should be active on load
    And the "Check UNN" button should be enabled
    And the "Add Business Partner" button should be disabled
    And all other form fields should be unavailable

  @validation @input-format @negative
  Scenario Outline: Invalid UNN format shows an inline validation error and does not trigger lookup
    When the user clicks "+ Add Business Partner"
    And the user enters UNN "<unn>"
    And the user clicks "Check UNN"
    Then the inline error "Enter a valid Unified National Number - 10 digits, starting with 7." should appear beneath the UNN field
    And the form fields should remain unavailable

    Examples:
      | unn         |
      | 1234567890  |
      | 712345678   |
      | 71234567890 |
      | 712345678A  |

  @validation @save-validation @negative
  Scenario Outline: Save is blocked when a filled field fails format validation
    Given the user has opened the Add Business Partner page
    And the user has completed a successful UNN lookup for "7101000002"
    When the user enters "<value>" in the "<field>" field
    And the user moves focus away from the "<field>" field
    And the user clicks "Add Business Partner"
    Then the form should not be submitted
    And the inline error "<message>" should appear on the "<field>" field

    Examples:
      | field                   | value         | message                                                                  |
      | VAT Registration Number | 12345         | Enter a valid VAT Registration Number - 15 digits, starting and ending with 3. |
      | Email Address           | invalid-email | Enter a valid email address (e.g. name@company.com, name@gmail.com).    |
      | Phone Number            | 123456789     | Enter a valid 9 digits Saudi mobile number (e.g. +966 5XXXXXXXX).       |

  @validation @save-validation @negative
  Scenario: Save is blocked when Business Partner ID Type is selected without an ID Number
    Given the user has opened the Add Business Partner page
    And the user has completed a successful UNN lookup for "7101000002"
    When the user selects "Commercial Registration Number" in the "Business Partner ID Type" field
    And the user clicks "Add Business Partner"
    Then the form should not be submitted
    And the inline error "Enter the ID number for the selected identifier type." should appear on the "ID Number" field

  @validation @save-validation @negative
  Scenario: Save is blocked when ID Number is entered without a Business Partner ID Type
    Given the user has opened the Add Business Partner page
    And the user has completed a successful UNN lookup for "7101000002"
    When the user enters "CR-88991" in the "ID Number" field
    And the user clicks "Add Business Partner"
    Then the form should not be submitted
    And the inline error "Select an identifier type to match this number." should appear on the "Business Partner ID Type" field

  @validation @cta-state @positive
  Scenario: Add Business Partner button becomes enabled after a successful UNN lookup
    Given the user has opened the Add Business Partner page
    When the user enters UNN "7101000002"
    And the user clicks "Check UNN"
    Then the "Add Business Partner" button should be enabled

  @validation @cta-state @negative
  Scenario: Add Business Partner button remains disabled after a failed UNN lookup
    Given the user has opened the Add Business Partner page
    When the user enters UNN "1234567890"
    And the user clicks "Check UNN"
    Then the "Add Business Partner" button should be disabled

  @validation @state-reset @positive
  Scenario: Editing the UNN after a successful lookup resets the add form to its initial state
    Given the user has opened the Add Business Partner page
    And the user has completed a successful UNN lookup for "7101000001"
    When the user clears the UNN field
    Then all business partner form fields should reset
    And only the "Unified National Number (UNN)" field should remain active
    And the verification status badge should disappear
    And the "Check UNN" button should return to its pre-lookup state

  # Failed and blocked scenarios

  @failed-flow @lookup-block @negative
  Scenario: Adding X Trading's own business UNN is blocked
    When the user clicks "+ Add Business Partner"
    And the user enters UNN "7101000003"
    And the user clicks "Check UNN"
    Then the inline error "You cannot add your own business as a business partner." should appear beneath the UNN field
    And the form fields should remain unavailable

  @failed-flow @lookup-block @negative
  Scenario: Existing active business partner relationship blocks the add flow
    Given an active Trading Partner Relationship already exists for UNN "7101000004"
    When the user clicks "+ Add Business Partner"
    And the user enters UNN "7101000004"
    And the user clicks "Check UNN"
    Then the inline message "You've already added this business as a business partner." should appear
    And a "View" link should be shown in the message
    And the form fields should remain unavailable

  @failed-flow @lookup-block @negative
  Scenario: Existing inactive relationship blocks creating a new partner and shows a reactivate link
    Given an inactive Trading Partner Relationship already exists for UNN "7101000005"
    When the user clicks "+ Add Business Partner"
    And the user enters UNN "7101000005"
    And the user clicks "Check UNN"
    Then the inline message "This business is in your inactive business partners list." should appear
    And a "Reactivate" link should be shown in the message
    And the form fields should remain unavailable

  @failed-flow @lookup-block @negative
  Scenario: Unknown UNN in the Saudi commercial registry keeps the form locked
    When the user clicks "+ Add Business Partner"
    And the user enters UNN "7101000008"
    And the user clicks "Check UNN"
    Then the inline error "We couldn't find this UNN in the Saudi commercial registry. Please double-check the number." should appear beneath the UNN field
    And the form fields should remain unavailable

  @failed-flow @lookup-block @negative
  Scenario: Saudi commercial registry outage prevents adding a business partner
    When the user clicks "+ Add Business Partner"
    And the user enters UNN "7109999999"
    And the user clicks "Check UNN"
    Then the inline error "The Saudi commercial registry is temporarily unavailable. Please try again in a few moments." should appear beneath the UNN field
    And the form fields should remain unavailable

  @failed-flow @cancel @positive
  Scenario: Cancel before UNN lookup returns to Business Partners page without adding a partner
    Given the user has opened the Add Business Partner page
    When the user clicks "Cancel"
    Then the user should be navigated to the "Business Partners" page
    And no new business partner should be created

  @failed-flow @cancel @positive
  Scenario: Cancel after successful UNN lookup discards retrieved data and returns to Business Partners page
    Given the user has opened the Add Business Partner page
    And the user has completed a successful UNN lookup for "7101000002"
    When the user clicks "Cancel"
    Then the user should be navigated to the "Business Partners" page
    And no new business partner should be created

  # Happy path scenarios

  @happy-path @creation @smoke @positive
  Scenario: Add a verified Qawafel business partner with a successful UNN lookup
    Given no Trading Partner Relationship exists for UNN "7101000001"
    When the user clicks "+ Add Business Partner"
    Then the "Add Business Partner" page should open
    When the user enters UNN "7101000001"
    And the user clicks "Check UNN"
    And the form fields should become available
    And the verification status should show "Verified on Qawafel"
    And the "Legal Business Name (Arabic)" field should be populated and locked
    And the "VAT Registration Number" field should be populated and locked
    And all remaining fields should be editable and empty
    When the user fills the business partner form with the following details:
      | Field                         | Value               |
      | Legal Business Name (English) | Al Noor Trading LLC |
      | Commercial Name               | Al Noor Wholesale   |
      | Email Address                 | info@alnoor.sa      |
      | Phone Number                  | 512345678           |
      | City                          | Riyadh              |
    And the user clicks "Add Business Partner"
    Then the user should see the success toast "Business partner added successfully."
    And the user should be navigated to the Trading Partner Record detail view for UNN "7101000001"
    And the Trading Partner Record header should show verification status "Verified on Qawafel"

  @happy-path @creation @positive
  Scenario: Add a business partner found only in the Saudi commercial registry
    Given no Trading Partner Relationship exists for UNN "7101000002"
    When the user clicks "+ Add Business Partner"
    And the user enters UNN "7101000002"
    And the user clicks "Check UNN"
    Then the verification status should show "Not Registered on Qawafel"
    And the "Legal Business Name (Arabic)" field should be populated from the Saudi commercial registry and locked
    And the source label "Retrieved from the Saudi commercial registry" should be shown beneath the field
    And the "VAT Registration Number" field should remain editable
    When the user fills the business partner form with the following details:
      | Field                         | Value               |
      | Legal Business Name (English) | Cedar Gulf Supplies |
      | Commercial Name               | Cedar Gulf          |
      | VAT Registration Number       | 300111222333003     |
      | Email Address                 | contact@cedar.sa    |
      | Phone Number                  | 501234567           |
    And the user clicks "Add Business Partner"
    Then the user should see the success toast "Business partner added successfully."
    And the user should be navigated to the Trading Partner Record detail view for UNN "7101000002"
    And the Trading Partner Record header should show verification status "Not Registered on Qawafel"

  @happy-path @creation @discrepancy @positive
  Scenario: Saving a verified partner with conflicting data flags a discrepancy after creation
    Given no Trading Partner Relationship exists for UNN "7001000006"
    When the user clicks "+ Add Business Partner"
    And the user enters UNN "7001000006"
    And the user clicks "Check UNN"
    And the verification status should show "Verified on Qawafel"
    And the user enters "Conflicting English Name" in the "Legal Business Name (English)" field
    And the user clicks "Add Business Partner"
    Then the user should see the success toast "Business partner added successfully."
    And the user should be navigated to the Trading Partner Record detail view for UNN "7001000006"
    And the amber discrepancy banner should show "Data mismatch detected. The information you entered does not match this business's verified profile on Qawafel. Please review and update your records."
    And a "Review" call to action should be visible