# Mobile - Business Verification - Details screen differs from design when entering business data

## Summary
The iOS business-verification details screen differs from the provided design in the title and progress count, language selector visibility, instructional copy, tax-field labels, and Continue button state.

## Scenario
```gherkin
[MISSING: scenario text]
```

## Expected Result
The business-verification screen should match the design: it should show the title "التحقق التجاري", progress text "الخطوة 3 من 4", no visible English language selector in the header, the instruction "أدخل بيانات السجل التجاري لنشاطك.", the design's labels for the unified national number, VAT registration number, and optional tax identification number, and a black enabled Continue button.

## Actual Result
The iOS app shows the title "التحقق من المنشأة" and progress text "الخطوة 3 من 3". It displays an "English" language selector that is not visible in the design panel. The instruction reads "أدخل أرقام السجل التجاري. ستتحقق منها لدى الجهة المختصة." instead of "أدخل بيانات السجل التجاري لنشاطك.". The second field is labeled "الرقم الضريبي" instead of "رقم التسجيل في ضريبة القيمة المضافة", and the third field is labeled "الرقم الضريبي للمنشأة (اختياري)" instead of "رقم التعريف الضريبي (اختياري)". The displayed values in the three fields match between the panels, but the app's Continue button is gray and disabled while the design's button is black and enabled.

## Evidence
- [MISSING: evidence file path] — supplied screenshot comparing the iOS app (panel 1) with the design (panel 2).

## Environment
- **Product:** Qawafel iOS app — Registration / Business Verification
- **Environment:** [MISSING: Dev | QA | Staging | Prod] — [MISSING: URL]
- **Branch:** [MISSING: git branch]
- **Build:** 1.0 (3)
- **Date/Time:** 2026-09-21
- **Browser:** [MISSING: browser + version] — **Device:** iPhone 11 — **OS:** iOS 27.0
