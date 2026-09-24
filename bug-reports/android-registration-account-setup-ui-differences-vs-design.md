# Mobile - Registration - Account setup screen differs from design when creating account

## Summary
The Android build's registration account-setup screen differs from the provided design in the header spacing, progress indicator position, instructional text layout, field-label alignment, placeholder copy, and overall vertical sizing of the form controls.

## Scenario
```gherkin
[MISSING: scenario text]
```

## Expected Result
The registration account-setup screen should match the provided design: it should show the , the instruction **"أنشئ حسابك باستخدام بريدك الإلكتروني للعمل وكلمة مرور"**, right-aligned field labels, password placeholder text should show  **"8 احرف علي الاقل "**, and form controls sized and spaced consistently with the design panel.

## Actual Result
The Android build shows the same title **"التسجيل"** and progress text **"الخطوة 1 من 4"**, The email label **"بريد العمل الإلكتروني"** appears misaligned relative to the design, and the instruction line overlaps visually with the email-label area. The password placeholder shows **"أدخل كلمة المرور"** while the design shows **"8 أحرف على الأقل"**. 

## Evidence
- [MISSING: evidence file path] — supplied screenshot comparing the Android build panel with the design panel. The screenshot highlights differences in instructional text placement, **"بريد العمل الإلكتروني"** label alignment, and password placeholder text.

## Environment
- **Product:** Qawafel Android app — Registration / Account Setup
- **Environment:** Dev
- **Branch:** [MISSING: git branch]
- **Build:** `version2026-09-22-1.testing(905800)`
- **Date/Time:** 2026-09-22
- **Browser:** N/A — **Device:** Mobile, Honor X9b, 6.78-inch screen — **OS:** Android 15

---

**Severity:** Low — the issue is a UI/design mismatch on the registration account setup screen and does not appear to block account creation from the provided screenshot.  
**Priority:** P4