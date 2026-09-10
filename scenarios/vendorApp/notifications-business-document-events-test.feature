@notifications @notification-center @business-document-events
Feature: Business Document Notification Events
  As an Owner or Admin
  I want to be notified about invoice and financing outcomes
  So that I know when a document needs my attention

  Background:
    Given the user is signed in as "Owner"
    And the user is working in a business

  @business-document-events @invoices @negative
  Scenario: A notification is raised when an invoice from an upload is not registered
    Given an invoice from an uploaded batch fails to register
    Then a notification stating the invoice was not registered should be raised
    And the notification should link to the invoices list

  # ──────────────── Positive scenarios ────────────────

  @business-document-events @invoices @positive @smoke
  Scenario: A notification is raised when invoice registration finishes
    Given an uploaded batch of invoices finishes registering
    Then a notification stating invoice registration finished should be raised
    And the notification should link to the invoices list

  @business-document-events @invoices @positive
  Scenario: A notification is raised when a sales invoice becomes overdue
    Given a sales invoice passes its due date unpaid
    Then a notification stating the invoice is past its due date should be raised
    And the notification should link to that specific invoice

  @business-document-events @financing @positive
  Scenario: A notification is raised when invoice financing is approved
    Given an invoice financing application is approved
    Then a notification stating the financing was approved should be raised
    And the notification should link to the financing applications page

  @business-document-events @financing @positive
  Scenario: A notification is raised when a financed invoice settles to the business IBAN
    Given a financed invoice's net amount is sent to the business IBAN
    Then a notification stating the amount was sent to the IBAN should be raised
    And the notification should link to the financing applications page
