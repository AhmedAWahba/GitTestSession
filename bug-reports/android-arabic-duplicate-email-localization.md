# [bug][android][localization] Duplicate-email error remains English in Arabic mode

## Summary
The duplicate-email validation message remains English on the Arabic Create Account screen, while the surrounding heading and field labels are localized.

## Scenario
```gherkin
Scenario: Localize duplicate-email feedback in Arabic
  Given I am a user on Create Account with Arabic selected
  When I submit registration details using an already-registered email
  Then the duplicate-email validation message should appear in Arabic
```

## Expected Result
Display the duplicate-email validation message in Arabic when Arabic is the selected application language.

## Actual Result
- The Arabic Create Account screen displays "An account already exists for this email." in English.

## Evidence
![Android English and Arabic duplicate-email comparison](../evidence/UI%20comparison%20of%20registration/android-arabic/android-duplicate-email-localization-comparison.png)

## Environment
- **Product:** Qawafel Android - Registration / Account Setup
- **App version/build:** `2026 - 11 - 04-979b446.testing`, copied from [ID-466](https://linear.app/qawafel/issue/ID-466/buguilocalization-duplicate-email-validation-differs-across-platforms)
- **Device:** Honor X9b
- **OS:** Android 15
- **Application language:** Arabic; English screenshot supplied as comparison baseline
- **Evidence date:** 2026-11-04, from screenshot filenames
- **Report date:** 2026-11-05
- **Backend environment / branch:** Not provided