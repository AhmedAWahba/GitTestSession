Feature: End-to-End B2B Registration & Approval
  As a new buyer on a Qawafel vendor store
  I want to register and have my account approved by the admin
  So that I can proceed to ordering products

  Background:
    Given the vendor store is open at "https://store.development.qawafel.dev/hint"

  @e2e @registration
  Scenario: New user registers on vendor store
    Given the user initiates registration via "دخول / تسجيل"
    When the user registers with a new mobile number
    And the user verifies their mobile with the 6-digit OTP
    Then Step 1 of the registration form "بيانات الشركة" is displayed
    When the user submits company and address details:
      | Field        | Value        |
      | Company Name | Test Bakery  |
      | Address      | Riyadh, KSA  |
    And the user submits legal information:
      | Field           | Value            |
      | Legal Name      | Test Bakery LLC  |
      | CR Number       | 1010000000       |
      | VAT Number      | 300000000000003  |
    Then the success popup "طلبك قيد المراجعة الآن" is displayed
    And the user is redirected to the store as a logged-in unverified user
    And the shop registration can be approved in [approve_verification.feature](approve_verification.feature)

