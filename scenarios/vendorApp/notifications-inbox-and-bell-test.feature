@notifications @nc3 @linear-id-311 @inbox-bell
Feature: NC-3 Notification inbox and bell
  As a signed-in APEX user
  I want a single inbox with an accurate unread bell badge
  So that I always know when something needs my attention without hunting for it

  Background:
    Given the user is signed in
    And the user is working in a business

  # ──────────────── Validation scenarios ────────────────

  @inbox-bell @validation @navigation
  Scenario Outline: Inbox is reachable for every signed-in role
    Given the user is signed in as "<Role>"
    When the user opens the notification inbox from the main navigation
    Then the inbox page should open

    Examples:
      | Role   |
      | Owner  |
      | Admin  |
      | Member |

  @inbox-bell @validation @ui
  Scenario: Every notification entry shows what happened, when, and where to go next
    Given the inbox has at least one notification
    Then each entry should show a message describing what happened
    And each entry should show the time it happened
    And each entry should show a link to the relevant page

  @inbox-bell @validation @ui
  Scenario Outline: Unread bell badge matches the unread count and hides when zero
    Given the current business has "<UnreadCount>" unread notifications
    Then the bell badge should show "<UnreadCount>"

    Examples:
      | UnreadCount |
      | 0           |
      | 1           |
      | 6           |

  # ──────────────── Positive scenarios ────────────────

  @inbox-bell @positive @ordering
  Scenario: Newest notification is always at the top
    Given the inbox has notifications raised at different times
    When the user opens the inbox
    Then the most recently raised notification should be listed first
    And reading a notification should not change its position in the list

  @inbox-bell @positive @ui
  Scenario: Unread notifications are visibly distinct from read ones
    Given the inbox has both read and unread notifications
    Then unread notifications should be visibly marked as unread
    And read notifications should not carry the unread marker

  @inbox-bell @positive @read-state
  Scenario: Opening the inbox does not change the unread count
    Given the current business has unread notifications
    When the user opens the inbox
    Then the unread count should remain unchanged

  @inbox-bell @positive @read-state @smoke
  Scenario: Opening a single notification marks only that one read
    Given the current business has more than one unread notification
    When the user opens one unread notification
    Then that notification should become read
    And the unread count should decrease by exactly one
    And every other notification should keep its previous read state

  @inbox-bell @positive @read-state @smoke
  Scenario: Mark all as read clears the unread count for the current business only
    Given the current business has unread notifications
    And another business the user has access to also has unread notifications
    When the user selects "Mark all as read"
    Then the unread count for the current business should be zero
    And the unread count for the other business should remain unchanged

  @inbox-bell @positive @empty-state
  Scenario: Empty inbox shows an explanatory message
    Given the current business has no notifications
    When the user opens the inbox
    Then an explanation of what the inbox is for should be visible
    And no notification entries should be listed

  # ──────────────── Structural / conflict scenarios ────────────────
  # PRD Master APEX PRD Set.md NC-1.4: "The inbox is a single list. There are
  # no tabs, categories, or headings that divide it." See open question #2 in
  # docs/prd-analysis/apex-notification-center-inbox-and-access-rules.md —
  # Linear ID-311 [NC-3] scopes the page as "Unread and Earlier" sections,
  # which conflicts with this requirement pending a Product decision.

  @inbox-bell @negative @structure
  Scenario: The inbox is a single list with no dividing tabs, categories, or headings
    Given the inbox has both read and unread notifications
    Then all notifications should appear in one continuous list
    And no tab, category, or heading should separate them

  @inbox-bell @known-conflict @needs-product-decision
  Scenario: Current engineering scope groups the inbox into "Unread" and "Earlier" sections
    Given the inbox has both read and unread notifications
    When the "Unread and Earlier" layout described in Linear ID-311 [NC-3] is built as scoped
    Then the page would show a heading-divided "Unread" section and a heading-divided "Earlier" section
    But this conflicts with NC-1.4 and must be resolved by Product before this scenario can be marked pass or fail
