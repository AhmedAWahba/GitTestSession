# Comparison: create_business_partner-test.feature vs bussiness-trading-partener-create-test.feature

Copy from the header row below and paste directly into Excel.
Format: TSV (tab-separated values).

Area	PRD Expectation	Prototype Behavior	UAT
UNN empty-state rule	Check UNN behavior should match current Business Partner create flow	On add-form load, UNN is the only active field and Check UNN is visible and clickable while other fields stay unavailable	If product expects disabled-empty behavior, this is a mismatch
Required UNN empty message	If a dedicated required-empty validation exists, it should be asserted explicitly	When lookup is triggered with invalid input, the screen shows inline UNN validation feedback under the UNN field	Confirm whether empty input has its own distinct required-message copy
UNN invalid-format validation style	Invalid UNN should show consistent error behavior	Invalid UNN values keep the form locked and show inline format/error messaging; no downstream fields are enabled	Align final assertions to exact on-screen copy
Lookup success data population model	Create flow should reflect source-driven lock/edit behavior per latest Business Partner logic	After successful lookup, UNN stays locked; Legal Business Name (Arabic) is locked; other fields become editable depending on verified vs registry-only result	Use source-based lock/edit behavior as the expected UI pattern
VAT lookup assertion granularity	VAT handling should be validated per lookup source and format constraints	For verified lookup, VAT appears prefilled and locked when available; for registry-only lookup, VAT remains editable with save-time validation	Keep separate VAT assertions only if reporting needs dedicated checks
Blocked relationship branch depth	Create flow should block own UNN, active duplicate, inactive duplicate, unknown registry UNN, and outage paths	Lookup branches show distinct blocked outcomes: own-business error, duplicate with View, inactive with Reactivate, not-found error, and registry-unavailable error	All blocked branches should be asserted as separate negative scenarios
ID Type and ID Number paired validation	If either field is provided, the paired requirement must be enforced	On save, selecting ID Type without ID Number or entering ID Number without ID Type shows inline paired-field validation and blocks submission	Paired-field validation should remain mandatory in UAT
Post-save destination	Successful create should land on the intended next screen	After successful add, the flow navigates to the Trading Partner Record detail view with partner header and status context	If expected destination is list view, this is a flow mismatch
Discrepancy on create	When verified-partner data conflicts, discrepancy flow should be surfaced	Saving conflicting data for a verified partner shows success toast, opens partner detail, and displays amber mismatch banner with Review CTA	Discrepancy create-path should be treated as a critical behavior check
List appearance assertion placement	List visibility after create should be asserted in the suite	List verification is observed after returning to Business Partners, where the new/updated partner row and status are shown	Track this as a companion list/action verification step
Domain terminology	Scenario language should match current Business Partner product terms	UI labels and copy use Business Partners, Trading Partner context, verification badges, and discrepancy language across add/detail/list screens	Keep scenario wording aligned to current UI labels and PRD terms

## Business Partner Difference Summary

Area	PRD Expectation	Prototype Behavior	UAT
Difference focus	Only rows that represent Business Partner feature differences are retained	This sheet reflects screen-observed behavior in add, detail, and list flows	Use this as a difference-only checklist for UAT
