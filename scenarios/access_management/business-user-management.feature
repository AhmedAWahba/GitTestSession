@access-management @user-management
Feature: Business User List and Access Management
  As a verified Apex business owner
  I want to view and manage business users
  So that membership and access remain accurate

  Background:
    Given the user is logged in as a verified business owner
    And the user is on the "User Management" page

  # Note: Scenarios specify the role executing the test unless noted as "Any role"
  # Owner: Only Owner can execute (has all permissions)
  # Admin: Admin or Owner can execute (similar permissions)
  # Member: Member, Admin, or Owner (if applicable)
  # Any role: Behavior is the same regardless of role

  # ──────────────── Negative scenarios ────────────────

  @listing @authorization @negative @role-member
  Scenario: Member cannot reach User Management
    Given the user is logged in as a Business User:Member
    When the user opens Settings
    Then the "User Management" entry should not be visible
    And the user should not be able to reach User Management by direct navigation

  @listing @actions @negative @role-owner @role-admin
  Scenario: Owner entry has no available actions
    Given the Owner is visible in the "Members" tab
    When the user opens the Owner row actions
    Then no "Change role" action should be available
    And no "Remove" action should be available

  @listing @actions @negative @role-admin @role-owner
  Scenario: A user cannot change or remove their own entry
    Given the signed-in user is an active Admin
    When the user opens their own row actions
    Then no "Change role" action should be available
    And no "Remove" action should be available

  @listing @search @negative @role-owner @role-admin
  Scenario: Search shows a no-results state when there are no matches
    Given the Invitations tab contains at least one invitation
    When the user enters "NO_MATCH_ABC" in the Invitations search input
    Then the no-results state should be displayed
    And the first-use empty state should not be displayed

  @listing @authorization @negative @role-member
  Scenario: Member cannot reach the Members or Invitations tabs directly
    Given the user is logged in as a Business User:Member
    When the user opens the Members tab by direct navigation
    Then the Members tab should not be displayed
    When the user opens the Invitations tab by direct navigation
    Then the Invitations tab should not be displayed

  @listing @state-change @negative @role-owner @role-admin
  Scenario: Members tab excludes invitation statuses
    Given the current business has Active and Removed members
    And the current business has Pending, Expired, and Revoked invitations
    When the user opens the "Members" tab
    Then no row should show status "Pending"
    And no row should show status "Expired"
    And no row should show status "Revoked"

  @listing @state-change @negative @role-owner @role-admin
  Scenario: Invitations tab excludes member statuses
    Given the current business has Active and Removed members
    And the current business has Pending, Expired, and Revoked invitations
    When the user opens the "Invitations" tab
    Then no row should show status "Active"
    And no row should show status "Removed"

  @listing @empty-state @negative @role-owner @role-admin
  Scenario: Members search shows a no-results state when there are no matches
    Given the Members tab contains at least one member
    When the user enters "NO_MATCH_ABC" in the Members search input
    Then the Members no-results state should be displayed
    And the Members first-use empty state should not be displayed

  @listing @filter @negative @role-owner @role-admin
  Scenario: Members status filter excludes active members from the Removed view
    Given the Members tab contains Active and Removed members
    When the user selects "Removed" in the Members status filter
    Then all visible rows should show status "Removed"
    And no visible row should show status "Active"

  @listing @filter @negative @role-owner @role-admin
  Scenario: Invitations status filter excludes pending invitations from the Expired view
    Given the Invitations tab contains Pending and Expired invitations
    When the user selects "Expired" in the Invitations status filter
    Then all visible rows should show status "Expired"
    And no visible row should show status "Pending"

  @listing @actions @negative @role-owner @role-admin
  Scenario: Removed member actions do not include role change or remove
    Given a Removed member is visible in the "Members" tab
    When the user opens the Removed member row actions
    Then the menu should contain "Invite again"
    And the menu should not contain "Update role"
    And the menu should not contain "Remove user"

  @listing @actions @negative @role-owner @role-admin
  Scenario: Pending invitation actions do not include invite again
    Given a Pending invitation is visible in the "Invitations" tab
    When the user opens the Pending invitation row actions
    Then the menu should contain "Resend invitation"
    And the menu should contain "Update role"
    And the menu should contain "Withdraw invitation"
    And the menu should not contain "Invite again"

  @listing @actions @negative @role-owner @role-admin
  Scenario: Expired invitation actions do not include pending-only actions
    Given an Expired invitation is visible in the "Invitations" tab
    When the user opens the Expired invitation row actions
    Then the menu should contain "Invite again"
    And the menu should not contain "Resend invitation"
    And the menu should not contain "Update role"
    And the menu should not contain "Withdraw invitation"

  @listing @role-change @negative @role-owner @role-admin
  Scenario: Cancelling an active member role change keeps the original role
    Given an active Member named "Alex User" is visible in the "Members" tab
    When the user opens the row actions for "Alex User"
    And the user clicks "Update role"
    And the user cancels the role change confirmation
    Then "Alex User" should remain a "Member"
    And no role-change email should be sent

  @listing @removal @negative @role-owner @role-admin
  Scenario: Cancelling member removal keeps the member active
    Given an active Member named "Alex User" is visible in the "Members" tab
    When the user opens the row actions for "Alex User"
    And the user clicks "Remove user"
    And the user cancels the removal confirmation
    Then "Alex User" should remain visible with status "Active"
    And the member should retain access to the current business

  # ──────────────── Validation scenarios ────────────────

  @listing @search @filter @positive @role-owner @role-admin
  Scenario: Each tab preserves its own search and filter choices
    Given the user has entered search text and selected filters in the "Members" tab
    And the user has entered different search text and selected different filters in the "Invitations" tab
    When the user returns to the "Members" tab
    Then the Members search text and filters should be unchanged
    When the user returns to the "Invitations" tab
    Then the Invitations search text and filters should be unchanged

  @listing @ui @positive @role-owner @role-admin
  Scenario: User Management opens the Invitations tab from a direct link
    When the user opens a direct link to the "Invitations" tab
    Then the "Invitations" tab should be selected
    And the "Members" tab should not be selected

  @listing @ui @positive @role-owner @role-admin
  Scenario: Members entries show the required member details
    Given an active Member named "Alex User" has email "alex@business.com"
    When the user opens the "Members" tab
    Then the member's verified name should be visible
    And the member's email address should be visible
    And the member's role should be visible
    And the member's status should be visible
    And the available actions should be visible

  @listing @ui @positive @role-owner @role-admin
  Scenario: Invitations entries show the required invitation details
    Given a pending invitation exists for "new.user@business.com"
    And the invitation has an offered role, sender, last-sent date, and expiry date
    When the user opens the "Invitations" tab
    Then the invited email address should be visible
    And the offered role should be visible
    And the invitation status should be visible
    And the sender should be visible
    And the last-sent date should be visible
    And the expiry date should be visible
    And the available actions should be visible

  # ──────────────── Positive listing and navigation scenarios ────────────────

  @listing @ui @positive @smoke @role-owner @role-admin
  Scenario: User Management opens on the Members tab
    When the user opens the "User Management" page from Settings
    Then the "Members" tab should be selected
    And the "Invitations" tab should be visible

  @listing @ui @positive @role-owner @role-admin
  Scenario: Members tab shows active and removed members
    Given the current business has an active Admin, an active Member, and a removed member
    When the user opens the "Members" tab
    Then all three entries should be visible
    And each entry should show a verified name
    And each entry should show an email address
    And each entry should show a role
    And each entry should show either "Active" or "Removed" status

  @listing @ui @positive @role-owner @role-admin
  Scenario: Invitations tab shows pending, expired, and revoked invitations
    Given the current business has pending, expired, revoked, and activated invitations
    When the user opens the "Invitations" tab
    Then the pending invitation should be visible
    And the expired invitation should be visible
    And the revoked invitation should be visible
    And the activated invitation should not be visible in the "Invitations" tab

  @listing @search @positive @role-owner @role-admin
  Scenario: Members search matches verified name or email
    Given the Members tab contains a member named "Alex User" with email "alex@business.com"
    When the user enters "Alex User" in the Members search input
    Then the member should be displayed
    When the user enters "alex@business.com" in the Members search input
    Then the member should be displayed

  @listing @search @positive @role-owner @role-admin
  Scenario: Invitations search matches invited email or sender name
    Given the Invitations tab contains an invitation for "new.user@business.com" sent by "Alex User"
    When the user enters "new.user@business.com" in the Invitations search input
    Then the invitation should be displayed
    When the user enters "Alex User" in the Invitations search input
    Then the invitation should be displayed

  @listing @filter @positive @role-owner @role-admin
  Scenario Outline: Members filter shows only matching role or status
    Given the Members tab contains entries with different roles and statuses
    When the user selects "<filter>" in the Members filter
    Then only entries matching "<filter>" should be displayed

    Examples:
      | filter  |
      | Owner   |
      | Admin   |
      | Member  |
      | Active  |
      | Removed |

  @listing @filter @positive @role-owner @role-admin
  Scenario Outline: Invitations filter shows only matching role or status
    Given the Invitations tab contains entries with different offered roles and statuses
    When the user selects "<filter>" in the Invitations filter
    Then only entries matching "<filter>" should be displayed

    Examples:
      | filter  |
      | Admin   |
      | Member  |
      | Pending |
      | Expired |
      | Revoked |

  @listing @pagination @positive @role-owner @role-admin
  Scenario: Members and Invitations tabs paginate long lists
    Given both tabs contain more entries than fit on one page
    When the user opens the "Members" tab
    Then page navigation should be available
    When the user opens the "Invitations" tab
    Then page navigation should be available

  @listing @empty-state @positive @role-owner @role-admin
  Scenario: Empty Invitations tab shows its first-use state
    Given the current business has no invitations
    When the user opens the "Invitations" tab
    Then the first-use empty state should be displayed
    And the empty state should explain what to do next

  # ──────────────── Positive member actions ────────────────

  @listing @actions @role-change @positive @smoke @role-owner
  Scenario Outline: Owner changes an active member or Admin role
    Given an active "<CurrentRole>" named "Alex User" is visible in the "Members" tab
    When the user opens the row actions for "Alex User"
    And the user clicks "Change role"
    And the user selects "<NewRole>"
    Then a role-change confirmation should be displayed
    When the user confirms the role change
    Then "Alex User" should show role "<NewRole>" immediately
    And a role-change email should be sent to "Alex User"
    And the user should not need to approve the change

    Examples:
      | CurrentRole | NewRole |
      | Member      | Admin   |
      | Admin       | Member  |

  @listing @actions @role-change @positive @role-owner @role-admin
  Scenario: Role change updates the affected session without sign-out
    Given an active Admin is signed in to the current business
    When the user's role is changed to "Member" from another session
    Then the affected session should reflect "Member" permissions
    And actions unavailable to Members should no longer be executable
    And the affected user should remain signed in

  @listing @actions @role-change @positive @role-owner
  Scenario: Changing an Admin's role to Member does not withdraw their pending invitations
    Given an active Admin named "Alex User" has pending invitations for the current business
    When the Admin is changed to the "Member" role
    Then the pending invitations should remain in the "Invitations" tab
    And the invitations should remain able to activate

  # ──────────────── Positive removal scenarios ────────────────

  @listing @actions @removal @positive @smoke @role-owner
  Scenario Outline: Owner removes an active member or Admin
    Given an active "<Role>" named "Alex User" is visible in the "Members" tab
    When the user opens the row actions for "Alex User"
    And the user clicks "Remove"
    Then a removal confirmation should be displayed
    When the user confirms the removal
    Then "Alex User" should no longer have access to the current business
    And any open session for the current business should stop accepting actions
    And "Alex User" should show status "Removed"

    Examples:
      | Role   |
      | Member |
      | Admin  |

  @listing @actions @removal @positive @role-owner
  Scenario: Removing a Member or Admin does not affect access to another business
    Given a user with any role has access to the current business and another business
    When the user removes that person from the current business
    Then the other business should remain available to that person
    And the current business should no longer be available to that person

  @listing @role-change @negative @role-owner
  Scenario: Owner cannot change an active member role to Owner
    Given an active Member is visible in the "Members" tab
    When the user opens the role-change control for that member
    Then the role selector should contain "Admin" and "Member"
    And the role selector should not contain "Owner"

  @listing @role-change @positive @role-owner
  Scenario: Role change in one business does not affect another business
    Given the same user has different roles in the current business and another business
    When the user changes that user's role in the current business
    Then the user's role in the other business should remain unchanged
    And the user's access to the other business should remain unchanged

  @listing @removal @positive @role-owner
  Scenario: Removing a member routes their active session to a valid destination
    Given a member has the current business open
    And the member also has another available business or another valid destination
    When the user removes that member from the current business
    Then the current business should stop accepting actions for that member
    And the member should be routed to another available business, business selection, or business registration

  @listing @actions @removal @positive @role-owner
  Scenario Outline: Removing a Member or Admin revokes their pending invitations
    Given an active "<Role>" has pending invitations sent for the current business
    When the user removes that "<Role>"
    And the user confirms the removal
    Then those invitations should show status "Revoked"
    And those invitations should no longer activate

    Examples:
      | Role   |
      | Member |
      | Admin  |

  @listing @actions @removal @positive @role-owner
  Scenario Outline: Removing a Member or Admin preserves drafts and submitted document attribution
    Given the "<Role>" has contributed to a draft invoice or credit note
    And the "<Role>" has submitted an invoice or credit note
    When the user removes that "<Role>"
    Then the draft should remain available to users with business access
    And the submitted document should remain unchanged
    And the "<Role>"'s name should remain on the submitted document

    Examples:
      | Role   |
      | Member |
      | Admin  |

  # ──────────────── Positive invite-again and state-change scenarios ────────────────

  @listing @invite-again @positive @role-owner
  Scenario: Owner invites a removed member again
    Given a removed member has a verified identity
    When the user clicks "Invite again" for that member
    Then the member should return to the "Members" tab with status "Active"
    And no second member entry should be created
    And no pending invitation should be created
    And no invitation email should be sent

  @listing @invite-again @positive @role-owner
  Scenario Outline: Owner invites again after an expired or revoked invitation
    Given an invitation for "new.user@business.com" has status "<status>"
    When the user clicks "Invite again"
    Then the invitation should show status "Pending"
    And the invitation should have a fresh seven-day activation period
    And no second current entry should be created

    Examples:
      | status  |
      | Expired |
      | Revoked |

  @listing @state-change @positive @role-owner @role-admin
  Scenario: User Management reflects an invitation activation while the list is open
    Given a pending invitation is visible in the "Invitations" tab
    When the invitation activates
    Then the invitation should no longer be visible in the "Invitations" tab
    And the user should appear in the "Members" tab with status "Active"

  @listing @pagination @positive @role-owner @role-admin
  Scenario: Pagination applies after filtering a User Management list
    Given the current business has more matching entries than fit on one page
    When the user applies a role or status filter
    Then page navigation should apply to the filtered entries
    And entries from the unfiltered result should not appear on the current page

  @listing @state-change @positive @role-owner @role-admin
  Scenario: User Management reflects a removed member in the Members tab
    Given an active Member is visible in the "Members" tab
    When the member is removed from the current business
    Then the member should remain in the "Members" tab
    And the member should show status "Removed"
    And the member should not appear as Active

  # ──────────────── End-to-end happy path ────────────────

  @listing @happy-path @positive @smoke @role-owner
  Scenario: Owner reviews an active user in the Members list
    Given an active Member named "Alex User" has email "alex@business.com"
    When the user opens the "Members" tab
    And the user searches for "alex@business.com" in the Members search input
    Then the member named "Alex User" should be displayed
    And the member should show role "Member"
    And the member should show status "Active"
    And the member row actions should include "Change role" and "Remove"
