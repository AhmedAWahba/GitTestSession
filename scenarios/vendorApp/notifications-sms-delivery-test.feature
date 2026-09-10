@notifications @notification-center @sms-channel
Feature: Notification SMS Delivery
  As an Apex user
  I want security-critical events to always reach me by SMS
  So that my account and money stay protected even if I can't opt out

  Background:
    Given the user's mobile number is on file

  # Source: Linear ID-315 [NC-7] Notification SMS Delivery; PRD Notification Center Section 2.

  @sms-channel @scope @negative
  Scenario: No SMS is sent for an event the catalog does not map to the SMS channel
    Given an event occurs that the Notification Event Catalog routes to email only
    Then no SMS should be sent for that event

  # ──────────────── Positive scenarios ────────────────

  @sms-channel @security @smoke @positive
  Scenario Outline: Security SMS messages are always sent and cannot be switched off
    Given the security event "<Event>" occurs on the user's account
    Then an SMS should be delivered for "<Event>"
    And the user should have no option to switch off "<Event>" SMS messages

    Examples:
      | Event                            |
      | One-time verification code       |
      | Password changed confirmation    |
      | Bank account added confirmation  |

  @sms-channel @informational @positive
  Scenario: Payment request expiring soon is the only informational SMS today
    Given a payment request is approaching its expiry
    Then the buying business should receive an informational SMS about the expiry
    And no other informational SMS type should exist yet besides payment request expiry
