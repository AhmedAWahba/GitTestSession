@notifications @notification-center @payment-requests
Feature: Payment Request Notification Events
  As an Owner or Admin
  I want payment-request notifications to reflect the request's current standing
  So that I can act on the right thing without opening the request first

  Background:
    Given the user is signed in as "Owner"
    And the user is working in a business with a payment request

  # Source: Linear ID-310 [NC-2] Payment Event Notifier; PRD Notification Center NC-1.7.

  @payment-requests @scope @negative
  Scenario: A payment request notification is raised only from payment request events
    Given a credit note event occurs that is unrelated to any payment request
    Then no payment-request-style notification should be raised for that event

  # ──────────────── Positive scenarios ────────────────

  @payment-requests @status @positive @smoke
  Scenario Outline: Notification shows the payment request's current standing
    Given a payment request notification exists in status "<Status>"
    Then the notification should show the standing "<Status>"

    Examples:
      | Status    |
      | Payable   |
      | Paid      |
      | Expired   |
      | Cancelled |

  @payment-requests @navigation @positive
  Scenario: Opening the notification opens the correct payment request
    Given a payment request notification exists for request "PR-26-0003"
    When the user opens that notification
    Then the payment request detail page for "PR-26-0003" should open
