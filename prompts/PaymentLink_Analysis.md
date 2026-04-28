# 🧪 Test Analysis — PRD 1: Invoice to Payment Link (APEX Platform)

**Version:** 1.0 | **Date:** April 28, 2026 | **Status:** Draft  
**Prepared by:** QA Team  
**PRD:** PRD 1 — Invoice to Payment Link — Minimum Viable Path (v1.0)  
**Design:** APEX — Payment Flow (Figma v.2 — PRD 1 Invoice to Payment Link MVP 2)

---

## Table of Contents

1. [Scope Overview](#1-scope-overview)
2. [Test Conditions by Feature](#2-test-conditions-by-feature)
   - 2.1 Sign-Up
   - 2.2 Business Profile Setup
   - 2.3 Home – Invoice List
   - 2.4 Buyer Business Management
   - 2.5 Invoice Creation
   - 2.6 Generate Payment Link *(Critical)*
   - 2.7 Payment Request Listings
   - 2.8 Admin – Payment Methods
3. [Gaps, Ambiguities & Risks](#3-gaps-ambiguities--risks)
4. [Entry & Exit Criteria](#4-entry--exit-criteria)

---

## 1. Scope Overview

| Feature Area | FR IDs | Risk Level |
|---|---|---|
| Sign-Up | FR-1.1 – FR-1.4 | Medium |
| Business Profile Setup | FR-2.1 – FR-2.4 | High |
| Home – Invoice List | FR-3.1 – FR-3.6 | Medium |
| Buyer Business Management | FR-4.1 – FR-4.4 | Medium |
| Invoice Creation | FR-5.1 – FR-5.6 | High |
| Generate Payment Link | FR-6.1 – FR-6.11 | **Critical** |
| Payment Request Listings | FR-7.1 – FR-7.7 | High |
| Admin – Payment Methods | FR-8.1 – FR-8.3 | High |

---

## 2. Test Conditions by Feature

---

### 2.1 Sign-Up (FR-1.1 – FR-1.4)

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
| TC-1.10 | Successful registration redirects immediately to Business Profile — no intermediate screen | Positive | Direct redirect, no email verify step |

> **⚠️ Design Gap:** Figma frame `Signup 6` shows *"You don't have an account? Create new account"* — copy is inconsistent with other signup frames that show *"Log in"*. Needs alignment.

---

### 2.2 Business Profile Setup (FR-2.1 – FR-2.4)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-2.1 | All required fields filled (CR/Unified, phone, tax number, address) → Save | Positive | Profile created, redirect to invoice list |
| TC-2.2 | Attempt to skip by navigating to `/invoices` before completing profile | Negative | Redirect back to profile setup screen |
| TC-2.3 | Attempt to navigate to `/buyers` before completing profile | Negative | Redirect back to profile setup screen |
| TC-2.4 | Email field is pre-filled with registered email and is read-only | Design Check | Field shows registration email, not editable |
| TC-2.5 | Submit with CR/Unified field empty | Negative | Inline validation error, form does not submit |
| TC-2.6 | Submit with phone number empty | Negative | Inline validation error |
| TC-2.7 | Submit with tax number empty | Negative | Inline validation error |
| TC-2.8 | Submit with address empty | Negative | Inline validation error |
| TC-2.9 | Verify CR field shows dual-label: *"CR Number"* / *"Unified Number"* as selection (per Figma) | Design Check | CR/Unified is a selectable toggle between the two options |
| TC-2.10 | After successful save, verify merchant profile record persists across login sessions | Data Integrity | Profile data retained |

> **⚠️ PRD Ambiguity (FR-2.2):** PRD says "CR number or Unified number (selection field)" — Figma confirms a dropdown/toggle between "CR Number" and "Unified Number" as two separate input labels. Engineering confirmation required.

---

### 2.3 Home – Invoice List (FR-3.1 – FR-3.6)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-3.1 | Login with completed profile → lands on invoice list | Positive | Invoice list is the first screen shown |
| TC-3.2 | Invoice table shows all 5 columns: Invoice No., Buyer Name, Invoice Date, Total Amount (SAR), Status | Design Check | All columns present and populated |
| TC-3.3 | Status badge shows exactly `Sent`, `Paid`, or `Cancelled` — no other values | Design Check | Only 3 status values |
| TC-3.4 | Click "Create Invoice" CTA → navigates to invoice creation screen | Positive | Correct navigation |
| TC-3.5 | Invoice list with zero invoices shows empty state message + Create Invoice CTA | Edge Case | No blank table; empty state UI displayed |
| TC-3.6 | Verify no filter controls, sort controls, or search bar on invoice table | Out-of-Scope Check | None present |
| TC-3.7 | Verify no PO-linked column or document relationship column is present | Out-of-Scope Check | Not present |

---

### 2.4 Buyer Business Management (FR-4.1 – FR-4.4)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-4.1 | Add buyer with only business name + email (minimum required) | Positive | Buyer saved, appears in listing and invoice dropdown |
| TC-4.2 | Add buyer with all optional fields (CR/Unified, phone, tax number, address) | Positive | All fields saved and displayed correctly |
| TC-4.3 | Attempt to add buyer with no business name | Negative | Inline validation error |
| TC-4.4 | Attempt to add buyer with no email | Negative | Inline validation error |
| TC-4.5 | Attempt to add buyer with invalid email format | Negative | Inline validation error |
| TC-4.6 | Edit existing buyer record → verify changes reflect in listing and invoice dropdown | Positive | Updated values persist everywhere |
| TC-4.7 | Delete buyer (Figma shows "Delete Business" action) → verify removed from listing and dropdown | Positive / Destructive | Buyer removed — **Note: PRD does not mention delete. Figma shows it. Needs PRD confirmation.** |
| TC-4.8 | Buyer dropdown on invoice creation form is searchable | Design Check | Typing filters results in real time |
| TC-4.9 | Buyers listing shows: business name, CR/Unified number, email, phone | Design Check | All 4 columns present |
| TC-4.10 | Add two buyers with identical email — verify uniqueness enforcement at buyer level | Edge Case | **PRD is silent — gap to clarify with product** |

> **⚠️ Design Gap:** Figma frame `Frame 1984080222` shows "Delete Business" and "Edit Business" via a context menu. **Delete is not mentioned in the PRD (FR-4.3 only covers edit).** Needs product decision.

---

### 2.5 Invoice Creation (FR-5.1 – FR-5.6)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-5.1 | Create invoice → verify auto-generated number follows `INV-YY-XXXXXX` format | Positive | Number assigned; user cannot edit it |
| TC-5.2 | Invoice number increments sequentially on each new invoice | Positive | Sequential and unique per invoice |
| TC-5.3 | Seller info block is pre-populated (business name, CR/Unified, tax number, address) and read-only | Design Check | Fields non-editable on invoice form |
| TC-5.4 | Select buyer from searchable dropdown → buyer fields pre-fill (name, email, phone) | Positive | Pre-fill occurs on selection |
| TC-5.5 | Attempt to submit invoice with no buyer selected | Negative | Inline validation error |
| TC-5.6 | Enter valid positive numeric Total Amount (SAR) | Positive | Invoice created successfully |
| TC-5.7 | Enter 0 as total amount | Boundary/Negative | Validation error — must be positive |
| TC-5.8 | Enter negative amount | Negative | Validation error |
| TC-5.9 | Enter non-numeric characters in amount field | Negative | Validation error |
| TC-5.10 | Submit with empty amount field | Negative | Validation error |
| TC-5.11 | Verify no line item fields, no quantity, no unit price, no VAT field on form | Out-of-Scope Check | None present |
| TC-5.12 | Verify no ZATCA status field; confirm no ZATCA API call fires on create (check Network tab) | Out-of-Scope Check | No ZATCA call |
| TC-5.13 | Invoice created with `Sent` status → "Generate Payment Link" CTA is visible | Positive | CTA visible on Sent invoice |
| TC-5.14 | Invoice in `Paid` status → "Generate Payment Link" CTA is not visible | Negative | CTA absent |
| TC-5.15 | Invoice in `Cancelled` status → "Generate Payment Link" CTA is not visible | Negative | CTA absent |
| TC-5.16 | Sent invoice with an existing active payment link → "Generate Payment Link" CTA hidden/disabled | Edge Case | Only one active link per invoice (OQ-4 resolved) |

---

### 2.6 Generate Payment Link (FR-6.1 – FR-6.11) — *Critical Path*

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-6.1 | Click "Generate Payment Link" on Sent invoice → Create Payment Request modal/page opens | Positive | Modal opens over invoice detail |
| TC-6.2 | Click Cancel or X button → modal closes with no payment request created | Negative | No record created |
| TC-6.3 | Verify Invoice Details block shows: Invoice No., Email, Total Amount, Buyer Name, Phone — all read-only | Design Check | 5 fields pre-populated and non-editable |
| TC-6.4 | Net Payable = Invoice Total (VAT = 0, Credit Notes = 0) — value is read-only | Design Check | Values correct and non-editable |
| TC-6.5 | "Send Now" is the default selected send timing option on modal open | Design Check | Send Now pre-selected |
| TC-6.6 | Select "Send Later" → Scheduled Date + Scheduled Time pickers appear | Positive | Both pickers visible |
| TC-6.7 | Select "Send Later" + enter a past date → inline validation error | Negative | Error: date must be in the future |
| TC-6.8 | Select "Send Later" + enter today's date with a past time → inline validation error | Boundary | Validation error shown |
| TC-6.9 | Select "Send Later" + leave date empty → attempt submit | Negative | Required field error |
| TC-6.10 | Payment Link Expiration has no pre-selected option on open | Design Check | No radio pre-selected |
| TC-6.11 | Select each expiry option: 7 Days / 15 Days / 30 Days / 45 Days | Positive | Each option is individually selectable |
| TC-6.12 | Submit with no expiry option selected | Negative | Inline validation error |
| TC-6.13 | Verify all 4 payment methods shown: Credit Card, Apple Pay, SADAD, AlRajhi BNPL | Design Check | All 4 checkboxes present |
| TC-6.14 | Submit with no payment method selected | Negative | Inline error: *"Select at least one payment method."* |
| TC-6.15 | Select only one payment method and submit all other fields valid | Positive | Form submits successfully |
| TC-6.16 | Each payment method shows its fee info (Mada Fees + Card Fees / Apple Pay basis / SADAD % / BNPL %) | Design Check | Fee labels drawn from admin payment method config |
| TC-6.17 | Net payable < SAR 1,500 (BNPL minimum) → BNPL shows warning and is non-selectable | Boundary | Warning shown, checkbox disabled |
| TC-6.18 | Net payable = SAR 1,500 (exact minimum threshold) → BNPL is selectable | Boundary | No warning, BNPL available |
| TC-6.19 | Net payable > SAR 20,000 (BNPL upper bound per OQ-2) → verify BNPL behavior | Boundary | **PRD gap — upper threshold behavior not specified. To clarify.** |
| TC-6.20 | Submit valid form → unique payment link generated, payment request record saved | Positive | Record created, share options displayed |
| TC-6.21 | Share options shown after creation: Copy Link, WhatsApp, Email | Design Check | All 3 share actions present |
| TC-6.22 | Copy Link → link copied to clipboard successfully | Positive | Clipboard contains valid payment URL |
| TC-6.23 | WhatsApp share → opens WhatsApp with pre-filled message containing the link | Positive | WhatsApp intent triggered |
| TC-6.24 | Email share → opens email client or modal with pre-filled body containing the link | Positive | Email intent triggered |
| TC-6.25 | Verify each share action is logged with timestamp + channel (copy / WhatsApp / email) | Auditability | Log record created per share event |
| TC-6.26 | Inactive payment method (deactivated in admin) is NOT shown in payment method checkboxes | Integration | Method absent from seller form |

> **⚠️ Figma Observation:** The Create Payment Request modal in Figma shows a **Notes/Memo field** (`اضافة الملاحظة` — "Add Note") and a **"Sending Mode"** section label, separate from the send timing section. The PRD does not mention a notes field. Needs product confirmation on scope.

> **⚠️ Figma Observation:** Figma label for send timing reads *"When would you like to send this payment request?"* with separate "Sending Mode" grouping — differs from PRD's simple "Send Now / Send Later" radio description (FR-6.4). Design and PRD alignment required before dev build.

---

### 2.7 Payment Request Listings (FR-7.1 – FR-7.7)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-7.1 | Created Payment Requests table shows: request no., linked invoice no., buyer name, amount, expiry date, send type, status | Design Check | All 7 columns present and populated |
| TC-7.2 | Status values in Created listing: Active, Expired, Paid, Cancelled only | Design Check | Only these 4 status values used |
| TC-7.3 | Cancel an Active payment request from the listing | Positive | Status → Cancelled; linked invoice → Sent |
| TC-7.4 | Cancel an Active payment request from the detail view | Positive | Same outcome as TC-7.3 |
| TC-7.5 | Attempt to cancel an Expired request | Negative | Cancel action absent or disabled |
| TC-7.6 | Attempt to cancel a Paid request | Negative | Cancel action absent or disabled |
| TC-7.7 | Re-share an Active payment link from the listing | Positive | Share options modal opens (copy, WhatsApp, email) |
| TC-7.8 | Attempt to re-share a Cancelled payment link | Negative | Share action absent or disabled |
| TC-7.9 | Received Payment Requests table shows: request no., seller name, amount, expiry date, status | Design Check | All 5 columns present |
| TC-7.10 | Send Later request → does NOT appear in buyer's Received listing before scheduled date | Negative | Absent from buyer view |
| TC-7.11 | Send Later request → appears in buyer's Received listing on/after the scheduled date | Positive | Visible from scheduled date/time onward |
| TC-7.12 | Received listing has no Pay Now or checkout CTA | Out-of-Scope Check | No payment action present |
| TC-7.13 | Cancel an Active payment link → linked invoice automatically returns to Sent status (OQ-5: auto-cancel) | Integration | Automatic — no manual action required |
| TC-7.14 | Cancel the linked invoice → active payment link auto-cancels (OQ-5) | Integration | Payment link status → Cancelled automatically |

> **⚠️ Figma Observation:** Figma frame `28` shows a **"Cancellation Reason"** field in the Cancel Payment Request confirmation modal. The PRD (FR-7.3) does not mention capturing a cancellation reason. Needs product confirmation.

---

### 2.8 Admin – Payment Methods (FR-8.1 – FR-8.3)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-8.1 | Login with Qawafel-linked account → admin interface is shown | Positive | Admin screens shown instead of business screens |
| TC-8.2 | Login with standard business account → standard business interface shown | Negative | Admin screens NOT visible |
| TC-8.3 | Payment Methods listing shows: method name, type, fee structure, status (Active/Inactive), Create CTA | Design Check | All columns and CTA present |
| TC-8.4 | Create a new payment method via the admin form | Positive | Method saved, appears in listing |
| TC-8.5 | Edit existing payment method (fee values, name) → changes reflect in seller-facing form | Positive | Updated values propagate to seller view |
| TC-8.6 | Toggle a payment method to Inactive | Positive | Method hidden from seller's Create Payment Request form |
| TC-8.7 | Re-activate an Inactive payment method → it reappears on the seller form | Positive | Method visible again in seller form |
| TC-8.8 | Verify Qawafel business record + admin-linked user are seeded on initial environment deployment | Setup Check | Admin login works on fresh staging environment |
| TC-8.9 | BNPL minimum threshold (SAR 1,500) is configurable in admin payment method settings | Config Check | Value editable in admin; drives FR-6.9 warning on seller form |

---

## 3. Gaps, Ambiguities & Risks

| # | Area | Issue | Risk | Recommendation |
|---|---|---|---|---|
| G-1 | Sign-Up | Copy inconsistency in Figma: `Signup 6` shows *"Create new account"* where others show *"Log in"* | Low | Align copy across all signup frames before dev handoff |
| G-2 | Business Profile | CR vs Unified — selection mechanism (toggle vs dropdown vs radio) not fully defined in PRD | High | Confirm exact UX with design team |
| G-3 | Buyer Management | Delete buyer action visible in Figma but not mentioned in PRD (FR-4.3 covers edit only) | Medium | Product to confirm if delete is in scope for this phase |
| G-4 | Buyer Management | No uniqueness rule defined for buyer email across different selling businesses | Medium | Confirm if duplicate buyer emails across sellers are allowed |
| G-5 | Payment Link | Notes/Memo field shown in Figma (`اضافة الملاحظة`) not referenced in PRD | Medium | Confirm if notes field is in scope; if yes, add FR and test conditions |
| G-6 | Payment Link | BNPL upper threshold (SAR 20,000 per OQ-2) — behavior above the threshold not specified | Medium | Define: warning only, or also non-selectable? |
| G-7 | Payment Link | "Sending Mode" section label in Figma differs from PRD's Send Now/Send Later radio description | Medium | Align PRD wording with final Figma before engineering build |
| G-8 | Payment Link | One active link per invoice (OQ-4 resolved) — system enforcement mechanism not described | High | Confirm: CTA hidden, disabled, or inline error on second attempt? |
| G-9 | Cancel Payment Request | Cancellation Reason field in Figma (frame 28) not mentioned in PRD (FR-7.3) | Low | Confirm if reason capture is in scope for this phase |
| G-10 | Admin | Admin detection method (OQ-3) still open — email domain vs linkage to Qawafel business record ID | **Critical** | Must be resolved before FR-8.1 can be implemented or tested |
| G-11 | General | No session timeout or token refresh behavior defined in NFRs | Low | Clarify expected session duration for desktop web |

---

## 4. Entry & Exit Criteria

### Entry Criteria
- [ ] Feature deployed to staging environment
- [ ] Qawafel admin business record and at least one admin-linked user seeded on staging
- [ ] Payment method fee values configured in admin (OQ-1 resolved — *same as current*)
- [ ] AlRajhi BNPL minimum threshold confirmed as SAR 1,500 (OQ-2 resolved)
- [ ] AlRajhi BNPL maximum threshold behavior above SAR 20,000 clarified (G-6)
- [ ] Admin detection mechanism (OQ-3) resolved and implemented (G-10)
- [ ] G-8 (single active link enforcement) confirmed and implemented

### Exit Criteria
- [ ] All **Must Have** FRs covered by at least one positive test and one negative/boundary test
- [ ] All **Critical** and **High** risk gaps (G-2, G-8, G-10) resolved or formally accepted as risk
- [ ] Zero open P1 (blocker) defects
- [ ] Audit log verified for all share events (FR-6.11 / NFR Auditability requirement)
- [ ] Admin detection verified for both Qawafel-linked and standard business accounts (FR-8.1)

---

**Total Test Conditions:** 90  
**Critical Path:** Section 2.6 — Generate Payment Link (FR-6)  
**Blocking Gap:** G-10 — Admin detection mechanism (OQ-3 still open)  
**Next Steps:** Await product responses on gaps G-2, G-3, G-5, G-8, G-9, G-10 before writing Gherkin feature files
