# [Web] - [User Management] - Multiple UI differences vs prototype design from Settings through Invitations tab

## Summary

Comparing the approved design prototype against the UAT build surfaces several UI differences across the User Management journey, starting at the Settings hub entry card and continuing through the Members and Invitations tabs (naming, table columns, filter/sort/pagination controls, and status badge coloring).

## Findings

### 1. Settings page — User Management entry card name

The Settings hub card that links to the Members/Invitations destination is labeled differently between the two builds. Prototype: **"Users and roles"** with description "The people who have access to the business and the invitations sent to them." UAT: **"User Management"** with description "Manage members and invitations for this business." Typography and color tokens are identical on both (IBM Plex Sans Arabic, 17px/600, `#14181d` text, `#fefcf6` card background, `#14181d` border) — only the card name and description copy differ.

![Settings page — User Management card name difference](../evidence/UI%20comparison%20of%20user%20management/settings-card-naming-comparison.png)

### 2. Members tab — page heading naming

On the Members tab, the page heading text itself also differs. Prototype: **"Users Management"** (plural, H2). UAT: **"User Management"** (singular, H1).

![Members tab — page heading naming difference](../evidence/UI%20comparison%20of%20user%20management/members-heading-naming-comparison.png)

### 3. Members tab — filters, column sorting and pagination controls

Three related UI elements present in the prototype are not implemented in UAT: (1) the prototype exposes separate, instantly-applied "Filter by role" / "Filter by status" dropdowns, while UAT combines both into a single "Filters" panel behind an "Apply" step; (2) the prototype's table column headers (Name, Role, Status, Email) are clickable sort buttons with direction icons, while UAT's headers are static text with no per-column sorting; (3) UAT's pagination only shows Previous/Next buttons, while the prototype additionally shows a "Rows per page" selector (10/25/50), a "Showing X–Y of Z" result count, and a numbered current-page indicator.

![Members tab — filters, sorting and pagination gaps](../evidence/UI%20comparison%20of%20user%20management/members-missing-ui-elements-comparison.png)

### 4. Members tab — status badge color coding

Status pill coloring differs between the two builds. Prototype uses distinct semantic colors: Active `#bfe7d4` (green), Pending `#bac0cc` (blue-gray), Revoked `#f2bdbd` (red). UAT renders every status as a neutral tan/cream pill (Active `#ebddce`, Removed `#f5f1e9` — nearly identical to the page background), with no color differentiation between statuses. Font family, size, and weight are identical on both ("IBM Plex Sans Arabic", 12px, weight 500, text `#14181d`) — only the badge background color differs.

![Members tab — status badge color coding difference](../evidence/UI%20comparison%20of%20user%20management/status-badge-colors-comparison.png)

### 5. Invitations tab — table columns

The Invitations table columns differ between builds. UAT shows: Email, Offered role, Status, **Sender**, **Sent**, Expires, Actions. The prototype (on the captured load) shows only: Invited email, Role, Status, Expires, Actions — omitting the Sender and Sent columns.

![Invitations tab — table columns difference](../evidence/UI%20comparison%20of%20user%20management/invitations-columns-comparison.png)

### 6. Invitations tab — filters, column sorting and pagination controls

The same toolbar/table control gaps seen on the Members tab repeat on the Invitations tab: UAT combines role/status filtering into one "Filters" panel plus a single global "Sent: newest first" sort-direction toggle, instead of the prototype's separate instantly-applied role/status dropdowns; UAT's column headers (Email, Offered role, Status, Sender, Sent, Expires) are static text with no per-column sort buttons, unlike the prototype's clickable sortable headers on Invited email/Role/Status/Expires; and UAT lacks the "Rows per page" selector, result count, and numbered pagination seen in the prototype.

![Invitations tab — filters and sorting gaps](../evidence/UI%20comparison%20of%20user%20management/invitations-missing-ui-elements-comparison.png)

## Environment

- **Product:** Qawafel — Apex Web / Settings & User Management
- **Prototype (design reference):** `https://apex-web-app-prototype.vercel.app`
- **Environment under test:** UAT — `https://apex.qawafel.dev/business/pearl`
- **Branch:** main
- **Date/Time:** 2026-09-21
- **Browser:** Chromium — **Device:** Desktop — **OS:** Windows 11
