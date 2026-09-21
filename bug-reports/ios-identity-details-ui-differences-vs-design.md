# Mobile - Identity Details - Verification screen differs from design when entering identity data

## Summary
The iOS identity-details screen differs from the provided design in the title and progress count, language selector visibility, instructional copy, identity-number label, and Continue button state.



## Expected Result
The identity-details screen should match the design: it should show the title "التحقق الشخصي", progress text "الخطوة 2 من 4", no visible English language selector in the header, the instruction "أدخل بيانات هويتك للتحقق من شخصيتك.", the label "رقم الهوية الوطنية", the identity-number field, the date-of-birth field, and a black enabled Continue button.

## Actual Result
The iOS app shows the title "التحقق من الهوية" and progress text "الخطوة 2 من 3". It displays an "English" language selector that is not visible in the design panel. The instruction reads "يجب أن تطابق هذه البيانات وتلك الرسمية." instead of "أدخل بيانات هويتك للتحقق من شخصيتك.". The identity-number label reads "رقم الهوية الوطنية أو الإقامة" instead of "رقم الهوية الوطنية". The identity-number value/placeholder and date "1996/09/21" are visible in both panels, but the app's Continue button is gray and disabled while the design's button is black and enabled.

## Evidence
- [MISSING: evidence file path] — supplied screenshot comparing the iOS app (panel 1) with the design (panel 2).

## Environment
- **Product:** Qawafel iOS app — Registration / Identity Details

- **Branch:** [MISSING: git branch]
- **Build:** 1.0 (3)
- **Date/Time:** 2026-09-21
**Device:** iPhone 11 — **OS:** iOS 27.0
