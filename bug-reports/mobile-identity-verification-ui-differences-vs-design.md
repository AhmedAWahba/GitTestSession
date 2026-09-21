#[Bug][iOS] Mobile - Identity Verification - UI differs from design when entering phone number

## Summary
The iOS build's identity-verification phone-number screen differs from the provided design in the heading and progress copy, instructional text, phone-number field presentation, and Continue button state.

## Expected Result
The identity-verification phone-number screen should match the provided design: it should show the heading "التحقق الشخصي", progress text "الخطوة 2 من 4", the instruction "أدخل رقم جوالك لاستلام رمز التحقق.", the phone number in the design's right-aligned format with the phone icon on the right, and a black enabled Continue button.

## Actual Result
The iOS build shows the heading "التحقق من الهوية" and progress text "الخطوة 2 من 3". It displays "سنرسل رمزًا من ست خانات إلى هذا الرقم عبر رسالة نصية." instead of the design instruction. The phone field shows "+966" on the left, a phone icon inside the field, and the placeholder "5XXXXXXXX"; the design shows "05XXXXXXXX" right-aligned with the phone icon on the right. The iOS build's Continue button is gray and disabled, while the design's button is black and enabled.

## Evidence
- [MISSING: evidence file path] — supplied screenshot comparing the iOS build (panel 1) with the design (panel 2). The attached chat image could not be copied into the workspace evidence folder.

## Environment
- **Product:** Qawafel iOS app — Identity Verification
- **Build:** 1.0 (3)
- **Date/Time:** 2026-09-21
- **Device:** iPhone 11 — **OS:** iOS 27.0
