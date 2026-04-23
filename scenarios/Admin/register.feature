Feature: Vendor Store Registration
  As a new buyer on a Qawafel vendor store
  I want to register an account using my mobile number and OTP
  So that I can browse products and place orders

  Background:
    Given the vendor store "الواهب 2 الحلويات الشرقية" is open at "https://store.development.qawafel.dev/hint"
    And the user clicks "دخول / تسجيل"
    And the registration form is displayed


  # ──────────────── Positive Scenarios ────────────────

  @register @positive @smoke
  Scenario: Successful registration with valid mobile number
    When the user enters mobile number "555989805" in the registration form
    And the user submits the registration form
    Then an OTP verification screen should be displayed
    When the user enters a valid OTP "201111"
    Then the user should be registered and logged in
    And the user profile name should be visible in the header

  @register @positive
  Scenario: Complete registration form with all required fields
    Given the user enters mobile number "555989806" and verifies OTP "201111"
    When the user is on the company details form "بيانات الشركة"
    And the user fills in all required company fields with valid data
    And the user clicks "الخطوة التالية" to proceed to the legal info step
    Then the legal information form "المعلومات القانونية" should be displayed
    When the user fills in all required legal fields with valid data
    And the user uploads a VAT certificate file
    And the user clicks "إنشاء حساب" to submit
    Then the account should be created successfully
    And the confirmation message "طلبك قيد المراجعة الآن" should be displayed
    And the user should be redirected to the vendor store as a logged-in user


  # ──────────────── Negative Scenarios ────────────────

  @register @negative
  Scenario: Registration with empty mobile number
    When the user submits the registration form without entering a mobile number
    Then the "أنشئ الحساب" button should remain disabled

  @register @negative
  Scenario: Registration with invalid mobile number format
    When the user enters mobile number "12345" in the registration form
    Then the "أنشئ الحساب" button should remain disabled

  @register @negative
  Scenario: Registration with incorrect OTP
    When the user enters mobile number "555989807" in the registration form
    And the user submits the registration form
    And the user enters an incorrect OTP "000000"
    Then the error message "رمز التحقق غير صحيح" should be displayed
    And the user should remain on the OTP verification screen


  # ──────────────── Failed Registration Scenarios ────────────────

  @register @failed
  Scenario: Registration fails when submitting company form without filling required fields
    Given the user enters mobile number "555989806" and verifies OTP "201111"
    When the user is on the company details form "بيانات الشركة"
    And the user clicks "الخطوة التالية" without filling any required fields
    Then validation errors should be displayed on all required fields
    And the form should not advance to the next step

  @register @failed
  Scenario: Registration fails when commercial registration number is already in use
    Given the user enters mobile number "555989806" and verifies OTP "201111"
    When the user completes the company details form "بيانات الشركة" and proceeds
    And the user fills the legal info form with commercial registration number "1234567890" already used by another account
    And the user clicks "إنشاء حساب"
    Then an error message should indicate the commercial registration number is already in use
    And the account should not be created

  @register @failed
  Scenario: Registration fails when national address short code is already registered
    Given the user enters mobile number "555989806" and verifies OTP "201111"
    When the user completes the company details form "بيانات الشركة" and proceeds
    And the user fills the legal info form with national address code "MKHB2929" already registered
    And the user clicks "إنشاء حساب"
    Then an error message "قيمة short address مُستخدمة من قبل" should be displayed
    And the user should remain on the form to correct the address
