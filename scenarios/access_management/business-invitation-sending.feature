@access-management @business-invitation @sending
Feature: Sending a Business Invitation
  As a verified Qawafel business owner
  I want to invite users to my business
  So that eligible users can receive business access

  Background:
    Given the user is logged in as a verified business owner
    And the user is on the "User Management" page

  @sending @ui @positive
  Scenario: Invitation form shows only email and role fields
    When the user clicks "Invite user"
    Then the "Email address" field should be visible
    And the role selector should be visible
    And no name field should be visible
    And no mobile number field should be visible

  @sending @authorization @negative
  Scenario: Member cannot access the invitation flow
    Given the user is logged in as a Business User:Member
    When the user opens Settings
    Then the "User Management" entry should not be visible
    And the user should not be able to open the invitation form by direct navigation

  @sending @authorization @positive @smoke
  Scenario: Owner can invite an existing user by email
    Given an existing Qawafel user has email "member@business.com"
    When the user clicks "Invite user"
    And the user enters "member@business.com" in the "Email address" field
    And the user selects the "Member" role
    And the user clicks "Send invitation"
    Then a pending business-access invitation should be created for "member@business.com"
    And an invitation email should be sent to "member@business.com"
    And the invitation should be associated with the current business only

  @sending @authorization @positive @smoke
  Scenario: Owner can invite a person who does not have a Qawafel account
    Given no Qawafel user has email "new.user@business.com"
    When the user clicks "Invite user"
    And the user enters "new.user@business.com" in the "Email address" field
    And the user selects the "Admin" role
    And the user clicks "Send invitation"
    Then an invitation email with a business-linked account-creation path should be sent
    And the invitation should be recorded as "Pending"
    And no business access should be active for "new.user@business.com"

  @sending @validation @negative
  Scenario Outline: Invitation is blocked when the email or role is invalid
    When the user clicks "Invite user"
    And the user enters "<email>" in the "Email address" field
    And the user selects the "<role>" role
    And the user clicks "Send invitation"
    Then the invitation should not be created
    And an inline validation error should be displayed

    Examples:
      | email              | role   | message              |
      | invalid-email      | Member | invalid email format |
      | owner@business.com | Admin  | own email address    |
      | member@business.com|        | no role selected     |

  @sending @authorization @negative
  Scenario: Owner cannot offer the Owner role
    When the user clicks "Invite user"
    Then the role selector should contain "Admin"
    And the role selector should contain "Member"
    And the role selector should not contain "Owner"

  @sending @eligibility @negative
  Scenario: Staff account cannot be invited
    Given the email belongs to a Qawafel staff account
    When the user clicks "Invite user"
    And the user enters the staff email in the "Email address" field
    And the user selects the "Member" role
    And the user clicks "Send invitation"
    Then the invitation should not be created
    And an eligibility error should be displayed
    And the error should not disclose why the address is not eligible

  @sending @duplicate @negative
  Scenario: Existing pending invitation cannot be duplicated
    Given a pending invitation exists for "member@business.com"
    When the user invites "member@business.com" again
    Then the invitation should not be duplicated
    And an inline message should link to the existing invitation

  @sending @duplicate @negative
  Scenario: Existing active member cannot be invited again
    Given an active member exists with email "member@business.com"
    When the user invites "member@business.com" again
    Then the invitation should not be created
    And an inline message should link to the existing member

  @sending @email @positive
  Scenario: Invitation email identifies the inviting business
    Given a pending invitation is created for "new.user@business.com"
    When the invitation email is delivered
    Then the email should identify the inviting business
    And the email should identify the sender
    And the email should contain a link to continue
    And the email should not state the offered role
    And the Arabic content should appear above the English content

  @sending @lifecycle @positive
  Scenario: Resending a pending invitation sends a fresh email
    Given a pending invitation exists for "new.user@business.com"
    When the user clicks "Resend invitation"
    Then a fresh invitation email should be sent
    And the invitation status should remain "Pending"
    And the expiry period should restart from the resend time

  @sending @lifecycle @negative
  Scenario: Resending is blocked during the waiting period
    Given a pending invitation for "new.user@business.com" was sent within the resend waiting period
    When the user clicks "Resend invitation"
    Then no new invitation email should be sent
    And the resend action should explain when it can be used again
    And the message should not disclose the recipient account status

  @sending @lifecycle @negative
  Scenario: Resending is blocked after the maximum resend count
    Given a pending invitation for "new.user@business.com" has reached the maximum resend count
    When the user clicks "Resend invitation"
    Then no new invitation email should be sent
    And the resend action should explain that the maximum has been reached

  @sending @lifecycle @positive
  Scenario: Changing a pending invitation role does not send a new email
    Given a pending invitation for "new.user@business.com" offers the "Member" role
    When the user changes the offered role to "Admin"
    Then the invitation should show the offered role as "Admin"
    And no new invitation email should be sent
    And the role in force when the invitation activates should be "Admin"

  @sending @lifecycle @negative
  Scenario: Withdrawing a pending invitation prevents activation
    Given a pending invitation exists for "new.user@business.com"
    When the user clicks "Withdraw invitation"
    And the user confirms the withdrawal
    Then the invitation status should become "Revoked"
    And the invitation should not be able to activate

  @sending @lifecycle @negative
  Scenario: Pending invitation expires after seven days
    Given a pending invitation was last sent seven calendar days ago
    When the invitation expiry is processed
    Then the invitation status should become "Expired"
    And the invitation should not be able to activate

  @sending @positive
  Scenario: Invitation to an already verified user grants access immediately
    Given the invited email belongs to a user with a verified identity
    When the user sends an invitation with the "Member" role
    Then the user should appear in the "Members" tab with status "Active"
    And no pending invitation should be created
    And no invitation email should be sent

  @sending @positive
  Scenario: Invitation to an unverified user shows a pending outcome
    Given the invited email does not belong to a user with a verified identity
    When the user sends an invitation with the "Member" role
    Then the invitation should appear in the "Invitations" tab with status "Pending"
    And the sender should not be told whether the recipient has an APEX account

  # ──────────────── End-to-end happy path ────────────────

  @sending @happy-path @positive @smoke
  Scenario: Owner sends a valid invitation and the recipient appears as pending
    Given no Qawafel user has email "new.user@business.com"
    When the user clicks "Invite user"
    And the user enters "new.user@business.com" in the "Email address" field
    And the user selects the "Member" role
    And the user clicks "Send invitation"
    Then the invitation should appear in the "Invitations" tab
    And the invitation should show email "new.user@business.com"
    And the invitation should show role "Member"
    And the invitation should show status "Pending"
    And an invitation email should be sent to "new.user@business.com"
