@prd2 @payment-link @seller @preconditions
Feature: Seller Payment Link Preconditions for Buyer Execution
  As a seller creating a payment request
  I want valid payment-link setup rules enforced
  So that buyer-side payment execution starts from a reliable state

  Background:
    Given I am logged in as a seller user
    And I have a "Sent" invoice with no active payment link

  @smoke @success
  Scenario: Seller creates an active payment link with ARB enabled for eligible amount
    Given the invoice total amount is "SAR 5000"
    When I open "Create Payment Request" for the invoice
    And I select "Send Now"
    And I select "15 Days" as link expiry
    And I enable these payment methods:
      | Method         |
      | Credit Card    |
      | Apple Pay      |
      | SADAD          |
      | AlRajhi BNPL   |
    And I submit the payment request
    Then a unique payment link should be generated
    And the payment request status should be "Active"
    And buyer landing should show all configured methods including "AlRajhi BNPL"

  @validation
  Scenario: Seller cannot create payment request without expiry selection
    Given the invoice total amount is "SAR 5000"
    When I open "Create Payment Request" for the invoice
    And I select "Send Now"
    And I leave link expiry unselected
    And I enable "Credit Card"
    And I submit the payment request
    Then the payment request should not be created
    And I should see validation on "Payment Link Expiration"

  @validation
  Scenario: Seller cannot create payment request without selecting a payment method
    Given the invoice total amount is "SAR 5000"
    When I open "Create Payment Request" for the invoice
    And I select "Send Now"
    And I select "7 Days" as link expiry
    And I leave all payment methods unselected
    And I submit the payment request
    Then the payment request should not be created
    And I should see validation error "Select at least one payment method."

  @boundary
  Scenario Outline: ARB availability follows the configured minimum threshold
    Given the invoice total amount is "<amount>"
    When I open "Create Payment Request" for the invoice
    Then "AlRajhi BNPL" should be <availability>
    And the warning message should be "<warning>"

    Examples:
      | amount   | availability | warning                                 |
      | SAR 1499 | unavailable  | Minimum amount for BNPL is SAR 1,500    |
      | SAR 1500 | available    |                                         |
