# PRD Analysis: APEX Settings — SET-1 Settings Index and SET-11 Authorization

## 1. Sources Analysed
- `docs/Master APEX PRD Set (1).md` — Settings PRD, ST-1.1 through ST-6.8, Settings screens and role matrix
- `prompts/prd-analysis-prompt.md` — Senior QC analysis structure and review rules
- `SET-1 — Settings index: role-aware cards` — Linear ID-287, state: In Review
- `SET-11 — Authorization guard on business Settings routes` — Linear ID-288, state: In Review
- Existing Access Management scenarios:
  - `scenarios/access_management/business-user-management.feature`
  - `scenarios/access_management/business-invitation-sending.feature`
  - `scenarios/access_management/business-invitation-accepting.feature`

## 2. Feature Summary

The Settings index provides role-aware navigation cards for business and personal settings. Owner and Admin users should see the same business settings, while Members should see only their personal Profile card.

SET-11 adds route-level protection so hiding business cards is not the only control. Members must be refused when directly navigating to Business Profile, Bank Account, or Users and Roles routes. Profile remains available to every authenticated role.

## 3. In Scope / Out of Scope

**In scope:**
- Settings access for Owner, Admin, and Member
- Settings card visibility by role
- Business Profile, Bank Account, Users and Roles, and Profile cards
- Renaming Team Access to Users and Roles
- Navigation from each rendered card
- Direct route authorization for business Settings pages
- Business-context changes while remaining in Settings
- Profile persistence across business switching
- Owner/Admin parity
- Member restriction to Profile
- Desktop and mobile Settings presentation
- Existing Users and Roles behavior covered by Access Management

**Out of scope or deferred:**
- Notification Preferences implementation; the Settings PRD marks its content as reserved until the Notification PRD is ready
- Business Profile, Bank Account, Profile, or Notification Preferences functional details beyond the referenced Settings requirements
- Final visual copy and final visual design where the PRD describes screens as low-fidelity concepts
- Backend architecture and implementation mechanism for route authorization
- Audit-log behavior, except where the broader role-engineering PRD requires audit logging for permission-gated actions
- Settings tickets not represented by the live SET-* tickets reviewed here

## 4. Personas & Permissions

| Persona | Role | Key permissions / constraints |
|---|---|---|
| Business Owner | Owner | Can access Settings and all four current cards: Business Profile, Bank Account, Users and Roles, and Profile. |
| Business Admin | Admin | Must see the same Settings cards and actions as the Owner for the same business. |
| Business User | Member | Can access Settings but sees exactly one card: Profile. No business card or disabled business section is shown. |
| Authenticated multi-business user | Owner/Admin/Member by business | Business Settings cards follow the active business context. Profile remains person-scoped and unchanged when switching businesses. |
| Unauthenticated user | No role | Must not access authenticated Settings pages. Exact login redirect behavior is `[MISSING: unauthenticated Settings route behavior]`. |

## 5. End-to-End User Flow

### Owner or Admin

1. Sign in to APEX.
2. Open Settings from the main navigation.
3. See four cards: Business Profile, Bank Account, Users and Roles, and Profile.
4. Open each rendered card through its card navigation.
5. Switch to another accessible business without signing out or leaving Settings.
6. Confirm business cards reflect the newly active business.
7. Confirm Profile remains unchanged and appears only once.

### Member

1. Sign in to APEX.
2. Open Settings from the main navigation.
3. See exactly one card: Profile.
4. Confirm Business Profile, Bank Account, and Users and Roles are not rendered.
5. Attempt direct navigation to each business Settings route.
6. Confirm the request is refused and no part of the protected page is visible.
7. Open Profile successfully.

### Cross-role route protection

1. Owner requests each business Settings route and reaches the page.
2. Admin requests each business Settings route and reaches the page.
3. Member requests each business Settings route directly and is refused.
4. Owner, Admin, and Member request the Profile route and can reach it.

## 6. Acceptance Criteria Coverage

| Story / Section | AC stated in PRD or Linear | Testable? | Gaps |
|---|---|---|---|
| SET-1 | Settings is reachable from the main navigation for Owner, Admin, and Member. | Yes | A dedicated Settings navigation scenario is missing. |
| SET-1 | Owner and Admin see an identical set of four cards with identical actions. | Partial | Requires paired Owner/Admin comparison using the same business and seeded data. |
| SET-1 | Member sees exactly one card, Profile. | Yes | Missing dedicated Settings scenario. |
| SET-1 | No business card is rendered anywhere in Member Settings. | Yes | Missing direct UI assertion for Business Profile, Bank Account, and Users and Roles absence. |
| SET-1 | Every card rendered navigates to a page. | Yes | Missing navigation coverage for all four cards. |
| SET-1 | No Settings area is reachable except through its card. | Partial | SET-11 covers protected business routes but does not explicitly define whether direct Profile access is prohibited. |
| SET-1 | After switching business, business cards show the newly selected business. | Yes | Missing multi-business Settings scenario. |
| SET-1 | Cards available in one business and not another appear or disappear accordingly. | Partial | Requires two businesses with different available Settings areas. The PRD does not define which specific card differs. |
| SET-1 | Profile is unchanged by switching business. | Yes | Missing scenario comparing Profile values before and after business switching. |
| SET-1 | Profile appears once for a person with access to several businesses. | Yes | Missing explicit duplicate-card assertion. |
| SET-11 | A Member requesting any business Settings URL directly is refused. | Yes | Missing scenarios for Business Profile, Bank Account, and Users and Roles. |
| SET-11 | A refused Member request does not show any part of the page. | Yes | Missing explicit assertion that no page heading, card content, or business data is visible. |
| SET-11 | Owner reaches every business Settings route. | Yes | Missing route matrix coverage for Owner. |
| SET-11 | Admin reaches every business Settings route. | Yes | Missing route matrix coverage for Admin. |
| SET-11 | Profile route is reachable by every role. | Yes | Missing Owner, Admin, and Member Profile route scenarios. |
| SET-11 | Tests cover Owner, Admin, and Member against each business Settings route. | Yes | Largest current coverage gap; use a role-by-route Scenario Outline. |
| ST-1.1 | Settings is available from the main navigation to every signed-in role. | Yes | Not directly covered. |
| ST-1.2 | Each available card has a title, short description, and navigation to its own page. | Yes | No Settings scenarios cover titles, descriptions, or card navigation. |
| ST-1.3 | Owner and Admin see identical Settings and actions. | Yes | Not covered. |
| ST-1.4 | Member sees Profile only and has no business route. | Yes | User Management visibility is covered, but full Settings and direct-route behavior are not. |
| ST-1.5 | Business cards follow the active business without leaving Settings or signing out. | Yes | Not covered. |
| ST-1.6 | Profile is person-scoped, unchanged by business switching, and present once across multiple businesses. | Yes | Not covered. |
| ST-4.1 | Users and Roles card opens the complete business user/invitation list. | Yes | Existing User Management scenarios cover the destination, but not Settings-card entry. |
| ST-4.2 | Users and Roles is available only to Owner/Admin and unreachable by Member. | Yes | Existing Access Management covers part of this; SET-11 requires direct-route coverage. |
| Settings screens | Owner/Admin landing screen shows business and personal cards. | Partial | Screen reference exists, but no executable visual scenario exists. |
| Settings screens | Member landing screen shows the restricted role-aware layout. | Partial | No executable visual scenario exists. |
| Experience quality | Settings works on mobile and desktop. | Partial | No viewport-specific scenarios or visual evidence exist. |
| Experience quality | Arabic and English layouts preserve meaning and action hierarchy. | Partial | No Settings localization scenarios exist. |
| Experience quality | Keyboard focus, accessible names, and reading order support assistive technology. | No | Accessibility coverage is missing. |

## 7. Business Rules & Data

- Settings is available to every authenticated role.
- Owner and Admin receive the same Settings cards and actions for the same business.
- Member receives Profile only.
- Business cards are Business Profile, Bank Account, and Users and Roles.
- Profile is personal and not business-scoped.
- Business cards reflect the currently active business.
- Switching business does not require sign-out.
- Users and Roles is an Owner/Admin-only business area.
- Direct route authorization must independently enforce business Settings permissions.
- A Member must be blocked even when bypassing the UI.
- `[MISSING: exact refusal behavior for unauthorized direct route access]`
- `[MISSING: whether unauthorized requests return a redirect, 403 page, or generic access-denied state]`
- `[MISSING: whether unauthenticated users are redirected to login and whether the original URL is preserved]`
- `[MISSING: which business-specific cards may differ between two businesses]`
- `[MISSING: exact card titles, descriptions, and final UI copy]`
- `[MISSING: whether Bank Account supports one or multiple accounts in the current SET scope]`
- The separate deployed `ID-73 Business Settings: Bank Account Management` ticket says multiple bank accounts are supported, while Settings PRD `ST-3.1` says a business holds one bank account. This is a direct specification conflict.

## 8. Edge Cases & Negative Paths

- Owner, Admin, and Member all open Settings from the main navigation.
- Member sees no disabled, empty, or placeholder business section.
- Member directly opens Business Profile URL.
- Member directly opens Bank Account URL.
- Member directly opens Users and Roles URL.
- Member attempts to access a business route using a stale URL after their role changes.
- Admin or Member role changes while Settings is open.
- Owner/Admin business access changes while Settings is open.
- User switches business while a Settings card or route is loading.
- User switches from a business where a card is available to one where it is unavailable.
- User switches back and confirms the original business cards return.
- Profile data remains unchanged after multiple business switches.
- Multiple browser tabs hold different active business contexts.
- Settings API or authorization request fails or times out.
- Business card data partially fails while Profile remains available.
- Business with no bank account or incomplete business profile.
- Keyboard-only navigation through Settings cards.
- Screen-reader order for card title, description, and navigation action.
- Arabic/RTL layout preserves card order, text direction, and action placement.
- Mobile viewport does not hide or merge cards.
- Desktop viewport does not show duplicate or stale cards after switching business.
- Direct route access after logout does not expose Settings content.
- A role changes in another session while the current Settings page remains open.

## 9. Cross-Story Dependencies

`SET-1` controls the navigation and visible card surface. `SET-11` supplies the authorization boundary behind that surface. They must be tested together because hiding a card without protecting the route would fail the security requirement.

The Settings index depends on the active business context and business-switching mechanism. A stale active-business context could display the wrong Business Profile, Bank Account, or Users and Roles data.

The Users and Roles card depends on the Access Management flow already covered in:

- `business-user-management.feature`
- `business-invitation-sending.feature`
- `business-invitation-accepting.feature`

Those scenarios validate the destination after entry, but not the Settings-card entry point or the complete SET-11 role-by-route matrix.

Bank Account behavior depends on a conflict between the Settings PRD and deployed `ID-73`:

- Settings PRD: one bank account per business.
- `ID-73`: multiple bank accounts can be viewed and added.

This must be resolved before final Settings scenario design.

## 10. Risk Assessment

| Risk | Area | Likelihood | Impact | Mitigation suggestion |
|---|---|---:|---:|---|
| Member can bypass hidden cards through direct Business Profile, Bank Account, or Users and Roles URLs | Security | H | H | Add a role-by-route authorization matrix covering all three roles and all business routes. |
| Owner and Admin receive different Settings cards or actions despite the parity requirement | Authorization / UI | M | H | Compare rendered card sets and available actions for identical business context. |
| Settings displays stale business data after switching active business | Data / Security | M | H | Switch between two businesses and verify card content, route scope, and Profile invariance. |
| Profile data changes or duplicates after business switching | Data integrity | M | M | Assert Profile is business-independent and rendered exactly once. |
| Direct route refusal behavior is inconsistent across business Settings pages | Security / UX | M | H | Define one expected refusal contract and apply it to all protected routes. |
| Bank Account cardinality differs between the Settings PRD and ID-73 | Product / Data | H | H | Resolve one-account versus multiple-account rule before authoring executable cases. |
| Settings cards render without working navigation | UI / Functional | M | M | Validate every visible card opens the expected route. |
| A Member sees business data in a loading, error, or stale state | Security / UI | M | H | Verify no business content is present before, during, or after denied navigation. |
| Role changes are not reflected in an already-open Settings session | Security / Session | M | H | Change role in a second session and verify card visibility and route authorization refresh. |
| Mobile or RTL layouts hide cards or change action hierarchy | Accessibility / Localization | M | M | Add mobile, desktop, Arabic, keyboard, and screen-reader checks. |
| User Management entry point is correct in Settings but route behavior diverges | Integration | M | M | Link SET-1 card navigation tests to existing Access Management destination tests. |

## 11. Open Questions

1. **Product/Engineering:** What exact response should a Member receive when directly requesting a protected Settings route: redirect, 403, generic access-denied page, or another behavior?
2. **Product/Engineering:** Should unauthenticated direct access redirect to login, and should the original Settings URL be preserved after login?
3. **Product:** Does the live Settings index contain exactly four cards, or should Notification Preferences be included now? The Settings PRD marks Notification Preferences as reserved, while SET-1 explicitly defines four cards.
4. **Product/Engineering:** Is Bank Account limited to one account per business (`ST-3.1`) or does deployed `ID-73` multiple-account behavior supersede that requirement?
5. **Product/Design:** What are the final card titles, descriptions, icons, and empty-state messages?
6. **Product/Design:** Which cards should appear or disappear when switching between businesses with different configurations?
7. **Engineering:** How quickly must card visibility and route authorization update after a role change?
8. **QA/Engineering:** What seeded Owner, Admin, Member, and multi-business accounts are available for the SET-1 and SET-11 matrix?
9. **Design/Accessibility:** What is the approved Arabic/RTL layout and reading order for the Settings cards?
10. **Engineering:** Should denied direct-route requests be logged as authorization failures, and what audit data is required?

## 12. Test Strategy Recommendation

- **Test types needed:** Functional, API, Authorization/Security, Integration, E2E, Regression, Accessibility, Localization/RTL, Responsive UI, Session/concurrency.
- **Suggested test data:** Owner, Admin, Member, multi-business account, two businesses with different Settings data, verified Profile data, complete/incomplete Business Profile data, and businesses with/without bank-account data.
- **Environment prerequisites:** SET-1 and SET-11 deployed, seeded role accounts, multi-business account, stable business switching, known Settings URLs, route-response verification, mobile/desktop execution, and Arabic/RTL support or an explicit feature flag.
- **Reusable scenarios to extend:** `Member cannot reach User Management`, `Member cannot reach the Members or Invitations tabs directly`, and `User Management opens on the Members tab` in `business-user-management.feature`.
- **New scenarios to author:** Owner/Admin card parity; Member-only Profile; visible-card navigation; role-by-route authorization matrix; all-role Profile access; business switching and Profile invariance; role changes in an open Settings session; denied-route loading/error privacy; mobile/desktop hierarchy; Arabic/RTL layout; keyboard navigation and accessible names.

## 13. Readiness Verdict

**Verdict:** Conditionally ready — resolve open questions

**Blockers / Conditions:**

- Resolve the one-bank-account versus multiple-bank-account conflict between `ST-3.1` and deployed `ID-73`.
- Define the exact unauthorized direct-route response for `SET-11`.
- Confirm whether Notification Preferences is excluded from the current SET-1 release.
- Provide Owner, Admin, Member, and multi-business test data.
- Define the business-switching data variation needed to test card appearance/disappearance.
- Confirm final visual, responsive, accessibility, and RTL acceptance baselines.

The current Access Management scenarios provide reusable coverage for the Users and Roles destination, but do not cover the Settings index or the complete SET-1/SET-11 authorization matrix. Dedicated Settings scenarios are required before these tickets can be considered fully covered.
