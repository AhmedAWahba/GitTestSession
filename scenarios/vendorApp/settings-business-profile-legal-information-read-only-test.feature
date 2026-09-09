@settings @st2 @business-profile @read-only
Feature: Settings business profile legal information read-only
  As an owner or admin
  I want verified legal fields to be read-only in Settings
  So that legal identity values are protected from accidental edits

  Background:
    Given the user is signed in as "Owner"
    And the user opens the "Business profile" page from Settings

  # ──────────────── Negative scenarios ────────────────

  @business-profile @negative @navigation
  Scenario: No alternate settings route allows editing verified legal fields
    When the user checks available actions on the Business profile page
    Then no edit action should be available for verified legal fields
    And no settings route should allow changing verified legal values

  @business-profile @negative @logo
  Scenario: Replacing the logo keeps only the new logo
    Given the business has an existing logo
    When the user uploads a replacement logo image
    Then only the replacement logo should be visible
    And the previous logo should not be visible

  @business-profile @negative @logo
  Scenario: Removing a logo leaves the business with no logo
    Given the business has an existing logo
    When the user removes the business logo
    Then no logo should be visible for the business

  # ──────────────── Validation scenarios ────────────────

  @business-profile @validation @read-only
  Scenario: Legal information is displayed and cannot be edited
    Then the "Business legal name" field should be visible and read-only
    And the "Unified National Number" field should be visible and read-only
    And the "CR number" field should be visible and read-only
    And the "VAT registration number" field should be visible and read-only

  @business-profile @validation @ui
  Scenario: Tax identification number field is visible in business profile legal information
    Then the "Tax identification number" field should be visible

  @business-profile @validation @logo
  Scenario: Uploading a logo applies immediately with no separate save action
    Given the business has no existing logo
    When the user uploads a valid logo image
    Then the new logo should be visible immediately
    And no separate save action should be required

  @business-profile @validation @logo
  Scenario: Logo changes apply to future documents only
    Given a document was issued before a logo change
    And the business has an existing logo
    When the user replaces or removes the business logo
    Then documents issued before the change should keep their previous logo state
    And documents issued after the change should use the latest logo state

  @business-profile @validation @ui
  Scenario: Business profile screen shows held address and held logo together
    Given the business has an existing national address
    And the business has an existing logo
    When the user opens the "Business profile" page from Settings
    Then the national address values should be visible
    And the business logo should be visible
