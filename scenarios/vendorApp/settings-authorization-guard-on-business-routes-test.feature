@settings @set11 @linear-id-288 @authorization-guard
Feature: SET-11 Settings authorization guard on business routes
  As an authenticated user
  I want route-level authorization on business settings pages
  So that hidden UI cards cannot be bypassed by direct URL access

  Background:
    Given business settings route protection is enabled

  # ──────────────── Negative scenarios ────────────────

  @authorization-guard @negative @security @role-member
  Scenario Outline: Member is blocked from direct business settings routes
    Given the user is signed in as "Member"
    When the user navigates directly to "<Route>"
    Then access to "<Route>" should be denied
    And no protected page content should be visible

    Examples:
      | Route             |
      | /settings/business-profile |
      | /settings/bank-account     |
      | /settings/users            |

  @authorization-guard @negative @security
  Scenario Outline: Denied routes do not leak business information during load or error states
    Given the user is signed in as "Member"
    When the user navigates directly to "<Route>"
    Then no business legal name should be visible
    And no business UNN should be visible
    And no business address or bank data should be visible

    Examples:
      | Route                     |
      | /settings/business-profile|
      | /settings/bank-account    |
      | /settings/users           |

  # ──────────────── Positive scenarios ────────────────

  @authorization-guard @positive @security @role-owner @role-admin
  Scenario Outline: Owner and Admin can access business settings routes
    Given the user is signed in as "<Role>"
    When the user navigates directly to "<Route>"
    Then the "<ExpectedPage>" page should open

    Examples:
      | Role  | Route                     | ExpectedPage      |
      | Owner | /settings/business-profile| Business profile  |
      | Owner | /settings/bank-account    | Bank account      |
      | Owner | /settings/users           | Users and roles   |
      | Admin | /settings/business-profile| Business profile  |
      | Admin | /settings/bank-account    | Bank account      |
      | Admin | /settings/users           | Users and roles   |

  @authorization-guard @positive @profile-route
  Scenario Outline: Profile route is reachable by all roles
    Given the user is signed in as "<Role>"
    When the user navigates directly to "/settings/profile"
    Then the "Profile" page should open

    Examples:
      | Role   |
      | Owner  |
      | Admin  |
      | Member |
