# PRD Analysis: APEX Notification Center — Inbox, Channels & Access Rules

## 1. Sources Analysed
- `docs/Master APEX PRD Set.md` (lines 5087–5170) — Notification Center PRD: Purpose & Scope, Channels, Section 3 "The Inbox" (NC-1.1–NC-1.17), Section 4 "Access and Roles" (NC-2.1–NC-2.5), Notification Event Catalog reference, Screens list
- `prompts/prd-analysis-prompt.md` — analysis structure and rules used to produce this document
- `https://apex-web-app-prototype.vercel.app/notifications` — live design prototype, inspected via accessibility snapshot and screenshots (Owner/Admin persona, single business context, ~26 seeded notifications spanning 13 Jul–9 Sept 2026)
- Notification Event Catalog (Google Sheet linked from the PRD) — **inaccessible**: the link requires Google sign-in and returned a login wall, not the catalog contents `[MISSING: Notification Event Catalog access]`
- `https://linear.app/qawafel/team/ID/cycle/active` — **attempted and inaccessible**. Opening the link redirected through the Linear desktop-app handoff screen, then to a Google OAuth sign-in page pre-filled with `ahmedwahba@qawafel...` requesting a password. I did not enter any credentials (out of scope for this agent — credentials must never be handled by the assistant) and stopped there. No ticket list, cycle content, or `NC`-prefixed issue data was ever rendered or read. `[MISSING: authenticated Linear session or an exported/shared view of the NC tickets]`
- The only `NC`-prefixed identifiers actually available in this workspace are the PRD's own requirement IDs (NC-1.1–NC-1.17, NC-2.1–NC-2.5) inside `Master APEX PRD Set.md`. This analysis is traced against those IDs, not against Linear ticket numbers, since the Linear board could not be reached.
- Screenshot images referenced inline in the PRD (`image95`–`image115` for the Notification Center) were **not resolvable as pixel data** in the provided document; only the text-form wireframe screen list was available, plus the live prototype used above as the closest visual substitute. `[MISSING: rendered PRD screenshot assets for Notification Center]`

## 2. Feature Summary
The Notification Center gives every APEX user a per-business notification inbox plus email and SMS channels, so people learn about things that happen away from the screen they're on. The Inbox is a single reverse-chronological list scoped to the business currently being worked in, with per-person read/unread state, a 60-day retention window, and an unread-count badge in the main navigation. Owner and Admin receive business notifications; Members receive none (business-related) but keep account-level notifications regardless of role.

## 3. In Scope / Out of Scope

**In scope:**
- In-app inbox: single list, no tabs/categories, newest-first, read/unread state, mark-one/mark-all-as-read, 60-day retention, unread badge in navigation
- Per-business inbox scoping and per-business unread counts for multi-business users
- Role-based receipt rules: Owner/Admin get business notifications, Member gets none (business), everyone gets account-level notifications
- Three channels: in-app, email (bilingual Arabic-above-English), SMS (security vs. informational)
- Reference to the Notification Event Catalog as the single source for trigger/recipient/channel/wording per notification

**Out of scope (per this PRD document):**
- The actual content of the Notification Event Catalog (lives in an external spreadsheet, not this document)
- Notification Preferences settings screen — the Settings PRD (ST-6.x) marks this "reserved" pending this document, but this document does not itself define an opt-out/preferences UI
- Final visual design/copy — screens are explicitly labelled "low-fidelity wireframes... not final visual design"
- Anything the person sees as the immediate result of their own action (confirmation screens, success toasts, in-form messages) — explicitly excluded by Section 1
- Linear ticket status/state tracking — no ticket data was reachable for this analysis (see §1)

## 4. Personas & Permissions

| Persona | Role | Key permissions / constraints |
|---|---|---|
| Owner | Business owner | Reaches the inbox at all times (NC-1.1); receives all business notifications for the business they're working in (NC-2.1); receives own-account notifications regardless of role (NC-2.3) |
| Admin | Business admin | Same inbox reach and business-notification receipt as Owner (NC-2.1) |
| Member | View-only business role | Inbox is reachable but always empty of business notifications (NC-2.2); still receives own-account notifications (NC-2.3) |
| Any person, multi-business | N/A | Gets one inbox per business with an independent unread count per business (NC-1.3); a business notification never appears in another business's inbox (NC-1.2) |
| Any person whose access to a business ended | N/A | Receives nothing further from that business from the moment access ends (NC-2.4) |

## 5. End-to-End User Flow

1. A triggering event occurs somewhere in APEX (e.g., a payment request nears expiry, a partner connects, a role changes, a bank account is added).
2. The Notification Event Catalog determines who should be notified, on which channel(s), and with what wording — `[MISSING: catalog contents, not accessible for verification]`.
3. If in-app is one of the channels: a notification entry is created scoped to the relevant business (or to the person's account, for personal notifications) and marked unread for each intended recipient independently (NC-1.11).
4. The recipient's main navigation shows an incremented unread badge for the business they are currently working in (NC-1.12) — confirmed in the prototype as a red "6" badge next to the bell icon.
5. The recipient opens the inbox (does not change unread state — NC-1.9) and sees a single newest-first list mixing all notification types with no tabs or headings (NC-1.4, NC-1.5) — confirmed in the prototype by scrolling the full list with no dividing heading.
6. Each entry shows what happened, when, and a link to "where to go next" (NC-1.6) — confirmed: every prototype entry has message text, a relative/absolute timestamp, and a deep link (e.g., `/payments/PR-26-0003`, `/settings/security`, `/partners/p2`).
7. Payment-request notifications additionally show current standing as a status chip (NC-1.7) — confirmed: "Payable", "Paid", "Cancelled", "Expired" chips all observed.
8. Opening an individual notification, or clicking its "Mark as read" action, marks only that entry read for that person and decrements their unread count by one (NC-1.9); the same read state is visible from any device the person signs into, but is never shared with a co-recipient of the same notification (NC-1.11).
9. "Mark all as read" clears the unread count for the current business only (NC-1.10) — button exists in the prototype; functional confirmation could not be completed in this session (see §11, item 3).
10. If the person switches business, the inbox contents and unread count swap to the new business's own data without signing out (NC-1.2, NC-1.3) — **not verified in this session**; the prototype's business switcher (hamburger menu) did not respond within the browser tool's timeout window.
11. 60 days after a notification is raised, it is removed regardless of read state (NC-1.13, NC-1.14); the entity it referred to (payment request, person, partner, bank account) remains fully intact elsewhere in APEX (NC-1.16).
12. If the inbox holds nothing for the current business, an explanatory empty state is shown instead of blank space (NC-1.17); for a Member this is always the case for business notifications (NC-2.2).

## 6. Acceptance Criteria Coverage

| Story / Section | AC stated in PRD | Testable? | Gaps |
|---|---|---|---|
| NC-1.1 | "The inbox is reachable at all times by Owner, Admin, and Member." | Yes | None |
| NC-1.2 | "A notification raised in one business never appears in another. Switching business changes what the inbox holds without the person signing out." | Partial | Requires a multi-business test account and functioning business switcher; not exercised this session |
| NC-1.3 | "Reading a notification in one business does not change the unread count of another. Each business carries its own count." | Partial | Same dependency as NC-1.2 |
| NC-1.4 | "Every notification for the current business appears in one list with nothing separating it into groups." | Yes | Prototype renders unread and read notifications as two separate DOM `<list>` elements with visually distinct card styling for unread items; no heading/label divides them, so the letter of the AC holds, but see Risk table item on accessibility semantics |
| NC-1.5 | "The newest notification is always at the top. Order does not change when a notification is read." | Yes | Order-preservation-after-read not explicitly re-tested this session (button click did not register) |
| NC-1.6 | "All three are present on every entry. The time is shown against each one." | Yes | Confirmed for every entry inspected |
| NC-1.7 | "...shows whether it is now payable, paid, expired, or cancelled, whatever the notification itself says." | Yes | All four states observed in prototype data |
| NC-1.8 | "Every notification carries one of the two states. Unread ones are visibly distinct in the list." | Yes | Confirmed (red dot + "Unread." accessible label + card styling) |
| NC-1.9 | "Opening the inbox leaves the unread count unchanged. Opening a notification marks that one read and reduces the count by one." | Partial | "Opening the inbox unchanged" not independently re-verified after a fresh reload with items already read; "opening a notification" behavior (via its link, as opposed to the explicit "Mark as read" button) not tested |
| NC-1.10 | "The action is available whenever the business has unread notifications. Using it clears the unread count for that business only." | Partial | Button present; click did not register as a state change within the session (see §11) — needs re-test |
| NC-1.11 | "...never carries across to anyone else who received the same notification." | No | Requires two distinct recipient accounts sharing one notification — not testable from a single-session prototype walkthrough; implies a per-(notification, recipient) data model `[ASSUMPTION]` |
| NC-1.12 | "...absent when there are none. Two people in the same business can see different counts..." | Partial | Badge presence/count confirmed; multi-person divergence not testable in this session |
| NC-1.13 | "A notification older than 60 days is no longer in the inbox." | No | Cannot fast-forward time in a static prototype; oldest seeded item is ~58 days old (13 Jul vs. 9 Sept "today"), suggesting the boundary was deliberately seeded near the edge but not crossed |
| NC-1.14 | "The unread count falls when an unread notification is removed." | No | Same limitation as NC-1.13 |
| NC-1.15 | "No dismiss or delete action is offered anywhere in the inbox." | Yes | Confirmed — only "Mark as read" actions present, no delete/dismiss control anywhere in the UI |
| NC-1.16 | "...leaves the payment request, person, partner, or bank account it referred to unchanged." | No | Requires backend/data verification after a retention cycle; not testable from UI alone |
| NC-1.17 | "A person with no notifications sees a message telling them what the inbox is for." | No | Prototype account always has 26 seeded notifications; no route/state observed to reach the empty state |
| NC-2.1 | "Every notification addressed to a business reaches both [Owner and Admin], and reaches them in that business only." | No | Requires distinct Owner/Admin test accounts; not exercised |
| NC-2.2 | "A Member opening the inbox sees the explanation shown when it holds nothing." | No | Requires a Member-role test account; not exercised |
| NC-2.3 | "Account notifications reach Owner, Admin, and Member alike, and do not depend on which business they are working in." | No | Requires business-switch + role variation; not exercised |
| NC-2.4 | "Someone whose access has ended receives nothing further from that business." | No | Requires a removal event plus a subsequent notification trigger; cross-references Access Management PRD (UM-012/UM-019) |
| NC-2.5 | "The catalog is the single reference. No notification exists that the catalog does not list." | No | Catalog inaccessible this session `[MISSING: Notification Event Catalog access]` — cannot cross-check the ~20 distinct notification types observed in the prototype against catalog rows |

## 7. Business Rules & Data
- Retention: notifications are held exactly 60 days from creation, then removed regardless of read state (NC-1.13/1.14). The removal boundary (inclusive/exclusive of day 60) is not stated. `[ASSUMPTION]`
- Read state is scoped per person, not per notification object, and does not propagate to other recipients of the same broadcast notification (NC-1.11) — implies the backend stores a read flag per (notification, recipient) pair rather than a single shared record. `[ASSUMPTION]`
- Unread counts are computed per (person, business) pair (NC-1.3, NC-1.12).
- Channel selection, recipient list, and wording for every notification are governed exclusively by the external Notification Event Catalog (NC-2.5); this PRD defines only inbox *behavior*, not notification *content or existence*.
- Removing/expiring a notification never deletes or alters the underlying business record it references (NC-1.16).
- SMS is split into two rule sets: security messages (cannot be switched off, per Section 2) vs. informational messages (payment-request-expiry today; more to follow with financing) — the "can be switched off" preference control itself is out of scope for this document (deferred to Settings/Notification Preferences).

## 8. Edge Cases & Negative Paths
- Empty inbox for a brand-new business or a Member (NC-1.17, NC-2.2) — not reachable in the current prototype seed data.
- Exactly-60-day boundary notification (created at day 60 vs. day 61) — ambiguous per PRD wording, needs explicit confirmation.
- Very large notification volume for a long-lived business (potential hundreds of entries within the 60-day window) — no pagination, infinite-scroll, or performance requirement is stated. `[MISSING: list virtualization/pagination behavior at scale]`
- Unauthorized/cross-tenant access: a user attempting to view another business's inbox or a specific notification ID belonging to a business they no longer have access to — not explicitly covered beyond "the inbox belongs to the business the person is working in" (NC-1.2); no explicit statement of server-side authorization enforcement on a direct notification/route request.
- Concurrent actions: two devices/tabs of the same person both open the inbox and one calls "Mark all as read" while the other still shows stale unread items — cross-device consistency implied by NC-1.11 ("follows them from one device to another") but not detailed for real-time sync.
- Network failure during "Mark as read"/"Mark all as read" — no stated behavior for optimistic UI vs. rollback on failure. `[MISSING]`
- Access-ends-mid-session: a Member/Admin is removed from a business while actively viewing its inbox — does the inbox stop updating immediately, or only on next load? Cross-references Access Management PRD's "removed person's open view stops accepting actions" rule (UM-3.35/UM-019), not restated here. `[MISSING: cross-document confirmation]`
- Locale/RTL: the PRD specifies Arabic-above-English ordering for emails only; the in-app inbox's RTL/bilingual behavior is unstated, and the live prototype was only observed in English/LTR. `[MISSING]`

## 9. Cross-Story Dependencies
The Notification Center is a downstream consumer of nearly every other PRD in this set:
- **Access Management** (role changes, removals, invitations) supplies "role changed," "joined your business," "no longer has access" notifications observed in the prototype (e.g., "Faisal Al Dosari is now Member," "Yousef Al Ghamdi no longer has access"). Retention/removal timing here must stay consistent with Access Management's immediate-effect rules (UM-3.33–UM-3.38).
- **Payment Link** PRDs supply the payable/paid/expired/cancelled notification family (NC-1.7) and its deep links (`/payments/PR-...`).
- **Invoices & Credit Notes** supply "invoice past due," "invoice registration finished/not registered" notifications.
- **Business Partner / Access Management** supply "connected to your business" / "removed from your business partners" notifications.
- **Settings** (bank account, security, profile) supply account-level notifications (NC-2.3) shown regardless of the currently selected business.
- Because none of these source PRDs define the exact trigger/recipient/channel mapping (that lives only in the external catalog), **any change to those PRDs' business rules could silently create or remove a notification type without this document being updated** — a traceability risk worth flagging to Product.
- **Linear cycle tracking** (`https://linear.app/qawafel/team/ID/cycle/active`) could not be linked into this analysis at all — no ticket IDs, states, or acceptance criteria from Linear are reflected anywhere above. If Linear tracks NC-prefixed tickets separately from these PRD requirement IDs, that mapping is currently undocumented.

## 10. Risk Assessment

| Risk | Area | Likelihood | Impact | Mitigation suggestion |
|---|---|---|---|---|
| Notification Event Catalog is access-gated and was not reachable during analysis or (potentially) test design | Process/Data | H | H | Get QA a read-access copy or exported CSV/Markdown mirror of the catalog before scenario authoring starts |
| Linear board for `NC`-prefixed tickets is access-gated (Google SSO) and was not reachable; ticket status, scope changes, and any engineering caveats recorded there are unaccounted for in this analysis | Process/Traceability | H | M | Share an authenticated Linear session, an exported ticket list, or add the assistant as a workspace member with API/MCP access before the next analysis pass |
| Per-recipient read-state model (NC-1.11) is inferred, not explicit; if the backend instead shares one read flag per notification object, multi-recipient notifications would incorrectly show as read for everyone once one person opens them | Data model | M | H | Confirm the data model with Engineering before writing "shared notification, independent read state" scenarios |
| Cross-business notification leakage if the backend does not enforce business-id scoping server-side (only client-side inbox filtering) | Security | M | H | Add an explicit authorization test hitting the notifications API/route with a business-id the user does not have current access to |
| Unread/read UI renders as two separate DOM lists (unread cards vs. read rows) with no shared `<ul>`/heading, which may be announced by assistive tech as two lists despite NC-1.4's "single list" intent | Accessibility | M | M | Verify with a screen reader; consider a single semantic list with a "read"/"unread" attribute rather than two list containers |
| No pagination/virtualization requirement for a 60-day, potentially high-volume inbox | Performance | M | M | Confirm with Product whether infinite scroll, pagination, or a hard cap is intended; add a load-test scenario with 200+ seeded notifications |
| Ambiguous 60-day boundary (inclusive/exclusive) for retention removal | Data/QA | M | L | Confirm exact cutover semantics with Product before writing boundary test cases |
| Prototype header exposes a "Search" control on the Notifications page with no corresponding requirement anywhere in this PRD | Product/Scope | M | M | Confirm with Product/Design whether search-within-notifications is in scope for this release or was added ahead of documentation |
| "Mark as read"/"Mark all as read" network-failure behavior is unspecified (optimistic update vs. wait-and-confirm) | Functional | L | M | Add explicit AC for failure handling before implementation sign-off |
| In-app inbox's RTL/Arabic behavior is undocumented (only email is explicitly bilingual) | Localization | M | M | Confirm with Design whether the inbox itself needs Arabic-above-English or single-locale rendering |
| Access-ends-mid-session behavior for an open inbox is not restated here and only implied by the Access Management PRD | Cross-story consistency | L | M | Add a cross-reference note/AC in this PRD, or confirm QA should test it under the Access Management suite instead |

## 11. Open Questions
1. [Product/QA] Can the Notification Event Catalog be shared with QA (view/export access), since NC-2.5 makes it the sole source of truth for which notifications exist, who receives them, and on which channel?
2. [Product/Engineering Manager] Can the assistant (or QA) be given an authenticated way to read the Linear cycle at `https://linear.app/qawafel/team/ID/cycle/active` — e.g., a shared read-only view, an exported ticket list, or workspace access — so `NC`-prefixed tickets can be cross-checked against these PRD requirement IDs? This analysis currently has zero visibility into Linear ticket state, scope notes, or comments.
3. [Engineering] Please confirm the read-state data model: is read/unread tracked per (notification, recipient) pair, so that one recipient reading a shared notification never affects another recipient's unread state (per NC-1.11)?
4. [Design/Product] Is the "Search" icon shown in the prototype's Notifications header an intended feature for this release? It has no corresponding requirement in this PRD.
5. [Product] What is the exact 60-day retention boundary — is a notification still visible on day 60 and removed on day 61, or removed exactly at the 60-day mark?
6. [Product/Design] Does a business with a large notification volume paginate, infinite-scroll, or cap the inbox list? No requirement addresses this.
7. [Design] Should the in-app inbox follow the same Arabic-above-English bilingual pattern specified for emails, or does it render in a single locale based on the user's UI language?
8. [Engineering] What is the expected behavior when "Mark as read" or "Mark all as read" fails over the network — optimistic UI with rollback, or blocking confirmation?
9. [Product] Confirm cross-document consistency: when a person's business access ends mid-session (per Access Management's immediate-effect rules), does their already-open inbox for that business stop updating instantly, or only on next reload?

## 12. Test Strategy Recommendation
- **Test types needed:** Functional, API/contract (notification retrieval + mark-as-read endpoints), Integration (cross-PRD notification triggers from Access Management, Payment Link, Invoices, Settings), E2E (trigger → catalog routing → inbox/email/SMS delivery), Regression (Notification Center touches nearly every other module), Accessibility (single-list semantics, unread announcement), Localization (Arabic/RTL inbox rendering, bilingual email), Security (cross-business isolation), Performance (60-day volume/retention job)
- **Suggested test data:** accounts with 2+ businesses and differing roles per business (Owner in one, Member in another); notifications seeded at day 1, day 59, day 60, and day 61 relative to "now" for retention boundary testing; one notification with two recipients (e.g., Owner + Admin) to test independent read state; a payment-request notification in each of Payable/Paid/Expired/Cancelled states; a recently-removed business member to test NC-2.4
- **Environment prerequisites:** access to (or export of) the Notification Event Catalog; authenticated/shared access to the Linear cycle for `NC` tickets; ability to manipulate/seed notification `created_at` timestamps for retention testing; multi-tenant test businesses; email/SMS sandbox capture (e.g., Mailhog/test SMS gateway) to verify channel delivery and bilingual formatting
- **Reusable scenarios to extend:** none found in `scenarios/` — no existing Notification Center feature files exist; related-but-separate coverage exists in `scenarios/access_management/` (invitation/role-change emails) and could be cross-linked rather than duplicated
- **New scenarios to author:**
  - Inbox reachable for Owner, Admin, and Member
  - Business-scoped inbox contents and switching without sign-out
  - Independent unread counts per business
  - Single continuous list with no tabs/categories/headings
  - Newest-first ordering, stable after read
  - Notification entry completeness (what/when/where-to-go-next)
  - Payment-request notification reflects current standing (Payable/Paid/Expired/Cancelled)
  - Read vs. unread visual and semantic distinction
  - Mark one notification as read (via button and via opening the link)
  - Opening the inbox does not change unread state
  - Mark all as read clears count for current business only
  - Read state is device-independent for the same person
  - Read state does not propagate to a co-recipient of the same notification
  - Unread badge accuracy and per-business divergence in main navigation
  - 60-day retention removal regardless of read state, including boundary cases
  - Underlying referenced record is unaffected by notification retention removal
  - Empty-inbox explanatory state (new business, and Member business notifications)
  - Own-account notifications reach the person regardless of role or selected business
  - Access-ended person receives nothing further from that business
  - Cross-business authorization: direct route/API access to another business's notifications is denied

## 13. Readiness Verdict
**Verdict:** Conditionally ready — resolve open questions before test design finishes.
**Blockers / Conditions:**
- Notification Event Catalog access is required before NC-2.5 and the specific trigger/recipient/channel mapping for every observed notification type can be verified — without it, test design is working from inference only.
- Linear (`https://linear.app/qawafel/team/ID/cycle/active`) could not be accessed — it required a Google-authenticated sign-in that this assistant will not complete on the user's behalf. No `NC`-prefixed ticket data, status, or comments were retrieved. This analysis is traced only against the PRD's own NC-1.x/NC-2.x requirement IDs; reconcile against actual Linear ticket numbers before sign-off.
- Confirmation of the read-state data model (per-recipient vs. shared) is required before authoring the multi-recipient scenarios implied by NC-1.11.
- Multi-business and multi-role (Owner/Admin/Member) verification could not be completed against the live prototype in this session (browser interaction limits) and should be re-run before scenarios are finalized.
