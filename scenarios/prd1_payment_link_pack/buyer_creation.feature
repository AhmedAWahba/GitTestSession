@buyer-creation
Feature: Buyer Business Creation and Selection
  As a selling business user on the APEX platform
  I want to create buyer business records and select them during invoice creation
  So that I can efficiently manage buyers and generate invoices and payment links

  Background:
    Given I am on the APEX platform login page at "https://apex.development.qawafel.dev/login"
    And I log in with a valid selling business account

  # ──────────────── Creating Buyer Businesses ────────────────

  @buyer-creation @positive @smoke
  Scenario: Create a buyer business with the minimum required fields
    Given I navigate to the Buyer Business Management page
    When I create a buyer business with the following details:
      | Field         | Value                      |
      | Business Name | Al Ahmed Trading           |
      | Email         | accounts@alahmedtrading.example |
    Then a buyer business creation success message should be displayed
    And the buyer business "Al Ahmed Trading" should appear in the buyer listing
    And the buyer listing should show the email "accounts@alahmedtrading.example" for "Al Ahmed Trading"

  @buyer-creation @positive
  Scenario: Create a buyer business with all supported fields
    Given I navigate to the Buyer Business Management page
    When I create a buyer business with the following details:
      | Field             | Value                      |
      | Business Name     | Al Ahmed Wholesale        |
      | Email             | finance@alahmedwholesale.example |
      | CR/Unified Number | 4030201000                 |
      | Phone             | 0551234567                 |
      | Tax Number        | 310234567800003            |
      | Address           | Riyadh Business District   |
    Then a buyer business creation success message should be displayed
    And the buyer listing should show the buyer business details including:
      | Field             | Value                      |
      | Business Name     | Al Ahmed Wholesale        |
      | CR/Unified Number | 4030201000                 |
      | Email             | finance@alahmedwholesale.example |
      | Phone             | 0551234567                 |

  # ──────────────── Validating Buyer Business Creation ────────────────

  @buyer-creation @negative
  Scenario Outline: Creating a buyer business fails when required or formatted data is invalid
    Given I navigate to the Buyer Business Management page
    When I create a buyer business with the following details:
      | Field         | Value           |
      | Business Name | <business_name> |
      | Email         | <email>         |
    Then the buyer business should not be created
    And I should remain on the Buyer Business Management form
    And I should see an inline validation error on the "<field>" field
    And the buyer business "<list_value>" should not appear in the buyer listing

    Examples:
      | business_name        | email                                 | field         | list_value                         |
      |                      | operations@alnourtrading.example      | Business Name | operations@alnourtrading.example   |
      | Al Noor Supplies     |                                       | Email         | Al Noor Supplies                   |
      | Al Rawabi Trading    | invalid-email                         | Email         | Al Rawabi Trading                  |

  # ──────────────── Selecting Buyer Businesses in Invoice Creation ────────────────

  @buyer-creation @smoke
  Scenario: Existing buyer business is selectable from the invoice buyer dropdown
    Given I navigate to the Invoice Creation page
    And a buyer business exists with the following details:
      | Field         | Value                         |
      | Business Name | Al Rowad Industrial Supplies  |
      | Email         | procurement@alrowad.example   |
    When I open the buyer business dropdown
    Then the buyer business "Al Rowad Industrial Supplies" should be available for selection

  @buyer-creation
  Scenario: Search returns the matching buyer business in the invoice buyer dropdown
    Given I navigate to the Invoice Creation page
    And a buyer business exists with the following details:
      | Field         | Value                         |
      | Business Name | Al Rowad Industrial Supplies  |
      | Email         | procurement@alrowad.example   |
    When I open the buyer business dropdown
    And I search for "Al Rowad"
    Then the buyer business "Al Rowad Industrial Supplies" should be returned in the search results
