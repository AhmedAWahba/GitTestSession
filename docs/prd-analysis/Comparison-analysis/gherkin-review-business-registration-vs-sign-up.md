# Gherkin Comparison Report: business-registration-test vs sign-up-test

## 1. Files Compared
- `scenarios/prd1_business_registration/business-registration-test.feature`
- `D:/APEX/quality-hub/scenarios/app/tests/sign-up-test.feature`

## 2. Executive Summary
These two files describe the same broad domain, user registration and onboarding, but they represent materially different generations of requirements.

`sign-up-test.feature` models a comparatively simple onboarding journey built around three UI steps: account creation, business details, and personal details, followed by external email verification. In contrast, `business-registration-test.feature` models a much richer product with multiple feature blocks covering account setup, OTP behavior, mobile confirmation, Nafath identity verification, business verification through the commercial registry, optional bank-account verification, sign-in, forgot password, multi-business behavior, dashboard security, concurrency, and localization.

At the requirement level, the shift is from a linear sign-up wizard to a regulated, identity-backed business registration platform with stronger validation, more external dependencies, more post-registration behaviors, and more security rules.

## 3. Feature-Level Differences
| Area | `sign-up-test.feature` | `business-registration-test.feature` | Requirement Change |
|---|---|---|---|
| Overall scope | One end-to-end onboarding feature | Multiple features: account setup, identity verification, business verification, shared OTP behavior, sign-in, forgot password, multi-business, dashboard and security | Registration expanded from a single flow into a full auth and onboarding capability set |
| Step model | 3-step sign-up flow: account, business details, personal details | Multi-phase registration with account setup, personal/mobile details, email OTP, sign-in continuation, mobile confirmation, mobile OTP, identity confirmation, Nafath, business verification, bank step, confirmation | The product now separates identity, business, and verification concerns much more explicitly |
| Business verification | Business details entered directly | Commercial registry checks, UNN checks, VAT validation, owner/identity verification, optional IBAN verification | Business registration became externally verified and rule-driven |
| Identity verification | No Nafath flow | Full Nafath challenge, approval, retry, timeout, regenerate, and service failure flows | Government-backed identity verification was introduced |
| OTP coverage | No generalized OTP model in onboarding steps | Email OTP, mobile OTP, shared OTP rules, resend cooldowns, expiry behavior | OTP behavior became a first-class requirement set |
| Sign-in / recovery | Outside scope except email verification completion | Sign-in, forgot password, reset flow, post-registration sign-in, multi-business selection, in-session switcher | Authentication lifecycle requirements were added |
| Security / platform hardening | Minimal validation and redirect checks | URL access control, concurrency, sanitization, credential lockout, RTL rendering, locale enforcement | Security and robustness requirements were added explicitly |
| External verification after onboarding | Email verification by mailbox inspection | Immediate verified dashboard access after registration plus no outbound notification requirement | Completion semantics changed from email-verified activation to immediate verified platform access after identity/business verification |

## 4. Scenario Inventory Comparison
| Source File | Feature Blocks | Scenario Count | Scenario Outlines | Main Focus |
|---|---:|---:|---:|---|
| `sign-up-test.feature` | 1 | 15 | 2 | Basic onboarding, UI validation, and email verification |
| `business-registration-test.feature` | 6 | 66 | 15 | End-to-end registration, identity/business verification, OTP rules, sign-in lifecycle, security, localization |

## 5. Feature Block Mapping
| `sign-up-test.feature` block | Closest block(s) in `business-registration-test.feature` | What changed in scenario design | What changed in the requirements |
|---|---|---|---|
| Step 1: Account Creation | `Business Registration — Account Setup` | Similar starting point, but the new file decomposes validation, button states, password rules, duplicate email handling, and show/hide behavior into dedicated scenarios | Account creation requirements became more explicit and testable, especially around password complexity and duplicate-account handling |
| Step 2: Business Details | `Business Registration — Business Verification` | Old file treats business details as a single form step; new file splits commercial-registry lookup, Arabic legal-name population, UNN/VAT validation, business-owner match, service outage, IBAN step, and confirmation | Business details are no longer plain user input; they are now verified against external and internal business-identity rules |
| Step 3: Personal Details | `Business Registration — Account Setup`, `Business Registration — Identity Verification` | Old file has personal details as one step with first/last name and phone; new file splits personal/mobile details, email OTP, sign-in continuation, mobile confirmation, mobile OTP, and identity confirmation | Personal onboarding was redesigned into staged verification checkpoints rather than a single submit step |
| Email verification | Partly replaced by `Email OTP Verification`, `Sign in to continue`, and later verified-dashboard flows | Old file validates mailbox-based verification links; new file validates in-product OTP and sign-in continuity instead | Activation shifted from email-link verification to stronger in-product identity and OTP orchestration |
| UI-only checks | Spread across multiple new scenarios | Old file uses a dedicated UI section; new file mixes UI assertions into behavior-specific scenarios | UI assertions are now tied more closely to business behavior rather than isolated screen checks |

## 6. Scenario-by-Scenario Comparison Matrix
| `sign-up-test.feature` scenario | Closest scenario(s) in `business-registration-test.feature` | What changed in the scenario design | What changed in the requirements |
|---|---|---|---|
| `Create account with valid credentials` | `Successful account creation with valid credentials navigates to personal details` | Same broad outcome; new file uses Qawafel-specific copy, field names, and `Continue` step progression | Account creation still exists, but now uses defined password rules and a named step transition |
| `Submit business details with taxable customer <taxable_state>` | `Clicking Continue on business details triggers the commercial registry check`; `Successful registry lookup populates the Arabic Legal Business Name as read-only`; `Successful business details submission navigates to the bank account step` | One broad outline was decomposed into lookup, validation, and post-lookup navigation scenarios | Business details now depend on UNN, registry verification, and read-only Arabic legal name instead of generic taxable/identifier toggles |
| `Submit personal details and complete onboarding` | `Valid personal and mobile details submission navigates to email OTP`; `Correct email OTP advances to the sign-in step and confirms account creation`; `Successful sign-in after email verification navigates to identity verification`; later identity/business verification scenarios | Single completion path was expanded into several gated verification stages | Onboarding no longer completes after personal details; it now requires OTPs, sign-in continuation, identity verification, business verification, and optionally IBAN |
| `Sign-up form shows inline validation error for invalid input` | `Password checklist shows a grey cross for each failing rule`; `Confirm Password mismatch shows inline error on blur and disables Continue`; `Duplicate email shows an inline error after Continue` | One broad outline was split by validation type | Validation rules became more specific and cover both client-side and post-submit duplicate checks |
| `Sign-up form enables "Create Account" button after correcting invalid data` | `Continue button becomes enabled when all three fields contain valid values`; `Inline mismatch error clears when Confirm Password is corrected to match` | New file separates button-enable conditions from mismatch-correction recovery | Button-state and error-recovery behaviors became explicit requirements |
| `Business details form shows required field errors when submitted empty` | No direct equivalent | New file does not preserve a generic empty business-details submission scenario because the business step is now lookup-driven and validated through specific field/business rules | Requirements shifted away from generic empty-form validation toward domain-specific UNN, VAT, TIN, registry, and owner-match rules |
| `Personal details form shows phone validation error for invalid format` | `Duplicate mobile number shows inline error after Continue`; `Mobile Number field shows a read-only country code prefix`; OTP/mobile confirmation steps | The new file does not keep a standalone invalid-phone-format scenario in the same form shape; mobile handling is embedded in staged registration and confirmation | Personal phone collection was reworked into mobile-number verification and OTP-driven confirmation rather than a basic personal-details field validation |
| `Create Account button is disabled on initial page load` | `Continue button is disabled when no fields are filled` | Same behavior with Qawafel-specific button wording and context | Initial gating of account creation remained, but terminology changed |
| `Create Account button becomes enabled when all fields are valid` | `Continue button becomes enabled when all three fields contain valid values` | Same behavior, reworded and placed in step-based account setup | No major requirement change beyond button label / step naming |
| `Password visibility toggle shows and hides password text` | `Show/hide toggle reveals the value of each password field`; `Show/hide toggle re-obscures the value of each password field` | One scenario became two outlines covering both Password and Confirm Password fields | Visibility-toggle behavior became more complete and explicitly symmetric |
| `Business Details page shows correct progress bar and header` | No direct equivalent | New file does not carry over progress-bar percentage or generic header assertions in the same style | UI framing requirements changed substantially because the registration architecture changed |
| `Personal Details page shows prefilled email and correct placeholders` | `Personal details step shows the registered email as read-only context` | Placeholder-specific assertions were reduced; the new file preserves the read-only email context but not the exact placeholder checks | The product shifted from placeholder-driven onboarding UI checks to behavior-focused read-only context and step transitions |
| `Submit button becomes enabled when all personal details are valid` | `Valid personal and mobile details submission navigates to email OTP` | New file focuses on successful step submission and transition rather than just button enabled state | The requirement emphasis moved from UI readiness to verified progression |
| `Verify account email via dev localhost mailbox` | No direct equivalent | Removed entirely from the Qawafel registration feature set | Email-link mailbox verification was replaced by in-product OTP and staged sign-in/identity verification |
| `Verify account email via UAT mailbox` | No direct equivalent | Removed entirely from the Qawafel registration feature set | Same requirement shift: no mailbox-link verification flow in the new requirements |

## 7. New Requirement Areas Present Only In `business-registration-test.feature`
| New requirement area | Representative scenarios | What changed from `sign-up-test.feature` |
|---|---|---|
| Email OTP behavior | `Correct email OTP advances to the sign-in step and confirms account creation`; `Verify button is disabled when fewer than 6 OTP digits are entered` | Email verification moved from mailbox-link confirmation to OTP verification inside the app |
| Mobile confirmation and mobile OTP | `Valid mobile number confirmation sends an OTP and advances to mobile OTP step`; `Correct mobile OTP advances to the identity confirmation step` | Mobile verification became a dedicated staged requirement |
| Nafath identity verification | `Nafath approval shows a success message and advances to business verification`; `Nafath rejection shows an error message and a retry option`; `Nafath timeout shows a session expired message and a regenerate option` | Government-backed identity verification was introduced |
| Commercial registry business verification | `Successful registry lookup populates the Arabic Legal Business Name as read-only`; `UNN already registered on Qawafel shows an inline error`; `Commercial registry service unavailable shows an inline error and allows retry` | Business validation became externally verified and dependency-heavy |
| Bank account verification | `Successful IBAN verification navigates to the registration confirmation screen`; `Clicking Add Later skips IBAN entry` | A bank-verification step was added after core registration |
| Shared OTP rules | Incorrect OTP, resend cooldown, max resend attempts, expiry behavior across steps | OTP handling became reusable shared behavior with platform-wide consistency |
| Sign-in and forgot password | Single-business sign-in, multi-business selection, reset flow, forgot password validation | Post-registration authentication requirements were added |
| Security / resilience / localization | Access control, sanitization, concurrency, lockout, RTL, locale-specific date format | Non-happy-path platform hardening became explicit requirement coverage |

## 8. Requirement Changes Implied By The New Registration File
1. **Registration became identity-backed rather than just form-submission based.**
The new file introduces email OTP, mobile OTP, identity confirmation, and Nafath verification, none of which exist in the older sign-up file.

2. **Business details became externally validated instead of purely user-entered.**
The old file allows direct business details entry with local field logic such as taxable state. The new file introduces UNN, commercial-registry lookup, owner verification, VAT validation, and business-record state checks.

3. **Completion semantics changed.**
In the old file, onboarding completes after personal details and mailbox verification. In the new file, completion requires multiple verification stages and ends in a verified dashboard / registration confirmation model.

4. **Authentication lifecycle requirements were added.**
The old file focuses on registration only. The new file adds sign-in, forgot password, reset flow, multi-business behavior, and in-session business switching.

5. **OTP became a shared platform behavior.**
Instead of one-off verification behavior, the new requirements define reusable OTP expectations like resend cooldowns, max attempts, expiry handling, and button-state rules across multiple steps.

6. **Security and localization became explicit product requirements.**
The old file contains minimal security assertions. The new file adds access control, sanitization, concurrency, failed-login restriction, RTL rendering, and locale-enforced date format.

7. **Email-link verification was effectively replaced.**
The mailbox-based dev/UAT verification scenarios in the old file no longer appear as the activation mechanism. The new flow uses in-app verification and staged sign-in continuity instead.

## 9. What Was Not Carried Forward From `sign-up-test.feature`
- The dedicated `Business Details` taxable-state toggle scenario was not carried forward in that form.
- Generic business-details empty-form validation was not preserved as a single scenario.
- Placeholder-heavy UI checks for personal details were reduced or replaced with behavior-oriented assertions.
- Mailbox-link verification scenarios were not carried forward.
- Progress-bar percentage checks were not preserved in the same form.

## 10. Notable Additions In `business-registration-test.feature`
- Two distinct registration feature blocks instead of one monolithic sign-up feature
- Business verification through commercial-registry and Qawafel checks
- Nafath challenge / retry / timeout / service-failure handling
- Shared OTP behavior feature covering multiple OTP steps
- Sign-in, forgot password, and multi-business flows
- Verified dashboard and security feature set
- Concurrency, sanitization, RTL, and locale scenarios

## 11. Conclusion
`business-registration-test.feature` is not a simple extension of `sign-up-test.feature`; it is a substantially more mature and regulated requirement model.

The old `sign-up-test.feature` assumes:
- a relatively straightforward onboarding wizard,
- direct user entry of business details,
- email-link based post-registration verification,
- and modest UI validation.

The new `business-registration-test.feature` assumes:
- staged registration across multiple feature blocks,
- external identity and business verification,
- shared OTP rules,
- post-registration sign-in and recovery flows,
- multi-business platform behavior,
- and explicit security / localization constraints.

In short, the change from the second file to the first file is a move from **basic onboarding wizard coverage** to **full business-registration and authentication platform coverage**.
