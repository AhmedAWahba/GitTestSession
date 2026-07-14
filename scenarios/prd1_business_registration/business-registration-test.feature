@registration
Feature: Business Registration — Account Setup
  As a business owner
  I want to create a Qawafel account, verify my identity, and register my business
  So that I can access all platform features immediately upon verification

  Background:
    Given I am on the Qawafel registration page at "https://app.development.qawafel.dev/register"

  # ──────────────── Account Creation ────────────────

  @registration @positive @smoke
  Scenario: Successful account creation with valid credentials navigates to personal details
    Given I am on the account creation step
    When I fill the account creation form:
      | Field            | Value              |
      | Email Address    | owner@business.com |
      | Password         | Owner@123456789    |
      | Confirm Password | Owner@123456789    |
    And I click "Continue"
    Then I should be navigated to the personal and mobile details step

  @registration
  Scenario: Continue button is disabled when no fields are filled
    Given I am on the account creation step with no fields filled
    Then the "Continue" button should be disabled
    And a sign-in link should be visible for users who already have an account

  @registration
  Scenario: Continue button becomes enabled when all three fields contain valid values
    Given I am on the account creation step with no fields filled
    When I enter email "owner@business.com"
    And I enter password "Owner@123456789"
    And I enter confirm password "Owner@123456789"
    Then the "Continue" button should become enabled

  @registration
  Scenario: Continue button disables again if a required field is cleared after being valid
    Given I have filled all account creation fields with valid data
    When I clear the email address field
    Then the "Continue" button should become disabled

  # ──────────────── Password Complexity ────────────────

  @registration @negative
  Scenario Outline: Password checklist shows a grey cross for each failing rule
    Given I am on the account creation step with no fields filled
    When I enter password "<password>"
    Then the complexity rule "<rule>" should show a grey cross

    Examples:
      | password        | rule                           |
      | abcdefghijkl    | At least one uppercase letter  |
      | ABCDEFGHIJKL    | At least one lowercase letter  |
      | AbcdefghijkL    | At least one number            |
      | Abcdefghijk1    | At least one special character |
      | Ab@1            | Minimum 12 characters          |

  @registration @positive
  Scenario Outline: Password checklist shows a green tick once each rule is satisfied
    Given I am on the account creation step with no fields filled
    When I enter password "<password>"
    Then the complexity rule "<rule>" should show a green tick

    Examples:
      | password          | rule                           |
      | Owner@123456789   | At least one uppercase letter  |
      | owner@123456789   | At least one lowercase letter  |
      | Owner@ABCDEFGH1   | At least one number            |
      | Owner@abcdefgh1   | At least one special character |
      | Owner@12345678901 | Minimum 12 characters          |

  @registration @negative
  Scenario: Confirm Password mismatch shows inline error on blur and disables Continue
    Given I am on the account creation step with no fields filled
    When I enter password "Owner@123456789"
    And I enter confirm password "Different@123456789"
    And I move focus away from the Confirm Password field
    Then the inline error "Passwords do not match." should appear under the Confirm Password field
    And the "Continue" button should be disabled

  @registration @positive
  Scenario: Inline mismatch error clears when Confirm Password is corrected to match
    Given I have entered password "Owner@123456789"
    And I have entered "Different@123456789" in Confirm Password and moved focus away
    And the inline error "Passwords do not match." is visible under the Confirm Password field
    When I replace the Confirm Password value with "Owner@123456789"
    And I move focus away from the Confirm Password field
    Then the inline error "Passwords do not match." should disappear
    And the "Continue" button should become enabled

  @registration @negative
  Scenario: Duplicate email shows an inline error after Continue
    Given a Qawafel account already exists with email "existing@business.com"
    When I fill the account creation form with email "existing@business.com" and a valid password
    And I click "Continue"
    Then the inline error "An account with this email already exists. Sign in instead." should appear under the Email Address field
    And I should remain on the account creation step with all fields re-enabled

  # ──────────────── Password Show / Hide ────────────────

  @registration
  Scenario Outline: Show/hide toggle reveals the value of each password field
    Given I have entered a value in the "<field>" field
    When I activate the show/hide toggle on the "<field>" field
    Then the "<field>" value should be displayed in plain readable text

    Examples:
      | field            |
      | Password         |
      | Confirm Password |

  @registration
  Scenario Outline: Show/hide toggle re-obscures the value of each password field
    Given I have the "<field>" field showing in plain text
    When I activate the show/hide toggle on the "<field>" field again
    Then the "<field>" value should be obscured

    Examples:
      | field            |
      | Password         |
      | Confirm Password |

  # ──────────────── Personal & Mobile Details ────────────────

  @registration @positive @smoke
  Scenario: Valid personal and mobile details submission navigates to email OTP
    Given I have completed the account creation step and am on the personal details step
    And the registered email is displayed as read-only at the top of the screen
    When I fill the personal details form:
      | Field               | Value      |
      | Mobile Number       | 512345678  |
      | National ID / Iqama | 1000000001 |
      | Date of Birth       | 01/01/1985 |
    And I click "Continue"
    Then I should be navigated to the email OTP verification step

  @registration
  Scenario: Personal details step shows the registered email as read-only context
    Given I am on the personal details step
    Then the email I registered with should be displayed as read-only

  @registration @negative
  Scenario: Duplicate mobile number shows inline error after Continue
    Given a Qawafel account already exists with mobile number "501000001"
    And I am on the personal details step
    When I enter mobile number "501000001" with valid National ID and Date of Birth
    And I click "Continue"
    Then the inline error "This mobile number is already associated with a Qawafel account. Please sign in instead." should appear under the mobile number field
    And I should remain on the personal details step

  @registration
  Scenario: Back button on personal details returns to account creation with email preserved
    Given I am on the personal details step
    When I click "Back"
    Then I should be returned to the account creation step
    And the email I entered previously should still be visible in the Email Address field

  # ──────────────── Mobile Number Country Code ────────────────

  @registration
  Scenario Outline: Mobile Number field shows a read-only country code prefix on <step>
    Given I am on the <step>
    Then the "+966" country code prefix should be visible in the mobile number field
    And the country code prefix should be read-only and not editable

    Examples:
      | step                     |
      | personal details step    |
      | mobile confirmation step |

  # ──────────────── National ID / Iqama Validation ────────────────

  @registration @negative
  Scenario Outline: National ID / Iqama format validation rejects invalid values on <step>
    Given I am on the <step>
    When I enter "<value>" in the "National ID / Iqama" field
    And I move focus away from the field
    Then an inline format error should appear under the "National ID / Iqama" field
    And the "Continue" button should not be enabled

    Examples:
      | step                       | value       |
      | personal details step      | 3234567890  |
      | personal details step      | 123456789   |
      | personal details step      | 12345678901 |
      | personal details step      | 0000000001  |
      | identity confirmation step | 3000000001  |
      | identity confirmation step | 100000000   |
      | identity confirmation step | 10000000001 |

  @registration @positive
  Scenario Outline: National ID / Iqama validation accepts valid Saudi ID and Iqama numbers
    Given I am on the personal details step
    When I enter "<value>" in the "National ID / Iqama" field
    And I move focus away from the field
    Then no inline error should appear under the "National ID / Iqama" field

    Examples:
      | value      |
      | 1234567890 |
      | 2234567890 |

  # ──────────────── Email OTP Verification ────────────────

  @registration @positive @smoke
  Scenario: Correct email OTP advances to the sign-in step and confirms account creation
    Given I have completed the personal details step and am on the email OTP step
    And the registered email is shown as read-only above the OTP input
    And a countdown timer is visible
    When I enter the correct 6-digit OTP
    Then the heading "Sign in to continue" should be displayed
    And the message "Your email is verified. Please sign in to continue to identity verification." should be visible

  @registration
  Scenario: Verify button is disabled when fewer than 6 OTP digits are entered
    Given I am on the email OTP step with no digits entered
    When I enter 5 digits in the OTP input
    Then the verify button should be disabled

  @registration
  Scenario: Verify button becomes enabled when the 6th OTP digit is entered
    Given I am on the email OTP step
    And I have entered 5 digits in the OTP input
    When I enter the 6th digit
    Then the verify button should become enabled

  @registration
  Scenario: Back button on the email OTP step returns to personal details
    Given I am on the email OTP step
    When I click "Back"
    Then I should be returned to the personal details step

  # ──────────────── Sign In to Continue ────────────────

  @registration @positive @smoke
  Scenario: Successful sign-in after email verification navigates to identity verification
    Given I have verified my email and am on the "Sign in to continue" screen
    And the registered email is pre-filled as read-only
    And a forgotten password link is visible
    When I enter password "Owner@123456789" and click "Sign in"
    Then I should be navigated to the mobile number confirmation step
    And the identity verification phase heading should be visible

  @registration @negative
  Scenario: Incorrect password on sign-in after email verification shows a generic error
    Given I am on the "Sign in to continue" screen
    When I enter password "WrongPass@99" and click "Sign in"
    Then the inline error "Incorrect email or password. Please try again." should be displayed
    And I should remain on the "Sign in to continue" screen


@registration
Feature: Business Registration — Identity Verification
  As a business owner who has created an account
  I want to verify my mobile number and identity via Nafath
  So that my account can be linked to a verified legal identity

  Background:
    Given I am on the Qawafel platform at "https://app.development.qawafel.dev"
    And I have completed account setup and signed in to continue

  # ──────────────── Mobile Confirmation ────────────────

  @registration @positive @smoke
  Scenario: Valid mobile number confirmation sends an OTP and advances to mobile OTP step
    Given I am on the mobile number confirmation step
    When I confirm mobile number "512345678" and click "Continue"
    Then I should be navigated to the mobile OTP verification step

  @registration @negative
  Scenario: Duplicate mobile number shows inline error on the mobile confirmation step
    Given another Qawafel account is already registered with mobile "501000001"
    And I am on the mobile number confirmation step
    When I enter mobile "501000001" and click "Continue"
    Then the inline error "This mobile number is already associated with a Qawafel account. Please sign in instead." should appear under the mobile number field
    And I should remain on the mobile number confirmation step

  # ──────────────── Mobile OTP ────────────────

  @registration @positive @smoke
  Scenario: Correct mobile OTP advances to the identity confirmation step
    Given I am on the mobile OTP step
    And a 6-digit OTP has been sent to my registered mobile number
    And a countdown timer is visible
    When I enter the correct 6-digit OTP
    Then I should be navigated to the identity confirmation step

  @registration
  Scenario: Back button on the mobile OTP step returns to mobile number confirmation
    Given I am on the mobile OTP step
    When I click "Back"
    Then I should be returned to the mobile number confirmation step

  # ──────────────── Identity Confirmation ────────────────

  @registration @positive @smoke
  Scenario: Valid identity details advance to the Nafath verification step
    Given I am on the identity confirmation step
    When I fill the identity details:
      | Field               | Value      |
      | National ID / Iqama | 1000000001 |
      | Date of Birth       | 01/01/1985 |
    And I click "Continue"
    Then I should be navigated to the Nafath identity verification step

  @registration
  Scenario: Informational banner about document accuracy is visible on the identity confirmation step
    Given I am on the identity confirmation step
    Then the informational banner "Make sure all details match your official government documents exactly. Mismatches are the most common cause of verification delays." should be visible above the form fields

  # ──────────────── Nafath KYC ────────────────

  @registration @positive @smoke
  Scenario: Nafath approval shows a success message and advances to business verification
    Given I am on the Nafath identity verification step
    And a 2-digit challenge number is displayed
    And a countdown timer is visible
    And the option to open the Nafath app is visible
    When I approve the request in the Nafath app
    Then the message "Identity Verified Successfully" should be displayed
    And I should be navigated to the business details step

  @registration
  Scenario: Nafath challenge number is visible and cannot be selected or copied
    Given I am on the Nafath identity verification step
    Then a 2-digit number should be visible in the Nafath challenge area
    And the number should not be selectable or copyable from the screen

  @registration
  Scenario: Open Nafath App option opens the Nafath application on the device
    Given I am on the Nafath identity verification step
    When I activate the option to open the Nafath app
    Then the Nafath application should open on the device

  @registration @negative
  Scenario: Nafath rejection shows an error message and a retry option
    Given I am on the Nafath identity verification step
    When I reject the Nafath verification request in the Nafath app
    Then the error message "Verification Rejected. Please ensure you are scanning your own face in a well-lit area." should be displayed
    And all other screen elements should be non-interactive
    And a retry option should be visible

  @registration @positive
  Scenario: Retry after Nafath rejection generates a fresh challenge number and restarts the timer
    Given I am on the Nafath identity verification step
    And Nafath has returned a rejection for my verification attempt
    And the rejection error message is visible with a retry option
    When I activate the retry option
    Then a fresh 2-digit number should replace the previous one in the challenge area
    And the countdown timer should restart
    And the option to open the Nafath app should be visible

  @registration @negative
  Scenario: Nafath timeout shows a session expired message and a regenerate option
    Given I am on the Nafath identity verification step
    And the countdown timer has expired with no action taken in the Nafath app
    Then the challenge number should be shown in a disabled state
    And the message "Session Expired. For security, Nafath requests must be completed within 3 minutes." should be displayed
    And an option to regenerate the request should be visible

  @registration @positive
  Scenario: Regenerate Request after timeout produces a fresh challenge number and restarts the timer
    Given I am on the Nafath identity verification step
    And the session has expired with the expired message visible
    And the regenerate option is visible
    When I activate the regenerate option
    Then a fresh 2-digit number should appear in the challenge area
    And the countdown timer should restart
    And the option to open the Nafath app should be visible

  @registration @negative
  Scenario: Nafath API failure on load shows a service unavailable message with a retry option
    Given I have completed the identity confirmation step
    And the Nafath API is configured to return an initiation failure
    When the Nafath identity verification step loads
    Then the error "Nafath is temporarily unavailable. Please try again." should be displayed
    And a retry option should be visible to re-initiate the request
    And no challenge number should be shown

  @registration
  Scenario: Navigation back is not available after successful Nafath verification
    Given I have successfully completed Nafath verification
    When I attempt to navigate back using the browser or device back control
    Then I should remain on the business verification phase
    And no previous identity verification step should be displayed


@registration
Feature: Business Registration — Business Verification
  As a business owner with a verified identity
  I want to register my business UNN and optionally add an IBAN
  So that my business profile is complete and I can access the dashboard

  Background:
    Given I am on the Qawafel platform at "https://app.development.qawafel.dev"
    And I have completed identity verification

  # ──────────────── Business Details ────────────────

  @registration @positive @smoke
  Scenario: Clicking Continue on business details triggers the commercial registry check
    Given I am on the business details step
    When I fill the business registration form:
      | Field                         | Value           |
      | Unified National Number (UNN) | 7000000001      |
      | VAT Registration Number       | 300000000000003 |
    And I click "Continue"
    Then I should see a verification in-progress state
    And all form fields should not be editable while the check runs

  @registration @positive @smoke
  Scenario: Successful registry lookup populates the Arabic Legal Business Name as read-only
    Given I am on the business details step
    And I have entered UNN "7000000001" and VAT "300000000000003"
    And the commercial registry has returned a match for UNN "7000000001"
    Then the Arabic Legal Business Name field should be visible and not editable
    And the text "Retrieved from the commercial registry." should be shown below the Arabic Legal Business Name field
    And all other form fields should be re-enabled
    And the "Continue" button should be enabled

  @registration @positive @smoke
  Scenario: Successful business details submission navigates to the bank account step
    Given I am on the business details step
    And I enter UNN "7000000001" and VAT "300000000000003" and the registry returns a match
    When I click "Continue"
    Then I should be navigated to the bank account step
    And the heading "Bank account (optional)" should be visible

  @registration @positive
  Scenario: TIN field is optional and does not block Continue when left empty
    Given I am on the business details step and the Arabic Legal Business Name has been retrieved
    When I leave the TIN field empty and click "Continue"
    Then I should be navigated to the bank account step

  # ──────────────── UNN Format Validation ────────────────

  @registration @negative
  Scenario Outline: UNN format validation rejects invalid values
    Given I am on the business details step
    When I enter "<unn>" in the UNN field
    And I move focus away from the field
    Then an inline format error should appear under the UNN field
    And the "Continue" button should not be enabled

    Examples:
      | unn        |
      | 6000000001 |
      | 700000000  |
      | 70000000010|
      | 7ABCDEFGHI |
      | 8000000001 |

  # ──────────────── VAT Format Validation ────────────────

  @registration @negative
  Scenario Outline: VAT Registration Number format validation rejects invalid values
    Given I am on the business details step
    When I enter "<vat>" in the VAT Registration Number field
    And I move focus away from the field
    Then an inline format error should appear under the VAT Registration Number field
    And the "Continue" button should not be enabled

    Examples:
      | vat              |
      | 30000000000000   |
      | 3000000000000030 |
      | 200000000000003  |
      | 300000000000002  |
      | 400000000000004  |

  # ──────────────── UNN API Error States ────────────────

  @registration @negative
  Scenario: UNN already registered on Qawafel shows an inline error
    Given a Qawafel account is already registered with UNN "7100000001"
    And I am on the business details step
    When I enter UNN "7100000001" with valid VAT and click "Continue"
    Then the inline error "This UNN is already registered on Qawafel. Please sign in instead." should appear under the UNN field
    And I should remain on the business details step with fields re-enabled

  @registration @negative
  Scenario: UNN not found in the commercial registry shows an inline error
    Given the commercial registry returns no result for UNN "7999999999"
    And I am on the business details step
    When I enter UNN "7999999999" with valid VAT and click "Continue"
    Then the inline error "We couldn't find this UNN in the Saudi commercial registry. Please double-check the number." should appear under the UNN field
    And I should remain on the business details step with fields re-enabled

  @registration @negative
  Scenario: UNN associated with an inactive commercial registry record shows an inline error
    Given the commercial registry record for UNN "7888888881" is inactive
    And I am on the business details step
    When I enter UNN "7888888881" with valid VAT and click "Continue"
    Then an inline error should appear under the UNN field indicating the business record is inactive in the commercial registry
    And I should remain on the business details step with fields re-enabled

  @registration @negative
  Scenario: Verified identity does not match the registered CR owner shows an inline error
    Given the commercial registry for UNN "7777777771" is registered to a different owner
    And I am on the business details step
    When I enter UNN "7777777771" with valid VAT and click "Continue"
    Then an inline error should appear under the UNN field indicating the verified identity does not match the owner on the commercial registry record
    And I should remain on the business details step

  @registration @negative
  Scenario: Commercial registry service unavailable shows an inline error and allows retry
    Given the commercial registry API is temporarily unavailable
    And I am on the business details step
    When I enter a valid UNN with valid VAT and click "Continue"
    Then an inline error should appear indicating the verification service is temporarily unavailable
    And I should remain on the business details step with fields re-enabled

  # ──────────────── IBAN (Optional) ────────────────

  @registration @positive @smoke
  Scenario: Successful IBAN verification navigates to the registration confirmation screen
    Given I have completed the business details step and am on the bank account step
    When I select a supported bank from the Bank Name dropdown
    And I enter a valid Saudi IBAN
    And I click "Continue"
    Then I should be navigated to the Registration Confirmation Screen

  @registration @positive @smoke
  Scenario: Clicking Add Later skips IBAN entry and navigates to the confirmation screen
    Given I am on the bank account step
    When I click "Add Later"
    Then no IBAN data should be saved
    And I should be navigated to the Registration Confirmation Screen

  @registration
  Scenario: Bank Name dropdown is populated with supported Saudi banks
    Given I am on the bank account step
    Then the Bank Name dropdown should contain a list of supported Saudi banks
    And the dropdown should not be empty

  @registration
  Scenario: Add Later and Continue are both visible at all times on the bank account step
    Given I am on the bank account step
    Then the "Add Later" option and the "Continue" button should both be visible

  @registration @negative
  Scenario Outline: IBAN format validation rejects invalid formats
    Given I am on the bank account step
    When I enter "<iban>" in the IBAN field
    And I move focus away from the IBAN field
    Then an inline format error should appear under the IBAN field
    And the "Continue" button should remain disabled

    Examples:
      | iban                       |
      | SA038000000060801675       |
      | SA03800000006080101675190  |
      | GB0380000000608010167519   |
      | 0380000000608010167519     |
      | SA                         |

  @registration @negative
  Scenario: Continue is disabled when no bank is selected but an IBAN is entered
    Given I am on the bank account step
    When I enter a valid-format IBAN without selecting a bank
    Then the "Continue" button should remain disabled

  @registration @negative
  Scenario: Continue is disabled when a bank is selected but the IBAN field is empty
    Given I am on the bank account step
    When I select a bank without entering an IBAN
    Then the "Continue" button should remain disabled

  @registration @positive
  Scenario: Clicking Add Later after a partial IBAN entry saves no IBAN data
    Given I am on the bank account step
    And I have partially entered an IBAN
    When I click "Add Later"
    Then no IBAN data should be persisted to my account
    And I should be navigated to the Registration Confirmation Screen

  @registration @negative
  Scenario Outline: IBAN verification API failure shows an inline error
    Given the IBAN verification API returns a "<failure_reason>" result for the entered IBAN
    And I am on the bank account step
    When I select a bank and enter the IBAN and click "Continue"
    Then the inline error "We couldn't verify your IBAN. Please check your details and try again." should appear under the IBAN field
    And I should remain on the bank account step

    Examples:
      | failure_reason        |
      | not found             |
      | not linked to business|
      | service unavailable   |

  # ──────────────── Registration Confirmation ────────────────

  @registration @positive @smoke
  Scenario: Registration Confirmation Screen displays the correct content
    Given I have completed registration
    Then a success indicator should be visible
    And the heading "Your account is verified" should be displayed
    And the subtext "You can now access all platform features." should be visible
    And a "Go to Dashboard" button should be visible

  @registration @positive @smoke
  Scenario: Clicking Go to Dashboard navigates to the verified dashboard with all features accessible
    Given I am on the Registration Confirmation Screen
    When I click "Go to Dashboard"
    Then I should be navigated to the verified dashboard
    And all platform features should be immediately accessible

  @registration
  Scenario: No outbound notification is sent on registration completion
    Given I have just completed registration
    When the Registration Confirmation Screen is displayed
    Then no SMS should be sent to my registered mobile number
    And no confirmation email should be sent to my registered email address


@registration
Feature: OTP Verification — Shared Behaviour
  As a user on any OTP step in the registration or sign-in flow
  I want consistent OTP validation rules applied everywhere
  So that the experience is predictable regardless of which step I am on

  # Covers: email OTP · mobile OTP · sign-in OTP · forgot password OTP

  # ──────────────── OTP Entry Validation ────────────────

  @registration @negative
  Scenario Outline: Incorrect OTP shows an inline error and clears the input on <otp_step>
    Given I am on the <otp_step>
    When I enter incorrect OTP "000000" and submit
    Then the inline error "Incorrect code. Please try again." should be displayed
    And the OTP input field should be cleared
    And the countdown timer should continue from its current position

    Examples:
      | otp_step                   |
      | email OTP step             |
      | mobile OTP step            |
      | sign-in OTP screen         |
      | forgot password OTP screen |

  @registration
  Scenario Outline: Resend option shows a cooldown indicator and is not interactive on <otp_step>
    Given I am on the <otp_step>
    And an OTP has just been sent
    Then the resend option should show a remaining-time countdown
    And the resend option should not be interactive during the cooldown window

    Examples:
      | otp_step                   |
      | email OTP step             |
      | mobile OTP step            |
      | sign-in OTP screen         |
      | forgot password OTP screen |

  @registration @positive
  Scenario Outline: Resend option becomes active once the cooldown elapses on <otp_step>
    Given I am on the <otp_step>
    And the resend cooldown countdown has completed
    Then the resend option should be active and clickable

    Examples:
      | otp_step                   |
      | email OTP step             |
      | mobile OTP step            |
      | sign-in OTP screen         |
      | forgot password OTP screen |

  @registration @negative
  Scenario Outline: Resend option is disabled with a message after 3 resend attempts on <otp_step>
    Given I am on the <otp_step>
    And I have resent the OTP 3 times
    Then the resend option should be disabled
    And the message "Maximum resend attempts reached. Please wait for the current code to expire." should be shown

    Examples:
      | otp_step                   |
      | email OTP step             |
      | mobile OTP step            |
      | sign-in OTP screen         |
      | forgot password OTP screen |

  @registration @negative
  Scenario Outline: Expired OTP disables the input and shows an immediate resend option on <otp_step>
    Given I am on the <otp_step>
    And the OTP countdown timer has expired without a correct entry
    Then the OTP input field should be disabled
    And the message "Your code has expired." should be shown
    And the resend option should be immediately available

    Examples:
      | otp_step                   |
      | email OTP step             |
      | mobile OTP step            |
      | sign-in OTP screen         |
      | forgot password OTP screen |


@signin
Feature: Sign-In, Forgot Password & Multi-Business
  As a registered and verified business owner
  I want to sign in securely and manage multi-business access
  So that I can access the correct business context

  Background:
    Given I am on the Qawafel sign-in page at "https://app.development.qawafel.dev/login"

  # ──────────────── Sign-In ────────────────

  @signin @positive @smoke
  Scenario: Single-business user signs in with valid credentials and is sent a mobile OTP
    Given a verified single-business Qawafel account exists
    When I enter valid credentials and click "Sign in"
    Then a 6-digit OTP should be automatically sent to my registered mobile number
    And the OTP entry screen should be displayed

  @signin @positive @smoke
  Scenario: Single-business user enters the correct OTP and lands directly on the dashboard
    Given a verified single-business account has passed credential validation and I am on the OTP screen
    When I enter the correct OTP
    Then I should be navigated directly to the dashboard
    And no business selection screen should be shown

  @signin @positive @smoke
  Scenario: Multi-business user sees a business selection screen after OTP
    Given a verified Qawafel account with 2 or more registered businesses exists
    When I sign in with valid credentials and the correct OTP
    Then the business selection screen should be displayed
    And each business card should show only the Arabic Legal Business Name

  @signin @positive
  Scenario: Selecting a business on the selection screen loads the dashboard scoped to that business
    Given I am a verified multi-business user on the business selection screen
    When I select one business
    Then the dashboard should load scoped to that business
    And the selected business name should be shown in the navigation bar

  @signin
  Scenario: Sign-in screen offers only email and password authentication
    Given I am on the sign-in page
    Then only an email field and a password field should be present
    And no alternative sign-in methods should be visible
    And a forgotten password link should be visible
    And a link to create a new account should be visible

  @signin @negative
  Scenario: Incorrect credentials show a generic error without disclosing account existence
    Given I am on the sign-in page
    When I enter an incorrect email or password and click "Sign in"
    Then the inline error "Incorrect email or password. Please try again." should be displayed
    And the error should not indicate whether the email exists or the password is wrong

  # ──────────────── Forgot Password ────────────────

  @signin @positive @smoke
  Scenario: Valid identity details on the password recovery screen trigger a mobile OTP
    Given I am on the sign-in page
    When I click the forgotten password link
    And I fill the identity verification form:
      | Field                         | Value              |
      | National ID / Iqama           | 1000000001         |
      | Unified National Number (UNN) | 7000000001         |
      | Registered Email              | owner@business.com |
    And I submit the identity verification form
    Then a 6-digit OTP should be sent to the mobile number registered to that account
    And the OTP entry screen should be displayed

  @signin @positive
  Scenario: Correct OTP on the forgot password flow shows the password reset screen
    Given I am on the forgot password OTP screen
    And I have received a 6-digit OTP for password recovery
    When I enter the correct 6-digit OTP
    Then the password reset screen should be shown
    And a New Password field should be visible
    And a Confirm Password field should be visible
    And a password complexity checklist should be visible

  @signin @positive @smoke
  Scenario: New password saved on the reset screen shows a success message
    Given I am on the password reset screen in the forgot password flow
    When I enter new password "NewPass@123456789" and confirm password "NewPass@123456789"
    And I click "Next"
    Then the message "Your password has been updated successfully. You can now log in to your account and explore our services." should be displayed
    And an option to return to the sign-in screen should be visible

  @signin @positive
  Scenario: Returning to the sign-in screen from the password reset success screen works correctly
    Given I have successfully reset my password and the success message is visible
    When I activate the sign-in link
    Then the sign-in screen should be displayed

  @signin
  Scenario: Forgotten password link is visible on the sign-in screen
    Given I am on the sign-in page
    Then a forgotten password link should be visible

  @signin @negative
  Scenario: Invalid identity combination shows a generic error without disclosing account existence
    Given I am on the password recovery screen
    When I submit an identity combination that does not match any account
    Then the error "We couldn't verify those details. Please check and try again." should be displayed
    And no indication of whether an account exists should be disclosed

  @signin @negative
  Scenario: New password on the reset screen must satisfy all five complexity rules
    Given I am on the password reset screen in the forgot password flow
    When I enter a password that fails one or more complexity rules
    Then the submit button should remain disabled
    And the complexity checklist should show grey crosses for each failing rule

  # ──────────────── Multi-Business Switcher ────────────────

  @signin @positive
  Scenario: The in-session business switcher is accessible from the navigation bar
    Given I am a multi-business user signed in and on the dashboard
    Then the active business name should be visible in the navigation bar
    When I click the active business name in the navigation bar
    Then the business selection screen should open

  @signin @positive
  Scenario: Switching business in-session rescopes the dashboard without requiring sign-out
    Given I am a multi-business user signed in with one business as the active context
    When I open the switcher and select a different business
    Then the dashboard should reload scoped to the selected business
    And I should remain signed in

  @signin
  Scenario: Single-business users do not see the business selection screen or the switcher
    Given I am a verified single-business user who has just signed in
    Then the business selection screen should not be shown
    And the in-session business switcher should not be visible in the navigation bar


@registration
Feature: Verified Dashboard & Security
  As a verified business owner
  I want the dashboard to be immediately accessible and my account to be secure
  So that I can start using the platform without delay and my data stays protected

  Background:
    Given I am on the Qawafel platform at "https://app.development.qawafel.dev"

  # ──────────────── Dashboard State ────────────────

  @registration @positive @smoke
  Scenario: All platform features are accessible immediately on the first dashboard load
    Given I have completed registration and navigated to the dashboard
    Then all platform features should be accessible from the first page load
    And no lock indicators should be shown
    And no approval-pending or under-review messages should be visible

  @registration @positive
  Scenario: Verified dashboard shows a dismissible account verification status card
    Given I am on the verified dashboard for the first time
    Then a card indicating my account is verified should be visible
    When I dismiss the card
    Then the card should no longer be visible on the dashboard

  # ──────────────── Security ────────────────

  @registration @negative
  Scenario: Accessing the dashboard URL without being signed in redirects to sign-in
    Given I am not signed in
    When I navigate directly to the dashboard URL
    Then I should be redirected to the sign-in screen
    And no dashboard content should be visible

  @registration @negative
  Scenario: A signed-in user cannot access another business's data via URL manipulation
    Given I am signed in with my own business context
    When I manipulate the URL to reference another business's record
    Then access should be denied
    And I should not see any data belonging to the other business

  @registration @negative
  Scenario: Script injection in free-text registration fields is sanitised before storage
    Given I am on the business details step
    When I enter "<script>alert('xss')</script>" in the optional TIN field
    And I submit the form with otherwise valid data
    Then the script should not be executed in the browser
    And the stored TIN value should be sanitised or rejected

  @registration @negative
  Scenario: Concurrent registrations with the same email create only one account
    Given two sessions simultaneously attempt to register with the same email address
    When both sessions submit the account creation form at the same time
    Then only one account should be created for that email address
    And the second session should receive a duplicate email error

  @registration @negative
  Scenario: Concurrent registrations with the same UNN create only one business record
    Given two sessions simultaneously attempt to register with the same UNN
    When both sessions submit the business details form at the same time
    Then only one business registration should be created for that UNN
    And the second session should receive a duplicate UNN error

  @registration @negative
  Scenario: Sign-in is restricted after repeated failed credential attempts
    Given I am on the sign-in page
    When I submit incorrect credentials multiple consecutive times
    Then the sign-in form should show a restricted state preventing further immediate attempts
    And a message should communicate that access is temporarily limited

  # ──────────────── Localisation & RTL ────────────────

  @registration
  Scenario: Arabic Legal Business Name renders in the correct RTL direction on the dashboard
    Given I am a business owner whose business has an Arabic Legal Business Name
    When I land on the verified dashboard
    Then the Arabic name should be rendered in the correct RTL text direction in the navigation bar
    And English-language elements on the same screen should not be disrupted by the RTL text

  @signin
  Scenario: Business selection screen cards render Arabic names in RTL direction
    Given I am a multi-business user with businesses that have Arabic Legal Business Names
    When the business selection screen is displayed
    Then each business card should render the Arabic name in the correct RTL direction
    And the card layout should not be broken by RTL text

  @registration
  Scenario Outline: Date of Birth field enforces DD/MM/YYYY format regardless of device locale
    Given I am on the <step> on a device configured with a non-Saudi date locale
    When I interact with the Date of Birth field
    Then the field should accept and display dates in DD/MM/YYYY format
    And the field should not default to the device's native date format

    Examples:
      | step                       |
      | personal details step      |
      | identity confirmation step |
