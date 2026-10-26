@billing @invoice-import
Feature: Validate invoice source facts and recognize duplicate records
  As an authorized Business user
  I want to import already-cleared documents and understand each result
  So that my Business can retain dependable source records and original files

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

  @negative
  Scenario Outline: Reject an identifiable invoice outside the supported source rules
    Given an otherwise valid new invoice "INV-001" has "<condition>"
    When I import its XML with prior-clearance declared
    Then its result is "Rejected" with a plain-language reason identifying "<problem>"
    And "INV-001" is absent from the accepted document list

    Examples:
      | condition                                    | problem                           |
      | simplified transaction classification        | unsupported simplified document   |
      | standalone prepayment invoice type 386       | unsupported prepayment invoice    |
      | document and tax currency USD                | unsupported currency              |
      | an explicit draft marker                     | document not issued and cleared   |
      | an explicit rejected-clearance marker        | document not cleared              |
      | an explicit uncleared marker                 | document not cleared              |

  @negative
  Scenario Outline: Reject the whole invoice rather than discard invalid facts
    Given an otherwise valid invoice "INV-001" has "<defect>"
    When I import its XML with prior-clearance declared
    Then its result is "Rejected" with the affected "<location>" identified
    And no invoice or subset of its lines is registered as accepted

    Examples:
      | defect                                                    | location                 |
      | no supply date                                            | supply date              |
      | no commercial line                                        | commercial lines         |
      | commercial line quantity zero                             | line quantity            |
      | negative commercial line net unit price                    | line unit price          |
      | a missing stated total before tax                         | total before tax         |
      | two units at 100.00 with line net 190.00 and no adjustments | line amount              |
      | a tax breakdown inconsistent with its lines                | tax breakdown            |
      | a QR total that differs from its stated total              | QR total                 |
      | an unexplained positive prepayment deduction               | prepayment details       |
      | malformed supplied due date                                | due date                 |
      | a repeated single-occurrence field with equal values       | repeated field           |
      | an issue date after the retained Saudi processing date     | issue date               |
      | supply-period end before its start                         | supply period            |
      | a supply-period end without a start                        | supply period            |

  @negative
  Scenario Outline: Require tax reasons appropriate to the stated treatment
    Given an otherwise valid invoice "INV-001" has a "<treatment>" line
    And the line omits its required "<missing>"
    When I import its XML with prior-clearance declared
    Then the whole invoice is "Rejected" with the line tax treatment and missing fact identified

    Examples:
      | treatment    | missing                          |
      | Zero-rated   | exemption code and explanation   |
      | Exempt       | exemption code and explanation   |
      | Outside scope | outside-scope code and reason   |

  @negative @security
  Scenario Outline: Reject documents whose parties do not identify an eligible trade
    Given a new invoice "INV-001" has "<condition>"
    When I import its XML with prior-clearance declared
    Then its result is "Rejected" with "<problem>" explained without another Business's private details
    And import creates no Business record

    Examples:
      | condition                                                  | problem                              |
      | a buyer that cannot resolve to an existing verified Business | buyer identification                |
      | recognized seller identifiers resolving to different Businesses | inconsistent seller identification |
      | only a group tax registration identifying no legal buyer    | buyer identification                 |
      | a verified seller and buyer neither of which is Seller A   | current Business is neither party    |
      | Seller A as both seller and buyer                          | seller and buyer are the same Business |

  @negative
  Scenario Outline: Reject conflicting recognized facts on a repeated identity
    Given an invoice with seller "Seller A" and number "42" is accepted
    And a valid incoming document with the same seller and number has "<conflict>"
    When I import the incoming XML with prior-clearance declared
    Then its result is "Rejected" with the conflicting fact identified
    And the existing invoice and its accepted facts remain unchanged

    Examples:
      | conflict                                      |
      | credit-note type instead of invoice type      |
      | an issue date in a different year             |
      | a different total amount                     |
      | a conflicting supplied document hash         |

  @negative
  Scenario: Validate an invalid repeat before recognizing a duplicate
    Given invoice "INV-001" is accepted
    And another XML with that seller and number has an invalid line total
    When I import that XML with prior-clearance declared
    Then its result is "Rejected" with the invalid line identified rather than "Duplicate"

  # POSITIVE CASES: Accepted behavior, record integrity, and recovery

  @positive @smoke @duplicate
  Scenario: Keep accepted facts and retain a compatible repeated original file
    Given invoice "INV-001" is accepted without a due date
    And a compatible new XML for that identity supplies a valid due date
    When I import the compatible XML with prior-clearance declared
    Then the result is "Duplicate" with "This document is already in your records" and a link to the invoice
    And the accepted invoice's due date remains unavailable
    And both original files can be downloaded from that invoice

  @positive @boundary
  Scenario Outline: Preserve significant differences in document numbers
    Given a valid invoice with number "<existing>" is accepted for Seller A
    And an otherwise compatible incoming invoice states number "<incoming>"
    When I import the incoming XML with prior-clearance declared
    Then its result is "<result>"

    Examples:
      | existing | incoming | result    |
      | 42       | 42       | Duplicate |
      | 42       | 042      | Accepted  |
      | INV-42   | inv-42   | Accepted  |
      | INV 42   | INV42    | Accepted  |
      | INV-42   | INV.42   | Accepted  |

  @positive @boundary
  Scenario: Trim only outer whitespace when comparing a document number
    Given an invoice with number "42" is accepted for Seller A
    And an otherwise compatible incoming invoice has the literal number " 42 " in its XML
    When I import the incoming XML with prior-clearance declared
    Then its result is "Duplicate" and opens the existing invoice numbered "42"

  @positive @concurrency
  Scenario: Accept at most one record from concurrent compatible imports
    Given two Owner sessions have compatible XML copies of the same new invoice identity ready to import
    When both sessions submit their copies concurrently with prior-clearance declared and processing finishes
    Then exactly one attempt is "Accepted" and the other is "Duplicate"
    And the document list contains exactly one accepted record for that identity

  @positive @duplicate
  Scenario: An inactive partner does not block a compatible repeat
    Given invoice "INV-001" is accepted and Seller A's relationship with Buyer B is now inactive
    When I import a valid compatible repeat with prior-clearance declared
    Then its result is "Duplicate" and links to the unchanged accepted invoice

  # BOUNDARY AND MIXED CASES: Parameterized outcomes and result summaries

  @rounding
  Scenario Outline: Respect the source component-rounding steps
    Given invoice "INV-001" has a price component 10.004 rounded to 10.00
    And its allowance calculation 1.005 is separately rounded to 1.01
    And its stated line net is "<net>" with otherwise consistent totals
    When I import its XML with prior-clearance declared
    Then its result is "<result>"

    Examples:
      | net  | result   |
      | 8.99 | Accepted |
      | 9.00 | Rejected |
