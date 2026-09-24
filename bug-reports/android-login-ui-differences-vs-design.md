# Mobile - Sign In - Excessive spacing appears below password field

## Summary
The Android build's sign-in screen has excessive vertical padding between the password text field and the **"نسيت كلمة المرور؟"** link compared with the provided design.

## Scenario
```gherkin
[MISSING: scenario text]
```

## Expected Result
The sign-in screen should match the provided design: the **"نسيت كلمة المرور؟"** link should appear close to the password text field, directly below it with compact vertical spacing.

## Actual Result
The Android build shows a wide empty padding area between the password text field and the **"نسيت كلمة المرور؟"** link. The link is visually pushed too far below the password field compared with the design.

## Evidence
- [MISSING: evidence file path] — supplied screenshot comparing the Android build panel with the design panel. The screenshot highlights the excessive spacing between the password field and **"نسيت كلمة المرور؟"** link.

## Environment
- **Product:** Qawafel Android app — Sign In
- **Environment:** Dev
- **Branch:** [MISSING: git branch]
- **Build:** `version2026-09-22-1.testing(905800)`
- **Date/Time:** 2026-09-22
- **Browser:** N/A — **Device:** Mobile, Honor X9b, 6.78-inch screen — **OS:** Android 15

---

**Severity:** Low — the issue is a UI/design mismatch on the sign-in screen and does not appear to block login from the provided screenshot.  
**Priority:** P4