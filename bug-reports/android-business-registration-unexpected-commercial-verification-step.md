# [Mobile] - Registration: Commercial verification step appears despite being absent from design

## Summary

In Android dev build `version2026-09-22-1.testing(905800)`, the business registration flow displays an Arabic **"التحقق التجاري"** screen at step **"الخطوة 3 من 4"** showing detected commercial registration details and requiring confirmation. This screen is not present in the provided design and should be removed from the registration steps.

## Scenario

```gherkin
[MISSING: scenario]
```

## Expected Result

The registration flow should follow the approved design steps only. The **"التحقق التجاري"** commercial verification screen should not appear as a separate registration step, and users should proceed through the designed registration sequence without being asked to confirm this extra commercial-registration details screen.

## Actual Result

The Android app shows an additional **"التحقق التجاري"** screen with progress text **"الخطوة 3 من 4"**. The screen states that a commercial registration was found and asks the user to confirm registration. It displays a commercial-registration details card with company name **"شركة السجل التجاري المحلية"**, labels including **"الرقم الوطني الموحد"**, **"رقم السجل التجاري"**, and **"رقم التسجيل في ضريبة القيمة المضافة"**, plus **"تأكيد"** and **"رجوع"** actions. This screen is not included in the design and should be removed from the registration flow.

## Evidence

- Evidence will be uploaded manually to Linear — supplied screenshot from Android dev app showing the unexpected **"التحقق التجاري"** screen at **"الخطوة 3 من 4"** with commercial-registration details and a **"تأكيد"** button.

## Environment

- **Product:** Qawafel Android app — Business Registration
- **Environment:** Dev
- **Build:** `version2026-09-22-1.testing(905800)`
- **Branch:** [MISSING: git branch]
- **Date/Time:** 2026-09-22
- **Browser:** N/A — **Device:** Mobile, Honor X9b, 6.78-inch screen — **OS:** Android 15

---

**Severity:** Medium — the registration flow includes an undesigned extra screen that can confuse users and adds an unintended confirmation step, but the screenshot does not show a crash or blocked state.  
**Priority:** P3