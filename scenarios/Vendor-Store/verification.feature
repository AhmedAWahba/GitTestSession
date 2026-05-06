Feature: User Account Verification
  As an approved buyer
  I want to see my account status updated
  So that I can access verified-only features and products

  Background:
    Given the vendor store is open at "https://store.development.qawafel.dev/hint"

  @e2e @verification
  Scenario: Verified user logs in and confirms account state
    Given a shop "Test Bakery" has been approved by the admin
    When the user logs in with their mobile number and OTP
    Then the user is redirected to the vendor store as a logged-in user
    And the account verification status is no longer showing an unverified ribbon
    And the user account reflects a verified state
