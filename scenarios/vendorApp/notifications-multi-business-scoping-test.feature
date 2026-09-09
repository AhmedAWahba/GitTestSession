@notifications @nc1 @linear-id-309 @multi-business
Feature: NC-1 Notification storage and per-business scoping
  As a person with access to more than one business
  I want each business's inbox and read state kept separate
  So that activity in one business never leaks into or affects another

  Background:
    Given the user is signed in
    And the user has access to more than one business

  # ──────────────── Positive scenarios ────────────────

  @multi-business @positive @scoping @smoke
  Scenario: A notification raised in one business never appears in another business's inbox
    Given a notification is raised for business "Al Nakheel"
    When the user opens the inbox for business "Al Rowad"
    Then the notification raised for "Al Nakheel" should not be listed

  @multi-business @positive @scoping
  Scenario: Each business carries its own independent unread count
    Given business "Al Nakheel" has "3" unread notifications
    And business "Al Rowad" has "1" unread notification
    Then the unread count for "Al Nakheel" should be "3"
    And the unread count for "Al Rowad" should be "1"

  @multi-business @positive @scoping
  Scenario: Reading a notification in one business does not change another business's count
    Given business "Al Nakheel" has "3" unread notifications
    And business "Al Rowad" has "1" unread notification
    When the user reads one notification in "Al Nakheel"
    Then the unread count for "Al Nakheel" should be "2"
    And the unread count for "Al Rowad" should remain "1"

  @multi-business @positive @switching
  Scenario: Switching business updates the inbox without signing out
    Given the user is currently working in "Al Nakheel"
    When the user switches active business to "Al Rowad"
    Then the inbox should show "Al Rowad" notifications only
    And the user should remain signed in

  # ──────────────── Read-state independence ────────────────

  @multi-business @positive @read-state
  Scenario: Read state follows the person across devices
    Given the user reads a notification on one device
    When the same user signs in on another device
    Then that notification should already be read

  @multi-business @positive @read-state
  Scenario: Reading a shared notification does not mark it read for a co-recipient
    Given a notification was raised for both "Owner" and "Admin" of the same business
    When the "Owner" opens and reads that notification
    Then the notification should remain unread for the "Admin"

  # ──────────────── Negative / access scenarios ────────────────

  @multi-business @negative @role-based-access
  Scenario: A person whose access has ended receives nothing further from that business
    Given the user's access to business "Al Nakheel" has ended
    When an event that would normally notify the business occurs in "Al Nakheel"
    Then the user should not receive a notification for that event

  @multi-business @negative @security @authorization
  Scenario: Direct access to another business's notifications is denied
    Given the user does not currently have access to business "Al Rowad"
    When the user requests the notifications for business "Al Rowad" directly by route or API
    Then access should be denied
    And no notification content for "Al Rowad" should be returned
