@prd2 @arb @payment-link
Feature: AlRajhi BNPL Payment via Payment Link
  As a buyer (guest or registered) receiving an APEX payment link
  I want to pay an invoice using AlRajhi BNPL when eligible
  So that the invoice is settled and both parties receive confirmation

  Background:
    Given a selling business has created an invoice with total amount "5000.00 SAR" for buyer "Acme Corp"
    And a payment link has been generated for the invoice with the following methods enabled:
      | Method       |
      | Credit Card  |
      | Apple Pay    |
      | SADAD        |
      | AlRajhi BNPL |
    And the payment link is in "Active" status

  # ---------------------------------------------------------------------------
  # Seller: Payment Link Creation Preconditions
  # ---------------------------------------------------------------------------

  @positive @seller @smoke
  Scenario: Seller creates an active payment link with AlRajhi BNPL enabled
    Given the selling business is logged in to APEX
    And the selling business has a "Sent" invoice with no active payment link
    When the selling business opens "Create Payment Request" for the invoice
    And the selling business selects "15 Days" as the link expiry
    And the selling business enables the following payment methods:
      | Method       |
      | Credit Card  |
      | Apple Pay    |
      | SADAD        |
      | AlRajhi BNPL |
    And the selling business submits the payment request
    Then a unique payment link is generated
    And the payment request status is "Active"

  @negative @seller
  Scenario: Seller cannot submit a payment request without selecting a link expiry
    Given the selling business is logged in to APEX
    And the selling business has a "Sent" invoice with no active payment link
    When the selling business opens "Create Payment Request" for the invoice
    And the selling business leaves the link expiry unselected
    And the selling business enables "Credit Card"
    And the selling business submits the payment request
    Then the payment request is not created
    And an inline validation error is displayed for the "Payment Link Expiration" field

  @negative @seller
  Scenario: Seller cannot submit a payment request without selecting a payment method
    Given the selling business is logged in to APEX
    And the selling business has a "Sent" invoice with no active payment link
    When the selling business opens "Create Payment Request" for the invoice
    And the selling business selects "7 Days" as the link expiry
    And the selling business leaves all payment methods unselected
    And the selling business submits the payment request
    Then the payment request is not created
    And an inline validation error is displayed with the message "Select at least one payment method."

  @negative @seller
  Scenario Outline: AlRajhi BNPL availability follows the configured minimum amount threshold
    Given the selling business is logged in to APEX
    And the selling business has a "Sent" invoice with total amount "<amount>"
    When the selling business opens "Create Payment Request" for the invoice
    Then "AlRajhi BNPL" is <availability> as a payment method option
    And <warning_assertion>

    Examples:
      | amount      | availability | warning_assertion                                          |
      | 1499.00 SAR | unavailable  | the warning message "Minimum amount for BNPL is SAR 1,500" is displayed |
      | 1500.00 SAR | available    | no warning message is displayed                            |

  # ---------------------------------------------------------------------------
  # Landing Page
  # ---------------------------------------------------------------------------

  @positive @guest
  Scenario: Guest buyer sees AlRajhi BNPL on the payment landing page
    Given the buyer is not logged in to APEX
    When the buyer opens the payment link
    Then the landing page displays the invoice summary
    And the payment method selection includes "AlRajhi BNPL"
    And the landing page status shows "Awaiting Payment"

  @positive @registered
  Scenario: Registered buyer sees pre-populated business name and AlRajhi BNPL on landing page
    Given the buyer is logged in to APEX as a registered buying business
    When the buyer opens the payment link
    Then the buyer's business name is pre-populated on the landing page
    And the payment method selection includes "AlRajhi BNPL"
    And the landing page status shows "Awaiting Payment"

  # ---------------------------------------------------------------------------
  # Successful Payment
  # ---------------------------------------------------------------------------

  @positive @smoke
  Scenario Outline: <buyer_type> buyer completes payment with AlRajhi BNPL successfully
    Given the buyer <login_precondition>
    And the buyer opens the payment link
    When the buyer selects "AlRajhi BNPL" as the payment method
    And the buyer passes the ARB eligibility check
    And the buyer accepts the ARB installment terms
    Then the Payment Success screen is displayed with:
      | Field             |
      | Seller Name       |
      | Invoice Number    |
      | Payment Reference |
      | Amount (SAR)      |
      | Payment Method    |
    And the payment method is shown as "AlRajhi BNPL"
    And a "Download Receipt" button is visible

    Examples:
      | buyer_type | login_precondition                                   |
      | Guest      | is not logged in to APEX                             |
      | Registered | is logged in to APEX as a registered buying business |

  # ---------------------------------------------------------------------------
  # Receipt and Status Updates
  # ---------------------------------------------------------------------------

  @positive @guest
  Scenario: Guest buyer downloads PDF receipt after successful AlRajhi BNPL payment
    Given the buyer is not logged in to APEX
    And the buyer has completed a successful AlRajhi BNPL payment on the payment link
    And the Payment Success screen is displayed
    When the buyer clicks "Download Receipt"
    Then a PDF is downloaded containing:
      | Field             |
      | Seller Name       |
      | Invoice Number    |
      | Payment Reference |
      | Amount (SAR)      |
      | Payment Method    |

  @positive
  Scenario Outline: Seller payment request updates to Paid after <buyer_type> buyer pays with AlRajhi BNPL
    Given the buyer <login_precondition>
    And the buyer completes a successful AlRajhi BNPL payment on the payment link
    When the selling business views their Created Payment Requests listing
    Then the corresponding payment request shows status "Paid"
    And the linked invoice shows status "Paid"

    Examples:
      | buyer_type | login_precondition                                   |
      | guest      | is not logged in to APEX                             |
      | registered | is logged in to APEX as a registered buying business |

  @positive @registered
  Scenario: Registered buyer AlRajhi BNPL payment appears in Received Payment Requests
    Given the buyer is logged in to APEX as a registered buying business
    And the buyer completes a successful AlRajhi BNPL payment on the payment link
    When the buyer navigates to their Received Payment Requests listing
    Then the payment appears with status "Paid"

  @positive @guest
  Scenario: Guest buyer AlRajhi BNPL payment does not appear in any Received Payment Requests list
    Given the buyer is not logged in to APEX
    And the buyer has completed a successful AlRajhi BNPL payment on the payment link
    Then the payment does not appear in any buyer Received Payment Requests list

  # ---------------------------------------------------------------------------
  # ARB Eligibility Rejection
  # ---------------------------------------------------------------------------

  @negative
  Scenario Outline: <buyer_type> buyer is rejected by ARB eligibility check
    Given the buyer <login_precondition>
    And the buyer opens the payment link
    When the buyer selects "AlRajhi BNPL" as the payment method
    And ARB returns an eligibility rejection
    Then the ARB payment attempt status shows "Failed"
    And the "Try Another Method" button is visible
    And "AlRajhi BNPL" is removed from the available payment methods for this session
    And the payment link remains in "Active" status
    And the following payment methods remain available:
      | Method      |
      | Credit Card |
      | Apple Pay   |
      | SADAD       |

    Examples:
      | buyer_type | login_precondition                                   |
      | Guest      | is not logged in to APEX                             |
      | Registered | is logged in to APEX as a registered buying business |

  # ---------------------------------------------------------------------------
  # Retry After ARB Rejection
  # ---------------------------------------------------------------------------

  @positive @guest
  Scenario: Guest buyer completes payment with a fallback method after ARB rejection
    Given the buyer is not logged in to APEX
    And the buyer opens the payment link
    And a previous AlRajhi BNPL attempt has been rejected on this link
    When the buyer clicks "Try Another Method"
    And the buyer selects "Credit Card" as the payment method
    And the buyer enters the following card details:
      | Field           | Value            |
      | Card Number     | 4111111111111111 |
      | Expiry Date     | 12/28            |
      | CVV             | 123              |
      | Cardholder Name | John Doe         |
    And the buyer submits the payment
    Then the Payment Success screen is displayed
    And the linked invoice shows status "Paid"

  @positive @registered
  Scenario: Registered buyer completes payment with a fallback method after ARB rejection
    Given the buyer is logged in to APEX as a registered buying business
    And the buyer opens the payment link
    And a previous AlRajhi BNPL attempt has been rejected on this link
    When the buyer clicks "Try Another Method"
    And the buyer selects "Credit Card" as the payment method
    And the buyer enters the following card details:
      | Field           | Value            |
      | Card Number     | 5500000000000004 |
      | Expiry Date     | 06/29            |
      | CVV             | 456              |
      | Cardholder Name | Jane Smith       |
    And the buyer submits the payment
    Then the Payment Success screen is displayed
    And the linked invoice shows status "Paid"

  @positive @guest
  Scenario: All payment methods remain visible after ARB rejection
    Given the buyer is not logged in to APEX
    And the buyer opens the payment link
    And a previous AlRajhi BNPL attempt has been rejected on this link
    When the buyer clicks "Try Another Method"
    Then all seller-enabled payment methods except "AlRajhi BNPL" are visible

  # ---------------------------------------------------------------------------
  # Link State
  # ---------------------------------------------------------------------------

  @negative
  Scenario Outline: <buyer_type> buyer attempts AlRajhi BNPL payment on an expired link
    Given the buyer <login_precondition>
    And the payment link has expired
    When the buyer opens the payment link
    Then the "Link Expired" screen is displayed
    And no payment methods or action buttons are shown

    Examples:
      | buyer_type | login_precondition                                   |
      | Guest      | is not logged in to APEX                             |
      | Registered | is logged in to APEX as a registered buying business |

  @negative @guest
  Scenario Outline: Buyer accesses a payment link in <link_status> status
    Given the payment link is in "<link_status>" status
    When the buyer opens the payment link
    Then the "<screen_title>" screen is displayed
    And no payment methods are shown

    Examples:
      | link_status | screen_title |
      | Paid        | Already Paid |
      | Cancelled   | Cancelled    |
