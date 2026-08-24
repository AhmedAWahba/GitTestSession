# PRD Senior QC Review: Invoices & Credit Notes

## Findings First (Prioritized)

### Critical

| ID | Finding | Evidence | Risk | Recommendation |
|---|---|---|---|---|
| ICN-CR-01 | Credit note value guardrails are not defined in the invoice/CN PRD. The PRD requires linkage to one original invoice, but does not define whether cumulative credited amount must be capped at invoice total or outstanding balance. | PRD requirements for credit notes in [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3687), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3736). Registered credit note detail wireframes show totals but no explicit cap rule in content: [fixtures/figma-review/invoice-cn-wireframes/image69.png](fixtures/figma-review/invoice-cn-wireframes/image69.png), [fixtures/figma-review/invoice-cn-wireframes/image87.png](fixtures/figma-review/invoice-cn-wireframes/image87.png). | Financial/compliance inconsistency, negative outstanding anomalies, disputes between invoice and CN ledgers. | Add explicit rule set: cumulative CN amount <= original invoice total, and define behavior once invoice is fully offset. |
| ICN-CR-02 | Batch/template screens explicitly state no limit for rows per file, with no technical or operational limits documented. | Wireframe copy in template screens: [fixtures/figma-review/invoice-cn-wireframes/image55.png](fixtures/figma-review/invoice-cn-wireframes/image55.png), [fixtures/figma-review/invoice-cn-wireframes/image64.png](fixtures/figma-review/invoice-cn-wireframes/image64.png), [fixtures/figma-review/invoice-cn-wireframes/image73.png](fixtures/figma-review/invoice-cn-wireframes/image73.png), [fixtures/figma-review/invoice-cn-wireframes/image82.png](fixtures/figma-review/invoice-cn-wireframes/image82.png). | Import denial-of-service risk, timeout risk, non-deterministic UX at high volume. | Replace "no limit" copy with governed limits (max file size, max rows, processing SLA). |

### High

| ID | Finding | Evidence | Risk | Recommendation |
|---|---|---|---|---|
| ICN-H-01 | Reference uniqueness is specified, but normalization rules are missing (case sensitivity, leading/trailing spaces, Arabic/English numerals, punctuation). | Uniqueness requirements: [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3672), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3689), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3720), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3738). | Duplicate leakage or false positives across channels and imports. | Define canonical normalization before uniqueness checks and document in API/file rules. |
| ICN-H-02 | Verified-business precondition exists in PRD but gating/blocked-state UX is not visible in invoice/CN wireframes. | Preconditions: [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3647), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3676), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3724), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3742). Entry/list wireframes show normal register CTAs with no blocked variant: [fixtures/figma-review/invoice-cn-wireframes/image51.png](fixtures/figma-review/invoice-cn-wireframes/image51.png), [fixtures/figma-review/invoice-cn-wireframes/image61.png](fixtures/figma-review/invoice-cn-wireframes/image61.png), [fixtures/figma-review/invoice-cn-wireframes/image70.png](fixtures/figma-review/invoice-cn-wireframes/image70.png), [fixtures/figma-review/invoice-cn-wireframes/image79.png](fixtures/figma-review/invoice-cn-wireframes/image79.png). | Users in non-verified states may hit dead ends or unauthorized failures without clear guidance. | Add explicit blocked-state screens/messages and test criteria. |
| ICN-H-03 | Channel parity rule for credit notes is defined, but cross-channel duplicate and idempotency behavior is unspecified for same reference submitted via API then file upload (or vice versa). | Same-channel constraints: [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3695), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3744). Multi-channel entry paths: [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3665), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3667), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3713), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3715). | Duplicate registration race and reconciliation defects across ingestion channels. | Define idempotency key strategy and dedupe precedence across all channels. |

### Medium

| ID | Finding | Evidence | Risk | Recommendation |
|---|---|---|---|---|
| ICN-M-01 | Currency assumptions are implicit in UI (SAR labels) but not explicitly constrained in the FR tables. | Wireframes display SAR in totals columns and detail cards: [fixtures/figma-review/invoice-cn-wireframes/image51.png](fixtures/figma-review/invoice-cn-wireframes/image51.png), [fixtures/figma-review/invoice-cn-wireframes/image60.png](fixtures/figma-review/invoice-cn-wireframes/image60.png), [fixtures/figma-review/invoice-cn-wireframes/image61.png](fixtures/figma-review/invoice-cn-wireframes/image61.png), [fixtures/figma-review/invoice-cn-wireframes/image69.png](fixtures/figma-review/invoice-cn-wireframes/image69.png). | Multi-currency ambiguity in future integrations and reporting. | Add explicit currency model (single-currency SAR or supported currency list + conversion policy). |
| ICN-M-02 | Date semantics are underdefined (timezone for invoice date/due date, import-time interpretation). | Required date fields exist but no timezone rules: [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3668), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3716), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3687), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3736). | Boundary-date inconsistencies in audit and legal reporting. | Define timezone source and serialization rules for all channels. |
| ICN-M-03 | Error reasons appear as free text; reason-code taxonomy is not defined in PRD for machine-readable reconciliation. | Error/result screens: [fixtures/figma-review/invoice-cn-wireframes/image57.png](fixtures/figma-review/invoice-cn-wireframes/image57.png), [fixtures/figma-review/invoice-cn-wireframes/image59.png](fixtures/figma-review/invoice-cn-wireframes/image59.png), [fixtures/figma-review/invoice-cn-wireframes/image66.png](fixtures/figma-review/invoice-cn-wireframes/image66.png), [fixtures/figma-review/invoice-cn-wireframes/image68.png](fixtures/figma-review/invoice-cn-wireframes/image68.png), [fixtures/figma-review/invoice-cn-wireframes/image75.png](fixtures/figma-review/invoice-cn-wireframes/image75.png), [fixtures/figma-review/invoice-cn-wireframes/image84.png](fixtures/figma-review/invoice-cn-wireframes/image84.png). | Hard to automate retries, support workflows, and analytics on failure causes. | Introduce canonical reason codes + stable localized message mapping. |

## Positive Coverage Confirmed

- Immutability rule is consistently reflected in PRD and list/detail wireframes (registered records not editable/deletable): [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3645), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3675), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3692), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3723), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3741).
- One-credit-note-to-one-invoice rule is explicitly stated in both sales and purchase CN requirements: [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3694), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3743).
- Failure handling communicates full-document rejection and non-partial registration across invoice and CN flows: [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3673), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3690), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3721), [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3739).

---

## QC-Only Open Questions (Unanswered by PRD/Wireframes)

### Removed as already answered

1. Should registered invoices be editable after upload? Removed; answered in PRD: registered records are immutable.
2. Can a credit note correct more than one invoice? Removed; answered in PRD: one credit note maps to exactly one invoice.
3. Are partial rows accepted during import? Removed; answered in PRD: invalid required fields block registration of that document.
4. Are there explicit row limits in current wireframes? Removed from open list; wireframes state there is no row limit in template copy.

### Remaining QC open questions

1. What is the canonical normalization standard for reference uniqueness (case, whitespace, Arabic/English numerals, punctuation)?
2. What is the required idempotency and replay policy across API and upload channels?
3. Is mixed-validity file processing order deterministic, and if yes, what is the order contract?
4. Which timezone governs invoice date, due date, and credit-note date validation?
5. Is currency strictly SAR in scope, or should multi-currency be formally supported?
6. What is the exact blocked-state UX for non-verified businesses attempting registration?
7. Must invalid outputs include stable machine-readable reason codes in addition to human-readable text?
8. If the same reference appears across sales and purchase contexts, what is the exact collision-handling rule?
9. For credit notes, is cumulative value capped by original invoice total or by current outstanding balance?
10. If a credit note exceeds the allowed cap, is behavior full rejection or constrained acceptance?
11. After credit-note registration, what is the mandatory synchronization behavior for outstanding and payment-link eligibility/status?

---

## Review Scope

- PRD invoice/CN sections reviewed: [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3624) through [docs/Master APEX PRD Set.md](docs/Master%20APEX%20PRD%20Set.md#L3933).
- Wireframes reviewed from embedded PRD assets (extracted): [fixtures/figma-review/invoice-cn-wireframes](fixtures/figma-review/invoice-cn-wireframes).

---

## Part-Wise Independent Sorting (New Response)

### Invoices

1. What is the exact normalization standard for invoice reference uniqueness before duplicate checks (case, whitespace, Arabic/English numerals, punctuation)?
2. What is the approved idempotency and replay policy when the same invoice is submitted across different channels (API then upload, or upload then API)?
3. Are mixed-validity invoice files processed in a deterministic order, and if yes, how is that order defined?
4. What is the governing timezone for invoice date and due date validation in all channels?
5. Is currency strictly SAR or extensible, and is that a current-scope or future-scope decision?
6. What is the exact blocked-state UX for non-verified businesses attempting invoice registration (CTA state, error copy, recovery path)?
7. Must invalid invoice exports include stable reason codes in addition to readable text?
8. What is the exact collision-handling rule if the same reference appears across sales and purchase invoice contexts?

This part has insufficient context to answer.

Screenshots:
- [fixtures/figma-review/invoice-cn-wireframes/image51.png](fixtures/figma-review/invoice-cn-wireframes/image51.png)
- [fixtures/figma-review/invoice-cn-wireframes/image52.png](fixtures/figma-review/invoice-cn-wireframes/image52.png)
- [fixtures/figma-review/invoice-cn-wireframes/image54.png](fixtures/figma-review/invoice-cn-wireframes/image54.png)
- [fixtures/figma-review/invoice-cn-wireframes/image55.png](fixtures/figma-review/invoice-cn-wireframes/image55.png)
- [fixtures/figma-review/invoice-cn-wireframes/image57.png](fixtures/figma-review/invoice-cn-wireframes/image57.png)
- [fixtures/figma-review/invoice-cn-wireframes/image58.png](fixtures/figma-review/invoice-cn-wireframes/image58.png)
- [fixtures/figma-review/invoice-cn-wireframes/image59.png](fixtures/figma-review/invoice-cn-wireframes/image59.png)
- [fixtures/figma-review/invoice-cn-wireframes/image60.png](fixtures/figma-review/invoice-cn-wireframes/image60.png)

### Credit Notes

1. What is the financial cap rule for cumulative sales credit notes (cap at invoice total or cap at current outstanding)?
2. What is the policy when a sales credit note exceeds the allowed cap (full reject or constrained acceptance), including audit impact?
3. What is the normalization standard for sales credit note reference uniqueness?
4. What idempotency and replay protection apply to sales credit note submissions across API and upload channels?
5. Is processing deterministic for mixed-validity sales credit note files?
6. What is the authoritative timezone used for sales credit note date validation?
7. Are sales credit notes restricted to SAR, or do they support currency expansion?
8. What is the blocked-state UX for non-verified businesses trying to register sales credit notes?
9. Must invalid sales credit note outputs include stable, machine-readable reason codes?
10. What mandatory downstream synchronization is required after sales credit note registration (invoice outstanding and payment-link eligibility/status)?

This part has insufficient context to answer.

Screenshots:
- [fixtures/figma-review/invoice-cn-wireframes/image61.png](fixtures/figma-review/invoice-cn-wireframes/image61.png)
- [fixtures/figma-review/invoice-cn-wireframes/image62.png](fixtures/figma-review/invoice-cn-wireframes/image62.png)
- [fixtures/figma-review/invoice-cn-wireframes/image63.png](fixtures/figma-review/invoice-cn-wireframes/image63.png)
- [fixtures/figma-review/invoice-cn-wireframes/image64.png](fixtures/figma-review/invoice-cn-wireframes/image64.png)
- [fixtures/figma-review/invoice-cn-wireframes/image66.png](fixtures/figma-review/invoice-cn-wireframes/image66.png)
- [fixtures/figma-review/invoice-cn-wireframes/image67.png](fixtures/figma-review/invoice-cn-wireframes/image67.png)
- [fixtures/figma-review/invoice-cn-wireframes/image68.png](fixtures/figma-review/invoice-cn-wireframes/image68.png)
- [fixtures/figma-review/invoice-cn-wireframes/image69.png](fixtures/figma-review/invoice-cn-wireframes/image69.png)

### Purchase Invoices

1. What is the normalization standard for purchase invoice reference uniqueness?
2. What idempotency and replay policy apply to purchase invoice submissions across API and upload channels?
3. Is processing order deterministic for mixed-validity purchase invoice files?
4. What is the governing timezone for purchase invoice date and due date validation?
5. Are purchase invoices SAR-only, or are they designed for multi-currency evolution?
6. What is the blocked-state UX for non-verified businesses attempting purchase invoice registration?
7. Must invalid purchase invoice outputs include stable reason codes?
8. What is the exact collision-handling rule if the same reference appears across purchase and sales invoice contexts?

This part has insufficient context to answer.

Screenshots:
- [fixtures/figma-review/invoice-cn-wireframes/image70.png](fixtures/figma-review/invoice-cn-wireframes/image70.png)
- [fixtures/figma-review/invoice-cn-wireframes/image71.png](fixtures/figma-review/invoice-cn-wireframes/image71.png)
- [fixtures/figma-review/invoice-cn-wireframes/image72.png](fixtures/figma-review/invoice-cn-wireframes/image72.png)
- [fixtures/figma-review/invoice-cn-wireframes/image73.png](fixtures/figma-review/invoice-cn-wireframes/image73.png)
- [fixtures/figma-review/invoice-cn-wireframes/image75.png](fixtures/figma-review/invoice-cn-wireframes/image75.png)
- [fixtures/figma-review/invoice-cn-wireframes/image76.png](fixtures/figma-review/invoice-cn-wireframes/image76.png)
- [fixtures/figma-review/invoice-cn-wireframes/image77.png](fixtures/figma-review/invoice-cn-wireframes/image77.png)
- [fixtures/figma-review/invoice-cn-wireframes/image78.png](fixtures/figma-review/invoice-cn-wireframes/image78.png)

### Purchase Credit Notes

1. What is the financial cap rule for cumulative purchase credit notes (invoice total vs current outstanding)?
2. What is the policy for over-cap purchase credit notes (full reject vs constrained acceptance), including audit implications?
3. What is the normalization standard for purchase credit note reference uniqueness?
4. What idempotency and replay controls apply to purchase credit note submissions across API/upload channels?
5. Is processing deterministic for mixed-validity purchase credit note files?
6. What is the governing timezone for purchase credit note date validation?
7. Are purchase credit notes SAR-only, or is broader currency support planned?
8. What is the blocked-state UX for non-verified businesses attempting purchase credit note registration?
9. Must invalid purchase credit note outputs include stable reason codes?
10. What mandatory synchronization rules apply after purchase credit note registration (original purchase invoice outstanding updates)?

This part has insufficient context to answer.

Screenshots:
- [fixtures/figma-review/invoice-cn-wireframes/image79.png](fixtures/figma-review/invoice-cn-wireframes/image79.png)
- [fixtures/figma-review/invoice-cn-wireframes/image80.png](fixtures/figma-review/invoice-cn-wireframes/image80.png)
- [fixtures/figma-review/invoice-cn-wireframes/image81.png](fixtures/figma-review/invoice-cn-wireframes/image81.png)
- [fixtures/figma-review/invoice-cn-wireframes/image82.png](fixtures/figma-review/invoice-cn-wireframes/image82.png)
- [fixtures/figma-review/invoice-cn-wireframes/image84.png](fixtures/figma-review/invoice-cn-wireframes/image84.png)
- [fixtures/figma-review/invoice-cn-wireframes/image85.png](fixtures/figma-review/invoice-cn-wireframes/image85.png)
- [fixtures/figma-review/invoice-cn-wireframes/image86.png](fixtures/figma-review/invoice-cn-wireframes/image86.png)
- [fixtures/figma-review/invoice-cn-wireframes/image87.png](fixtures/figma-review/invoice-cn-wireframes/image87.png)

---

## New PRD Question Sections

The following sections contain the reviewed open questions. Questions already answered directly by the PRD are excluded. `Previously Asked` means the question was in the earlier question list. `New Question` means it was added during the detailed PRD review.

### Sales Invoices PRD

| Section | Question | Describe | PRD Section |
|---|---|---|---|
| Sales Invoice | What min/max values are allowed for Unit Price? | Previously Asked | Sales Invoices PRD / FR-1.5 |
| Sales Invoice | How many decimal places are allowed for Unit Price? | Previously Asked | Sales Invoices PRD / FR-1.5 |
| Sales Invoice | Are decimal quantities allowed, or only whole numbers? | Previously Asked | Sales Invoices PRD / FR-1.5 |
| Sales Invoice | How many decimal places are allowed for Quantity? | New Question | Sales Invoices PRD / FR-1.5 |
| Sales Invoice | What min/max values are allowed for fixed-amount and percentage discounts? | New Question | Sales Invoices PRD / FR-1.5 |
| Sales Invoice | How many decimal places are allowed for discounts? | New Question | Sales Invoices PRD / FR-1.5 |
| Sales Invoice | What are the minimum and maximum dates allowed for the Invoice Date? | New Question | Sales Invoices PRD / FR-1.4 |
| Sales Invoice | What are the minimum and maximum dates allowed for the Due Date? | New Question | Sales Invoices PRD / FR-1.4 |
| Sales Invoice | Can the Due Date be before the Invoice Date? | New Question | Sales Invoices PRD / FR-1.4 |
| Sales Invoice | Which timezone is used for the Invoice Date and Due Date? | New Question | Sales Invoices PRD / FR-1.4 |
| Sales Invoice | How are case differences handled when checking duplicate invoice references? | Previously Asked | Sales Invoices PRD / FR-1.7 and FR-1.8 |
| Sales Invoice | Are spaces at the beginning or end removed before checking duplicate invoice references? | Previously Asked | Sales Invoices PRD / FR-1.7 and FR-1.8 |
| Sales Invoice | Are Arabic and English numbers treated as the same value when checking duplicate invoice references? | Previously Asked | Sales Invoices PRD / FR-1.7 and FR-1.8 |
| Sales Invoice | How are special characters and punctuation handled when checking duplicate invoice references? | Previously Asked | Sales Invoices PRD / FR-1.7 and FR-1.8 |
| Sales Invoice | What happens if the system cannot assign a unique invoice reference? | Previously Asked | Sales Invoices PRD / FR-1.7 and FR-1.8 |
| Sales Invoice | What is the maximum file size allowed for a structured invoice file? | Previously Asked | Sales Invoices PRD / FR-1.3 |
| Sales Invoice | What is the maximum number of invoices allowed in one structured file? | New Question | Sales Invoices PRD / FR-1.3 |
| Sales Invoice | What is the maximum number of rows allowed in one structured file? | Previously Asked | Sales Invoices PRD / FR-1.3 |
| Sales Invoice | What is the maximum number of line items allowed for one invoice? | New Question | Sales Invoices PRD / FR-1.4 and FR-1.5 |
| Sales Invoice | When a file contains valid and invalid invoices, are the invoices processed in a fixed order? | Previously Asked | Sales Invoices PRD / FR-1.3 |
| Sales Invoice | Is the import result handled per row, per invoice, or for the complete file? | Previously Asked | Sales Invoices PRD / FR-1.3 and FR-1.9 |
| Sales Invoice | Should rejected invoices include an error code as well as the error message? | Previously Asked | Sales Invoices PRD / FR-1.9 |
| Sales Invoice | What should happen if the same invoice is sent through the API more than once? | Previously Asked | Sales Invoices PRD / FR-1.1 |
| Sales Invoice | What should happen if the same invoice is submitted through more than one channel? | New Question | Sales Invoices PRD / FR-1.1, FR-1.2, and FR-1.3 |
| Sales Invoice | Which buyer details are used to match the invoice with an existing business record? | New Question | Sales Invoices PRD / FR-1.4 |
| Sales Invoice | What happens when the buyer details in the submitted invoice do not match the business record? | New Question | Sales Invoices PRD / FR-1.4 |
| Sales Invoice | What is the maximum API request size for an invoice? | New Question | Sales Invoices PRD / FR-1.1 |
| Sales Invoice | What is the maximum number of invoice API requests allowed within a period? | New Question | Sales Invoices PRD / FR-1.1 |

### Sales Credit Notes PRD

| Section | Question | Describe | PRD Section |
|---|---|---|---|
| Sales Credit Note | What are the allowed sales credit-note reasons? | Previously Asked | Sales Credit Notes PRD / FR-2.1 |
| Sales Credit Note | Should each sales credit-note reason have its own code? | New Question | Sales Credit Notes PRD / FR-2.1 |
| Sales Credit Note | What min/max values are allowed for the credited amount? | New Question | Sales Credit Notes PRD / FR-2.1 and FR-2.4 |
| Sales Credit Note | How many decimal places are allowed for the credited amount? | New Question | Sales Credit Notes PRD / FR-2.1 and FR-2.4 |
| Sales Credit Note | Are partial quantities allowed for credited line items? | Previously Asked | Sales Credit Notes PRD / FR-2.1 |
| Sales Credit Note | How many decimal places are allowed for credited quantities? | New Question | Sales Credit Notes PRD / FR-2.1 |
| Sales Credit Note | Should the total credit-note amount be limited to the original invoice total or the current outstanding balance? | Previously Asked | Sales Credit Notes PRD / FR-2.1 and FR-2.4 |
| Sales Credit Note | What should happen if the credit note is higher than the allowed amount: reject the full credit note or accept only the allowed amount? | Previously Asked | Sales Credit Notes PRD / FR-2.1 and FR-2.4 |
| Sales Credit Note | What should happen if two credit notes are created for the same invoice at the same time? | Previously Asked | Sales Credit Notes PRD / FR-2.1 |
| Sales Credit Note | What are the minimum and maximum dates allowed for the Credit Note Date? | New Question | Sales Credit Notes PRD / FR-2.1 |
| Sales Credit Note | Which timezone is used for the Credit Note Date? | Previously Asked | Sales Credit Notes PRD / FR-2.1 |
| Sales Credit Note | How are case differences handled when checking duplicate credit-note references? | Previously Asked | Sales Credit Notes PRD / FR-2.3 |
| Sales Credit Note | Are spaces at the beginning or end removed before checking duplicate credit-note references? | Previously Asked | Sales Credit Notes PRD / FR-2.3 |
| Sales Credit Note | Are Arabic and English numbers treated as the same value when checking duplicate credit-note references? | Previously Asked | Sales Credit Notes PRD / FR-2.3 |
| Sales Credit Note | How are special characters and punctuation handled when checking duplicate credit-note references? | Previously Asked | Sales Credit Notes PRD / FR-2.3 |
| Sales Credit Note | Is duplicate checking applied across API, file upload, and structured-file channels? | Previously Asked | Sales Credit Notes PRD / FR-2.3 and FR-2.9 |
| Sales Credit Note | What should happen if the same sales credit note is sent through the API more than once? | Previously Asked | Sales Credit Notes PRD / FR-2.9 |
| Sales Credit Note | What should happen if the same sales credit note is submitted through different channels? | Previously Asked | Sales Credit Notes PRD / FR-2.9 |
| Sales Credit Note | If the original invoice and credit note are in the same file, which one is processed first? | Previously Asked | Sales Credit Notes PRD / FR-2.2 and FR-2.9 |
| Sales Credit Note | What should happen if the original invoice is not registered yet: reject the credit note or retry it later? | Previously Asked | Sales Credit Notes PRD / FR-2.2 |
| Sales Credit Note | What is the maximum file size allowed for a structured credit-note file? | New Question | Sales Credit Notes PRD / FR-2.9 |
| Sales Credit Note | What is the maximum number of credit notes allowed in one structured file? | New Question | Sales Credit Notes PRD / FR-2.9 |
| Sales Credit Note | What is the maximum number of rows allowed in one structured file? | New Question | Sales Credit Notes PRD / FR-2.9 |
| Sales Credit Note | When a file contains valid and invalid credit notes, are they processed in a fixed order? | Previously Asked | Sales Credit Notes PRD / FR-2.4 and FR-2.9 |
| Sales Credit Note | Is the import result handled per row, per credit note, or for the complete file? | Previously Asked | Sales Credit Notes PRD / FR-2.4 and FR-2.9 |
| Sales Credit Note | Should rejected credit notes include an error code as well as the error message? | Previously Asked | Sales Credit Notes PRD / FR-2.4 |
| Sales Credit Note | What rounding rule is used when recalculating the original invoice balance? | Previously Asked | Sales Credit Notes PRD / FR-2.1 |
| Sales Credit Note | When is the original invoice balance recalculated after registering a credit note? | New Question | Sales Credit Notes PRD / FR-2.1 |
| Sales Credit Note | What should happen if several credit notes update the same invoice balance at the same time? | Previously Asked | Sales Credit Notes PRD / FR-2.1 |

### Purchase Invoices PRD

| Section | Question | Describe | PRD Section |
|---|---|---|---|
| Purchase Invoice | What min/max values are allowed for Unit Price? | Previously Asked | Purchase Invoices PRD / FR-3.5 |
| Purchase Invoice | How many decimal places are allowed for Unit Price? | Previously Asked | Purchase Invoices PRD / FR-3.5 |
| Purchase Invoice | Are decimal quantities allowed, or only whole numbers? | Previously Asked | Purchase Invoices PRD / FR-3.5 |
| Purchase Invoice | How many decimal places are allowed for Quantity? | New Question | Purchase Invoices PRD / FR-3.5 |
| Purchase Invoice | What min/max values are allowed for fixed-amount and percentage discounts? | New Question | Purchase Invoices PRD / FR-3.5 |
| Purchase Invoice | How many decimal places are allowed for discounts? | New Question | Purchase Invoices PRD / FR-3.5 |
| Purchase Invoice | What are the minimum and maximum dates allowed for the Invoice Date? | New Question | Purchase Invoices PRD / FR-3.4 |
| Purchase Invoice | What are the minimum and maximum dates allowed for the Due Date? | New Question | Purchase Invoices PRD / FR-3.4 |
| Purchase Invoice | Can the Due Date be before the Invoice Date? | New Question | Purchase Invoices PRD / FR-3.4 |
| Purchase Invoice | Which timezone is used for the Invoice Date and Due Date? | New Question | Purchase Invoices PRD / FR-3.4 |
| Purchase Invoice | How are case differences handled when checking duplicate purchase-invoice references? | Previously Asked | Purchase Invoices PRD / FR-3.7 and FR-3.8 |
| Purchase Invoice | Are spaces at the beginning or end removed before checking duplicate purchase-invoice references? | Previously Asked | Purchase Invoices PRD / FR-3.7 and FR-3.8 |
| Purchase Invoice | Are Arabic and English numbers treated as the same value when checking duplicate purchase-invoice references? | Previously Asked | Purchase Invoices PRD / FR-3.7 and FR-3.8 |
| Purchase Invoice | How are special characters and punctuation handled when checking duplicate purchase-invoice references? | Previously Asked | Purchase Invoices PRD / FR-3.7 and FR-3.8 |
| Purchase Invoice | What is the maximum file size allowed for a structured purchase-invoice file? | Previously Asked | Purchase Invoices PRD / FR-3.2 |
| Purchase Invoice | What is the maximum number of purchase invoices allowed in one structured file? | New Question | Purchase Invoices PRD / FR-3.2 |
| Purchase Invoice | What is the maximum number of rows allowed in one structured file? | New Question | Purchase Invoices PRD / FR-3.2 |
| Purchase Invoice | What is the maximum number of line items allowed for one purchase invoice? | New Question | Purchase Invoices PRD / FR-3.4 and FR-3.5 |
| Purchase Invoice | When a file contains valid and invalid purchase invoices, are the invoices processed in a fixed order? | New Question | Purchase Invoices PRD / FR-3.2 and FR-3.9 |
| Purchase Invoice | Is the import result handled per row, per invoice, or for the complete file? | New Question | Purchase Invoices PRD / FR-3.2 and FR-3.9 |
| Purchase Invoice | Should rejected purchase invoices include an error code as well as the error message? | New Question | Purchase Invoices PRD / FR-3.9 |
| Purchase Invoice | What should happen if the same purchase invoice is sent through the API more than once? | New Question | Purchase Invoices PRD / FR-3.3 |
| Purchase Invoice | What should happen if the same purchase invoice is submitted through different channels? | New Question | Purchase Invoices PRD / FR-3.1, FR-3.2, and FR-3.3 |
| Purchase Invoice | Which seller details are used to match the purchase invoice with an existing business record? | New Question | Purchase Invoices PRD / FR-3.4 |
| Purchase Invoice | What happens when the seller details in the purchase invoice do not match the business record? | New Question | Purchase Invoices PRD / FR-3.4 |
| Purchase Invoice | What is the maximum API request size for a purchase invoice? | New Question | Purchase Invoices PRD / FR-3.3 |
| Purchase Invoice | What is the maximum number of purchase-invoice API requests allowed within a period? | New Question | Purchase Invoices PRD / FR-3.3 |

### Purchase Credit Notes PRD

| Section | Question | Describe | PRD Section |
|---|---|---|---|
| Purchase Credit Note | What are the allowed purchase credit-note reasons? | Previously Asked | Purchase Credit Notes PRD / FR-4.1 |
| Purchase Credit Note | Should each purchase credit-note reason have its own code? | New Question | Purchase Credit Notes PRD / FR-4.1 |
| Purchase Credit Note | What min/max values are allowed for the credited amount? | New Question | Purchase Credit Notes PRD / FR-4.1 and FR-4.4 |
| Purchase Credit Note | How many decimal places are allowed for the credited amount? | New Question | Purchase Credit Notes PRD / FR-4.1 and FR-4.4 |
| Purchase Credit Note | Are partial quantities allowed for credited line items? | Previously Asked | Purchase Credit Notes PRD / FR-4.1 |
| Purchase Credit Note | How many decimal places are allowed for credited quantities? | New Question | Purchase Credit Notes PRD / FR-4.1 |
| Purchase Credit Note | Should the total purchase credit-note amount be limited to the original invoice total or the current outstanding balance? | Previously Asked | Purchase Credit Notes PRD / FR-4.1 and FR-4.4 |
| Purchase Credit Note | What should happen if the purchase credit note is higher than the allowed amount: reject the full credit note or accept only the allowed amount? | Previously Asked | Purchase Credit Notes PRD / FR-4.1 and FR-4.4 |
| Purchase Credit Note | What should happen if two purchase credit notes are created for the same invoice at the same time? | Previously Asked | Purchase Credit Notes PRD / FR-4.1 |
| Purchase Credit Note | What are the minimum and maximum dates allowed for the Credit Note Date? | New Question | Purchase Credit Notes PRD / FR-4.1 |
| Purchase Credit Note | Which timezone is used for the Purchase Credit Note Date? | Previously Asked | Purchase Credit Notes PRD / FR-4.1 |
| Purchase Credit Note | How are case differences handled when checking duplicate purchase credit-note references? | Previously Asked | Purchase Credit Notes PRD / FR-4.3 |
| Purchase Credit Note | Are spaces at the beginning or end removed before checking duplicate purchase credit-note references? | Previously Asked | Purchase Credit Notes PRD / FR-4.3 |
| Purchase Credit Note | Are Arabic and English numbers treated as the same value when checking duplicate purchase credit-note references? | Previously Asked | Purchase Credit Notes PRD / FR-4.3 |
| Purchase Credit Note | How are special characters and punctuation handled when checking duplicate purchase credit-note references? | Previously Asked | Purchase Credit Notes PRD / FR-4.3 |
| Purchase Credit Note | Is duplicate checking applied across API, file upload, and structured-file channels? | Previously Asked | Purchase Credit Notes PRD / FR-4.3 and FR-4.9 |
| Purchase Credit Note | What should happen if the same purchase credit note is sent through the API more than once? | New Question | Purchase Credit Notes PRD / FR-4.9 |
| Purchase Credit Note | What should happen if the same purchase credit note is submitted through different channels? | New Question | Purchase Credit Notes PRD / FR-4.9 |
| Purchase Credit Note | If the original purchase invoice and credit note are in the same file, which one is processed first? | Previously Asked | Purchase Credit Notes PRD / FR-4.2 and FR-4.9 |
| Purchase Credit Note | What should happen if the original purchase invoice is not registered yet: reject the credit note or retry it later? | Previously Asked | Purchase Credit Notes PRD / FR-4.2 |
| Purchase Credit Note | What is the maximum file size allowed for a structured purchase credit-note file? | New Question | Purchase Credit Notes PRD / FR-4.9 |
| Purchase Credit Note | What is the maximum number of purchase credit notes allowed in one structured file? | New Question | Purchase Credit Notes PRD / FR-4.9 |
| Purchase Credit Note | What is the maximum number of rows allowed in one structured file? | New Question | Purchase Credit Notes PRD / FR-4.9 |
| Purchase Credit Note | When a file contains valid and invalid purchase credit notes, are they processed in a fixed order? | New Question | Purchase Credit Notes PRD / FR-4.4 and FR-4.9 |
| Purchase Credit Note | Is the import result handled per row, per credit note, or for the complete file? | New Question | Purchase Credit Notes PRD / FR-4.4 and FR-4.9 |
| Purchase Credit Note | Should rejected purchase credit notes include an error code as well as the error message? | New Question | Purchase Credit Notes PRD / FR-4.4 |
| Purchase Credit Note | What rounding rule is used when recalculating the original purchase invoice balance? | New Question | Purchase Credit Notes PRD / FR-4.1 |
| Purchase Credit Note | When is the original purchase invoice balance recalculated after registering a credit note? | New Question | Purchase Credit Notes PRD / FR-4.1 |
| Purchase Credit Note | What should happen if several purchase credit notes update the same purchase invoice balance at the same time? | New Question | Purchase Credit Notes PRD / FR-4.1 |
