# Invoice Analysis

## Sources Reviewed
- d:/Master APEX PRD Set.md
- prompts/PaymentLink_Analysis.md
- prompts/PRD2_PaymentExecution_Analysis.md
- docs/prd-analysis/qawafel-business-registration-product-context-synthesis.md
- docs/prd-analysis/qawafel-business-partner-management.md

## Section Template
| Field | Description |
|---|---|
| Objective | Business outcome expected from the PRD |
| Scope | What is included and excluded |
| Success Criteria | Observable outcomes or functional requirements |
| Key Features | Core capabilities in the PRD |
| Stakeholders | Primary owners and impacted users |
| Risks | Delivery, compliance, data, UX, or operational risks |

## PRD 4: Invoice Creation - Drafting
| Field | Details |
|---|---|
| Objective | Enable authorised businesses to prepare compliant invoice drafts before legal submission. |
| Scope | In scope: draft creation, buyer selection from trading partners, catalog lines, line discount, VAT calculations, draft save/delete. Out of scope: post-submission editing. |
| Success Criteria | Draft starts from invoice module; buyer and seller details are controlled; required fields enforced for submission path; draft can be saved incomplete and deleted. |
| Key Features | Trading-partner-only buyer selection, catalog-only lines, line-level override snapshot, line-level discount, VAT per rate grouping, optional notes, draft persistence. |
| Stakeholders | Seller business users, product manager, backend/API team, compliance. |
| Risks | Missing numeric precision rules; undefined max limits (quantity/notes); unclear concurrent draft behavior. |

### Prototype
- Link: [MISSING: prototype link for PRD 4]
- Assessment: No direct prototype mapping found in repository artifacts for this PRD section.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| Draft behavior | Full draft lifecycle prior to submit | [MISSING: prototype evidence] | Coverage gap | Add prototype walkthrough or screenshots mapped to FR-4.x. |
| Validation depth | Quantity/discount/date validations needed | [MISSING: max/min and rounding in PRD] | Requirement gap | Add explicit validation matrix (min/max/precision/error copy). |

## PRD 5: Invoice Creation - Submission and ZATCA
| Field | Details |
|---|---|
| Objective | Convert a draft into a legal invoice by atomic submission and clearance lifecycle. |
| Scope | In scope: submit once, lock identifiers, Sent to ZATCA, Cleared/Rejected outcomes, permanent retention. Out of scope: resubmit rejected invoice. |
| Success Criteria | Single-action submit with lock/send behavior; immutable post-submit records; status transition integrity; no delete after Draft. |
| Key Features | Submission atomicity, auto reference numbering, timestamped pending state, legal immutability, cleared invoice download, credit note launch action. |
| Stakeholders | Seller business users, compliance/legal, platform operations, integration team. |
| Risks | Indefinite pending state with no user escalation; unclear retry/idempotency contract; timezone/date lock ambiguity. |

### Prototype
- Link: [MISSING: prototype link for PRD 5]
- Assessment: No explicit prototype flow in repo proving Sent-to-ZATCA lifecycle screens.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| Sent-to-ZATCA handling | Remains pending until response, no user-visible escalation | [MISSING: prototype behavior] | Validation gap | Define operational SLA and internal alerting while preserving user-facing rule. |
| Rejected recovery | No resubmit; create new invoice | [MISSING: UX evidence for restart path] | UX gap | Specify clone/new-from-rejected journey to reduce user re-entry risk. |

## PRD 6: Invoice Import - Bulk CSV (Invoices)
| Field | Details |
|---|---|
| Objective | Import already-cleared invoices from external systems in bulk. |
| Scope | In scope: template download, file upload, row-level validation, partial success import, status Cleared registration. Out of scope: catalog interaction. |
| Success Criteria | Valid rows import without being blocked by invalid rows; clear row-level error reasons; stored reference unchanged. |
| Key Features | Required-template fields, duplicate reference rejection, partner matching, VAT treatment constraints, partial import summary. |
| Stakeholders | Seller finance teams, migration teams, support, backend import services. |
| Risks | Large file performance constraints unspecified; matching rules not fully defined; missing normalization rules for references. |

### Prototype
- Link: [MISSING: prototype link for PRD 6]
- Assessment: No import UI/API prototype evidence found in the repository.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| Import limits | Multi-row imports supported | [MISSING: limits] | Requirement gap | Add file size, row count, and timeout limits. |
| Error payload | Specific row reasons required | [MISSING: downloadable report spec] | Functional gap | Define structured error export format and reason-code taxonomy. |

## PRD 7: Credit Notes Import - Bulk CSV (Credit Notes)
| Field | Details |
|---|---|
| Objective | Bulk import historical credit notes and link them to original invoices. |
| Scope | In scope: optional co-upload with invoices, original-invoice reference checks, row-level validation, auto-balance recalculation. |
| Success Criteria | Only valid notes import; each imported note links to original invoice and recalculates outstanding amount. |
| Key Features | Optional credit note file, dependency on original invoice presence, unique note reference checks, partial success handling. |
| Stakeholders | Seller finance teams, accounting, data migration owners. |
| Risks | Out-of-order dependencies in same batch; unclear duplicate handling across channels; recalculation precision risk. |

### Prototype
- Link: [MISSING: prototype link for PRD 7]
- Assessment: Prototype or design evidence not available in current repository snapshot.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| Batch dependency | Notes require original invoice in same import or existing records | [MISSING: processing-order spec] | Requirement gap | Define deterministic row ordering and dependency resolution policy. |
| Recalculation | Balance auto-updated after import | [MISSING: rounding rules] | Data gap | Define precision and floor-at-zero behavior. |

## PRD 8: Invoice Import - API (Invoices)
| Field | Details |
|---|---|
| Objective | Let verified businesses integrate external invoice systems via API import. |
| Scope | In scope: access request, test-to-live progression, validation, cleared registration, unified list visibility. |
| Success Criteria | Test access before live; invalid payloads rejected with reason; accepted invoices appear as Cleared with origin indicator. |
| Key Features | Access gating, test/live approval workflow, validation parity with CSV path, catalog isolation, channel tagging. |
| Stakeholders | Integration engineers, platform ops, security/compliance, seller enterprises. |
| Risks | Missing API contract and idempotency details; weak error-code formalization; access approval SLA ambiguity. |

### Prototype
- Link: [MISSING: prototype link for PRD 8]
- Assessment: No technical prototype/API schema artifact linked in repo docs.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| API contract | Clear accept/reject behavior | [MISSING: OpenAPI or equivalent] | Technical gap | Publish API schema, error model, and idempotency behavior. |
| Access workflow | Test then live approval | [MISSING: role/SLA/approval screens] | Process gap | Define approver persona, queue process, and measurable SLA. |

## PRD 9: Credit Notes Import - API (Credit Notes)
| Field | Details |
|---|---|
| Objective | Accept credit notes via API using invoice import access controls. |
| Scope | In scope: original invoice reference validation, clear rejections, linkage and recalculation on success. |
| Success Criteria | Invalid credit notes rejected with reason; valid ones registered as Cleared and linked to invoice. |
| Key Features | Shared API access with invoices, strict original invoice dependency, automatic link and recalculation. |
| Stakeholders | Integration teams, finance operations, support. |
| Risks | Out-of-order message arrival; missing retry semantics; duplicate note reference race conditions. |

### Prototype
- Link: [MISSING: prototype link for PRD 9]
- Assessment: No prototype evidence found for credit note API import interactions.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| Original invoice dependency | Must exist in APEX to accept note | [MISSING: deferred-processing policy] | Requirement gap | Define hold/retry queue or strict reject-only model explicitly. |
| Error interoperability | Caller receives reason | [MISSING: machine-readable reason schema] | Integration gap | Add stable reason codes and localization-safe messages. |

## PRD 10: Invoice List View
| Field | Details |
|---|---|
| Objective | Provide one unified invoice index across all intake channels. |
| Scope | In scope: search, sort, single-value filters, status-specific actions, overdue highlights, related-credit-note indicator. |
| Success Criteria | All channel invoices listed; default sort correct; action matrix enforced by status. |
| Key Features | Channel indicator, overdue visual cue, list empty states, link to related credit notes. |
| Stakeholders | Seller users, support/ops, product/design. |
| Risks | Filter/search behavior ambiguity; accessibility and indicator consistency risk; missing exact empty-state copy. |

### Prototype
- Link: [MISSING: prototype link for PRD 10]
- Assessment: Prototype linkage not explicitly provided for the invoice list module.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| Search semantics | Search by ref and buyer name | [MISSING: exact matching rules] | Requirement gap | Define case sensitivity, partial matching, and tokenization rules. |
| Filter behavior | One filter value at a time | [MISSING: design rationale] | UX gap | Confirm whether multi-filter combinations are intentionally out of scope. |

## PRD 11: Invoice Detail View and Status Lifecycle
| Field | Details |
|---|---|
| Objective | Present complete invoice details, lifecycle history, and status-guarded actions. |
| Scope | In scope: lifecycle and payment statuses, history with timestamps, action matrix, immutable constraints post-draft. |
| Success Criteria | Detail view consistently enforces allowed actions and shows linked credit note context. |
| Key Features | Origin channel display, status history timeline, overdue derivation, no void/cancel/revert actions. |
| Stakeholders | Seller users, finance operations, auditors/compliance. |
| Risks | Manual vs derived payment status conflict; incomplete event provenance; API/UI enforcement drift. |

### Prototype
- Link: [MISSING: prototype link for PRD 11]
- Assessment: No accessible walkthrough artifact proving full action-matrix compliance.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| Payment status precedence | Manual set or derived from payments | [MISSING: precedence rule] | Logic gap | Define deterministic precedence and recalculation triggers. |
| History completeness | Full timeline with timestamps | [MISSING: retention depth] | Data gap | Specify event retention scope and immutable audit controls. |

## PRD 12: Credit Note Creation
| Field | Details |
|---|---|
| Objective | Allow compliant creation of credit notes from cleared invoices. |
| Scope | In scope: reason selection, inherited parties, line-limited crediting, amount caps, timing warning rules. |
| Success Criteria | Credit note can only start from Cleared invoice; amount cannot exceed original; reason always required. |
| Key Features | Partial/full credit support, distinct numbering prefix, no due date, warning (not block) for late issuance. |
| Stakeholders | Seller users, compliance, finance controllers. |
| Risks | Missing explicit reason enumeration in extracted corpus; quantity precision ambiguity; warning copy undefined. |

### Prototype
- Link: [MISSING: prototype link for PRD 12]
- Assessment: No direct prototype section found to validate reason selector and amount constraints.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| Reason values | Exactly five ZATCA reasons | [MISSING: enumerated values in reviewed artifacts] | Requirement gap | Add explicit reason code list in PRD and API contracts. |
| Late issuance warning | Warning-only after threshold | [MISSING: exact copy and locale variants] | UX gap | Define warning messages and translation keys. |

## PRD 13: Credit Note Submission and Lifecycle
| Field | Details |
|---|---|
| Objective | Submit draft credit notes to ZATCA with immutable lifecycle handling. |
| Scope | In scope: submit and lock as single action, Sent/Cleared/Rejected outcomes, recalculation effects, retention. |
| Success Criteria | No editable fields post-submit; cleared notes update invoice balance/payment status; rejected notes retain original invoice values. |
| Key Features | Atomic submission, no resubmit for rejected notes, unresolved connectivity stays Sent to ZATCA, downloadable cleared note. |
| Stakeholders | Seller users, integration/ops, compliance. |
| Risks | Pending-state operations ambiguity; duplicate submit race conditions; recalculation timing edge cases. |

### Prototype
- Link: [MISSING: prototype link for PRD 13]
- Assessment: No explicit prototype evidence captured for credit-note lifecycle states.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| Recalculation consistency | Balance and payment status updates on clear | [MISSING: sequencing rule with payments] | Logic gap | Define event ordering and reconciliation strategy. |
| Rejected note retention | Permanent record, no resubmit | [MISSING: UX restart path] | UX gap | Add guided new-note workflow from rejected context. |

## PRD 14: Credit Note List View
| Field | Details |
|---|---|
| Objective | Offer dedicated discoverability for credit notes with links back to invoices. |
| Scope | In scope: search, default sort, single-status filtering, status-based row actions, empty-state variants. |
| Success Criteria | Credit notes appear in dedicated list; invoice linkage works; action matrix by status is enforced. |
| Key Features | Cross-link to invoice, filtered navigation from invoice indicator, distinct list context from invoices. |
| Stakeholders | Seller users, support, product/design. |
| Risks | Search semantics not fully specified; action-matrix duplication risk between list and detail views. |

### Prototype
- Link: [MISSING: prototype link for PRD 14]
- Assessment: No linked prototype state coverage discovered in repository.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| Search scope | Note ref, buyer, linked invoice ref | [MISSING: match behavior details] | Requirement gap | Define exact search behavior and test fixtures. |
| Empty states | Distinct no-data variants | [MISSING: approved copy] | UX gap | Freeze final empty-state messages for regression testing. |

## PRD 15: Credit Note Detail View and Status Lifecycle
| Field | Details |
|---|---|
| Objective | Provide traceable credit-note details with strict lifecycle guardrails. |
| Scope | In scope: lifecycle display, original-invoice link, channel display, history timeline, status-specific action restrictions. |
| Success Criteria | No edit/delete/resubmit in disallowed statuses; cleared notes downloadable; permanent retention post-draft. |
| Key Features | Detail-level matrix, immutable history, bidirectional navigation with original invoice. |
| Stakeholders | Seller users, auditors, support, compliance. |
| Risks | Inconsistent matrix enforcement across modules; missing fallback if linked invoice unavailable. |

### Prototype
- Link: [MISSING: prototype link for PRD 15]
- Assessment: Prototype validation artifact not present in current project files.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| Matrix parity | List/detail actions must match status matrix | [MISSING: single source of truth] | Governance gap | Publish one canonical matrix artifact used by design, backend, and QA. |
| Link reliability | Original invoice always linked | [MISSING: broken link behavior] | Reliability gap | Define fallback UX and error handling when linked record is inaccessible. |

## PRD 16: Invoice Sharing
| Field | Details |
|---|---|
| Objective | Introduce seller-triggered invoice sharing to buyers inside Qawafel, with optional auto-send. |
| Scope | In scope: send action with inside-Qawafel option, buyer notification, Received Invoices tab visibility, irreversibility, cleared-only and Qawafel-generated-only constraints. Out of scope: external channels detailed behavior. |
| Success Criteria | Manual or auto-send path controlled; only eligible invoices can be sent; action cannot be reverted. |
| Key Features | Multi-channel send intent, default no-send behavior, inside-Qawafel notifications, global auto-send toggle (off by default). |
| Stakeholders | Seller users, buyer users, product/design, notifications team, compliance. |
| Risks | Draft-level specification only; no FR table/user stories; undefined delivery failure and retry model; unclear audit evidence model. |

### Prototype
- Link: [MISSING: prototype link for PRD 16]
- Assessment: Current section is message-level specification and not represented with formal prototype and testable criteria in repo.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| Lifecycle detail | Send is irreversible and buyer-visible | [MISSING: status model for queued/sent/read/failed] | Requirement gap | Define end-to-end state model and telemetry for delivery outcomes. |
| Eligibility rules | Cleared + Qawafel-generated only | [MISSING: eligibility checks in UX/API] | Logic gap | Add explicit validation points and error messages for ineligible invoices. |

## PRD 1: Invoice to Payment Link MVP
| Field | Details |
|---|---|
| Objective | Allow sellers to generate and share payment links from invoice context. |
| Scope | In scope: seller signup/login baseline assumptions, buyer selection/creation, payment request configuration, link generation and sharing paths. |
| Success Criteria | Link generated against eligible invoice; channel sharing works; method constraints enforced. |
| Key Features | Buyer management, payment method controls, send-now/send-later behavior, payment-link lifecycle actions. |
| Stakeholders | Sellers, buyers, payment operations, product/design, engineering. |
| Risks | PRD vs Figma drift on buyer delete, notes/memo field, copy inconsistencies, undefined login behavior in PRD. |

### Prototype
- Link: https://www.figma.com/design/v3CjDjDMvxqHqHRoq6GscH/APEX---Payment-Flow?node-id=178-22248
- Assessment: Strong design coverage exists, but documented mismatches remain between PRD statements and Figma frames.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| Buyer actions | PRD describes edit behavior | Figma shows Edit and Delete actions | Scope mismatch | Confirm if delete is in scope; update PRD and tests accordingly. |
| Payment request fields | PRD covers send-now/send-later controls | Figma includes Notes/Memo and "Sending Mode" section label | Requirement mismatch | Decide if notes/sending-mode semantics are functional or presentational; update PRD. |
| Copy consistency | Stable navigation copy expected | Signup frame copy inconsistent ("Log in" vs "Create new account") | UX mismatch | Finalize canonical copy and update design + acceptance tests. |

## PRD 2: Buyer Execution and Failure Handling
| Field | Details |
|---|---|
| Objective | Define buyer-side payment execution and resilient failure handling across methods. |
| Scope | In scope: buyer payment journey, failures and retries, method-specific constraints and validations. |
| Success Criteria | Buyers can complete or recover payment attempts with clear status updates and reliable post-payment outcomes. |
| Key Features | Multi-method execution logic, failure-state UX, post-payment confirmation flows. |
| Stakeholders | Buyers, sellers, payment processing team, support, compliance. |
| Risks | Final design-token dependency for validation; possible mismatch between PRD and final UI interactions. |

### Prototype
- Link: https://www.figma.com/design/v3CjDjDMvxqHqHRoq6GscH/APEX---Payment-Flow?node-id=178-22248
- Assessment: Prototype/design reference exists; readiness notes in repository indicate dependency on finalized Figma frames.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| Failure-state completeness | PRD-driven scenarios required | Test-readiness notes depend on final frame availability | Traceability gap | Lock and version final frame set before test sign-off. |
| Method behavior details | Method constraints should be explicit | Some constraints inferred from design/test docs, not always explicit in PRD text | Requirement gap | Backfill PRD with explicit per-method failure and recovery rules. |

## Combined Analysis

### Common Gaps Across PRDs
| Gap Theme | Where It Appears | Impact | Priority |
|---|---|---|---|
| Missing prototype links or inaccessible prototype evidence | PRD 4-16 (mostly) | Slower validation and higher interpretation risk | High |
| Undefined limits/precision/idempotency | PRD 4-9, 11-13 | Data integrity and inconsistent behaviors across channels | High |
| Incomplete user-facing copy catalogs for errors/empty states | PRD 6, 10, 12, 14, 16 and payment-link docs | Test instability and UX inconsistency | Medium |
| Incomplete operational model for pending external states | PRD 5 and 13 | Support burden and monitoring blind spots | High |
| Action-matrix source fragmentation | PRD 10, 11, 14, 15 | UI/Backend drift and regression risk | High |

### Open Questions Raised During Analysis
| # | Question | Affected PRDs | Owner Suggestion |
|---|---|---|---|
| 1 | What are hard limits for import files/payloads (size, rows, timeouts)? | 6, 7, 8, 9 | PM + Engineering |
| 2 | What is canonical idempotency/retry behavior for submit/import APIs? | 5, 8, 9, 13 | Engineering |
| 3 | Which timezone and date-cutoff logic govern submission and overdue statuses? | 5, 10, 11, 13 | PM + Engineering |
| 4 | What are the exact approved user-facing messages for key errors/warnings and empty states? | 6, 10, 12, 14, 16 | PM + Design |
| 5 | Is buyer deletion in payment-link buyer management in scope? | Payment Link PRD 1 | PM |
| 6 | Is Notes/Memo in payment request functional or cosmetic? | Payment Link PRD 1 | PM + Design |
| 7 | What is the full delivery-state model for inside-Qawafel invoice sharing? | 16 | PM + Engineering |

### PRD vs Prototype Differences (Consolidated)
| PRD | Prototype Availability | Key Differences | Decision Needed |
|---|---|---|---|
| PRD 4-15 (invoice/credit note lifecycle set) | Mostly missing in repo | Coverage gaps in visual/interaction validation rather than confirmed contradictions | Publish traceable prototype artifacts per module |
| PRD 16 (Invoice Sharing) | Missing | Requirements are high-level; no formal FR/user-story/prototype parity | Convert draft notes into formal PRD with testable criteria |
| Payment Link PRD 1 | Figma link present | Buyer delete action, Notes/Memo field, copy inconsistencies | Confirm scope and update PRD/design alignment |
| Payment Link PRD 2 | Figma link present | Readiness tied to finalized design frames; some behavior implicit in design docs | Freeze frame baseline and map to explicit acceptance criteria |

### Differences and Gaps (Concrete Mismatches and Missing Requirements)
| Area | Mismatch or Missing Requirement | Risk | Recommended Action |
|---|---|---|---|
| Payment Link buyer management | Figma includes delete action; PRD text mainly covers edit | Destructive action ambiguity and data loss risk | Add delete requirements (authorization, confirmation, downstream impact) or remove from design |
| Payment request modal | Notes/Memo and Sending Mode appear in design but not fully in PRD | Unclear implementation scope | Explicitly classify fields as in-scope/out-of-scope and specify behavior |
| Invoice sharing (PRD 16) | No FR table, no state model, no error taxonomy | Cannot produce deterministic automation coverage | Create formal FRs, user stories, API/UI contracts, and notification state transitions |
| Import channels | Missing max limits, reason-code schema, idempotency guidance | Performance failures and inconsistent retries | Add platform limits and canonical error-code dictionary |
| Lifecycle pending states | Sent-to-ZATCA indefinite with no operational details | Monitoring and support blind spots | Define non-user-visible escalation and reconciliation operating model |

### Overall Implications and Next Steps
| Decision Area | Implication | Recommended Next Step |
|---|---|---|
| Specification quality | Current invoice set is strong functionally but has implementation-detail gaps | Run a requirements hardening pass for limits, precision, and idempotency |
| Prototype traceability | Missing links for many invoice modules blocks fast QA alignment | Require a prototype evidence checklist per PRD before implementation kickoff |
| Product/design consistency | Payment-link discrepancies can cause scope creep | Hold one PRD-design reconciliation review and freeze final baseline |
| Delivery readiness | PRD 16 is not test-ready in current form | Elevate PRD 16 from draft notes to full PRD before sprint commitment |

## Missing PRD or Prototype Remediation Plan
- Create a PRD inventory index file mapping each PRD to: owner, latest version, prototype link, and status.
- Require each PRD to include: acceptance table, edge-case matrix, copy catalog, and API/UI constraints.
- Enforce design/PRD parity check at story kickoff and before QA sign-off.
- Add a single source-of-truth action matrix for invoice and credit-note statuses used by list and detail views.

## Question Analysis by PRD (Single Table)
| PRD Title | Section | Question |
|---|---|---|
| PRD 4: Invoice Creation - Drafting | Invoice Date | Are past dates and future dates both allowed during Draft, and is there a max back/future range? |
| PRD 4: Invoice Creation - Drafting | Unit Price | What min/max values and decimal precision are allowed for Unit Price? |
| PRD 4: Invoice Creation - Drafting | Select Business Partner | Can inactive trading partners be selected as buyers? |
| PRD 4: Invoice Creation - Drafting | Save Draft | What happens if seller or buyer profile data changes after a draft is saved? |
| PRD 4: Invoice Creation - Drafting | Quantity | Are decimal quantities allowed, or integers only? |
| PRD 5: Invoice Creation - Submission and ZATCA | Submit Action | How is duplicate-click submit handled to prevent double submission? |
| PRD 5: Invoice Creation - Submission and ZATCA | Sent to ZATCA | Is there an internal SLA/escalation if status stays Sent to ZATCA for too long? |
| PRD 5: Invoice Creation - Submission and ZATCA | Reference Numbering | What is the retry/collision strategy if reference assignment fails at submit time? |
| PRD 5: Invoice Creation - Submission and ZATCA | Rejected Invoice | Is there a create-from-rejected-copy shortcut, or always manual re-entry? |
| PRD 5: Invoice Creation - Submission and ZATCA | Date Lock | Which timezone is authoritative for the locked submission date? |
| PRD 6: Invoice Import - Bulk CSV (Invoices) | File Limits | What are max file size, max rows, and max line items per invoice? |
| PRD 6: Invoice Import - Bulk CSV (Invoices) | Reference Matching | Is duplicate detection case-sensitive and whitespace-sensitive? |
| PRD 6: Invoice Import - Bulk CSV (Invoices) | Trading Partner Match | Which fields are used for matching partner records, and in what priority order? |
| PRD 6: Invoice Import - Bulk CSV (Invoices) | Partial Import | Is import transactional per row, per invoice, or per whole file? |
| PRD 6: Invoice Import - Bulk CSV (Invoices) | Error Reporting | Can users download structured error reports with reason codes? |
| PRD 7: Credit Notes Import - Bulk CSV (Credit Notes) | Dependency Order | If invoice and credit note are in same upload, which is processed first? |
| PRD 7: Credit Notes Import - Bulk CSV (Credit Notes) | Missing Original Invoice | Is there a deferred retry queue, or immediate rejection only? |
| PRD 7: Credit Notes Import - Bulk CSV (Credit Notes) | Amount Validation | How do we prevent over-credit when multiple notes target the same invoice concurrently? |
| PRD 7: Credit Notes Import - Bulk CSV (Credit Notes) | Recalculation | What rounding rule is used when recalculating outstanding balances? |
| PRD 7: Credit Notes Import - Bulk CSV (Credit Notes) | Duplicate Reference | Is uniqueness enforced across all channels or only CSV-imported notes? |
| PRD 8: Invoice Import - API (Invoices) | Idempotency | What idempotency key/strategy is required for safe client retries? |
| PRD 8: Invoice Import - API (Invoices) | Access Approval | Who approves test-to-live access and what is the target SLA? |
| PRD 8: Invoice Import - API (Invoices) | API Contract | Is there a versioned schema and error-code catalog available? |
| PRD 8: Invoice Import - API (Invoices) | Throughput | What are API rate limits and payload size limits? |
| PRD 8: Invoice Import - API (Invoices) | Failure Responses | Are errors machine-readable and stable for integration partners? |
| PRD 9: Credit Notes Import - API (Credit Notes) | Out-of-Order Arrival | What happens if a credit note arrives before its original invoice via API? |
| PRD 9: Credit Notes Import - API (Credit Notes) | Retry Behavior | Should clients retry on dependency failures, and after how long? |
| PRD 9: Credit Notes Import - API (Credit Notes) | Link Integrity | How is duplicate linking prevented when same credit note is retried? |
| PRD 9: Credit Notes Import - API (Credit Notes) | Balance Recalculation | What is recalculation order if multiple credit notes clear close together? |
| PRD 9: Credit Notes Import - API (Credit Notes) | Error Semantics | Are rejection reasons standardized across API and CSV channels? |
| PRD 10: Invoice List View | Search | Is search exact, partial, case-insensitive, and does it support Arabic normalization? |
| PRD 10: Invoice List View | Filters | Is one-filter-only intentional, or should combined filters be supported? |
| PRD 10: Invoice List View | Overdue Highlight | Which timezone and cutoff time determine overdue status? |
| PRD 10: Invoice List View | Pagination | What is default page size and max page size? |
| PRD 10: Invoice List View | Empty States | What are the exact approved messages for each empty-state scenario? |
| PRD 11: Invoice Detail View and Status Lifecycle | Payment Status | If manual and derived payment statuses conflict, which one wins? |
| PRD 11: Invoice Detail View and Status Lifecycle | History Timeline | Is status history immutable, and can admins correct wrong events? |
| PRD 11: Invoice Detail View and Status Lifecycle | Action Matrix | Is there one canonical action matrix used by both UI and API? |
| PRD 11: Invoice Detail View and Status Lifecycle | Linked Records | What is shown if related credit note link is broken or unavailable? |
| PRD 11: Invoice Detail View and Status Lifecycle | Deletion Rules | Are there any emergency deletion exceptions for compliance incidents? |
| PRD 12: Credit Note Creation | Credit Note Reason | What are the exact five allowed ZATCA reason values? |
| PRD 12: Credit Note Creation | Quantity and Amount | Are partial quantities decimal-allowed, and what precision is enforced? |
| PRD 12: Credit Note Creation | Late Issuance Warning | What is the exact warning copy and locale behavior? |
| PRD 12: Credit Note Creation | Amount Cap | Is cumulative cap checked against original invoice live balance or original total only? |
| PRD 12: Credit Note Creation | Numbering | What is the exact format for credit-note prefix and sequence continuity? |
| PRD 13: Credit Note Submission and Lifecycle | Submit Safety | How is duplicate submit prevented for credit notes? |
| PRD 13: Credit Note Submission and Lifecycle | Pending State | What operational action happens if Sent to ZATCA remains unresolved? |
| PRD 13: Credit Note Submission and Lifecycle | Rejected Flow | Is there a guided start-new-credit-note path from rejected state? |
| PRD 13: Credit Note Submission and Lifecycle | Recalculation | What triggers recalculation first: balance, payment status, or both atomically? |
| PRD 13: Credit Note Submission and Lifecycle | Auditability | What audit events are required for submission and lifecycle transitions? |
| PRD 14: Credit Note List View | Search Scope | Does search tokenize invoice reference and buyer name similarly to invoice list? |
| PRD 14: Credit Note List View | Filter Behavior | Are multi-select or combined filters intentionally out of scope? |
| PRD 14: Credit Note List View | Sorting | What is tie-breaker when two notes share same date/time? |
| PRD 14: Credit Note List View | Empty States | What exact copy should appear for no data vs no filter/search results? |
| PRD 14: Credit Note List View | Navigation | If invoice link target is inaccessible, what fallback behavior is expected? |
| PRD 15: Credit Note Detail View and Status Lifecycle | Original Invoice Link | What should user see if original invoice is archived or unavailable? |
| PRD 15: Credit Note Detail View and Status Lifecycle | Action Governance | How do we guarantee list-level and detail-level action parity? |
| PRD 15: Credit Note Detail View and Status Lifecycle | History Source | Are history events sourced from one service or multiple services? |
| PRD 15: Credit Note Detail View and Status Lifecycle | Download Output | What file format, signature, and compliance metadata are required? |
| PRD 15: Credit Note Detail View and Status Lifecycle | Retention | How is never-deleted retention implemented operationally (archive tier, retrieval SLA)? |
| PRD 16: Invoice Sharing | Delivery Lifecycle | What are statuses for inside-Qawafel send (queued, sent, delivered, read, failed)? |
| PRD 16: Invoice Sharing | Eligibility | Where are Cleared-only and Qawafel-generated-only checks enforced (UI, API, or both)? |
| PRD 16: Invoice Sharing | Irreversibility | Is there any correction flow if sent to wrong buyer by mistake? |
| PRD 16: Invoice Sharing | Auto-Send Scope | Is auto-send configured per business, per user, or per buyer relationship? |
| PRD 16: Invoice Sharing | Notifications | What channels, retries, and failure messages are required for buyer notifications? |

## Audit of Question Coverage

### Coverage Status
| Area | Status | Notes |
|---|---|---|
| Functional flow | Partially covered | Core lifecycle questions are present across drafting, submission, imports, list/detail, credit notes, and sharing. |
| Edge cases | Partially covered | Good coverage for duplicates/retries/order, but concurrency and reconciliation remain under-specified. |
| Non-functional | Not covered | No explicit SLO, throughput, availability, or recovery targets. |
| UX/content | Partially covered | Some copy and empty-state questions exist; full error catalog and irreversible-action safeguards are missing. |
| Performance | Not covered | No measurable targets for import throughput, list/search latency, or recalculation timing. |
| Security/privacy | Partially covered | Governance intent appears, but no explicit RBAC matrix, tamper controls, or audit-event minimum set. |
| Accessibility/localization | Not covered | No explicit WCAG, keyboard, screen-reader, or RTL/date-number formatting criteria. |
| Compliance/auditability | Partially covered | Retention and immutability are raised, but operational evidence and legal-hold controls are not defined. |

### Gaps by Area
| Area | Gap |
|---|---|
| Functional | Missing explicit state-machine acceptance criteria for all transition and failure paths. |
| Non-functional | Missing SLO/SLA for ZATCA pending states, import completion times, and list/detail responsiveness. |
| UX | Missing mandated confirmation/warning patterns for irreversible or destructive actions. |
| Performance | Missing hard limits and burst-capacity assumptions for CSV/API imports and parallel recalculations. |
| Security | Missing complete role-action matrix, minimum audit-event set, and document integrity/tamper rules. |
| Accessibility | Missing keyboard flow, focus order, contrast, labels, and bidi/RTL acceptance criteria. |

### Recommended Clarifying Questions (Prioritized)
| Priority | Area | Clarifying question | Intent |
|---|---|---|---|
| P0 | Security/Functional | What is the authoritative role-action matrix per status and channel for invoices and credit notes? | Prevent unauthorized actions and UI/API drift. |
| P0 | Data Integrity | What idempotency contract applies to submit/import operations and retries? | Eliminate duplicate legal records. |
| P0 | Financial Correctness | What rounding/precision order applies at line, VAT bucket, subtotal, total, and credit recalculation? | Ensure consistent monetary outcomes across UI/API/documents. |
| P0 | Lifecycle Reliability | What is the reconciliation model when Sent to ZATCA remains unresolved? | Define deterministic pending-state operations. |
| P0 | Concurrency | How is cumulative credit cap enforced under concurrent credit notes/payments? | Prevent over-credit and negative outstanding balance. |
| P0 | Reference Governance | How are reference numbers normalized across manual, CSV, and API channels? | Prevent hidden duplicate collisions. |
| P0 | Compliance/Audit | What minimum immutable audit events are required for legal traceability? | Make immutability and retention testable. |
| P0 | Sharing Safety | What remediation path exists for wrong-recipient invoice sharing, without violating irreversibility? | Reduce irreversible-send business risk. |
| P1 | Performance | What are P95 targets for list/search latency and import/recalculation completion? | Create measurable NFR pass/fail criteria. |
| P1 | UX/content | What is the approved versioned error/warning/empty-state message catalog? | Stabilize behavior and regression testing. |
| P1 | Accessibility | What WCAG and localization requirements are mandatory for invoice and credit-note flows? | Ensure inclusive and locale-correct implementation. |
| P1 | Notifications | What delivery guarantees and retry policies apply to sharing notifications? | Prevent silent delivery failures. |
| P1 | Retention Ops | How is never-deleted retention implemented (archive tier, retrieval SLA, legal hold)? | Operationalize compliance requirements. |
| P2 | Operability | What dashboards/alerts/runbooks are required for import and pending-state incidents? | Improve incident detection and triage speed. |
| P2 | Compatibility | How are API versioning and deprecation managed for import clients? | Avoid integration breakage over time. |

### Concrete Acceptance Criteria to Add
| Area | Acceptance criterion |
|---|---|
| Idempotency | Replaying the same submit/import request with same idempotency key returns same outcome and does not create duplicate records. |
| Authorization | For every status, UI and API enforce identical allowed actions; unauthorized attempts are rejected and audited. |
| Monetary Precision | Calculation order and precision are defined and deterministic; totals match across UI, API, and exported documents. |
| Pending Reconciliation | Retry cadence, reconciliation trigger, and escalation thresholds are documented with ownership and measurable SLA. |
| Concurrency | Parallel credit-note/payment operations cannot produce negative outstanding balances or credit totals above original invoice total. |
| Accessibility | All primary flows are keyboard-complete, screen-reader labeled, and pass defined color-contrast and RTL rendering checks. |

### Ambiguous or Conflicting Questions to Refine
| Existing question | Ambiguity | Clarifying question |
|---|---|---|
| Is one-filter-only intentional, or should combined filters be supported? | Could challenge an intentional PRD rule. | Confirm one-filter-only as a release constraint and document explicit non-goal rationale. |
| Is there a create-from-rejected-copy shortcut, or always manual re-entry? | May conflict with no-resubmit rule. | Can clone-as-new-draft be allowed while preserving new identifiers and no-resubmit semantics? |
| Are there emergency deletion exceptions for compliance incidents? | Can conflict with never-deleted requirement. | Is physical deletion prohibited in all cases; if exceptions exist, what legal authority and controls apply? |
| Is there a deferred retry queue, or immediate rejection only? | Behavior may differ by channel and dependency state. | For dependency-not-found imports, define strict reject vs queued retry behavior per channel. |
| Is there correction flow if sent to wrong buyer by mistake? | May conflict with irreversible send statement. | What non-reversal remediation is allowed post-send and what evidence trail is required? |
| If manual and derived payment statuses conflict, which one wins? | Model currently under-specified. | Define precedence, trigger order, and lock behavior between manual edits and derived updates. |

### Suggested Next Steps
| Step | Action | Owner |
|---|---|---|
| 1 | Convert P0 clarifying questions into explicit acceptance criteria per PRD section. | PM + Engineering |
| 2 | Publish one canonical invoice/credit-note status-action matrix for UI, API, and QA. | Product + Architecture |
| 3 | Add NFR appendix covering SLO, limits, idempotency, reconciliation, and observability. | Engineering |
| 4 | Add accessibility/localization appendix with testable pass criteria. | Design + QA |
| 5 | Run PRD-prototype reconciliation for unresolved ambiguities and freeze a versioned baseline. | PM + Design + QA |
