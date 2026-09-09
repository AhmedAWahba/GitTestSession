@notifications @nc2 @linear-id-310 @payment-requests
Feature: NC-2 Payment request notification events
  As an Owner or Admin
  I want payment-request notifications to reflect the request's current standing
  So that I can act on the right thing without opening the request first

  Background:
    Given the user is signed in as "Owner"
    And the user is working in a business with a payment request

  # ──────────────── Positive scenarios ────────────────

  @payment-requests @positive @smoke
  Scenario Outline: Notification shows the payment request's current standing
    Given a payment request notification exists in status "<Status>"
    Then the notification should show the standing "<Status>"

    Examples:
      | Status    |
      | Payable   |
      | Paid      |
      | Expired   |
      | Cancelled |

  @payment-requests @positive @navigation
  Scenario: Opening the notification opens the correct payment request
    Given a payment request notification exists for request "PR-26-0003"
    When the user opens that notification
    Then the payment request detail page for "PR-26-0003" should open

  # ──────────────── Validation scenarios ────────────────

  @payment-requests @validation @scope
  Scenario: A payment request notification is raised only from payment request events
    Given a credit note event occurs that is unrelated to any payment request
    Then no payment-request-style notification should be raised for that event
