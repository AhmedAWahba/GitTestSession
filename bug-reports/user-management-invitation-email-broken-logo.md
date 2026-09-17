# [Web] - [User Management] - Brand logo image broken in email template when invitation delivered

## Summary

When an invitation email is sent to a recipient from User Management via SMTP (`no-reply@qawafel.sa`), the header logo in the HTML email body fails to render across email clients (e.g., Gmail), displaying a broken image placeholder `[img Qawafel]` instead of the brand asset.

## Scenario

```gherkin
# Actor: Invited recipient checking mailbox

@sending @email @validation
Scenario: Invitation email contains valid and renderable brand assets
  Given a pending invitation is sent to "new.recipient@business.com"
  When the invitation email is delivered to the recipient mailbox
  Then the email header logo should be loaded from an accessible public URL
  And the logo image should not return a broken asset or placeholder
```

## Steps to Reproduce

1. Log in as an Owner or Admin and navigate to User Management.
2. Click **Invite user**, enter a valid external email address (e.g. `ahmedwahba.qa@gmail.com`), and submit the invitation.
3. Open the received email in the recipient's mailbox client (e.g. Gmail).
4. Inspect the email header area located directly above the invitation text.

## Expected Result

The Qawafel logo image should be loaded from a valid, publicly accessible, HTTPS asset URL and render cleanly in the email header.

## Actual Result

The email header displays a broken image box with the alt text `[img Qawafel]` because the image source URL is invalid, inaccessible, or blocked.

## Evidence

- `evidence/user-management/002-invitation-email-broken-logo.png` — Broken logo asset placeholder displayed in the invitation email header

![Evidence Screenshot](https://raw.githubusercontent.com/AhmedAWahba/GitTestSession/main/evidence/user-management/002-invitation-email-broken-logo.png)

## Environment

- **Product:** Qawafel — Apex Web / Notification & User Management
- **Environment:** UAT — `https://apex.qawafel.dev`
- **Branch:** main
- **Date/Time:** 2026-09-15
- **Browser:** Chromium 125 — **Device:** Desktop — **OS:** Windows 11
