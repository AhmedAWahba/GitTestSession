@billing @invoice-import
Feature: Submit and recover issued invoice imports within the current Business
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
  Scenario: Require the prior-clearance declaration before submission
    Given I selected a valid new invoice XML on Import documents
    When I attempt to submit without declaring prior ZATCA clearance
    Then no document processing starts
    And the import form explains that the clearance declaration is required

  @negative
  Scenario: Report an unreadable file as a source issue rather than an invoice rejection
    Given a submission contains a valid invoice "INV-001" and a file with no identifiable document
    When I import the submission with prior-clearance declared
    Then "INV-001" is "Accepted"
    And the unreadable file has a file-level source issue with a safe explanation
    And no rejected invoice is invented for the unreadable file

  @negative @recovery
  Scenario Outline: Repairing a partner relationship does not automatically resume an invoice
    Given I work in "<business>" as an "<role>"
    And its relationship with "<partner>" is "<state>" while the reciprocal relationship is active
    And valid invoice "INV-001" is in "Action required" for that relationship
    When I add or reactivate that relationship through Business Partners
    Then the invoice remains "Action required" with Resume available
    And import has not created an accepted record for "INV-001"

    Examples:
      | business | role  | partner  | state    |
      | Seller A | Owner | Buyer B  | missing  |
      | Seller A | Admin | Buyer B  | inactive |
      | Buyer B  | Owner | Seller A | missing  |
      | Buyer B  | Admin | Seller A | inactive |

  @negative @recovery
  Scenario Outline: Never reopen a terminal transfer
    Given a file transfer has terminal outcome "<outcome>"
    When I try to recover that transfer
    Then the terminal transfer remains "<outcome>" and cannot resume uploading

    Examples:
      | outcome   |
      | cancelled |
      | expired   |
      | failed    |

  @negative @recovery @controlled-fault
  Scenario: Explain infrastructure delay without requesting business-data changes
    Given a valid imported invoice is Processing when a controlled infrastructure delay prevents its checks
    When I reopen its import results
    Then it remains "Processing" with "Processing is taking longer than expected. Your submission is saved."
    And I am not told to change the file or repair a partner relationship because of that delay

  # POSITIVE CASES: Accepted behavior, record integrity, and recovery

  @positive @smoke
  Scenario Outline: Accept an invoice for an authorized seller or buyer
    Given I work in "<business>" as an "<role>"
    And a new invoice "INV-001" states "Seller A" as seller and "Buyer B" as buyer
    When I import its XML with an explicit declaration of prior ZATCA clearance
    Then its document result is "Accepted" without a second registration approval
    And exactly one "<perspective>" invoice "INV-001" appears with "<partner>" as Business Partner

    Examples:
      | business | role  | perspective | partner  |
      | Seller A | Owner | Sales       | Buyer B  |
      | Seller A | Admin | Sales       | Buyer B  |
      | Buyer B  | Owner | Purchase    | Seller A |
      | Buyer B  | Admin | Purchase    | Seller A |

  @positive @recovery
  Scenario Outline: Keep an unfinished submission available after leaving
    Given a submission has accepted invoice "INV-001" and invoice "INV-002" held in Processing by the test environment
    When I "<interruption>" and return to its import results
    Then "INV-001" remains "Accepted" and "INV-002" remains "Processing"
    And neither invoice has a second accepted record from returning
    And "Processing finished" is absent while any file or document is unfinished

    Examples:
      | interruption                 |
      | navigate to another page     |
      | close and reopen the page    |
      | lose and restore connection  |

  @positive @business-isolation
  Scenario: A seller import does not populate the buyer's records
    Given a new valid invoice "INV-001" states Seller A and Buyer B
    When Seller A imports the invoice and it is accepted
    Then Buyer B's document list contains no "INV-001" and no counterparty-import notification is created there

  @positive @business-isolation
  Scenario: A seller's accepted copy does not make the buyer's independent import a duplicate
    Given invoice "INV-001" is independently accepted in Seller A's records but absent from Buyer B's records
    And I work in Buyer B as an Owner
    When I import the same valid invoice with prior-clearance declared
    Then Buyer B's result is "Accepted" as a Purchase invoice rather than "Duplicate"

  @positive @recovery
  Scenario Outline: Explicitly resume an invoice after repairing its partner relationship
    Given I work in "<business>" as an "<role>"
    And valid invoice "INV-001" has an Action required result for a partner relationship
    And that Business's required partner relationship has already been repaired
    When I Resume the invoice's current result and revalidation finishes
    Then its new result is "Accepted" and exactly one invoice record is listed

    Examples:
      | business | role  |
      | Seller A | Owner |
      | Seller A | Admin |
      | Buyer B  | Owner |
      | Buyer B  | Admin |

  @positive @recovery
  Scenario: Recover one interrupted pending upload without restarting its siblings
    Given a submission has one accepted invoice and another pending file transfer interrupted by connection loss
    And the pending transfer remains within the environment's approved recovery deadline
    When I recover that pending upload
    Then the existing pending transfer receives recovery instructions
    And the accepted sibling stays accepted with no repeated accepted record

  @positive @recovery @controlled-fault
  Scenario: Recover delayed work without creating another accepted invoice
    Given valid invoice attempt "ATTEMPT-1" is held in Processing by a controlled infrastructure failure
    When an authorized platform operator restores processing and continues that attempt
    Then the same attempt reaches "Accepted" with exactly one accepted invoice record
    And the operational audit identifies the operator, recovery action and time

  @positive @correction
  Scenario: Correct rejected source material through a new attempt
    Given invoice attempt "ATTEMPT-1" was rejected with its original file retained
    And the issuing process provides corrected valid XML for that document
    When I import the corrected XML with prior-clearance declared
    Then a separate attempt has result "Accepted"
    And the earlier rejected attempt, its reasons and original file remain accessible

  # BOUNDARY AND MIXED CASES: Parameterized outcomes and result summaries

  @boundary @requires-approved-limits
  Scenario Outline: Enforce the approved file-count and file-size limits
    Given the environment publishes an approved finite "<limit>" limit
    And all other upload limits are satisfied by valid independent invoice fixtures
    When I submit fixtures "<position>" that published limit with prior-clearance declared
    Then the submission is "<outcome>"

    Examples:
      | limit     | position        | outcome                                                |
      | file count | exactly at     | accepted for processing                                |
      | file count | one file above | refused with the exceeded file-count limit explained    |
      | file size  | exactly at     | accepted for processing                                |
      | file size  | one byte above | refused with the exceeded file-size limit explained     |

  @mixed-results
  Scenario: Complete a mixed submission without undoing accepted siblings
    Given the following independent invoice fixtures are selected for one submission
      | Reference | Fixture condition                                          |
      | INV-001   | valid new invoice                                          |
      | INV-002   | valid new invoice                                          |
      | INV-003   | valid compatible repeat of an independently accepted record |
      | INV-004   | otherwise valid invoice with no supply date                 |
      | INV-005   | valid new invoice for a verified buyer with no partner record |
    When I import the submission with prior-clearance declared and open its completed results
    Then the summary shows "Processing finished" with these counts
      | Result          | Count |
      | Processing      | 0     |
      | Accepted        | 2     |
      | Duplicate       | 1     |
      | Rejected        | 1     |
      | Action required | 1     |
    And no overall completion percentage is displayed
