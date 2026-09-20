// iOS registration flow automation for BrowserStack App Automate.
// SELECTORS are placeholders: after running capture-screen.js against the real app,
// replace each `~placeholder` accessibility id below with the real one from the
// saved .xml page-source dumps in ios-automation/output/.
//
// Usage: node ios-automation/run-ios-registration.js

const fs = require('fs');
const path = require('path');
const { remote } = require('webdriverio');
const { getRemoteOptions } = require('./capabilities');

const OUTPUT_DIR = path.join(__dirname, 'output');

// TODO: replace with real accessibility ids / predicates found via capture-screen.js
const SELECTORS = {
  emailField: '~email-address-field',
  passwordField: '~password-field',
  confirmPasswordField: '~confirm-password-field',
  continueButton: '~continue-button',
  emailOtpField: '~email-otp-field',
  mobileNumberField: '~mobile-number-field',
};

// Same deterministic values used in the Android QA build's fake server, per
// builds/qa-auth-flow/magic-values.md. Update if the iOS build uses different stubs.
const TEST_DATA = {
  email: 'buyer@example.com',
  password: 'Qawafel1234-',
  emailOtp: '123456',
  mobileNumber: '512345670',
};

async function captureStep(driver, label) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  await driver.saveScreenshot(path.join(OUTPUT_DIR, `${label}.png`));
  fs.writeFileSync(path.join(OUTPUT_DIR, `${label}.xml`), await driver.getPageSource());
  console.log(`Captured step: ${label}`);
}

async function main() {
  const driver = await remote(getRemoteOptions('Registration flow'));

  try {
    await captureStep(driver, '01-launch');

    const emailField = await driver.$(SELECTORS.emailField);
    await emailField.setValue(TEST_DATA.email);

    const passwordField = await driver.$(SELECTORS.passwordField);
    await passwordField.setValue(TEST_DATA.password);

    const confirmPasswordField = await driver.$(SELECTORS.confirmPasswordField);
    await confirmPasswordField.setValue(TEST_DATA.password);
    await captureStep(driver, '02-account-filled');

    const continueButton = await driver.$(SELECTORS.continueButton);
    await continueButton.click();
    await captureStep(driver, '03-after-account-continue');

    const emailOtpField = await driver.$(SELECTORS.emailOtpField);
    await emailOtpField.setValue(TEST_DATA.emailOtp);
    await captureStep(driver, '04-email-otp-entered');

    // Continue wiring remaining steps (mobile, identity, Nafath, business,
    // bank) here once the account + email-OTP selectors above are confirmed
    // against the real build.
  } finally {
    await driver.deleteSession();
  }
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
