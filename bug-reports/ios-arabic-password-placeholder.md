# [bug][ios][localization] Password placeholder differs from reference

## Summary
The empty Password field displays minimum-length guidance instead of the expected Arabic entry prompt used in the supplied reference.

## Scenario
```gherkin
Scenario: Display the expected Arabic password placeholder
  Given I am a user on Create Account with Arabic selected
  When the Password field is empty
  Then its placeholder should display "أدخل كلمة المرور"
```

## Expected Result
Display "أدخل كلمة المرور" in the Password field, matching the supplied reference and the Web/Android behavior identified by the reporter.

## Actual Result
- The empty Password field displays "12 حرفًا على الأقل".

## Evidence
![Highlighted iOS Password field](../evidence/UI%20comparison%20of%20registration/ios-arabic-1.0.0-22/ios-password-placeholder-highlight.png)

## Environment
- **Product:** Qawafel iOS - Registration / Account Setup
- **App version:** 1.0.0 (22)
- **OS:** iOS 27.2
- **Language:** Arabic
- **Report date:** 2026-11-04
- **Device model:** [MISSING: device model]
- **Environment / branch:** [MISSING: environment and branch]