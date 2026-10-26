@billing @invoice-import
Feature: Access and inspect invoice records within the current Business
  As a Business user
  I want to find records and retrieve their original files within my current permissions
  So that I can inspect issued facts and report capture errors without changing accepted documents

  Each scenario uses independent synthetic data and approved environment teardown.
  Accepted documents are never deleted through the Business interface for cleanup.


  Background:
    Given the English Billing interface is available in an isolated non-production environment
    And this scenario has its own verified Businesses "Seller A" and "Buyer B"
    And each Business has its own active trading partner relationship with the other
    And Owner, Admin and Member test users are available for each Business
    And I am signed in as Seller A's Owner with Seller A selected
    And the Billing document list is open
    And XML fixtures are synthetic standard B2B SAR documents with valid source and issuing-system facts unless a step states otherwise

  # NEGATIVE CASES: Validation, authorization, and blocked processing

  @negative @roles
  Scenario: Hide import and Resume controls from a Member
    Given I work in Seller A as a Member
    And invoice "INV-001" has an actionable import result
    When I inspect the Billing list and that invoice's import result
    Then no Import control is displayed in the list and no Resume control is displayed on the result

  @negative @roles
  Scenario Outline: Deny a Member's direct import or Resume action
    Given I work in Seller A as a Member
    And invoice "INV-001" has an actionable import result
    When I attempt "<action>" through "<entry>"
    Then the action is denied because it requires an Owner or Admin
    And no new import starts and the actionable result is unchanged

    Examples:
      | action | entry                 |
      | Import | direct import address |
      | Import | direct request        |
      | Resume | direct request        |

  @negative @security
  Scenario Outline: Apply demotion to the next action from an already-open page
    Given I work in Seller A as an Admin with an open page and a valid pending action "<action>"
    And another Owner demotes that Admin to Member
    When I attempt that action from the already-open page
    Then the action is denied and no Billing document or upload is changed by the attempt

    Examples:
      | action                  |
      | Import a new document   |
      | Recover a pending upload |
      | Cancel a pending upload |
      | Resume an actionable result |

  @negative @security
  Scenario Outline: Disclose no private facts through another Business's address
    Given verified Business C owns a private "<resource>" inaccessible to Seller A
    When I request its direct address with Seller A selected
    Then the visible response matches the response for an unknown resource of that kind
    And it reveals no Business name, amount, filename, size, path or download instructions

    Examples:
      | resource      |
      | document      |
      | import result |
      | original file |

  # POSITIVE CASES: Accepted behavior, record integrity, and recovery

  @positive @smoke @list
  Scenario: Combine document filters within the current Business
    Given Seller A has accepted invoices, credit notes and debit notes
    And exactly one record has reference "INV-001", type Invoice, Sales perspective, partner Buyer B and issue date "2026-09-10"
    And other records differ in type, perspective, partner or issue date
    When I search for "INV-001" and filter by Invoice, Sales, Buyer B and issue dates "2026-09-01" to "2026-09-20"
    Then only the matching record is listed with its type, date, partner, perspective and total including VAT and currency

  @positive @list
  Scenario: Returning from detail preserves the current search and filters
    Given the document list has reference search "INV-001" and filters Invoice, Sales and Buyer B applied
    And accepted invoice "INV-001" is the matching record
    When I open it and return to the list
    Then the reference search, filters and matching record remain in place

  @positive @list
  Scenario: Explain that the current Business has no accepted documents
    Given Seller A has no accepted documents
    When I open its Billing list
    Then it shows that the Business has no documents yet

  @positive @list
  Scenario: Explain unmatched searches without claiming the Business has no documents
    Given Seller A has an independently seeded accepted invoice "INV-001"
    When I search for the nonexistent reference "NO-MATCH-999"
    Then the list explains that no documents match the search rather than claiming the Business has no documents

  @positive @records
  Scenario: Preserve source-stated invoice details after a Business profile changes
    Given invoice "INV-001" is accepted with source seller name "Seller A Original" and source address "Original Street"
    And its optional due date is absent from the source
    And Seller A's current profile now has different name and address values
    When I open the accepted invoice detail
    Then it shows the original seller name and address and an unavailable due date
    And it distinguishes declared prior clearance from independent verification that APEX did not perform
    And no payment status, outstanding balance or financing eligibility is inferred from acceptance

  @positive @download
  Scenario Outline: Let every Business role retrieve original files from the correct surface
    Given I work in Seller A as a "<role>"
    And an independently seeded attempt for invoice "INV-001" has result "<result>" and an associated original XML
    And any Accepted or Duplicate result links to an existing accepted invoice
    When I download that XML from "<surface>"
    Then an attachment containing the original XML is downloaded with a safe filename rather than executed inline

    Examples:
      | role   | result          | surface         |
      | Owner  | Accepted        | document detail |
      | Admin  | Duplicate       | document detail |
      | Member | Accepted        | document detail |
      | Owner  | Rejected        | import results  |
      | Admin  | Action required | import results  |
      | Member | Rejected        | import results  |
      | Member | Action required | import results  |

  @positive @support @requires-approved-support
  Scenario: Report a capture error without changing accepted facts
    Given accepted invoice "INV-001" has an original file and a disputed captured field
    And payment request "PR-001" exists against the invoice
    And the approved test support route provides acknowledgements and follow-up references
    When I report the capture error through the route explained on document detail
    Then the report identifies the Business, invoice, file, disputed field and "PR-001" without an unprotected file link
    And I receive an acknowledgement and follow-up reference
    And the accepted invoice, files and earlier results remain unchanged
