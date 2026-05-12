# 📋 Test Analysis – PRD 2: Buyer-Side Payment Execution & Failure Handling

- **Version:** 1.0
- **Date:** May 11, 2026
- **Status:** Draft
- **Prepared by:** QA Team
- **PRD:** PRD 2 – Buyer-Side Payment Execution & Failure Handling (v1.0)
- **Design:** APEX – Payment Flow (Figma token: `figd_OlC1l8x358-85UoL-kTY7qf8yAoFR1jpPGdzl__n`)
- **Dependencies:** PRD Phase 1 (Invoice to Payment Link MVP) must be stable

---

## Table of Contents

1. [Scope Overview](#1-scope-overview)
2. [Payment Link State Model (Authoritative)](#2-payment-link-state-model-authoritative)
3. [Test Conditions by Feature](#3-test-conditions-by-feature)
   - 3.1 Payment Link Landing Page (FR-2.1 – FR-2.7)
   - 3.2 Credit Card Execution (FR-2.8 – FR-2.12)
   - 3.3 Apple Pay Execution (FR-2.13 – FR-2.16)
   - 3.4 SADAD Execution (FR-2.17 – FR-2.21)
   - 3.5 AlRajhi BNPL Execution (FR-2.22 – FR-2.25)
   - 3.6 Payment Success (FR-2.26 – FR-2.29)
   - 3.7 Payment Failure Handling (FR-2.30 – FR-2.35)
4. [Gaps, Ambiguities & Risks](#4-gaps-ambiguities--risks)
5. [Open Questions](#5-open-questions)
6. [Entry & Exit Criteria](#6-entry--exit-criteria)

---

## 1. Scope Overview

**In Scope:**
- ✅ Payment link landing page (no login required)
- ✅ Guest buyer identity (no credentials)
- ✅ Registered buyer identity (logged-in APEX account)
- ✅ Credit Card execution with 3DS support
- ✅ Apple Pay execution (Safari/iOS only)
- ✅ SADAD execution with pending state and retry
- ✅ AlRajhi BNPL execution with eligibility check, approval, and rejection
- ✅ Payment success confirmation + PDF receipt download
- ✅ Payment failure handling (all states: generic failure, BNPL rejection, SADAD pending, link expired)
- ✅ Seller's Created Payment Requests listing updates to Paid

**Out of Scope (Deferred):**
- ❌ Qawafel Pay as a payment method
- ❌ Seller real-time notification (in-app or email)
- ❌ Automated receipt email to buyer
- ❌ BNPL instalment tracking and management UI post-payment
- ❌ Refunds and credit notes
- ❌ Partial payments
- ❌ Buyer-initiated dispute or query flow

---

## 2. Payment Link State Model (Authoritative)

This is the source-of-truth state machine for all payment link statuses and their UI/CTA implications:

| Scenario | Status Shown | CTA | Methods Available | Buyer Action | Outcome |
|---|---|---|---|---|---|
| Link first accessed | **Awaiting Payment** | "Select Payment Method" | All seller-enabled methods | Choose method | Method form shown |
| Payment attempt failed (generic) | **Failed** | "Try Another Method" | All seller-enabled methods | Retry with same or different method | New form shown or new method selected |
| BNPL application rejected | **Failed** | "Try Another Method" | All methods **except AlRajhi BNPL** (removed) | Retry via other method | BNPL option hidden |
| SADAD bill generated | **Pending** | "Try Another Method" | All seller-enabled methods | Wait for bank callback OR switch method | Link awaits SADAD callback; buyer can use other method |
| Payment confirmed (any method) | **Paid** | "Download Receipt" | None (payment complete) | Download PDF receipt | Receipt generated and downloaded |
| Link expired | **Link Expired** | None | None | No action available | Terminal screen; no retry; link inaccessible |
| Link explicitly cancelled by seller | **Cancelled** | None | None | No action available | Terminal screen; no retry; link inaccessible |

**Critical Rules:**
- All non-terminal failure states (Failed, Pending) allow retry until link expiry.
- Expiry is the only terminal failure state that closes the link completely.
- SADAD pending is unique: shows as "Pending" (not "Failed") with "Try Another Method" CTA.
- BNPL rejection is permanent within that session: method is removed, others remain.
- Guest payers do not require identity verification; registered buyers' accounts are linked automatically if logged in.

---

## 3. Test Conditions by Feature

---

### 3.1 Payment Link Landing Page (FR-2.1 – FR-2.7)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-2.1.1 | Access valid payment link URL without login | Positive | Payment landing page renders immediately; no authentication prompt |
| TC-2.1.2 | Verify landing page displays seller name, invoice number, invoice date, amount due, expiry date | Design Check | All 5 fields visible and accurate |
| TC-2.1.3 | Payment methods shown on landing page match exactly those enabled by seller when creating link | Integration | Methods displayed match admin-configured enabled methods |
| TC-2.1.4 | Guest buyer (no APEX account, not logged in) opens link | Positive | Payment method selection shown immediately; no email/phone/identity capture form |
| TC-2.1.5 | Registered buyer (full APEX account) opens link while logged in | Positive | Buyer business name pre-populated; payment links to their account and appears in Received Payment Requests |
| TC-2.1.6 | Registered buyer opens link while NOT logged in | Positive | Treated as guest; no account linkage until buyer logs in during checkout (OQ-1: clarify if in-checkout login allowed) |
| TC-2.1.7 | Access payment link in Expired status | Positive | Terminal 'Link Expired' screen rendered; no payment options; no CTA |
| TC-2.1.8 | Access payment link in Paid status (already paid by another buyer) | Positive | Terminal 'Paid' screen rendered; no payment options |
| TC-2.1.9 | Access payment link in Cancelled status (seller cancelled) | Positive | Terminal 'Cancelled' screen rendered; no payment options |
| TC-2.1.10 | Verify expiry date/time displayed matches seller-configured expiry from PRD Phase 1 | Data Integrity | Expiry timestamp is accurate |

> ⚠️ **OQ-1 (Clarify):** PRD states registered buyer must be logged in to link payment to account. If buyer logs in during payment flow, is their payment retroactively linked? Need product decision.

---

### 3.2 Credit Card Execution (FR-2.8 – FR-2.12)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-2.2.1 | Buyer selects Credit Card from method list | Positive | Card entry form displayed with 4 required fields |
| TC-2.2.2 | Verify card form has fields: card number, expiry (MM/YY), CVV, cardholder name | Design Check | All 4 fields present and properly labelled |
| TC-2.2.3 | Card type is auto-detected from prefix (Visa, Mastercard, Mada) and icon shown | Positive | Correct card icon displayed for recognized prefixes |
| TC-2.2.4 | Submit form with all fields empty | Negative | Form does not submit; inline validation errors shown for each field |
| TC-2.2.5 | Submit form with 3 fields filled, 1 empty (test each field as empty one at a time) | Negative | Validation error shown for the empty field only; form blocked |
| TC-2.2.6 | Submit with invalid card format (11 digits) | Negative | Card number validation error shown; form blocked |
| TC-2.2.7 | Submit with invalid expiry format (MM/DD instead of MM/YY) | Negative | Expiry validation error shown; form blocked |
| TC-2.2.8 | Submit with expired card date (e.g., 01/20 in 2026) | Negative | Expiry validation error shown; form blocked |
| TC-2.2.9 | Submit with invalid CVV (2 digits for Visa/Mastercard; should be 3) | Negative | CVV validation error shown; form blocked |
| TC-2.2.10 | Submit with all valid fields, 3DS-required card (Visa/Mastercard typically) | Positive | 3DS challenge screen presented inline within payment flow (no page navigation) |
| TC-2.2.11 | Buyer completes 3DS challenge successfully | Positive | Payment Success screen displayed; invoice and payment request status updated to Paid |
| TC-2.2.12 | Buyer completes 3DS challenge but 3DS validation fails | Negative | Link status shows 'Failed'; 'Try Another Method' CTA shown; all methods remain available |
| TC-2.2.13 | Submit card payment without 3DS requirement (if possible on test gateway) | Positive | Payment Success screen displayed immediately (no 3DS step) |
| TC-2.2.14 | Card payment fails for non-3DS reason (e.g., card declined, insufficient funds) | Negative | Link status shows 'Failed'; 'Try Another Method' CTA shown; failure reason displayed (e.g., 'Card declined'); all methods available |
| TC-2.2.15 | Gateway timeout during card payment | Negative | Status shows 'Failed' with timeout message; 'Try Another Method' CTA shown; all methods available (buyer must not retry same card immediately per OQ-2) |
| TC-2.2.16 | Verify payment event is recorded after successful card payment | Auditability | Payment event record created with card method, reference, timestamp |
| TC-2.2.17 | Attempt card payment on same link twice with different cards after first card fails | Positive | Both attempts recorded; second attempt can proceed if within methods availability rules |
| TC-2.2.18 | Verify Mada card is accepted and processed | Positive | Mada icon shown; payment processes via Mada network |

> ⚠️ **OQ-2 (Clarify):** PRD states "buyer must not be offered immediate retry because original charge may still succeed via delayed callback." How is this enforced? Block same-card retry immediately? Block all retries for N seconds? Implementation unclear.

---

### 3.3 Apple Pay Execution (FR-2.13 – FR-2.16)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-2.3.1 | Access payment link on Safari browser (macOS/iOS) | Positive | Apple Pay option is visible in payment method list |
| TC-2.3.2 | Access payment link on iOS device with Apple Pay configured | Positive | Apple Pay option is visible |
| TC-2.3.3 | Access payment link on Chrome browser | Negative | Apple Pay option is absent from method list |
| TC-2.3.4 | Access payment link on Firefox browser | Negative | Apple Pay option is absent from method list |
| TC-2.3.5 | Access payment link on Android device | Negative | Apple Pay option is absent from method list |
| TC-2.3.6 | Buyer selects Apple Pay on Safari/iOS | Positive | Native Apple Pay sheet presented with merchant name, amount (SAR), and payment summary |
| TC-2.3.7 | Buyer completes Apple Pay authentication via Face ID on supported device | Positive | Payment Success screen displayed; payment recorded; invoice and payment request status updated to Paid |
| TC-2.3.8 | Buyer completes Apple Pay authentication via Touch ID | Positive | Payment Success screen displayed; payment recorded |
| TC-2.3.9 | Buyer completes Apple Pay authentication via passcode | Positive | Payment Success screen displayed; payment recorded |
| TC-2.3.10 | Buyer cancels the Apple Pay sheet (dismisses without authorizing) | Negative | Link status shows 'Failed'; 'Try Another Method' CTA shown; all methods remain available |
| TC-2.3.11 | Apple Pay authorization fails (issuer decline, network error) | Negative | Link status shows 'Failed'; failure reason shown; 'Try Another Method' CTA; all methods available |
| TC-2.3.12 | Verify payment event is recorded after successful Apple Pay payment | Auditability | Payment event record created with Apple Pay method, reference, timestamp |
| TC-2.3.13 | Buyer selects Apple Pay, cancels, then selects Apple Pay again on same link | Positive | Second Apple Pay attempt proceeds normally (no blocking) |
| TC-2.3.14 | Verify amount displayed in Apple Pay sheet matches invoice total | Data Integrity | Amount shown in native sheet is accurate |

---

### 3.4 SADAD Execution (FR-2.17 – FR-2.21)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-2.4.1 | Buyer selects SADAD from payment method list | Positive | SADAD bill number generated via API and displayed to buyer |
| TC-2.4.2 | Verify SADAD bill number display includes payment instructions | Design Check | Instructions shown to buyer on how to pay via bank app |
| TC-2.4.3 | After bill generation, link status shown to buyer is 'Pending' | Design Check | Status label shows 'Pending' (not 'Failed') |
| TC-2.4.4 | After bill generation, CTA shown to buyer is 'Try Another Method' | Design Check | CTA text reads 'Try Another Method'; not greyed out or disabled |
| TC-2.4.5 | After bill generation, all seller-enabled payment methods remain available | Positive | Buyer can select any other method while SADAD is pending |
| TC-2.4.6 | Buyer switches to Credit Card while SADAD bill pending | Positive | Credit Card form shown; buyer can complete card payment |
| TC-2.4.7 | Buyer completes Credit Card payment while SADAD bill pending | Positive | Payment Success screen shown; SADAD bill is automatically voided via API; invoice and payment request status updated to Paid |
| TC-2.4.8 | Buyer completes Apple Pay while SADAD bill pending | Positive | Payment Success screen shown; SADAD bill voided; payment recorded |
| TC-2.4.9 | SADAD callback confirms payment received from bank | Positive | Link status transitions to 'Paid'; invoice and payment request status updated to Paid; payment event recorded |
| TC-2.4.10 | SADAD callback confirms payment failure (bill not paid, bank declined) | Negative | Link status shows 'Failed'; 'Try Another Method' CTA shown; all methods remain available |
| TC-2.4.11 | Payment link expires before SADAD bill is paid | Negative | Link status transitions to 'Link Expired' (overrides Pending); no CTA; link inaccessible |
| TC-2.4.12 | Buyer refreshes page while SADAD is pending | Positive | Bill number and Pending status are preserved; 'Try Another Method' CTA still available |
| TC-2.4.13 | Verify SADAD bill number is unique per link | Data Integrity | Each generated bill number is unique |
| TC-2.4.14 | Verify payment event is recorded when SADAD callback confirms payment | Auditability | Payment event record created with SADAD method, bill number, callback timestamp |

> ⚠️ **OQ-3 (Clarify):** How long after SADAD bill generation should the system wait for a callback before timing out? Should link auto-fail after N hours if no callback received?

---

### 3.5 AlRajhi BNPL Execution (FR-2.22 – FR-2.25)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-2.5.1 | Buyer selects AlRajhi BNPL from method list when amount ≥ SAR 1,500 | Positive | Loading/processing state shown; eligibility check initiated with Al Rajhi |
| TC-2.5.2 | During BNPL eligibility check, buyer cannot interact with other payment methods | Design Check | Other methods are disabled or not clickable during check |
| TC-2.5.3 | Al Rajhi returns BNPL approval and buyer accepts terms | Positive | Payment recorded as successful; Payment Success screen displayed; invoice and payment request status updated to Paid |
| TC-2.5.4 | Al Rajhi approves BNPL and displays instalment schedule (up to 4 instalments) | Positive | Instalment schedule shown to buyer (e.g., 4 × SAR X due on dates Y, Z, W, V) |
| TC-2.5.5 | Buyer reviews instalment schedule and confirms acceptance | Positive | Payment Success screen displayed; instalment schedule is not displayed post-payment (tracking deferred to later phase) |
| TC-2.5.6 | Al Rajhi returns BNPL rejection (buyer fails eligibility check) | Negative | Link status shows 'Failed'; 'Try Another Method' CTA shown; AlRajhi BNPL option removed from method list for this session |
| TC-2.5.7 | After BNPL rejection, verify all other seller-enabled methods remain available | Positive | Only BNPL is hidden; Credit Card, Apple Pay, SADAD all remain selectable |
| TC-2.5.8 | Buyer selects a different method after BNPL rejection and completes payment | Positive | Payment Success screen; payment recorded via selected method; link transitions to Paid |
| TC-2.5.9 | Amount is below SAR 1,500 (BNPL minimum) when link is accessed | Negative | BNPL option is disabled or hidden; warning message shown: "Minimum amount for BNPL is SAR 1,500" |
| TC-2.5.10 | Amount is exactly SAR 1,500 | Boundary | BNPL option is enabled; no warning shown; buyer can select and proceed |
| TC-2.5.11 | Amount is above SAR 1,500 but verification method shows minimum warning on landing page | Design Check | Verify warning text matches PRD Phase 1 FR-6.9 (same warning on both seller and buyer forms) |
| TC-2.5.12 | BNPL eligibility check times out (Al Rajhi API timeout) | Negative | Processing state clears; error message shown; 'Try Another Method' CTA; all methods available |
| TC-2.5.13 | Verify BNPL payment event is recorded with approval reference from Al Rajhi | Auditability | Payment event includes BNPL approval reference and instalment schedule details |
| TC-2.5.14 | Verify seller's Created Payment Requests listing shows BNPL payment as Paid with method identified as 'AlRajhi BNPL' | Integration | Listing reflects BNPL method and Paid status |

> ⚠️ **OQ-4 (Clarify):** What is the maximum amount for BNPL? PRD mentions minimum (SAR 1,500) but no upper bound defined. Is there a cap?

---

### 3.6 Payment Success (FR-2.26 – FR-2.29)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-2.6.1 | Buyer completes payment via Credit Card | Positive | Payment Success screen displayed with all required fields |
| TC-2.6.2 | Success screen displays: confirmation message, total amount (SAR), payment reference, seller name, payment method used | Design Check | All 5 elements visible and accurate |
| TC-2.6.3 | Success screen includes 'Download Receipt' CTA | Design Check | CTA is present and clickable |
| TC-2.6.4 | Buyer clicks 'Download Receipt' | Positive | PDF receipt generated and downloaded to device |
| TC-2.6.5 | Verify PDF receipt contains: seller name, invoice number, payment reference, amount, payment method, timestamp | Design Check | All 6 fields present in PDF |
| TC-2.6.6 | After payment, seller's Created Payment Requests listing reflects 'Paid' status for this link | Integration | Status changes from 'Active' to 'Paid' in seller view |
| TC-2.6.7 | After payment, seller's linked invoice status updates to 'Paid' | Integration | Invoice status in invoice listing changes to 'Paid' |
| TC-2.6.8 | Registered buyer (logged in) completes payment | Positive | Payment appears in buyer's Received Payment Requests listing with 'Paid' status |
| TC-2.6.9 | Guest buyer completes payment | Positive | Payment is recorded; receipt is downloaded; no entry in buyer's Received Payment Requests (guest has no account) |
| TC-2.6.10 | Verify payment reference number is unique per transaction | Data Integrity | Each payment has a unique reference number |
| TC-2.6.11 | Buyer can download receipt multiple times from success screen | Positive | Each download generates the same PDF with consistent data |
| TC-2.6.12 | Buyer closes success screen without downloading receipt | Positive | Receipt can still be re-downloaded from the screen if they return before link expires |
| TC-2.6.13 | Verify success screen shows correct payment method icon for the method used | Design Check | Icon matches the method (card icon for Credit Card, Apple logo for Apple Pay, etc.) |

---

### 3.7 Payment Failure Handling (FR-2.30 – FR-2.35)

| TC# | Condition | Type | Expected |
|---|---|---|---|
| TC-2.7.1 | Card payment fails (card declined) | Negative | Link status shown: 'Failed'; CTA: 'Try Another Method'; failure reason: 'Card declined' |
| TC-2.7.2 | 3DS challenge fails | Negative | Link status shown: 'Failed'; CTA: 'Try Another Method'; failure reason shown |
| TC-2.7.3 | Gateway timeout during card payment | Negative | Link status shown: 'Failed'; CTA: 'Try Another Method'; all methods available |
| TC-2.7.4 | After any generic failure, verify all seller-enabled payment methods remain available | Positive | No method is removed; buyer can retry with same or different method |
| TC-2.7.5 | After BNPL rejection, verify AlRajhi BNPL is removed from available methods | Positive | BNPL option hidden; all other seller-enabled methods remain |
| TC-2.7.6 | After BNPL rejection, buyer selects Credit Card | Positive | Credit Card form shown; payment proceeds normally |
| TC-2.7.7 | SADAD pending state status text is 'Pending' (not 'Failed') | Design Check | Status label reads 'Pending' explicitly |
| TC-2.7.8 | SADAD pending state shows CTA 'Try Another Method' | Design Check | CTA is active and selectable |
| TC-2.7.9 | SADAD pending state shows SADAD bill details alongside status | Design Check | Bill number and payment instructions displayed with status |
| TC-2.7.10 | SADAD pending state does NOT show a failure message (not generic failure) | Design Check | No error or declined message shown; only 'Pending' status |
| TC-2.7.11 | Link expiration (date/time reached) | Negative | Status shows 'Link Expired'; no CTA shown; no payment options; link completely inaccessible |
| TC-2.7.12 | Reload an expired link | Negative | Same 'Link Expired' screen rendered; no payment options |
| TC-2.7.13 | Buyer can attempt payment multiple times before link expires | Positive | Each failed attempt resets to method selection screen; all applicable methods available per rules |
| TC-2.7.14 | Buyer attempts payment 5 times before link expires (all fail via different methods) | Positive | All 5 attempts recorded; link remains Active; buyer can continue retrying |
| TC-2.7.15 | Verify payment link remains Active in system during all non-terminal failure states | Data Integrity | Link status in database is 'Active' (not closed) even though shown as 'Failed' to buyer |
| TC-2.7.16 | Verify expiration check is enforced server-side on every payment attempt | Security | Expired links cannot be paid regardless of client-side display |
| TC-2.7.17 | Cancelled link (seller cancelled after generation) | Negative | Status shows 'Cancelled'; no CTA; no payment options; link inaccessible |
| TC-2.7.18 | Payment link is overdue by 1 hour past expiry | Negative | 'Link Expired' screen shown; link is inaccessible |

---

## 4. Gaps, Ambiguities & Risks

### 🔴 Critical

- **G-10 – SADAD Timeout**
  SADAD callback handling missing timeout definition. How long should system wait for bank confirmation?
  → Must be resolved before FR-2.21 implementation.

- **G-11 – Same-Card Retry Block**
  PRD states buyer must not retry same card immediately after failure (ambiguous transaction), but implementation mechanism not defined.
  → Clarify: block same-card immediately? Block all retries for N seconds? Add to FR-2.12 acceptance criteria.

### 🟡 High

- **G-12 – BNPL Upper Bound**
  PRD defines SAR 1,500 minimum but no upper limit specified. Does BNPL have a maximum amount threshold?
  → Confirm maximum with Al Rajhi integration team.

- **G-13 – Guest Buyer Post-Payment Account Creation**
  PRD does not specify if guest can create account post-payment or if their payment remains guest-only forever.
  → Clarify product intent: can guest buyers later claim their payments by creating account?

- **G-14 – In-Checkout Login for Registered Buyers**
  PRD states registered buyers must be logged in to link payment to account, but allows guest checkout. Can buyer log in *during* payment flow?
  → If yes, at which step? Before or after payment method selection?

### 🟠 Medium

- **G-15 – BNPL Instalment Display Timeline**
  Instalment schedule shown during approval flow (FR-2.5.4) but post-payment tracking deferred. When does schedule stop showing?
  → Clarify if schedule remains on success screen or removed immediately after approval.

- **G-16 – Multiple SADAD Bills on Same Link**
  If buyer selects SADAD, cancels, then selects SADAD again, is a new bill generated? Does old bill remain pending?
  → Clarify: does system cancel previous SADAD bill before generating new one?

- **G-17 – Failure Message Specificity**
  FR-2.30 says "failure reason is displayed where available" but specific text formats not defined for each failure type.
  → Provide standardized error message templates for card decline, 3DS fail, timeout, etc.

---

## 5. Open Questions

### High Priority (Blocking Test Design)

- **OQ-1: Registered Buyer Account Linkage During Checkout**
  PRD states registered buyer must be logged in to link payment. If buyer logs in *during* payment flow (e.g., before entering card), is payment retroactively linked to their account and appears in Received Payment Requests?
  - Impact: Test case design for OQ-1 login flow
  - Resolution: Product to confirm in-checkout login support

- **OQ-2: Same-Card Retry Prevention**
  PRD states "buyer must not be offered immediate retry because original charge may still succeed via delayed callback." How is this enforced?
  - Impact: Acceptance criteria for FR-2.12 and FR-2.7.2
  - Resolution: Engineering to define block duration and scope (same-card only or all retries?)

- **OQ-3: SADAD Callback Timeout**
  How long should system wait for SADAD bank confirmation callback before auto-failing the link?
  - Impact: Acceptance criteria for FR-2.21 and test timeout scenarios
  - Resolution: SADAD integration team to specify SLA

- **OQ-4: BNPL Maximum Amount Threshold**
  PRD specifies SAR 1,500 minimum but no upper limit. Does BNPL have a maximum amount or maximum instalment term?
  - Impact: Test boundary conditions for BNPL (TC-2.5.x)
  - Resolution: Al Rajhi integration team to confirm limits

### Medium Priority

- **OQ-5: Guest Buyer Account Upgrade**
  Can a guest buyer who completed a payment later create an APEX account and claim/view that payment in their Received Payment Requests?
  - Impact: Test scenario for guest-to-registered transition
  - Resolution: Product design decision

- **OQ-6: PDF Receipt Custom Content**
  Does seller have option to add custom message, notes, or T&Cs to the PDF receipt?
  - Impact: Design of FR-2.27 PDF generation
  - Resolution: Product scope confirmation

- **OQ-7: Payment Link Re-share After Payment**
  Can seller re-share a Paid payment link to buyer, and if so, what does buyer see (success screen or cannot-pay screen)?
  - Impact: Test scenario for post-payment link access (overlap with FR-2.6)
  - Resolution: Product to clarify re-sharing rules

- **OQ-8: Failed Payment Webhook Notifications**
  Should seller receive webhook or in-app notification on buyer's payment failures (generic, BNPL rejection, etc.)?
  - Impact: Integration test scope
  - Resolution: Out-of-scope per PRD, but affects admin dashboard design

- **OQ-9: Expired Link Reactivation**
  Can seller reactivate an expired payment link, or must they generate a new one?
  - Impact: Admin/seller-side test scope
  - Resolution: Product to confirm expiration is terminal

- **OQ-10: Multiple Buyers on Same Link**
  Can multiple different buyers pay towards the same payment link, or is link locked to the first successful buyer?
  - Impact: Multi-buyer failure test scenarios
  - Resolution: Confirm payment link is single-use only

---

## 6. Entry & Exit Criteria

### Entry Criteria (PRD2 Test Execution Ready When)

- ✅ PRD Phase 1 (Invoice to Payment Link creation) is deployed and stable on staging
- ✅ Payment gateway integration (Stripe / local test gateway) is functional for card/Apple Pay testing
- ✅ SADAD API integration (mock or live endpoint) is available for testing
- ✅ Al Rajhi BNPL API integration (mock or live endpoint) is available for testing
- ✅ Figma design frames are finalized and available at provided token link
- ✅ All critical gaps (OQ-1, OQ-2, OQ-3, OQ-4) are resolved
- ✅ Test data seeded: seller accounts, buyer accounts, sample invoices, payment methods configured in admin
- ✅ PDF receipt template is designed and functional

### Exit Criteria (PRD2 Test Complete When)

- ✅ All test cases (TC-2.1.1 through TC-2.7.18) executed and passed (or deferred with documented reason)
- ✅ All critical and high-risk paths covered by automated tests
- ✅ Payment success path tested end-to-end: invoice → payment link → all 4 payment methods → receipt
- ✅ All failure states tested: generic failures, BNPL rejection, SADAD pending, link expiration
- ✅ Guest and registered buyer flows tested
- ✅ Cross-browser/device testing complete for Apple Pay (Safari + iOS, non-Apple browsers negative)
- ✅ All payment method icons and UI elements match Figma design
- ✅ Seller's Created Payment Requests listing verified to update to Paid on buyer success
- ✅ Registered buyer's Received Payment Requests listing verified to reflect successful payments
- ✅ PDF receipt download and content verified
- ✅ Performance benchmarks met (payment processing <3s, receipt generation <2s)
- ✅ Regression testing of PRD1 flows (invoice creation, payment link generation) completed
- ✅ No critical or high-severity defects remain open
- ✅ Test coverage report generated (requirements → test case mapping)

---

## 7. Recommended Test Automation Strategy

**Priority 1 – Automate (High Coverage)**
- Payment success path for each payment method (TC-2.2.13, TC-2.3.7, TC-2.4.9, TC-2.5.3)
- All failure state transitions (TC-2.7.1, TC-2.7.5, TC-2.7.7, TC-2.7.11)
- Seller listing updates (TC-2.6.6, TC-2.6.7)
- Registered buyer Received Payment Requests (TC-2.6.8)
- PDF receipt generation (TC-2.6.4, TC-2.6.5)

**Priority 2 – Automate (Medium Coverage)**
- Form validation for all payment methods (TC-2.2.4 through TC-2.2.9)
- BNPL minimum warning (TC-2.5.9 through TC-2.5.11)
- SADAD bill generation and method switching (TC-2.4.1, TC-2.4.6, TC-2.4.7)

**Priority 3 – Manual (Complex Interactions)**
- 3DS challenge flow (requires interactive authentication)
- Apple Pay on actual iOS device (native sheet behavior)
- Al Rajhi BNPL eligibility decision (requires live or complex mock)
- SADAD callback timing and race conditions (requires async coordination)

---

## 8. Test Data & Fixtures Required

| Entity | Purpose | Examples |
|---|---|---|
| Seller Account | Payment link creator | Business: "Tech Supplies Inc.", Invoice: INV-26-000001 |
| Guest Buyer | No-account payment | No credentials; payment via guest checkout |
| Registered Buyer | Account-linked payment | Email: buyer@example.com, password: TestPass123 |
| Test Invoices | Payment link source | INV-26-000001 (SAR 5,000), INV-26-000002 (SAR 1,500 for BNPL min) |
| Payment Methods (Admin Config) | Seller-enabled methods | Credit Card (enabled), Apple Pay (enabled), SADAD (enabled), BNPL (enabled) |
| Test Cards | Card payment testing | Visa: 4111111111111111, Mastercard: 5555555555554444, Mada: various |
| SADAD Test Bill | SADAD flow testing | Bill number generation and callback simulation |
| BNPL Eligibility Scenarios | BNPL outcome testing | Approved buyer data, rejected buyer data, timeout scenario |

---

## Version History

| Version | Date | Status | Notes |
|---|---|---|---|
| 1.0 | May 11, 2026 | Draft | Initial test analysis created from PRD2 |

---

**Analysis prepared by:** QA Team
**Last Updated:** May 11, 2026
**Next Review:** After PRD2 critical gaps resolved
