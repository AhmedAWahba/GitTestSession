# Mobile - Email Verification - OTP screen differs from design when entering code

## Summary
The iOS build's email-verification OTP screen differs from the provided design in the screen title, progress count, language control visibility, email text casing, and resend/expiry timer messaging.


## Expected Result
The email-verification OTP screen should match the provided design: it should show the title "التسجيل", progress text "الخطوة 1 من 4", the design's header controls without the visible English language selector, the email address as shown in the design, and the design's timer messages: "إعادة الإرسال خلال: 43s" and "ينتهي الرمز خلال 4:43".

## Actual Result
The iOS build shows the title "إعداد الحساب" and progress text "الخطوة 1 من 3". It displays an "English" language selector that is not visible in the design panel. The email text is shown as "test@gmail.com", while the design shows "Test@gmail.com". The iOS build shows "ينتهي الرمز خلال 2:25" and "إعادة الإرسال خلال 25s", which differ from the design's visible timer messages "إعادة الإرسال خلال: 43s" and "ينتهي الرمز خلال 4:43".

## Evidence
- [MISSING: evidence file path] — supplied screenshot comparing the iOS build (panel 1) with the design (panel 2).

## Environment
- **Product:** Qawafel iOS app — Registration / Email Verification
- **Environment:** [MISSING: Dev | QA | Staging | Prod] — [MISSING: URL]
- **Branch:** [MISSING: git branch]
- **Build:** 1.0 (3)
- **Date/Time:** 2026-09-21
- **Browser:** [MISSING: browser + version] — **Device:** iPhone 11 — **OS:** iOS 27.0
