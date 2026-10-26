# Invoice Creation Gherkin Review and Engineering Replacement Coverage

Reviewed 2026-10-25 against [rubric](../../gherkin/rubric.md), [style guide](../../gherkin/style-guide.md) and [Billing PRD (Engineering)](../Master%20APEX%20PRD%20Set.md#L4928).

Source reviewed read-only: `D:/Apex/Apex Project/quality-hub/scenarios/app/tests/invoice-create-test.feature`. It was not modified. It contains nine scenario definitions, one of which is a four-example outline. The report below assesses each definition separately; all four invalid-amount examples share its findings.

## Findings First

- High: the source implements a different product contract: in-app creation, generated numbering, Sent/Draft statuses and payment-link eligibility. Engineering instead imports externally issued XML, preserves numbering, uses Processing/Action required/Accepted/Rejected/Duplicate and excludes authoring/ZATCA submission/collection from this release. Do not mechanically rename Create to Import or Sent to Accepted.
- High: the shared Background depends on an unspecified selling user, profile state and at least one buyer rather than a named role, verified parties and directional partner relationship. No isolated environment, language or test-data lifecycle is defined.
- Medium: exact validation messages, generated number format and Sent/payment-link rules are not justified by this Engineering baseline. The amount outline's zero-total rejection must not be transplanted into import: some zero line values and supported negative payable amounts are permitted.
- Medium: created invoice cleanup is absent. Accepted Engineering records cannot be deleted through the Business UI; use isolated scenario fixtures and approved environment teardown instead.

## Individual Rubric Review

Dimension order: Preconditions / Actions / Assertions / Behavior focus / Execution completeness / Data richness / Independence / Naming. S = Strong, N = Needs work, W = Weak. Readiness is for the requested Engineering release, not a claim about historical MVP requirements. A requirement mismatch fails the clear-start or clear-outcome gate even if the prose is otherwise readable.

| Scenario | Gates / readiness | Dimensions | Anti-patterns and highest-value correction |
|---|---|---|---|
| Seller information is pre-populated and read-only | Not ready: starts on an out-of-scope authoring screen | W/S/N/S/W/S/N/S | Hidden assumption that current profile is the source; imported accepted details preserve source-stated values. Replace with a source-snapshot detail scenario after profile change. |
| Buyer details are pre-filled after selection | Not ready: no import buyer picker is specified | W/S/N/S/W/N/N/S | Missing named buyer setup; hidden assumption that stored contact details populate invoice facts. Test identifier resolution and preserved source parties instead. |
| Successfully create an invoice with valid data | Not ready: actions/outcomes contradict release | W/S/W/N/W/N/W/S | Multiple behaviors mixed; invented Sent/number-format expectations; missing cleanup. Replace with import plus automatic acceptance and preserved reference. |
| Buyer dropdown lists all buyers and supports search | Not ready: out-of-scope control | W/S/N/S/W/W/N/S | Missing relationship state and exact candidate data. Test current-Business document filtering or partner validation, not a nonexistent import buyer picker. |
| Create invoice without selecting a buyer | Not ready: out-of-scope action and unsupported error contract | W/S/N/S/W/N/N/S | Unclear sourced validation expectation; inconsistent user/I voice. Test missing buyer identification in XML and whole-document rejection. |
| Create invoice with invalid total amount (four examples) | Not ready: form-entry model is not XML validation | W/S/N/S/W/S/W/S | Good outline shape, but messages and zero/negative rules are unsupported here. Use field-specific invalid XML and reconciled amount fixtures; avoid blanket positive-payable assumptions. |
| Invoice does not include ZATCA fields | Not ready: expected detail behavior conflicts with clearance disclosure | W/S/W/N/W/N/W/N | Negative assertion hides required disclosure. Test prior-clearance declaration and the statement that independent verification was not performed. |
| Generate Payment Link button is visible on unpaid Sent invoices | Not ready: collection eligibility and Sent status outside Billing scope | W/S/N/S/W/N/N/S | Missing payment-state fixture; hidden eligibility assumption. Defer to collection requirements; do not encode Billing acceptance as payment eligibility. |
| Generate Payment Link button is hidden for non-Sent invoices | Not ready: Draft status/collection rule outside release | W/S/N/S/W/N/N/S | Hidden status model and incomplete setup. Keep collection action-matrix testing separate from import acceptance. |

Feature coherence: the source is coherent as a small historical seller-authoring/payment-link pack, but not as acceptance coverage for this Engineering release. No claim is made that the old feature is wrong for its original MVP. Strength: descriptive scenario names, readable actions and an appropriate invalid-data outline. Highest-value improvement: change the requirement baseline before changing steps. Next step: implement isolated XML fixtures and step definitions for the replacement suites and review them with Product/Engineering.

Common-scenario candidacy: sign-in and selecting a Business could be reusable setup helpers. Do not add separate domain login scenarios or require execution of another feature to establish Billing state; use independent fixture/setup steps. No new common feature is necessary for this change.

## New Suites and Traceability

| Suite | Coverage |
|---|---|
| [invoice-import.feature](../../scenarios/billing/invoice-import.feature) | 15 definitions / 31 cases: submission/declaration/limits, file-source outcomes, mixed results, leave/return, independent seller/buyer import, partner repair/Resume, interrupted transfers, technical recovery and corrected attempts. |
| [invoice-validation-duplicates.feature](../../scenarios/billing/invoice-validation-duplicates.feature) | 12 definitions / 44 cases: supported source scope, required facts, VAT, rounding, party identification, compatible/conflicting repeats, reference normalization, concurrent acceptance and inactive-partner duplicate exception. |
| [invoice-records-access.feature](../../scenarios/billing/invoice-records-access.feature) | 11 definitions / 24 cases: role restrictions/demotion, Business isolation, combined filters, list-state restoration, empty/no-match states, accepted source snapshots, original-file downloads and capture reports. |
| [credit-note-import.feature](../../scenarios/billing/credit-note-import.feature) | 11 definitions / 30 cases: sales/purchase acceptance, multi-invoice links, unchanged invoice amounts, reasons/references/dates, optional/source facts, zero-valued lines, repeat-file/link stability and debit-note parity. |
| [credit-note-recovery.feature](../../scenarios/billing/credit-note-recovery.feature) | 12 definitions / 21 cases: missing-reference explanation, no automatic resume, explicit Resume, contradiction precedence, system delay, partner/duplicate rechecks, repeated/stale actions, summary reopening, Member guidance and cross-Business reference isolation. |

Scenario tags are requirement provenance, not automation bindings. Shared import scenarios use the document-level language intentionally; credit-note scenarios add the note-specific reference/recovery behavior without duplicating every shared rule. The debit-note outline protects the Engineering inclusion of type 383 even though the inspected prototype rejects it.

## Fixture and Execution Contract

- These are acceptance specifications, not an installed automation suite. This workspace currently has no Cucumber runner, Billing step definitions or fixture builder wired to them. Parser validation does not establish runtime passing behavior.
- Every scenario gets independent Businesses, users, document identities and files; readable aliases such as INV-001 are local to that scenario, not globally reusable production references. Background setup is performed for every scenario/example and does not depend on a preceding test.
- A valid fixture includes all required XML and issuing-system information, correct parties/dates, reconciled amounts and supported tax treatment. Negative fixtures vary only the defect stated, keeping every other fact valid. Pre-existing accepted/actionable/duplicate records are independently seeded, not results from earlier scenarios.
- Control processing dates and infrastructure/reference waits through a non-production test clock/fault harness. Do not use hardcoded sleeps or depend on the wall-clock date. Concurrency and direct-request cases require service-capable adapters as well as UI observations.
- Retire isolated scenario data through approved environment teardown. Never add Business-facing accepted-document delete behavior to satisfy test cleanup.
- Limits/support scenarios require approved environment policies and a safe test support destination. When those prerequisites are missing, mark the execution blocked, not passed; do not silently adopt prototype values.
- Plain-language error assertions identify the offending field/fact without inventing exact copy where Engineering has not specified it. Match exact messages only where supplied by Engineering.

## Deliberate Exclusions and Remaining Coverage

Do not assert an invented credit cap, earliest absolute date, due-date ordering, full numeric scale/range, Catalog side effect, recovery deadline or SLA. Resolve those decisions in the [analysis backlog](invoices-credit-notes-engineering-qa-analysis.md#4-prioritized-questions-after-reconciliation) before converting them into deterministic expected outcomes. Draft authoring, payment-link eligibility, CSV follow-up and API connection contracts are outside these initial-release suites.

Additional implementation gates remain: full XML identifier/address/export/self-billing/prepayment/payment-instruction permutations; upload-initiation/lost-response idempotency; stale signed-download renewal; paginated notification recovery; access removal; capture-investigation audit beyond the operational-recovery audit scenario; durability/process-stop testing; privacy-safe logs; measured performance; retention/legal holds; keyboard and RTL accessibility. The suites are a focused Engineering-aligned starting pack, not a claim that every PRD acceptance criterion or non-functional gate has executable coverage.

## Validation

All five feature files were checked with the official `@cucumber/gherkin` parser API using a temporary npm package, without changing the project's dependencies. The three invoice files together retain 38 scenario definitions expanding to 99 cases; the two credit-note files retain 23 definitions expanding to 51 cases, for 150 cases total. A parsed pre/post comparison confirmed every definition appears exactly once with identical Background steps, inherited tags, data tables and Examples. Only two scenario-step texts intentionally changed: multi-invoice note setup now explicitly works in the example Business as Owner, and the cross-Business missing-reference case explicitly works in Buyer B as Owner. Both reuse the existing role-context step wording. Literal outer reference spaces are tested in a quoted step rather than table-cell padding, which Gherkin trims. Structural checks found unique scenario names, explicit outcome phases, no Given after an action, no repeated action/outcome cycles and no scenario body with ten or more steps. These checks supplement, not replace, the semantic review below. No application acceptance tests were executed; step bindings, real synthetic XML fixtures and the controlled test harness remain prerequisites.

### Independent Five-File Execution Contract

- Invoice scenarios are split into three files and credit-note scenarios into two files by behavior, not by Sales/Purchase. This remains within the four-file invoice limit.
- Each file contains its complete Background. Running records/access first, import first, credit notes alone, or a single Scenario Outline example must not require any preceding scenario/file.
- Given steps that mention Accepted, Rejected, Duplicate, pending or Action required records must seed those states in that scenario's isolated environment. They must not look for records created by another feature. Local aliases such as INV-001 may repeat only because fixture namespaces are scenario-specific.
- Reuse one set of registered step definitions and lifecycle hooks across all five files; do not copy bindings or define steps that execute another scenario. The split introduced no new step wording; the two authorization corrections reuse an existing role-context pattern.
- Runner discovery must include `scenarios/billing/*.feature`, or explicitly list all five files. A runner configured only for old file paths will not discover moved scenarios. Existing `@invoice-import` selection still selects all three invoice files; `@credit-note-import` still selects both note files. Filename selection is narrower than tag selection.
- Teardown must release held processing/fault states, restore controlled clocks and retire isolated data even on failure. Parallel execution additionally requires per-scenario users/sessions or isolated memberships so role-change tests cannot affect neighboring scenarios.
- The absence of runtime bindings, fixture adapters or approved policy values remains an execution prerequisite, not something a file split can solve. Missing setup or policy must be reported as blocked/undefined, never silently skipped or counted as passing. Confirm runner discovery and binding completeness with a real Cucumber dry run once that runner exists.

The files are connected through shared Business/document vocabulary and reusable fixture/step contracts, not through execution order:

| Shared prerequisite / operation | Files using the contract | Independent setup requirement |
|---|---|---|
| Business, user and role context | All five | Create isolated memberships and authenticate the stated actor before setting the current Business. Buyer-side scenarios do not inherit seller-side permissions. |
| Valid XML and invoice import | Invoice import, validation, note import and note recovery | Use one valid-fixture factory with independently prepared validation fixtures; apply only the scenario's named mutation. |
| Accepted invoices and original files | Validation, records/access and both note files | Seed accepted facts/files within the current scenario; never require invoice-import.feature to run first. |
| Complete note-to-invoice relationship | Both note files | Seed all specified links, matching parties and dates, or intentionally missing dependencies in that scenario's Business only. |
| Action required and Resume | Invoice import, records/access and note recovery | Seed the current attempt/result version and its repairable cause. Recovery scenarios start from that fixture rather than another scenario's output. |
| Processing, interruptions and operational recovery | Invoice import and note recovery | Use a scenario-local controlled processing gate or fault state and always release it during teardown. |

Execution readiness must be checked at three levels: parse every file alone, run Cucumber binding discovery/dry-run for each file once a runner is wired, then execute each file alone and the whole folder in shuffled order using isolated data. The first level passed here; the latter two have not been executed and must not be inferred from parser validation.

## Second-Pass Rubric Assessment of the Generated Suites

Reviewed 2026-10-25. All 61 current definitions were assessed individually; each outline's examples inherit its row assessment. Repeated examples differ in relevant data or role/perspective rather than relying on earlier execution.

### Structure Decision: Keep Shared Sales/Purchase Outlines

Do not split into selling and purchasing feature files. Engineering defines one document list and the same validation, duplicate, immutable-record and recovery contracts for both perspectives. The difference is the selected Business and displayed counterparty, not a separate feature. Duplicating the suites would obscure drift between two copies of the same rule.

The acceptance and relationship-recovery outlines explicitly cover Seller A/Sales and Buyer B/Purchase, with Owner/Admin examples. The independent buyer-import and cross-Business note-reference scenarios cover behavior that cannot be represented by merely changing a Sales label. Not every shared validation scenario is repeated for both perspectives; complete Cartesian expansion is not implied. A future requirement with genuinely different seller/buyer behavior can justify its own scenario or Rule without duplicating the suite.

### Corrections Made

- Removed teardown from Background Given steps; cleanup is a scenario-lifecycle policy in feature descriptions and this fixture contract, not a pre-action business event.
- Replaced implicit ownership of both Businesses with separate role-capable test users and an explicit default selected Business.
- Split the two-Business import cycle, partner repair/Resume, list/filter navigation, empty/no-match and delay/recovery behaviors into atomic scenarios.
- Replaced a mixed-result setup that merely declared expected statuses with concrete fixture conditions.
- Split missing-invoice note handling into independently seeded missing-reference explanation, import-without-auto-resume and explicit-Resume cases.
- Made note submission explicit and supplied default note reasons/parties/dates/reference assumptions; no note result is asserted for a fixture that was never submitted.
- Split Member UI visibility from direct-request denial; the outcome is no longer the ambiguous "unavailable or denied".
- Added pending-action data for demotion tests, controlled Processing gates for transient-state assertions, and an explicit action for concurrent submissions.
- Removed an assertion about an internal reprocessing-operation count and unsupported stale-page refresh messaging. Compare attempt/record results instead.
- Made the multi-invoice purchase-note and cross-Business missing-reference actors explicit Owners instead of merely selecting a Business.

### Individual Assessment

Dimension profile **F** means: Preconditions Strong; Actions Strong; Assertions Strong; Behavior focus Strong; Execution completeness Needs work; Data richness Strong; Independence Strong; Naming Strong. Each F row is **Almost ready** for execution because XML fixtures and step bindings still need implementation, although its behavioral specification now passes the four readiness gates.

Profile **H** has the same ratings and readiness as F, but additionally needs a controlled service/clock/processing harness. Profile **P** has the same ratings and readiness as F, but additionally requires an approved limit/support policy. These dependencies must be supplied before execution; unavailable dependencies are blocked tests, not passes. Neither syntax validation nor these ratings mean the application passed.

| Invoice scenario | Profile | Individual finding / disposition |
|---|---|---|
| Accept an invoice for an authorized seller or buyer | F | Shared role/perspective outline retained; record/counterparty assertion is explicit. |
| Require the prior-clearance declaration before submission | F | Separate prerequisite failure; no checkbox mechanism or invented exact error copy. |
| Enforce the approved file-count and file-size limits | P | Boundary values resolve from approved finite policy, not the prototype's provisional numbers. |
| Reject an identifiable invoice outside the supported source rules | F | Each example identifies its specific unsupported condition and expected reason category. |
| Reject the whole invoice rather than discard invalid facts | F | One defect per fixture; no partial accepted record is the common invariant. |
| Require tax reasons appropriate to the stated treatment | F | Required reason/code omissions are parameterized by tax category. |
| Respect the source component-rounding steps | F | Uses the PRD's explicit numeric counterexample, not a guessed general precision rule. |
| Reject documents whose parties do not identify an eligible trade | F | Identifying failure and no auto-created Business are explicit. |
| Report an unreadable file as a source issue rather than an invoice rejection | F | Distinguishes file failure from identified-document failure and preserves the sibling. |
| Complete a mixed submission without undoing accepted siblings | F | Actual fixture defects/relationships now drive expected aggregate counts. |
| Keep an unfinished submission available after leaving | H | Held Processing state removes ambiguity about an independently completing job. |
| Keep accepted facts and retain a compatible repeated original file | F | Known optional due-date compatibility and both originals are asserted. |
| Reject conflicting recognized facts on a repeated identity | F | Outline isolates each conflict while preserving the first accepted facts. |
| Preserve significant differences in document numbers | F | Distinct reference cases and expected statuses are explicit. |
| Trim only outer whitespace when comparing a document number | F | Literal quoted source value preserves spaces unlike Examples cell padding. |
| Accept at most one record from concurrent compatible imports | H | Concurrent submission is an action; sessions are seeded prerequisites. |
| Validate an invalid repeat before recognizing a duplicate | F | Clear validation-before-deduplication negative case. |
| A seller import does not populate the buyer's records | F | Split from buyer-side import; only counterparty independence is tested here. |
| A seller's accepted copy does not make the buyer's independent import a duplicate | F | Buyer has independently seeded empty records and its own selected context. |
| Repairing a partner relationship does not automatically resume an invoice | F | Stops at the repair outcome; no second action cycle. |
| Explicitly resume an invoice after repairing its partner relationship | F | Independent repaired-actionable fixture; asserts the revalidated final result. |
| An inactive partner does not block a compatible repeat | F | Explicit accepted-record exception to new-document partner gating. |
| Hide import and Resume controls from a Member | F | Visibility-only rule separated from mutation denial. |
| Deny a Member's direct import or Resume action | H | Requires direct-route/request adapter; exact denial wording not invented. |
| Apply demotion to the next action from an already-open page | H | Role session and eligible pending action now belong to the acting user. |
| Disclose no private facts through another Business's address | H | Compare unknown-resource response with private-resource response, including file metadata. |
| Combine document filters within the current Business | F | Replaced unspecified chosen date range with concrete interior fixture dates. |
| Returning from detail preserves the current search and filters | F | Independent filter setup; one navigation-return behavior. |
| Explain that the current Business has no accepted documents | F | Atomic empty-list state, no mid-scenario reseeding. |
| Explain unmatched searches without claiming the Business has no documents | F | Independently populated list and nonexistent reference. |
| Preserve source-stated invoice details after a Business profile changes | F | Tests source snapshot, unknown optional values and acceptance meaning. |
| Let every Business role retrieve original files from the correct surface | F | Attempts and accepted-record links distinguished for Duplicate; download surface is explicit. |
| Recover one interrupted pending upload without restarting its siblings | P | Pending transfer eligibility and approved recovery deadline are required. |
| Never reopen a terminal transfer | F | Terminal states share one observable invariant. |
| Explain infrastructure delay without requesting business-data changes | H | Delay-only behavior split from operational recovery. |
| Recover delayed work without creating another accepted invoice | H | Independent delayed attempt, final accepted count and recovery audit are asserted. |
| Correct rejected source material through a new attempt | F | Retains prior evidence rather than implying editable rejected records. |
| Report a capture error without changing accepted facts | P | Safe test support route and externally seeded payment reference are explicit. |

| Credit-note scenario | Profile | Individual finding / disposition |
|---|---|---|
| Accept a credit note in the current Business's sales or purchase perspective | F | Both Business contexts and authorized roles; amounts preserved, not assumed strictly positive. |
| Keep the full credit-note amount under every referenced invoice | F | Both perspectives; full amount and complete links, no inferred allocation. |
| Keep an invoice amount unchanged after accepting a credit note | F | Explicit note import action; original invoice and separate note amounts are concrete. |
| Reject an invalid credit-note reference set without partial links | F | Explicit default reference set; defect changes only the named fact. |
| Compare the credit-note date with the invoice date | H | Controlled Saudi processing date makes historical/same-day/future boundaries reproducible. |
| Omit an optional credit-note supply date without inventing it | F | Optional absences are observable and remain distinct from invoice-required supply date. |
| Explain every missing invoice after a submitted note's reference wait | H | Submission and concluded reference wait now explicit; no implicit processing. |
| Importing the missing invoices does not automatically resume the note | F | Stops at the no-auto-resume outcome; separate examples for role and perspective. |
| Accept a waiting note only after an explicit Resume | F | Independent complete/repaired dependency setup; final acceptance has all links. |
| Reject a known contradiction even when another referenced invoice is missing | H | Controlled dates and one conclusive contradiction isolate precedence. |
| Do not report a missing invoice when APEX cannot check references | H | Fault harness distinguishes technical failure from missing dependency. |
| Recheck the current partner relationship when resuming a note | F | Inactive relationship seeded after invoice arrival; acceptance remains blocked. |
| Recognize a duplicate that arrived while a note was waiting | F | Another accepted attempt is setup, not an ordering dependency on another scenario. |
| Repeated Resume actions do not repeat acceptance work | H | Compare same current attempt and one complete accepted record instead of internal job counts. |
| An old page cannot resume a later actionable result | H | Asserts unchanged current result, not an unspecified refresh message. |
| Resume makes a finished submission unfinished until the new result arrives | H | Held revalidation makes immediate Processing and finished-state removal observable. |
| A Member can inspect an actionable note but cannot resume it | F | Purchase context, missing-reference explanation and role-specific guidance are explicit. |
| Another Business's invoice cannot satisfy a note reference | H | Note submission and controlled wait explicit; only current-Business records may resolve references. |
| Reject invalid credit-note source facts without dropping lines | F | One source defect per example and no partial credit note. |
| Accept a zero-valued commercial line when its remaining facts reconcile | F | Positive quantity with zero price/ordinary amounts is not confused with an invalid zero quantity. |
| A repeated credit note keeps its invoice links and adds its original file | F | Compatible repeat keeps complete existing links and both files. |
| A repeated note cannot silently redirect an accepted invoice link | F | Incoming reference is valid independently but conflicts with accepted identity facts. |
| Accept the same supported note relationship for credit and debit notes | F | Two supported types share one parity rule; no duplicated sales/purchase file needed. |

### Feature-Level Coherence and Coaching

Invoice files: submission/recovery, validation/duplicates and records/access are separate behavioral areas, each with identical independent setup. Credit-note files separate acceptance/link semantics from dependency/recovery behavior. The individual assessment tables above span the final five files; their fixture/harness/policy qualifications still apply after the move. Two Owner-context corrections resolve the earlier implicit Buyer B actor assumption. Shared import contracts are reused conceptually rather than as scenario execution dependencies.

Common-scenario candidacy: generic authenticated-session setup and environment teardown can be reusable helper/hook implementations. Do not create a separate common feature whose successful execution is required by these scenarios; keep each example independent.

Strength: the revised suites retain requirement traceability and meaningful seller/buyer coverage with atomic, observable outcomes. Highest-value improvement remaining: supply independently validated XML fixture variants and deterministic environment controls for H/P cases. Next step: bind the steps, run a fixture-backed dry run and mark blocked policy/harness cases explicitly before claiming execution readiness.

## Notification-Style Alignment Review

Reviewed the external reference `D:/Apex/Apex Project/quality-hub/scenarios/app/tests/notification-07-sms-delivery-test.feature` read-only against the local style guide and rubric. The reference uses a concise Feature narrative, shared Background, source annotation, negative-first and positive-second section comments, polarity tags, focused smoke selection and scenario-level requirement annotations. It is a style reference, not a Billing requirements source.

| Reference convention | Applied to all five Billing features |
|---|---|
| Source annotation before Background | Added Billing PRD (Engineering) source and relevant BIL/data sections; clarified that prototype differences do not redefine acceptance. |
| Negative cases first | Validation failures, authorization denials, blocked/stale actions and failure explanations precede positive scenarios. Relative order within each group is preserved. |
| Positive cases second | Acceptance, safe duplicates, record integrity and successful recovery use `@positive`, with existing domain/requirement tags retained. |
| Focused `@positive @smoke` | Five existing definitions selected: authorized invoice acceptance, compatible invoice repeat, combined document filtering, authorized credit-note acceptance and explicit waiting-note Resume. These still require their fixtures and, for Resume, recovery setup. |
| Scenario requirement annotations | Added a short comment inside each scenario identifying its existing BIL/data provenance, while keeping the original requirement tags for selection. |
| Mixed-outcome outlines | Limit boundaries, rounding acceptance/rejection, note-date acceptance/rejection and mixed-result summaries remain under `BOUNDARY AND MIXED CASES` rather than being mislabeled as entirely positive or negative. |
| Shared context and readable business actions | Preserved existing complete Backgrounds, named actors, meaningful fixture data and behavior-focused steps. Kept existing space indentation rather than reformatting it into tabs. |

Scenario names were retained because they already identify the tested behavior and are referenced in the individual rubric assessment. No change to action wording was needed to mirror the reference's organizational conventions; preserving steps also avoids gratuitous future binding churn. No notification-specific delivery codes, user IDs or security-message assumptions were copied into Billing.

The latest invoice-import and credit-note-import contents were read before editing. A new parsed baseline was captured immediately before the mechanical style rewrite. Post-edit comparison confirmed all 61 scenario definitions and 150 expanded cases remain present exactly once, with unchanged names, Backgrounds, step text, tables, Examples and original inherited/scenario tags. Only source/section/requirement comments, added classification/smoke tags and display order changed. Both role-context fixes from the earlier split remain intact.

Negative-first organization is for scanning and review, not test dependency. Any file, scenario or example must still seed its prerequisites independently and be runnable first. The parser/order checks passed, but runtime readiness still depends on the fixture/binding/harness/policy qualifications recorded above.

Strength: the suites now use the reference's recognizable annotation and ordering conventions without losing Engineering traceability. Highest-value improvement remaining: validate the new polarity and smoke selections during a fixture-backed Cucumber dry run. Next step: wire the shared step definitions and execute each file independently and in shuffled order before declaring application tests passed.