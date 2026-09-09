@settings @st4 @users-and-roles-card
Feature: Settings users and roles card
  As a business owner or admin
  I want to open users and roles from Settings
  So that I can manage member and invitation access

  Background:
    Given the user is signed in
    And the user opens the "Settings" page

  # ──────────────── Negative scenarios ────────────────

  @users-and-roles-card @negative @role-member
  Scenario: Member cannot see the Users and roles card
    Given the user role is "Member"
    When the user opens Settings
    Then the "Users and roles" card should not be visible

  @users-and-roles-card @negative @authorization @role-member
  Scenario: Member cannot open Users and roles by direct route
    Given the user is signed in as "Member"
    When the user navigates directly to "/settings/users"
    Then access should be denied
    And the "User Management" page should not be visible

  # ──────────────── Positive scenarios ────────────────

  @users-and-roles-card @positive @smoke @role-owner @role-admin
  Scenario Outline: Owner and Admin can open Users and roles from Settings
    Given the user role is "<Role>"
    When the user clicks the "Users and roles" card
    Then the "User Management" page should open
    And the "Members" tab should be visible
    And the "Invitations" tab should be visible

    Examples:
      | Role  |
      | Owner |
      | Admin |
