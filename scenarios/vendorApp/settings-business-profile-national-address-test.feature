@settings @st2 @business-profile @national-address
Feature: Settings business profile national address field rules
  As an owner or admin
  I want the national address section to follow the PRD data model
  So that only the allowed address fields are captured

  Background:
    Given the user is signed in as "Admin"
    And the user opens the "Business profile" page from Settings

  # ──────────────── Validation scenarios ────────────────

  @business-profile @validation @national-address
  Scenario: National address section contains the expected fields
    Then the national address section should show "Country"
    And the national address section should show "Address line"
    And the national address section should show "City"
    And the national address section should show "District"
    And the national address section should show "Street name"
    And the national address section should show "Building number"
    And the national address section should show "Additional number"
    And the national address section should show "Postal code"
    And the national address section should show "Short address"

  @business-profile @validation @national-address
  Scenario: Country is fixed to Saudi Arabia and cannot be edited
    Then the "Country" field value should be "Saudi Arabia"
    And the "Country" field should be read-only

  # ──────────────── Positive scenarios ────────────────

  @business-profile @positive @national-address
  Scenario: Other address fields are optional
    Given the national address section is open in edit mode
    When the user leaves one or more optional fields empty
    And the user saves the address section
    Then the address should be saved successfully
