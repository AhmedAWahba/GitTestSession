@notifications @notification-center @people-and-partner-events
Feature: People and Partner Notification Events
  As an Owner or Admin
  I want to be notified when people or partners connect to or leave my business
  So that I always know who currently has access or a trading relationship

  Background:
    Given the user is signed in as "Owner"
    And the user is working in a business

  # Source: PRD Notification Center Section 5 "Notification content — in the
  # platform" (People and partners); observed in the live design prototype.

  @people-and-partner-events @partners @negative
  Scenario: A notification about a removed partner has no destination link
    Given a business partner is removed from the current business
    When the removal notification is raised
    Then the notification should describe that the partner was removed
    And the notification should not offer a link to the removed partner

  # ──────────────── Positive scenarios ────────────────

  @people-and-partner-events @membership @positive @smoke
  Scenario: A notification is raised when a person joins the business
    Given a new person joins the current business
    Then a notification stating that person joined the business should be raised
    And the notification should link to Users and roles

  @people-and-partner-events @membership @positive
  Scenario: A notification is raised when a person no longer has access
    Given an active member's access to the current business ends
    Then a notification stating that person no longer has access should be raised
    And the notification should link to Users and roles

  @people-and-partner-events @partners @positive @smoke
  Scenario: A notification is raised when a partner connects to the business
    Given a business partner connects to the current business
    Then a notification stating that partner is now connected should be raised
    And the notification should link to that partner's profile
