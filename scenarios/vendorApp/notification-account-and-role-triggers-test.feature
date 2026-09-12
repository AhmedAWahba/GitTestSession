@notifications @notification-center @account-role-triggers
Feature: Account and Role Notification Triggers
  As any signed-in person
  I want notifications about my own account and role to reach me
  So that I know about changes regardless of my role or the business I'm working in

  Background:
    Given the user is signed in

  # Source: Linear ID-312 [NC-4] Account and Role Notification Triggers; PRD Notification Center NC-2.

  @account-role-triggers @role-based-access @negative @role-member
  Scenario: Member receives no business notifications
    Given the user's role is "Member"
    When a business-level event occurs in the business the user is working in
    Then the user should not receive a business notification for that event
    And opening the inbox should show the empty-state explanation

  # ──────────────── Validation scenarios ────────────────

  @account-role-triggers @catalog @validation
  Scenario Outline: Candidate account-settings-change notifications observed in the prototype
    Given the account setting change "<Change>" occurs on the user's account
    Then the user should receive a notification for "<Change>"

    Examples:
      | Change                         |
      | Password changed               |
      | Bank account added             |
      | Two-step verification enabled  |
      | Phone number updated           |
      | Email address updated         |
      | New device signed in           |

  # ──────────────── Positive scenarios ────────────────

  @account-role-triggers @smoke @positive
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

  @account-role-triggers @email @positive
  Scenario: Role-change notification uses the approved bilingual wording when it takes effect
    Given the user's role in "Al Nakheel" changes from "Member" to "Admin"
    Then the user should receive the role-change email
    And the email body should present the Arabic wording above the English wording
    And the email should state the new role as "Admin"

  @account-role-triggers @role-based-access @positive
  Scenario Outline: Owner and Admin receive business notifications for the business they are working in
    Given the user's role is "<Role>"
    When a business-level event occurs in the business the user is working in
    Then the user should receive that business notification

    Examples:
      | Role  |
      | Owner |
      | Admin |

  @account-role-triggers @membership @positive @smoke
  Scenario: A notification is raised when a person joins the business
    Given a new person joins the current business
    Then a notification stating that person joined the business should be raised
    And the notification should link to Users and roles

  @account-role-triggers @membership @positive
  Scenario: A notification is raised when a person no longer has access
    Given an active member's access to the current business ends
    Then a notification stating that person no longer has access should be raised
    And the notification should link to Users and roles
