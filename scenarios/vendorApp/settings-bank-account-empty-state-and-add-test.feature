@settings @st3 @bank-account @empty-state
Feature: Settings bank account empty state and add flow
  As an owner or admin
  I want to add a business bank account from Settings when none exists
  So that financing workflows can use verified payout details

  Background:
    Given the user is signed in as "Owner"
    And the user opens the "Bank account" page from Settings

  # ──────────────── Negative scenarios ────────────────

  @bank-account @negative @verification
  Scenario: Failed IBAN active check blocks saving
    Given the business has no saved bank account
    When the user enters a valid bank name and Saudi IBAN
    And the IBAN active check fails
    Then the bank account should not be saved
    And the user should be asked to check details and try again

  # ──────────────── Validation scenarios ────────────────

  @bank-account @validation
  Scenario Outline: Bank account cannot be saved with missing required data
    Given the business has no saved bank account
    When the user enters bank name "<BankName>"
    And the user enters iban "<IBAN>"
    And the user saves bank account details
    Then the account should not be saved
    And inline validation should be shown

    Examples:
      | BankName | IBAN                     |
      |          | SA1234567890123456789012 |
      | Al Rajhi |                          |

  @bank-account @validation
  Scenario: IBAN must be Saudi format SA plus 22 digits
    Given the business has no saved bank account
    When the user enters bank name "Al Rajhi"
    And the user enters iban "SA123"
    And the user saves bank account details
    Then the account should not be saved
    And an IBAN format error should be shown

  @bank-account @validation @copy
  Scenario: Failed IBAN check uses the same guidance text as onboarding
    Given the business has no saved bank account
    When the user enters a valid bank name and Saudi IBAN
    And the IBAN active check fails
    Then the failure message should match the onboarding IBAN-check failure wording

  # ──────────────── Positive scenarios ────────────────

  @bank-account @positive
  Scenario: Empty bank account state shows add action and explanatory text
    Given the business has no saved bank account
    Then an add bank account action should be visible
    And explanatory text for bank account usage should be visible

  # ──────────────── Happy path scenarios ────────────────

  @bank-account @happy-path @positive
  Scenario: Successful add saves one bank account for the current business
    Given the business has no saved bank account
    When the user enters a valid bank name and Saudi IBAN
    And the IBAN active check passes
    Then the bank account should be saved
    And the saved account should belong to the current business only
