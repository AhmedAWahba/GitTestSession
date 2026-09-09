@notifications @nc8 @linear-id-316 @retention
Feature: NC-8 Notification retention and data integrity
  As the platform
  I want notifications purged after 60 days regardless of read state
  So that the inbox stays relevant without becoming a permanent record

  Background:
    Given the user has notifications of different ages in the inbox

  # ──────────────── Positive scenarios ────────────────

  @retention @positive @boundary
  Scenario Outline: A notification is removed once it reaches the retention limit
    Given a notification is "<AgeInDays>" days old
    And the notification is "<ReadState>"
    When the retention purge runs
    Then the notification should be "<Expected>" in the inbox

    Examples:
      | AgeInDays | ReadState | Expected |
      | 1         | unread    | present  |
      | 59        | read      | present  |
      | 60        | unread    | present  |
      | 61        | unread    | removed  |
      | 61        | read      | removed  |

  @retention @positive
  Scenario: Unread count falls when an unread notification is purged
    Given the current business has "2" unread notifications
    And one of them is "61" days old
    When the retention purge runs
    Then the unread count for the current business should be "1"

  @retention @positive @data-integrity @smoke
  Scenario: The underlying record a purged notification referred to is unchanged
    Given a notification older than 60 days refers to a payment request
    When the retention purge removes that notification
    Then the payment request itself should remain unchanged and reachable in its own module

  # ──────────────── Negative scenarios ────────────────

  @retention @negative @ui
  Scenario: No dismiss or delete action is offered anywhere in the inbox
    Given the inbox has at least one notification
    Then no dismiss action should be visible on any notification
    And no delete action should be visible on any notification

  @retention @negative
  Scenario: A notification cannot be removed early regardless of read state
    Given a notification is 10 days old
    When the user reads that notification
    Then the notification should still be visible in the inbox until the 60-day limit is reached
