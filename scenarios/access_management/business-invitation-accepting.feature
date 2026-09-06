@access-management @business-invitation @accepting
Feature: Accepting a Business Invitation
  As an invited Apex user
  I want to complete the required activation steps for an invitation
  So that I can access the business that invited me

  Background:
    Given the user is on the Qawafel invitation account flow

  @accepting @design-alignment @negative
  Scenario: Invitation flow does not show an Accept or Reject decision
    When the invitation flow loads
    Then no "Accept invitation" action should be displayed
    And no "Reject invitation" action should be displayed
    And the user should be directed to sign in or create an account

  @accepting @activation @negative
  Scenario: Invitation flow does not start business verification
    Given a pending invitation exists for "new.user@business.com"
    When the invited user follows the invitation account-creation path
    Then no business identifier should be requested
    And no business verification should be started
    And no ownership check should be performed against the invited user

  @accepting @activation @negative
  Scenario: Invitation for one email cannot activate a different signed-in account
    Given a pending invitation exists for "member@business.com"
    And the recipient is signed in with "different.user@business.com"
    When the recipient continues from the invitation link
    Then access should not be added to "different.user@business.com"
    And the invitation should remain pending for "member@business.com"
    And the invited email address should be shown

  @accepting @activation @negative
  Scenario: Expired invitation cannot activate after required steps finish
    Given an invitation for "new.user@business.com" has expired
    When the user completes the remaining required activation steps
    Then no Business User relationship should be activated for the invited business
    And the user should not be allowed to enter the invited business

  @accepting @activation @negative
  Scenario: Withdrawn invitation cannot activate after required steps finish
    Given an invitation for "new.user@business.com" has been withdrawn
    When the user completes the remaining required activation steps
    Then no Business User relationship should be activated for the invited business
    And the user should not be allowed to enter the invited business

  @accepting @activation @negative
  Scenario: Activation and invitation expiry at the same time produce no partial access
    Given a pending invitation is reaching its expiry boundary
    When identity verification completion and invitation expiry occur at the same time
    Then the invitation should produce one final outcome
    And the user should either have complete access or no access to that business
    And no partial Business User relationship should remain

  @accepting @activation @negative
  Scenario: Activation and invitation withdrawal at the same time produce no partial access
    Given a pending invitation exists for "new.user@business.com"
    When identity verification completion and invitation withdrawal occur at the same time
    Then the invitation should produce one final outcome
    And the user should either have complete access or no access to that business
    And no partial Business User relationship should remain

  @accepting @routing @validation
  Scenario Outline: Personally verified user without active access sees the Add your business screen
    Given the authenticated recipient has completed personal identity verification
    And the recipient has no accessible business destination
    And the recipient's invitation history is "<InvitationHistory>"
    When post-verification invitation routing completes
    Then the "Add your business" screen should be displayed
    And the screen should not name a business or sender
    And the screen should not reveal an invitation outcome
    And an "Add your business" action should be available

    Examples:
      | InvitationHistory |
      | Absent            |
      | Pending           |
      | Expired           |
      | Revoked           |

  @accepting @routing @validation
  Scenario: Recipient whose invitation is revoked after account creation sees the Add your business screen
    Given a pending invitation exists for "new.user@business.com"
    And the invited user has created an account through the invitation path
    And the invitation is revoked before personal identity verification completes
    When the invited user completes personal identity verification
    Then no Active membership should exist for the invited business
    And the "Add your business" screen should be displayed
    And the screen should not reveal that the invitation was revoked

  @accepting @routing @negative
  Scenario: Business routing takes precedence over the Add your business screen
    Given at least one invitation activates for the user
    And another invitation for the user has expired or been withdrawn
    When the activation flow completes
    Then the user should be routed to an available business or business selection
    And the "Add your business" screen should not be displayed

  # ──────────────── Validation scenarios ────────────────

  @accepting @activation @validation
  Scenario: New invited user account creation does not activate access
    Given a pending invitation exists for "new.user@business.com"
    When the invited user creates an account through the business-linked path
    Then the account should use email "new.user@business.com"
    And the invited email address should not be editable
    And business access should remain pending
    And the user should not be allowed to enter the invited business

  @accepting @activation @validation
  Scenario: Existing verified user is not asked to repeat identity verification
    Given the invited email belongs to a user with a verified identity
    When the user follows the invitation sign-in path
    Then the user should not be asked to complete identity verification again
    And the pending business access should be eligible for activation

  @accepting @routing @validation
  Scenario: Invitation link opens account creation for an unknown email
    Given no Qawafel user has email "new.user@business.com"
    When the recipient opens the invitation link
    Then the account-creation flow should be displayed
    And the invited email address should be carried into the flow
    And the recipient should not be asked to choose the destination

  @accepting @routing @validation
  Scenario: Invitation link opens sign-in for an existing email
    Given a Qawafel user exists with email "member@business.com"
    When the recipient opens the invitation link
    Then the sign-in flow should be displayed
    And the recipient should not be shown an account-creation flow first

  @accepting @verification @validation
  Scenario: Invited user sees the personal details verification step
    Given a new account has been created through the invitation path
    When the recipient continues the invitation flow
    Then the personal details step should be displayed
    And the recipient should not be asked for business verification details

  # ──────────────── Positive scenarios ────────────────

  @accepting @activation @positive @smoke
  Scenario: New invited user gains access after personal details and mobile verification
    Given a pending invitation exists for "new.user@business.com"
    And the invited user has created an account through the business-linked path
    When the invited user completes the required personal details
    And the invited user completes mobile verification
    Then the business access should become active
    And a Business User relationship should exist before business entry is allowed
    And the invited user should enter the invited business

  @accepting @activation @positive
  Scenario: Multiple valid invitations activate for multiple businesses
    Given valid pending invitations exist for the same verified email address
    And each invitation belongs to a different business
    When the user completes the required activation steps
    Then each valid invitation should become active
    And the user should have access to each invited business
    And the business selection screen should be displayed

  @accepting @activation @positive
  Scenario Outline: Activation applies the current offered role
    Given a pending invitation exists for "new.user@business.com" with role "<OriginalRole>"
    And the invitation role is changed to "<CurrentRole>" before personal identity verification completes
    When the invited user completes personal identity verification
    Then one Active membership should be created or restored for the invited business
    And the membership role should be "<CurrentRole>"

    Examples:
      | OriginalRole | CurrentRole |
      | Member       | Admin       |
      | Admin        | Member      |

  @accepting @activation @positive
  Scenario: Repeated or competing activation attempts create one final membership
    Given a valid pending invitation exists for "new.user@business.com"
    And the invited user has completed personal identity verification
    When repeated or competing activation attempts are processed for the invitation
    Then exactly one Active membership should exist for the invited business
    And the invitation should produce one final outcome

  @accepting @routing @positive
  Scenario: User with one active business is routed to that business
    Given the user has access to exactly one business after invitation activation
    When the activation flow completes
    Then the user should be routed to that business
    And the business selection screen should not be displayed

  @accepting @routing @positive
  Scenario: User with multiple active businesses sees business selection
    Given the user has access to more than one business after invitation activation
    When the activation flow completes
    Then the business selection screen should be displayed
    And each available business should be selectable

  @accepting @routing @positive
  Scenario: User can switch between active businesses without signing out
    Given the user has access to more than one business
    And one business is the active context
    When the user selects another business from the business switcher
    Then the selected business should become the active context
    And the user should remain signed in
    And the page data should be scoped to the selected business

  @accepting @routing @positive
  Scenario: User with no business access continues to business registration when no invitation is active
    Given the authenticated user has completed personal identity verification
    And the user has no business access
    And the user has no expired or withdrawn invitation for the account email
    When post-verification invitation routing completes
    Then the business registration flow should be displayed
    And no invitation-outcome notice should be displayed

  @routing @positive
  Scenario: Verified ordinary signup without a business sees the Add your business screen
    Given an authenticated user has completed signup and personal identity verification
    And the user has no platform access or accessible business
    And the user has no matching invitation history
    When post-verification routing completes
    Then the Add your business screen should be displayed
    And no invitation-outcome notice should be displayed
    And an "Add your business" action should be available

  @routing @validation
  Scenario: Add your business screen guides an existing business participant to request an invitation
    Given the Add your business screen is displayed
    Then guidance to contact the business administrator and request an invitation should be displayed

  @routing @validation
  Scenario: Add your business screen provides language switching and sign-out
    Given the Add your business screen is displayed
    Then a language-switching control should be available
    And a sign-out action should be available

  @routing @positive
  Scenario: Add your business opens business registration
    Given the Add your business screen is displayed
    When the user selects "Add your business"
    Then the business registration flow should be displayed

  @accepting @resume @positive
  Scenario: Returning user resumes outstanding invitation activation steps
    Given the recipient created an account but stopped before completing activation
    And the invitation has not expired or been withdrawn
    When the recipient signs in again
    Then the outstanding personal activation steps should be displayed
    And the invitation should remain pending until those steps are complete

  # ──────────────── End-to-end happy path ────────────────

  @accepting @happy-path @positive @smoke
  Scenario: Recipient completes activation and enters the invited business
    Given a pending invitation exists for "new.user@business.com"
    And the invitation link opens the account-creation path
    When the recipient creates an account with the invited email address
    And the recipient completes the required personal details
    And the recipient completes mobile verification
    Then the invitation should become active
    And a Business User relationship should exist for the invited business
    And the recipient should enter the invited business
