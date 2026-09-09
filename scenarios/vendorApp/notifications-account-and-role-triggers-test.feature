@notifications @nc4 @linear-id-312 @account-role-triggers
Feature: NC-4 Account and role notification triggers
  As any signed-in person
  I want notifications about my own account and role to reach me
  So that I know about changes regardless of my role or the business I'm working in

  Background:
    Given the user is signed in

  # ──────────────── Positive scenarios ────────────────

  @account-role-triggers @positive @smoke
  Scenario Outline: Own-account notifications reach every role
    Given the user's role is "<Role>"
    When an event affecting the user's own account occurs
    Then the user should receive a notification about it

    Examples:
      | Role   |
      | Owner  |
      | Admin  |
      | Member |

  @account-role-triggers @positive
  Scenario: Own-account notifications do not depend on the currently selected business
    Given the user is working in business "Al Rowad"
    When an event affecting the user's own account occurs
    Then the user should receive the notification regardless of which business is currently selected

  @account-role-triggers @positive @email
  Scenario: Role-change notification uses the approved bilingual wording when it takes effect
    Given the user's role in "Al Nakheel" changes from "Member" to "Admin"
    Then the user should receive the role-change email
    And the email body should present the Arabic wording above the English wording
    And the email should state the new role as "Admin"

  # ──────────────── Access and roles ────────────────

  @account-role-triggers @positive @role-based-access
  Scenario Outline: Owner and Admin receive business notifications for the business they are working in
    Given the user's role is "<Role>"
    When a business-level event occurs in the business the user is working in
    Then the user should receive that business notification

    Examples:
      | Role  |
      | Owner |
      | Admin |

  @account-role-triggers @negative @role-based-access @role-member
  Scenario: Member receives no business notifications
    Given the user's role is "Member"
    When a business-level event occurs in the business the user is working in
    Then the user should not receive a business notification for that event
    And opening the inbox should show the empty-state explanation

  # ──────────────── Open item ────────────────
  # Linear ID-312 [NC-4] scopes "the five account and role notifications" without
  # naming them. The PRD confirms the role-change email (Section 20.1) and the
  # prototype shows five account-settings confirmations (password changed, bank
  # account added, two-step verification turned on, phone number updated, email
  # address updated) plus separate membership events (role changed, member
  # removed). Which five the ticket refers to is unconfirmed — see open question
  # #4 in docs/prd-analysis/apex-notification-center-inbox-and-access-rules.md.

  @account-role-triggers @needs-clarification
  Scenario Outline: Candidate account-settings-change notifications observed in the prototype
    Given the following account setting changes
      | Change                        |
      | Password changed              |
      | Bank account added            |
      | Two-step verification enabled |
      | Phone number updated          |
      | Email address updated        |
    When "<Change>" occurs on the user's account
    Then the user should receive a notification for "<Change>"

    Examples:
      | Change                        |
      | Password changed              |
      | Bank account added            |
      | Two-step verification enabled |
      | Phone number updated          |
      | Email address updated        |
