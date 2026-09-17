# [Web] - [User Management] - Search query filter automatically applied when sending an invitation

## Summary

In User Management, after an Owner or Admin sends an invitation to any recipient, the application redirects to `/business/<slug>/settings/users?search=<invited-email>&tab=invitations` and automatically populates the search query with `Search: <invited-email>`. This unintended filter hides all previously existing invitations in the Invitations tab until the user manually clicks "Clear all".

## Scenario

```gherkin
# Actor: Business Owner or Admin

@listing @ui @validation @role-owner @role-admin
Scenario: Sending an invitation adds the entry without unintentionally filtering the full list
  Given the "Invitations" tab currently contains multiple invitations
  When the user sends an invitation to "another.user@business.com"
  Then the new invitation for "another.user@business.com" should appear in the "Invitations" tab
  And previously existing invitations should remain visible in the list
```

## Steps to Reproduce

1. Log in as an Owner or Admin (`owner@pearltrading.sa`).
2. Navigate to **Settings > User Management > Invitations** tab (`/business/pearl/settings/users?tab=invitations`).
3. Note that multiple invitations exist in the list.
4. Click **Invite user**.
5. Enter a valid email address (e.g. `shimaa.fayz@gmail.com` or `ahmedwahba.qa@ymail.com`), select role **Admin** or **Member**, and click **Send invitation**.
6. Observe the redirected page URL and the displayed table rows.

## Expected Result

The new invitation is created with status "Pending" and added to the Invitations tab. The Invitations tab should remain in its default unfiltered state so that the user can see all pending, expired, and revoked invitations without being forced to click "Clear all".

## Actual Result

The user is redirected to `.../settings/users?search=<invited-email>&tab=invitations`. The search criteria bar displays `Search: <invited-email>` and only the single newly created invitation is visible in the table. All other invitations are hidden until the user manually clicks "Clear all".

## Evidence

- `evidence/user-management/001-invitation-auto-search-filter.png` — Redirected Invitations tab with automatic search query filter applied hiding other invitations

![Evidence Screenshot](https://raw.githubusercontent.com/AhmedAWahba/GitTestSession/main/evidence/user-management/001-invitation-auto-search-filter.png)

## Environment

- **Product:** Qawafel — Apex Web / User Management
- **Environment:** UAT — `https://apex.qawafel.dev/business/pearl/settings/users`
- **Branch:** main
- **Date/Time:** 2026-09-15
- **Browser:** Chromium 125 — **Device:** Desktop — **OS:** Windows 11
