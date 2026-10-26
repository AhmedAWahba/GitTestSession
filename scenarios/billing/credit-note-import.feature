@billing @credit-note-import
Feature: Record issued credit notes and their invoice relationships
  As an authorized selling or buying Business user
  I want to import issued credit notes with complete invoice links
  So that commercial adjustments remain traceable without rewriting invoices

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
    And every new note fixture has an issuance reason and valid dates and names Seller A and Buyer B as its parties unless stated otherwise

  # NEGATIVE CASES: Validation, authorization, and blocked processing

  @negative
  Scenario Outline: Reject an invalid credit-note reference set without partial links
    Given Seller A has accepted invoices "INV-001" and "INV-002" with Seller A and Buyer B as parties
    And the credit-note fixture references each invoice once unless the defect changes its references
    And otherwise valid credit note "CN-001" has "<defect>"
    When I import the note with prior-clearance declared
    Then its result is "Rejected" with "<reason>" identified
    And no accepted "CN-001" or partial invoice-link set appears in Billing

    Examples:
      | defect                                                  | reason                    |
      | no issuance reason                                      | missing reason            |
      | no invoice reference                                    | missing invoice reference |
      | INV-001 referenced twice                                 | repeated invoice reference |
      | one reference to an accepted invoice with a different buyer | buyer mismatch         |
      | one reference to an accepted invoice with a different seller | seller mismatch       |
      | an issue date before one referenced invoice              | note predates invoice     |

  @negative
  Scenario Outline: Reject invalid credit-note source facts without dropping lines
    Given Seller A has accepted invoice "INV-001"
    And otherwise valid note "CN-001" references it but has "<defect>"
    When I import the note with prior-clearance declared
    Then its result is "Rejected" with the affected field or line identified
    And no partial credit note is accepted

    Examples:
      | defect                                      |
      | a negative ordinary commercial amount       |
      | a commercial line quantity zero             |
      | a non-SAR document currency                 |
      | an exempt line without exemption explanation |
      | an unexplained positive prepayment          |
      | conflicting repeated QR and document totals |
      | malformed supplied optional payment instructions |

  @negative
  Scenario: A repeated note cannot silently redirect an accepted invoice link
    Given "CN-001" is accepted referencing "INV-001"
    And "INV-002" is another accepted invoice with matching parties and a valid date
    When I import a new valid XML for the same seller and note number referencing only "INV-002"
    Then its result is "Rejected" for the conflicting reference details
    And the accepted note still links only to "INV-001"

  # POSITIVE CASES: Accepted behavior, record integrity, and recovery

  @positive @smoke
  Scenario Outline: Accept a credit note in the current Business's sales or purchase perspective
    Given I work in "<business>" as an "<role>"
    And invoice "INV-001" is accepted in that Business with Seller A and Buyer B as its parties
    And a new credit note "CN-001" has the same parties and references that invoice
    And the note states a reason and an issue date on or after the invoice date
    When I import its XML with an explicit declaration of prior ZATCA clearance
    Then "CN-001" is "Accepted" as a "<perspective>" credit note with its stated amounts preserved
    And its invoice reference opens the exact "INV-001" in the current Business

    Examples:
      | business | role  | perspective |
      | Seller A | Owner | Sales       |
      | Seller A | Admin | Sales       |
      | Buyer B  | Owner | Purchase    |
      | Buyer B  | Admin | Purchase    |

  @positive @multi-invoice
  Scenario Outline: Keep the full credit-note amount under every referenced invoice
    Given "<business>" has accepted invoices "INV-001" and "INV-002" with identical seller and buyer
    And I work in "<business>" as an "Owner"
    And credit note "CN-001" validly references both invoices once with a stated total including VAT of SAR 115.00
    When I import the note with prior-clearance declared and it is accepted
    Then the note lists both invoice references with working links to those exact records
    And each invoice's related-notes list shows "CN-001" with its date and full stated SAR 115.00 amount

    Examples:
      | business |
      | Seller A |
      | Buyer B  |

  @positive @amounts
  Scenario: Keep an invoice amount unchanged after accepting a credit note
    Given invoice "INV-001" is accepted with stated total including VAT of SAR 230.00
    And a valid note "CN-001" references it with stated total including VAT of SAR 115.00
    When I import the note with prior-clearance declared and open its referenced invoice after acceptance
    Then the invoice still shows its original SAR 230.00 total
    And its related-notes list shows the separate SAR 115.00 note
    And the note does not create a payment, refund or derived outstanding balance

  @positive
  Scenario: Omit an optional credit-note supply date without inventing it
    Given Seller A has accepted invoice "INV-001"
    And otherwise valid note "CN-001" references it without supply date or due date
    When I import the note with prior-clearance declared and open its accepted detail
    Then the source reason and stated amounts are displayed
    And supply date and due date are shown as unavailable
    And the detail states that prior clearance was declared and not independently verified by APEX

  @positive
  Scenario: Accept a zero-valued commercial line when its remaining facts reconcile
    Given Seller A has accepted invoice "INV-001"
    And valid note "CN-001" references it with a reason and positive commercial quantity
    And that line has zero unit price and reconciled zero ordinary amounts and appropriate tax facts
    When I import the note with prior-clearance declared
    Then the note is "Accepted" with the stated zero values preserved

  @positive @duplicate
  Scenario: A repeated credit note keeps its invoice links and adds its original file
    Given "CN-001" is accepted with complete links to "INV-001" and "INV-002"
    When I import a valid compatible copy with prior-clearance declared
    Then its result is "Duplicate" and opens the accepted note
    And both original XML files are downloadable from note detail
    And the accepted note facts and both invoice links remain unchanged

  @positive @debit-note-parity
  Scenario Outline: Accept the same supported note relationship for credit and debit notes
    Given Seller A has accepted invoice "INV-001"
    And a new standard SAR "<type>" has XML type code "<code>", a reason and a valid distinct reference to that invoice
    When I import its XML with prior-clearance declared
    Then it is "Accepted" with document type "<type>" in the unified list and detail
    And the invoice's related-notes list links to that note with its type and full stated amount

    Examples:
      | type        | code |
      | Credit note | 381  |
      | Debit note  | 383  |

  # BOUNDARY AND MIXED CASES: Parameterized outcomes and result summaries

  @boundary
  Scenario Outline: Compare the credit-note date with the invoice date
    Given invoice "INV-001" was accepted with issue date "2026-09-10"
    And Saudi processing date is "2026-09-20"
    And a credit note "CN-001" references that invoice with issue date "<date>"
    When I import the note with prior-clearance declared
    Then its result is "<result>"

    Examples:
      | date       | result   |
      | 2026-09-09 | Rejected |
      | 2026-09-10 | Accepted |
      | 2026-09-11 | Accepted |
      | 2026-09-21 | Rejected |
