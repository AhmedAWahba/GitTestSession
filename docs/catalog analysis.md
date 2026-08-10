# Catalog Analysis

## Sources Reviewed
- d:/Master APEX PRD Set.md

## Section Template
| Field | Description |
|---|---|
| Objective | Business outcome expected from the PRD |
| Scope | What is included and excluded |
| Success Criteria | Observable outcomes or functional requirements |
| Key Features | Core capabilities in the PRD |
| Stakeholders | Primary owners and impacted users |
| Risks | Delivery, compliance, data, UX, or operational risks |

## PRD 1: Catalog Management - Item Setup
| Field | Details |
|---|---|
| Objective | Enable businesses to create and maintain high-quality catalog items used for manual invoice creation. |
| Scope | In scope: item creation/editing, field validation, unit list selection, VAT treatment defaults, create-from-invoice quick flow. Out of scope: item lifecycle filtering and bulk import operations (covered by PRD 2 and PRD 3). |
| Success Criteria | Required fields and limits are enforced; item names remain unique per business; invoice lines already created remain unchanged after item edits; quick-create from invoice preserves draft context. |
| Key Features | Name uniqueness and length controls, optional description/unit, positive SAR default price, VAT as Standard/Exempt, Active-by-default behavior, invoice-context item creation. |
| Stakeholders | Business users (seller operations), product management, engineering, QA, compliance. |
| Risks | Unclear uniqueness normalization details, unspecified decimal precision for price, no explicit permission matrix for who can create/edit items. |

### Prototype
- Link: [MISSING: catalog-specific prototype link for PRD 1]
- Assessment: No explicit catalog item setup prototype was found in the repository references.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| Name uniqueness normalization | Unique within business catalog | Collaboration note suggests case-insensitive + trim, but FR does not codify implementation rule | Requirement gap | Add canonical normalization rule (trim + case-insensitive comparison) to acceptance criteria and API validation. |
| Price precision | Positive SAR amount required | No explicit precision/scale or rounding behavior defined | Data gap | Define precision (for example, max decimals), min positive value, and rounding policy. |
| Permissions | Authorised business user can create/edit items | No role-action matrix in this PRD | Security/functional gap | Add explicit role permissions and denial behavior for unauthorized users. |

## PRD 2: Catalog Management - List View and Lifecycle
| Field | Details |
|---|---|
| Objective | Enable day-to-day catalog operations using an Active/Inactive lifecycle while preserving invoice history. |
| Scope | In scope: list columns, default Active view, name-only search, A-to-Z sorting, status filters, empty/no-result states, deactivate/reactivate actions, no delete. |
| Success Criteria | Active items appear by default; search/filter/sort work as defined; deactivation removes item from invoice picker for new lines only; existing invoice lines are unchanged. |
| Key Features | Active/Inactive lifecycle, no permanent deletion, status-based actions, contextual empty states, invoice picker dependency behavior. |
| Stakeholders | Business users, product/design, engineering, QA, support/compliance. |
| Risks | Search behavior detail is shallow (matching rules not explicit), missing audit requirements for lifecycle transitions, no performance target for large catalogs. |

### Prototype
- Link: [MISSING: catalog-specific prototype link for PRD 2]
- Assessment: No explicit list/lifecycle prototype path was linked in current repository artifacts.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| Search matching semantics | Search works by item name only | No exact definition for case handling, Arabic normalization, token behavior | Requirement gap | Specify exact matching semantics and multilingual normalization rules. |
| Lifecycle transition auditing | Deactivate/reactivate controls available | No explicit audit-event requirements | Compliance gap | Require lifecycle audit events with actor, timestamp, old/new status. |
| No-delete enforcement | Delete not available anywhere | No API-level statement in list PRD | Integrity gap | Add API prohibition and test criteria to ensure no hidden delete path. |

## PRD 3: Catalog Management - Bulk Import
| Field | Details |
|---|---|
| Objective | Allow fast catalog population through file upload with row-level validation and partial success behavior. |
| Scope | In scope: template download, upload + preview, row validations, partial import confirmation, result summary and re-upload loop. Out of scope: system-to-system API import for catalog items. |
| Success Criteria | Valid rows import even when other rows fail; invalid rows show row number and exact reason; imported items conform to the same rules as manual creation. |
| Key Features | Required template schema, row independence, uniqueness checks against file and existing catalog, status defaults, result summary, duplicate prevention on repeated confirm. |
| Stakeholders | Business operations teams, product, data/import engineering, QA, support. |
| Risks | Missing hard limits (file size/row count), potential race conditions between preview and confirm, undefined idempotency contract, limited non-functional targets. |

### Prototype
- Link: [MISSING: catalog bulk-import prototype link]
- Supporting artifact: [Bulk Import Template File](https://docs.google.com/spreadsheets/d/1ltKt_eaeb0LH2UIxW1E_5MjHUL-UUx-CojMrrvU8TkI/edit?gid=1781163180#gid=1781163180)
- Assessment: Template exists, but no interactive prototype path for upload/preview/result behavior was identified in repository references.

### Differences and Gaps
| Item | PRD Expectation | Prototype/Design Evidence | Gap Type | Recommended Action |
|---|---|---|---|---|
| Import limits | Multi-row file import and preview | No max file size, max rows, or timeouts defined | Performance gap | Add limits and measurable processing targets. |
| Preview-to-confirm race handling | Rows validated in preview; duplicates can fail at confirm | Behavior implied in stories but not fully formalized | Functional gap | Define final confirm re-validation semantics and user messaging for race conflicts. |
| Idempotency and repeat confirm | Repeated confirmation does not create duplicates | No technical contract defined | Technical gap | Specify idempotency key strategy and duplicate-safe processing guarantees. |

## Combined Analysis

### Common Gaps Across Catalog PRDs
| Gap Theme | Where It Appears | Impact | Priority |
|---|---|---|---|
| Prototype traceability gaps | PRD 1, PRD 2, PRD 3 | Slow validation and risk of interpretation drift | High |
| Unspecified normalization/precision | PRD 1, PRD 3 | Duplicate or inconsistent data quality | High |
| Missing non-functional targets | PRD 2, PRD 3 | Unknown performance and scalability behavior | High |
| Incomplete authorization/audit details | PRD 1, PRD 2, PRD 3 | Compliance and accountability risk | High |
| Race and idempotency handling under-specified | PRD 3 | Duplicate creation and user confusion | High |

### Open Questions Raised During Analysis
| # | Question | Affected PRDs | Owner Suggestion |
|---|---|---|---|
| 1 | Is catalog item name uniqueness case-insensitive and trimmed by default across UI and API? | 1, 3 | PM + Engineering |
| 2 | What decimal precision and rounding rules apply to default price? | 1, 3 | PM + Engineering |
| 3 | What are file-size, row-count, and processing-time limits for bulk import? | 3 | Engineering |
| 4 | What is the exact search behavior for name filtering (case, partial, Arabic normalization)? | 2 | Product + Engineering |
| 5 | What audit logs are mandatory for create/edit/deactivate/reactivate/import events? | 1, 2, 3 | Compliance + Engineering |
| 6 | Which roles can create/edit/deactivate/reactivate/import catalog items? | 1, 2, 3 | Product + Security |
| 7 | What conflict message appears when a row is valid in preview but fails at confirm due to a late duplicate? | 3 | Product + UX |

### PRD vs Prototype Differences (Consolidated)
| PRD | Prototype Availability | Key Differences | Decision Needed |
|---|---|---|---|
| PRD 1 | Missing | No prototype evidence for item form validation and quick-create from invoice behavior | Provide testable prototype/screens for CAT-1 flows |
| PRD 2 | Missing | No prototype evidence for lifecycle controls, empty states, and picker impact | Provide list/lifecycle prototype evidence |
| PRD 3 | Template available, prototype missing | File schema is visible, but upload/preview/result UX behavior not demonstrated | Provide bulk import interaction prototype or executable UX spec |

### Differences and Gaps (Concrete Mismatches and Missing Requirements)
| Area | Mismatch or Missing Requirement | Risk | Recommended Action |
|---|---|---|---|
| Name uniqueness | FR requires unique names but does not formalize normalization | Duplicate-like items and inconsistent validation outcomes | Add canonical comparison rule and examples to FR-1.2 and FR-3.3. |
| Price handling | Positive price required, but precision/rounding undefined | Calculation inconsistencies and import mismatches | Define numeric constraints and rounding policy for all channels. |
| Lifecycle auditing | Deactivate/reactivate behavior defined without event-audit minimums | Weak traceability and dispute handling | Add mandatory audit event fields and retention policy. |
| Bulk import NFR | Partial import behavior defined without throughput/limits | Scale failures and unclear user expectations | Add explicit limits, timing targets, and error behavior under load. |
| Permissions | Authorised user concept used but no role matrix provided | Unauthorized operations risk | Add role-action matrix and denial responses. |

### Overall Implications and Next Steps
| Decision Area | Implication | Recommended Next Step |
|---|---|---|
| Specification quality | Functional coverage is solid but operational details are incomplete | Add a technical constraints appendix for validation, precision, and limits |
| Prototype readiness | Missing catalog prototypes reduce confidence before implementation | Produce prototype evidence for CAT-1/2/3 core journeys |
| Compliance and security | Lack of explicit RBAC and audit criteria creates control gaps | Publish role matrix and audit logging requirements |
| Import reliability | Bulk import needs idempotency and race-control hardening | Define confirm-time re-validation and duplicate-safe processing contract |

## Missing PRD or Prototype Remediation Plan
- Create a catalog PRD index with owner, latest version, prototype link, and status.
- Require each catalog PRD to include a validation matrix with explicit normalization and numeric precision rules.
- Add a shared role-action matrix and audit-event checklist across CAT-1, CAT-2, and CAT-3.
- Add non-functional criteria for list/search latency and bulk import throughput.

## Question Analysis by PRD (Single Table)
| PRD Title | Section | Question |
|---|---|---|
| PRD 1: Catalog Management - Item Setup | Name Uniqueness | Is uniqueness enforced after trimming leading/trailing spaces and normalizing case? |
| PRD 1: Catalog Management - Item Setup | Name Length | Is the 100-character limit measured by characters, Unicode code points, or bytes? |
| PRD 1: Catalog Management - Item Setup | Default Price | What decimal precision, minimum positive value, and rounding rules apply to price? |
| PRD 1: Catalog Management - Item Setup | Unit of Measure | Are unit values localized labels or canonical enums at API level? |
| PRD 1: Catalog Management - Item Setup | Quick Create in Invoice | If quick-create fails, is invoice draft context fully preserved including unsaved line edits? |
| PRD 1: Catalog Management - Item Setup | Edit Impact | If a catalog item is edited while another user is drafting, what snapshot value is applied when selected? |
| PRD 2: Catalog Management - List View and Lifecycle | Default List | Is default sort case-insensitive alphabetical and locale-aware for Arabic/English names? |
| PRD 2: Catalog Management - List View and Lifecycle | Search | Does search support partial token match, prefix match, and Arabic normalization? |
| PRD 2: Catalog Management - List View and Lifecycle | Filter Behavior | Is filter state sticky across navigation and sessions? |
| PRD 2: Catalog Management - List View and Lifecycle | Deactivate Action | Is confirmation required before deactivation, and what exact warning copy is shown? |
| PRD 2: Catalog Management - List View and Lifecycle | Reactivate Action | Are there any constraints preventing reactivation of historical items? |
| PRD 2: Catalog Management - List View and Lifecycle | No Delete | Is permanent delete blocked at API level as well as UI level? |
| PRD 2: Catalog Management - List View and Lifecycle | Invoice Dependency | How quickly does deactivation propagate to invoice item pickers across open sessions? |
| PRD 3: Catalog Management - Bulk Import | File Constraints | What are maximum file size, row count, and row processing limits? |
| PRD 3: Catalog Management - Bulk Import | Supported Formats | Which file formats and encodings are accepted (xlsx, csv, UTF-8)? |
| PRD 3: Catalog Management - Bulk Import | Validation Timing | Are all validation rules re-run at confirm time to catch races with new duplicates? |
| PRD 3: Catalog Management - Bulk Import | Idempotency | How is repeated confirm prevented from creating duplicates under retries? |
| PRD 3: Catalog Management - Bulk Import | Status Handling | If Status is invalid, is row rejected or coerced; what exact error is returned? |
| PRD 3: Catalog Management - Bulk Import | Error Report | Can failure rows be exported with row number, field, and reason code? |
| PRD 3: Catalog Management - Bulk Import | Concurrency | What happens if two imports for same business run concurrently with overlapping names? |

## Audit of Question Coverage

### Coverage Status
| Area | Status | Notes |
|---|---|---|
| Functional flow | Covered | Core create/edit/list/lifecycle/import flows are represented. |
| Edge cases | Partially covered | Concurrency and preview-confirm race scenarios need more explicit acceptance criteria. |
| Non-functional | Not covered | No explicit performance/SLA targets in current catalog PRDs. |
| UX/content | Partially covered | Empty states and high-level behaviors exist; exact copy catalog is not defined. |
| Performance | Not covered | No measurable limits for list/search or bulk import processing. |
| Security/privacy | Partially covered | Authorized user concept exists, but no full role matrix or denial behavior. |
| Accessibility/localization | Not covered | No explicit keyboard/screen-reader/RTL criteria. |
| Compliance/auditability | Partially covered | No-delete and history intent exist; audit event requirements are not explicit. |

### Gaps by Area
| Area | Gap |
|---|---|
| Functional | Missing explicit conflict handling for concurrent updates/imports. |
| Non-functional | Missing hard limits and throughput expectations. |
| UX | Missing standardized validation/error message catalog. |
| Performance | Missing latency and completion targets. |
| Security | Missing role-action matrix and API-level authorization criteria. |
| Accessibility | Missing WCAG-oriented acceptance criteria. |

### Recommended Clarifying Questions (Prioritized)
| Priority | Area | Clarifying question | Intent |
|---|---|---|---|
| P0 | Data Integrity | What canonical normalization is used for Name uniqueness across create/edit/import? | Prevent duplicate-like records and inconsistent validations. |
| P0 | Technical Reliability | What idempotency model is enforced for bulk import confirm operations? | Ensure retry safety and no duplicate creation. |
| P0 | Security | Which roles can create, edit, deactivate, reactivate, and bulk import catalog items? | Prevent unauthorized catalog mutations. |
| P0 | Performance | What are file and processing limits for catalog import, and what happens when exceeded? | Protect system stability and user expectations. |
| P0 | Lifecycle Dependency | What is propagation SLA from item deactivation to invoice picker exclusion? | Avoid stale selectable items during invoice drafting. |
| P1 | UX/content | What are the exact validation messages for each FR-1.x and FR-3.x failure path? | Stabilize QA checks and user feedback consistency. |
| P1 | Search Behavior | How should name search behave for Arabic/English case and normalization? | Ensure predictable discovery in multilingual catalogs. |
| P1 | Compliance/Audit | What audit events are mandatory for item state and import changes? | Strengthen traceability for investigations. |
| P2 | Accessibility | What keyboard and screen-reader requirements apply to item forms and import result grids? | Ensure inclusive operation for business users. |

### Concrete Acceptance Criteria to Add
| Area | Acceptance criterion |
|---|---|
| Name Uniqueness | Name comparison for uniqueness is case-insensitive and whitespace-trimmed across UI and API validations. |
| Price Validation | Default price supports defined precision and rejects values outside numeric and positivity constraints with a specific message. |
| Import Idempotency | Re-submitting same confirmed import payload does not create duplicate items and returns deterministic result. |
| Conflict Revalidation | Confirm step revalidates all rows and reports newly conflicting rows without blocking non-conflicting rows. |
| Authorization | Unauthorized create/edit/lifecycle/import attempts are rejected consistently in UI and API and are audit logged. |
| Deactivation Propagation | Deactivated items become non-selectable in invoice pickers within defined SLA and never alter existing invoice lines. |

### Ambiguous or Conflicting Questions to Refine
| Existing question | Ambiguity | Clarifying question |
|---|---|---|
| Is uniqueness case-sensitive and whitespace-sensitive? | Raw wording can be interpreted differently across channels. | Confirm canonical uniqueness as case-insensitive with trimmed whitespace and define locale handling. |
| Search works by name only | Does not define match algorithm detail. | Is match substring/prefix/tokenized, and how is Arabic normalization handled? |
| Status defaults to Active when blank | Invalid status behavior only appears in stories, not FR table wording. | Should invalid status values always reject row with a specific error code and message? |
| Repeated confirmation does not create duplicates | Technical mechanism is not stated. | Is idempotency key required, or is duplicate prevention solely name-based at commit time? |

### Suggested Next Steps
| Step | Action | Owner |
|---|---|---|
| 1 | Add a validation and normalization appendix for CAT-1 and CAT-3. | PM + Engineering |
| 2 | Publish catalog role-action matrix and API authorization criteria. | Product + Security |
| 3 | Add catalog import NFRs (limits, throughput, timeout, retry behavior). | Engineering |
| 4 | Define versioned error/copy catalog for create/edit/import flows. | Product + UX + QA |
| 5 | Produce prototype evidence or executable specs for CAT-1/2/3 critical flows. | Design + QA |
