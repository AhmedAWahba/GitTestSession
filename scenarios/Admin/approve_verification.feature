Feature: Admin Verification Approval
  As a Qawafel Admin
  I want to review and approve shop verification requests
  So that retailers can begin trading on the platform

  Background:
    Given the Qawafel admin is logged in at "https://admin.development.qawafel.dev"

  @e2e @admin @approval
  Scenario: Admin approves a pending shop registration
    Given a shop "Test Bakery" exists with "Pending" status in the verification center
    When the admin reviews the legal documents for "Test Bakery"
    And the admin approves the "Verify Retailer" request
    Then a success message "Verification Accepted Successfully" is displayed
    And the shop status for "Test Bakery" is updated to "Accepted"
    And the user can then perform [verification.feature](verification.feature)
