# Android Build vs UAT Registration Comparison

**Assessment date:** 2026-09-13  
**Android artifact:** `builds/app.apk`  
**SHA-256:** `65FF1B5971EE7A00B5F0244E9131B743309B5C4A9FE67144007702FF32373526`

## Scope and Evidence

This assessment compares the supplied Android QA build evidence with the registration acceptance scenarios in `D:\Apex\Apex Project\quality-hub\scenarios\app\tests\business-registration-test.feature`.

Android evidence reviewed:

- `builds/qa-auth-flow/magic-values.md`
- `builds/qa-auth-flow/qa-auth-flow/14-signup-1-email-password.png`
- `builds/qa-auth-flow/qa-auth-flow/17-signup-2-email-otp.png`
- `builds/qa-auth-flow/qa-auth-flow/18-signup-3-mobile.png`
- `builds/qa-auth-flow/qa-auth-flow/20-signup-5-national-id-dob.png`
- `builds/qa-auth-flow/qa-auth-flow/21-signup-6-nafath-waiting.png`
- `builds/qa-auth-flow/qa-auth-flow/23-signup-7-business-details.png`
- `builds/qa-auth-flow/qa-auth-flow/24a-signup-7-business-filled.png`
- `builds/qa-auth-flow/qa-auth-flow/25-signup-8-bank-details.png`
- `builds/qa-auth-flow/qa-auth-flow/27-signup-8-bank-filled.png`

Merged comparison evidence created from live UAT and Android emulator captures:

- `builds/registration-mobile-web-vs-android-difference.png` - different identity-verification sequence and step count.
- `builds/registration-mobile-number-web-vs-android-difference.png` - full local mobile number on UAT versus a masked mobile number on Android.

Merged comparison evidence created from supplied QA build screenshots versus the actual Android APK:

- `builds/registration-password-policy-expected-vs-actual-difference.png` - supplied `15-signup-1-validation-error.png` presents an 8-character password warning; the actual APK shows a 12-character minimum and five separate rules. Relevant Ready-for-QC ticket: `ID-226`.
- `builds/registration-mobile-prefix-expected-vs-actual-difference.png` - supplied `18-signup-3-mobile.png` displays `05XXXXXXXX` within one field; the actual APK displays a separate `+966` prefix with a masked local number. Relevant Ready-for-QC ticket: `ID-227`.

## Result Summary

| Area | Result | Notes |
| --- | --- | --- |
| Account fields | Partial parity | Android renders Email, Password, Confirm Password. Password hint conflicts with the baseline. |
| Email OTP | Partial parity | Android renders six digits, resend countdown, and expiry timer. Its next step differs from the baseline. |
| Mobile | At risk | Android screenshot shows `05XXXXXXXX`; the baseline requires a read-only `+966` prefix. |
| Identity | Mismatch | Android displays DOB as `YYYY/MM/DD`; the baseline requires `DD/MM/YYYY`. |
| Nafath | Aligned visually | Android has a timed, 2-digit Nafath approval screen with explicit instructions. |
| Business details | Aligned | Android renders required UNN and VAT fields, plus optional TIN. No extra business field was found. |
| Bank details | Aligned | Android renders bank selection and IBAN; `Add later` makes the whole step optional. |

## Confirmed Differences

### P1: Date-of-birth format is reversed

- **Baseline:** the registration scenario requires `DD/MM/YYYY` regardless of device locale.
- **Android evidence:** the rendered date is `1996/09/13` in `20-signup-5-national-id-dob.png`, i.e. `YYYY/MM/DD`.
- **Impact:** a user following UAT/web guidance may enter an ambiguous or rejected date. This is a direct UI-format parity defect.
- **Recommendation:** change Android display, placeholder, parsing, and validation messaging to `DD/MM/YYYY`; add locale-independent automated coverage.

### P1: Password UI states an 8-character minimum instead of the required 12

- **Baseline:** all five password rules are required, including a minimum of 12 characters.
- **Android evidence:** `14-signup-1-email-password.png` presents the password placeholder as `8 characters minimum` (Arabic: `8 أحرف على الأقل`).
- **Impact:** the UI promises acceptance for passwords the baseline says must remain invalid. This may be a copy-only fault or a validation defect; it needs an on-device test with a valid 8-11 character password.
- **Recommendation:** make the Android hint and validator use 12 characters and expose the five-rule checklist required by the scenario.

### P1: Registration orchestration differs after email verification

- **Baseline:** after a correct email OTP, the user reaches **Sign in to continue** before Identity Verification.
- **Android evidence:** the documented fast path moves from Email OTP directly to Mobile Number, then Mobile OTP, National ID + DOB, and Nafath. No intermediate sign-in screen is represented in the QA screenshot pack.
- **Impact:** this changes authentication, navigation/back behavior, and the recovery route expected by the baseline.
- **Recommendation:** confirm the approved flow owner. If the UAT scenario is current, insert the intermediate sign-in state or revise the scenario and UAT together under a tracked product decision.

## Items Requiring Runtime Confirmation

| Item | Evidence | Required check |
| --- | --- | --- |
| `+966` country-code presentation | Android mobile screenshot visibly uses `05XXXXXXXX`, while the QA magic-values guide says `+966` is already present. | On a device, try editing/removing the prefix and verify the submitted canonical number. |
| Password enforcement | UI says eight characters; the supplied happy-path password is 12 characters. | Submit valid passwords at 8, 11, and 12 characters and capture the button/error state. |
| OTP error, resend, and lockout | QA guide documents deterministic codes and timers. | Exercise an incorrect code, five failures, three resends, expiry, and back navigation. |
| Business lookup and ownership errors | QA guide defines five UNN error values. | Run each value, confirm exact inline copy, loading state, rate-limit behavior, and no unintended navigation. |
| Bank optionality | Screenshot and guide show `Add later`. | Select it and verify registration completes with no bank record. |

## Fields Inventory

| Registration area | Android build | Baseline scenario | Assessment |
| --- | --- | --- | --- |
| Account | Email, Password, Confirm Password | Email, Password, Confirm Password | Same fields. |
| Mobile | Mobile number | Mobile number with fixed `+966` | Same core data; visible prefix differs. |
| Identity | National ID, Date of Birth | National ID / Iqama, Date of Birth | Same core fields; format differs. |
| Business | UNN, VAT Registration Number, optional TIN | UNN, VAT Registration Number, optional TIN | Exact field parity; no unnecessary field found. |
| Bank | Bank selector, IBAN; optional step | Optional bank-account step expected by supplied QA material | No unnecessary field found. |

## UAT and Linear Limitations

- UAT access was authenticated and the live flow was exercised through account creation, personal-details capture, email-link verification, the required intermediate sign-in, and Identity Verification Step 1. Mobile-code submission did not transition or return an inline validation result, which is consistent with the known unavailable mobile API. The flow cannot proceed to mobile OTP, Nafath, business, or bank registration until that API is available.
- Live UAT uses an email verification **link**, not a numeric email OTP. It collects Email, Password, Confirm Password, Mobile Number, National ID / Iqama, and Date of Birth before the email verification screen. After verification, it requires a sign-in before Identity Verification begins.
- `https://linear.app/qawafel/team/ID/cycle/active` is offline in the shared browser and locked to the **Notifications** project filter. The cached view contains no issue whose title includes `Android`; clearing the filter and workspace search cannot complete while offline. Android registration tasks could not be read or used as acceptance authority.
- `adb` is installed but no Android emulator/device is connected. The APK could not be installed or exercised interactively.
- The APK uses a fake in-app server according to `magic-values.md`; successful Android runtime outcomes do not prove UAT backend parity.

## Live UAT Validation Results

| Check | Result | Evidence |
| --- | --- | --- |
| Account creation | Passed | Unique valid email and a 12+ character password satisfying all five advertised rules created an account. |
| Personal details | Passed | UAT rendered and accepted Mobile Number, fixed `+966`, National ID / Iqama, and Date of Birth. |
| Date format | Failed against baseline | The native UAT date input rejected `13/09/1996` and required `1996-09-13`, contradicting the scenario requirement for `DD/MM/YYYY`. |
| Email verification | Passed | The email-link route changed to `Email verified` and exposed `Sign in to continue`. |
| Intermediate sign-in | Passed | Valid credentials routed to Identity Verification Step 1 of 6. |
| Mobile-code request | Blocked | Continue did not transition or show a validation result after normal and forced submission; mobile APIs are known unavailable. |

## Live Android Emulator Validation Results

**Device:** `copilot-api34` (`emulator-5554`)  
**Application:** `com.qawafel.apex.testing`  
**Data source:** deterministic in-app fake server, as documented in `builds/qa-auth-flow/magic-values.md`

| Check | Result | Android observation | UAT comparison |
| --- | --- | --- | --- |
| Application installation and launch | Passed | APK installed, app data was cleared, and the application rendered successfully in the API 34 emulator. | UAT is browser-rendered and reachable after Cloudflare authentication. |
| Account registration fields | Passed | Work email address, Password, Confirm password. | Same three credential fields in UAT. |
| Password policy | Passed | 12-character minimum, uppercase, lowercase, number, special character; matching values enable Continue. | Matches the live UAT five-rule policy. The previous 8-character screenshot finding is superseded by this tested APK. |
| Account progression | Passed | Valid `buyer@example.com` and matching `Qawafel1234-` values enable Continue and open a six-digit email-code screen. | UAT saves personal details before email verification and uses an emailed verification link. |
| Email verification | Passed in fake-server flow | Code `123456` advances the Android journey. The page displays a 3-minute expiry timer and 60-second resend cooldown. | UAT exposes email-link verification rather than an in-app numeric OTP. |
| Post-email sequence | Mismatch | Android transitions directly to Identity Verification, `Step 2 of 4`, Mobile number. | UAT requires `Sign in to continue`, then opens Identity Verification `Step 1 of 6`, Mobile number. |
| Mobile presentation | Aligned visually | Android displays fixed `+966` followed by a masked `5XXXXXXXX` value. | UAT displays fixed `+966` with the original mobile number preserved. |

## Ready-for-QC Scope Decision

Direct Linear inspection supersedes the earlier stale search result: `ID-227 [Android] - Registration (Account Setup) - Mobile Verification` is **Ready for QC** with **High** priority.

Its acceptance scope is Android-specific and explicitly states that mobile entry comes before identity capture, unlike web where mobile, National ID / Iqama, and Date of Birth are collected together. The Web-versus-Android sequence difference is therefore intentional for `ID-227`, not a ticket defect. Formal QC for this ticket must assess its own criteria: dedicated mobile entry, SMS-code transition, masked number at the OTP screen, correction action, preserved message allowance after returning, and progression to identity details.

## Re-evaluation Against Completed Registration Scenarios

The following results are based on the executed UAT and Android screens only. UAT mobile-code submission is unavailable, so no statement is made about later UAT mobile OTP, identity-details, Nafath, business-details, or bank-details behavior.

| Scenario expectation | UAT web result | Android result | Verdict |
| --- | --- | --- | --- |
| Empty account form has disabled Continue and a sign-in route | Not re-run after the authenticated account was created. | Initial Android account screen showed disabled Continue; the pre-existing-account route is available from login. | Android pass; UAT unverified in re-run. |
| All three valid account fields enable Continue | Passed with the live account. | Passed with `buyer@example.com` and matching compliant passwords. | Aligned. |
| Account creation leads to personal details | Passed: UAT next screen contains Mobile Number, National ID / Iqama, and Date of Birth. | Failed against scenario: Android next screen is a six-digit email-code screen. | Sequence mismatch. |
| Personal details are captured before email verification | Passed in UAT. | Failed against scenario: Android captures them after email-code verification. | Sequence mismatch. |
| Email verification is a six-digit OTP with a Verify button | Failed against UAT: verification is an emailed link. | Partial: Android uses a six-digit OTP, but has no Verify button; it automatically advances on digit six. | Both differ from scenario. |
| Fewer than six OTP digits keep verification pending | Not applicable in UAT link flow. | Passed functionally: five digits remain on the code screen; digit six advances. | Android behavior meets the outcome, but not the required button interaction. |
| Expired OTP disables input, clears stale value, and enables resend | Not applicable in UAT link flow. | Failed: Android shows expiry and enables Resend, but the input remains enabled and retains `123456`. | Android defect against shared OTP scenario. |
| Back from email OTP returns to personal details | Not applicable in UAT link flow. | Failed: Android explicit Back returns to Account setup, preserving the email. | Android sequence mismatch. |
| Intermediate sign-in after email verification | Passed: UAT verified email then required sign-in before identity verification. | Failed: Android advances straight from email code to mobile verification. | Major sequence mismatch. |
| Mobile entry uses fixed `+966` prefix | Passed: UAT shows fixed `+966` with editable local number. | Passed visually: Android shows fixed `+966` followed by masked `5XXXXXXXX`. | Both show prefix; editability cannot be compared at the same state. |
| Date of Birth accepts `DD/MM/YYYY` regardless of locale | Failed: UAT native date input rejected `13/09/1996` and accepted `1996-09-13`. | Not executed live because Android identity details follow unavailable later flow; historical screenshot evidence shows `YYYY/MM/DD`. | UAT defect against scenario; Android still requires live confirmation. |

## Current QC Eligibility Re-check

The active Sprint 2 cycle currently has **97** issues in **Ready for QC**. The rendered Ready-for-QC group confirms all Android registration tickets below are eligible and have **High** priority:

| Issue | Ready-for-QC scope | Priority |
| --- | --- | --- |
| `ID-224` | Registration - Shell and Step Progression | High |
| `ID-226` | Account Setup - Account Credentials and Email Verification | High |
| `ID-227` | Account Setup - Mobile Verification | High |
| `ID-228` | Identity Verification - Identity Details | High |
| `ID-229` | Identity Verification - Nafath | High |
| `ID-230` | Business Verification - Business Details | High |
| `ID-231` | Business Verification - Bank Details | High |

The other Ready-for-QC issues in Sprint 2 are outside this Android registration comparison. The earlier generic search status was stale and should not be used as release authority.

For `ID-227`, only the following acceptance evidence is currently confirmed by execution:

- Android has a dedicated mobile-number screen after its email-code flow.
- The mobile screen visibly displays a `+966` prefix and a masked destination number.
- The Android code screen uses a six-digit code and a resend countdown.

The ticket's required duplicate-mobile error, SMS-code transition from a manually entered number, correction action, message-allowance preservation, and successful progression to identity details have not yet been executed in this clean QC pass. They remain **not tested**, not passed or failed.

## Completion Criteria for a Live Parity Pass

1. Authenticate a test account to UAT and start a disposable registration.
2. Connect an emulator/device, install the APK, and reset app data before each path.
3. Execute the same valid and invalid data set on both targets, capturing each state.
4. Reconcile findings against the active Android Linear tickets after the workspace is online and registration-scoped.
5. Reclassify the remaining parity risks as confirmed or rejected with paired UAT and Android screenshots.