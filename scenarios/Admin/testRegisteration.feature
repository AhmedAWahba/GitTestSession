Feature: B2B Online Store Registration & Verification
  As a new buyer on a Qawafel vendor store
  I want to register an account, complete my business and legal info
  So that my account gets verified by the Qawafel admin and I can place orders

  Background:
    Given the vendor store is open at "https://store.development.qawafel.dev/hint"
    And the user clicks "دخول / تسجيل"


  # ══════════════════════════════════════════════════════════
  # POSITIVE SCENARIOS
  # ══════════════════════════════════════════════════════════

  @registration @positive @smoke @end-to-end
  Scenario: Complete successful registration flow from phone to verification popup
    When the user enters a new unregistered mobile number "5XX XXX XXX"
    And the user clicks "أنشئ الحساب"
    Then the OTP verification screen "أدخل رمز التحقق" is displayed
    When the user enters the valid 6-digit OTP received on the mobile
    And the user clicks "تأكيد"
    Then Step 1 of the registration form "بيانات الشركة" is displayed with progress "33%"
    When the user fills the following Step 1 fields with valid data:
      | Field                | Value                    |
      | الاسم الأول          | أحمد                     |
      | اسم العائلة          | وهبة                     |
      | البريد الإلكتروني    | test.new@example.com     |
      | اسم المتجر بالعربية  | مخبز الاختبار            |
      | اسم المتجر بالإنجليزية| Test Bakery             |
      | نوع المتجر           | مخبز                     |
      | المدينة              | الرياض                   |
      | الحي                 | الفيحاء                  |
      | اسم العنوان          | المخبز الرئيسي           |
    And the user clicks "الخطوة التالية"
    Then Step 2 of the registration form "المعلومات القانونية" is displayed with progress "100%"
    When the user fills the following Step 2 fields with valid data:
      | Field                            | Value               |
      | الاسم القانوني للشركة (بالعربية) | شركة الاختبار       |
      | نوع السجل التجاري/الرقم الموحد   | سجل تجاري           |
      | رقم السجل التجاري/الرقم الموحد   | 1234567891          |
    And the user uploads a valid CR certificate file (PDF, under 5MB)
    And the VAT toggle "هل النشاط التجاري خاضع للضريبة؟" is enabled
    And the user enters VAT number "3001234567890003"
    And the user uploads a valid VAT certificate file (PDF, under 5MB)
    And the user clicks "إنشاء الحساب"
    Then the success popup "طلبك قيد المراجعة الآن" is displayed
    And the popup message says "سيتم مراجعة بياناتك من قبل فريق قوافل وستتلقى تأكيداً خلال 24 ساعة بمجرد التحقق من حسابك وقبول طلب التوثيق"
    And the popup contains button "تصفح المنصة"
    When the user clicks "تصفح المنصة"
    Then the user is redirected to the vendor store as a logged-in unverified user

  @registration @positive @admin
  Scenario: Admin approves a pending registration request from the verification center
    Given a customer has completed the registration form and is in "pending" status
    And the Qawafel admin is logged in at "https://admin.development.qawafel.dev"
    When the admin navigates to the verification center "https://admin.development.qawafel.dev/verification-center/list"
    Then the pending registration request is listed
    When the admin opens the request and reviews the submitted legal information
    And the admin clicks "موافقة" to approve the request
    Then the request status changes to "approved"
    And the customer receives an SMS notification that their account is verified
    And the customer can now place orders on the vendor store

  @registration @positive
  Scenario: Existing user with incomplete registration completes verification via profile ribbon
    Given a registered user with mobile "5XX XXX XXX" has an incomplete registration
    When the user logs into the store using OTP
    Then a verification ribbon is visible on the profile page at "/hint/profile/orders"
    When the user clicks the verification ribbon
    Then the legal information modal "المعلومات القانونية" is displayed
    When the user fills all required legal fields and uploads required certificates
    And the user clicks "إنشاء الحساب"
    Then the popup "طلبك قيد المراجعة الآن" is displayed
    And the admin receives the updated verification request in the verification center

  @registration @positive
  Scenario: User without VAT registration completes registration as untaxable merchant
    Given the user has completed OTP verification and is on Step 2 "المعلومات القانونية"
    When the user fills the legal name and CR number with valid data
    And the user uploads a valid CR certificate
    And the VAT toggle "هل النشاط التجاري خاضع للضريبة؟" is disabled
    Then the VAT number field and VAT certificate upload area are hidden
    When the user clicks "إنشاء الحساب"
    Then the popup "طلبك قيد المراجعة الآن" is displayed
    And the user is tagged as an untaxable merchant in the system


  # ══════════════════════════════════════════════════════════
  # NEGATIVE SCENARIOS
  # ══════════════════════════════════════════════════════════

  @registration @negative
  Scenario: User dismisses the registration form after completing Step 1 and logs in again
    Given the user has entered a new mobile number and verified OTP
    And the user has completed Step 1 "بيانات الشركة" and clicked "الخطوة التالية"
    When the user closes/dismisses the registration drawer before completing Step 2
    And the user logs in again with the same mobile number and a valid OTP
    Then the registration form is shown again starting from Step 1 "بيانات الشركة"
    And no previously entered data is pre-filled

  @registration @negative
  Scenario: Registration fails when CR/UNN number is already used by another account
    Given the user has completed OTP verification and is on Step 2 "المعلومات القانونية"
    When the user fills the legal name with valid data
    And the user enters a CR/UNN number "1234567890" that is already registered by another account
    And the user uploads a valid CR certificate
    And the user clicks "إنشاء الحساب"
    Then an error message is displayed indicating the CR/UNN number is already in use
    And the account is not created

  @registration @negative
  Scenario: Registration fails when uploading an invalid file type as CR certificate
    Given the user has completed OTP verification and is on Step 2 "المعلومات القانونية"
    When the user attempts to upload a file with an unsupported format (e.g. .exe, .svg) as the CR certificate
    Then an error message is displayed rejecting the file type
    And the CR certificate upload area shows no accepted file
    And the user cannot proceed with "إنشاء الحساب"

  @registration @negative
  Scenario: Registration fails when uploading a CR certificate file that exceeds 5MB
    Given the user has completed OTP verification and is on Step 2 "المعلومات القانونية"
    When the user uploads a file larger than 5MB as the CR certificate
    Then an error message is displayed indicating the file exceeds the maximum allowed size
    And the CR certificate upload area shows no accepted file
    And the user cannot proceed with "إنشاء الحساب"

  @registration @negative @admin
  Scenario: Admin denies a registration request and user is prompted to resubmit
    Given a customer has completed registration and is in "pending" status
    And the Qawafel admin is logged in at "https://admin.development.qawafel.dev"
    When the admin navigates to "https://admin.development.qawafel.dev/verification-center/list"
    And the admin opens the pending request and clicks "رفض" to deny it
    Then the request status changes to "denied"
    And the customer sees a message on their profile indicating their account is not verified
    And the message includes instruction to update legal data and resubmit
    When the customer clicks the verification ribbon on "/hint/profile/orders"
    Then the legal information modal is shown with previously entered data
    When the customer updates the required fields and clicks "إنشاء الحساب"
    Then the request is resubmitted to the admin verification center

  @registration @negative @post-approval
  Scenario: A new user cannot register using a CR/UNN number belonging to an already approved account
    Given an existing account has been approved by admin with CR/UNN number "1234567890"
    When a different user completes OTP verification and navigates to Step 2 "المعلومات القانونية"
    And the user enters the same CR/UNN number "1234567890"
    And the user clicks "إنشاء الحساب"
    Then an error message is displayed indicating the CR/UNN number is already registered
    And the new account is not created
