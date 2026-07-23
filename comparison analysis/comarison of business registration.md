# Business Registration PRD vs Prototype - Combined Findings (Excel Ready)

Copy each section from the header row and paste directly into Excel.
Format: TSV (tab-separated values).

## Registration

Area	PRD Expectation	Prototype Behavior	Consolidated Result	Comment
Registration structure	Single mandatory 5-step flow	3-phase, 9-screen flow	Mismatch	Major structural divergence that changes journey orchestration.
Step 1 field grouping	National ID/Iqama, DOB, UNN, VAT, TIN, Mobile, Email together	Fields split across multiple screens/phases	Mismatch	Validation timing and user progression differ.
Password placement	Password setup after identity/business entry	Password collected on first account screen	Mismatch	Changes funnel order and early failure points.
Intermediate authentication	No re-login step during registration	Sign in to continue appears mid-registration	Mismatch	Not represented in baseline flow expectations.
Identity fields repetition	Identity details entered once	Identity details re-entered later	Mismatch	Clarify whether re-entry is intentional confirmation or UX redundancy.
Mobile number capture pattern	Collected once and reused	Captured early and reconfirmed later	Mismatch	Clarify whether second capture is mandatory.
Bank step entry point	Final optional IBAN step after core verification	Final phase includes optional bank/IBAN step	Partially aligned	Intent matches, but positioned inside a different phase model.

## Login

Area	PRD Expectation	Prototype Behavior	Consolidated Result	Comment
Sign-in default verification	Coworker baseline says OTP not mandatory; analyzed PRD baseline says OTP mandatory after credentials	OTP required after valid email/password	Ambiguous	Conflict likely due to different PRD snapshots.
Forgot-password verification model	Coworker baseline says email-link reset; analyzed PRD baseline says identity plus OTP reset	Identity form plus OTP before reset password	Ambiguous	Confirm approved reset model for release.
Account-safe error policy	Should avoid account existence disclosure	Prototype paths include specific mismatch variants	Potential mismatch	Depends on exact UI copy shown to end users in production.

## Verification

Area	PRD Expectation	Prototype Behavior	Consolidated Result	Comment
Signup verification method	Coworker baseline says email-link verification; analyzed PRD baseline says OTP-led verification	6-digit OTP screen used during signup	Ambiguous	PRD baseline appears inconsistent across versions; confirm source-of-truth PRD revision.
Mobile verification checkpoint	Mobile OTP before Nafath in onboarding continuation	Mobile OTP step with timer/resend exists	Aligned	No functional gap observed.
Identity confirmation input	National ID/Iqama plus DOB before Nafath	Identity confirmation step captures same inputs before Nafath	Aligned	Core sequencing is consistent.
Nafath success and failure states	Success, rejection, timeout, initiation failure expected	All listed states present, plus retry/regenerate	Aligned	Strong state coverage in prototype.
Nafath challenge UX	2-digit challenge with controlled session behavior	2-digit challenge, timer, retry/regenerate paths	Aligned	No functional gap observed.
Account creation timing	Account should be created after Nafath success	Account appears created earlier (post email-OTP, pre-Nafath)	Mismatch	Potential pre-verified account lifecycle risk.
Arabic legal business name visibility	Retrieved from registry and stored (not clearly user-facing)	Shown as read-only field with registry source note	Mismatch	UI exposure differs from silent-storage expectation.
Informational banner position	Shown at top of initial registration step	Shown later in identity-confirmation step	Mismatch	Guidance timing is shifted.
Step navigation behavior	Back allowed on early steps, blocked after Nafath success	Back control visibility varies by screen	Mismatch	Needs exact navigation spec alignment.
UNN verification timing	Coworker baseline: after onboarding continuation; analyzed PRD baseline: Step 1 checks	UNN checks in business verification phase	Ambiguous	Requirement timing differs across available baselines.
Owner identity match dependency	Verified identity must match legal owner before owner access	Explicit owner identity mismatch failure path present	Aligned	Coverage present.
