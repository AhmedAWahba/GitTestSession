# PRD Analysis: APEX - Business User Invitation & Access Management — Access Management (3-Document Flow + Role Matrix)

## 1. Sources Analysed
- `docs/Master APEX PRD Set .md` — Access management section containing:
  - Document 1: Business User Invitation - Sending an Invitation
  - Document 2: Business User Invitation - Accepting an Invitation
  - Document 3: Business User Invitation - Users List
  - Access Management capability matrix
- `scenarios/prd1_business_registration/business-registration-test.feature` — Existing reusable multi-business sign-in/switcher scenarios
- `docs/concepts/product-concept-map.md` — [MISSING: file not found]
- `docs/concepts/concept-scenario-index.md` — [MISSING: file not found]

## 2. Feature Summary
This PRD defines how a business grants and manages user access through invitation lifecycle, invitation acceptance paths, and ongoing membership administration in a single Users list. It supports three recipient types (new to APEX, existing account holder, previous member) with different onboarding requirements before access is granted. It also defines role protections and lifecycle effects such as immediate access revocation, invitation expiry, and permanent record retention on documents. The target users are business Owner/Admin operators managing access and invited individuals joining business workspaces.

## 3. In Scope / Out of Scope
**In scope:**
- Invitation creation, validation, resend, withdrawal, and pending-role edit
- Invitation acceptance/decline, account creation/sign-in branching, identity verification, and business access grant
- Users list with statuses, role changes, removal behavior, invite-again behavior, and Owner protection
- High-level capability matrix for Owner/Admin/Member

**Out of scope:**
- Detailed roles-and-permissions authorization model beyond explicitly stated role actions in these docs ([MISSING: full permission engine spec])
- Technical design details: API contracts, event schemas, audit/event store structure, retries, idempotency, and observability
- Non-functional targets (performance/error budgets/SLOs) for invitation and Users list workflows
- Admin/system operator controls outside business-surface user management

## 4. Personas & Permissions
| Persona | Role | Key permissions / constraints |
|---|---|---|
| Business Owner | Primary business authority | Can invite; cannot be removed; Owner role cannot be granted via invitation; full platform access per matrix |
| Business Admin | Delegated business operator | Can invite; can remove Admin/Member; can be removed (except Owner is protected); full platform access per matrix |
| Business Member | Operational participant | View-only across modules per matrix; cannot invite/remove/re-invite |
| Invited Recipient (new user) | External joiner path | Must explicitly accept, then create account + complete identity verification before access |
| Invited Recipient (existing verified user) | Existing APEX account holder | Gains access immediately on accept; no re-verification |
| Invited Recipient (previous member) | Rejoining user | Gains access immediately on accept; role from latest invitation applies |

## 5. End-to-End User Flow
1. Owner/Admin opens Users area and creates invitation with recipient email + role (Admin/Member only).
2. System validates: email format, self-invite block, duplicate pending/active checks, and business-local privacy behavior.
3. On success, invitation is recorded as Pending, bilingual email is sent, and Users list entry appears (name blank).
4. Recipient opens link and sees invitation details with explicit Accept/Decline decision.
5. Recipient path branches:
6. New to APEX: accept, create account, complete identity verification, then gain access.
7. Existing verified user: accept and gain immediate access.
8. Previous member: accept and gain immediate access.
9. Invitation terminal states (declined/expired/withdrawn/already accepted) enforce non-reusability or sign-in redirect behavior per state.
10. Business manages users from one Users list: resend/withdraw/change role for Pending; change role/remove for Active; invite again for terminal statuses.
11. Removal immediately ends access and open session for that business, revokes pending invitations sent by removed user, but preserves account and document attribution history.
12. Capability usage then follows Access Management matrix (Owner/Admin full, Member view-only; financing signing restricted to Owner).

## 6. Acceptance Criteria Coverage
| Story / Section | AC stated in PRD | Testable? | Gaps |
|---|---|---|---|
| INV-1.1 | "A business Owner or Admin can invite another person" and "not available to any other role." | Partial | [MISSING: authorization source of truth and enforcement layer for role checks] |
| INV-1.2 | "collects two things only: ... email ... and role." | Yes | [MISSING: server-side schema rejection behavior if extra payload fields posted] |
| INV-1.3 | "selectable roles are Admin and Member. Owner is not selectable." | Yes | [MISSING: API-level guard if Owner submitted via tampered request] |
| INV-1.4 | "email address must be a valid email format." | Partial | [MISSING: exact validation regex/spec and i18n email normalization rules] |
| INV-1.5 | "cannot invite their own email address." | Partial | [MISSING: case-folding/alias normalization policy] |
| INV-1.6 | "already has a pending invitation ... no duplicate is created." | Partial | [MISSING: idempotency key/race handling for concurrent sends] |
| INV-1.7 | "already an active member ... no duplicate is created." | Partial | [MISSING: behavior for status transitions happening between check and commit] |
| INV-1.8 | "previously left/declined/expired/withdrawn ... existing entry returns to pending." | Partial | [MISSING: deterministic merge key for person identity across historical states] |
| INV-1.9 | "appears immediately ... name left blank until ... identity verification." | Partial | [MISSING: freshness SLA and eventual consistency constraints] |
| INV-1.10 | "permanently records ... business, role, sender, date, email." | Partial | [MISSING: storage retention, immutability mechanism, and audit retrieval scope] |
| INV-1.11 | "email is sent ... only way ... no alternative delivery channel." | Partial | [MISSING: delivery failure handling, bounce processing, retry policy] |
| INV-1.12 | "email states sender, legal business name, expiry date, link; does not state role." | Yes | [MISSING: approved template variants per locale] |
| INV-1.13 | "email is bilingual, with Arabic shown above English." | Partial | [MISSING: locale fallback, RTL rendering acceptance baseline] |
| INV-1.14 | "expires 7 calendar days ... status becomes Expired without anyone taking action." | Partial | [MISSING: timezone/cutoff definition and batch/job timing] |
| INV-1.15 | "resend ... restarts the 7-day expiry ... status remains pending." | Partial | [MISSING: cap/rate limit on resend to prevent abuse] |
| INV-1.16 | "withdrawn ... link stops working ... requires confirmation." | Partial | [MISSING: stale-link cache invalidation timing] |
| INV-1.17 | "role on pending invitation can be changed ... no new email sent." | Partial | [MISSING: recipient notification policy for silent role changes] |
| INV-1.18 | "reveals nothing about whether invited person already has an APEX account..." | Partial | [MISSING: side-channel leakage assessment (timing/error variance)] |
| INV-2.1 | "valid invitation link shows ... accept or decline." | Yes | [MISSING: anonymous rate limiting/bot mitigation] |
| INV-2.2 | "screen shows legal business name, sender name, role." | Yes | [MISSING: [ASSUMPTION] same data source as invitation snapshot] |
| INV-2.3 | "offers ... sign in and continue." | Yes | [MISSING: deep-link return behavior after sign-in] |
| INV-2.4 | "accepting is a deliberate action ... access never granted without explicitly accepting." | Partial | [MISSING: server event sequence proving consent before grant] |
| INV-2.5 | "no account ... proceeds to create one ... email address invitation was sent to." | Partial | [MISSING: locked-email enforcement mechanics on UI/API] |
| INV-2.6 | "completes identity verification: mobile, one-time code, identity details, Nafath." | Partial | [MISSING: dependency contract to upstream identity flow and failure codes] |
| INV-2.7 | "does not complete business verification... no business identifier requested." | Yes | [MISSING: negative check proving business verification endpoints not called] |
| INV-2.8 | "identity verification completes ... gains access ... status becomes Active." | Partial | [MISSING: transaction atomicity between membership grant and list update] |
| INV-2.9 | "existing verified identity gains access immediately ... no account creation or identity verification." | Partial | [MISSING: definition of verified-identity state source] |
| INV-2.10 | "previous member gains access immediately ... no identity verification." | Partial | [MISSING: [ASSUMPTION] prior verification permanence policy] |
| INV-2.11 | "one account can hold more than one business access." | Partial | [MISSING: conflict handling when invitation role differs across businesses] |
| INV-2.12 | "declining ends invitation permanently ... nothing created." | Partial | [MISSING: reversibility policy and admin visibility/audit for declines] |
| INV-2.13 | "one person can hold only one APEX account... second account not created." | Partial | [MISSING: canonical identity matching algorithm and false-positive handling] |
| INV-2.14 | "invited email already belongs to account... directed to sign in." | Yes | [MISSING: sign-in continuity with preserved invitation context] |
| INV-2.15 | "mobile already belongs to account... directed to sign in." | Partial | [MISSING: local vs global mobile uniqueness scope] |
| INV-2.16 | "link usable until accepted/declined/withdrawn/expired." | Partial | [MISSING: token replay defense and one-time nonce policy] |
| INV-2.17 | "expired invitation ... no way to proceed." | Yes | [MISSING: path for requesting resend from UI] |
| INV-2.18 | "already accepted directs person to sign in." | Yes | [MISSING: redirect target behavior for signed-in users] |
| INV-2.19 | "declined or withdrawn shows single no-longer-valid message." | Yes | [MISSING: [ASSUMPTION] anti-social-engineering rationale approved by security] |
| INV-2.20 | "stops partway ... invitation remains pending and expires normally." | Partial | [MISSING: partial-progress persistence model and TTL behavior] |
| INV-2.21 | "stopped partway and signs in ... continues from outstanding steps." | Partial | [MISSING: resume checkpoint granularity and integrity guarantees] |
| INV-2.22 | "expires/withdrawn while partway ... account and identity retained, no business access." | Partial | [MISSING: compensating action and user messaging sequence timing] |
| INV-2.23 | "has account but no business access ... no action offered." | Partial | [MISSING: escalation/help pathway and support contact policy] |
| INV-3.1 | "single Users list ... no separate list of invitations." | Yes | [MISSING: pagination/sorting defaults] |
| INV-3.2 | "entry shows name, email, role, status, actions." | Yes | [MISSING: data masking policy for sensitive fields] |
| INV-3.3 | "name is blank until identity verification complete." | Yes | [MISSING: placeholder rendering and accessibility labels] |
| INV-3.4 | "status ... one of: Pending, Active, Declined, Expired, Revoked, Removed." | Partial | [MISSING: transition state machine and forbidden transitions] |
| INV-3.5 | "all entries shown by default ... all statuses visible." | Partial | [MISSING: performance target for large lists] |
| INV-3.6 | "Owner appears ... Active." | Yes | [MISSING: tie-break behavior if ownership transfer exists elsewhere] |
| INV-3.7 | "pending entry can be resent, withdrawn, or role changed." | Yes | [MISSING: action authorization matrix by actor role version] |
| INV-3.8 | "active member role changed or removed." | Yes | [MISSING: protection rules for self-removal/self-demotion] |
| INV-3.9 | "terminal entry can be invited again ... returns existing entry to Pending." | Partial | [MISSING: historical audit retention of previous statuses/timestamps] |
| INV-3.10 | "no action on Owner ... cannot be removed or role changed." | Yes | [MISSING: hard-stop checks in backend against direct API attempts] |
| INV-3.11 | "role change immediate ... requires confirmation ... email sent." | Partial | [MISSING: notification template content and delivery retry expectations] |
| INV-3.12 | "removal immediate ... open session stops working ... requires confirmation." | Partial | [MISSING: session invalidation propagation latency/SLA] |
| INV-3.13 | "removing a person withdraws pending invitations they had sent." | Partial | [MISSING: transactional linkage model between sender and pending invites] |
| INV-3.14 | "removal does not affect draft invoices or credit notes." | Partial | [MISSING: ownership/locking semantics for in-progress drafts] |
| INV-3.15 | "name stays permanently on every document submitted." | Partial | [MISSING: legal retention jurisdiction/source and redaction exceptions] |
| INV-3.16 | "removed person with other business access continues normally." | Partial | [MISSING: cross-business session isolation test hooks] |
| INV-3.17 | "Admin can remove another Admin; only Owner protected." | Yes | [MISSING: anti-lockout rule when only one admin remains besides owner] |
| INV-3.18 | "list shows current standing, not history." | Partial | [MISSING: where historical transitions are accessible for audit] |
| Access Matrix | "All platform modules ... Owner full, Admin full, Member view only." | Partial | [MISSING: per-module permission operation matrix and API enforcement mapping] |
| Access Matrix | "View financing products details: Yes/Yes/Yes." | Yes | [MISSING: no special gap identified] |
| Access Matrix | "Apply for financing: Owner yes, Admin/Member no." | Partial | [MISSING: explicit error response for unauthorized action attempts] |
| Access Matrix | "Sign financing applications ... Owner yes, Admin/Member no." | Partial | [MISSING: signature authorization workflow and non-repudiation controls] |
| Access Matrix | "Add Admins & Members: Owner yes, Admin yes, Member no." | Partial | [MISSING: conflict with external roles-permissions module ownership] |
| Access Matrix | "Remove and Re-Invite Admins & Members: Owner yes, Admin yes, Member no." | Partial | [MISSING: approval/audit requirement for destructive member actions] |
| Access Matrix | "Remove Owner: No/No/No." | Yes | [MISSING: ownership transfer prerequisite flow reference] |

## 7. Business Rules & Data
- "The selectable roles are Admin and Member. Owner is not selectable."
- "A business has exactly one Owner... and it cannot be granted to anyone."
- "An invitation expires 7 calendar days after it is sent."
- "Resending... restarts the 7-day expiry."
- "The invitation email is bilingual, with Arabic shown above English."
- "Nothing in the invitation flow reveals whether the invited person already has an APEX account..."
- "One person can hold only one APEX account... identified by their verified identity rather than by an email address."
- "A person can hold access to more than one business on a single account."
- "A person's status... Pending, Active, Declined, Expired, Revoked, or Removed."
- "Removing an active member ends their access... immediately, including any session they currently have open."
- "Removing a person does not affect draft invoices or credit notes..."
- "Their name stays permanently on every document they submitted..."
- [ASSUMPTION] Identity uniqueness resolution and account linkage are global across the platform, not tenant-scoped.
- [ASSUMPTION] Invitation and membership writes should be atomic where a single user action implies multi-entity changes (status + list + access + notifications).

## 8. Edge Cases & Negative Paths
- Empty input: blank email and no role selected (explicitly covered); [MISSING: combined multi-error priority/order].
- Max/boundary input: invitation expiry at exactly 7-day boundary; [MISSING: timezone definition and daylight-saving edge behavior].
- Unauthorized access: Member attempts invite/remove/role-change; direct API tampering to submit Owner role.
- Concurrent actions: two admins editing same pending invitation role simultaneously; role change racing with withdrawal.
- Network failure: invite send succeeds but email provider failure/timeout; user action retried causing duplicate command delivery.
- Locale/RTL: Arabic-first bilingual email rendering and mixed-direction text correctness for names/links.
- Session invalidation race: user removed while actively submitting invoice draft in another tab.
- Replay/reopen token: expired/withdrawn/accepted links opened from cached email clients.
- Resume flow edge: recipient accepts then partially verifies identity; invitation expires before completion.
- Cross-business context: removed from one business while still active in another, ensure isolation of navigation/context.

## 9. Cross-Story Dependencies
Document 1 creates invitation state and metadata that Document 2 consumes (token validity, recipient email, role, sender, business, expiry). Document 2 outcome transitions directly drive Document 3 list states and available actions (Pending to Active, Declined, Expired, Revoked, Removed). Document 3 destructive actions (remove) feed back into invitation validity by revoking pending invites sent by the removed user, creating a dependency from membership lifecycle back to invitation lifecycle. The Access Management matrix overlays all three documents but is not fully normalized with the referenced roles-and-permissions module, creating a breakage risk where UI-visible action availability diverges from backend authorization.

## 10. Risk Assessment
| Risk | Area | Likelihood | Impact | Mitigation suggestion |
|---|---|---|---|---|
| Invitation duplicate creation under concurrent sends/resends for same email-business pair | Data | M | H | Add backend idempotency key + unique constraint on active pending tuple and concurrency tests |
| Silent permission drift between Access matrix and external roles-permissions module | Security | H | H | Define single authorization source of truth and publish role-action contract tests |
| Improper Owner protection bypass via direct API calls | Security | M | H | Enforce immutable Owner constraints server-side and add negative API tests |
| Stale invitation link usability after withdrawal due cache/token lag | API | M | M | Use signed short-lived tokens + revocation lookup on every access |
| Session revocation delay after member removal allows residual business actions | Security | M | H | Define revocation SLA, push invalidation, and block write endpoints on fresh membership check |
| Identity/account collision false matches block legitimate onboarding | Data | L | H | Document identity matching rules, add manual recovery/support path |
| Arabic/English template drift causes legal/comms inconsistency | Compliance | M | M | Golden template snapshots and locale regression tests including RTL rendering |
| No observability for "email not received" scenario inflates support burden | UI | H | M | Add delivery-status instrumentation and operator-visible resend history |
| Partial-flow resume corruption grants access without full required completion | API | L | H | Persist explicit state machine checkpoints and verify prerequisite transitions server-side |
| Multi-business context leakage after removal/switch causes data exposure | Security | L | H | Enforce tenant scoping middleware and cross-business isolation tests |

## 11. Open Questions
1. PM/Architecture: What is the definitive product/module boundary and release tag for this access-management set? [MISSING: release identifier]
2. Security/Backend: What is the canonical authorization source of truth for Owner/Admin/Member actions across UI and API?
3. Backend: What are the exact allowed status transitions among Pending/Active/Declined/Expired/Revoked/Removed?
4. Platform: How are timezone and expiry cutoffs defined for the "7 calendar days" rule?
5. Security: What anti-abuse controls exist for invite/resend rate limiting and token replay protection?
6. Product/Support: Should the no-access screen include a support/escalation path despite "No action is offered on it"?
7. Data/Identity: What exact identity matching algorithm enforces "one person can hold only one APEX account"?
8. Compliance: What retention policy source governs permanent document attribution and invitation audit metadata?
9. QA/Perf: What list performance targets apply for large businesses in the single Users list view?
10. PM/Security: Confirm [ASSUMPTION] that role change on pending invitation intentionally sends no recipient notification.

## 12. Test Strategy Recommendation
- **Test types needed:** Functional, API, Regression, Integration, E2E, Security, Accessibility, Localization
- **Suggested test data:** Owner account, Admin account, Member account, invited-new user, invited-existing verified user, invited-previous-member user, duplicate email cases, duplicate mobile case, identity-collision case, cross-business user with 2+ memberships
- **Environment prerequisites:** controllable invitation expiry clock, email service sandbox with delivery telemetry, identity verification/Nafath stubs, session-store visibility for immediate revocation checks, seeded multi-business memberships
- **Reusable scenarios to extend:** `scenarios/prd1_business_registration/business-registration-test.feature`
- **New scenarios to author:** Invite validation matrix by role and email state
- **New scenarios to author:** Pending invitation role-change without re-email and recipient-view consistency
- **New scenarios to author:** Invitation lifecycle terminal states and token replay handling
- **New scenarios to author:** Accept flow variants (new user, existing verified user, previous member)
- **New scenarios to author:** Partial onboarding resume before/after invitation expiry
- **New scenarios to author:** Users list state/action matrix with real-time transition updates
- **New scenarios to author:** Immediate session invalidation on removal across active tabs/sessions
- **New scenarios to author:** Owner immutability negative API tests
- **New scenarios to author:** Arabic-first bilingual email and RTL UI rendering checks
- **New scenarios to author:** Cross-business isolation after removal from one business

## 13. Readiness Verdict
**Verdict:** Conditionally ready - resolve open questions  
**Blockers / Conditions:** [MISSING: explicit authorization contract], [MISSING: status transition state machine], [MISSING: expiry timezone/cutoff definition], [MISSING: API/idempotency and session-revocation SLAs], [MISSING: non-functional targets for list scale and notification reliability]

---

## 14. QC Question Triage (Sorted per Access Management PRD)

> **Evaluation note (2026-08-17):** All questions were re-verified line-by-line against the PRD text. Questions removed were either answered directly in the PRD, belong to a different PRD (identity/onboarding), or are engineering/process concerns with no hook in the access management FRs. Questions added were genuine gaps not previously raised.

---

### Removed questions and reason

| Q# | Original question | Reason removed |
|---|---|---|
| Q3 | If Owner-only is the final rule, which sections need updating? | Process/action item, not a QC question on PRD content |
| Q10 | What is the definitive release/module boundary? | Release metadata — irrelevant to PRD logic gaps |
| Q11 (original framing) | Where is the permission contract for Admin vs Owner? | PRD note explicitly defers this to the roles/permissions module; not a gap in this PRD |
| Q15 | What is the exact identity matching algorithm? | Belongs to the Identity/Onboarding PRD, not Access Management |
| Q16 | What happens with ambiguous identity matches? | Same — belongs to Onboarding PRD |
| Q21 | When PRD and prototype copy diverge, which wins? | General process question with no anchor in any access management FR |
| Q22 | Is Figma or prototype the design source of truth? | Same — general governance question, not a PRD gap |
| Q24 | What are minimum observability events? | Engineering/ops concern; no FR in this PRD creates the gap |
| Q25 | What regression pack is mandatory before release? | QA planning — not a PRD analysis question |

---

### PRD 1 — Sending an Invitation

| # | Question | Status | Evidence (PRD ID) | Gap | Owner |
|---|---|---|---|---|---|
| Q1 | Does the self-invite block in INV-1.5 account for case-insensitive email and plus-alias variants? | Open | INV-1.5 — "entering the sender's own address … is blocked" — no normalization spec | Case-folding and alias handling undefined | Dev / QA |
| Q2 | When two Admins send an invitation to the same email concurrently, which wins and does a duplicate entry appear? | Open | INV-1.6 — duplicate pending blocked, but no race/idempotency contract | Concurrent-send race condition not addressed | Dev |
| Q3 | INV-1.8 says the "existing entry returns to Pending" — how is the same person identified across historical states: by email only, or by verified identity? | Open | INV-1.8 — "existing entry returns to pending" — merge key not defined | Person-identity merge key undefined | Dev / QA |
| Q4 | Is there a maximum number of resends permitted on a single pending invitation before it must be withdrawn and re-created? | Open | INV-1.15 — resend restarts expiry; no cap mentioned | Unlimited resend could be abused | Security / PM |
| Q5 | What is the exact timezone and time-of-day cutoff for the 7-calendar-day expiry? | Open | INV-1.14 — "7 calendar days" — timezone and cutoff undefined | DST and boundary edge unspecified | Dev / Platform |
| Q6 | After withdrawal, how quickly is the link invalidated — is there a CDN/cache window where it may still work? | Open | INV-1.16 — "link stops working" — no propagation latency defined | Cache invalidation timing not specified | Dev |
| Q7 | Is the role change on a pending invitation (INV-1.17) logged in an audit trail even though no email is sent? | Open | INV-1.17 — role updates silently; no audit log mention | Role-change audit trail not specified | Dev / Compliance |
| Q8 | INV-1.10 states permanent record keeping — what is the retention period and who can query the audit data? | Partially Answered | INV-1.10 — "retained for the life of the invitation and afterwards, regardless of outcome" | Retention period, query scope, and access rights not defined | Compliance / Dev |

### PRD 2 — Accepting an Invitation

| # | Question | Status | Evidence (PRD ID) | Gap | Owner |
|---|---|---|---|---|---|
| Q9 | INV-2.4 states access is never granted without explicit acceptance — what is the server-side event order that prevents a race between accept-click and access-grant? | Open | INV-2.4 — "accepting is a deliberate action" — consent-before-grant sequence not defined | Server event ordering not formalized | Dev |
| Q10 | If Nafath is unavailable when a new invited user reaches verification, what is the fallback path? | Open | INV-2.6 — identity verification steps defined; no failure/degradation path stated | Nafath outage behavior undefined for invite flow | Dev / PM |
| Q11 | What exactly constitutes a "verified identity" for the purpose of INV-2.9 immediate access — Nafath completion alone, or mobile OTP as well? | Open | INV-2.9 — "verified identity gains access immediately" — verified-identity definition not stated | Minimum verification threshold for immediate access unclear | Dev / QA |
| Q12 | INV-2.5 locks account creation to the invited email address — what happens if the recipient can no longer access that mailbox? | Open | INV-2.5 — "account is created at the email address the invitation was sent to" | No alternative path or support process defined | PM / Support |
| Q13 | INV-2.8 says status becomes Active when identity verification completes — is this update atomic with the membership grant, or can a window exist where access is open but the list still shows Pending? | Open | INV-2.8 — both outcomes stated without atomicity guarantee | Transaction boundary between access grant and list update not specified | Dev |
| Q14 | INV-2.23 shows no-access screen with no action — is there any support or contact path available, even outside the platform? | **Answered** | INV-2.23 — "The screen states that the person has no business access. It offers no action." | Explicitly no action in PRD scope; out-of-platform support path is a product decision | PM |

### PRD 3 — Users List & Access Changes

| # | Question | Status | Evidence (PRD ID) | Gap | Owner |
|---|---|---|---|---|---|
| Q15 | What are all allowed status transitions? Specifically: can Declined transition directly back to Pending via invite-again, and can Revoked? | Partially Answered | INV-3.4 — six statuses; INV-3.9 — terminal entries can be invited again; UC-3.5 confirms Declined/Expired/Revoked/Removed → Pending via invite-again | Forbidden transitions and direct-path rules not formalized as a state machine | Dev / QA |
| Q16 | Can an Admin remove themselves, or does INV-3.8 only permit removing others? | Open | INV-3.8 — "an active member can … be removed"; INV-3.17 — "Admin can remove another Admin" — self-removal not addressed | Self-removal not covered | Dev / QA |
| Q17 | What prevents the last Admin (besides the Owner) from being removed, leaving only the Owner with no delegate? | Open | INV-3.17 — "only the Owner is protected" — no anti-lockout rule for Admin seat | Last-admin lockout scenario not addressed | Dev / PM |
| Q18 | INV-3.11 states a role-change email is sent — what is the exact template content and which language(s) does it use? | Open | INV-3.11 — "an email is sent to that person" — content and locale not defined | Role-change email template undefined | Design / PM |
| Q19 | INV-3.12 states access ends "immediately" — does this mean synchronously within the same HTTP request, or is it eventual-consistency with a bounded propagation delay? | Open | INV-3.12 — "access ends at once" — synchronous vs eventual not stated | Session revocation propagation model undefined | Dev |
| Q20 | INV-3.13 states removal revokes pending invitations the removed user sent — is this in the same database transaction, or can the invite revocation lag? | Partially Answered | INV-3.13 — "withdraws any invitations … that are still pending"; UC-3.8 — described as same removal outcome | Atomicity guarantee not explicitly stated | Dev |
| Q21 | INV-3.18 says the list shows current standing only — where can a business user or auditor access the full transition history for compliance? | Open | INV-3.18 — current standing only; no history surface defined | Audit-history access mechanism not specified | Dev / Compliance |

### PRD 4 — Access Management Capability Matrix

| # | Question | Status | Evidence (PRD ID) | Gap | Owner |
|---|---|---|---|---|---|
| Q22 | The matrix says "All platform modules … Member: View only" — which specific write operations are blocked, and what UI state or API response does a Member see when they attempt one? | Open | Matrix — view only for Member; no denial UX or API response defined | Member write-denial behavior not specified | Dev / Design |
| Q23 | The matrix says "Apply for financing: Admin No" — what does an Admin see when they navigate to the financing section: is it hidden, disabled, or shown with an error? | Open | Matrix — "No (view only)"; no UI treatment for denied financing actions defined | Financing denial UX not specified | Design / PM |
| Q24 | The matrix covers current modules but says "future modules, etc" — what is the default permission assignment for a newly added module before it is explicitly configured? | Open | Matrix header — "future modules" mentioned; no default-permission fallback stated | Default permission for new modules undefined | Dev / PM |
| Q25 | There is a conflict between this matrix (Owner+Admin can invite) and Onboarding alignment FR-E-024 (Owner-only invite authority) — which is the resolved rule? | Open | Matrix — "Add Admins & Members: Owner Yes, Admin Yes"; FR-E-024 — Owner-only | Cross-PRD authority unresolved; this is a blocker for both test design and implementation | PM |

### Summary Count

| Status | PRD 1 | PRD 2 | PRD 3 | PRD 4 | Total |
|---|---|---|---|---|---|
| Answered | 0 | 1 | 0 | 0 | **1** |
| Partially Answered | 1 | 0 | 2 | 0 | **3** |
| Open | 7 | 5 | 5 | 4 | **21** |
| **Total** | **8** | **6** | **7** | **4** | **25** |

`docs/prd-analysis/apex-access-management-invitation-lifecycle.md`
