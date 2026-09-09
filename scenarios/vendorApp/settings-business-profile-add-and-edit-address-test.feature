@settings @st2 @business-profile @address-workflow
Feature: Settings business profile add and edit address workflow
  As an owner or admin
  I want to add and update the business national address as one section
  So that address changes are saved or discarded consistently

  Background:
    Given the user is signed in as "Owner"
    And the user opens the "Business profile" page from Settings

  # ──────────────── Negative scenarios ────────────────

  @address-workflow @negative
  Scenario: Cancel discards all section edits
    Given the business has an existing national address
    And the user opens national address edit mode
    When the user changes multiple address fields
    And the user clicks the section cancel action
    Then no changed address values should be saved
    And the original address values should remain visible

  @address-workflow @negative
  Scenario: Cancel while adding address keeps the empty-address state
    Given the business has no national address
    And the user opens the national address add form
    When the user enters one or more address fields
    And the user clicks the section cancel action
    Then no address values should be saved
    And an "Add national address" action should be visible

  # ──────────────── Validation scenarios ────────────────

  @address-workflow @validation
  Scenario: Add national address opens section-level save and cancel actions
    Given the business has no national address
    When the user clicks "Add national address"
    Then the national address section should open in add mode
    And a section save action should be visible
    And a section cancel action should be visible

  @address-workflow @validation
  Scenario: Editing national address starts with the currently saved values
    Given the business has an existing national address
    When the user opens national address edit mode
    Then the existing national address values should be pre-filled

  @address-workflow @validation
  Scenario: Saving address commits the section as one update
    Given the business has an existing national address
    When the user changes multiple address fields
    And the user clicks the section save action
    Then all changed address fields should be saved together

  # ──────────────── Positive scenarios ────────────────

  @address-workflow @positive
  Scenario: Empty address shows add action
    Given the business has no national address
    Then an "Add national address" action should be visible
    And no address values should be shown

  @address-workflow @positive
  Scenario: Existing address can be edited later
    Given the business has an existing national address
    When the user updates one or more address fields
    And the user clicks the section save action
    Then the updated address should be visible on reload

  # ──────────────── Happy path scenarios ────────────────

  @address-workflow @happy-path @positive
  Scenario: Add national address and save as one section
    Given the business has no national address
    When the user adds national address values
    And the user clicks the section save action
    Then all entered address values should be saved together
