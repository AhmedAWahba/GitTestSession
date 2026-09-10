@notifications @notification-center @email-channel
Feature: Notification Email Delivery
  As a recipient who may not be signed in to Apex
  I want relevant notifications delivered by email
  So that I can act on them even when I'm not using the platform

  Background:
    Given a notification event has occurred that the catalog routes to email

  # Source: Linear ID-314 [NC-6] Notification Email Delivery; PRD Notification Center Section 2.

  # ──────────────── Validation scenarios ────────────────

  @email-channel @localization @validation
  Scenario Outline: Email body presents Arabic above English in the same message
    Given the email template is "<Template>"
    When the email is sent
    Then the Arabic wording should appear above the English wording in the same body

    Examples:
      | Template                              |
      | Verify your email address             |
      | Reset your password                   |
      | Your password was changed             |
      | Your business is verified             |
      | Invitation sent                       |
      | Invitation resent                     |
      | Role changed on a pending invitation  |
      | Invitation expiring soon              |
      | Role changed                          |

  @email-channel @copy @validation
  Scenario: Role-change email matches the approved wording exactly
    Given the user's role in "Al Nakheel" changed to "Admin"
    When the role-change email is sent
    Then the English body should read "Your role in Al Nakheel is now Admin. This change is already in effect. If you have a question about it, speak to the business."

  # ──────────────── Positive scenarios ────────────────

  @email-channel @smoke @positive
  Scenario: Email reaches an invited address that has no Apex account yet
    Given an email address with no existing Apex account is invited to a business
    When the invitation is sent
    Then an invitation email should be delivered to that address

  @email-channel @positive
  Scenario: Email is used for anything the person may need to keep
    Given a password recovery request is made for an existing account
    Then a password-recovery email should be delivered to the account's email address
