# [bug][ios][localization] Arabic email-validation wording differs from reference

## Summary
The Arabic Work Email validation message on iOS uses different wording from the supplied reference.

## Scenario
```gherkin
Scenario: Display the expected Arabic email-validation message
  Given I am a user on Create Account with Arabic selected
  When I leave Work Email empty and tap Continue
  Then the email-validation message should match the reference wording
```

## Expected Result
Display "أدخل عنوان بريد إلكتروني عمل صالح." as shown in the supplied reference.

## Actual Result
- iOS displays "أدخل بريدًا إلكترونيًا صحيحًا." beneath the Work Email field.

## Evidence
![Arabic email-validation comparison](../evidence/UI%20comparison%20of%20registration/ios-arabic-1.0.0-22/ios-arabic-email-validation-comparison.png)

## Environment
- **Product:** Qawafel iOS - Registration / Account Setup
- **App version:** 1.0.0 (22)
- **OS:** iOS 27.2
- **Language:** Arabic
- **Report date:** 2026-11-04
- **Device model:** [MISSING: device model]
- **Environment / branch:** [MISSING: environment and branch]