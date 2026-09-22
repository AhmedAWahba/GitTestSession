# Mobile - Identity Details - Verification screen differs from design when entering identity data

## Summary
The Android build's personal identity-details verification screen differs from the provided design in the presence of an extra guidance card, date-of-birth field content, field spacing, and overall vertical layout.


## Expected Result
The identity-details screen should match the provided design: it should show  No green informational guidance card should appear between the instruction and identity-number field in the design.

## Actual Result
The Android build shows  an extra green informational card between the instruction and identity-number field with the text **"تأكد من مطابقة جميع البيانات لوثائقك الحكومية الرسمية. عدم التطابق هو السبب الأكثر شيوعاً لتأخر التحقق."**. 
## Evidence
- [MISSING: evidence file path] — supplied screenshot comparing the Android build panel with the design panel. The screenshot highlights the extra green informational card, the date-of-birth field placeholder, and the shifted form layout.

## Environment
- **Product:** Qawafel Android app — Registration / Identity Verification / Identity Details
- **Environment:** Dev
- **Branch:** [MISSING: git branch]
- **Build:** `version2026-09-22-1.testing(905800)`
- **Date/Time:** 2026-09-22
- **Browser:** N/A — **Device:** Mobile, Honor X9b, 6.78-inch screen — **OS:** Android 15

---

**Severity:** Low — the issue is a UI/design mismatch on the identity-details screen and does not appear to block continuation from the provided screenshot.  
**Priority:** P4