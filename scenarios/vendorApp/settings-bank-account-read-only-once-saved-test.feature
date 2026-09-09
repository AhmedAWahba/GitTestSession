@settings @st3 @bank-account @read-only
Feature: Settings bank account read-only once saved
  As an owner or admin
  I want a saved bank account to be reference-only in Settings
  So that account details are not changed or removed from this flow

  Background:
    Given the user is signed in as "Admin"
    And the user opens the "Bank account" page from Settings

  # ──────────────── Negative scenarios ────────────────

  @bank-account @negative
  Scenario: User cannot add a second bank account
    Given the business already has a saved bank account
    When the user checks available bank account actions
    Then no add-second-account action should be visible

  # ──────────────── Validation scenarios ────────────────

  @bank-account @validation @read-only
  Scenario: Saved bank account is shown with no edit or remove actions
    Given the business already has a saved bank account
    Then the bank name should be visible
    And the iban should be visible
    And no edit action should be visible
    And no remove action should be visible

  # ──────────────── Positive scenarios ────────────────

  @bank-account @positive
  Scenario: Bank account is business-scoped for multi-business users
    Given the signed-in user has access to business "Al Nakheel"
    And the signed-in user has access to business "Al Rowad"
    And "Al Nakheel" has a saved bank account
    And "Al Rowad" has no saved bank account
    When the user switches active business to "Al Rowad"
    Then the "Al Nakheel" bank account should not be visible
    And the empty bank account state should be shown for "Al Rowad"
