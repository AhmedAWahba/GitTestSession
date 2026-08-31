andtion activation
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
    And the inactive invitation notice should not be displayed

  @accepting @routing @positive
  Scenario: Terminal invitation notice action opens business registration
    Given the authenticated recipient has completed personal identity verification
    And the terminal invitation notice is displayed
    When the recipient selects the action to continue to business registration
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
