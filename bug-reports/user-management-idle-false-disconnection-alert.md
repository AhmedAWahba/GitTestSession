# [Web] - [User Management] - False disconnection alert displayed when page idle for extended duration

## Summary

Leaving the User Management page (Invitations tab) open and idle for approximately 10 minutes causes the client-side Phoenix LiveView / WebSocket heartbeat to fail and display false network disconnection error alerts ("We can't find the internet" / "Something went wrong! Attempting to reconnect") despite a completely healthy and active internet connection.

## Scenario

```gherkin
# Actor: Business Owner or Admin

@listing @resilience @negative @role-owner @role-admin
Scenario: Keeping the User Management page open does not trigger false network disconnection alerts
  Given the user is on the "Invitations" tab with an active internet connection
  When the page remains open and idle for an extended duration
  Then no false "We can't find the internet" error toast should be displayed
  And the page should maintain or silently refresh its active connection
```

## Steps to Reproduce

1. Log in to Qawafel as an Owner or Admin (`owner@pearltrading.sa`).
2. Navigate to **Settings > User Management > Invitations** tab (`/business/pearl/settings/users?tab=invitations`).
3. Keep the browser tab open and idle without interacting for approximately 10 minutes.
4. Observe the top right corner of the viewport.

## Expected Result

The application should maintain connection silently or perform background heartbeat reconnects without displaying false connection error toasts to the user while network connectivity is healthy.

## Actual Result

Two stacked orange alert banners appear:
1. "We can't find the internet. Attempting to reconnect"
2. "Something went wrong! Attempting to reconnect"

## Evidence

- `evidence/user-management/003-idle-false-disconnection-alert.png` — False network disconnection error toasts displayed over User Management page

![Evidence Screenshot](https://raw.githubusercontent.com/AhmedAWahba/GitTestSession/main/evidence/user-management/003-idle-false-disconnection-alert.png)

## Environment

- **Product:** Qawafel — Apex Web / User Management
- **Environment:** UAT — `https://apex.qawafel.dev/business/pearl/settings/users?tab=invitations`
- **Branch:** main
- **Date/Time:** 2026-09-15
- **Browser:** Chromium 125 — **Device:** Desktop — **OS:** Windows 11
