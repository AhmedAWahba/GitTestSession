# ?? Test Analysis � PRD 1: Invoice to Payment Link (APEX Platform)

- **Version:** 1.0
- **Date:** April 28, 2026
- **Status:** Draft
- **Prepared by:** QA Team
- **PRD:** PRD 1 � Invoice to Payment Link � Minimum Viable Path (v1.0)
- **Design:** APEX � Payment Flow (Figma v.2 � PRD 1 Invoice to Payment Link MVP 2)

---

## Table of Contents

1. [Scope Overview](#1-scope-overview)
2. [Test Conditions by Feature](#2-test-conditions-by-feature)
   - 2.1 Sign-Up
   - 2.2 Business Profile Setup
   - 2.3 Home � Invoice List
   - 2.4 Buyer Business Management
   - 2.5 Invoice Creation
   - 2.6 Generate Payment Link *(Critical)*
   - 2.7 Payment Request Listings
   - 2.8 Admin � Payment Methods
3. [Gaps, Ambiguities & Risks](#3-gaps-ambiguities--risks)
4. [Open Questions](#4-open-questions)
5. [Entry & Exit Criteria](#5-entry--exit-criteria)

---

## 1. Scope Overview

- **Sign-Up** � FR-1.1 � FR-1.4 � Risk: `Medium`
- **Business Profile Setup** � FR-2.1 � FR-2.4 � Risk: `High`
- **Home � Invoice List** � FR-3.1 � FR-3.6 � Risk: `Medium`
- **Buyer Business Management** � FR-4.1 � FR-4.4 � Risk: `Medium`
- **Invoice Creation** � FR-5.1 � FR-5.6 � Risk: `High`
- **Generate Payment Link** � FR-6.1 � FR-6.11 � Risk: ? `Critical`
- **Payment Request Listings** � FR-7.1 � FR-7.7 � Risk: `High`
- **Admin � Payment Methods** � FR-8.1 � FR-8.3 � Risk: `High`

---

## 2. Test Conditions by Feature

---

### 2.1 Sign-Up (FR-1.1 � FR-1.4)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-1.1 | Register with valid email + password (8+ chars) | Positive | Redirect to Business Profile setup |
| TC-1.2 | Register with already-used email | Negative | Inline error: *"An account with this email already exists."* |
| TC-1.3 | Submit password with exactly 7 characters | Negative | Inline validation error before submission |
| TC-1.4 | Submit password with exactly 8 characters | Boundary | Registration succeeds |
| TC-1.5 | Submit with empty email field | Negative | Inline validation error |
| TC-1.6 | Submit with invalid email format (e.g. `user@`, `user.com`) | Negative | Inline validation error |
| TC-1.7 | Submit with empty password | Negative | Inline validation error |
| TC-1.8 | Verify no OTP, no email verification prompt, no SSO buttons, no forgot password link on the page | Design Check | None of these elements are present |
| TC-1.9 | Verify "Log in" link is present on sign-up screen (Figma: *"You don't have an account? Log in"*) | Design Check | Link is present and navigates to login |
| TC-1.10 | Successful registration redirects immediately to Business Profile � no intermediate screen | Positive | Direct redirect, no email verify step |

> ?? **Design Gap:** Figma frame `Signup 6` shows *"You don't have an account? Create new account"* � copy is inconsistent with other signup frames that show *"Log in"*. Needs alignment.

---

### 2.2 Business Profile Setup (FR-2.1 � FR-2.4)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-2.1 | All required fields filled (CR/Unified, phone, tax number, address) ? Save | Positive | Profile created, redirect to invoice list |
| TC-2.2 | Attempt to skip by navigating to `/invoices` before completing profile | Negative | Redirect back to profile setup screen |
| TC-2.3 | Attempt to navigate to `/buyers` before completing profile | Negative | Redirect back to profile setup screen |
| TC-2.4 | Email field is pre-filled with registered email and is read-only | Design Check | Field shows registration email, not editable |
| TC-2.5 | Submit with CR/Unified field empty | Negative | Inline validation error, form does not submit |
| TC-2.6 | Submit with phone number empty | Negative | Inline validation error |
| TC-2.7 | Submit with tax number empty | Negative | Inline validation error |
| TC-2.8 | Submit with address empty | Negative | Inline validation error |
| TC-2.9 | Verify CR field shows dual-label: *"CR Number"* / *"Unified Number"* as selection (per Figma) | Design Check | CR/Unified is a selectable toggle between the two options |
| TC-2.10 | After successful save, verify merchant profile record persists across login sessions | Data Integrity | Profile data retained |

> ?? **PRD Ambiguity (FR-2.2):** PRD says "CR number or Unified number (selection field)" � Figma confirms a dropdown/toggle between "CR Number" and "Unified Number" as two separate input labels. Engineering confirmation required.

---

### 2.3 Home � Invoice List (FR-3.1 � FR-3.6)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-3.1 | Login with completed profile ? lands on invoice list | Positive | Invoice list is the first screen shown |
| TC-3.2 | Invoice table shows all 5 columns: Invoice No., Buyer Name, Invoice Date, Total Amount (SAR), Status | Design Check | All columns present and populated |
| TC-3.3 | Status badge shows exactly `Sent`, `Paid`, or `Cancelled` � no other values | Design Check | Only 3 status values |
| TC-3.4 | Click "Create Invoice" CTA ? navigates to invoice creation screen | Positive | Correct navigation |
| TC-3.5 | Invoice list with zero invoices shows empty state message + Create Invoice CTA | Edge Case | No blank table; empty state UI displayed |
| TC-3.6 | Verify no filter controls, sort controls, or search bar on invoice table | Out-of-Scope Check | None present |
| TC-3.7 | Verify no PO-linked column or document relationship column is present | Out-of-Scope Check | Not present |

---

### 2.4 Buyer Business Management (FR-4.1 � FR-4.4)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-4.1 | Add buyer with only business name + email (minimum required) | Positive | Buyer saved, appears in listing and invoice dropdown |
| TC-4.2 | Add buyer with all optional fields (CR/Unified, phone, tax number, address) | Positive | All fields saved and displayed correctly |
| TC-4.3 | Attempt to add buyer with no business name | Negative | Inline validation error |
| TC-4.4 | Attempt to add buyer with no email | Negative | Inline validation error |
| TC-4.5 | Attempt to add buyer with invalid email format | Negative | Inline validation error |
| TC-4.6 | Edit existing buyer record ? verify changes reflect in listing and invoice dropdown | Positive | Updated values persist everywhere |
| TC-4.7 | Delete buyer (Figma shows "Delete Business" action) ? verify removed from listing and dropdown | Positive / Destructive | Buyer removed � **Note: PRD does not mention delete. Figma shows it. Needs PRD confirmation.** |
| TC-4.8 | Buyer dropdown on invoice creation form is searchable | Design Check | Typing filters results in real time |
| TC-4.9 | Buyers listing shows: business name, CR/Unified number, email, phone | Design Check | All 4 columns present |
| TC-4.10 | Add two buyers with identical email � verify uniqueness enforcement at buyer level | Edge Case | **PRD is silent � gap to clarify with product** |

> ?? **Design Gap:** Figma frame `Frame 1984080222` shows "Delete Business" and "Edit Business" via a context menu. **Delete is not mentioned in the PRD (FR-4.3 only covers edit).** Needs product decision.

---

### 2.5 Invoice Creation (FR-5.1 � FR-5.6)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-5.1 | Create invoice ? verify auto-generated number follows `INV-YY-XXXXXX` format | Positive | Number assigned; user cannot edit it |
| TC-5.2 | Invoice number increments sequentially on each new invoice | Positive | Sequential and unique per invoice |
| TC-5.3 | Seller info block is pre-populated (business name, CR/Unified, tax number, address) and read-only | Design Check | Fields non-editable on invoice form |
| TC-5.4 | Select buyer from searchable dropdown ? buyer fields pre-fill (name, email, phone) | Positive | Pre-fill occurs on selection |
| TC-5.5 | Attempt to submit invoice with no buyer selected | Negative | Inline validation error |
| TC-5.6 | Enter valid positive numeric Total Amount (SAR) | Positive | Invoice created successfully |
| TC-5.7 | Enter 0 as total amount | Boundary/Negative | Validation error � must be positive |
| TC-5.8 | Enter negative amount | Negative | Validation error |
| TC-5.9 | Enter non-numeric characters in amount field | Negative | Validation error |
| TC-5.10 | Submit with empty amount field | Negative | Validation error |
| TC-5.11 | Verify no line item fields, no quantity, no unit price, no VAT field on form | Out-of-Scope Check | None present |
| TC-5.12 | Verify no ZATCA status field; confirm no ZATCA API call fires on create (check Network tab) | Out-of-Scope Check | No ZATCA call |
| TC-5.13 | Invoice created with `Sent` status ? "Generate Payment Link" CTA is visible | Positive | CTA visible on Sent invoice |
| TC-5.14 | Invoice in `Paid` status ? "Generate Payment Link" CTA is not visible | Negative | CTA absent |
| TC-5.15 | Invoice in `Cancelled` status ? "Generate Payment Link" CTA is not visible | Negative | CTA absent |
| TC-5.16 | Sent invoice with an existing active payment link ? "Generate Payment Link" CTA hidden/disabled | Edge Case | Only one active link per invoice (OQ-4 resolved) |

---

### 2.6 Generate Payment Link (FR-6.1 � FR-6.11) � ? *Critical Path*

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-6.1 | Click "Generate Payment Link" on Sent invoice ? Create Payment Request modal/page opens | Positive | Modal opens over invoice detail |
| TC-6.2 | Click Cancel or X button ? modal closes with no payment request created | Negative | No record created |
| TC-6.3 | Verify Invoice Details block shows: Invoice No., Email, Total Amount, Buyer Name, Phone � all read-only | Design Check | 5 fields pre-populated and non-editable |
| TC-6.4 | Net Payable = Invoice Total (VAT = 0, Credit Notes = 0) � value is read-only | Design Check | Values correct and non-editable |
| TC-6.5 | "Send Now" is the default selected send timing option on modal open | Design Check | Send Now pre-selected |
| TC-6.6 | Select "Send Later" ? Scheduled Date + Scheduled Time pickers appear | Positive | Both pickers visible |
| TC-6.7 | Select "Send Later" + enter a past date ? inline validation error | Negative | Error: date must be in the future |
| TC-6.8 | Select "Send Later" + enter today's date with a past time ? inline validation error | Boundary | Validation error shown |
| TC-6.9 | Select "Send Later" + leave date empty ? attempt submit | Negative | Required field error |
| TC-6.10 | Payment Link Expiration has no pre-selected option on open | Design Check | No radio pre-selected |
| TC-6.11 | Select each expiry option: 7 Days / 15 Days / 30 Days / 45 Days | Positive | Each option is individually selectable |
| TC-6.12 | Submit with no expiry option selected | Negative | Inline validation error |
| TC-6.13 | Verify all 4 payment methods shown: Credit Card, Apple Pay, SADAD, AlRajhi BNPL | Design Check | All 4 checkboxes present |
| TC-6.14 | Submit with no payment method selected | Negative | Inline error: *"Select at least one payment method."* |
| TC-6.15 | Select only one payment method and submit all other fields valid | Positive | Form submits successfully |
| TC-6.16 | Each payment method shows its fee info (Mada Fees + Card Fees / Apple Pay basis / SADAD % / BNPL %) | Design Check | Fee labels drawn from admin payment method config |
| TC-6.17 | Net payable < SAR 1,500 (BNPL minimum) ? BNPL shows warning and is non-selectable | Boundary | Warning shown, checkbox disabled |
| TC-6.18 | Net payable = SAR 1,500 (exact minimum threshold) ? BNPL is selectable | Boundary | No warning, BNPL available |
| TC-6.19 | Net payable > SAR 20,000 (BNPL upper bound per OQ-9) ? verify BNPL behavior | Boundary | **PRD gap � upper threshold behavior not specified. To clarify.** |
| TC-6.20 | Submit valid form ? unique payment link generated, payment request record saved | Positive | Record created, share options displayed |
| TC-6.21 | Share options shown after creation: Copy Link, WhatsApp, Email | Design Check | All 3 share actions present |
| TC-6.22 | Copy Link ? link copied to clipboard successfully | Positive | Clipboard contains valid payment URL |
| TC-6.23 | WhatsApp share ? opens WhatsApp with pre-filled message containing the link | Positive | WhatsApp intent triggered |
| TC-6.24 | Email share ? opens email client or modal with pre-filled body containing the link | Positive | Email intent triggered |
| TC-6.25 | Verify each share action is logged with timestamp + channel (copy / WhatsApp / email) | Auditability | Log record created per share event |
| TC-6.26 | Inactive payment method (deactivated in admin) is NOT shown in payment method checkboxes | Integration | Method absent from seller form |

> ?? **Figma Observation:** The Create Payment Request modal shows a **Notes/Memo field** (`????? ????????` � "Add Note") and a **"Sending Mode"** section label not mentioned in the PRD. Needs product confirmation on scope ? see OQ-6, OQ-7.

---

### 2.7 Payment Request Listings (FR-7.1 � FR-7.7)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-7.1 | Created Payment Requests table shows: request no., linked invoice no., buyer name, amount, expiry date, send type, status | Design Check | All 7 columns present and populated |
| TC-7.2 | Status values in Created listing: Active, Expired, Paid, Cancelled only | Design Check | Only these 4 status values used |
| TC-7.3 | Cancel an Active payment request from the listing | Positive | Status ? Cancelled; linked invoice ? Sent |
| TC-7.4 | Cancel an Active payment request from the detail view | Positive | Same outcome as TC-7.3 |
| TC-7.5 | Attempt to cancel an Expired request | Negative | Cancel action absent or disabled |
| TC-7.6 | Attempt to cancel a Paid request | Negative | Cancel action absent or disabled |
| TC-7.7 | Re-share an Active payment link from the listing | Positive | Share options modal opens (copy, WhatsApp, email) |
| TC-7.8 | Attempt to re-share a Cancelled payment link | Negative | Share action absent or disabled |
| TC-7.9 | Received Payment Requests table shows: request no., seller name, amount, expiry date, status | Design Check | All 5 columns present |
| TC-7.10 | Send Later request ? does NOT appear in buyer's Received listing before scheduled date | Negative | Absent from buyer view |
| TC-7.11 | Send Later request ? appears in buyer's Received listing on/after the scheduled date | Positive | Visible from scheduled date/time onward |
| TC-7.12 | Received listing has no Pay Now or checkout CTA | Out-of-Scope Check | No payment action present |
| TC-7.13 | Cancel an Active payment link ? linked invoice automatically returns to Sent status (OQ-5: auto-cancel) | Integration | Automatic � no manual action required |
| TC-7.14 | Cancel the linked invoice ? active payment link auto-cancels (OQ-5) | Integration | Payment link status ? Cancelled automatically |

> ?? **Figma Observation:** Figma frame `28` shows a **"Cancellation Reason"** field in the cancel confirmation modal. Not mentioned in PRD (FR-7.3). Needs product confirmation ? see OQ-8.

---

### 2.8 Admin � Payment Methods (FR-8.1 � FR-8.3)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-8.1 | Login with Qawafel-linked account ? admin interface is shown | Positive | Admin screens shown instead of business screens |
| TC-8.2 | Login with standard business account ? standard business interface shown | Negative | Admin screens NOT visible |
| TC-8.3 | Payment Methods listing shows: method name, type, fee structure, status (Active/Inactive), Create CTA | Design Check | All columns and CTA present |
| TC-8.4 | Create a new payment method via the admin form | Positive | Method saved, appears in listing |
| TC-8.5 | Edit existing payment method (fee values, name) ? changes reflect in seller-facing form | Positive | Updated values propagate to seller view |
| TC-8.6 | Toggle a payment method to Inactive | Positive | Method hidden from seller's Create Payment Request form |
| TC-8.7 | Re-activate an Inactive payment method ? it reappears on the seller form | Positive | Method visible again in seller form |
| TC-8.8 | Verify Qawafel business record + admin-linked user are seeded on initial environment deployment | Setup Check | Admin login works on fresh staging environment |
| TC-8.9 | BNPL minimum threshold (SAR 1,500) is configurable in admin payment method settings | Config Check | Value editable in admin; drives FR-6.9 warning on seller form |

---

## 3. Gaps, Ambiguities & Risks

### ?? Critical

- **G-10 � Admin**
  Admin detection method (OQ-3) still open � email domain vs linkage to Qawafel business record ID.
  ? Must be resolved before FR-8.1 can be implemented or tested.

### ?? High

- **G-2 � Business Profile**
  CR vs Unified � selection mechanism (toggle vs dropdown vs radio) not fully defined in PRD.
  ? Confirm exact UX with design team.

- **G-8 � Payment Link**
  One active link per invoice (OQ-4 resolved) � system enforcement mechanism not described.
  ? Confirm: CTA hidden, disabled, or inline error on second attempt?

### ?? Medium

- **G-3 � Buyer Management**
  Delete buyer action visible in Figma but not mentioned in PRD (FR-4.3 covers edit only).
  ? Product to confirm if delete is in scope for this phase.

- **G-4 � Buyer Management**
  No uniqueness rule defined for buyer email across different selling businesses.
  ? Confirm if duplicate buyer emails across sellers are allowed.

- **G-5 � Payment Link**
  Notes/Memo field shown in Figma (`????? ????????`) not referenced in PRD.
  ? Confirm if notes field is in scope; if yes, add FR and test conditions.

- **G-6 � Payment Link**
  BNPL upper threshold (SAR 20,000 per OQ-9) � behavior above the threshold not specified.
  ? Define: warning only, or also non-selectable?

- **G-7 � Payment Link**
  "Sending Mode" section label in Figma differs from PRD's Send Now/Send Later radio description (FR-6.4).
  ? Align PRD wording with final Figma before engineering build.

### ?? Low

- **G-1 � Sign-Up**
  Copy inconsistency in Figma: `Signup 6` shows *"Create new account"* where other frames show *"Log in"*.
  ? Align copy across all signup frames before dev handoff.

- **G-9 � Cancel Payment Request**
  Cancellation Reason field in Figma (frame 28) not mentioned in PRD (FR-7.3).
  ? Confirm if reason capture is in scope for this phase.

- **G-11 � General**
  No session timeout or token refresh behavior defined in NFRs.
  ? Clarify expected session duration for desktop web.

---


## 4. Open Questions

All questions below are **unanswered**. They are scoped to the five user-facing screens in this delivery: Sign-Up, Login, Buyer Business Management, Invoice Creation, and Generate Payment Link. A scenario context is provided before each group so stakeholders can understand why the question matters before answering it.

---

### Screen 1 — Sign-Up (FR-1.1 to FR-1.4)

**Scenario:** A new seller visits the platform for the first time and creates an account using email and password. The PRD specifies a minimum password length of 8 characters and states there is no OTP, no email verification step, no SSO, and no forgot-password link on this screen. After a successful registration the seller is redirected directly to the Business Profile setup. The screen has a "Log in" link for users who already have an account.

- **Q1** — Source: PRD FR-1.1 / Figma Signup frames
  The Figma frame "Signup 6" shows the copy "You don't have an account? Create new account" while all other Signup frames show "Log in". Which copy is final, and what does this link actually navigate to — the login screen or somewhere else?
  *Impacts: TC-1.9 — link label and destination cannot be asserted until resolved*

- **Q2** — Source: PRD FR-1.3
  What are the full password rules beyond the 8-character minimum? Is there an upper length limit? Are uppercase letters, numbers, or special characters required or prohibited?
  *Impacts: TC-1.3, TC-1.4 — boundary tests cannot be written without the complete ruleset*

- **Q3** — Source: PRD FR-1.1
  After a successful registration, is a session immediately established so the seller is already logged in when they land on Business Profile? Or are they required to log in separately after registering?
  *Impacts: Determines whether post-registration navigation is a redirect within an active session or a new authentication step*

- **Q4** — Source: PRD FR-1.1
  If the registration API call fails (e.g. server error, network timeout), what does the seller see? Is there an inline error, a retry CTA, or a generic error page?
  *Impacts: Error-path test coverage for TC-1.1 — currently no error condition is defined for backend failures*

- **Q5** — Source: PRD FR-1.2
  Is there a rate limit or lockout on registration attempts? For example, if a user submits the form 10 times in a row with invalid data, does the system apply any throttling or CAPTCHA?
  *Impacts: Security testing scope — undefined rate-limit behaviour is an OWASP risk*

---

### Screen 2 — Login

**Scenario:** An existing seller returns to the platform and logs in with their registered email and password. The Figma file contains a "Login 1" frame. The PRD describes the registration flow in detail but provides almost no specification for the login screen behaviour — including what happens on failed attempts, session duration, and post-login redirect logic.

- **Q6** — Source: PRD (Login not described) / Figma Login 1
  What fields are shown on the login screen — email and password only, or are there additional inputs? Does the login screen show the same "no SSO, no forgot-password" restrictions that apply to sign-up?
  *Impacts: Login screen design-check test conditions are completely absent from the current analysis*

- **Q7** — Source: PRD (not specified)
  What happens after a set number of consecutive failed login attempts? Is there an account lockout, a CAPTCHA challenge, a cooldown timer, or no restriction at all?
  *Impacts: Security boundary tests — this is a standard brute-force risk (OWASP A07)*

- **Q8** — Source: PRD (not specified)
  Is there a "Forgot Password" or "Reset Password" link on the login screen? If yes, what is the reset flow — email link, OTP to phone, or other?
  *Impacts: Determines whether a forgot-password test path exists anywhere in this delivery*

- **Q9** — Source: PRD (not specified)
  After a successful login, where is the seller redirected? Is the destination different depending on whether the business profile is complete or not (e.g., profile-complete user lands on invoice list; incomplete user is prompted to finish the profile)?
  *Impacts: TC-2.2, TC-2.3 — profile-enforcement redirect logic is only testable once the login destination is defined*

- **Q10** — Source: PRD (not specified)
  What is the session duration for a logged-in seller? Is there an inactivity timeout? If the session expires mid-task (e.g., while filling the invoice form), what happens to unsaved input?
  *Impacts: Session management — gap G-11; timeout behaviour is undefined for the entire platform*

- **Q11** — Source: PRD (not specified)
  Can a seller be logged in on multiple browsers or devices simultaneously using the same account? If yes, is each session independent, or does a login on one device invalidate others?
  *Impacts: Concurrent session test conditions — not defined anywhere in the PRD*

---

### Screen 3 — Buyer Business Management (FR-4.1 to FR-4.4)

**Scenario:** The seller navigates to the Buyers section to manage the businesses they invoice. A buyer record has two required fields (business name, email) and several optional fields (CR/Unified number, phone, tax number, address). The seller can add, edit, and — according to the Figma design — also delete buyer records. Buyers are selected from a searchable dropdown when creating invoices. The PRD does not define whether buyer records are isolated per seller, whether buyer emails must be unique, or what happens to related invoices if a buyer is deleted.

- **Q12** — Source: Figma frame 1984080222 / PRD FR-4.3
  Figma shows both an "Edit Business" and a "Delete Business" action in the buyer context menu. The PRD only describes edit (FR-4.3) — delete is not mentioned. Is buyer deletion in scope for this phase?
  *Impacts: TC-4.7 — the test condition is marked pending PRD confirmation; gap G-3*

- **Q13** — Source: PRD (not specified)
  If buyer deletion is in scope, what happens to existing invoices that reference the deleted buyer? Are they retained with the buyer's name frozen on them, or do they become orphaned records?
  *Impacts: Data integrity — cascading delete behaviour must be defined before this test can be written*

- **Q14** — Source: PRD FR-4.1
  Is the buyer's email required to be unique within the seller's own buyer list, globally across all sellers, or is there no uniqueness enforcement at all?
  *Impacts: TC-4.10 — this test condition currently notes "PRD is silent"; it cannot be executed without this answer*

- **Q15** — Source: PRD FR-4.1
  Is there a maximum number of buyer records a seller can create? If yes, what happens when the limit is reached — an inline error, a disabled "Add Buyer" button, or a soft warning?
  *Impacts: Edge case for large seller accounts — not defined in any FR*

- **Q16** — Source: PRD FR-4.4
  When an existing buyer record is edited (e.g., the email or business name is changed), do those changes immediately reflect on previously created invoices that referenced that buyer?
  *Impacts: TC-4.6 — "updated values persist everywhere" is asserted but the scope of "everywhere" (including past invoices) is not confirmed*

- **Q17** — Source: PRD FR-4.1 / FR-4.2
  Is the buyer list isolated per seller account, or could two sellers on the platform share or see each other's buyer records?
  *Impacts: Data isolation — a security concern if buyer PII (email, phone, CR number) is accessible across seller accounts*

---

### Screen 4 — Invoice Creation (FR-5.1 to FR-5.6)

**Scenario:** The seller creates a new invoice by selecting a buyer from a searchable dropdown and entering a Total Amount in SAR. The invoice number is auto-generated (INV-YY-XXXXXX) and cannot be edited. Seller information is pre-filled from the business profile and is read-only. The invoice is always created in "Sent" status, which enables the Generate Payment Link CTA. The PRD does not define the amount field's upper bound, decimal precision, whether the invoice date is manual or automatic, or what triggers the Sent-to-Paid status transition.

- **Q18** — Source: PRD FR-5.3
  What is the maximum allowed Total Amount (SAR)? Is there an upper value beyond which the system rejects the invoice with a validation error?
  *Impacts: TC-5.6 — the upper boundary test condition (TC-5.7 covers 0; no upper bound test exists)*

- **Q19** — Source: PRD FR-5.3
  Does the Total Amount field accept decimal values (e.g. SAR 1,500.75)? If yes, how many decimal places are allowed — 2 (standard SAR), or more?
  *Impacts: Boundary tests for TC-5.6 through TC-5.10 — decimal input handling is undefined*

- **Q20** — Source: PRD FR-5.1
  Is the invoice date automatically set to today's creation date (read-only), or can the seller pick a custom date? Is there a separate "due date" field distinct from the payment link expiry date?
  *Impacts: Invoice form design-check — a date field is visible in the invoice table (TC-3.2) but its source and editability are not defined in the PRD*

- **Q21** — Source: PRD FR-5.5
  Can the seller cancel an invoice they have already created? If yes, under which status conditions (e.g., only while Sent, not after a payment link is active)? What is the cancellation UI — a button, a context menu action, a confirmation modal?
  *Impacts: Manual cancellation path is not covered in any test condition; only auto-cancel via payment link is described*

- **Q22** — Source: PRD FR-5.5
  What triggers the invoice status to transition from Sent to Paid? Is the change automatic upon payment gateway confirmation, or does the seller manually mark it as paid? How quickly does the status update appear in the invoice list?
  *Impacts: TC-5.13 through TC-5.16, TC-7.3 — the entire CTA visibility and payment link flow depends on this transition*

- **Q23** — Source: PRD FR-5.1
  If the buyer dropdown contains no records (the seller has not added any buyers yet), what does the invoice creation screen show — an empty dropdown, an inline prompt to add a buyer first, or a redirect to the Buyers screen?
  *Impacts: Empty-state UX for new sellers — not described in PRD or Figma; currently no test condition covers this path*

- **Q24** — Source: PRD FR-5.1
  Is there a Notes or Description field on the invoice creation form, or is the only seller-entered content the Total Amount and the buyer selection?
  *Impacts: If a notes field exists, test conditions for character limits and special characters are needed*

---

### Screen 5 — Generate Payment Link (FR-6.1 to FR-6.11)

**Scenario:** From a Sent invoice, the seller opens the Create Payment Request modal. The modal shows pre-filled invoice details (read-only), a Send Now / Send Later option, a payment link expiry selector (7/15/30/45 days), and payment method checkboxes (Credit Card, Apple Pay, SADAD, AlRajhi BNPL). BNPL is disabled below SAR 1,500. On submission a unique link is created and can be shared via Copy, WhatsApp, or Email. The Figma design adds a Notes/Memo field and a "Sending Mode" section label that are not in the PRD. The buyer-facing page, delivery channel, timezone, expiry mechanism, and partial payment behaviour are all undefined.

- **Q25** — Source: Figma — Create Payment Request modal / PRD FR-6.4
  The Figma modal contains a Notes/Memo field labelled "Add Note" (اضافة الملاحظة) that is not mentioned in the PRD. Is this field in scope for this phase? If yes — is it optional or required, and does the buyer see it on the payment page?
  *Impacts: TC-6.x needs a new condition if confirmed in scope; gap G-5*

- **Q26** — Source: Figma — Create Payment Request modal / PRD FR-6.4
  Figma groups the Send Now/Send Later controls under a separate "Sending Mode" section header that the PRD does not describe (FR-6.4 only mentions a simple radio choice). Does "Sending Mode" introduce any additional sending options beyond these two (e.g. recurring, triggered on a condition)?
  *Impacts: TC-6.5, TC-6.6 — if extra options exist, new test conditions are required; gap G-7*

- **Q27** — Source: PRD FR-6.9
  What is the upper invoice amount threshold for AlRajhi BNPL (referenced as SAR 20,000 in design discussions)? When the net payable exceeds this upper bound, is BNPL disabled with a warning only, or is there an additional hard block?
  *Impacts: TC-6.19 — upper boundary test condition cannot be written without this; gap G-6*

- **Q28** — Source: PRD FR-6.2
  When the seller selects "Send Now" and submits the form, through which channel is the payment link delivered to the buyer — email only, SMS only, both, or is the channel configurable per request?
  *Impacts: TC-6.5 — the Send Now delivery path cannot be end-to-end tested without knowing the channel*

- **Q29** — Source: PRD FR-6.7
  What timezone is applied to the "Send Later" date and time picker — Saudi Arabia Standard Time (AST, UTC+3) fixed, or the seller's browser locale? What happens if the seller is in a different timezone?
  *Impacts: TC-6.6 through TC-6.9 — all scheduled delivery tests require timezone behaviour to be confirmed*

- **Q30** — Source: PRD FR-6.3
  What does the buyer-facing payment page display? Specifically: is the invoice number shown, is the seller's business name and branding visible, and are the payment method options drawn from what the seller selected or from all active methods?
  *Impacts: No buyer-facing design check exists in the current test conditions — this is a complete coverage gap*

- **Q31** — Source: PRD FR-6.3
  Is the buyer required to log in or verify their identity before accessing the payment page via the link? Or does the link work for anyone who has the URL (anonymous access)?
  *Impacts: Security — if anonymous access is intended, a test must verify the link cannot be guessed or enumerated*

- **Q32** — Source: PRD FR-6.5
  After successful payment by the buyer, does the seller receive a real-time notification? If yes, through which channel (in-app notification, email, SMS, or all three)?
  *Impacts: Post-payment seller experience — not covered in any current test condition*

- **Q33** — Source: PRD FR-6.10
  What mechanism triggers the payment link status change from Active to Expired when the expiry date/time is reached — a scheduled background job, or a real-time check at the moment the buyer opens the link?
  *Impacts: TC-6.11 — expiry tests cannot define expected timing behaviour without this*

- **Q34** — Source: PRD FR-6.3
  Must the buyer pay the full net payable amount in a single transaction, or can partial payments be made? If partial payment is supported, does the payment link status stay Active until the balance is settled?
  *Impacts: Partial payment handling is not addressed in any FR — if supported it requires a new set of test conditions*

- **Q35** — Source: PRD FR-6.10
  After a payment link is cancelled or expires, can the seller generate a new payment request for the same invoice? The PRD permits only one active link at a time but is silent on whether a new request can follow a closed one.
  *Impacts: TC-5.16 and TC-7.3 — the regeneration path after link closure is not tested*

---

> **Open Question Count: 35**
> - Screen 1 (Sign-Up): Q1 – Q5
> - Screen 2 (Login): Q6 – Q11
> - Screen 3 (Buyer Business Management): Q12 – Q17
> - Screen 4 (Invoice Creation): Q18 – Q24
> - Screen 5 (Generate Payment Link): Q25 – Q35



---

## 5. Entry & Exit Criteria

### Entry Criteria

- [ ] Feature deployed to staging environment
- [ ] Qawafel admin business record and at least one admin-linked user seeded on staging
- [ ] Payment method fee values configured in admin *(OQ-1 resolved - same as current)*
- [ ] AlRajhi BNPL minimum threshold confirmed as SAR 1,500 *(OQ-2 resolved)*
- [ ] AlRajhi BNPL maximum threshold behavior above SAR 20,000 clarified *(G-6 / Q27)*
- [ ] Admin detection mechanism resolved and implemented *(OQ-3 / G-10)*
- [ ] Single active link enforcement confirmed and implemented *(G-8)*

### Exit Criteria

- [ ] All **Must Have** FRs covered by at least one positive test and one negative/boundary test
- [ ] All **Critical** and **High** risk gaps (G-2, G-8, G-10) resolved or formally accepted as risk
- [ ] Zero open P1 (blocker) defects
- [ ] Audit log verified for all share events *(FR-6.11 / NFR Auditability)*
- [ ] Admin detection verified for both Qawafel-linked and standard business accounts *(FR-8.1)*

---

**Total Test Conditions:** 90
**Critical Path:** Section 2.6 - Generate Payment Link (FR-6)
**Blocking Gap:** G-10 / OQ-3 - Admin detection mechanism (still open)
**Open Questions:** 35 unanswered questions across 5 screens (see Section 4)
**Next Steps:** Distribute Section 4 questions to product and design for answers before Gherkin feature files are written
