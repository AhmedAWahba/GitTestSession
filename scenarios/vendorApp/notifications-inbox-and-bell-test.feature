@notifications @notification-center @inbox-bell
Feature: Notification Inbox and Bell
  As a signed-in Apex user
  I want a single inbox with an accurate unread bell badge
  So that I always know when something needs my attention without hunting for it

  Background:
    Given the user is signed in
    And the user is working in a business

  # Source: Linear ID-311 [NC-3] Notification Inbox and Bell; PRD Notification Center NC-1.

  @inbox-bell @structure @negative
  Scenario: The inbox is a single list with no dividing tabs, categories, or headings
    Given the inbox has both read and unread notifications
    Then all notifications should appear in one continuous list
    And no tab, category, or heading should separate them

  @inbox-bell @structure @negative
  Scenario: Current engineering scope groups the inbox into Unread and Earlier sections
    Given the inbox has both read and unread notifications
    When the page is built as scoped in Linear ID-311
    Then the page would show a heading-divided "Unread" section and a heading-divided "Earlier" section

  @inbox-bell @empty-state @negative
  Scenario: Empty inbox shows an explanatory message
    Given the current business has no notifications
    When the user opens the inbox
    Then an explanation of what the inbox is for should be visible
    And no notification entries should be listed

  @inbox-bell @edge-case @negative
  Scenario: A notification whose referenced item no longer exists has no destination link
    Given a business partner referenced by a notification has since been removed
    Then that notification should not offer a destination link
    And every other notification should still offer a destination link

  # ──────────────── Validation scenarios ────────────────

  @inbox-bell @navigation @validation
  Scenario Outline: Inbox is reachable for every signed-in role
    Given the user is signed in as "<Role>"
    When the user opens the notification inbox from the main navigation
    Then the inbox page should open

    Examples:
      | Role   |
      | Owner  |
      | Admin  |
      | Member |

  @inbox-bell @ui @validation
  Scenario: Every notification entry shows what happened, when, and where to go next
    Given the inbox has at least one notification
    Then each entry should show a message describing what happened
    And each entry should show the time it happened
    And each entry should show a link to the relevant page

  @inbox-bell @ui @validation
  Scenario Outline: Unread bell badge matches the unread count and hides when zero
    Given the current business has "<UnreadCount>" unread notifications
    Then the bell badge should show "<UnreadCount>"

    Examples:
      | UnreadCount |
      | 0           |
      | 1           |
      | 6           |

  # ──────────────── Positive scenarios ────────────────

  @inbox-bell @ordering @positive
  Scenario: Newest notification is always at the top
    Given the inbox has notifications raised at different times
    When the user opens the inbox
    Then the most recently raised notification should be listed first
    And reading a notification should not change its position in the list

  @inbox-bell @ui @positive
  Scenario: Unread notifications are visibly distinct from read ones
    Given the inbox has both read and unread notifications
    Then unread notifications should be visibly marked as unread
    And read notifications should not carry the unread marker

  @inbox-bell @read-state @positive
  Scenario: Opening the inbox does not change the unread count
    Given the current business has unread notifications
    When the user opens the inbox
    Then the unread count should remain unchanged

  @inbox-bell @read-state @positive @smoke
  Scenario: Opening a single notification marks only that one read
    Given the current business has more than one unread notification
    When the user opens one unread notification
    Then that notification should become read
    And the unread count should decrease by exactly one
    And every other notification should keep its previous read state

  @inbox-bell @read-state @positive @smoke
  Scenario: Mark all as read clears the unread count for the current business only
    Given the current business has unread notifications
    And another business the user has access to also has unread notifications
    When the user selects "Mark all as read"
    Then the unread count for the current business should be zero
    And the unread count for the other business should remain unchanged

  @inbox-bell @read-state @positive
  Scenario: Mark all as read marks every notification in the current business as read
    Given the current business has more than one unread notification
    When the user selects "Mark all as read"
    Then every notification in the current business should be read
