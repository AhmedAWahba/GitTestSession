const path = require('path');
const { chromium } = require('playwright');

const dir = path.resolve(__dirname, '..', 'evidence', 'UI comparison of user management');
const toFileUrl = (p) => 'file:///' + p.replace(/\\/g, '/');

const jobs = [
  {
    title: 'User Management \u2014 Members Tab: Page Heading Naming',
    leftLabel: 'Prototype',
    rightLabel: 'UAT (business/pearl) \u2014 actual',
    leftSrc: toFileUrl(path.join(dir, 'prototype-members-crop.png')),
    rightSrc: toFileUrl(path.join(dir, 'uat-members-crop.png')),
    boxes: [
      { x: 4, y: 42, width: 180, height: 22 }
    ],
    captions: [
      '1. Prototype heading reads "Users Management" (plural); UAT reads "User Management" (singular),',
      '   matching the Engineering PRD title exactly (Master APEX PRD Set, Section 11 \u2014 User Management Experience).'
    ],
    out: path.join(dir, 'members-heading-naming-comparison.png')
  },
  {
    title: 'User Management \u2014 Invitations Tab: Table Columns (PRD UM-016)',
    leftLabel: 'Prototype',
    rightLabel: 'UAT (business/pearl) \u2014 actual',
    leftSrc: toFileUrl(path.join(dir, 'prototype-invitations-crop.png')),
    rightSrc: toFileUrl(path.join(dir, 'uat-invitations-crop.png')),
    boxes: [
      { x: 293, y: 262, width: 365, height: 20 }
    ],
    captions: [
      '1. UAT includes Sender and Sent columns as required by the PRD ("email, offered role, status, sender,',
      '   last-sent time, expiry"). The prototype omits both columns for the same Invitations tab.'
    ],
    out: path.join(dir, 'invitations-columns-comparison.png')
  },
  {
    title: 'Settings Page \u2014 User Management Card Name',
    leftLabel: 'Prototype',
    rightLabel: 'UAT (business/pearl) \u2014 actual',
    leftSrc: toFileUrl(path.join(dir, 'prototype-settings-crop.png')),
    rightSrc: toFileUrl(path.join(dir, 'uat-settings-crop.png')),
    boxes: [
      { x: 34, y: 231, width: 148, height: 26 }
    ],
    captions: [
      '1. Prototype card is titled "Users and roles"; UAT card is titled "User Management" for the same',
      '   destination. Typography/color are identical on both (IBM Plex Sans Arabic, 17px/600, #14181d text,',
      '   #fefcf6 card background, #14181d border) \u2014 only the card name and description copy differ.'
    ],
    out: path.join(dir, 'settings-card-naming-comparison.png')
  },
  {
    title: 'Members Tab \u2014 Filters, Column Sorting & Pagination Not Implemented in UAT',
    leftLabel: 'Prototype',
    rightLabel: 'UAT (business/pearl) \u2014 actual',
    leftSrc: toFileUrl(path.join(dir, 'prototype-members-crop.png')),
    rightSrc: toFileUrl(path.join(dir, 'uat-members-crop.png')),
    boxes: [
      { x: 4, y: 200, width: 150, height: 28 },
      { x: 4, y: 258, width: 610, height: 38 },
      { x: 4, y: 558, width: 701, height: 42 }
    ],
    captions: [
      '1. UAT combines role + status into one "Filters" panel with an Apply step; the prototype exposes',
      '   separate "Filter by role" / "Filter by status" dropdowns that apply instantly, with no Apply button.',
      '2. UAT column headers (Name, Role, Status, Email) are static text; the prototype renders each as a',
      '   clickable sort button with an ascending/descending icon \u2014 UAT has no per-column table sorting.',
      '3. UAT pagination shows only Previous/Next. The prototype additionally provides a "Rows per page"',
      '   selector (10/25/50), a "Showing X\u2013Y of Z" count, and a numbered current-page indicator.'
    ],
    out: path.join(dir, 'members-missing-ui-elements-comparison.png')
  },
  {
    title: 'Invitations Tab \u2014 Filters & Column Sorting Not Implemented in UAT',
    leftLabel: 'Prototype',
    rightLabel: 'UAT (business/pearl) \u2014 actual',
    leftSrc: toFileUrl(path.join(dir, 'prototype-invitations-crop.png')),
    rightSrc: toFileUrl(path.join(dir, 'uat-invitations-crop.png')),
    boxes: [
      { x: 4, y: 200, width: 200, height: 28 },
      { x: 4, y: 258, width: 610, height: 38 }
    ],
    captions: [
      '1. UAT replaces the prototype\'s separate role/status filter dropdowns with a combined "Filters" panel',
      '   plus a single global sort-direction toggle button (next to Apply) \u2014 a different filtering/sorting model.',
      '2. UAT column headers (Email, Offered role, Status, Sender, Sent, Expires) are static text; the prototype',
      '   renders Invited email/Role/Status/Expires as clickable per-column sort buttons. UAT also lacks the',
      '   "Rows per page" selector, result count, and numbered pagination seen on the Members tab (same gap).'
    ],
    out: path.join(dir, 'invitations-missing-ui-elements-comparison.png')
  },
  {
    title: 'Members Tab \u2014 Status Badge Color Coding Not Implemented in UAT',
    leftLabel: 'Prototype',
    rightLabel: 'UAT (business/pearl) \u2014 actual',
    leftSrc: toFileUrl(path.join(dir, 'prototype-members-crop.png')),
    rightSrc: toFileUrl(path.join(dir, 'uat-members-crop.png')),
    boxes: [
      { x: 210, y: 290, width: 150, height: 65 }
    ],
    captions: [
      '1. UAT renders every status as a neutral tan/cream pill (Active #ebddce, Removed #f5f1e9 \u2014 nearly the',
      '   same as the page background). The prototype uses distinct semantic colors (Active #bfe7d4 green,',
      '   Pending #bac0cc blue-gray, Revoked #f2bdbd red). Font family/size/weight are IDENTICAL on both',
      '   ("IBM Plex Sans Arabic", 12px, 500, text #14181d) \u2014 only the badge background color-coding differs.'
    ],
    out: path.join(dir, 'status-badge-colors-comparison.png')
  }
];

(async () => {
  const browser = await chromium.launch();
  for (const job of jobs) {
    const page = await browser.newPage();
    const configStr = encodeURIComponent(JSON.stringify(job));
    const templateUrl = toFileUrl(path.resolve(__dirname, 'merge-template.html')) + '?config=' + configStr;
    await page.goto(templateUrl);
    await page.waitForFunction(() => window.__renderDone === true, null, { timeout: 15000 });
    await page.locator('canvas').screenshot({ path: job.out });
    await page.close();
    console.log('wrote', job.out);
  }
  await browser.close();
})();
