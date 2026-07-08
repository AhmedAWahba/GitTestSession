@prd2 @payment-link @apple-pay
Feature: Apple Pay Payment Cycle from Payment Link
  As a buyer paying from an APEX payment link
  I want to complete or recover from Apple Pay outcomes
  So that payment status and records are always accurate

  Background:
    Given a seller has a "Sent" invoice with total amount "SAR 5000"
    And the seller generates a payment link with these enabled methods:
      | Method      |
      | Apple Pay   |
      | Credit Card |
      | SADAD       |
    And the payment link is in "Active" status
    And the payment landing page shows status "Awaiting Payment"

  @smoke @success @guest
  Scenario: Guest buyer completes payment successfully with Apple Pay
    Given I open the payment link as a guest buyer without logging in
    And I am using a device and browser that supports Apple Pay
    And Apple Pay is available in the payment methods list
    When I select "Apple Pay"
    And I confirm the payment in the Apple Pay authorization sheet
    Then the payment status should become "Paid"
    And I should see a payment success screen with:
      | Field             |
      | Seller Name       |
      | Invoice Number    |
      | Payment Reference |
      | Amount            |
      | Payment Method    |
    And the payment method should be shown as "Apple Pay"
    And the "Download Receipt" action should be available
    And the seller's created payment request should be updated to "Paid"
    And the linked invoice status should be updated to "Paid"
    And this payment should not appear in the "Received Payment Requests" list for any buyer account

  @success @registered-buyer
  Scenario: Registered buyer successful Apple Pay is visible in buyer records
    Given I am logged in as a registered buyer account
    And I am using a device and browser that supports Apple Pay
    And I open the payment link
    And Apple Pay is available in the payment methods list
    When I select "Apple Pay"
    And I confirm the payment in the Apple Pay authorization sheet
    Then the payment status should become "Paid"
    And the seller's created payment request should be updated to "Paid"
    And the linked invoice status should be updated to "Paid"
    And I navigate to "Received Payment Requests" in the buyer dashboard
    And the payment should appear in the list with status "Paid"

  @failure @device-eligibility
  Scenario: Apple Pay is unavailable on unsupported device or browser
    Given I open the payment link on a device or browser that does not support Apple Pay
    When the payment methods are displayed
    Then I should not see "Apple Pay" as a selectable method
    And these payment methods should remain available:
      | Method      |
      | Credit Card |
      | SADAD       |
    And the payment link should remain "Active" until expiry

  @failure @user-cancel
  Scenario: Buyer cancels Apple Pay authorization and can retry another method
    Given I open the payment link
    And I am using a device and browser that supports Apple Pay
    And Apple Pay is available in the payment methods list
    When I select "Apple Pay"
    And I cancel the Apple Pay sheet before authorization
    Then the payment status should remain "Awaiting Payment"
    And I should see a "Try Another Method" button on the payment page
    And these payment methods should remain available:
      | Method      |
      | Apple Pay   |
      | Credit Card |
      | SADAD       |

  @failure @gateway-error
  Scenario: Apple Pay authorization succeeds but gateway capture fails
    Given I open the payment link
    And I am using a device and browser that supports Apple Pay
    And Apple Pay is available in the payment methods list
    And the test environment is configured to simulate a gateway capture failure
    When I select "Apple Pay"
    And I confirm the payment in the Apple Pay authorization sheet
    Then the payment status should become "Failed"
    And I should see a visible payment failure message with a retry action on the payment page
    And the payment link should remain "Active" until expiry
    And the linked invoice status should remain "Sent"

  @failure @expired-link
  Scenario: Buyer cannot pay using Apple Pay after link expiry
    Given the payment link expiry time has passed
    When I refresh the payment link page
    Then I should see status "Link Expired"
    And I should not see any payment methods
    And I should not be able to submit any payment attempt

  @failure @idempotency
  Scenario: Duplicate Apple Pay submission does not create duplicate payment records
    Given I open the payment link
    And I am using a device and browser that supports Apple Pay
    And Apple Pay is available in the payment methods list
    And the test environment is configured to simulate a duplicate Apple Pay submission
    When the payment authorization is submitted twice for the same payment link
    Then only one payment reference should be created
    And the payment request status should be "Paid"
    And the linked invoice status should be updated to "Paid" exactly once

  @failure @method-config
  Scenario: Apple Pay is hidden when seller did not enable Apple Pay for the link
    Given a payment link exists with status "Active"
    And the payment link has payment methods configured without "Apple Pay"
    When I open the payment link
    Then I should not see "Apple Pay" as a selectable method

  @failure @status-validation
  Scenario Outline: Buyer cannot proceed with Apple Pay for restricted link statuses
    Given a payment link exists with status "<Status>"
    When I open the payment link
    Then the page should display the "<Status>" status
    And I should not see any payment methods
    And I should not be able to submit any payment attempt

    Examples:
      | Status    |
      | Cancelled |
      | Expired   |
      | Paid      |

  @failure @issuer-decline
  Scenario: Apple Pay authorization is declined by issuer
    Given I open the payment link
    And Apple Pay is available in the payment methods list
    When I select "Apple Pay"
    And I authorize payment in the Apple Pay sheet with a card that will be declined
    Then the payment status should become "Failed"
    And I should see a visible payment error message with a retry action
    And the payment link should remain "Active" until expiry

  @failure @network
  Scenario: Network interruption after Apple Pay authorization does not create duplicate results
    Given I open the payment link
    And Apple Pay is available in the payment methods list
    When I select "Apple Pay"
    And I authorize payment in the Apple Pay sheet
    And the network connection is interrupted before final confirmation
    Then the final payment status should be shown as unresolved or failed
    And I should not see duplicate success records
    And I should be able to safely retry or use another available method

  @positive @retry
  Scenario: Buyer can recover with another method after Apple Pay failure
    Given I open the payment link
    And a previous Apple Pay payment attempt has failed on this link
    When I click "Try Another Method"
    Then all remaining seller-enabled payment methods are available for selection

  @positive @browser-compatibility
  Scenario Outline: Apple Pay visibility matches browser and device support
    Given a payment link exists with status "Active"
    When I open the payment link using "<Browser>" on "<Device>"
    Then Apple Pay should be "<Visibility>" as a payment method

    Examples:
      | Browser       | Device  | Visibility  |
      | Safari        | macOS   | visible     |
      | Safari        | iPhone  | visible     |
      | Safari        | iPad    | visible     |
      | Google Chrome | macOS   | not visible |
      | Firefox       | macOS   | not visible |

  @positive @localization
  Scenario Outline: Core Apple Pay payment details render consistently across locales
    Given a payment link exists with status "Active"
    And the buyer locale is set to "<Locale>"
    When I open the payment link using Safari
    Then the invoice total and currency are clearly displayed
    And the "Apple Pay" payment method label is visible and readable

    Examples:
      | Locale |
      | en-US  |
      | ar-SA  |
