# [Web] - Registration: Intermediate Auth - Generic login page shown instead of in-flow "Sign in to continue" screen after OTP verification

## Summary

After a new user enters the correct 6-digit email OTP during the business registration flow, the application redirects them to the standard Qawafel login page ("Welcome back to Qawafel!") displaying only the toast "Email verified. You can sign in now." The expected in-flow re-auth screen — headed "Sign in to continue" with the contextual message "Your email is verified. Please sign in to continue to identity verification." — never appears. After the user manually logs in from the generic page, they land on the Business Workspace dashboard rather than being forwarded to the next onboarding step (mobile number confirmation / identity verification).

## Scenario

```gherkin
# Actor: Business owner (new user registering)

@registration @positive @smoke
Scenario: Correct email OTP advances to the sign-in step and confirms account creation
  Given I have completed the personal details step and am on the email OTP step
  And the registered email is shown as read-only above the OTP input
  And a countdown timer is visible
  When I enter the correct 6-digit OTP
  Then the heading "Sign in to continue" should be displayed
  And the message "Your email is verified. Please sign in to continue to identity verification." should be visible
```

## Expected Result

After entering a correct 6-digit OTP, the registration flow advances within the onboarding wizard to an in-flow "Sign in to continue" screen. That screen must display the heading **"Sign in to continue"** and the contextual message **"Your email is verified. Please sign in to continue to identity verification."** — keeping the user inside the multi-step registration journey, not routing them to the generic login page.

## Actual Result

After entering the correct OTP, the application redirects to the standalone Qawafel login page displaying the heading **"Welcome back to Qawafel!"** and the generic subtitle "All you need to manage your business in one system, log in and get started." A transient toast reads **"Email verified. You can sign in now."** The registration-specific heading, contextual message, and pre-filled read-only email are absent. After the user manually completes the generic login, they are dropped into the Business Workspace dashboard — the identity verification step is never reached from the flow.

## Evidence

- `evidence/2026-06-17T13-13-24/016-email-verification/003-email-verified-redirect.png` — Immediately after OTP submission: generic login page displayed with "Welcome back to Qawafel!" heading and "Email verified. You can sign in now." toast; the in-flow "Sign in to continue" screen is absent
- `evidence/2026-06-17T13-13-24/016-email-verification/005-newuser2-verified.png` — Same generic login page still rendered; the expected registration-scoped re-auth screen never loads
- `evidence/2026-06-17T13-13-24/017-login-verified-account/001-login-page.png` — User forced to complete full credential entry on the standalone login form as a separate manual step
- `evidence/2026-06-17T13-13-24/017-login-verified-account/005-dashboard-after-login.png` — Post-login destination is the Business Workspace dashboard; identity verification onboarding step is bypassed entirely

## Environment

- **Product:** Qawafel — Business Registration / Account Setup
- **Environment:** Development — `https://apex.qawafel.dev/register`
- **Branch:** [MISSING: git branch]
- **Date/Time:** 2026-06-17
- **Browser:** [MISSING: name + version] — **Device:** Desktop — **OS:** [MISSING: OS + version]

---

**Severity:** High — the defined re-authentication step within the onboarding wizard is replaced by the generic login page, breaking the scoped flow and dropping the user at the dashboard instead of identity verification. A workaround exists (manually navigate to identity verification after login) but it is not discoverable by end users.  
**Priority:** P2
