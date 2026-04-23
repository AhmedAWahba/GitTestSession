Feature: Vendor App Login  
  

  # ==================== Positive Cases ====================

  Scenario: Successful login with valid mobile and OTP
    Given the vendor is on the login page "https://app.development.qawafel.dev/login"
    When the vendor enters a valid mobile number "540000111"
    And the vendor clicks the "Login" button
    And the vendor enters a valid OTP "201111"
    And the vendor clicks the "Verify" button
    Then the vendor should be redirected to the home page


  # ==================== Negative Cases ====================

  Scenario: Login fails with incorrect OTP
    Given the vendor is on the login page "https://app.development.qawafel.dev/login"
    When the vendor enters a valid mobile number "540000111"
    And the vendor clicks the "Login" button
    And the vendor enters an incorrect OTP "000000"
    And the vendor clicks the "Verify" button
    Then the vendor should see an error message 

  Scenario: Login fails with unregistered mobile number
    Given the vendor is on the login page "https://app.development.qawafel.dev/login"
    When the vendor enters an unregistered mobile number "540000999"
    And the vendor clicks the "Login" button
    Then the vendor should see an error message 

  Scenario: Login fails with invalid mobile format
    Given the vendor is on the login page "https://app.development.qawafel.dev/login"
    When the vendor enters an invalid mobile number "123"
    And the vendor clicks the "Login" button
    Then the vendor should see a validation message 


  # ==================== Empty Fields ====================

  Scenario: Login fails when mobile number is empty
    Given the vendor is on the login page "https://app.development.qawafel.dev/login"
    When the vendor leaves the mobile number field empty
    And the vendor clicks the "Login" button
    Then the vendor should see a validation message 

  Scenario: Login fails when OTP is empty
    Given the vendor is on the login page "https://app.development.qawafel.dev/login"
    When the vendor enters a valid mobile number "540000111"
    And the vendor clicks the "Login" button
    And the vendor leaves the OTP field empty
    And the vendor clicks the "Verify" button
    Then the vendor should see a validation message 


  # ==================== Field-Level Validation ====================

  Scenario: Mobile field does not accept whitespace-only input
    Given the vendor is on the login page "https://app.development.qawafel.dev/login"
    When the vendor enters mobile number "   "
    And the vendor clicks the "Login" button
    Then the vendor should see a validation message 

  Scenario: OTP field accepts only numeric values
    Given the vendor is on the login page "https://app.development.qawafel.dev/login"
    When the vendor enters a valid mobile number "540000111"
    And the vendor clicks the "Login" button
    And the vendor enters OTP "abc123"
    And the vendor clicks the "Verify" button
    Then the vendor should see a validation message 

  Scenario: Login fails with OTP containing only spaces
    Given the vendor is on the login page "https://app.development.qawafel.dev/login"
    When the vendor enters a valid mobile number "540000111"
    And the vendor clicks the "Login" button
    And the vendor enters OTP "      "
    And the vendor clicks the "Verify" button
    Then the vendor should see an error message 