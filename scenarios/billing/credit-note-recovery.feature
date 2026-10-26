@billing @credit-note-import
Feature: Recover credit notes with missing or changed invoice dependencies
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

  @negative @recovery
  Scenario Outline: Explain every missing invoice after a submitted note's reference wait
    Given I work in "<business>" as an "<role>"
    And valid note "CN-001" was submitted with prior-clearance declared and references "INV-001" and "INV-002" not yet in that Business's records
    And the controlled reference wait has concluded without those invoices arriving
    When I inspect the note's import result
    Then it is "Action required" and lists exactly "INV-001" and "INV-002" as missing

    Examples:
      | business | role  |
      | Seller A | Owner |
      | Seller A | Admin |
      | Buyer B  | Owner |
      | Buyer B  | Admin |

  @negative @recovery
  Scenario Outline: Importing the missing invoices does not automatically resume the note
    Given I work in "<business>" as an "<role>"
    And note "CN-001" is Action required because invoices "INV-001" and "INV-002" are missing
    When I import both valid invoices with prior-clearance declared and their accepted records become visible
    Then "CN-001" remains "Action required" with Resume available
    And no accepted record for that note exists yet

    Examples:
      | business | role  |
      | Seller A | Owner |
      | Seller A | Admin |
      | Buyer B  | Owner |
      | Buyer B  | Admin |

  @negative
  Scenario: Reject a known contradiction even when another referenced invoice is missing
    Given Saudi processing date is "2026-09-20"
    And Seller A has accepted invoice "INV-LATER" issued on "2026-09-12"
    And otherwise valid note "CN-001" is dated "2026-09-11"
    And it references "INV-LATER" and missing invoice "INV-MISSING"
    When I import the note with prior-clearance declared
    Then its result is "Rejected" because it predates "INV-LATER"
    And it is not left in "Action required" solely for "INV-MISSING"

  @negative @controlled-fault
  Scenario: Do not report a missing invoice when APEX cannot check references
    Given a valid imported note "CN-001" is Processing
    And a controlled infrastructure failure prevents lookup of its referenced invoice
    When I inspect its import result during the delay
    Then it remains "Processing" with a saved-submission delay explanation
    And no result instructs me to import a supposedly missing invoice because of that system failure

  @negative @recovery
  Scenario: Recheck the current partner relationship when resuming a note
    Given note "CN-001" is Action required for a missing invoice
    And the missing invoice is now accepted and visible
    And Seller A's relationship with Buyer B has since become inactive
    When I Resume the note's current result
    Then revalidation leaves the note "Action required" with the inactive relationship explained
    And the note and its links are not accepted until that cause is repaired and explicitly resumed

  @negative @stale-page
  Scenario: An old page cannot resume a later actionable result
    Given I opened note "CN-001" at its first Action required result
    And another authorized user resumed it and it returned to a different Action required result
    When I attempt Resume from my unchanged old page
    Then the later result is not resumed by that stale action
    And the current Action required result remains unchanged by my stale action

  @negative @roles
  Scenario: A Member can inspect an actionable note but cannot resume it
    Given I work in Buyer B as a Member
    And purchase note "CN-001" is Action required for a missing invoice
    When I open its import result
    Then the missing invoice reference is explained and I am directed to ask an Owner or Admin
    And no Resume action is available to me

  @negative @security
  Scenario: Another Business's invoice cannot satisfy a note reference
    Given "INV-001" exists in Seller A's records but not Buyer B's records
    And I work in "Buyer B" as an "Owner"
    And an otherwise valid purchase note "CN-001" references that invoice number
    When I import that note with prior-clearance declared and its reference wait completes without a Buyer B invoice arriving
    Then the note is "Action required" listing "INV-001" as missing from the current Business
    And no seller-side record, private facts or cross-Business invoice link is disclosed

  # POSITIVE CASES: Accepted behavior, record integrity, and recovery

  @positive @smoke @recovery
  Scenario Outline: Accept a waiting note only after an explicit Resume
    Given I work in "<business>" as an "<role>"
    And valid note "CN-001" is Action required because its referenced invoices were previously missing
    And both referenced invoices are now accepted in that Business with matching parties and valid dates
    When I Resume the note's current result and revalidation finishes
    Then "CN-001" is "Accepted" with the complete set of invoice links

    Examples:
      | business | role  |
      | Seller A | Owner |
      | Seller A | Admin |
      | Buyer B  | Owner |
      | Buyer B  | Admin |

  @positive @recovery
  Scenario: Recognize a duplicate that arrived while a note was waiting
    Given one attempt for note "CN-001" waits in Action required for an invoice
    And that invoice is now accepted
    And another valid attempt has already accepted the compatible note identity
    When I Resume the waiting attempt's current result
    Then its new result is "Duplicate" and opens the existing note
    And exactly one accepted credit-note record exists for that identity

  @positive @concurrency
  Scenario: Repeated Resume actions do not repeat acceptance work
    Given note "CN-001" has an Action required result whose causes are repaired
    When two authorized actions Resume that same result before processing concludes
    Then both actions lead to the same current attempt rather than new note attempts
    And the final result links exactly one accepted note with one complete reference set

  @positive @summary
  Scenario: Resume makes a finished submission unfinished until the new result arrives
    Given a submission shows Processing finished with accepted siblings and an actionable note
    And the note's missing invoices are now accepted
    And the test environment holds note revalidation in Processing until released
    When I Resume that note
    Then the note shows "Processing" and the submission no longer shows "Processing finished"
    And accepted siblings keep their results while the note is checked again
