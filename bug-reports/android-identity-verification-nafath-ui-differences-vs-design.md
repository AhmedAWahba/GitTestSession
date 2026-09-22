# Mobile - Identity Verification - Nafath screen differs from design when awaiting approval

## Summary
The Android build's personal identity-verification Nafath screen differs from the provided design in the overall scale, spacing, verification-code value, waiting timer, status text, and the presence of an extra bottom action button.


## Expected Result
The personal identity-verification Nafath screen should match the provided design: it should show the heading **"التحقق الشخصي"**, progress text **"الخطوة 2 من 4"**, No extra **"افتح تطبيق نفاذ"** action button should appear below the waiting-status field in the design.

## Actual Result
 An additional black **"افتح تطبيق نفاذ"** button is displayed below the waiting-status field, while the design does not show this button.

## Evidence
- [MISSING: evidence file path] — supplied screenshot comparing the Android build panel with the design panel. The screenshot highlights the extra **"افتح تطبيق نفاذ"** button, the different verification number, timer mismatch, and compressed layout.

## Environment
- **Product:** Qawafel Android app — Registration / Identity Verification / Nafath
- **Environment:** Dev
- **Branch:** [MISSING: git branch]
- **Build:** `version2026-09-22-1.testing(905800)`
- **Date/Time:** 2026-09-22
- **Browser:** N/A — **Device:** Mobile, Honor X9b, 6.78-inch screen — **OS:** Android 15

---

**Severity:** Low — the issue is a UI/design mismatch on the Nafath approval screen and does not appear to block approval from the provided screenshot.  
**Priority:** P4