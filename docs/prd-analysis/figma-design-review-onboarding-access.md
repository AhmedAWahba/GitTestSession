# Design Review: Business Onboarding & Access Management
**Figma File:** Design System V5 (`fZy0Y8eWmYWOxlErRbWd0D`)
**Canvases reviewed:** Onboarding (176:42377), Invited User frame (239:68192)
**PRD source:** `docs/Master APEX PRD Set.md`
**Review date:** 2026-08-19
**Reviewer:** GitHub Copilot (AI-assisted cross-reference)

---

## Summary

The Onboarding canvas contains **12 numbered screens (ONB-01 to ONB-12)** plus a separate **Invited User "Create Account — Web"** frame. All screens were exported and reviewed against the Product PRD and Engineering PRD alignment document.

The core happy-path flow is well-structured and the design system is consistent. However, **8 screens required by the PRD are completely absent** from the canvas, **3 screens have direct PRD deviations**, and the Users Management canvas (access/partner management) could not be assessed due to Figma API rate limits — a separate session is needed for that canvas.

---

## 1. Onboarding Flow — Screen-by-Screen Audit

### ONB-01 — Account Setup: Create Account (happy path)

| Status | Finding |
|--------|---------|
| ✅ | Three fields present: Email Address, Password, Confirm Password |
| ✅ | Password show/hide toggle visible on Password field |
| ✅ | Step label: "Account Setup — Step 1 of 3 · Create account" |
| ✅ | 3-step stepper with Step 1 active |
| ✅ | Terms & Conditions and Privacy Policy link included |
| ✅ | "Already have an account? Sign in" link present |
| ✅ | Continue CTA |
| ❌ **DEVIATION** | Password complexity rules are shown as a **live checklist** below the fields. The PRD explicitly states: *"Password complexity is validated only when the user clicks Continue — there is no live checklist."* (AS-1.3). The design must remove the live checklist and instead surface unmet rules only on Continue click. |
| ❌ **DEVIATION** | Show/hide toggle is only visible on the **Password** field. The PRD requires: *"Eye icon on each field"* — i.e. the Confirm Password field also needs a toggle (AS-1.5). |

---

### ONB-02 — Account Setup: Create Account (password mismatch error state)

| Status | Finding |
|--------|---------|
| ✅ | Inline error shown on Confirm Password field when it doesn't match |
| ✅ | Password field border turns red to signal error |
| ℹ️ **NOTE** | Error copy reads "it does not match password." PRD says mismatch is shown as inline error but does not prescribe exact wording for this field. Consider aligning with the tone used across other inline errors ("Password does not match. Please re-enter."). |
| ❌ **DEVIATION** | The live complexity checklist is still shown in error state. Consistent with ONB-01 issue — this should only appear after a failed Continue attempt. |

---

### ONB-03 — Account Setup: Personal Data Collection

| Status | Finding |
|--------|---------|
| ✅ | Three fields: Mobile Number, National ID / Iqama, Date of Birth |
| ✅ | +966 read-only prefix shown in mobile field |
| ✅ | Placeholder in National ID field: "Starts with 1 (Saudi) or 2 (Iqama)" — good UX hint |
| ✅ | Step label: "Account Setup — Step 2 of 3 · Your details" |
| ✅ | Green informational banner: "These details must match your official documents exactly." (FR-P-015) |
| ✅ | Continue CTA |
| ✅ | Email address shown at top as read-only reference |
| ❌ **DEVIATION** | Date of Birth displays in `YYYY-MM-DD` format (placeholder shows `yyyy-mm-dd`). The PRD requires `DD/MM/YYYY` format (AS-2.4, FR-P-011). The input format and picker output must be corrected to DD/MM/YYYY. |
| ❌ **MISSING** | The Confirm Password show/hide toggle issue from ONB-01 flows through — the overall PRD says no API calls fire on this screen and Continue advances immediately, which the design correctly implies. But there is no sub-note about the "pre-fill" behaviour in later Identity Verification steps — the design should add helper text such as *"You'll be able to review and confirm these details in the next step."* (The image shows this text, so ✅ on second inspection.) |

---

### ONB-04 — Sign-In (with Email Verified badge)

| Status | Finding |
|--------|---------|
| ✅ | "Email verified" green badge shown prominently (AS-4.1, SI-P1.6) |
| ✅ | Confirmation message: "Your email is verified. Please sign in to continue." |
| ✅ | Email Address and Password fields |
| ✅ | "Forgot password?" link (SI-P1.5) |
| ✅ | "Create new account" link |
| ℹ️ **NOTE** | CTA label reads **"Login"**. PRD uses "Sign in" throughout all references. This is a minor copy inconsistency — unify to "Sign in" for consistency with the rest of the product vocabulary. |
| ❌ **MISSING** | The flow jumps from Personal Data (ONB-03) directly to Sign-In (ONB-04). The **"Check Your Inbox" screen (Account Setup Screen 3)** — AS-3.1 through AS-3.5 — is **entirely absent** from the canvas. This screen must show: the registered email read-only, three-step instructions, the "Go to sign in" CTA, the spam/promotions note, and the "Profile details saved. Verify your email before signing in." non-blocking notification. |

---

### ONB-05 — Identity Verification: Step 1 of 6 — Mobile Number

| Status | Finding |
|--------|---------|
| ✅ | Screen title: "Verify your mobile" (IV-1.1) |
| ✅ | Step label: "Identity Verification — Step 1 of 6 · Mobile number" |
| ✅ | Email address shown with "Email verified" badge (IV-1.1) |
| ✅ | Mobile number pre-filled and editable (+966 5012345 99) |
| ✅ | Helper text: "We'll send a 6-digit code to confirm this number." (IV-1.2) |
| ✅ | 6-step progress indicator at top |
| ✅ | Continue CTA |
| ❌ **MISSING** | **Mobile OTP screen (IV Step 2 of 6)** is absent. Required elements: masked mobile display, 6-digit OTP input, dual countdown timers (code expiry at 3 min, resend available at 60 sec), Verify CTA, Back button (IV-2.1 through IV-2.6). |
| ❌ **MISSING** | **Mobile Verified screen (IV Step 3 of 6)** is absent. Required elements: success icon, "Mobile verified" heading, lock message, verified number display, Continue CTA with no back navigation (IV-3.1, IV-3.2). |

---

### ONB-06 — Identity Verification: Step 4 of 6 — Confirm Your Identity

| Status | Finding |
|--------|---------|
| ✅ | Screen title: "Confirm your identity" (IV-4.1) |
| ✅ | Step label: "Identity Verification — Step 4 of 6 · Identity details" |
| ✅ | Green banner: "Make sure all details match your official government documents exactly. Mismatches are the most common cause of verification delays." (IV-4.1) |
| ✅ | National ID / Iqama pre-filled and editable |
| ✅ | Date of birth pre-filled and editable |
| ✅ | Continue CTA |
| ✅ | Stepper correctly shows checkmarks on steps 1–3, step 4 active |
| ❌ **DEVIATION** | Date of birth value in the design shows **"1998-01-81"** — an invalid date (day 81). This is a data error in the mockup and must be corrected before handoff. |
| ❌ **MISSING** | **Nafath Request screen (IV Step 5 of 6)** is absent. Required elements: auto-triggered Nafath call, large non-copyable 2-digit number, 3-minute countdown, "Open Nafath App" deep-link CTA only (no back), success / failure / timeout states, error retry paths (IV-5.1 through IV-5.5). |

---

### ONB-07 — Identity Verification: Step 6 of 6 — Identity Verified

| Status | Finding |
|--------|---------|
| ✅ | Step label: "Identity Verification — Step 6 of 6 · Confirmation" |
| ✅ | Success icon / checkmark |
| ✅ | "Identity verified" heading (IV-6.1) |
| ✅ | Message: "Your identity is confirmed. These details are now permanently linked to your account." (IV-6.1) |
| ✅ | Read-only summary: Full name (Darth Maul), National ID / Iqama, Date of birth (IV-6.2) |
| ✅ | Continue CTA with no back button (IV-6.3) |
| ❌ **MISSING** | Nafath screen (Step 5) as noted above — this screen assumes Nafath succeeded but the step that precedes it has no design. |

---

### ONB-08 — Business Verification: Step 1 of 3 — Business Details

| Status | Finding |
|--------|---------|
| ✅ | Screen title: "Business details" (BV-1.1) |
| ✅ | Step label: "Business Verification — Step 1 of 3 · Business details" |
| ✅ | UNN field: "10 digits starting with 7" placeholder |
| ✅ | VAT Registration Number field: "15 digits starting and ending with 3" |
| ✅ | Tax Identification Number field marked optional with "Optional — 10 digits if available." |
| ✅ | 3-step stepper with step 1 active |
| ✅ | Continue CTA |
| ❌ **DEVIATION** | The email address + verification badge visible on ONB-05 and ONB-09 is **absent on this screen**. The PRD requires (AS-4.2): *"Throughout Identity Verification and Business Verification, the user's email address is shown as a read-only reference."* This consistency break needs to be fixed. |
| ❌ **MISSING** | No error states designed for the 4 BV API outcomes specified in BV-1.6: UNN not found, UNN not active, owner identity mismatch, and service unavailable with Retry. These are critical for QA and developer handoff. |
| ❌ **MISSING** | **Confirm Your Business screen (BV Step 2 of 3)** is entirely absent. Required elements: "Confirm your business" heading, the retrieved business summary card (Business Legal Name, UNN, CR Number, VAT, TIN), Back and Confirm CTAs, the ownership commitment message (BV-2.1 through BV-2.3). |

---

### ONB-09 — Business Verification: Step 3 of 3 — Bank Account (Optional)

| Status | Finding |
|--------|---------|
| ✅ | Screen title: "Bank account (optional)" (BV-3.1) |
| ✅ | Step label: "Business Verification — Step 3 of 3 · Bank account" |
| ✅ | Email address + "Email verified" badge shown (BV-3.1) |
| ✅ | Informational note about financing applications and option to add later (BV-3.2) |
| ✅ | Bank Name dropdown: "Select a bank" |
| ✅ | IBAN field: "Enter a Saudi IBAN" |
| ✅ | "Add Later" CTA visible alongside "Continue" (BV-3.6) |
| ❌ **DEVIATION** | Both Bank Name and IBAN fields are marked with an asterisk (`*`), implying they are **required**. The PRD states the screen is optional — fields become required only if the user *chooses* to fill one of them (BV-3.3). The asterisk should be removed or replaced with a conditional-requirement note ("Required if filling out bank details"). |
| ℹ️ **NOTE** | The design shows a single "Continue" CTA. Clarify whether "Continue" here proceeds to the Account Verified screen (with IBAN verification) or maps to the IBAN Verification API call — the PRD states the API fires on Continue (BV-3.5). |

---

### ONB-10 — Account Verified

| Status | Finding |
|--------|---------|
| ✅ | Success icon/checkmark |
| ✅ | "Your account is verified" heading (AV-1.1) |
| ✅ | "You can now access all platform features." subheading (AV-1.1) |
| ✅ | "Go to Dashboard" CTA navigates to dashboard |
| ✅ | No outbound notification implied (AV-1.2) |

---

### ONB-11 — Dashboard (Single Business, Base State)

| Status | Finding |
|--------|---------|
| ✅ | Sidebar: Dashboard, Business Partners, Invoices, Payment Requests, Settings |
| ✅ | Business name "Dathomir Nightbrothers" shown in top navigation |
| ✅ | Session scoped to a single business — no selection screen shown |
| ❌ **MISSING** | The **verification status card** ("Your account is verified." — dismissible) required by DS-1.2 is absent on the first dashboard load. |
| ❌ **PLACEHOLDER** | The main content area shows debug text: *"Authentication is working. You reached this area through a user-scoped session plus URL-scoped business authorization."* This must be replaced with the actual dashboard content before any handoff. |

---

### ONB-12 — Dashboard with In-Session Business Switcher (open)

| Status | Finding |
|--------|---------|
| ✅ | Dropdown accessible from business name in top nav (MB-1.3) |
| ✅ | Dropdown header shows active business name |
| ✅ | "Add business" option included |
| ✅ | "Log out" option included |
| ❌ **MISSING** | **Multi-business selection screen** (MB-1.1, MB-1.2) — shown to users with 2+ businesses after sign-in before the dashboard — is not in the canvas. This screen must show business cards with the Legal Name in Arabic for each business. |
| ℹ️ **NOTE** | "Add business" in the switcher dropdown is a good affordance for the multi-business use case. Confirm with product whether this CTA should appear for single-business users or only after first business is verified. |

---

### CreateAccount-Web (239:68192) — Invited User: Create Account

| Status | Finding |
|--------|---------|
| ✅ | Invitation context shown: "Munawar Al Otaibi invited you to join Najd Wholesale." |
| ✅ | Email pre-filled and read-only: "The address your invitation was sent to. It cannot be changed." (FR-E-023) |
| ✅ | 4-step stepper: Create account → Your details → Verify email → Identity |
| ✅ | Password and Confirm password fields |
| ✅ | "Join" CTA — appropriate labelling for invitation context |
| ✅ | Bottom toast/notification: "Profile details saved. Verify your email before signing in." (AS-3.4) |
| ❌ **MISSING** | Steps 2–4 of the invited flow (Your details, Verify email, Identity) are not in the canvas. The engineering PRD (FR-E-021) requires: personal-details capture + mobile verification before access becomes active. All these must be designed. |
| ℹ️ **NOTE** | The notification appears on the Create Account screen in the invited flow. Per the PRD, this notification fires after personal details are saved (AS-3.4). Confirm whether the notification shown here is from the *previous* screen state or whether it's intentionally triggered on this screen. |

---

## 2. Missing Screens Summary

The following screens are **required by the PRD** but have **no design** in the canvas:

| # | Screen | PRD Reference | Priority |
|---|--------|--------------|----------|
| 1 | Account Setup Screen 3 — Check Your Inbox | AS-3.1 to AS-3.5 | Must Have |
| 2 | Identity Verification Step 2 of 6 — Mobile OTP | IV-2.1 to IV-2.6 | Must Have |
| 3 | Identity Verification Step 3 of 6 — Mobile Verified | IV-3.1, IV-3.2 | Must Have |
| 4 | Identity Verification Step 5 of 6 — Nafath Request | IV-5.1 to IV-5.5 | Must Have |
| 5 | Business Verification Step 2 of 3 — Confirm Your Business | BV-2.1 to BV-2.3 | Must Have |
| 6 | Multi-business selection screen (post sign-in) | MB-1.1, MB-1.2 | Must Have |
| 7 | Forgot Password — Email entry + reset confirmation | FP-P1.1 to FP-P1.7 | Must Have |
| 8 | Dashboard — Verification status dismissible card | DS-1.2 | Must Have |
| 9 | Invited flow: Steps 2–4 (Your details, Verify email, Identity) | FR-E-021, FR-E-022 | Must Have |
| 10 | Business verification API error states (BV-1.6 four variants) | BV-1.6 | Must Have |

---

## 3. PRD Deviations Summary

| # | Screen | Deviation | PRD Ref |
|---|--------|-----------|---------|
| 1 | ONB-01, ONB-02 | Live password complexity checklist shown; PRD requires validation only on Continue click | AS-1.3 |
| 2 | ONB-01 | Show/hide toggle missing on Confirm Password field | AS-1.5 |
| 3 | ONB-03 | Date of birth format is `YYYY-MM-DD`; PRD requires `DD/MM/YYYY` | AS-2.4, FR-P-011 |
| 4 | ONB-04 | CTA label is "Login"; product copy uses "Sign in" throughout | SI-P1.1 |
| 5 | ONB-06 | Date of birth value shows "1998-01-**81**" — invalid date in the mockup data | — |
| 6 | ONB-08 | Email + verification badge absent; required throughout Business Verification | AS-4.2 |
| 7 | ONB-09 | Asterisk on Bank Name and IBAN implies required; step is optional | BV-3.3 |

---

## 4. Access Management (Users Management Canvas) — Review Status

The **Users Management canvas (21:2721)** — which is expected to contain the Business Partner Management designs (Add Business Partner, Business Partners list, Trading Partner Record) — could **not be accessed** during this session due to Figma API rate limiting.

The following screens are defined in the PRD and must be reviewed in a follow-up session against the Users Management canvas:

| Screen | PRD Reference |
|--------|--------------|
| Business Partners list (empty state, populated, filters, search) | FR-BL.1 to FR-BL.9 |
| Add Business Partner form — UNN lookup flow (all 9 outcomes UC-1 to UC-9) | FR-PA.1 to FR-PA.15 |
| Trading Partner Record detail view (header, sections, edit) | FR-TR.1 to FR-TR.8 |
| Relationship management (Mark Active / Inactive, no Delete) | FR-BL.9, UC-25 to UC-27 |

---

## 5. Design System Observations

| Area | Observation |
|------|------------|
| **Stepper component (DS Stepper)** | Correctly implemented: done steps show charcoal-outlined checkmarks, current step is charcoal fill with number, upcoming steps are outlined. Consistent across all onboarding screens. |
| **DS Field** | Input fields use the 48px wrapper with 10px radius. Error states (red border + red hint) seen in ONB-02. Focus and disabled states not explicitly shown in error flow screens — design team should add focus and disabled variants. |
| **DS Button** | Primary button (dark, full width) used consistently for Continue / Login / Join. Ghost button used for "Add Later" (ONB-09). Sizes appear consistent at `lg`. |
| **DS Toast** | Notification in CreateAccount-Web uses the correct pill format (bottom-right, cream background, dismissible with ✕). |
| **Email badge** | "Email verified" badge is consistent (green, checkmark, small pill). "Email not verified" state (AS-4.2) has no design representation yet — this state must be designed for users who reach Identity Verification without having verified their email. |
| **Layout consistency** | ONB-01 through ONB-10 use a centered card layout on a cream background. ONB-11/ONB-12 switch to a full-width app shell with sidebar. The transition from onboarding card to dashboard shell is correct. |

---

## 6. Recommended Next Actions

### Immediate (before developer handoff)

1. **Design the 10 missing screens** listed in Section 2 — especially the OTP, Nafath, Confirm Business, and Check Inbox screens. These are all Must Have.
2. **Fix live checklist** on ONB-01 and ONB-02 — move complexity validation to Continue click only.
3. **Add show/hide toggle** to the Confirm Password field.
4. **Correct date format** to DD/MM/YYYY across ONB-03 and ONB-06.
5. **Add email + verification badge** to ONB-08 (Business Details screen).
6. **Remove required asterisks** from Bank Name and IBAN on ONB-09.
7. **Replace placeholder dashboard content** (ONB-11) with real content layout.
8. **Design the "Email not verified" badge state** for users who skip email verification before continuing.
9. **Add the dismissible verification status card** to ONB-11 (first dashboard load).

### Follow-up session

10. **Export and review the Users Management canvas** for Business Partner Management screens.
11. **Add Forgot Password screens** to the Onboarding canvas.
12. **Add multi-business landing/selection screen.**
13. **Add all invited user flow screens** (Steps 2–4 beyond the Create Account frame already designed).

---

*Review generated from Figma REST API export + full PRD cross-reference. All 13 Figma frames viewed directly. Design images saved to `fixtures/figma-review/`.*

---

## 6. UAT Environment Execution — 2026-08-19

**Environment:** `https://apex.qawafel.dev`
**Evidence folder:** `D:\Apex\Apex Project\quality-hub\evidence`
**Sessions reviewed:**

| Session | Time | Outcome |
|---------|------|---------|
| 15:28:52 | Blocked — Google SSO gate, no credentials | ❌ BLOCKED |
| 15:31:40 | Extended partial pass across all 4 test suites | ⚠️ PARTIAL |
| 16:06:51 | Limited-attempt happy-path run (single OTP attempt) | ✅ PASS |

---

### 6.1 Business Registration & Onboarding — UAT Results

#### 6.1.1 Happy-path outcome (16:06:51 run)

The full happy path completed end-to-end in UAT for account `qa.uat.20260819130703+limited@pearl.test`. All stages reached their expected terminal states:

| Stage | Result | Evidence |
|-------|--------|----------|
| Create account (credentials) | ✅ PASS | `002-signup-page-opened.png` |
| Personal details | ✅ PASS | `004-after-account-continue.png` |
| Check your inbox | ✅ PASS | `007-email-verification-gate.png` |
| Sign in to continue | ✅ PASS | `008-signin-page-after-gate.png` |
| Identity Verification Step 1 — Mobile | ✅ PASS | `012-entered-mobile-otp-step.png` |
| Identity Verification Step 2 — OTP | ✅ PASS (OTP: 037765) | `014-otp-submit-result-037765.png` |
| Identity Verification Step 3 — Mobile verified | ✅ PASS | `015-mobile-verified-step3.png` |
| Identity Verification Step 4 — Identity details | ✅ PASS | `016-identity-verification-step4-entry.png` |
| Identity Verification Step 5 — Nafath | ✅ PASS (number: 45) | `018-nafath-step5-request.png` |
| Identity Verification Step 6 — Identity confirmed | ✅ PASS | `020-identity-verified-step6.png` |
| Business Verification Step 1 — Business details | ✅ PASS | `022-business-details-filled.png` |
| Business Verification Step 2 — Confirm ownership | ✅ PASS | `024-business-confirm-step2.png` |
| Business Verification Step 3 — Bank account | ✅ PASS via Add Later | `026-bank-account-step3.png` |
| Account verified | ✅ PASS | `027-after-add-later.png` |

#### 6.1.2 Screens confirmed implemented (resolving earlier Figma gaps)

The following screens were flagged **missing in the Figma canvas** (Section 2) but are **confirmed present and functional in UAT**:

| Screen | Figma Status | UAT Status | Notes |
|--------|-------------|------------|-------|
| Check Your Inbox (Account Setup Step 3) | ❌ Missing in canvas | ✅ Live | `007-email-verification-gate.png` — fully compliant with AS-3.1 through AS-3.5 |
| Mobile OTP (IV Step 2 of 6) | ❌ Missing in canvas | ✅ Live | `012-entered-mobile-otp-step.png` — 6 separate input boxes, dual timers, Back + Verify CTAs |
| Mobile Verified (IV Step 3 of 6) | ❌ Missing in canvas | ✅ Live | `015-mobile-verified-step3.png` — correct lock message and verified number |
| Nafath Request (IV Step 5 of 6) | ❌ Missing in canvas | ✅ Live | `018-nafath-step5-request.png` — number, countdown, Open Nafath App CTA |
| Confirm Your Business (BV Step 2 of 3) | ❌ Missing in canvas | ✅ Live | `024-business-confirm-step2.png` — business card in Arabic, Back + Confirm |
| Account Verified | ✅ In canvas | ✅ Live | `027-after-add-later.png` |

> These screens must be backfilled into the Figma canvas to keep design artefacts in sync with the implemented product.

#### 6.1.3 PRD deviations confirmed in UAT

| # | Finding | PRD Ref | Severity |
|---|---------|---------|---------|
| **UAT-01** | **Live password complexity checklist is present in production.** The signup screen shows the rules live below the fields, not only on Continue click. Both the Figma design and the UAT implementation deviate from AS-1.3. Decision needed: align the PRD to match the current implementation, or fix the implementation. | AS-1.3 | Medium |
| **UAT-02** | **Date of birth input uses browser-native HTML date picker (`dd-----yyyy` format).** The execution summary confirms the field accepts `yyyy-MM-dd` internally. The PRD requires `DD/MM/YYYY`. The Identity Verified confirmation screen (Step 6) correctly displays `01/01/1985` in DD/MM/YYYY, but the input format itself is browser-native. | AS-2.4, FR-P-011 | Low |
| **UAT-03** | **Nafath Step 5 screen title is "Confirm your identity"** — the same title used for Step 4. The step label correctly differentiates them ("Step 5 of 6 · Nafath request"), but the heading is shared. This creates momentary confusion when landing on Step 5. | IV-5.1 | Low |
| **UAT-04** | **Continue button appears visually enabled on the empty Create Account form** (observed in 15:31:40 run). PRD requires: "Continue does not fire while required fields are empty or format invalid" (AS-1.3). Needs investigation to confirm whether the button submits on click or only triggers inline errors. | AS-1.3 | High |

#### 6.1.4 Bugs found in UAT

| # | Bug | Steps to Reproduce | Expected (PRD) | Actual | Evidence |
|---|-----|--------------------|---------------|--------|----------|
| **BUG-01** | **OTP rate limit lockout persists on Step 1 navigation.** After exhausting OTP attempts, the "Too many attempts" state with a 10-minute cooldown timer persists when the user navigates Back to Step 1. The Continue button re-enables on Step 1 but returning to Step 2 still shows the locked state. | On Step 2 enter wrong OTP until rate limited → click Back → click Continue from Step 1 | Step 1 Back should allow the user to re-enter their mobile and trigger a new OTP from a clean state | Rate limit lockout from Step 2 bleeds back to Step 1; "Too many attempts" shown on Step 2 re-entry even after Back navigation | `033-mobile-step1-continue-enabled-after-resend.png`, `036-037` |
| **BUG-02** | **Sticky session redirect after email verification.** After clicking the email verification link, returning to sign-in redirected to a previously authenticated workspace user instead of the newly registered account. | Complete Step 1 → Step 2 → click email verification link in a different browser tab → navigate to sign-in URL | Sign-in screen should be clean (email verified state) | Existing sticky session redirected to previously signed-in user | `013-signin-continue-redirected-to-existing-session.png` |
| **BUG-03** | **Google SSO gate appears on isolated onboarding continuation.** When resuming onboarding in a fresh browser context, the platform presents a Google Cloudflare SSO gate before the Qawafel sign-in page is reachable. | Sign out → open a fresh browser session → navigate to `apex.qawafel.dev` | Qawafel email/password sign-in screen | Google Cloudflare SSO ("Couldn't sign you in") | `016-google-sso-gate-new-account.png` |
| **BUG-04** | **Direct URL access to onboarding routes returns "Not Found" with no redirect.** Probing `/onboarding/...` routes directly without an active session returns a bare "Not Found" page with no redirect to sign-in. | Navigate directly to an onboarding step URL without an authenticated session | Redirect to sign-in or a friendly access-denied message | Raw "Not Found" page | `038-direct-route-probe-results.png` |

---

### 6.2 Business Partner Management — UAT Results

#### 6.2.1 Business Partners List Page

| Check | Result | Notes |
|-------|--------|-------|
| Page loads with header and search | ✅ PASS | `001-listing-default.png` |
| Search by business name / UNN | ✅ PASS | `003-search-by-unn.png` — search by UNN 7000000003 returned matching row |
| Search no-match empty state | ✅ PASS | `002-search-no-match.png` |
| View details from row | ✅ PASS | `005-view-details-opened.png` — opens Trading Partner Record for "Najd Hospitality Supplies" |

**UAT vs PRD deviations on this page:**

| # | Finding | PRD Ref | Severity |
|---|---------|---------|---------|
| **UAT-05** | **CTA label is "+ Add to network" not "+ Add Business Partner".** The page header button reads "+ Add to network" in both the live application and the detail page breadcrumb. PRD FR-BL.1 specifies "+ Add Business Partner". | FR-BL.1 | Medium |
| **UAT-06** | **Page subtitle copy differs.** Live: "Browse and manage the businesses in your network." PRD: "Manage your trading partners." | FR-BL.1 | Low |
| **UAT-07** | **Filter UI is a single "Filters" dropdown with a count badge and an Apply button**, not two separate filter dropdowns. PRD requires two distinct dropdowns: Verification Status and Status with their own defaults. The filter interaction and defaults have not been validated against the PRD specification. | FR-BL.8 | Medium |

#### 6.2.2 Trading Partner Record — Detail View

| Check | Result | Notes |
|-------|--------|-------|
| Page opens with business name heading | ✅ PASS | "Najd Hospitality Supplies" as H1 |
| "Business identity" section shown read-only | ✅ PASS | "These details cannot be edited here." |
| Business name and UNN visible | ✅ PASS | UNN 7000000005 shown |

**UAT vs PRD deviations on the detail view:**

| # | Finding | PRD Ref | Severity |
|---|---------|---------|---------|
| **UAT-08** | **"Remove from network" CTA exists on the detail view.** PRD explicitly states "No Delete option exists anywhere in the interface" (FR-BL.9) and the action menu should only offer Mark as Inactive / Mark as Active. "Remove from network" implies hard deletion or permanent removal, which violates the PRD's relationship-preservation model. Needs immediate clarification: does "Remove from network" delete the record or set it to Inactive? | FR-BL.9 | **Critical** |
| **UAT-09** | **"Manage partner" is a top-level CTA button on the detail view**, not a section-level edit control per FR-TR.6/FR-TR.7. The PRD's edit model is field-level or section-level inline editing. A single "Manage partner" top-level CTA may not align with the section-by-section edit model. | FR-TR.6, FR-TR.7 | Medium |

#### 6.2.3 Add to Network (UNN Lookup) — UAT Results

The "Add Business Partner" flow is surfaced in UAT as "Add to network" with a "Find a business" form heading.

| Check | Result | Notes |
|-------|--------|-------|
| Invalid UNN format validation | ✅ PASS | `003-invalid-unn-validation.png` — "must start with 7 and be 10 digits" |
| Successful UNN lookup renders result | ✅ PASS | `004-successful-unn-lookup.png` — UNN 7101000002 returned a result |

**Bugs in UNN lookup:**

| # | Bug | PRD Ref | Evidence |
|---|-----|---------|----------|
| **BUG-05** | **All differentiated UNN error states collapsed into a single generic error.** UNNs 7101000003, 7101000004, 7101000005, 7101000008, 7109999999 were tested — each was expected to trigger a distinct outcome (own UNN, existing active partner, existing inactive partner, UNN not found, registry outage). All returned "Business could not be verified" / "No business was found for this Unified National Number." The differentiated error messages specified in FR-PA.3 through FR-PA.8 (UC-6, UC-7, UC-8, UC-4, UC-5) are **not functional in UAT** with current test data. | FR-PA.3 to FR-PA.8 | `009` to `013` screenshots |

> Note: The test data seeding for differentiated UNN scenarios (own UNN, existing active/inactive, outage simulation) must be confirmed with the engineering team. The UAT environment may not have the required seed data to exercise these branches.

---

### 6.3 Combined Design + UAT Findings Matrix

This table consolidates design deviations and bugs across both the Figma review and the UAT execution.

| ID | Area | Type | Finding | Status |
|----|------|------|---------|--------|
| D-01 | Create Account | Design deviation | Live password complexity checklist (not on-Continue) | Confirmed in UAT — needs product decision |
| D-02 | Create Account | Design deviation | Confirm Password missing show/hide toggle | Not verified in UAT — needs UAT check |
| D-03 | Personal Details | Design deviation | Date input format is browser-native YYYY-MM-DD vs PRD DD/MM/YYYY | Confirmed in UAT |
| D-04 | Sign-in | Copy deviation | CTA says "Login" not "Sign in" | Needs UAT verification |
| D-05 | Identity details | Data error | ONB-06 mockup has "1998-01-81" invalid date | Figma-only artefact error |
| D-06 | Business Details | Design deviation | Email + badge missing on ONB-08 | Not confirmed in UAT — needs check |
| D-07 | Bank Account | Design deviation | Required asterisk on optional fields | Needs UAT verification |
| UAT-01 | Create Account | PRD deviation (confirmed) | Live checklist present in production | Confirmed |
| UAT-02 | Personal Details | PRD deviation (confirmed) | Date input is browser-native | Confirmed |
| UAT-03 | Nafath Step 5 | UX issue | "Confirm your identity" title shared with Step 4 | Confirmed |
| UAT-04 | Create Account | **Bug** | Continue visually enabled on empty form | Confirmed — needs investigation |
| UAT-05 | Business Partners | Copy deviation | "+ Add to network" vs "+ Add Business Partner" | Confirmed |
| UAT-06 | Business Partners | Copy deviation | Subtitle copy differs from PRD | Confirmed |
| UAT-07 | Business Partners | Design deviation | Single "Filters" dropdown vs two separate dropdowns | Confirmed |
| UAT-08 | Partner Detail | **Critical deviation** | "Remove from network" CTA may hard-delete vs PRD no-delete rule | **Confirmed — critical** |
| UAT-09 | Partner Detail | Design deviation | "Manage partner" top-level CTA vs section-level edit model | Confirmed |
| BUG-01 | OTP | **Bug** | Rate limit lockout persists on Back navigation to Step 1 | Confirmed |
| BUG-02 | Sign-in | **Bug** | Sticky session redirect after email verification | Confirmed |
| BUG-03 | Auth | **Bug** | Google SSO gate blocks isolated onboarding continuation | Confirmed |
| BUG-04 | Routing | **Bug** | Direct route access returns bare "Not Found" (no redirect) | Confirmed |
| BUG-05 | UNN Lookup | **Bug** | Differentiated UNN error states collapsed into generic error | Confirmed — may be test data gap |

---

### 6.4 UAT Recommended Actions

| Priority | Action |
|----------|--------|
| 🔴 Critical | Clarify "Remove from network" behaviour — confirm whether it hard-deletes or deactivates the relationship. If it hard-deletes, this violates FR-BL.9 and must be changed to "Mark as Inactive". |
| 🔴 High | Investigate BUG-04 (Continue button visually enabled on empty form) — confirm whether the button actually allows submission. |
| 🔴 High | Fix BUG-01 (OTP lockout persisting across Back navigation) — the user should be able to return to Step 1, re-enter their mobile, and get a fresh OTP without being locked. |
| 🟡 Medium | Confirm BUG-05 root cause with engineering — determine whether the differentiated UNN lookup error states require specific test data seeds in UAT or if the logic is not yet implemented. |
| 🟡 Medium | Fix BUG-03 (Google SSO gate blocking Qawafel-native login) — a user opening the UAT environment cold should reach the Qawafel sign-in page, not a Google SSO page. |
| 🟡 Medium | Fix BUG-02 (sticky session redirect after email verification) — sign-in continuation after email verification should always use the newly verified account's session context. |
| 🟡 Medium | Replace BUG-04 bare "Not Found" with a proper redirect to sign-in for unauthenticated route access. |
| 🟡 Medium | Product decision on D-01/UAT-01: align PRD AS-1.3 to the live checklist behaviour, or revert the implementation to validate-on-Continue. |
| 🟢 Low | Backfill 6 missing screens into Figma canvas (Section 2) — these are all confirmed live in UAT. |
| 🟢 Low | Align "Add to network" naming to PRD ("Add Business Partner") or update PRD to match the implemented copy. |
| 🟢 Low | Fix UAT-03 — give Step 5 (Nafath) a distinct screen title separate from Step 4. |

---

*UAT evidence reviewed from `quality-hub/evidence/2026-08-19T15-31-40` and `quality-hub/evidence/2026-08-19T16-06-51`. Screenshots viewed directly. Execution summaries cross-referenced with PRD requirements.*
