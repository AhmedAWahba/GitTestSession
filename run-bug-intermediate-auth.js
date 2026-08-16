/**
 * Bug evidence capture: Intermediate re-authentication during registration
 * Scenario: Correct email OTP advances to the "Sign in to continue" screen
 * Feature:  scenarios/prd1_business_registration/business-registration-test.feature
 * Tags:     @registration @positive @smoke
 * Evidence: evidence/2026-08-10/001-email-otp-advances-to-sign-in-step/
 */

const { chromium } = require('playwright');
const path = require('path');
const fs   = require('fs');

const RUN_DATE    = '2026-08-10';
const SCENARIO    = '001-email-otp-advances-to-sign-in-step';
const EVIDENCE_DIR = path.resolve(`evidence/${RUN_DATE}/${SCENARIO}`);
if (!fs.existsSync(EVIDENCE_DIR)) fs.mkdirSync(EVIDENCE_DIR, { recursive: true });

// Unique credentials for this run — counter 10 is current
const COUNTER  = 10;
const EMAIL    = `test.reg.qawafel${COUNTER}@example.com`;
const PASSWORD = 'Owner@123456789';
const MOBILE   = '512345678';
const NATID    = '1000000001';
const DOB      = '01/01/1985';
const OTP      = '201111';

let stepIndex = 0;
async function shot(page, label) {
  stepIndex++;
  const num  = String(stepIndex).padStart(3, '0');
  const file = path.join(EVIDENCE_DIR, `${num}-${label}.png`);
  await page.screenshot({ path: file, fullPage: false });
  console.log(`  📸 ${path.basename(file)}`);
}

const networkFailures = [];

(async () => {
  const browser = await chromium.launch({ headless: false, slowMo: 80 });
  const context = await browser.newContext();
  const page    = await context.newPage();

  page.on('response', res => {
    if (res.status() >= 400) {
      networkFailures.push(`${res.status()} ${res.request().method()} ${res.url()}`);
    }
  });

  try {
    // ── Step 1: Navigate to registration page ───────────────────────────────
    console.log('\n▶ 1. Navigate to registration page');
    await page.goto('https://app.development.qawafel.dev/register', { waitUntil: 'domcontentloaded', timeout: 30000 });
    await page.waitForTimeout(1500);
    await shot(page, 'registration-page-loaded');

    // ── Step 2: Fill account creation form ─────────────────────────────────
    console.log(`\n▶ 2. Fill account creation — email: ${EMAIL}`);
    await page.locator('input[type="email"], input[placeholder*="email" i], input[name*="email" i]').first().fill(EMAIL);
    await page.waitForTimeout(300);
    await page.locator('input[type="password"]').first().fill(PASSWORD);
    await page.waitForTimeout(300);
    const pwFields = await page.locator('input[type="password"]').all();
    if (pwFields.length >= 2) {
      await pwFields[1].fill(PASSWORD);
    }
    await page.waitForTimeout(500);
    await shot(page, 'account-creation-form-filled');

    // ── Step 3: Click Continue ───────────────────────────────────────────────
    console.log('\n▶ 3. Click "Continue" on account creation step');
    const continueBtn = page.getByRole('button', { name: /continue|متابعة/i });
    await continueBtn.click();
    await page.waitForTimeout(2000);
    await shot(page, 'after-continue-account-creation');

    // ── Step 4: Fill personal details ───────────────────────────────────────
    console.log('\n▶ 4. Fill personal details');
    // Mobile number
    const mobileInput = page.locator('input[type="tel"], input[placeholder*="mobile" i], input[placeholder*="phone" i], input[placeholder*="رقم" ]').first();
    await mobileInput.fill(MOBILE);
    await page.waitForTimeout(300);
    // National ID
    const natIdInput = page.locator('input[placeholder*="national" i], input[placeholder*="iqama" i], input[placeholder*="هوية" ], input[placeholder*="id" i]').first();
    await natIdInput.fill(NATID);
    await page.waitForTimeout(300);
    // Date of Birth — try date input or text input
    const dobInput = page.locator('input[type="date"], input[placeholder*="birth" i], input[placeholder*="dob" i], input[placeholder*="تاريخ"]').first();
    await dobInput.fill(DOB);
    await page.waitForTimeout(500);
    await shot(page, 'personal-details-form-filled');

    // ── Step 5: Click Continue on personal details ───────────────────────────
    console.log('\n▶ 5. Click "Continue" on personal details step');
    await continueBtn.click();
    await page.waitForTimeout(2000);
    await shot(page, 'after-continue-personal-details');

    // ── Step 6: Capture OTP screen ───────────────────────────────────────────
    console.log('\n▶ 6. Email OTP step');
    await shot(page, 'email-otp-step');

    // ── Step 7: Enter OTP ────────────────────────────────────────────────────
    console.log(`\n▶ 7. Enter OTP: ${OTP}`);
    const otpBoxes = await page.locator('input[maxlength="1"]').all();
    if (otpBoxes.length >= 6) {
      const digits = OTP.split('');
      for (let i = 0; i < 6; i++) {
        await otpBoxes[i].fill(digits[i]);
        await page.waitForTimeout(80);
      }
    } else {
      const singleOtp = page.locator('input[maxlength="6"], input[autocomplete="one-time-code"], input[placeholder*="otp" i], input[placeholder*="code" i]').first();
      await singleOtp.fill(OTP);
    }
    await page.waitForTimeout(500);
    await shot(page, 'otp-entered');

    // ── Step 8: Click Verify ─────────────────────────────────────────────────
    console.log('\n▶ 8. Click "Verify"');
    const verifyBtn = page.getByRole('button', { name: /verify|تحقق/i });
    await verifyBtn.click();
    await page.waitForTimeout(3000);
    await shot(page, 'after-otp-verify');

    // ── Step 9: Check for "Sign in to continue" heading ──────────────────────
    console.log('\n▶ 9. Check post-OTP screen');
    const signInHeading = await page.locator('text=Sign in to continue').isVisible().catch(() => false);
    const signInMsg     = await page.locator('text=Your email is verified').isVisible().catch(() => false);

    await shot(page, 'post-otp-screen-full');

    if (signInHeading) {
      console.log('⚠️  BUG CONFIRMED: "Sign in to continue" heading is visible after email OTP');
      await shot(page, 'BUG-sign-in-to-continue-screen');
      // Capture heading and message text as-is
      const headingText = await page.locator('h1, h2, h3').first().textContent().catch(() => '');
      const msgText     = await page.locator('p, .message, [class*="message"]').filter({ hasText: 'email is verified' }).first().textContent().catch(() => '');
      console.log(`   Heading  : "${headingText.trim()}"`);
      console.log(`   Message  : "${msgText.trim()}"`);
    } else {
      console.log('ℹ️  "Sign in to continue" heading not detected — check screenshot manually');
    }

    // ── Network failures ─────────────────────────────────────────────────────
    if (networkFailures.length) {
      console.log('\n⚠️  Network failures (≥400):');
      networkFailures.forEach(f => console.log(`   ${f}`));
      fs.writeFileSync(path.join(EVIDENCE_DIR, 'network-failures.txt'), networkFailures.join('\n'));
    } else {
      console.log('\n✅  No network failures (≥400) detected.');
    }

    console.log(`\n📁 Evidence: ${EVIDENCE_DIR}`);

    // ── Result ───────────────────────────────────────────────────────────────
    if (signInHeading || signInMsg) {
      console.log('\n🔴 RESULT: FAIL — Intermediate re-authentication screen ("Sign in to continue") appeared after email OTP.');
      console.log('   PRD expects direct continuation to identity verification with no re-login step.');
    } else {
      console.log('\n🟡 RESULT: INCONCLUSIVE — Check evidence screenshots for the post-OTP state.');
    }

  } catch (err) {
    console.error('\n❌ Script error:', err.message);
    await shot(page, 'FAIL-script-error').catch(() => {});
  } finally {
    await browser.close();
  }
})();
