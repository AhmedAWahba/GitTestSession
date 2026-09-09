@settings @set1 @linear-id-287 @role-aware-cards
Feature: SET-1 Settings role-aware cards
  As an authenticated Apex user
  I want Settings cards to follow role and business context rules
  So that business and personal settings access is enforced correctly

  Background:
    Given the user is signed in
    And the user opens the "Settings" page

  # Note: Scenarios specify the role executing the test unless marked as mixed-role.

  # ──────────────── Validation scenarios ────────────────

  @role-aware-cards @validation @navigation
  Scenario Outline: Settings is reachable from main navigation for every signed-in role
    Given the user is signed in as "<Role>"
    When the user opens Settings from the main navigation
    Then the "Settings" page should open

    Examples:
      | Role   |
      | Owner  |
      | Admin  |
      | Member |

  @role-aware-cards @validation @role-owner @role-admin
  Scenario: Owner and Admin see the same card set and actions in the same business
    Given the active business is "Al Nakheel"
    When the user opens Settings as "Owner"
    And the user opens Settings as "Admin" for the same business
    Then both roles should see the same settings cards
    And both roles should have the same available actions on each card

  @role-aware-cards @validation @navigation
  Scenario Outline: Every visible card opens its destination page
    Given the signed-in role is "<Role>"
    And the "<Card>" card is visible
    When the user clicks the "<Card>" card
    Then the "<Destination>" page should open

    Examples:
      | Role   | Card             | Destination      |
      | Owner  | Business profile | Business profile |
      | Owner  | Bank account     | Bank account     |
      | Owner  | Users and roles  | Users and roles  |
      | Owner  | Profile          | Profile          |
      | Admin  | Business profile | Business profile |
      | Admin  | Bank account     | Bank account     |
      | Admin  | Users and roles  | Users and roles  |
      | Admin  | Profile          | Profile          |
      | Member | Profile          | Profile          |

  @role-aware-cards @validation @ui
  Scenario Outline: Every visible Settings card shows a title and short description
    Given the signed-in role is "<Role>"
    When the user opens the "Settings" page
    Then the "<Card>" card should show a title
    And the "<Card>" card should show a short description

    Examples:
      | Role   | Card             |
      | Owner  | Business profile |
      | Owner  | Bank account     |
      | Owner  | Users and roles  |
      | Owner  | Profile          |
      | Admin  | Business profile |
      | Admin  | Bank account     |
      | Admin  | Users and roles  |
      | Admin  | Profile          |
      | Member | Profile          |

  @role-aware-cards @validation @ui
  Scenario: Settings uses the Users and roles label and not Team Access
    Given the user is signed in as "Owner"
    When the user opens the "Settings" page
    Then the "Users and roles" card label should be visible
    And the "Team Access" label should not be visible

  @role-aware-cards @validation @ui @role-owner @role-admin
  Scenario Outline: Owner and Admin landing screen shows the expected four cards
    Given the user is signed in as "<Role>"
    When the user opens the "Settings" page
    Then the "Business profile" card should be visible
    And the "Bank account" card should be visible
    And the "Users and roles" card should be visible
    And the "Profile" card should be visible
    And exactly four settings cards should be visible

    Examples:
      | Role  |
      | Owner |
      | Admin |

  # ──────────────── Positive scenarios ────────────────

  @role-aware-cards @positive @role-member @smoke
  Scenario: Member sees only the Profile card
    Given the user role is "Member"
    When the user opens Settings
    Then only the "Profile" card should be visible
    And the "Business profile" card should not be visible
    And the "Bank account" card should not be visible
    And the "Users and roles" card should not be visible
    And no disabled or empty business settings section should be visible

  @role-aware-cards @positive @switching
  Scenario: Switching business updates business cards without leaving Settings
    Given the user has access to business "Al Nakheel"
    And the user has access to business "Al Rowad"
    And the user is currently working in "Al Nakheel"
    When the user switches active business to "Al Rowad"
    Then the business settings cards should reflect "Al Rowad"
    And the user should remain on Settings
    And the user should remain signed in

  @role-aware-cards @positive @switching
  Scenario: Business-specific cards appear and disappear when switching businesses
    Given the user has access to business "Al Nakheel"
    And the user has access to business "Al Rowad"
    And the "Bank account" card is available in "Al Nakheel"
    And the "Bank account" card is not available in "Al Rowad"
    When the user switches active business to "Al Rowad"
    Then the "Bank account" card should not be visible
    When the user switches active business to "Al Nakheel"
    Then the "Bank account" card should be visible

  @role-aware-cards @positive @switching @profile
  Scenario: Profile remains unchanged when switching business
    Given the signed-in user has access to more than one business
    And the user opens the "Profile" card
    And the profile details are captured
    When the user switches active business
    Then the profile details should remain unchanged
    And the "Profile" card should appear once only

  @role-aware-cards @positive @role-member @switching
  Scenario: Member landing after switching business still shows profile only
    Given the user is signed in as "Member"
    And the user has access to more than one business
    And the user is currently working in "Al Nakheel"
    When the user switches active business to "Al Rowad"
    And the user opens the "Settings" page
    Then only the "Profile" card should be visible
    And no business settings card should be visible
