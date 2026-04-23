Feature: End-to-End B2B Registration, Admin Approval & Account Verification
  As a new buyer on a Qawafel vendor store
  I want to register, have my account approved by the admin
  So that my account status changes from "pending" to "verified" and I can place orders

  @e2e @registration @admin @verification
  Scenario: Complete end-to-end flow — registration, admin approval, user verification check

    # ── Phase 1: User Registration ──────────────────────────────────────────

    Given the vendor store is open at "https://store.development.qawafel.dev/hint"
    And the user clicks "دخول / تسجيل"
    When the user enters a new unregistered mobile number
    And the user clicks "أنشئ الحساب"
    Then the OTP verification screen "أدخل رمز التحقق" is displayed
    When the user enters the valid 6-digit OTP
    And the user clicks "تأكيد"
    Then Step 1 of the registration form "بيانات الشركة" is displayed
    When the user fills Step 1 with valid company and address data
    And the user clicks "الخطوة التالية"
    Then Step 2 of the registration form "المعلومات القانونية" is displayed
    When the user fills Step 2 with legal name, CR number, CR certificate, VAT number and VAT certificate
    And the user clicks "إنشاء الحساب"
    Then the success popup "طلبك قيد المراجعة الآن" is displayed
    And the popup contains button "تصفح المنصة"
    When the user clicks "تصفح المنصة"
    Then the user is redirected to the vendor store as a logged-in unverified user

    # ── Phase 2: Admin Approves the Verification Request ───────────────────

    Given the Qawafel admin is logged in at "https://admin.development.qawafel.dev"
    When the admin navigates to the verification center "https://admin.development.qawafel.dev/verification-center/list"
    Then the newly registered shop "Test Bakery" appears with status "Pending"
    When the admin opens the request and reviews the submitted legal information
    And the admin clicks "Verify Retailer" to approve the request
    And the admin confirms the approval in the confirmation dialog
    Then a success toast "Verification Accepted Successfully" is shown
    And the request state changes to "Accepted"

    # ── Phase 3: User Verifies Account Status ──────────────────────────────

    Given the same vendor store is open at "https://store.development.qawafel.dev/hint"
    When the user logs in again with the same mobile number and OTP
    Then the user is redirected to the vendor store as a logged-in user
    And the account verification status is no longer showing an unverified ribbon
    And the user account reflects a verified state
