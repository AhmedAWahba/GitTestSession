@prd2 @payment-link @arb @registered-buyer
Feature: Registered Buyer Payment Cycle with AlRajhi BNPL
  As a logged-in registered buyer
  I want to pay from a payment link using AlRajhi BNPL
  So that my successful payment is linked to my buyer account

  Background:
    Given a seller has a "Sent" invoice with total amount "SAR 5000"
    And the seller generates a payment link with these enabled methods:
      | Method         |
      | Credit Card    |
      | Apple Pay      |
      | SADAD          |
      | AlRajhi BNPL   |
    And the payment link is in "Active" status
    And I am logged in as a registered buyer account
    And I open the payment link

  @success
  Scenario: Logged-in buyer completes payment with AlRajhi BNPL
    Given the payment landing page shows status "Awaiting Payment"
    And my buyer business name is pre-populated on the payment page
    When I select "AlRajhi BNPL"
    And I pass the ARB eligibility check
    And I accept the ARB installment terms
    Then the payment status should become "Paid"
    And I should see the "Download Receipt" action
    And the seller's created payment request should be updated to "Paid"
    And the linked invoice status should be updated to "Paid"
    And the payment should appear in my "Received Payment Requests" list with status "Paid"

  @failure
  Scenario: Logged-in buyer ARB rejection keeps link payable with other methods
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
    And the payment link should remain "Active" until expiry

  @failure
  Scenario: Logged-in buyer cannot pay when the link is expired
    Given the payment link expiry time has passed
    When I refresh the payment link page
    Then I should see status "Link Expired"
    And I should not see any payment methods
    And I should not see a payment retry action
    And I should not be able to submit any payment attempt
