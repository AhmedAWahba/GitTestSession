@settings @st5 @profile
Feature: Settings profile reference-only fields and role coverage
  As a signed-in user
  I want my profile details to be visible as reference-only data
  So that account identity information is consistent and protected

  Background:
    Given the user is signed in
    And the user opens the "Profile" page from Settings

  # ──────────────── Validation scenarios ────────────────

  @profile @validation @ui
  Scenario: Profile shows the required personal and account fields
    Then the "Full name" field should be visible
    And the "National ID or Iqama" field should be visible
    And the "Date of birth" field should be visible
    And the "Email address" field should be visible
    And the "Mobile number" field should be visible

  @profile @validation @read-only
  Scenario: Profile fields are reference-only and not editable
    Then no edit action should be available for "Full name"
    And no edit action should be available for "National ID or Iqama"
    And no edit action should be available for "Date of birth"
    And no edit action should be available for "Email address"
    And no edit action should be available for "Mobile number"

  # ──────────────── Positive scenarios ────────────────

  @profile @positive @role-owner @role-admin @role-member
  Scenario Outline: Profile is available to every role
    Given the user is signed in as "<Role>"
    When the user opens the "Profile" page from Settings
    Then the profile page should open
    And the profile information should be shown in the same structure

    Examples:
      | Role   |
      | Owner  |
      | Admin  |
      | Member |
