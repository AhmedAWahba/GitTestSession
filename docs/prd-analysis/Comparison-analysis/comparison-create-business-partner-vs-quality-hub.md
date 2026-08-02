# Comparison: create_business_partner-test.feature vs bussiness-trading-partener-create-test.feature

Copy from the header row below and paste directly into Excel.
Format: TSV (tab-separated values).

Area	GitTestSession File (create_business_partner-test.feature)	Quality-Hub File (bussiness-trading-partener-create-test.feature)	Difference Type	Execution Impact
Feature scope	PRD-aligned creation flow with validation, blocked paths, cancel, and happy paths	Legacy add-flow orientation with simpler structure	Scope mismatch	GitTestSession file covers current expected behavior better
Scenario ordering	Ordered as validation -> failed/blocked -> happy path	Grouped by legacy sections (validation, success lookup, navigation, successful add, cancel)	Structure mismatch	GitTestSession file is easier for phased execution and reporting
Tag strategy	Uses targeted tags like @validation, @failed-flow, @happy-path, @creation, @cta-state	Uses broader tags like @app, @partner-creation, @smoke, @regression	Tagging mismatch	GitTestSession file supports granular test selection
UNN empty-state rule	Does not assert Check UNN disabled on empty	Asserts Check UNN disabled on empty	Behavior expectation mismatch	Quality-Hub scenario may fail against current flow if button is always active
UNN invalid-format coverage	Covers invalid examples with one canonical PRD-style error message	Covers invalid examples including empty and non-digit with varied error messages	Validation wording mismatch	May cause assertion failures if exact message text differs
Required UNN empty message	Not explicitly covered as a separate required-field message	Explicitly checks 'Unified National Number is required'	Missing legacy case in GitTestSession	Add only if product still requires distinct empty-message behavior
Lookup success data population	Asserts locked/unlocked behavior aligned to current create flow	Expects broad auto-population and read-only values across all sections	Data behavior mismatch	Quality-Hub assumptions can conflict with current design
VAT after lookup	Covers VAT as locked for verified path and editable for registry-only path	Has dedicated VAT format-from-lookup scenario	Scenario granularity mismatch	GitTestSession focuses on functional path over isolated VAT assertion
Add button state	Explicitly covers enable on successful lookup and disable on failed lookup	Also covers state but with legacy phrasing and assumptions	Minor wording mismatch	Both useful; GitTestSession is better aligned with current style
Duplicate/blocked relationship flows	Covers own UNN blocked, active duplicate blocked, inactive duplicate/reactivate, registry not found, outage	Not fully covered with current seeded UNN branch detail	Coverage gap in Quality-Hub	GitTestSession provides stronger negative-path confidence
ID Type / ID Number pairing	Explicit save-block scenarios for pair validation	Not explicitly covered in the same depth	Coverage gap in Quality-Hub	GitTestSession reduces regression risk on paired validation rules
Cancel behavior	Covers cancel before and after successful lookup with no creation	Covers cancel before and after lookup as well	Mostly aligned	Both files provide useful cancel coverage
Post-save destination	Expects navigation to Trading Partner Record detail view	Expects redirect to Business Partners list	Flow expectation mismatch	One of the files will fail if navigation behavior changes
Discrepancy-on-create	Includes verified-partner conflict save with amber banner and Review CTA	Not explicitly covered	Coverage gap in Quality-Hub	GitTestSession captures critical discrepancy behavior
List-appearance assertion	Moved to separate listing/actions file in GitTestSession workspace	Kept inside create flow (new partner appears in list)	Scope split difference	Run listing file together to match old end-to-end expectation
Language/context	Uses Qawafel/X Trading domain language	Uses APEX generic app wording	Terminology mismatch	Can affect readability and traceability to latest PRD
Overall suitability for current execution	High	Medium	Recommendation	Use GitTestSession creation file as primary; add listing file for full journey coverage

## Recommended execution set

Area	File	Reason
Creation flow (primary)	scenarios/vendorApp/create_business_partner-test.feature	Most aligned with latest structure and current expected behavior
Listing and actions (companion)	scenarios/vendorApp/business_partner_listing_actions-test.feature	Completes list visibility and row-action coverage split out of creation file
Legacy baseline (reference only)	D:/Apex/Apex Project/quality-hub/scenarios/app/tests/bussiness-trading-partener-create-test.feature	Useful for historical checks, but contains legacy assumptions
