@prd2 @payment-link @arb @guest
Feature: Guest Buyer Payment Cycle with AlRajhi BNPL
  As a guest buyer receiving an APEX payment link
  I want to pay using AlRajhi BNPL when eligible
  So that the invoice is settled without creating an account

  Background:
    Given a seller has a "Sent" invoice with total amount "SAR 5000"
    And the seller generates a payment link with these enabled methods:
      | Method         |
      | Credit Card    |
      | Apple Pay      |
      | SADAD          |
      | AlRajhi BNPL   |
    And the payment link is in "Active" status
    And I open the payment link as a guest buyer without logging in

  @smoke @success
  Scenario: Guest buyer completes payment with AlRajhi BNPL
    Given the payment landing page shows status "Awaiting Payment"
    And AlRajhi BNPL is available in the payment methods list
    When I select "AlRajhi BNPL"
    And I pass the ARB eligibility check
    And I accept the ARB installment terms
    Then the payment status should become "Paid"
    And I should see a payment success screen with:
      | Field               |
      | Seller Name         |
      | Invoice Number      |
      | Payment Reference   |
      | Amount              |
      | Payment Method      |
    And the payment method should be shown as "AlRajhi BNPL"
    And the "Download Receipt" action should be available
    And the seller's created payment request should be updated to "Paid"
    And the linked invoice status should be updated to "Paid"
    And this payment should not appear in any buyer received requests list

  @failure
  Scenario: Guest buyer is rejected by ARB and completes payment with another method
    Given the payment landing page shows status "Awaiting Payment"
    When I select "AlRajhi BNPL"
    And ARB returns an eligibility rejection
    Then the payment status should become "Failed"
    And I should see the call to action "Try Another Method"
    And "AlRajhi BNPL" should be removed from available methods for this session
    And these payment methods should remain available:
      | Method       |
      | Credit Card  |
      | Apple Pay    |
      | SADAD        |
    When I select "Credit Card"
    And I complete payment successfully
    Then the payment status should become "Paid"
    And the seller's created payment request should be updated to "Paid"
    And the linked invoice status should be updated to "Paid"
