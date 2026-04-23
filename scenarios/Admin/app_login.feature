Feature: Qawafel App Login & Vendor Store Access
  As a Qawafel platform user
  I want to authenticate via mobile OTP and access vendor stores
  So that I can manage my account and browse vendor products

  Background:
    Given the Qawafel app is open at "https://app.development.qawafel.dev/home"
    And any popups or modals are dismissed

  @login @admin @smoke
  Scenario: Successful admin login
    When the user logs in with mobile "538989808" and OTP "201111"
    Then the user should be on the home page
    And the greeting message should display the vendor name

  @login @vendor-store
  Scenario: Navigate to vendor store preview and login
    Given the user is logged in with mobile "538989808" and OTP "201111"
    When the user switches to vendor "الواهب 2 الحلويات الشرقية"
    And the user navigates to "الإدارة" > "تهيئة المتجر الالكتروني للشركة"
    And the user clicks "معاينة" to open the store preview
    And the user cancels preview mode by clicking "إلغاء وضع المعاينة"
    Then the vendor store should be displayed without preview banner
    When the user logs into the vendor store with mobile "538989802" and OTP "201111"
    Then the user should be authenticated on the vendor store
    And the user profile name should be visible in the header

  @login @negative
  Scenario: Login attempt with empty mobile number
    When the user submits the login form without entering a mobile number
    Then the submit button should remain disabled
    And a validation message should indicate the mobile number is required

  @login @negative
  Scenario: Login attempt with incorrect OTP
    When the user logs in with mobile "538989808" and an incorrect OTP "000000"
    Then the error message "رمز التحقق غير صحيح" should be displayed
    And the user should remain on the OTP verification screen

  @login @negative
  Scenario: Login attempt with invalid mobile number format
    When the user enters mobile "123" in the login form
    Then the submit button should remain disabled
    And the mobile input should only accept valid Saudi mobile number format
