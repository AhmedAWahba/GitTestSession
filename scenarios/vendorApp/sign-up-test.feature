Feature: Sign-Up End-to-End Onboarding
  Verify the full onboarding flow: account creation, business details, and personal details.

  # ── Step 1: Account Creation (Happy Path) ──

  @smoke
  Scenario: Create account with valid credentials
    Given user opens the "Sign Up" page
    When user fills the sign-up form:
      | Field            | Value               |
      | Email            | newuser@example.com |
      | Password         | TestPassword@123    |
      | Confirm Password | TestPassword@123    |
    And user clicks on "Create Account" button
    Then user should be redirected to "Business Details" page

  # ── Step 2: Business Details ──

  @smoke
  Scenario Outline: Submit business details with taxable customer <taxable_state>
    Given user has created an account with email "newuser@example.com" and is on the "Business Details" page
    And the Country field is preselected as "Saudi Arabia" and disabled
    When user fills the business details form:
      | Field              | Value              |
      | Legal Company Name | شركة اختبار        |
      | Identifier Type    | <identifier_type>  |
      | Customer Taxable   | <taxable_state>    |
      | Tax Number         | <tax_number>       |
      | City               | Makkah             |
      | District           | Al Haram           |
      | Street Name        | شارع الملك فهد     |
      | Building Number    | 1234               |
      | Additional Number  | 5678               |
      | Postal Code        | 21955              |
      | Short Address      | 1234ABCD           |
    And user clicks on "Continue" button
    Then <tax_field_assertion>
    And user should be redirected to "Personal Details" page

    Examples:
      | taxable_state | identifier_type | tax_number      | tax_field_assertion                   |
      | Enabled       | CR              | 310000000000003 | Tax Number field should be enabled    |
      | Disabled      | Unified Number  |                 | Tax Number field should be disabled   |

  # ── Step 3: Personal Details ──

  @smoke
  Scenario: Submit personal details and complete onboarding
    Given user has completed business details and is on the "Personal Details" page
    And the Email field is prefilled with the registered account email and is disabled
    When user fills the personal details form:
      | Field        | Value         |
      | First Name   | Mohamed       |
      | Last Name    | Hamed         |
      | Phone Number | +966512345678 |
    And user clicks on "Submit" button
    Then the system should display success message "Registration completed successfully"
    And user should be redirected to "Invoice List Page"

  # ── Validation: Step 1 ──

  @validation
  Scenario Outline: Sign-up form shows inline validation error for invalid input
    Given user opens the "Sign Up" page
    When user fills the sign-up form:
      | Field | Value   |
      | Email | <email> |
    And user enters password "<password>"
    And user moves focus away from the "<field>" field
    Then inline validation error "<error_message>" should appear under the "<field>" field
    And "Create Account" button should remain disabled

    Examples:
      | field    | email               | password     | error_message                                                          |
      | Email    | testexample.com     |              | Please enter a valid email address                                     |
      | Password | newuser@example.com | Test@123     | Password must be at least 12 characters and include uppercase, lowercase, number, and special character |

  @validation
  Scenario: Sign-up form enables "Create Account" button after correcting invalid data
    Given user opens the "Sign Up" page
    And user has entered an invalid email "testexample.com"
    When user corrects the email to "newuser@example.com"
    And user enters password "TestPassword@123"
    And user enters Confirm Password "TestPassword@123"
    Then "Create Account" button should become enabled

  # ── Validation: Step 2 ──

  @validation
  Scenario: Business details form shows required field errors when submitted empty
    Given user has created an account with email "newuser@example.com" and is on the "Business Details" page
    When user submits the business details form without filling any mandatory fields
    Then inline required field validation messages should appear for all mandatory fields
    And "Continue" button should remain disabled

  # ── Validation: Step 3 ──

  @validation
  Scenario: Personal details form shows phone validation error for invalid format
    Given user has completed business details and is on the "Personal Details" page
    When user enters phone number "123456" in the Phone Number field
    Then inline validation error "Invalid Saudi phone number" should appear under the Phone Number field
    And "Submit" button should remain disabled

  # ── UI: Step 1 ──

  @ui
  Scenario: Create Account button is disabled on initial page load
    Given user opens the "Sign Up" page
    Then "Create Account" button should be disabled

  @ui
  Scenario: Create Account button becomes enabled when all fields are valid
    Given user opens the "Sign Up" page
    When user fills the sign-up form:
      | Field            | Value               |
      | Email            | newuser@example.com |
      | Password         | TestPassword@123    |
      | Confirm Password | TestPassword@123    |
    Then "Create Account" button should become enabled

  @ui
  Scenario: Password visibility toggle shows and hides password text
    Given user opens the "Sign Up" page
    And user enters password "TestPassword@123" in the Password field
    When user clicks the password visibility toggle
    Then the password value should be visible in plain text
    When user clicks the password visibility toggle again
    Then the password value should be masked

  # ── UI: Step 2 ──

  @ui
  Scenario: Business Details page shows correct progress bar and header
    Given user has created an account with email "newuser@example.com" and is on the "Business Details" page
    Then progress bar should display "50%"
    And page title should be "Business Details"
    And subtitle should be "Let's add your business details to setup your account."
    And the Country field should be preselected as "Saudi Arabia" and disabled

  # ── UI: Step 3 ──

  @ui
  Scenario: Personal Details page shows prefilled email and correct placeholders
    Given user has completed business details and is on the "Personal Details" page
    Then Email field should be prefilled with the registered account email and disabled
    And First Name field should display placeholder "Enter first name"
    And Last Name field should display placeholder "Enter last name"
    And Phone Number field should display placeholder "+9665XXXXXXXX"

  @ui
  Scenario: Submit button becomes enabled when all personal details are valid
    Given user has completed business details and is on the "Personal Details" page
    When user fills the personal details form:
      | Field        | Value         |
      | First Name   | Mohamed       |
      | Last Name    | Hamed         |
      | Phone Number | +966512345678 |
    Then "Submit" button should become enabled

  # ── Post-Registration: Email Verification ──

  @email-verification @localhost
  Scenario: Verify account email via dev localhost mailbox
    Given user has completed onboarding and is awaiting email verification
    And user is not logged in
    When user opens the dev mailbox at "http://localhost:4000/dev/mailbox" using the following credentials:
      | Field    | Value |
      | Username | admin |
      | Password | admin |
    Then a verification email addressed to the registered account email should be listed
    When user navigates directly to the verification link from that email
    Then user should be redirected to the "Sign In" page
    And a flash message "Email verified. You can sign in now." should be displayed

  @email-verification @uat
  Scenario: Verify account email via UAT mailbox
    Given user has completed onboarding and is awaiting email verification
    And user is not logged in
    When user opens the dev mailbox at "https://apex.qawafel.dev/dev/mailbox/0dccaf38039443d53b3d5ad2fdd42642" using the following credentials:
      | Field    | Value                                                              |
      | Username | c3c282c6f7634212019870307029f7bb945a7e178f644a2fe71d87ab7ea71934 |
      | Password | fa3c9b1a6149456ce85bf9f07bebd8c0b4556d8cfa9af7e7796d0b9794326c01 |
    Then a verification email addressed to the registered account email should be listed
    When user navigates directly to the verification link from that email
    Then user should be redirected to the "Sign In" page
    And a flash message "Email verified. You can sign in now." should be displayed

