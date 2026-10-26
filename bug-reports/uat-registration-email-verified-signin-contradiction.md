# UAT registration - Email verified badge contradicts sign-in rejection

## Summary

The sign-in result for `technosteelg2@gmail.com` simultaneously shows an Email verified badge/success description and the blocking alert "Verify your email before signing in." The user reported completing email verification. Two sign-in submissions were observed: one with Arabic selected and one with English selected. Both returned the verification block.

This report establishes contradictory UI feedback, not the actual backend verification state. No database, verification link, or provider logs were inspected. An incorrect badge, incomplete verification, or synchronization issue remains possible; root cause is unconfirmed.

## Environment

- Date: 2026-10-26.
- UAT: https://apex.qawafel.dev/login
- Account: `technosteelg2@gmail.com`, supplied by the user.
- Browser: shared VS Code integrated browser on Windows.
- Languages: Arabic and English. In Arabic mode, the surrounding form and verified-email badge translate, but the blocking alert remains English.
- Build identifier: not exposed/recorded.

## Reproduction

1. Use the newly registered account after the user reports clicking its email verification link.
2. Open Sign in, select Arabic, and submit the account's registration credentials through the normal form.
3. Observe the blocking alert and the verified-email badge on the returned page.
4. Select English and make one fresh sign-in submission.
5. Observe the same contradictory result.

## Expected

The verified-email badge, success description, and sign-in decision reflect a consistent verification state. If verification is incomplete, the page must not claim it is complete. If verification is complete and the other authentication checks pass, it must not block sign-in for unverified email. Blocking feedback must follow the selected application language.

## Actual

- English: "Verify your email before signing in." appears alongside "Email verified" and "Your email is verified. Please sign in to continue."
- Arabic: the same English blocking alert appears alongside the Arabic verified-email badge and description.
- The browser remains on Sign in; no Iqama/identity-editing field is available.

## Evidence

- [English result](../evidence/registration-validation/2026-10-26/new-registration/en/signin-verification-conflict.png)
- [Arabic result](../evidence/registration-validation/2026-10-26/new-registration/ar/signin-verification-conflict.png)

## Execution impact

The requested Iqama change could not be performed because sign-in did not complete. The remembered synthetic value `2000000055` remains selected for a future editable identity step; it has not been entered or saved to this account. Its global uniqueness, real issuance, and business-owner association are unverified.

No account reset, verification bypass, password reset, or additional verification email was initiated in this attempt. Passwords, verification links, and onboarding tokens are not recorded here. No external issue-tracker ticket was created.

**Severity recommendation:** Medium for inconsistent verification/authentication feedback; the flow is blocked for this account, but backend verification correctness is not established.