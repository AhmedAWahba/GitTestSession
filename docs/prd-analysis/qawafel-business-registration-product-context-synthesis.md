# Product Context Synthesis: Qawafel — Business Registration, Sign-In & Verification

**Format: Markdown with structured sections**
**Date: 2026-07-14**

---

## Executive Summary

This document consolidates all available product context for the Qawafel Business Registration, Sign-In & Verification feature into a single authoritative reference for QA, design, and engineering. Three source types were analysed: the PRD (pasted text, full Sections 1–6), the Lovable interactive prototype (fully traversed via browser automation), and the Figma design board (referenced but login-restricted). The prototype traversal revealed a **material structural divergence** from the PRD: the registration flow is implemented as a **3-phase, 9-screen flow** — not the PRD's 5-step monolithic flow. This divergence is the single most important finding in this synthesis. All generated Gherkin scenarios have been updated to reflect the prototype-verified flow as the ground truth.

---

## Source References

| Source | Type | Status | Link / Location |
|---|---|---|---|
| PRD — Business Registration, Sign-In & Verification | Product Requirements Document | ✅ Fully reviewed (pasted text, Sections 1–6) | Provided inline — no hosted link |
| PRD Analysis (QA-authored) | QA Analysis Document | ✅ Saved to workspace | `docs/prd-analysis/qawafel-business-registration-signin-verification.md` |
| Lovable Prototype | Interactive Prototype | ✅ Fully traversed (happy path + all error states enumerated) | https://prototype-build-forge.lovable.app/ |
| Figma Design Board | Visual Design Reference | ⚠️ Login-restricted — content not accessible | https://www.figma.com/board/soouXWmYkP9cgMM6v32uVW/APEX-Screens?node-id=29-115 |
| Gherkin Scenarios (QA-authored) | Test Scenarios | ✅ Generated and saved to workspace | `scenarios/prd1_business_registration/business-registration-signin-verification.feature` |

**Prototype test credentials (from prototype UI):**
- Single-business: `owner@alnoor.sa / Owner@123456789` — OTP: any 6-digit code starting with `1`
- Multi-business: `multi@alnoor.sa / Multi@123456789` — OTP: any 6-digit code starting with `1`

---

## Context Mapping: PRD → Prototype → Design

### Structural Divergence (Critical)

The PRD describes a **linear 5-step flow**. The prototype implements a **3-phase, 9-screen flow** with an intermediate authentication step. This is the primary gap between documentation and implementation.

| PRD Step | PRD Description | Prototype Screen | Prototype Phase |
|---|---|---|---|
| Step 1 | National ID, DOB, UNN, VAT, TIN, Mobile, Email (all on one screen) | **Split across two phases and three screens** — see below | — |
| — | *(not described)* | Screen 1.1: Email, Password, Confirm Password | Phase 1 — Account Setup |
| — | *(not described)* | Screen 1.2: Mobile Number (+966), National ID / Iqama, DOB | Phase 1 — Account Setup |
| Step 3 (Mobile OTP) | OTP sent to mobile; occurs before Nafath | Screen 1.3: **Email OTP** — 6-digit code sent to email address, not mobile | Phase 1 — Account Setup |
| — | *(not described)* | **Intermediate: "Sign in to continue"** — re-authentication with email+password after email verified | Post-Phase 1 |
| Step 2 (Password Setup) | Occurs after identity fields, before OTP | *(Captured at Screen 1.1 — before any identity fields)* | Phase 1 — Account Setup |
| Step 3 (Mobile OTP) | Mobile OTP before Nafath | Screen 2.1: Mobile number entry | Phase 2 — Identity Verification |
| — | *(not described)* | Screen 2.2: Mobile OTP — 6-digit code to masked mobile | Phase 2 — Identity Verification |
| Step 1 partial | National ID, DOB with informational banner | Screen 2.3: National ID / Iqama + DOB + informational banner | Phase 2 — Identity Verification |
| Step 4 (Nafath) | Nafath identity verification | Screen 2.4: Nafath KYC | Phase 2 — Identity Verification |
| Step 1 partial | UNN, VAT, TIN | Screen 3.1: UNN + Arabic Legal Business Name (read-only from registry) + VAT + TIN | Phase 3 — Business Verification |
| Step 5 (IBAN) | Optional IBAN | Screen 3.2: Bank account (optional) — Bank Name dropdown + IBAN | Phase 3 — Business Verification |
| Confirmation | Registration Confirmation Screen | Confirmation Screen: "Your account is verified" | Post-Phase 3 |

### Field-Level Mapping

| Field | PRD Location | Prototype Screen | Notes |
|---|---|---|---|
| Email Address | Step 1 (identity screen) | Screen 1.1 | Required. Uniqueness enforced at account creation. |
| Password | Step 2 | Screen 1.1 | Password and email collected together — not separate steps |
| Confirm Password | Step 2 | Screen 1.1 | — |
| Mobile Number | Step 1 | Screen 1.2 + Screen 2.1 | Entered at Screen 1.2, re-confirmed at Screen 2.1 before OTP send |
| National ID / Iqama | Step 1 | Screen 1.2 + Screen 2.3 | Entered at Screen 1.2, re-entered at Screen 2.3 for identity confirmation |
| Date of Birth | Step 1 | Screen 1.2 + Screen 2.3 | Same as National ID / Iqama — entered twice |
| UNN | Step 1 | Screen 3.1 | Moved to Business Verification phase |
| VAT Registration Number | Step 1 | Screen 3.1 | Moved to Business Verification phase |
| TIN (optional) | Step 1 | Screen 3.1 | Hint text in prototype: "10 digits if available" |
| Arabic Legal Business Name | Retrieved automatically at Step 1 Continue (PRD: not shown to user) | Screen 3.1 | **Displayed as read-only field** with source label "Retrieved from the commercial registry." — contradicts PRD which states it is silently stored |
| Bank Name | Step 5 | Screen 3.2 | 11 Saudi banks enumerated in dropdown |
| IBAN | Step 5 | Screen 3.2 | Format: SA + 22 digits. Button label is "Add Later" (capital L, as shown in prototype) |

### Account Creation Timing

| Source | When account is created |
|---|---|
| PRD | On Nafath success (Step 4) |
| Prototype | After successful **email OTP** verification (Screen 1.3) — the "Sign in to continue" intermediate screen confirms the account exists and prompts re-authentication before identity verification begins |

This is a **critical divergence** — the PRD states no account exists until Nafath, but the prototype creates the account at email OTP completion, then treats Nafath as identity verification layered on top of the existing account.

### Informational Banner Location

| Source | Location |
|---|---|
| PRD | Top of Step 1 (the first screen a user sees) |
| Prototype | Screen 2.3 "Confirm your identity" (National ID + DOB screen in Phase 2) |

---

## User Flows and Key Interactions

### Happy Path (Prototype-Verified, 3-Phase Flow)

```
PHASE 1 — ACCOUNT SETUP (3 screens)
│
├─ Screen 1.1: Create your account
│   Step indicator: "Account Setup — Step 1 of 3 · Create Account"
│   Fields: Email Address*, Password*, Confirm Password*
│   Button: Continue → "Creating account…" (loading state, all fields disabled)
│   Errors: Duplicate email, weak password, mismatched confirm password
│
├─ Screen 1.2: Your details
│   Step indicator: "Account Setup — Step 2 of 3 · Personal & Mobile Details"
│   Email shown as read-only context at top
│   Hint text: "You'll be able to review and confirm these details in the next step."
│   Fields: Mobile Number* (+966 prefix, read-only; SA flag), National ID / Iqama*, Date of Birth*
│   Button: Continue | Back
│   Errors: Duplicate mobile, invalid National ID / Iqama format, invalid date
│
└─ Screen 1.3: Verify your email
    Step indicator: "Account Setup — Step 3 of 3 · Email Verification"
    OTP: 6-digit, sent to EMAIL address, 3-minute timer, "Resend in 60s"
    Button: Verify (disabled until 6 digits entered) | Back
    Errors: Incorrect OTP ("Incorrect code. Please try again."),
            expired OTP ("Your code has expired."),
            max resends reached ("Maximum resend attempts reached…")
    On success → Account is created → "Sign in to continue" screen

INTERMEDIATE — Sign in to continue
│   Email pre-filled (read-only), password field
│   Message: "Your email is verified. Please sign in to continue to identity verification."
│   Button: Sign in | Forgot password?
│   On success → Phase 2 begins

PHASE 2 — IDENTITY VERIFICATION (4 screens)
│
├─ Screen 2.1: Verify your mobile (Step 1 of 4 · Mobile Number)
│   Email shown with "✓ Email verified" badge
│   Fields: Mobile Number* (+966 prefix, SA flag)
│   Hint: "We'll send a 6-digit code to confirm this number."
│   Button: Continue → "Checking mobile number…" → "Sending code…" (loading)
│   Errors: Duplicate mobile number
│
├─ Screen 2.2: Mobile OTP (Step 2 of 4 · Mobile Verification)
│   Masked mobile shown: "+966 5** *** 678"
│   OTP: 6-digit, sent to MOBILE, 3-minute timer, resend after 60s, max 3 resends
│   Button: Verify | Back
│   Errors: Incorrect OTP, expired OTP, max resends reached
│
├─ Screen 2.3: Confirm your identity (Step 3 of 4 · Identity Details)
│   Banner: "Make sure all details match your official government documents exactly.
│            Mismatches are the most common cause of verification delays."
│   Fields: National ID / Iqama*, Date of Birth*
│   Button: Continue (no Back button visible on this screen)
│   Errors: Invalid National ID / Iqama format
│
└─ Screen 2.4: Nafath KYC (Step 4 of 4 · Nafath KYC)
    On load: "Initiating Nafath request…" → 2-digit non-copyable number + 3-min timer
    CTA: "Open Nafath App" (deep-links to Nafath application)
    Platform polls Nafath API in background
    ─ SUCCESS: "✓ Identity Verified Successfully" → auto-advance to Phase 3
    ─ REJECTION: Red error + "Verification Rejected. Please ensure you are scanning
                  your own face in a well-lit area." + "Retry Verification" button
                  (no retry limit; fresh 2-digit number on retry)
    ─ TIMEOUT: Number greyed out + "Session Expired. For security, Nafath requests
                must be completed within 3 minutes." + "Regenerate Request" button
    ─ API FAILURE: "Nafath is temporarily unavailable. Please try again." + Retry button
    Back navigation: BLOCKED after Nafath success

PHASE 3 — BUSINESS VERIFICATION (2 screens)
│
├─ Screen 3.1: Business details (Step 1 of 2 · Business Details)
│   Fields:
│     Unified National Number (UNN)* — "10 digits starting with 7"
│     [After registry call] Arabic Legal Business Name — read-only
│       Source label: "Retrieved from the commercial registry."
│     VAT Registration Number* — "15 digits starting and ending with 3"
│     Tax Identification Number (TIN) — optional, "10 digits if available"
│   Button: Continue → "Verifying…" (loading, all fields disabled) → registry result shown
│   Errors:
│     UNN already registered on Qawafel (internal check)
│     UNN not found in commercial registry
│     UNN inactive in commercial registry
│     Owner identity mismatch (verified identity ≠ CR owner)
│     Business verification service unavailable
│     Invalid UNN format, invalid VAT format
│
└─ Screen 3.2: Bank account / IBAN (Step 2 of 2 · IBAN)
    Heading: "Bank account (optional)"
    Note: "Your bank account details are used for financing applications. You can
           complete verification and start using the platform without adding your IBAN.
           Add it any time in account settings."
    Fields: Bank Name (dropdown), IBAN ("SA + 22 digits")
    Bank dropdown options (11 banks):
      Saudi National Bank (SNB), Al Rajhi Bank, Riyad Bank, Banque Saudi Fransi,
      Arab National Bank, Saudi Investment Bank, Bank Albilad, Bank AlJazira,
      Alinma Bank, Emirates NBD KSA, SAB (Saudi Awwal Bank)
    Buttons: Add Later | Continue
    Errors: IBAN Not Found, IBAN Not Linked to Business, IBAN Verification Unavailable
    Add Later: Skips IBAN, saves no data → Confirmation Screen

CONFIRMATION SCREEN
    Icon: ✓
    Heading: "Your account is verified"
    Subtext: "You can now access all platform features."
    Button: "Go to Dashboard" → Verified dashboard (all features unlocked immediately)
```

### Sign-In Flow (Prototype-Verified)

```
Sign-In Screen
│   Fields: Email, Password
│   Button: Sign in
│   Links: Forgot password? | Create an account (→ registration)
│   Error: "Incorrect email or password. Please try again." (generic, no account disclosure)
│   On success → Mobile OTP screen
│
Mobile OTP Screen
│   Masked mobile shown
│   6-digit OTP, 3-min timer, resend after 60s, max 3 resends
│   Errors: Incorrect OTP, expired OTP, max resends reached
│   On success:
│     Single-business → Dashboard (direct)
│     Multi-business  → Business Selection Screen
│
Business Selection Screen (multi-business only)
│   Each card: Arabic Legal Business Name only
│   Select → Dashboard scoped to selected business
│   Business name shown in navigation bar
│
In-Session Switcher (multi-business only)
    Accessible from navigation bar (click active business name)
    Opens Business Selection Screen
    Switching rescopes all data immediately, no sign-out required
    Absent for single-business users
```

### Forgot Password Flow (PRD-specified; not traversed in prototype)

```
Sign-In → "Forgot password?" link
→ Enter National ID / Iqama + UNN + registered email
→ System validates combination
  ─ No match: "We couldn't verify those details. Please check and try again."
    (generic error, no account existence disclosure)
→ OTP sent to registered mobile (6-digit, 3-min timer, resend after 60s, max 3 resends)
→ Enter OTP
→ New Password + Confirm Password
  Password rules (live checklist): min 12 chars, 1 uppercase, 1 lowercase, 1 number,
  1 special character — same 5 rules as registration
  Next button disabled until all rules pass and fields match
→ Save → Success: "Your password has been updated successfully. You can now log in to
   your account and explore our services."
→ Login button → Sign-In screen
```

---

## Assumptions, Constraints & Risks

### Confirmed Divergences: Prototype Overrides PRD

| # | Finding | PRD Said | Prototype Shows | Impact |
|---|---|---|---|---|
| P1 | Account created after **email OTP** (Screen 1.3), not after Nafath | Account created at Nafath success | Account created at email OTP; Nafath is identity verification on top of existing account | **High** — changes when uniqueness conflicts first appear; changes orphaned-account risk model |
| P2 | **Email OTP** is the first OTP in the flow | Step 3 = mobile OTP before Nafath | Screen 1.3 = email OTP immediately after password setup | **High** — all OTP test data, stubs, and scenarios must target email first |
| P3 | National ID + DOB entered **twice** — Screen 1.2 and Screen 2.3 | Fields collected once at Step 1 | Fields entered at 1.2 and re-entered at 2.3 | **Medium** — consistency between entries must be validated; UX friction risk |
| P4 | Arabic Legal Business Name **displayed** as a read-only field on Screen 3.1 with source label | "retrieved automatically… and stored" (not shown to user) | Shown as read-only field: "Retrieved from the commercial registry." | **Medium** — design shows it; test must assert its presence and locked state |
| P5 | Password collected on **Screen 1.1** (same screen as email) | Password is Step 2, a separate screen after identity fields | Password on Screen 1.1 alongside email and confirm password | **Medium** — live checklist and complexity validation occur on the very first screen |
| P6 | IBAN skip button label is **"Add Later"** (capital L) | PRD text says "Add later" | Prototype button: "Add Later" | **Low** — copy verification test must match exact label including capitalisation |
| P7 | Mobile Number collected at Screen 1.2 **and** re-entered at Screen 2.1 | Single mobile entry at Step 1 | Mobile entered at 1.2, re-confirmed at 2.1 | **Medium** — open question whether 2.1 is pre-filled or requires fresh entry |
| P8 | Informational banner ("Make sure all details match…") appears at Screen 2.3 | Banner at the top of Step 1 (first screen) | Banner on Screen 2.3 — identity confirmation screen in Phase 2 | **Low** — banner placement test must target Screen 2.3, not the registration entry screen |

### Risk Register

| Risk | Source | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| Account orphaned after email OTP (Screen 1.3) if user abandons before completing Phase 2 or 3 | Prototype flow | H | H | Define resume / cleanup flow for partially completed registrations |
| National ID + DOB entered twice creates data consistency risk (typo at Screen 2.3 vs. 1.2) | Prototype | M | H | Design/Dev: pre-fill Screen 2.3 from Screen 1.2 data, or clearly confirm which entry wins |
| Commercial registry API outage blocks all registrations at Screen 3.1 | PRD + Prototype | M | H | Define error copy and graceful degradation; consider retry queue |
| No account lockout after repeated incorrect sign-in credentials defined | PRD (gap) | H | H | PM/Dev must define lockout policy — OWASP A07 |
| Nafath app not installed — deep-link fails silently, timer runs down | PRD (gap) | M | H | Define fallback: App Store / Play Store redirect or instructional copy |
| Password reset does not invalidate active sessions | PRD (gap) | M | H | Dev must confirm session invalidation behaviour |
| Figma board login-restricted — all design-level details unverified | Figma (inaccessible) | H | M | Design: share publicly or provide export for QA review |
| TIN field hint ("10 digits if available") implies format expectation not in PRD | Prototype | L | M | PM/Dev: confirm if TIN has any enforced format or max-length constraint |
| Race condition: concurrent registration with same email/mobile/UNN bypasses application-layer uniqueness | Data | M | H | DB-level unique constraints required; do not rely on application layer alone |
| Brute-force forgot password: identity combination guessing not rate-limited | Security | M | H | Rate-limit identity verification attempts in forgot password flow |

---

## Open Questions and Next Steps

### Blocking — Must Resolve Before Test Execution

1. **(Dev/PM)** When exactly is the account created — at email OTP (as prototype shows) or at Nafath success (as PRD states)? This governs the entire error state model for Phases 1 and 2.
2. **(Dev)** Is the National ID / Iqama and Date of Birth at Screen 2.3 pre-filled from Screen 1.2 data, or must the user re-type it?
3. **(PM/Dev)** What is the account lockout policy after repeated incorrect sign-in credentials? Currently undefined — security gap.
4. **(Dev)** Does a successful password reset invalidate all active sessions for that account?
5. **(Dev)** What is the error message and UI behaviour when the commercial registry API is unavailable or returns no match at Screen 3.1 Continue?
6. **(Design)** Figma board is login-restricted. Please share publicly or export screens so QA can verify design details against PRD and prototype.

### Non-Blocking — Resolve Before Sign-Off

7. **(Dev)** Nafath app not installed — is there a store redirect or instructional fallback when "Open Nafath App" deep-link fails?
8. **(Dev)** What is the session lifetime between Screen 1.3 (email OTP) and Phase 2? If a user pauses, do they resume from where they left off or restart?
9. **(Dev)** Is the mobile field on Screen 2.1 pre-filled from Screen 1.2, or does the user need to re-enter it?
10. **(PM)** Is the verification status card dismissal on the dashboard persistent across sessions, or does it reappear on next login?
11. **(PM)** Password reuse restriction on forgot password — can the user reset to the same password they previously used?
12. **(Dev)** What is the IBAN verification API timeout duration, and what does the UI show if the timeout is exceeded?
13. **(Design/PM)** TIN field hint says "10 digits if available" — is this a format constraint or just illustrative guidance? PRD says no format validation.
14. **(Dev)** Is mobile uniqueness checked at Screen 1.2 (Phase 1) or Screen 2.1 (Phase 2) — or at both points?

### Next Steps

| Action | Owner | Priority |
|---|---|---|
| Share Figma board with QA (public link or export) | Design | Immediate |
| Confirm account creation timing (email OTP vs. Nafath) and update PRD if needed | Dev + PM | Immediate |
| Define account lockout policy for sign-in attempts | PM + Dev | Immediate |
| Confirm session invalidation on password reset | Dev | Before test execution |
| Define commercial registry API failure error copy for Screen 3.1 | PM + Dev | Before test execution |
| Set up API stubs: Nafath (success / reject / timeout / unavailable), commercial registry (success / not found / inactive / owner mismatch / unavailable), IBAN (success / not found / not linked / unavailable) | Dev / QA | Before test execution |
| Seed test accounts: single-business, multi-business (2+), duplicate email, duplicate mobile, duplicate UNN, inactive UNN account | QA | Before test execution |
| Confirm whether Screen 2.3 pre-fills National ID + DOB from Screen 1.2 | Dev / Design | Before scenario authoring |
| Review and sign off Gherkin scenarios against confirmed flow | QA + PM | After open questions resolved |
| Host PRD document in workspace at `docs/prd/` for version-controlled traceability | PM | Before next sprint |

---

## Appendix: Source Access Notes

**PRD:** Provided as pasted text in the QA chat session. No hosted URL available. The full PRD analysis has been saved to `docs/prd-analysis/qawafel-business-registration-signin-verification.md`.

**Figma:** `https://www.figma.com/board/soouXWmYkP9cgMM6v32uVW/APEX-Screens?node-id=29-115` — Requires Figma account login with access to the APEX Screens board. All design comparisons in this document are marked as unverified pending access. To enable QA access: set sharing to "Anyone with the link can view" in Figma Share settings.

**Prototype:** `https://prototype-build-forge.lovable.app/` — Publicly accessible. Fully traversed via browser automation on 2026-07-14. All 9 screens of the happy path were walked through and all error state labels from the test data panel were captured. The prototype is the most reliable source of ground truth for field names, button labels, step indicators, loading state copy, and exact UI messages used in the generated Gherkin scenarios.

**Gherkin Scenarios:** `scenarios/prd1_business_registration/business-registration-signin-verification.feature` — Generated and saved to workspace. Reflects the prototype-verified 3-phase flow, not the PRD's 5-step description.
