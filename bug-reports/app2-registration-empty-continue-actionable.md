# [Mobile] - Registration: Continue remains actionable when account form is empty

## Summary

On Android `app2.apk`, the Continue button is visibly active and accepts a tap while all account-registration fields are empty. Submission validates only the email field with **"Enter a valid work email address."**, while Password and Confirm password remain without required-field feedback.

## Scenario

```gherkin
# Actor: Business owner

@negative @ui
Scenario: Continue button is disabled when no fields are filled
  Given I am on the create account screen with no fields filled
  Then the "Continue" button should be disabled
  And a sign-in link should be visible for users who already have an account
```

## Expected Result

The Continue button is disabled and cannot submit while Email Address, Password, and Confirm Password are empty. A sign-in route is visible for users who already have an account.

## Actual Result

The empty Android registration form displays a solid active-looking Continue button that accepts a tap. After tapping it, only the email field shows **"Enter a valid work email address."** Password and Confirm password remain unflagged, and no sign-in link is visible on the registration screen. On Web UAT, Continue is also technically enabled, but submitting the empty form leaves the page visually unchanged with no inline validation message.

## Evidence

- `evidence/2026-09-24-app2-registration/001-empty-form-submit.png` — Android `app2.apk` after tapping Continue with all registration fields empty; only the email validation message is displayed.
- `evidence/2026-09-24-app2-registration/003-empty-validation-web-vs-android.png` — Sanitized side-by-side comparison showing no visible Web validation message versus Android's email-only message after empty submission.

## Environment

- **Product:** Qawafel — Android Registration / Account Setup
- **Environment:** QA build — local fake-server configuration
- **Branch:** [MISSING: git branch]
- **Date/Time:** 2026-09-24
- **Browser:** N/A — **Device:** Android Emulator (Pixel 6 profile) — **OS:** Android API 34

---

**Severity:** Medium — required-field gating and feedback are inconsistent, but the flow does not advance with empty data.  
**Priority:** P3
