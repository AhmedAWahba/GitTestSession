# UAT registration - validation localization and prototype discrepancies

## Environment

- Execution date: 2026-10-25.
- UAT: https://apex.qawafel.dev/signup
- Reference: https://apex-web-app-prototype.vercel.app/signup/account (live prototype; revision not pinned).
- Windows, VS Code integrated browser; Chrome 150.0.7871.250 / Electron 43.6.0.
- Browser languages: `en-US`, `ar-EG`; application languages: English and Arabic.
- Build: not recorded. Device pixel ratio: 1.25; viewport varied during capture, so screenshots are not pixel-comparison baselines.
- [Execution report and full screenshot checklist](../evidence/registration-validation/2026-10-25/REPORT.md).
- No external issue-tracker tickets were created. The findings below are locally documented, with severity recommendations rather than assigned product priorities.

## REG-L10N-001 - Arabic registration leaves Back untranslated

**Severity:** Low. **Status:** Reproduced against live prototype.

### Steps
1. Open UAT signup.
2. Activate the language switch to Arabic.
3. Inspect the navigation link above the registration heading.
4. Open the prototype signup page and switch it to Arabic.

**Expected:** Arabic navigation text, matching prototype "السابق".

**Actual:** UAT displays "Back" while the surrounding form is Arabic and the document direction is RTL.

**Evidence:** [UAT Arabic](../evidence/registration-validation/2026-10-25/ar/account/initial.png), [prototype Arabic](../evidence/registration-validation/2026-10-25/prototype/ar/account/navigation.png).

## REG-L10N-002 - Confirmation validation copy differs from prototype in both languages

**Severity:** Low. **Status:** Reproduced; confirm prototype revision before copy acceptance.

### Steps
1. Open UAT signup in English.
2. Enter email `qa-registration@example.com` and password `Owner@123456789`.
3. Enter confirmation `Different@123456789` and move focus away.
4. Wait for asynchronous validation and inspect the inline error.
5. Repeat in Arabic, then repeat the same mismatch in the prototype.

**Expected:** English "Passwords do not match."; Arabic "كلمتا المرور غير متطابقتين." as shown in the prototype.

**Actual:** English "does not match password"; Arabic "لا يطابق كلمة المرور". Errors exist in both languages, so this is a copy discrepancy, not a missing-message defect. Correcting confirmation clears the error.

**Evidence:** [UAT English](../evidence/registration-validation/2026-10-25/en/confirmation/mismatch-blur.png), [prototype English](../evidence/registration-validation/2026-10-25/prototype/en/confirmation/mismatch-blur.png), [UAT Arabic](../evidence/registration-validation/2026-10-25/ar/confirmation/mismatch-blur.png), [prototype Arabic](../evidence/registration-validation/2026-10-25/prototype/ar/confirmation/mismatch-blur.png).

## REG-L10N-003 - Arabic empty submission relies on English browser validation

**Severity:** Medium candidate. **Status:** Reproduced in English-language browser; confirm application-language policy.

### Steps
1. Use a browser whose preferred UI language is English (`en-US` in this run).
2. Open UAT signup and select Arabic. Verify `html[lang="ar"][dir="rtl"]`.
3. Leave all inputs untouched and empty.
4. Focus the email input and press Enter to submit.
5. Inspect the email input's `validity.valueMissing` and `validationMessage`.
6. Repeat an empty submission on the Arabic prototype.

**Expected:** Under the requested cross-language message requirement, required-field feedback should be Arabic when the application is Arabic. The prototype displays Arabic inline email/password errors on empty submission.

**Actual:** Native validation blocks submission and reports "Please fill out this field." in English. Browser-native copy follows browser language rather than the application's selected language. Separately, touching/clearing fields produces Arabic application inline errors, so the application translations are not universally missing.

**Evidence:** [UAT Arabic empty submission](../evidence/registration-validation/2026-10-25/ar/account/empty-submit.png), [prototype Arabic empty submission](../evidence/registration-validation/2026-10-25/prototype/ar/account/empty-submit.png). English native text was read through `HTMLInputElement.validationMessage`; the PNG does not prove native popover contents. Recheck in a standalone supported browser before release classification.

## REG-SPEC-004 - Continue remains enabled despite invalid fields

**Severity:** Pending requirement resolution. **Status:** Specification discrepancy, not confirmed against prototype.

### Steps
1. Open UAT signup with empty fields and inspect `#signup-submit.disabled`.
2. Fill a valid email and matching password/confirmation `Aa1!aaaaaaa` (11 characters).
3. Blur the fields, wait for the minimum-length inline error, and inspect Continue again.
4. Repeat in Arabic.

**Expected from repository scenario:** Continue is disabled for empty or invalid required input.

**Actual:** Continue is enabled (`disabled=false`) on empty and invalid states in both languages. The prototype also enables Continue on the empty form. This run does not demonstrate that invalid data can be successfully registered; no invalid password submission was attempted.

**Evidence:** [English invalid password](../evidence/registration-validation/2026-10-25/en/password/length-11.png), [Arabic invalid password](../evidence/registration-validation/2026-10-25/ar/password/length-11.png), [source scenarios](../scenarios/prd1_business_registration/business-registration-test.feature).

**Resolution needed:** Confirm whether the released contract is disabled-until-valid or enabled-submit-with-errors, then align implementation, prototype, and scenarios.