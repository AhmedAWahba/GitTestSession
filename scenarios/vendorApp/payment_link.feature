@payment-link
Feature: Generate Payment Link
  As a selling business user on the APEX platform
  I want to generate a payment link against a Sent invoice
  So that I can share it with my buyer and collect payment

  # ─────────────────────────────────────────────────────────────────────────
  # ❓ OPEN QUESTIONS — must be answered before executing these scenarios
  #
  # Q1: What is the staging base URL for the APEX platform?
  #     (e.g. https://apex.development.qawafel.dev — placeholder used below)
  #
  # Q2: What email + password should be used for the selling business test account?
  #     (APEX uses email/password login per PRD FR-1.1, not mobile/OTP)
  #
  # Q3: What email + password should be used for the buying business test account?
  #
  # Q4: What is the exact invoice number of a pre-existing "Sent" invoice in staging
  #     that has no active payment link (for positive tests)?
  #     (Placeholder: INV-26-000001 used below)
  #
  # Q5: After clicking "Create Payment Request", does the system show share options
  #     in the same modal (inline) or navigate to a new page/confirmation screen?
  #     (Figma shows share options inline in the modal — assumed below)
  #
  # Q6: What is the exact sidebar navigation label to reach Invoices?
  #     (Figma sidebar shows nav items — exact English label for "Invoices" section needed)
  # ─────────────────────────────────────────────────────────────────────────


  Background:
    Given I am on the APEX platform login page at "https://apex.development.qawafel.dev/login"
    And I log in with email "seller@test.com" and password "Test@1234"
    And I am redirected to the Invoice List page


  # ──────────────── Positive Scenarios ────────────────

  @positive @smoke
  Scenario: Generate payment link with Send Now and single payment method
    Given a "Sent" invoice "INV-26-000001" exists with no active payment link
    When I click the "Generate Payment Link" button on invoice "INV-26-000001"
    Then the "Create Payment Request" modal opens
    And the Invoice Details block displays the following read-only fields:
      | Field          |
      | Invoice No.    |
      | Email Address  |
      | Total Amount   |
      | Buyer Name     |
      | Phone Number   |
    And the Net Payable amount equals the invoice total amount
    When I select "Send Now" as the send timing
    And I select "7 Days" as the payment link expiration
    And I select "Credit Card" as the payment method
    And I click "Create Payment Request"
    Then a unique payment link is generated
    And the share options are displayed:
      | Option     |
      | Copy Link  |
      | WhatsApp   |
      | Email      |

  @positive
  Scenario: Generate payment link with Send Later scheduling
    Given a "Sent" invoice "INV-26-000002" exists with no active payment link
    When I click the "Generate Payment Link" button on invoice "INV-26-000002"
    Then the "Create Payment Request" modal opens
    When I select "Send Later" as the send timing
    Then a "Scheduled Date" picker and a "Scheduled Time" picker appear
    When I set the scheduled date to tomorrow's date
    And I set the scheduled time to "10:00 AM"
    And I select "30 Days" as the payment link expiration
    And I select "SADAD" as the payment method
    And I click "Create Payment Request"
    Then a unique payment link is generated
    And the payment request appears in the "Created Payment Requests" listing with send type "Send Later"
    And the payment request does NOT appear in the buyer's "Received Payment Requests" listing until the scheduled date

  @positive
  Scenario: Share a generated payment link via Copy Link
    Given a "Sent" invoice "INV-26-000003" exists with no active payment link
    When I click the "Generate Payment Link" button on invoice "INV-26-000003"
    And I select "Send Now" as the send timing
    And I select "15 Days" as the payment link expiration
    And I select "Apple Pay" as the payment method
    And I click "Create Payment Request"
    Then the share options are displayed
    When I click "Copy Link"
    Then the payment link URL is copied to the clipboard
    And the share event is logged with channel "copy" and a timestamp


  # ──────────────── Negative Scenarios ────────────────

  @negative
  Scenario: Submit Create Payment Request with no payment method selected
    Given a "Sent" invoice "INV-26-000004" exists with no active payment link
    When I click the "Generate Payment Link" button on invoice "INV-26-000004"
    And I select "Send Now" as the send timing
    And I select "7 Days" as the payment link expiration
    And I leave all payment method checkboxes unchecked
    And I click "Create Payment Request"
    Then the form is not submitted
    And I see an inline validation error "Select at least one payment method."

  @negative
  Scenario: Submit Create Payment Request with no expiry option selected
    Given a "Sent" invoice "INV-26-000005" exists with no active payment link
    When I click the "Generate Payment Link" button on invoice "INV-26-000005"
    And I select "Send Now" as the send timing
    And I leave the Payment Link Expiration unselected
    And I select "Credit Card" as the payment method
    And I click "Create Payment Request"
    Then the form is not submitted
    And I see an inline validation error on the "Payment Link Expiration" field

  @negative
  Scenario: Submit Create Payment Request with Send Later and a past date
    Given a "Sent" invoice "INV-26-000006" exists with no active payment link
    When I click the "Generate Payment Link" button on invoice "INV-26-000006"
    And I select "Send Later" as the send timing
    And I set the scheduled date to yesterday's date
    And I select "45 Days" as the payment link expiration
    And I select "AlRajhi BNPL" as the payment method
    And I click "Create Payment Request"
    Then the form is not submitted
    And I see an inline validation error on the "Scheduled Date" field indicating the date must be in the future
