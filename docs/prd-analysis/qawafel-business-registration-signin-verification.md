# PRD Analysis: Qawafel Platform — Business Registration, Sign-In & Verification

## 1. Sources Analysed
- `[pasted text]` — PRD: Business Registration, Sign-In & Verification (full document, Sections 1–6)
- `https://www.figma.com/board/soouXWmYkP9cgMM6v32uVW/APEX-Screens?node-id=29-115` — Figma design board (inaccessible without authenticated session; design comparison could not be performed — all Figma-dependent gaps are marked `[MISSING: design confirmation]`)
- `docs/concepts/product-concept-map.md` — Not found in workspace
- `docs/concepts/concept-scenario-index.md` — Not found in workspace
- `scenarios/Admin/register.feature` — Existing vendor store registration scenarios (different flow — Vendor Store buyer, not Business Owner; partially reusable structure only)
- `scenarios/vendorApp/login.feature` — Existing vendor app login scenarios (mobile+OTP flow; different auth mechanism)
- `scenarios/Vendor-Store/verification.feature` — Existing verification state scenario (different context)

---

## 2. Feature Summary
This PRD defines how a Business Owner registers a new business on the Qawafel platform via a mandatory 5-step flow (identity collection → password setup → mobile OTP → Nafath identity verification → optional IBAN), followed by immediate dashboard access upon successful Nafath verification. It also covers email+password+OTP sign-in, a two-stage forgot password flow, multi-business login with an in-session switcher, and the verified dashboard state. The flow is designed exclusively for first-time registrants; users registering a second business from an existing session are explicitly deferred to a future PRD.

---

## 3. In Scope / Out of Scope

**In scope:**
- 5-step business registration flow (Steps 1–5) including all field-level validation and API checks
- Government API checks at Step 1 Continue: platform credentials check, identity/DOB, mobile ownership, UNN existence, UNN ownership
- Saudi commercial registry API: retrieves Business Legal Name (Arabic) on Step 1 Continue
- Nafath identity verification (Step 4): happy path, failure/rejection, timeout, retry
- IBAN verification API (Step 5, optional): format validation and API confirmation
- Registration Confirmation Screen
- Email + password + OTP sign-in (two-factor)
- Forgot password flow (7-step: identity verification → OTP → password reset)
- Multi-business sign-in: business selection screen and in-session switcher
- Verified dashboard state (FR-DS.1, FR-DS.2)
- Explicit no-notification policy (Section 6)

**Out of scope:**
- Second-business registration from within an existing signed-in session (deferred — explicitly stated)
- Alternative sign-in methods (no social login, SSO, or magic link)
- Admin approval step (verification is direct via Nafath API — no manual admin gate)
- Phase 1 notifications of any kind (Section 6 explicitly excludes all outbound notifications)
- Authorised-registrant path (always the legal owner)
- International businesses (Saudi formats enforced throughout)

---

## 4. Personas & Permissions

| Persona | Role | Key permissions / constraints |
|---|---|---|
| Business Owner | Registers a new business; always the legal owner | Completes all 5 steps; must pass Nafath verification; cannot delegate registration |
| Multi-Business User | Business Owner who has registered 2+ businesses | Sees business selection screen at sign-in; can switch context in-session without signing out |
| Qawafel Platform | System actor | Enforces email and mobile uniqueness; runs sequential API checks; creates account only on Nafath success; no notifications sent in Phase 1 |
| Saudi Commercial Registry API | External system | Returns Business Legal Name (Arabic) on Step 1 Continue; not called for VAT or TIN |
| Nafath API | External identity platform | Issues 2-digit challenge number; receives approval/rejection from user's app; platform polls for status |
| IBAN Verification API | External banking system | Confirms IBAN is active and linked to the registered business; called only on Step 5 Continue |

---

## 5. End-to-End User Flow

**Flow A — New Business Owner completes full registration (IBAN provided)**

1. Business Owner opens the registration screen and sees the informational banner: *"Make sure all details match your official government documents exactly. Mismatches are the most common cause of verification delays."*
2. **Step 1:** Fills in National ID / Iqama, Date of Birth, UNN, VAT Registration Number, TIN (optional), Mobile Number, Work Email Address. All required fields must pass inline format validation before Continue is enabled.
3. Clicks Continue → button enters loading state, all fields disabled. Platform runs sequentially: platform credentials check → identity/DOB API → mobile ownership API → UNN existence API → UNN ownership API → Saudi commercial registry API (retrieves Business Legal Name (Arabic)).
4. On success: advances to **Step 2**. Business Legal Name (Arabic) stored as canonical name.
5. **Step 2:** Work email shown as read-only. Business Owner sets password (Enter Password + Confirm Password). Live checklist validates all 5 complexity rules. Continue enabled only when all rules pass and both fields match.
6. **Step 3:** Mobile number from Step 1 shown read-only. OTP auto-sent on step load (6 digits, 3-minute timer). Business Owner enters OTP. On success: auto-advances to Step 4. No account created.
7. **Step 4:** Nafath screen loads automatically. 2-digit non-copyable number displayed, 3-minute countdown, "Open Nafath App" CTA. Business Owner opens Nafath app, approves request. Platform polls in background.
8. On Nafath success: countdown stops, number container turns green with checkmark, *"Identity Verified Successfully"* shown. **Account is created.** Auto-advances to Step 5.
9. **Step 5:** Bank Name (dropdown) + IBAN fields. Business Owner selects bank and enters IBAN. Format validated (SA + 22 digits). Clicks Continue → IBAN verification API called. On success: proceeds to Confirmation Screen.
10. **Confirmation Screen:** Success icon, *"Your account is verified"*, *"You can now access all platform features."*, "Go to Dashboard" CTA.
11. Business Owner clicks "Go to Dashboard" → lands on Verified dashboard. Status card *"Your account is verified."* shown; dismissible.

**Flow B — New Business Owner skips IBAN**

1–8. Same as Flow A.
9. **Step 5:** Business Owner clicks "Add later" → proceeds directly to Confirmation Screen. No IBAN data saved.
10–11. Same as Flow A.

**Flow C — Sign-in (single-business user)**

1. Business Owner opens sign-in screen; enters email and password.
2. On valid credentials: OTP auto-sent to registered mobile. OTP entry screen shown with masked mobile number, 3-minute countdown.
3. Business Owner enters OTP. On success: lands directly on dashboard.

**Flow D — Sign-in (multi-business user)**

1–2. Same as Flow C.
3. On successful OTP: business selection screen shown (each card shows legal name in Arabic).
4. Business Owner selects a business → dashboard loads scoped to that business. Business name shown in navigation bar.
5. Business Owner can switch business from navigation bar → selection screen reopens → selecting another business rescopes all data and navigation immediately.

**Flow E — Forgot Password**

1. Business Owner clicks "Forgot password?" on sign-in screen.
2. Enters National ID / Iqama, UNN, and registered email address.
3. System validates combination. On match: OTP sent to registered mobile (6 digits, 3-minute timer, resend after 60 seconds, max 3 resends).
4. Business Owner enters OTP. On success: password reset screen shown (New Password + Confirm Password).
5. Business Owner sets new password meeting all 5 complexity rules. Next button enabled only when rules pass and fields match.
6. On save: success screen shown — *"Your password has been updated successfully. You can now log in to your account and explore our services."* Login button redirects to sign-in screen.

---

## 6. Acceptance Criteria Coverage

| Story / Section | AC stated in PRD | Testable? | Gaps |
|---|---|---|---|
| FR-1.1 — Step 1 fields | All required fields visible and enforced; TIN optional; form order enforced | Yes | Business Legal Name (Arabic) never shown to user in the form — confirm it is invisible at Step 1 or shown as read-only after retrieval [MISSING: design confirmation] |
| FR-1.2 — National ID / Iqama | 10 digits starting with 1 (National ID) or 2 (Iqama); inline error on leave: *"Please enter a valid National ID (starts with 1) or Iqama number (starts with 2)."* | Yes | No validation of actual ID authenticity at field level — only format; confirmed intentional |
| FR-1.3 — Date of Birth | DD/MM/YYYY format; date picker or formatted text input | Partial | Date picker vs. text input not decided; past-date boundary not defined; minimum age not defined [MISSING: min age constraint] |
| FR-1.4 — UNN | 10 digits starting with 7; inline error on invalid format; duplicate UNN inline error: *"This UNN is already registered on Qawafel. Please sign in instead"* | Yes | Duplicate UNN check happens at Step 1 Continue (API), not on blur — confirm inline error shown after Continue returns, not on field leave |
| FR-1.5 — VAT Registration Number | 15 digits, starts and ends with 3; inline error: *"VAT Registration Number must be 15 digits starting and ending with 3."*; no API validation | Yes | None |
| FR-1.6 — TIN | Optional; no API validation; stored as submitted | Yes | No format validation at all — any string accepted? [MISSING: format expectation for TIN] |
| FR-1.7 — Mobile Number | +966 5X XXX XXXX; +966 prefix read-only with flag; uniqueness enforced; duplicate error: *"This mobile number is already associated with a Qawafel account. Please sign in instead."* | Yes | Uniqueness check is at Step 1 Continue (API) — confirm inline error placement is under the Mobile Number field post-Continue |
| FR-1.8 — Work Email | Standard format validation on blur; uniqueness enforced; duplicate error: *"An account with this email already exists. Sign in instead."* | Yes | Email uniqueness check at Continue (API) or on blur? PRD says "must be unique" but uniqueness error wording suggests it is an API check; confirm trigger point |
| FR-1.9 — Informational banner | Banner visible above fields on Step 1 | Yes | None |
| FR-1.10 — Continue button + API sequence | Disabled until all required fields valid; loading state on click; all fields disabled; sequential API checks; no intermediate status surfaced; advances or returns field-level error | Yes | Order of error display when multiple fields fail API checks simultaneously not defined [MISSING]; what happens if Saudi commercial registry API fails at Step 1 Continue? [MISSING: error handling for registry API failure] |
| FR-1 note — Multi-business secondary registration | Deferred to future PRD; existing session reuse | No (deferred) | Full secondary flow not described — future test scope not defined |
| FR-2.1 — Email shown read-only on Step 2 | Greyed read-only text; not editable | Yes | None |
| FR-2.2 — Password complexity | Min 12 chars, 1 uppercase, 1 lowercase, 1 number, 1 special char; live checklist with grey cross / green tick; Continue disabled until all rules met | Yes | "Special character" set not defined — does it include spaces? Unicode characters? [MISSING: special character definition] |
| FR-2.3 — Confirm Password | Inline error on leave if mismatch: *"Passwords do not match."*; Continue disabled until match and all rules met | Yes | None |
| FR-2.4 — Show/hide toggle | Eye icon on each field; toggles obscured/plain text | Yes | None |
| FR-3.1 — OTP auto-send on Step 3 load | Mobile number shown read-only; OTP auto-sent on step load without user action; OTP is 6 digits | Yes | None |
| FR-3.2 — OTP input + timer | 6-digit input; 3-minute countdown timer; Submit enabled when 6 digits entered | Yes | Auto-submit on 6th digit or requires button press? [MISSING: design confirmation] |
| FR-3.3 — Incorrect OTP | Inline error: *"Incorrect code. Please try again."*; field cleared; timer continues | Yes | Maximum incorrect attempt count not defined [MISSING: lockout policy] |
| FR-3.4 — Resend OTP | Disabled for 60 seconds; enabled after 60 seconds; after 3 resends: disabled with *"Maximum resend attempts reached. Please wait for the current code to expire."* | Yes | What happens after 3 resends and the OTP expires — can the user restart from Step 3 or must they restart registration? [MISSING] |
| FR-3.5 — Successful OTP → Step 4 | Automatic navigation to Step 4; no account created | Yes | None |
| FR-3.6 — OTP expiry | Input disabled; *"Your code has expired."* shown; Resend button available immediately | Yes | Does OTP expiry resend count consume one of the 3 resend attempts? [MISSING] |
| FR-4.1 — Nafath screen | 2-digit non-copyable number; 3-minute countdown; "Open Nafath App" CTA deep-links to Nafath; platform polls in background | Partial | Deep-link scheme not defined — universal link, app scheme, or store redirect if not installed? [MISSING: Nafath deep-link spec]; polling interval not defined [MISSING] |
| FR-4.2 — Nafath API initiation failure | Error: *"Nafath is temporarily unavailable. Please try again."*; Retry button shown | Yes | Does retry consume a new Nafath API call? What is the retry limit? [MISSING] |
| FR-4 terminal — SUCCESS | Countdown stops; number container turns green with checkmark; *"Identity Verified Successfully"*; auto-advances to Step 5; account created; API data stored; audit record stored | Yes | None |
| FR-4 terminal — FAILURE / REJECTION | Screen locks; red error container: *"Verification Rejected. Please ensure you are scanning your own face in a well-lit area."*; Retry Verification button; no retry limit | Yes | "Screen locks" not further defined — are fields/CTAs disabled while locked? [MISSING: design confirmation] |
| FR-4 terminal — TIMEOUT | Number greyed out; *"Session Expired. For security, Nafath requests must be completed within 3 minutes."*; Regenerate Request button; fresh API call on click | Yes | None |
| FR-5.1 — IBAN fields | Bank Name dropdown (supported banks list); IBAN text input; both required if either populated; Continue triggers IBAN verification API | Yes | Supported bank list source/maintenance not defined [MISSING]; what if supported bank list fails to load? [MISSING] |
| FR-5.2 — IBAN format | SA + 22 digits; format validation only | Yes | None |
| FR-5.3 — IBAN verification API | API confirms IBAN active and linked to registered business; failure: *"We couldn't verify your IBAN. Please check your details and try again."*; cannot proceed until verification passes or "Add later" clicked | Yes | IBAN verification API timeout handling not defined [MISSING]; partial match (IBAN active but not linked to this business) — same error copy? |
| FR-5.4 — Add later | Always visible; navigates to confirmation screen; no IBAN data saved | Yes | None |
| FR-5.5 — Informational note | Note visible above form fields on Step 5 | Yes | None |
| FR-6.1 — Confirmation screen | Success icon, *"Your account is verified"*, *"You can now access all platform features."*, "Go to Dashboard" CTA → navigates to Verified dashboard | Yes | None |
| FR-6.2 — No notifications | No outbound notification triggered; confirmation screen is the only feedback | Yes | None |
| FR-SI.1 — Sign-in fields | Email and password fields only; no other sign-in methods | Yes | None |
| FR-SI.2 — Incorrect credentials | Generic error: *"Incorrect email or password. Please try again."*; no account existence disclosure | Yes | Account lockout after N failed attempts not defined [MISSING: brute-force protection policy] |
| FR-SI.3 — OTP auto-sent post-credential validation | OTP auto-sent; OTP entry screen shown immediately; 6 digits; no user trigger needed | Yes | None |
| FR-SI.4 — Sign-in OTP screen | Masked mobile shown; 3-minute countdown; resend after 60 seconds; max 3 resends: *"Maximum resend attempts reached. Please wait for the current code to expire."*; incorrect OTP: *"Incorrect code. Please try again."*; expired: *"Your code has expired."* | Yes | Same resend and lockout behaviour as Step 3 — confirm shared component or separate implementation |
| FR-SI.5 — Post-OTP redirect | Single-business → dashboard; multi-business → selection screen | Yes | None |
| FR-SI.6 — Forgot password link | Visible on sign-in screen | Yes | None |
| FR-SI.7 — Forgot password flow | 7-step sequence; success message: *"Your password has been updated successfully. You can now log in to your account and explore our services."*; Login button redirects to sign-in | Yes | Step 2 (system validates identity combination) — error message if combination invalid not defined here (covered by FR-SI.8); no OTP attempt limit differentiation from registration OTP |
| FR-SI.8 — Invalid identity combination | Generic error: *"We couldn't verify those details. Please check and try again."*; no account existence disclosure | Yes | None |
| FR-MB.1 — Business selection screen | Shown for 2+ businesses; each card shows legal name (Arabic) only; single-business → direct to dashboard | Yes | Card shows "only business legal name (Arabic)" — no additional context (e.g., UNN, status) shown; confirm [MISSING: design confirmation] |
| FR-MB.2 — Active business context | Business name in top navigation bar; all data scoped to selected business | Yes | None |
| FR-MB.3 — In-session switcher | Accessible from navigation bar at all times for multi-business users; selecting different business rescopes immediately; no sign-out required | Yes | What happens to in-flight operations (e.g., a form being filled) when business is switched? [MISSING] |
| FR-MB.4 — Single-business exclusion | Selection screen and switcher absent for single-business users | Yes | None |
| FR-DS.1 — Verified dashboard | All features accessible from first load; no lock indicators; no notification | Yes | None |
| FR-DS.2 — Verification status card | *"Your account is verified."*; dismissible via X or dismiss CTA | Yes | Dismissed state persistence not defined — does dismissal persist across sessions or re-appear on next login? [MISSING] |

---

## 7. Business Rules & Data

- Account is created **only** on successful Nafath verification (Step 4 success terminal). Not at OTP (Step 3), not at password (Step 2).
- Business Legal Name (Arabic) is not entered by the registrant — it is retrieved automatically from the Saudi commercial registry API on Step 1 Continue and stored as the canonical business name.
- Email uniqueness is enforced at the **account level**, not the business level. One email/password/verification can be associated with multiple businesses.
- Mobile uniqueness is enforced across all Qawafel accounts. Format: `+966 5X XXX XXXX`.
- UNN uniqueness is enforced: if already associated with an active account, registration is blocked with *"This UNN is already registered on Qawafel. Please sign in instead."*
- National ID format: 10 digits starting with 1. Iqama format: 10 digits starting with 2.
- UNN format: 10 digits starting with 7.
- VAT Registration Number format: 15 digits starting and ending with 3. No API validation — stored as submitted.
- TIN: optional, no validation, stored as submitted.
- Password complexity: minimum 12 characters, at least one uppercase, one lowercase, one number, one special character.
- OTP validity window: 3 minutes (registration Step 3, sign-in, forgot password).
- OTP resend: enabled after 60 seconds; maximum 3 resend attempts across all OTP screens.
- Nafath challenge number: 2 digits, non-copyable, expires in 3 minutes. No limit on retry attempts within a session.
- IBAN format: SA followed by 22 digits (Saudi IBAN standard). Verification API additionally confirms IBAN is active and linked to the registered business.
- Back navigation is permitted on Steps 1–3. Once Nafath is successfully verified (Step 4 success), back navigation is not available within the registration session.
- All platform features are unlocked **immediately** upon successful verification — no approval queue, no admin gate.
- No notifications of any kind are sent in Phase 1 (no SMS, email, or in-app).
- [ASSUMPTION] The sequential API checks at Step 1 Continue execute server-side in a single request from the platform's perspective — the PRD does not specify whether they are one composite call or chained individual calls.
- [ASSUMPTION] "Active credentials" in FR-1.4 (UNN already registered) means an account with a verified, non-deleted status. What constitutes an "inactive" or "suspended" account state for UNN uniqueness purposes is not defined.
- [ASSUMPTION] The Nafath polling mechanism uses the Nafath API's standard status endpoint; no webhook/callback alternative is described.

---

## 8. Edge Cases & Negative Paths

- **Empty required fields at Step 1 Continue:** Continue button disabled — inline validation must prevent reaching the API call; test that disabling is enforced in the DOM (not purely visual).
- **All-spaces input in text fields:** Fields with no format validation (TIN, Legal Name English) — whitespace-only input must be either rejected or trimmed before storage.
- **Maximum length inputs:** No max character length defined for TIN, Work Email, or password — extremely long strings (e.g., 10,000-character password) could cause server errors [MISSING: max length].
- **National ID starting with digit other than 1 or 2 (e.g., starts with 3):** Must trigger inline error — neither National ID nor Iqama pattern matches.
- **UNN starting with 7 but Government API returns no match:** Not covered in Step 1 error states — what error is shown if UNN passes format validation but the Saudi commercial registry returns no business? [MISSING: error copy for registry miss at Step 1].
- **Concurrent registration with the same email from two devices:** Race condition — only one account should be created; database-level unique constraint must be in place.
- **Concurrent registration with the same UNN from two devices:** Same race condition — UNN uniqueness at DB level required.
- **Step 1 Continue — multiple API failures simultaneously:** e.g., both mobile uniqueness and email uniqueness fail — all field-level errors must be surfaced simultaneously, not sequentially.
- **Back navigation from Step 2 to Step 1:** Data entered in Step 1 must be preserved. Confirm that the API checks do not re-fire on revisiting Step 1 without changing values.
- **Back navigation attempt after Nafath success:** PRD states back navigation is blocked — must confirm the back button/gesture is intercepted in both browser and native contexts.
- **Nafath app not installed on device:** Deep-link to Nafath app fails — user stranded on Qawafel screen with timer running. No fallback described [MISSING: fallback for uninstalled Nafath app].
- **Nafath API poll response arrives after session expiry / page refresh:** Account may have been created but UI shows error state — risk of orphaned accounts [MISSING: orphaned account handling].
- **Step 5 IBAN API timeout:** Loading state must not block indefinitely; no timeout or retry behaviour defined [MISSING].
- **Step 5 IBAN entered for a bank not in the dropdown:** Not possible if dropdown is the only bank selection method — but what if the supported bank list fails to load (empty dropdown)?
- **Step 5 "Add later" clicked after partial IBAN entry:** PRD states no IBAN data saved — confirm partial IBAN is not persisted.
- **Sign-in OTP — correct credential but OTP expires and all 3 resends exhausted:** User is locked out of completing sign-in; no path back to credentials step defined [MISSING: lockout recovery for sign-in OTP].
- **Forgot password — identity combination matches but mobile number has since changed:** OTP sent to an unreachable number; no fallback described [MISSING].
- **Multi-business switch mid-form-fill:** If Business Owner is filling a form and switches business, unsaved data loss behaviour is not defined.
- **RTL / LTR rendering:** Business Legal Name (Arabic) is the primary canonical name stored and displayed; it will appear in RTL contexts (navigation bar, business selection screen, dashboard). English-language fields on the same screen must not break mixed-direction layouts.
- **Locale — date of birth picker:** DD/MM/YYYY format must be enforced regardless of device locale (some devices default to MM/DD/YYYY).
- **Unauthorised access — accessing dashboard URL directly without signing in:** Standard auth gate — must redirect to sign-in; confirmed standard pattern but must be tested.
- **Unauthorised access — accessing another business's data via URL manipulation in multi-business context:** API-level business ownership scoping must prevent cross-tenant data access.
- **Password reuse on forgot password:** No rule stated preventing the Business Owner from resetting to the same password — [MISSING: password reuse policy].

---

## 9. Cross-Story Dependencies

- **Step 1 → Step 4 (account creation):** All data collected across Steps 1–3 is held in session state and only committed to the database on Nafath success at Step 4. If the session is lost between Steps 1 and 4 (e.g., browser close, device sleep), none of the data is persisted. The PRD does not define session recovery or draft-saving behaviour — this is a significant drop-off risk.
- **Step 1 API sequence → Business Legal Name (Arabic):** The Saudi commercial registry API call at Step 1 Continue is the source of the canonical business name. If this call fails, the entire Step 1 Continue fails — the error state for this specific failure is not defined in the PRD. This is a hard dependency; a registry outage blocks all registrations.
- **Step 4 (Nafath) → Step 5 (IBAN):** IBAN is verified against the registered business identity created at Step 4. The IBAN verification API must receive the correct business identifier from the Step 4 result. If Step 4 data is malformed or incomplete, IBAN verification will fail in a misleading way.
- **Registration → Sign-in:** A Business Owner who completes registration is immediately verified. They can sign in without any delay. The sign-in flow must correctly identify single-business vs. multi-business status from the first session.
- **Multi-business sign-in → in-session switcher:** Business selection at sign-in and in-session switching share the same business list data. A newly registered business must appear in the selection screen on the user's next sign-in or after a switch — timing of business list refresh not defined.
- **Forgot password → Sign-in:** Password reset via the forgot password flow must invalidate any active sessions for that account. Not stated in the PRD [MISSING: session invalidation on password reset].
- **Business Registration PRD (this PRD) → Business Partner Management PRD:** The Business Owner's verified status, UNN, and Business Legal Name (Arabic) established in this PRD are consumed directly by the Business Partner Management feature. UNN uniqueness and verified profile data are hard dependencies for that feature.

---

## 10. Risk Assessment

| Risk | Area | Likelihood | Impact | Mitigation suggestion |
|---|---|---|---|---|
| Saudi commercial registry API outage blocks all new registrations at Step 1 Continue — no fallback path defined | API / Perf | M | H | Define a graceful degradation strategy (queue, retry, or manual override path for admin) and a specific error message for this failure state |
| Nafath API polling receives success confirmation after user has closed the browser — account created but user never reaches Step 5 or confirmation screen; orphaned incomplete account state | Data / API | M | H | Store Nafath verification result server-side; on next sign-in detect incomplete registration and resume from Step 5 |
| Race condition: two concurrent Step 1 Continue submissions with the same UNN, email, or mobile pass uniqueness checks simultaneously and both proceed to Nafath | Data | M | H | Enforce unique constraints at DB level with atomic check-and-insert; do not rely solely on application-layer uniqueness checks |
| Nafath app not installed on registrant's device — deep-link fails silently with no fallback; 3-minute timer expires; user stuck | UI / Integration | M | H | Define deep-link fallback (App Store / Play Store redirect); display instructional text if app not detected |
| Session loss between Steps 1–3 and Nafath verification causes all entered data to be lost — no draft persistence defined | Data / UX | H | M | Define session recovery behaviour; consider server-side draft storage keyed to mobile number after OTP success (Step 3) |
| Brute-force sign-in attack: no account lockout after N failed credential attempts defined; generic error copy intentionally hides account existence but does not limit attempts | Security | H | H | Define and implement account lockout (e.g., 5 failed attempts → 15-minute lockout); add rate-limiting at API layer |
| Password reset does not invalidate existing sessions — attacker who reset a victim's password cannot prevent victim from using existing session; conversely, victim's active session is not terminated after reset | Security | M | H | Invalidate all active sessions on password reset; return to sign-in with a clear message |
| TIN field accepts any string with no validation — malformed or injected data stored directly as submitted | Security / Data | M | M | Apply input sanitisation and a reasonable max-length constraint server-side even if format validation is intentionally skipped |
| VAT Registration Number stored as submitted with no API validation — a mistyped but format-valid VAT is silently stored and propagates to Business Partner Management as a verified claim | Data | H | M | Add a prominent UI note that VAT is not validated by government API; flag it as unverified in the data model |
| Multi-business in-session switch discards in-flight form data without warning — user loses unsaved work silently | UX | M | M | Intercept switch action when unsaved changes exist; show discard-confirmation prompt |
| Forgot password OTP sent to mobile number that is no longer accessible to the Business Owner — no alternative recovery path defined | UX | L | H | Define an alternative identity recovery escalation path (e.g., admin-assisted recovery) |
| Business Legal Name (Arabic) display in RTL context breaks mixed-direction layouts on sign-in/dashboard when shown alongside LTR content | UI / Accessibility | M | M | Dedicated RTL/LTR mixed-content rendering test pass on all screens showing the Arabic canonical name |

---

## 11. Open Questions

1. **(Dev / PM)** What is the error message and UI behaviour when the Saudi commercial registry API fails or returns no result at Step 1 Continue? This is a hard blocker for all registrations but has no defined error state in the PRD.
2. **(Dev)** Are the Step 1 API checks (platform credentials, identity/DOB, mobile ownership, UNN existence, UNN ownership, commercial registry) a single composite server call or chained individual calls? When multiple checks fail simultaneously, are all field-level errors returned at once or only the first failure?
3. **(PM / Dev)** What is the account lockout policy after repeated failed sign-in attempts (FR-SI.2)? No lockout is currently defined — this is a security gap.
4. **(Dev)** Does a successful password reset (FR-SI.7) invalidate all active sessions for that account?
5. **(Design)** At Step 1, is Business Legal Name (Arabic) ever displayed back to the user within the registration flow (e.g., as a read-only confirmation field after retrieval), or is it silently stored and only visible post-login?
6. **(Design / Dev)** Does the OTP input at Step 3 (registration) and sign-in auto-submit on the 6th digit, or does the user need to click a Submit button after entering 6 digits?
7. **(PM)** After 3 OTP resend attempts and OTP expiry at Step 3 (registration), can the user restart registration from Step 3, or must they start the entire 5-step flow again?
8. **(PM / Dev)** What happens if the Nafath app is not installed on the device when "Open Nafath App" is clicked — is there a store redirect or a fallback instruction?
9. **(Dev)** If the Nafath polling confirmation arrives after the user has closed the browser, what is the account state and how does the user resume registration (particularly Step 5)?
10. **(Dev)** What is the session lifetime for the registration flow? If a user pauses between steps (e.g., 30 minutes), does the session expire and force restart?
11. **(PM)** Is there a password reuse restriction on the forgot password flow (e.g., cannot reuse the last N passwords)?
12. **(PM / Dev)** What happens to in-flight forms when a multi-business user switches business context mid-session — silent discard, warning prompt, or auto-save?
13. **(PM)** Is the verification status card dismissal (FR-DS.2) persistent across sessions, or does it reappear on each sign-in until dismissed?
14. **(Design)** The business selection screen card (FR-MB.1) shows "only business legal name (Arabic)" — is there any secondary identifier (e.g., UNN, registration date) shown on the card, particularly when two businesses have similar names?
15. **(PM / Dev)** What is the TIN field's expected format? The PRD states "stored as submitted" with no validation — should a reasonable max-length or character restriction be applied?
16. **(Dev)** What is the IBAN verification API timeout, and what does the UI show if the call exceeds it?
17. **(PM / Dev)** [ASSUMPTION Q] Does "active credentials" in FR-1.4 include suspended or soft-deleted accounts when checking UNN uniqueness, or only fully active accounts?

---

## 12. Test Strategy Recommendation

- **Test types needed:** Functional, API (contract + validation for all 5 external APIs), Security (brute-force, session management, input sanitisation, cross-tenant access), Integration (Nafath, Saudi commercial registry, IBAN verification API), E2E, Regression, Accessibility (RTL/LTR, keyboard navigation, screen reader for live checklist), Localisation (DD/MM/YYYY date format enforcement across device locales)
- **Suggested test data:**
  - Valid Saudi National ID (starts with 1, 10 digits) and Iqama (starts with 2, 10 digits)
  - Valid DOBs including boundary dates (today, minimum age if defined, far past)
  - Valid and invalid UNNs (format valid but not in registry, format valid and in registry, already registered)
  - Valid and invalid VAT numbers (15 digits start/end with 3; 14 digits; starts with 2; ends with 4)
  - Duplicate email, mobile, and UNN accounts pre-seeded
  - TIN values: empty, short string, very long string, special characters
  - Passwords: exactly 12 chars meeting all rules; 11 chars; missing each rule individually; 12 chars with spaces
  - OTPs: correct, incorrect, expired, after 3 resends exhausted
  - Nafath: success, rejection, timeout, API unavailable — requires mock/stub
  - Saudi IBANs: valid format and linked to business (API success); valid format but not linked; invalid format (SA + 21 digits, SA + 23 digits, non-SA prefix)
  - Multi-business account (2+ businesses registered to same email)
  - Single-business account
  - Valid and invalid forgot-password identity combinations
- **Environment prerequisites:**
  - Nafath API mock/stub supporting success, rejection, timeout, and initiation failure responses
  - Saudi commercial registry API stub for: valid UNN with name returned, UNN not found, service unavailable
  - IBAN verification API stub for: active+linked, active+not linked, inactive, timeout
  - Pre-seeded accounts: verified single-business, verified multi-business (2+), account with specific UNN, email, and mobile for duplicate tests
  - Ability to manually expire OTPs and trigger verification events (for retroactive testing)
  - Test environment with RTL locale enabled for Arabic rendering tests
- **Reusable scenarios to extend:**
  - `scenarios/vendorApp/login.feature` — OTP entry patterns (different auth method but OTP validation structure is reusable)
  - `scenarios/Admin/register.feature` — Registration flow structure; note this is vendor store buyer registration, not Business Owner registration — field sets differ significantly
  - `scenarios/Vendor-Store/verification.feature` — Verified state assertion pattern
- **New scenarios to author:**
  - Step 1 — successful field entry and Continue with all required fields
  - Step 1 — National ID format validation (starts with 1, starts with 2, starts with 3, 9 digits, 11 digits)
  - Step 1 — Iqama format validation
  - Step 1 — UNN format validation and duplicate UNN inline error
  - Step 1 — VAT Registration Number format validation (all boundary cases)
  - Step 1 — Mobile Number format validation and duplicate mobile inline error
  - Step 1 — Email format validation and duplicate email inline error
  - Step 1 — Continue disabled until all required fields valid
  - Step 1 — Continue loading state and field lock during API checks
  - Step 1 — Commercial registry API returns no match for valid UNN
  - Step 1 — Commercial registry API unavailable
  - Step 2 — Password live checklist validates each rule individually
  - Step 2 — Confirm Password mismatch inline error
  - Step 2 — Show/hide password toggle on both fields
  - Step 2 — Continue disabled until all complexity rules met and fields match
  - Step 2 — Email shown read-only from Step 1
  - Step 3 — OTP auto-sent on step load, mobile shown read-only
  - Step 3 — Correct OTP auto-advances to Step 4
  - Step 3 — Incorrect OTP inline error and field clear
  - Step 3 — Resend disabled for 60 seconds then enabled
  - Step 3 — Resend limit reached (3rd resend disables option)
  - Step 3 — OTP expiry locks input and shows resend prompt
  - Step 4 — Nafath screen loads with 2-digit number and 3-minute timer
  - Step 4 — 2-digit number is non-copyable
  - Step 4 — "Open Nafath App" deep-link
  - Step 4 — Nafath success: green container, checkmark, auto-advance, account created
  - Step 4 — Nafath rejection: red error, "Retry Verification" button, fresh number on retry
  - Step 4 — Nafath timeout: number greyed, "Regenerate Request" button, fresh number on regenerate
  - Step 4 — Nafath API initiation failure: error message and retry
  - Step 5 — Bank Name dropdown populated and selectable
  - Step 5 — IBAN format validation (SA + 22 digits; invalid variations)
  - Step 5 — IBAN verification API success and navigation to confirmation
  - Step 5 — IBAN verification API failure inline error
  - Step 5 — "Add later" skips IBAN and navigates to confirmation without saving data
  - Step 5 — Continue disabled until IBAN format is valid when IBAN field is populated
  - Confirmation screen — content and "Go to Dashboard" navigation
  - Confirmation screen — no outbound notification triggered
  - Sign-in — email + password success → OTP screen
  - Sign-in — incorrect credentials generic error
  - Sign-in — OTP screen: masked mobile, timer, resend behaviour, incorrect and expired OTP
  - Sign-in — single-business: direct to dashboard
  - Sign-in — multi-business: business selection screen shown
  - Business selection — card content shows Arabic legal name only
  - Business selection — selecting a business scopes the dashboard
  - In-session switcher — accessible from navigation bar, rescopes on selection
  - In-session switcher — absent for single-business users
  - Forgot password — "Forgot password?" link visible on sign-in screen
  - Forgot password — valid identity combination triggers OTP
  - Forgot password — invalid identity combination generic error (no account existence disclosure)
  - Forgot password — OTP flow (correct, incorrect, expired, resend)
  - Forgot password — new password complexity live checklist
  - Forgot password — success screen copy and Login button redirect
  - Verified dashboard — all features accessible from first load, no lock indicators
  - Verified dashboard — status card shown and dismissible
  - Security — duplicate concurrent registration race condition (same UNN)
  - Security — sign-in brute-force (N failed attempts)
  - Security — cross-tenant URL access attempt in multi-business context
  - RTL rendering — Arabic legal name in navigation bar, business selection screen, dashboard card

---

## 13. Readiness Verdict

**Verdict:** Conditionally ready — resolve open questions

**Blockers / Conditions:**
1. **Saudi commercial registry API failure state at Step 1 (Open Question 1):** The error message and UI behaviour for a registry outage or no-match result during Step 1 Continue are undefined. This blocks test design for a high-frequency failure scenario.
2. **Sign-in brute-force / account lockout policy undefined (Open Question 3):** Proceeding without a lockout policy is a security risk (OWASP A07 — Identification and Authentication Failures). Must be defined before security testing begins.
3. **Session invalidation on password reset undefined (Open Question 4):** A security gap; must be confirmed before the forgot password flow can be signed off.
4. **Nafath app not installed — no fallback defined (Open Question 8):** A likely real-world scenario for a non-trivial proportion of users; blocks UX testing of the Step 4 CTA.
5. **Nafath polling result after browser close — orphaned account handling undefined (Open Question 9):** Risk of permanent data inconsistency; must be resolved before E2E testing of the Step 4 success path.

All remaining open questions are non-blocking for scenario authoring but must be resolved before test execution sign-off.
