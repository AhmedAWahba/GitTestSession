@settings @st2 @business-profile @tin
Feature: Settings business profile tax identification number
  As an owner or admin
  I want to add a missing tax identification number once
  So that business tax identity is complete and immutable afterward

  Background:
    Given the user is signed in as "Owner"
    And the user opens the "Business profile" page from Settings

  # ──────────────── Negative scenarios ────────────────

  @business-profile @negative @immutability
  Scenario: Existing tax identification number cannot be changed
    Given the business already has tax identification number "1234567890"
    When the user attempts to edit the tax identification number
    Then no edit action should be available
    And the original tax identification number should remain unchanged

  # ──────────────── Validation scenarios ────────────────

  @business-profile @validation
  Scenario Outline: Tax identification number must be exactly 10 digits
    Given the business tax identification number is empty
    When the user enters "<TIN>"
    And the user saves the business profile section
    Then the value should not be saved
    And an inline validation error should be shown

    Examples:
      | TIN        |
      | 123456789  |
      | 12345678901|
      | 12A4567890 |

  # ──────────────── Positive scenarios ────────────────

  @business-profile @positive
  Scenario: Saved tax identification number is shown as read-only
    Given the business already has tax identification number "1234567890"
    Then the tax identification number value should be visible
    And no edit action should be available

  # ──────────────── Happy path scenarios ────────────────

  @business-profile @happy-path @positive
  Scenario: Owner can add tax identification number when missing
    Given the business tax identification number is empty
    When the user enters a valid 10-digit tax identification number
    And the user saves the business profile section
    Then the tax identification number should be saved
    And the saved value should be shown as read-only
