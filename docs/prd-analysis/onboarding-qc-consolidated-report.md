# QC Consolidated Report — Business Onboarding & Access Management
**Prepared by:** QC Engineering (AI-assisted)
**Report date:** 2026-08-19
**PRD source of truth:** `docs/Master APEX PRD Set.md`
**Figma file:** Design System V5 (`fZy0Y8eWmYWOxlErRbWd0D`) — Onboarding canvas (176:42377)
**UAT environment:** `https://apex.qawafel.dev`
**Evidence baseline:** `quality-hub/evidence/` — runs from 2026-06-17 through 2026-08-19

---

## Table of Contents

1. [Scope & Method](#1-scope--method)
2. [Delta Analysis](#2-delta-analysis)
3. [Unimplemented Screens & Functions](#3-unimplemented-screens--functions)
4. [Traceability Map](#4-traceability-map)
5. [Impact Assessment](#5-impact-assessment)
6. [Acceptance Criteria & Pass/Fail Checklist](#6-acceptance-criteria--passfail-checklist)

---

## 1. Scope & Method

### 1.1 Artefacts reviewed

| Artefact | Source | Coverage |
|----------|--------|----------|
| Product PRD | `docs/Master APEX PRD Set.md` — Business Registration, Sign-In & Verification + Business Partner Management | Full |
| Engineering PRD (alignment) | Same file — Onboarding alignment + Trading Partner sections | Full |
| Figma designs | Onboarding canvas: ONB-01 to ONB-12 + CreateAccount-Web (239:68192) | 13 frames reviewed |
| UAT evidence (today) | `2026-08-19T15-31-40` (4 test suites) and `2026-08-19T16-06-51` (limited-attempt) | ~65 screenshots + 6 execution summaries |
| UAT evidence (baseline) | `2026-08-02T14-53-29` (UNN lookup scenarios) and `2026-08-02T15-04-42` (listing & detail) | Regression reference |

### 1.2 Review methodology

Each PRD requirement was mapped to its corresponding Figma screen ID and UAT evidence. Gaps were classified into three categories:

- **Design gap** — present in PRD, absent or incorrect in Figma canvas
- **Implementation gap** — present in PRD/Design, absent or incorrect in UAT
- **Regression** — passed in a previous run, failing or changed in the current run

Severity ratings follow: 🔴 Critical · 🟠 High · 🟡 Medium · 🟢 Low

---

## 2. Delta Analysis

### 2.1 Design (Figma) vs PRD — Deviations

| ID | PRD Req | Figma Screen | Deviation | Severity |
|----|---------|-------------|-----------|----------|
| **DF-01** | AS-1.3 — password complexity validated on Continue only; no live checklist | ONB-01, ONB-02 | Live checklist shown below password field during typing. PRD explicitly prohibits a live checklist. | 🟠 High |
| **DF-02** | AS-1.5 — show/hide toggle on both password fields | ONB-01 | Toggle present on Password field only; absent on Confirm Password field | 🟡 Medium |
| **DF-03** | AS-2.4, FR-P-011 — Date of Birth input in DD/MM/YYYY | ONB-03 | Input placeholder shows `yyyy-mm-dd` (browser-native) instead of `DD/MM/YYYY` | 🟡 Medium |
| **DF-04** | AS-4.2 — email + verification badge shown throughout Business Verification | ONB-08 | Email and verification badge absent on Business Details screen; present on ONB-05 and ONB-09 | 🟡 Medium |
| **DF-05** | BV-3.3 — bank fields required only if user begins the step | ONB-09 | Bank Name and IBAN both carry required asterisk (`*`), implying mandatory status | 🟡 Medium |
| **DF-06** | SI-P1.1 — sign-in CTA label | ONB-04 | CTA reads "Login"; PRD vocabulary throughout uses "Sign in" | 🟢 Low |
| **DF-07** | — mockup data quality | ONB-06 | Date of birth field value shows "1998-01-**81**" — an invalid date | 🟢 Low |

### 2.2 Implementation (UAT) vs PRD — Deviations

| ID | PRD Req | UAT Evidence | Deviation | Severity |
|----|---------|-------------|-----------|----------|
| **DI-01** | AS-1.3 — no live complexity checklist | `002-signup-page-opened.png` (16:06:51) | Live checklist present in production. Matches Figma deviation DF-01 — both design and implementation deviate from PRD. | 🟠 High |
| **DI-02** | AS-2.4, FR-P-011 — DD/MM/YYYY input format | `004-after-account-continue.png` | Execution summary confirms field accepts `yyyy-MM-dd` internally. Browser-native date picker format. | 🟡 Medium |
| **DI-03** | IV-5.1 — unique screen title for Nafath step | `018-nafath-step5-request.png` | Nafath screen (Step 5 of 6) shares title "Confirm your identity" with Step 4. Step label differentiates them correctly but the heading is duplicated. | 🟢 Low |
| **DI-04** | AS-1.3 — Continue gated on required fields | `002-signup-empty-state.png` (15:31:40) | Execution summary notes "Continue button appeared enabled on empty Step 1 state." Needs investigation — may be a visual-only state issue or an actual submission bypass. | 🟠 High |
| **DI-05** | FR-BL.1 — page CTA label "+ Add Business Partner" | `001-listing-default.png` (Aug 02) | CTA reads "+ Add to network" in both Aug 02 and Aug 19. Consistent implementation but diverges from PRD label. | 🟡 Medium |
| **DI-06** | FR-BL.1 — subtitle "Manage your trading partners" | `001-listing-default.png` | Subtitle reads "Browse and manage the businesses in your network." | 🟢 Low |
| **DI-07** | FR-BL.8 — two separate filter dropdowns (Verification Status + Status) | `001-listing-default.png` (Aug 02) | Actual implementation uses two dropdowns with different labels: **"Relationship status"** (Active/Inactive) and **"Onboarding status"** (All/Onboarded/Pending) — not "Verification Status" and "Status" as PRD specifies. Aug 19 uses a single combined "Filters" button. | 🟡 Medium |
| **DI-08** | FR-BL.3 — columns: Business Name, UNN, Verification Status badge, Status badge, Action menu | `001-listing-default.png` (Aug 02) | Actual columns: Business name, UNN, Onboarding status, "View details" button. No Verification Status badge, no Status badge (Active/Inactive), no three-dot action menu. | 🟠 High |
| **DI-09** | FR-BL.9 — no Delete; actions: View, Edit, Mark as Inactive/Active | `001-actions-column-only-view-details.png` (Aug 02), `005-view-details-opened.png` (Aug 19) | Aug 02: only "View details" button per row — no three-dot menu, no Edit, no Mark as Inactive. Aug 19: "Remove from network" and "Manage partner" CTAs on detail page. Neither matches PRD's three-dot action model. | 🟠 High |
| **DI-10** | FR-BL.9 — no Delete option exists | `005-view-details-opened.png` (Aug 19) | "Remove from network" CTA exists on the Trading Partner Record detail view. If this performs hard deletion, it directly violates FR-BL.9. Absent from Aug 02 baseline — potential introduced regression. | 🔴 Critical |
| **DI-11** | FR-TR.6, FR-TR.7 — section-level or field-level edit controls | Aug 02 `Manage partner` edit page | Edit is accessed via a "Manage partner" CTA leading to a separate edit page ("Manage partner" heading), not inline section-level editing as described in PRD. | 🟡 Medium |

### 2.3 Implementation vs Design — Additional Deltas

| ID | Design (Figma) | UAT Actual | Delta |
|----|---------------|-----------|-------|
| **DD-01** | Check Your Inbox screen absent from canvas | Present in UAT (`007-email-verification-gate.png`) | Screen is built but not in Figma — design artefact debt |
| **DD-02** | Mobile OTP screen absent from canvas | Present in UAT (`012-entered-mobile-otp-step.png`) | Same |
| **DD-03** | Mobile Verified screen absent from canvas | Present in UAT (`015-mobile-verified-step3.png`) | Same |
| **DD-04** | Nafath Request screen absent from canvas | Present in UAT (`018-nafath-step5-request.png`) | Same |
| **DD-05** | Confirm Your Business absent from canvas | Present in UAT (`024-business-confirm-step2.png`) | Same |
| **DD-06** | ONB-09 bank fields show asterisk (required) | In UAT fields are labeled optional (consistent with PRD) | Figma design error — does not match implementation |

### 2.4 Confirmed Regressions (Aug 02 baseline → Aug 19)

| REG-ID | Scenario | Aug 02 Result | Aug 19 Result | Verdict |
|--------|----------|--------------|--------------|---------|
| **REG-01** | Own UNN check (7000000002) | ✅ "This is your current business. A business cannot add itself to its own network." | ❌ Returns "Business could not be verified" for equivalent UNN (7101000003) with Aug 19 test data | Probable regression — own-UNN check logic may have broken, or test data changed without seeding the check |
| **REG-02** | "Remove from network" CTA | ✅ Absent from detail view | ❌ Present in Aug 19 detail view ("Najd Hospitality Supplies") | New CTA introduced without PRD coverage — violates no-delete rule if it hard-deletes |
| **REG-03** | Differentiated UNN error messages | ✅ Own-UNN message confirmed working | ❌ All tested UNNs return same generic message | Active regression on at least the own-UNN check path |

---

## 3. Unimplemented Screens & Functions

### 3.1 Status legend

| Symbol | Meaning |
|--------|---------|
| ✅ Live | Confirmed working in UAT |
| 🎨 Design only | In Figma canvas, not confirmed in UAT |
| ❌ Missing | Absent from both Figma canvas and UAT |
| ⚠️ Partial | Present but incomplete vs PRD |
| 🚫 Blocked | Cannot progress due to dependency or blocker |

### 3.2 Onboarding flow — screen inventory

| Screen | PRD Section | Figma | UAT | Status | Rationale |
|--------|------------|-------|-----|--------|-----------|
| Create Account (Step 1 of 3) | AS-1.1–1.6 | ONB-01 ✅ | ✅ Live | ✅ Live (deviation DF-01, DF-02) | Minor PRD deviations present |
| Personal Data (Step 2 of 3) | AS-2.1–2.5 | ONB-03 ✅ | ✅ Live | ✅ Live (deviation DF-03) | Date format deviation |
| Check Your Inbox (Step 3 of 3) | AS-3.1–3.5 | ❌ Missing | ✅ Live | ⚠️ Figma debt | Screen built and PRD-compliant; missing from canvas |
| Sign-In screen | SI-P1.1–1.6 | ONB-04 ✅ | ✅ Live | ✅ Live | Minor copy deviation "Login" vs "Sign in" |
| Email verified badge — sign-in variant | AS-4.1 | ONB-04 ✅ | ✅ Live | ✅ Live | Confirmed in `011-email-verified-step3.png` |
| Mobile Number (IV Step 1 of 6) | IV-1.1–1.4 | ONB-05 ✅ | ✅ Live | ✅ Live | — |
| Mobile OTP (IV Step 2 of 6) | IV-2.1–2.6 | ❌ Missing | ✅ Live | ⚠️ Figma debt | OTP rate-limit lockout bug (BUG-01) |
| Mobile Verified (IV Step 3 of 6) | IV-3.1–3.2 | ❌ Missing | ✅ Live | ⚠️ Figma debt | — |
| Confirm Identity (IV Step 4 of 6) | IV-4.1–4.4 | ONB-06 ✅ | ✅ Live | ✅ Live | Invalid mockup date value (DF-07) |
| Nafath Request (IV Step 5 of 6) | IV-5.1–5.5 | ❌ Missing | ✅ Live | ⚠️ Figma debt | Title duplication with Step 4 (DI-03) |
| Nafath failure / rejection state | IV-5.4 | ❌ Missing | 🚫 Not tested | ❌ Missing | No evidence this state is implemented |
| Nafath timeout state | IV-5.5 | ❌ Missing | 🚫 Not tested | ❌ Missing | No evidence this state is implemented |
| Identity Verified (IV Step 6 of 6) | IV-6.1–6.3 | ONB-07 ✅ | ✅ Live | ✅ Live | — |
| Business Details (BV Step 1 of 3) | BV-1.1–1.6 | ONB-08 ✅ | ✅ Live | ✅ Live (DF-04) | Email badge missing in design; not confirmed absent in UAT |
| BV API error — UNN not found | BV-1.6 | ❌ Missing | ✅ Live | ⚠️ Figma debt | "Business could not be verified" shown in UAT |
| BV API error — UNN not active | BV-1.6 | ❌ Missing | 🚫 Not tested | ❌ Missing | No evidence this path is implemented |
| BV API error — owner mismatch | BV-1.6 | ❌ Missing | 🚫 Not tested | ❌ Missing | No evidence this path is implemented |
| BV API error — service unavailable + Retry | BV-1.6 | ❌ Missing | 🚫 Not tested | ❌ Missing | No evidence this path is implemented |
| Confirm Your Business (BV Step 2 of 3) | BV-2.1–2.3 | ❌ Missing | ✅ Live | ⚠️ Figma debt | Built and PRD-compliant per UAT evidence |
| Bank Account / IBAN (BV Step 3 of 3) | BV-3.1–3.6 | ONB-09 ✅ | ✅ Live | ✅ Live (DF-05) | Required asterisk deviation in design only |
| Account Verified | AV-1.1–1.2 | ONB-10 ✅ | ✅ Live | ✅ Live | — |
| Dashboard — first load | DS-1.1–1.2 | ONB-11 ✅ | ✅ Live | ⚠️ Partial | Verification status dismissible card (DS-1.2) not confirmed in UAT; dashboard shows placeholder content in Figma |
| In-session business switcher | MB-1.3 | ONB-12 ✅ | Not tested | 🎨 Design only | — |
| Multi-business selection screen | MB-1.1–1.2 | ❌ Missing | ❌ Not in UAT | ❌ Missing | No multi-business test account used |
| Forgot Password — email entry | FP-P1.1–1.4 | ❌ Missing | ❌ Not tested | ❌ Missing | Not tested in any UAT run |
| Forgot Password — reset screen | FP-P1.5–1.7 | ❌ Missing | ❌ Not tested | ❌ Missing | — |
| Sign-in — incorrect credentials error | SI-P1.2 | ❌ Missing | ❌ Not tested | ❌ Missing | — |
| OTP — max resend attempts reached state | IV-2.4 | ❌ Missing | 🚫 Blocked | 🚫 Blocked | Hit rate-limit before max-resend state reached |
| OTP — expired state | IV-2.5 | ❌ Missing | 🚫 Not tested | ❌ Missing | Timer not allowed to expire in any run |
| "Email not verified" badge state | AS-4.2 | ❌ Missing | 🚫 Not tested | ❌ Missing | All runs used verified emails before Identity Verification |
| Invited user — Create Account | FR-E-020, FR-E-022 | CreateAccount-Web ✅ | 🚫 Not tested | 🎨 Design only | Designed but invitation flow not executed in UAT |
| Invited user — Your details (Step 2) | FR-E-021 | ❌ Missing | 🚫 Not tested | ❌ Missing | — |
| Invited user — Verify email (Step 3) | FR-E-021 | ❌ Missing | 🚫 Not tested | ❌ Missing | — |
| Invited user — Identity (Step 4) | FR-E-021 | ❌ Missing | 🚫 Not tested | ❌ Missing | — |

### 3.3 Business Partner Management — screen inventory

| Screen | PRD Section | Figma | UAT | Status | Rationale |
|--------|------------|-------|-----|--------|-----------|
| Business Partners list — populated | FR-BL.3–5 | Not in Onboarding canvas | ✅ Live (DI-08) | ⚠️ Partial | Columns and badges differ from PRD |
| Business Partners list — empty state | FR-BL.2 | Not in canvas | 🚫 Not tested | 🚫 Not tested | No empty-state test run |
| Search — no match state | FR-BL.7 | Not in canvas | ✅ Live | ✅ Live | `002-search-no-match.png` |
| Search by UNN | FR-BL.7 | Not in canvas | ✅ Live | ✅ Live | `003-search-by-unn.png` |
| Filter — Verification Status | FR-BL.8 | Not in canvas | ⚠️ Partial (DI-07) | ⚠️ Partial | Labels and model differ |
| Filter — Status (Active/Inactive) | FR-BL.8 | Not in canvas | ⚠️ Partial (DI-07) | ⚠️ Partial | Implemented as "Relationship status" |
| Row action menu (three-dot) | FR-BL.9 | Not in canvas | ❌ Missing (DI-09) | ❌ Missing | Only "View details" inline button in Aug 02 |
| Add Business Partner form — UNN entry | FR-PA.1–2 | Not in canvas | ✅ Live | ✅ Live | Page titled "Add to network" |
| UNN lookup — own UNN blocked | FR-PA.6, UC-6 | Not in canvas | ❌ Regression (REG-01) | 🔴 Regressed | Worked Aug 02; broken Aug 19 |
| UNN lookup — active partner blocked | FR-PA.7, UC-7 | Not in canvas | ❌ Regression | 🔴 Regressed | Worked Aug 02; broken Aug 19 |
| UNN lookup — inactive partner / Reactivate | FR-PA.8, UC-8 | Not in canvas | ❌ Not reproduced | ❌ Not confirmed | Aug 02 had folder but result unclear |
| UNN lookup — not found in registry | FR-PA.4, UC-4 | Not in canvas | ✅ Live | ✅ Live | Generic "Business could not be verified" message confirmed |
| UNN lookup — registry unavailable | FR-PA.5, UC-5 | Not in canvas | 🚫 Not tested | ❌ Not confirmed | Cannot simulate outage in UAT |
| UNN lookup — Qawafel verified result | FR-PA.9, UC-1 | Not in canvas | ✅ Live | ✅ Live | `016/001-unn-lookup-result.png` (Aug 02) |
| UNN lookup — registry only result | FR-PA.10, UC-2 | Not in canvas | ✅ Live | ✅ Live | `004-successful-unn-lookup.png` |
| UNN edit resets form | FR-PA.11, UC-9 | Not in canvas | ✅ Live | ✅ Live | `008-edit-unn-resets-form` (Aug 02) |
| Save — CTA enabled after lookup | FR-PA.12 | Not in canvas | ✅ Live | ✅ Live | `006-cta-enabled-after-lookup` (Aug 02) |
| Save — blocked on validation failure | FR-PA.13 | Not in canvas | ✅ Live | ✅ Live | `003-save-blocked-field-validation` (Aug 02) |
| Save — success toast + navigate to record | FR-PA.14 | Not in canvas | ✅ Live | ✅ Live | `016/003-after-add-result.png` (Aug 02) |
| Cancel — discards form | FR-PA.15 | Not in canvas | 🚫 Not tested | 🚫 Not tested | — |
| Trading Partner Record — detail view | FR-TR.1–3 | Not in canvas | ✅ Live | ✅ Live | `005-view-details-opened.png` |
| Trading Partner Record — "Remove from network" | FR-BL.9 | Not in canvas | ✅ Present (DI-10) | 🔴 Violation | Not in PRD; violates no-delete rule |
| Contact Information — display + edit | FR-TR.6 | Not in canvas | ✅ Live | ✅ Live | `001-partner-detail-view.png` shows Contact info + Edit |
| National Address — display + edit | FR-TR.7 | Not in canvas | 🚫 Not scrolled | 🚫 Not confirmed | No screenshot of National Address section |
| Notes section | FR-TR.8 | Not in canvas | 🚫 Not confirmed | 🚫 Not confirmed | — |
| Mark as Inactive / Mark as Active | FR-BL.9, UC-25/26 | Not in canvas | ❌ Missing (DI-09) | ❌ Missing | No evidence of status-toggle action |

---

## 4. Traceability Map

### 4.1 Onboarding requirements

| PRD Req ID | Requirement (abbreviated) | Figma Frame | UAT Evidence | Status |
|-----------|--------------------------|------------|-------------|--------|
| AS-1.1 | 3 fields on Create Account | ONB-01 | `002-signup-page-opened.png` | ✅ |
| AS-1.2 | Email format + duplicate check | ONB-01 | `003-invalid-email-format.png` | ✅ |
| AS-1.3 | Password complexity on Continue only; no live checklist | ONB-01 ❌ | `002-signup-page-opened.png` ❌ | ❌ Deviated in both |
| AS-1.4 | Confirm Password mismatch inline error | ONB-02 ✅ | Not specifically tested | ⚠️ |
| AS-1.5 | Show/hide on both password fields | ONB-01 ❌ | Not confirmed | ❌ |
| AS-1.6 | Account created + verification email sent | ONB-01 | `005-after-continue.png` | ✅ |
| AS-2.1 | 3 fields on Personal Data | ONB-03 ✅ | `004-after-account-continue.png` | ✅ |
| AS-2.2 | +966 read-only prefix | ONB-03 ✅ | Confirmed | ✅ |
| AS-2.3 | National ID / Iqama format | ONB-03 ✅ | `008-invalid-national-id-error.png` | ✅ |
| AS-2.4 | Date of Birth DD/MM/YYYY | ONB-03 ❌ | ❌ Browser native | ❌ |
| AS-2.5 | No API calls on Personal Data | ONB-03 | Confirmed (immediate advance) | ✅ |
| AS-3.1 | Check Your Inbox — 3-step instructions | ❌ Missing in canvas | `007-email-verification-gate.png` ✅ | ⚠️ Figma debt |
| AS-3.2 | Spam folder note | ❌ Missing in canvas | Confirmed in UAT | ⚠️ Figma debt |
| AS-3.3 | No resend option | ❌ Missing in canvas | Confirmed in UAT | ⚠️ Figma debt |
| AS-3.4 | "Profile details saved" notification | CreateAccount-Web ✅ | Confirmed in UAT | ✅ |
| AS-3.5 | Go to sign-in navigates; auto-routes to IV | ❌ Missing in canvas | `008-signin-page-after-gate.png` ✅ | ⚠️ Figma debt |
| AS-4.1 | Email verified badge on sign-in screen | ONB-04 ✅ | `011-email-verified-step3.png` ✅ | ✅ |
| AS-4.2 | Email + badge throughout IV and BV | ONB-05 ✅, ONB-08 ❌ | Confirmed on IV steps; BV-Step-1 not confirmed | ⚠️ |
| IV-1.1–1.4 | Mobile Number step | ONB-05 ✅ | `012-entered-mobile-otp-step.png` ✅ | ✅ |
| IV-2.1–2.6 | Mobile OTP step | ❌ Missing in canvas | `012-013-014` ✅ + BUG-01 ❌ | ⚠️ Bug + Figma debt |
| IV-3.1–3.2 | Mobile Verified step | ❌ Missing in canvas | `015-mobile-verified-step3.png` ✅ | ⚠️ Figma debt |
| IV-4.1–4.4 | Confirm Identity step | ONB-06 ✅ | `016-017` ✅ | ✅ |
| IV-5.1–5.3 | Nafath Request — happy path | ❌ Missing in canvas | `018-019-020` ✅ | ⚠️ Figma debt |
| IV-5.4 | Nafath — failure/rejection state | ❌ Missing in canvas | ❌ Not tested | ❌ |
| IV-5.5 | Nafath — timeout state | ❌ Missing in canvas | ❌ Not tested | ❌ |
| IV-6.1–6.3 | Identity Verified step | ONB-07 ✅ | `020-identity-verified-step6.png` ✅ | ✅ |
| BV-1.1–1.4 | Business Details — fields | ONB-08 ✅ | `021-022` ✅ | ✅ |
| BV-1.5–1.6 | Business Details — UNN check + API errors | ONB-08 ✅ (form only) | `023` ✅ (happy path) | ⚠️ Error states missing |
| BV-2.1–2.3 | Confirm Your Business | ❌ Missing in canvas | `024-025` ✅ | ⚠️ Figma debt |
| BV-3.1–3.6 | Bank Account — optional | ONB-09 ✅ (DF-05) | `026-027` ✅ | ⚠️ Design asterisk deviation |
| AV-1.1–1.2 | Account Verified screen | ONB-10 ✅ | `027-after-add-later.png` ✅ | ✅ |
| DS-1.1 | All features accessible after BV | ONB-11 ✅ | Dashboard reached ✅ | ✅ |
| DS-1.2 | Verification status card — dismissible | ❌ Missing in canvas | ❌ Not confirmed in UAT | ❌ |
| MB-1.1–1.2 | Multi-business selection screen | ❌ Missing | ❌ Not tested | ❌ |
| MB-1.3 | In-session business switcher | ONB-12 ✅ | Not tested | 🎨 |
| FP-P1.1–1.7 | Forgot Password (Phase 1) | ❌ Missing | ❌ Not tested | ❌ |
| SI-P1.1–1.6 | Sign-In (Phase 1) | ONB-04 ✅ | ✅ Confirmed | ✅ |

### 4.2 Business Partner Management requirements

| PRD Req ID | Requirement (abbreviated) | Figma | UAT Evidence | Status |
|-----------|--------------------------|-------|-------------|--------|
| FR-BL.1 | "+ Add Business Partner" button in header | — | ✅ Present as "+ Add to network" (DI-05) | ⚠️ |
| FR-BL.2 | Empty state with heading + CTA | — | ❌ Not tested | ❌ |
| FR-BL.3 | 5 list columns per PRD | — | ❌ Columns differ (DI-08) | ❌ |
| FR-BL.4 | Verification Status badge auto-updates | — | ❌ Not tested | ❌ |
| FR-BL.5 | Active/Inactive Status badge | — | ❌ Not visible in current columns | ❌ |
| FR-BL.7 | Search by name + UNN | — | ✅ `003-search-by-unn.png` | ✅ |
| FR-BL.8 | Two filter dropdowns with correct defaults | — | ⚠️ Different labels + model (DI-07) | ⚠️ |
| FR-BL.9 | Three-dot action: View, Edit, Mark Inactive, no Delete | — | ❌ Missing three-dot; "Remove from network" present (DI-09, DI-10) | 🔴 |
| FR-PA.1 | Add button visible always | — | ✅ Confirmed | ✅ |
| FR-PA.2 | UNN format validation before lookup | — | ✅ `003-invalid-unn-validation.png` | ✅ |
| FR-PA.3 | Sequential lookup: own → active → inactive → Qawafel → registry | — | 🔴 Regressed (REG-01/03) | 🔴 |
| FR-PA.4 | UNN not found error | — | ✅ "Business could not be verified" shown | ✅ |
| FR-PA.5 | Registry unavailable error | — | ❌ Not tested | ❌ |
| FR-PA.6 | Own UNN error | — | 🔴 Regression (REG-01) | 🔴 |
| FR-PA.7 | Active partner "View Partner" link | — | 🔴 Regression (REG-03) | 🔴 |
| FR-PA.8 | Inactive partner "Reactivate" link | — | ❌ Not reproduced | ❌ |
| FR-PA.9 | Qawafel-verified UNN — auto-populate locked | — | ✅ Aug 02 `016` | ✅ |
| FR-PA.10 | Registry-only UNN — auto-populate | — | ✅ `004-successful-unn-lookup.png` | ✅ |
| FR-PA.11 | Edit UNN resets form | — | ✅ `008-edit-unn-resets-form` (Aug 02) | ✅ |
| FR-PA.12 | CTA enabled after successful lookup | — | ✅ `006-cta-enabled-after-lookup` (Aug 02) | ✅ |
| FR-PA.13 | Save blocked on validation failure | — | ✅ `003-save-blocked-field-validation` (Aug 02) | ✅ |
| FR-PA.14 | Success toast + navigate to record | — | ✅ `016/003` (Aug 02) | ✅ |
| FR-TR.1 | Record header: name, UNN, badge | — | ✅ Confirmed | ✅ |
| FR-TR.3 | Business Identity — read-only | — | ✅ "These details cannot be edited here." | ✅ |
| FR-TR.6 | Contact Information — editable | — | ✅ Edit button confirmed | ✅ |
| FR-TR.7 | National Address — editable | — | 🚫 Not confirmed | 🚫 |
| FR-TR.8 | Notes section — relationship-scoped | — | 🚫 Not confirmed | 🚫 |

---

## 5. Impact Assessment

### 5.1 Critical priority

| ID | Finding | Risk | Remediation |
|----|---------|------|------------|
| **DI-10 / REG-02** | **"Remove from network" CTA may hard-delete partner relationship** | Users accidentally permanently removing trading partners, violating FR-BL.9's no-delete rule. Irreversible data loss. High business impact. | Engineering must clarify: if hard-delete → replace with "Mark as Inactive"; if soft-deactivation → rename to "Mark as Inactive" and confirm data is preserved. Add UAT test to verify record persists. |
| **REG-01 / REG-03** | **Differentiated UNN lookup error messages broken** | Own-UNN check and active-partner duplicate check both return generic error. Users can attempt to add their own business or re-add an existing partner without a meaningful error, causing data confusion. | Engineering to investigate regression between Aug 02 and Aug 19. Verify lookup sequence logic (FR-PA.3) is intact. Re-seed UAT test data with the specific UNNs used in Aug 02. |

### 5.2 High priority

| ID | Finding | Risk | Remediation |
|----|---------|------|------------|
| **BUG-01** | **OTP rate-limit lockout persists through Back navigation** | User gets permanently trapped in the mobile OTP step with no recovery path except waiting the full 10-minute cooldown. Breaks the registration flow entirely for affected users. | Engineering: clear OTP lockout state when user navigates back to Step 1. Provide explicit error message on Step 1 explaining the cooldown and when they can retry. Design: add lockout error state to Mobile Number screen (IV Step 1). |
| **DI-04** | **Continue button may be enabled on empty Create Account form** | If Continue fires on an empty form, users bypass required-field validation and advance with no data, potentially causing silent failures downstream. | Engineering: validate the button is visually disabled (not just unclickable) when fields are empty. Add dedicated UAT test for the empty-state button. |
| **DI-08** | **Business Partners list columns do not match PRD** | Missing Verification Status badge (Verified/Not Registered) and Active/Inactive Status badge — these are key business signals. Filtering by Verification Status is also unsupported. | Design: update Figma for the Business Partners list to match the actual implementation columns. Product: confirm if the actual column model (Onboarding status) is the accepted implementation, and update PRD or align implementation. |
| **DI-09** | **Row action menu (three-dot) missing; View/Edit/Mark as Inactive not available** | Users cannot Mark as Inactive from the list. The Edit action flows through the detail view, which is a UX deviation. | Engineering: implement the three-dot action menu per FR-BL.9. Design: add action menu states to the Figma canvas. |
| **DF-01 / DI-01** | **Live password complexity checklist deviates from PRD** | The PRD rationale for on-Continue validation is to prevent premature complexity feedback. Both design and implementation show a live checklist. A product decision is required. | **Product decision:** (a) Amend PRD AS-1.3 to permit a live checklist (preferred UX), or (b) Remove the live checklist from implementation and Figma. |

### 5.3 Medium priority

| ID | Finding | Risk | Remediation |
|----|---------|------|------------|
| **BUG-02** | **Sticky session redirect after email verification** | User completing email verification in a tab while logged into a different account gets silently redirected to the wrong account. Data confusion; corrupted onboarding state. | Engineering: on email-verification callback, invalidate the existing session and load a clean sign-in screen scoped to the verified email. |
| **BUG-03** | **Google SSO gate blocks cold-start login** | New users or QA testers cannot access the UAT app in a fresh browser session. Blocks all unauthenticated test execution. | Infrastructure/DevOps: confirm whether the Cloudflare proxy rule is intentional for UAT. If so, provide valid SSO credentials to QA. If unintentional, remove the SSO gate for the UAT environment. |
| **DF-03 / DI-02** | **Date of Birth format is browser-native YYYY-MM-DD** | Inconsistent with Saudi date convention (DD/MM/YYYY) stated in PRD. Users may enter incorrect dates if the field format is ambiguous. | Engineering: implement a custom date picker or masked input enforcing DD/MM/YYYY format, not the browser-native HTML date input. |
| **DI-07** | **Filter labels and model differ from PRD** | "Relationship status" + "Onboarding status" vs "Verification Status" + "Status". Testers and users will encounter different terminology than documented. | Product/Design: align PRD terminology to the implemented model, or align implementation to PRD. Decide once and document. |
| **DD-01 to DD-06** | **5 implemented screens absent from Figma canvas** | Design artefacts are out of sync with the product. Future design changes will be made without reference to current implementation state. | Design: backfill Check Your Inbox, Mobile OTP, Mobile Verified, Nafath Request, and Confirm Your Business into the Figma Onboarding canvas. |
| **IV-5.4, IV-5.5** | **Nafath failure and timeout states not designed or tested** | These states will occur in production (network issues, user rejection, timeout). Without them, users have no recovery path. | Design: add Nafath error states to the canvas. Engineering: confirm error handling is implemented. QA: run targeted tests for these states in UAT. |

### 5.4 Low priority

| ID | Finding | Risk | Remediation |
|----|---------|------|------------|
| **BUG-04** | **Direct route returns bare "Not Found"** | Minor UX issue for developers and testers; does not affect real users who follow the normal sign-in flow. | Engineering: add a redirect from unauthenticated onboarding routes to the sign-in page with a return URL parameter. |
| **DF-06** | **"Login" vs "Sign in" copy on ONB-04** | Terminology inconsistency across the product. | Design/Copy: update button label to "Sign in" in Figma. Engineering: align implementation copy. |
| **DI-03** | **Nafath step shares title with Step 4** | Minor confusion on landing on Step 5 — same heading as previous step. | Design: add a distinct title for the Nafath step (e.g., "Verify with Nafath" or "Complete Nafath verification"). |
| **MB-1.1–1.2** | **Multi-business selection screen not designed or tested** | Affects multi-business users only. No known test accounts with multiple businesses. | Design: add multi-business selection screen to Figma canvas. QA: seed a multi-business test account for UAT coverage. |
| **FP-P1.1–1.7** | **Forgot Password flow entirely untested** | Full recovery path has no evidence. If broken in production, users have no way to regain access. | QA: prioritize Forgot Password as next test suite. Design: add screens to Figma canvas. |

---

## 6. Acceptance Criteria & Pass/Fail Checklist

### 6.1 Onboarding — pre-release acceptance criteria

#### AC-1: Account Setup

```
AC-1.1: Create Account screen has exactly 3 fields: Email, Password, Confirm Password.
AC-1.2: Email field validates format. Duplicate email shows inline error: "An account with this email already exists."
AC-1.3: Password complexity (≥12 chars, upper, lower, digit, special) is validated only on Continue click — not live.
AC-1.4: Confirm Password mismatch shows inline error on Continue.
AC-1.5: Show/hide toggle is present on BOTH password fields.
AC-1.6: Successful submission sends verification email and advances to Personal Data.

AC-2.1: Personal Data has exactly 3 fields: Mobile, National ID/Iqama, Date of Birth.
AC-2.2: +966 prefix is read-only. Mobile accepts 9-digit numbers starting with 5.
AC-2.3: National ID accepts 10-digit numbers starting with 1 or 2.
AC-2.4: Date of Birth input presents in DD/MM/YYYY format.
AC-2.5: Continue advances immediately; no API calls fire.

AC-3.1: Check Your Inbox shows 3-step instructions, the registered email read-only, and "Go to sign in" CTA.
AC-3.2: Spam/promotions note is visible.
AC-3.3: No resend option is present on this screen.
AC-3.4: "Profile details saved. Verify your email before signing in." notification appears.
```

#### AC-2: Identity Verification

```
AC-4.1: Mobile Number step shows pre-filled editable number, +966 prefix, helper text, Continue CTA.
AC-4.2: Continuing with a duplicate mobile shows inline error without advancing.
AC-4.3: OTP screen shows masked mobile, 6-digit input, dual timers (3-min expiry, 60-sec resend).
AC-4.4: Wrong OTP shows inline error and clears the field. Timer continues.
AC-4.5: After 60 seconds, Resend becomes available. After 3 resends: "Maximum resend attempts reached."
AC-4.6: Rate-limit lockout does NOT persist when user navigates Back to Step 1.
AC-4.7: Expired OTP disables input and shows regenerate/resend prompt.
AC-4.8: Back from OTP returns to Step 1 with mobile pre-filled and editable.
AC-4.9: Mobile Verified screen shows success icon, lock message, and verified number. No back navigation.
AC-4.10: Confirm Identity step shows pre-filled National ID and DOB. No API fires on Continue.
AC-4.11: Nafath screen auto-triggers on load. Shows 2-digit number, 3-min timer, Open Nafath App CTA. No back button.
AC-4.12: Nafath rejection state shows retry option with corrective message.
AC-4.13: Nafath timeout state greys out number and shows Regenerate option.
AC-4.14: Identity Verified screen shows read-only: Full name, National ID/Iqama, Date of birth.
```

#### AC-3: Business Verification

```
AC-5.1: Business Details step has UNN (required, starts with 7, 10 digits), VAT (required, 15 digits, starts and ends with 3), TIN (optional).
AC-5.2: Email + verification badge is visible throughout all Business Verification steps.
AC-5.3: Duplicate UNN check runs before API call. Specific inline error for own UNN and existing relationships.
AC-5.4: BV API failure states: UNN not found, UNN not active, owner mismatch, service unavailable with Retry — each shows a specific inline error.
AC-5.5: Confirm Your Business shows retrieved business card read-only. Back and Confirm CTAs.
AC-5.6: Confirm links the business permanently. Cannot undo after Confirm.
AC-5.7: Bank Account step is clearly optional. "Add Later" always visible. Required asterisk NOT shown on IBAN/Bank Name.
AC-5.8: IBAN format validated as SA + 22 digits before submission.
AC-5.9: Account Verified screen shows success icon, heading, and "Go to Dashboard" CTA.
```

#### AC-4: Business Partner Management

```
AC-6.1: Business Partners list has columns: Business Name, UNN, Verification Status badge (Verified/Not Registered), Status badge (Active/Inactive), Action menu.
AC-6.2: Default filter shows Active partners. Status filter and Verification Status filter have correct defaults.
AC-6.3: Action menu per row contains: View, Edit, Mark as Inactive (if Active) / Mark as Active (if Inactive). No Delete option.
AC-6.4: "Remove from network" does NOT appear anywhere in the interface.
AC-6.5: Own UNN entry shows: "This is your current business. A business cannot add itself to its own network." (or equivalent distinct message).
AC-6.6: Active partner UNN shows inline message with "View Partner" link.
AC-6.7: Inactive partner UNN shows inline message with "Reactivate" link. Clicking Reactivate restores Active state.
AC-6.8: Trading Partner Record shows Business Identity read-only with note: "These details cannot be edited here."
AC-6.9: Contact Information and National Address sections are editable inline. Saves to relationship only.
AC-6.10: No data is deleted when marking a partner Inactive — all relationship data is preserved.
```

---

### 6.2 Pass/Fail Checklist — current UAT state

| # | Check | PRD Ref | Result |
|---|-------|---------|--------|
| 1 | Create Account — 3 fields visible | AS-1.1 | ✅ Pass |
| 2 | Email duplicate validation | AS-1.2 | ✅ Pass |
| 3 | Password complexity validated on Continue only (no live checklist) | AS-1.3 | ❌ Fail — live checklist present |
| 4 | Show/hide toggle on Confirm Password | AS-1.5 | ❓ Unconfirmed |
| 5 | Continue disabled when fields empty on Create Account | AS-1.3 | ❌ Fail — button appeared enabled |
| 6 | Personal Data — DOB in DD/MM/YYYY format | AS-2.4 | ❌ Fail — browser native YYYY-MM-DD |
| 7 | Check Your Inbox — 3-step instructions + Go to sign-in | AS-3.1 | ✅ Pass |
| 8 | Email verified badge on sign-in screen | AS-4.1 | ✅ Pass |
| 9 | Mobile OTP — dual timers shown | IV-2.2 | ✅ Pass |
| 10 | OTP rate-limit lockout clears on Back to Step 1 | IV-2.6 | ❌ Fail — lockout persists |
| 11 | Nafath screen auto-triggers on load | IV-5.1 | ✅ Pass |
| 12 | Nafath failure state with retry | IV-5.4 | ❓ Not tested |
| 13 | Nafath timeout state with regenerate | IV-5.5 | ❓ Not tested |
| 14 | Email + badge visible on Business Details screen | AS-4.2 | ❓ Not confirmed |
| 15 | Business Details — UNN duplicate triggers specific errors | BV-1.5–1.6 | ❌ Fail — generic error returned |
| 16 | Confirm Your Business — business card read-only | BV-2.2 | ✅ Pass |
| 17 | Bank Account — fields NOT marked required | BV-3.3 | ❓ Unconfirmed (Figma shows asterisk) |
| 18 | Account Verified — Go to Dashboard | AV-1.1 | ✅ Pass |
| 19 | Forgot Password — email-only entry with safe messaging | FP-P1.2–3 | ❓ Not tested |
| 20 | Business Partners — 5 correct columns | FR-BL.3 | ❌ Fail — columns differ |
| 21 | Business Partners — three-dot action menu | FR-BL.9 | ❌ Fail — not present |
| 22 | "Remove from network" absent from interface | FR-BL.9 | ❌ Fail — present in Aug 19 |
| 23 | Own UNN triggers specific "current business" error | FR-PA.6 | ❌ Fail — regression |
| 24 | Active partner UNN shows "View Partner" link | FR-PA.7 | ❌ Fail — regression |
| 25 | Inactive partner UNN shows "Reactivate" link | FR-PA.8 | ❓ Not confirmed |
| 26 | UNN not found — correct message | FR-PA.4 | ✅ Pass |
| 27 | Edit UNN resets form | FR-PA.11 | ✅ Pass |
| 28 | Save blocked on validation failure | FR-PA.13 | ✅ Pass |
| 29 | Success toast on save + navigate to record | FR-PA.14 | ✅ Pass |
| 30 | Partner record Business Identity read-only | FR-TR.3 | ✅ Pass |
| 31 | Contact Information editable inline | FR-TR.6 | ✅ Pass |
| 32 | Direct route access redirects to sign-in | Security | ❌ Fail — returns bare "Not Found" |
| 33 | No sticky session redirect after email verification | SI | ❌ Fail — BUG-02 |

**Summary:** 14 ✅ Pass · 11 ❌ Fail · 8 ❓ Unconfirmed

---

### 6.3 Recommended test execution sequence (next cycle)

1. **Regression re-run** — UNN lookup differentiated errors with original Aug 02 UNNs (7000000002, 7000000003). Confirm if own-UNN check is broken or test-data dependent.
2. **"Remove from network" investigation** — click the button, verify whether the partner record is hard-deleted or moved to Inactive. Capture full state before and after.
3. **Forgot Password full flow** — Phase 1 (email link reset).
4. **OTP edge cases** — expired OTP state, max resend reached state.
5. **Nafath error states** — require a controlled environment where the Nafath callback can be simulated as rejected or timed out.
6. **Bank Account IBAN validation** — confirm required asterisk is not present in production and that partial entry (bank name without IBAN) is handled.
7. **Multi-business flow** — requires seeding a test account linked to two or more businesses.
8. **Continue button on empty form** — focused test: open Create Account, do not fill any fields, observe button state and click behavior.

---

*This report consolidates findings from the Figma design review (Section 1–5 of the companion document), all UAT execution sessions from 2026-08-19, and the Aug 02 regression baseline. Evidence files referenced are in `quality-hub/evidence/`. All PRD requirement IDs refer to `docs/Master APEX PRD Set.md`.*
