# Gherkin Comparison Report: create_business_partner vs buyer_creation

## 1. Files Compared
- `scenarios/vendorApp/create_business_partner.feature`
- `scenarios/prd1_payment_link_pack/buyer_creation.feature`

## 2. Executive Summary
These two feature files do not describe the same product capability, but they do share a similar high-level purpose: creating a business entity that will later be used in downstream workflows. The key shift is that `buyer_creation.feature` models simple buyer master-data creation for invoice and payment-link workflows, while `create_business_partner.feature` models governed business identity resolution and relationship creation based on UNN lookup, verification status, and discrepancy handling.

At the requirement level, the product moved from direct form-based record creation to a controlled identity-and-relationship workflow. That is why the business partner file is longer, has more branches, and carries more negative-path coverage.

## 3. Feature-Level Differences
| Area | `buyer_creation.feature` | `create_business_partner.feature` | Requirement Change |
|---|---|---|---|
| Product domain | Buyer business creation for invoice/payment-link flows | Business partner creation for Qawafel partner network management | Shift from invoice support data to relationship-managed partner data |
| Actor | Selling business user on APEX | Verified Qawafel business owner / X Trading | Creation now depends on a verified business-owner context |
| Entry point | Login to APEX, navigate to Buyer Business Management or Invoice Creation | Start on Business Partners page and open Add Business Partner | New dedicated feature area and navigation path |
| Creation model | Direct form entry | UNN-gated lookup first, then conditional form completion | Identity resolution introduced before record creation |
| Minimum data | Business Name + Email | Valid UNN found through lookup before any save can happen | UNN became the hard gate for creation |
| Data authority | User-entered buyer record | Mix of verified Qawafel data, Saudi registry data, and user-entered relationship data | Source-of-truth and provenance rules introduced |
| Validation | Basic required and email validation | UNN format, own-business block, duplicate active/inactive relationship, registry miss, registry outage, VAT/email/phone/ID validation | Business-rule enforcement became much richer |
| State model | Create or fail | Active/inactive relationship states, verified/unverified states, discrepancy states | Lifecycle complexity added |
| Post-create behavior | Record appears in listing and becomes selectable | Detail record opens with verification state and possible discrepancy banner | Save outcomes now include governance and review states |
| Downstream usage | Buyer dropdown in invoice creation | Trading Partner Record management and Business Partners list | Relationship management replaced invoice-selection focus |

## 4. Scenario Inventory Comparison
| Source File | Scenario Count | Positive | Negative | Outline | Main Focus |
|---|---:|---:|---:|---:|---|
| `scenarios/prd1_payment_link_pack/buyer_creation.feature` | 5 | 4 | 1 | 1 | Create buyer records and use them in invoice buyer selection |
| `scenarios/vendorApp/create_business_partner.feature` | 14 | 7 | 7 | 1 | Create business partners through lookup, validation, relationship-state, and discrepancy flows |

## 5. Scenario-by-Scenario Comparison Matrix
| `buyer_creation.feature` scenario | Closest scenario(s) in `create_business_partner.feature` | What changed in the scenario design | What changed in the requirements |
|---|---|---|---|
| `Create a buyer business with the minimum required fields` | `Add a verified Qawafel business partner with a successful UNN lookup`; `Add a business partner found only in the Saudi commercial registry` | A single direct-create happy path split into two happy paths based on lookup result source | Creation is no longer generic form entry; it now depends on whether the partner is already verified on Qawafel or exists only in the Saudi registry |
| `Create a buyer business with all supported fields` | `Add a business partner found only in the Saudi commercial registry`; partly `Add a verified Qawafel business partner with a successful UNN lookup` | Optional-field coverage is still present, but some fields now lock or unlock depending on the lookup result | Some business identity fields are now system-sourced and read-only instead of always user-editable |
| `Creating a buyer business fails when required or formatted data is invalid` | `Invalid UNN format shows an inline validation error and does not trigger lookup`; `Save is blocked when a filled field fails format validation`; `Save is blocked when Business Partner ID Type is selected without an ID Number`; `Save is blocked when ID Number is entered without a Business Partner ID Type` | One compact validation outline expanded into several targeted scenarios because validation now occurs at different stages | Validation moved from simple form constraints to staged gatekeeping: lookup-stage validation, save-stage format validation, and cross-field dependency validation |
| `Existing buyer business is selectable from the invoice buyer dropdown` | No direct equivalent | Buyer creation validated downstream reuse in invoice creation; business partner creation validates redirect to the Trading Partner Record instead | Downstream requirement changed from invoice selection to partner record management |
| `Search returns the matching buyer business in the invoice buyer dropdown` | No direct equivalent | Search/select behavior is not covered in the create-business-partner file because it belongs to the Business Partners list slice, not the create slice | Requirement scope shifted; search now belongs to Business Partners list requirements, not to creation itself |

## 6. Business-Partner-Only Scenarios With No Equivalent In `buyer_creation.feature`
| Scenario in `create_business_partner.feature` | Why there is no equivalent in `buyer_creation.feature` | Requirement change introduced |
|---|---|---|
| `Add Business Partner page opens with only the UNN field active` | Buyer creation had no gated first-step field state | Creation now begins with a controlled UNN lookup gate |
| `Adding X Trading's own business UNN is blocked` | Buyer creation had no concept of self-linking through a relationship model | Self-relationship prevention was introduced |
| `Existing active business partner relationship blocks the add flow` | Buyer creation had no stateful relationship uniqueness | Existing relationships must now be detected and blocked |
| `View link from an existing active relationship opens the partner record` | Buyer records were not governed through relationship-state guard rails | Users are now directed to an existing managed record instead of creating duplicates |
| `Existing inactive relationship blocks creating a new partner and shows a reactivate link` | Buyer creation had no inactive relationship state | Relationship archival/reactivation was introduced |
| `Reactivating an inactive relationship opens the existing partner record as active` | Buyer creation did not model reactivation behavior | Active/inactive lifecycle management was introduced |
| `Unknown UNN in the Saudi commercial registry keeps the form locked` | Buyer creation had no external identity dependency | Saudi registry existence became a hard prerequisite |
| `Saudi commercial registry outage prevents adding a business partner` | Buyer creation had no external registry outage branch | External service dependency and outage handling were introduced |
| `Editing the UNN after a successful lookup resets the add form to its initial state` | Buyer creation had no staged lookup state to reset | The form now carries post-lookup state that must be invalidated on identifier change |
| `Saving a verified partner with conflicting data flags a discrepancy after creation` | Buyer creation had no verified profile comparison or discrepancy governance | Post-save discrepancy detection and review flow were introduced |

## 7. Requirement Changes Implied By The New File
1. **UNN became the primary identity key.**
The new feature requires business identity resolution by UNN before partner creation can continue.

2. **System-sourced business identity data was introduced.**
Arabic legal name and some VAT values may now come from verified Qawafel data or the Saudi commercial registry instead of always coming from user input.

3. **A relationship model replaced simple record creation.**
The new feature is not only about creating a business object; it is about creating or reusing a `Trading Partner Relationship` with states such as active and inactive.

4. **One-directional privacy rules were introduced.**
The partner creation model assumes that X Trading can add a business partner privately without notifying the other side.

5. **Duplicate prevention became state-aware.**
The system must now distinguish active duplicate, inactive duplicate, self-relationship, and not-found outcomes before allowing creation.

6. **Verification provenance became part of the UI and behavior.**
The new feature distinguishes `Verified on Qawafel` from `Not Registered on Qawafel`, and those states affect lock behavior, save semantics, and post-save outcomes.

7. **Discrepancy governance was added after save.**
A save can succeed while still creating a discrepancy state that requires follow-up review. That behavior does not exist in the buyer creation file.

## 8. Scenario Design Changes Between The Files
| Design dimension | `buyer_creation.feature` | `create_business_partner.feature` | Observed change |
|---|---|---|---|
| Scenario granularity | Compact and broad | More granular and branch-specific | New file decomposes the flow by business-rule branch |
| Preconditions | Simple navigation/data setup | Relationship existence and lookup-result setup | Preconditions now encode domain state, not just page access |
| Assertions | Listing presence, field validation, dropdown availability | Field lock state, verification state, redirect target, inline branch messages, discrepancy banner | Assertions now reflect a richer state machine |
| Downstream focus | Invoice creation reuse | Trading Partner Record outcome | The target outcome of successful creation changed |
| Negative-path depth | One outline for invalid create attempts | Multiple scenarios for distinct business rules and system failures | Failure handling is more explicit and product-specific |

## 9. What Was Not Carried Forward From `buyer_creation.feature`
- Buyer dropdown selection scenarios were not carried into the create-business-partner file.
- Buyer search-in-dropdown scenarios were not carried into the create-business-partner file.
- A direct `minimum required fields` creation pattern was not carried forward; it was replaced by a lookup-first creation model.
- A single compact validation outline was not carried forward; it was replaced by separate scenarios for materially different branches.

## 10. Conclusion
`create_business_partner.feature` is not a simple rewrite of `buyer_creation.feature`. It represents a materially different and more complex requirement set.

The buyer-business feature assumes:
- direct data entry,
- lightweight validation,
- downstream invoice selection.

The business-partner feature assumes:
- verified-user access,
- UNN-first identity resolution,
- relationship-state handling,
- external registry dependency,
- duplicate-state branching,
- and discrepancy management after save.

In short, the change from the second file to the first file is a move from **simple business record creation** to **governed identity-backed partner relationship creation**.
