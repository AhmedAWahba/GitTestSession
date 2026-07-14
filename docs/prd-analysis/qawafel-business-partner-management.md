# PRD Analysis: Qawafel Platform — Business Partner Management

## 1. Sources Analysed
- `PRD pasted in chat` — Business Partner Management requirements, Sections 1–10 plus master tickets / prototype references
- `https://www.figma.com/board/soouXWmYkP9cgMM6v32uVW/APEX-Screens?node-id=57-170&p=f` — FigJam design board for APEX screens `[MISSING: design board access in current environment]`
- `https://prototype-build-forge.lovable.app/` — Lovable interactive prototype, including Business Partners list, add flow, detail view, discrepancy flow, and seeded verification controls
- `docs/concepts/product-concept-map.md` — not found in workspace
- `docs/concepts/concept-scenario-index.md` — not found in workspace
- `scenarios/prd1_business_registration/business-registration-test.feature` — upstream dependency coverage for registration / verification only; no direct Business Partner Management reuse

## 2. Feature Summary
This feature allows a verified business owner, referred to in the PRD as X Trading, to manage private one-directional business partner relationships on Qawafel. The core journey covers adding a partner by UNN, viewing the Business Partners list, opening the Trading Partner Record, editing relationship-scoped and claim-scoped data, and handling discrepancies between submitted data and a verified Qawafel profile. The PRD is detailed enough to support test design for the functional flow, but the current prototype diverges from several required behaviors and the Figma source could not be verified in this environment.

## 3. In Scope / Out of Scope
**In scope:**
- Manual business partner addition by UNN with sequential lookup and explicit `Check UNN` trigger
- Business Partners list view with search, verification/status filters, row actions, and empty states
- Trading Partner Record detail view, including Business Identity, Contact Information, National Address, Notes, and discrepancy banner states
- Relationship status management: active / inactive
- Discrepancy detection at save time and retroactively when a partner later becomes verified
- In-app notifications to X Trading when a partner becomes verified or a discrepancy is detected
- Alias display when Qawafel Admin changes the legal Arabic name

**Out of scope:**
- Any notification to the Business Partner; the PRD states the action is one-directional and private
- Destructive deletion; the PRD states `No Delete option exists anywhere in the interface`
- Automatic lookup without user action; the PRD states lookup triggers only when X Trading clicks `Check UNN`
- Business Partner visibility of X Trading's relationship-scoped notes or data claims

## 4. Personas & Permissions
| Persona | Role | Key permissions / constraints |
|---|---|---|
| Business Owner (X Trading) | Verified Qawafel user managing their trading partner network | Can add, view, edit, deactivate, reactivate, and resolve discrepancies for their own Trading Partner Relationships; must have completed verification |
| Business Partner | The business being added by X Trading | May or may not be registered on Qawafel; receives no notification and does not automatically see X Trading |
| Qawafel Admin | Administrative actor for legal-name corrections | Can update `Legal Business Name (Arabic)` only upon verification of a legal name change; prior name must be preserved as an alias |
| Qawafel Platform | System actor enforcing lookup, discrepancy, and notification rules | Must preserve verified profile data, create claims rather than destructive overwrites, and keep the relationship one-directional |

## 5. End-to-End User Flow
1. **Add partner happy path — Verified on Qawafel**
X Trading opens `Business Partners`, clicks `+ Add Business Partner`, enters a `Unified National Number (UNN)`, and clicks `Check UNN`. The platform runs checks in order: own UNN, active relationship, inactive relationship, Qawafel Business Identity, Saudi commercial registry. If the UNN belongs to a verified Qawafel business, the form unlocks with verified values populated and locked where required, X Trading fills any remaining editable fields, clicks `Add Business Partner`, sees `Business partner added successfully.`, and is navigated to the Trading Partner Record.

2. **Add partner happy path — Not Registered on Qawafel**
X Trading enters a valid UNN that is not found as a verified Qawafel Business Identity. The Saudi commercial registry returns the legal Arabic name, the form unlocks with `Not Registered on Qawafel`, X Trading enters optional relationship-scoped and claim-scoped data, saves immediately, and lands on the Trading Partner Record.

3. **Existing relationship guard path**
If the UNN belongs to an existing active relationship, the add flow stops and shows `You've already added this business as a business partner. [View]`. If it belongs to an inactive relationship, the add flow stops and shows `This business is in your inactive business partners list. [Reactivate]`; Reactivate should restore the existing relationship instead of creating a new one.

4. **Discrepancy path**
When X Trading saves a verified partner and one of the compared fields conflicts with the verified profile, the save still completes, a data mismatch is flagged, an in-app notification is sent to X Trading, and the Trading Partner Record opens with a persistent amber banner and `Review` CTA. On the resolution screen, X Trading can only choose `Update my records to match the verified profile`.

5. **Retroactive verification path**
If a previously unregistered partner later becomes verified on Qawafel, the platform updates the verification badge automatically. If no conflict exists, X Trading receives the `is now verified on Qawafel` notification. If a conflict exists, the row receives a warning indicator, the record gets a discrepancy banner, and X Trading receives the mismatch notification.

## 6. Acceptance Criteria Coverage
| Story / Section | AC stated in PRD | Testable? | Gaps |
|---|---|---|---|
| FR-PA.1 | `'+ Add Business Partner' button is shown in the Business Partners page header` and `Only the UNN field is active on load` | Yes | Prototype supports the flow; `[MISSING: design confirmation]` from Figma board |
| FR-PA.2 | `UNN field accepts a 10-digit number starting with 7` and invalid format shows an inline error without triggering lookup | Yes | Prototype matches invalid-format behavior; `[MISSING: design confirmation]` |
| FR-PA.3 | `checks in order: own UNN → active relationship → inactive relationship → Qawafel Business Identity → Saudi commercial registry API` and status text `Verifying Now...` | Partial | Prototype shows `Verifying with the Saudi commercial registry...` even on internal-block branches; this conflicts with the required copy and sequence cue |
| FR-PA.4 | `If the Saudi commercial registry API does not find the UNN: inline error shown beneath the UNN field. Form fields remain unavailable.` | Yes | Prototype matched the branch; `[MISSING: design confirmation]` |
| FR-PA.5 | `If the Saudi commercial registry API is temporarily unavailable: inline error shown. Form fields remain unavailable.` | Partial | Prototype error copy omits `Saudi` and instead shows `The commercial registry is temporarily unavailable. Please try again in a few moments.` |
| FR-PA.6 | `If the UNN matches X Trading's own business UNN: inline error shown. Form fields remain unavailable.` | Partial | Error copy matched, but in-flight text still implied a registry check before the internal-block result |
| FR-PA.7 | `If the UNN already has an active Trading Partner Relationship with X Trading: inline message with a 'View Partner' link.` | Partial | Add-flow duplicate guard matched on seeded branch, but prototype later allowed a duplicate active row via a seeded save path, which conflicts with the same business rule |
| FR-PA.8 | `If the UNN has an inactive Trading Partner Relationship with X Trading: inline message with a 'Reactivate' link` and `No new relationship created.` | Partial | Reactivate prompt matched; `[MISSING: executable confirmation that only the existing record is restored and no duplicate is created]` |
| FR-PA.9 | `If the UNN is found as a Verified Business Identity on Qawafel ... locked: Legal Business Name (Arabic), VAT Registration Number (if present)` | Partial | Prototype unlocked the correct general path, but displayed `This business is verified on Qawafel.` instead of the required `Verified on Qawafel` lookup label |
| FR-PA.10 | `If the UNN is not found as a Verified Business Identity in Qawafel ... Legal Business Name (Arabic) auto-populates from the Saudi commercial registry with a source label and locked indicator.` | Yes | Prototype matched general behavior; `[MISSING: design confirmation]` |
| FR-PA.11 | `If X Trading clears or edits the UNN field ... all fields reset and the form returns to its initial state` | Yes | `[MISSING: executable confirmation in prototype walkthrough]` |
| FR-BI.1 | `UNN is read-only after the lookup resolves.` | Yes | Prototype matched the locked UNN behavior |
| FR-BI.2 | `Legal Business Name (Arabic) is read-only for all users.` | Yes | Prototype matched locked Arabic legal name; `[MISSING: alias display confirmation from design source]` |
| FR-BI.3 | `Legal Business Name (English) is an optional free-text field entered by X Trading.` | Yes | Prototype exposed an editable field in the unlocked form |
| FR-BI.4 | `Commercial Name (Arabic or English) is an optional free-text field` | Yes | Prototype exposed an editable field in the unlocked form |
| FR-BI.5 | `VAT Registration Number is an optional field` and invalid format uses Section 10 error copy | Yes | `[MISSING: executable confirmation of invalid-format error in prototype]` |
| FR-BI.6 | `Business Partner ID Type and ID Number are a paired optional set` | Yes | `[MISSING: executable confirmation of paired save-time validation in prototype]` |
| FR-CI.1 | `Contact Information section contains two optional fields: Email Address and a Saudi format Phone Number.` | Yes | `[MISSING: executable confirmation of field validation in prototype]` |
| FR-NA.1 | `Country (default: Saudi Arabia, read-only and dimmed)` and all other fields optional | Partial | Prototype displayed `Kingdom of Saudi Arabia`, not `Saudi Arabia` |
| FR-PA.12 | `The 'Add Business Partner' CTA is shown at the bottom of the form` and save creates / updates the required records | Partial | Immediate save behavior matched; `[MISSING: backend-level confirmation of all three record mutations]` |
| FR-PA.13 | `If any filled field fails format validation at save ... the save is blocked.` | Yes | `[MISSING: executable confirmation across all field types in prototype]` |
| FR-PA.14 | `On successful save, a success toast is shown for 3 seconds.` | Yes | Prototype showed `Business partner added successfully.` |
| FR-PA.15 | `A 'Cancel' button is shown ... No confirmation prompt.` | Yes | Prototype displayed Cancel; `[MISSING: executable confirmation of navigation + discard behavior]` |
| FR-BL.1 | `The Business Partners page shows: page title 'Business Partners', subtitle 'Manage your trading partners', and a '+ Add Business Partner' CTA in the header.` | Yes | Prototype matched these header elements |
| FR-BL.2 | `When X Trading has no business partners yet, the list area shows an empty state` | Yes | `[MISSING: empty-state execution in prototype]` |
| FR-BL.3 | `List columns per row: Business Name (Arabic), UNN, Verification Status badge, Status badge, Action menu. Default list view shows Active partners only.` | Yes | Prototype matched the five-column list and active-only default |
| FR-BL.4 | `Verification Status badge shows one of two states` and auto-updates when the partner becomes verified | Yes | Prototype matched both seeded verification transitions |
| FR-BL.5 | `Status badge shows 'Active' (green) or 'Inactive' (grey).` | Yes | `[MISSING: inactive-row verification in prototype]` |
| FR-BL.6 | `Rows with an active data mismatch show a persistent amber warning indicator next to the Business Name.` | Yes | Prototype matched the warning indicator |
| FR-BL.7 | `Search input above the list filters across: Business Name (Arabic), Legal Business Name (English), and UNN.` | Partial | Prototype placeholder says `Search by business name or UNN...`, which does not signal English-name search coverage |
| FR-BL.8 | `Two filter dropdowns: Verification Status ... and Status ... Defaults: Status = Active, Verification Status = All.` | Partial | Visible list default matched, but prototype control text `All Statuses` is ambiguous against `Status = Active` |
| FR-BL.9 | `Each row has an Action menu ... View, Edit, Mark as Inactive, Mark as Active.` | Partial | Prototype action copy used `View Business Partner`, `Edit Business Partner`, and `Set Inactive` |
| FR-TR.1 | `Record header shows: Business Name (Arabic), UNN, and Verification Status badge with provenance label.` | Yes | Prototype matched verified detail header |
| FR-TR.2 | `If a data mismatch is flagged, a persistent amber banner appears above the header with a 'Review' CTA.` | Yes | Prototype matched the discrepancy banner |
| FR-TR.3 | `Business Identity section displays all fields in read-only mode.` | Yes | Prototype matched read-only display and exposed an edit route |
| FR-TR.4 | `'Also known as' aliases are shown below the current Legal Business Name (Arabic) when one or more aliases exist.` | Yes | `[MISSING: executable alias case in prototype]` |
| FR-TR.5 | `Clicking 'Edit section' on the Business Identity section puts all editable claim fields into edit mode simultaneously` | Partial | Edit route exists; `[MISSING: full executable confirmation that all claim fields activate together and save creates one Data Claim]` |
| FR-TR.6 | `Contact Information displays Email Address and a Saudi format Phone Number. Both editable at any time.` | Partial | Prototype added an `Edit section` gate, which conflicts with `Both editable at any time.` |
| FR-TR.7 | `National Address ... All other fields editable.` | Partial | Prototype added an `Edit section` gate, which conflicts with inline-edit wording |
| FR-TR.8 | `A Notes section shows a free-text area where X Trading can write and save notes` and `Notes are relationship-scoped` | Partial | Prototype added an `Edit section` gate instead of notes being editable at any time |
| FR-DD.1 | `When X Trading saves a business partner who is Verified on Qawafel, the platform compares X Trading's submitted fields against the verified profile.` | Yes | Prototype discrepancy-save path matched the comparison outcome |
| FR-DD.2 | `If a conflict is detected ... mismatch is flagged. Verified profile unchanged.` | Yes | Prototype matched the mismatch-flag outcome |
| FR-DD.3 | `When a Business Identity transitions from Not Registered on Qawafel to Verified on Qawafel ... Any relationship where X Trading's submitted data conflicts ... receives a data mismatch flag and triggers an in-app notification` | Yes | Prototype matched both no-conflict and conflict verification transitions |
| FR-DD.4 | `The amber discrepancy banner ... shows the specific conflicting fields with both values.` | Partial | Prototype exposed the resolution screen with side-by-side values; `[MISSING: banner-level confirmation that all conflicting fields are listed before click-through]` |
| FR-DD.5 | `the only available resolution is to update X Trading's records to match the verified profile.` | Yes | Prototype matched the single-resolution-path screen |
| FR-DD.6 | `On resolution confirmation ... Mismatch flag cleared.` | Yes | `[MISSING: executable confirmation of post-resolution clearing in prototype]` |
| FR-DD.7 | `An in-app notification is sent to X Trading when a discrepancy is detected.` | Yes | Prototype matched the discrepancy notification |

## 7. Business Rules & Data
- `Every piece of business data is a claim - never a destructive overwrite.`
- `Adding a business partner is a one-directional action` and `No notification of any kind is sent to that Business Partner.`
- `UNN is the hard gate - a business partner cannot be added without a valid UNN found in the Saudi commercial registry.`
- `The 'Check UNN' button is always active.`
- Lookup order is explicitly stated as `own UNN → active relationship → inactive relationship → Qawafel Business Identity → Saudi commercial registry API`.
- `Legal Business Name (Arabic)` is always read-only for X Trading and can be changed only by `Qawafel Admin` on a verified legal name change.
- When admin changes the legal Arabic name, `the prior name is automatically preserved as an 'Also known as' alias.`
- `Business Partner ID Type and ID Number are a paired optional set: if either is filled, both are required before saving.`
- `National Address is always X Trading's own entry - it is never sourced from the Business Partner's verified profile.`
- Successful save creates or updates `Business Identity`, `Trading Partner Relationship`, and `Data Claim`.
- Contact Information, National Address, and Notes are relationship-scoped, not visible to the Business Partner, and are not claim records unless explicitly stated otherwise.
- On discrepancy resolution for a verified profile, `X Trading cannot override the verified value.`
- [ASSUMPTION] The PRD's `Saudi commercial registry API` and the prototype's `commercial registry` / `Wathq` wording refer to the same external source, because no second registry source is defined in the PRD.

## 8. Edge Cases & Negative Paths
- Empty UNN field with `Check UNN` clicked: the PRD defines invalid-format handling, but `[MISSING: explicit empty-field error copy]`.
- UNN with valid format but own business match: must stop at the own-business check and show `You cannot add your own business as a business partner.`
- UNN with an existing active relationship: must show `You've already added this business as a business partner. [View]` and must not create a second relationship.
- UNN with an inactive relationship: must show `This business is in your inactive business partners list. [Reactivate]` and reactivate the existing record instead of creating a new one.
- Registry miss: must show `We couldn't find this UNN in the Saudi commercial registry. Please double-check the number.`
- Registry outage: must show `The Saudi commercial registry is temporarily unavailable. Please try again in a few moments.`
- Boundary and invalid inputs: VAT, email, and phone all have explicit negative validation cases; `[MISSING: explicit length constraints for free-text fields such as Legal Business Name (English), Commercial Name, Notes, and Address Line]`.
- Concurrent action risk: two simultaneous adds for the same UNN / relationship are not described in the PRD; this matters because the prototype exposed a duplicate-row path.
- Unauthorized access: the feature assumes verified X Trading access, but `[MISSING: access-control behavior for unverified or unauthorized users opening Business Partners routes directly]`.
- Locale / RTL: Arabic business names are primary list/detail labels, so mixed RTL/LTR rendering is relevant; `[MISSING: Figma confirmation of bidi layout treatment]`.

## 9. Cross-Story Dependencies
This PRD depends directly on the Business Registration, Sign-In & Verification flow for creation of a verified Business Identity, UNN uniqueness, and verified profile data, because the Business Partner Management feature consumes those records as lookup and trust anchors. The add flow also depends on the Business and Trading Partner Concept Note's three-layer model, separating Business Identity, Trading Partner Relationship, and Data Claims, which is why the PRD insists on claim creation instead of destructive overwrite. The discrepancy and retroactive verification flows depend on later state changes in the Business Identity lifecycle: when a partner transitions from `Not Registered on Qawafel` to `Verified on Qawafel`, the list, detail record, warnings, and notifications must all reconcile the same state change consistently.

## 10. Risk Assessment
| Risk | Area | Likelihood | Impact | Mitigation suggestion |
|---|---|---|---|---|
| Internal-only lookup branches display registry-specific loading copy, implying an external check before internal checks finish | UI / API | H | M | Align the loading text and logic to the PRD's `Verifying Now...` wording and verify each branch stops before the external call |
| Prototype allows a duplicate active row for an already-related UNN, contradicting `No new relationship created.` | Data | H | H | Add relationship uniqueness enforcement at service and persistence layers; create a regression test for add-after-existing-relationship paths |
| Contact Information, National Address, and Notes use section-gated editing in the prototype instead of the PRD's editable-at-any-time model | UI | M | M | Resolve whether the PRD or prototype is source of truth, then update tests and design together |
| Figma source could not be inspected, leaving `[MISSING: design confirmation]` on layout, spacing, disabled-state treatment, and alias presentation | UI | M | M | Re-run design review in an environment with working board access before sign-off |
| The prototype uses different exact copy for key states such as verified lookup and registry outage | UI | M | M | Run a copy audit against Sections 9 and 10, which explicitly require strings to be used `exactly as written` |
| Free-text fields lack explicit length / sanitization rules in the PRD | Security / Data | M | M | Add max-length and sanitization requirements for all free-text inputs before implementation sign-off |
| Unauthorized-access behavior for Business Partners routes is not defined | Security | M | H | Add explicit access-control acceptance criteria for verified vs. unverified / unauthorized users |

## 11. Open Questions
1. PM / Design / Dev: Is the PRD's editing model authoritative for `Contact Information`, `National Address`, and `Notes`, or should the PRD be updated to reflect section-gated editing shown in the prototype?
2. Dev: How is uniqueness enforced so that an existing active or inactive Trading Partner Relationship cannot be duplicated by a save path after lookup?
3. Design: Can the Figma board be made accessible or exported so the required design reconciliation can be completed for disabled states, alias display, discrepancy layouts, and copy treatment?
4. PM / Dev: What is the expected exact loading text during UNN lookup, given the PRD says `Verifying Now...` while the prototype references the commercial registry before internal checks are resolved?
5. PM / Dev: What is the explicit behavior for unauthorized or unverified users who try to access the Business Partners list, add form, or Trading Partner Record directly? `[MISSING: access-control requirement]`
6. PM / Dev: What maximum lengths and sanitization rules apply to free-text fields such as Legal Business Name (English), Commercial Name, Notes, and National Address fields? `[MISSING: field constraints]`
7. PM / Dev: [ASSUMPTION] Does the prototype's `Wathq` wording represent the same external source as the PRD's `Saudi commercial registry API`, or is there a naming / integration split that must be clarified?

## 12. Test Strategy Recommendation
- **Test types needed:** Functional, API, Regression, Integration, E2E, Security, Localization
- **Suggested test data:** verified Qawafel partner UNN, registry-only partner UNN, own-business UNN, active-duplicate UNN, inactive-duplicate UNN, unknown UNN, registry-outage stub, verified-partner-with-conflicting-data seed, verified-partner-with-no-conflict seed, alias-enabled partner record
- **Environment prerequisites:** verified X Trading account; seeded Business Identity and Trading Partner Relationship data for each lookup branch; controllable external-registry responses; controllable later-verification events; in-app notification visibility; access to Figma or equivalent exported design artifacts
- **Reusable scenarios to extend:** none found for direct Business Partner Management coverage in `scenarios/`; upstream dependency references only in `scenarios/prd1_business_registration/business-registration-test.feature`
- **New scenarios to author:** Add partner from verified Qawafel identity; add partner from registry-only identity; block own-business UNN; block active duplicate relationship; reactivate inactive relationship; save verified partner with discrepancy; resolve discrepancy to verified profile; auto-update verification badge with no conflict; auto-flag retroactive discrepancy on later verification; prevent duplicate relationship creation after existing match; enforce exact copy strings from PRD Sections 9 and 10; verify relationship-scoped vs. claim-scoped persistence boundaries

## 13. Readiness Verdict
**Verdict:** Conditionally ready — resolve open questions
**Blockers / Conditions:** `[MISSING: Figma board access]`; resolve whether the PRD or prototype is authoritative for relationship-field editing behavior; fix or explain the duplicate-relationship path observed in the prototype; align exact copy for lookup / registry states before implementation sign-off

Suggested save path: docs/prd-analysis/qawafel-business-partner-management.md