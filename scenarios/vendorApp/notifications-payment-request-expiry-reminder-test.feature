@notifications @nc5 @linear-id-313 @expiry-reminder
Feature: NC-5 Payment request expiry reminder
  As a buying business
  I want to be reminded before a payment request expires
  So that I don't miss the window to pay it

  Background:
    Given the user is signed in as the buying business named on a payment request

  # ──────────────── Needs clarification ────────────────
  # Linear ID-313 [NC-5] scopes the reminder as firing three days before expiry.
  # The live design prototype's seeded sample notification instead reads
  # "expires tomorrow" (about one day before). See open question #3 in
  # docs/prd-analysis/apex-notification-center-inbox-and-access-rules.md.
  # Only one of the two Examples rows below should be correct once Product
  # confirms the threshold against the Notification Event Catalog.

  @expiry-reminder @needs-clarification @positive
  Scenario Outline: Reminder fires at the confirmed threshold before expiry
    Given a payment request is "Payable" and expires in "<DaysRemaining>" day(s)
    When the reminder check runs
    Then a reminder notification should be raised for that payment request

    Examples:
      | DaysRemaining | Source                                  |
      | 3             | Linear ID-313 [NC-5] ticket description  |
      | 1             | Live prototype seeded sample notification |

  # ──────────────── Negative scenarios ────────────────

  @expiry-reminder @negative
  Scenario Outline: No reminder is sent once the payment request is no longer payable
    Given a payment request is "<Status>" and would otherwise be within the reminder window
    When the reminder check runs
    Then no reminder notification should be raised for that payment request

    Examples:
      | Status    |
      | Paid      |
      | Cancelled |
      | Expired   |

  @expiry-reminder @negative
  Scenario: No duplicate reminder is sent for the same payment request
    Given a reminder notification has already been raised for a payment request
    When the reminder check runs again before the request's status changes
    Then no second reminder notification should be raised for that payment request
