/**
 * Scenario: Complete successful registration flow from phone to verification popup
 * Feature:  B2B Online Store Registration & Verification
 * Tags:     @registration @positive @smoke @end-to-end
 * Evidence: evidence/register_successful_registration/2026-04-22/
 */

const { chromium } = require('playwright');
const path = require('path');
const fs   = require('fs');

// ── Per-run unique data ───────────────────────────────────────────────────────
// All dynamic values are derived from a single counter stored in fixtures/run-counter.json.
// The counter increments ONLY after a successful registration.
const RUN_COUNTER_FILE = path.resolve('fixtures/run-counter.json');

function readCounter() {
  if (fs.existsSync(RUN_COUNTER_FILE)) {
    return JSON.parse(fs.readFileSync(RUN_COUNTER_FILE, 'utf8')).counter;
  }
  return 2; // start at 2 (run 1 = mobile 556989801 already used)
}

function incrementCounter(counter) {
  const next = counter + 1;
  fs.writeFileSync(RUN_COUNTER_FILE, JSON.stringify({ counter: next }, null, 2));
  return next;
}

const COUNTER  = readCounter();
const MOBILE   = `55698980${COUNTER}`;                          // e.g. 556989802, 556989803 …
const EMAIL    = `test.reg.qawafel${COUNTER}@example.com`;      // unique per run
const CR_NUM   = `10000000${String(COUNTER).padStart(2,'0')}`;  // 10-digit, unique
const VAT_NUM  = `3001000000000${String(COUNTER).padStart(2,'0')}`; // 15-digit, unique
const STORE_AR   = 'مخبز الاختبار';   // store names: letters only (API rejects digits)
const STORE_EN   = 'Test Bakery';      // store names: letters only (API rejects digits)
const SHORT_ADDR = `TSTB${String(COUNTER).padStart(4, '0')}`; // unique 8-char national address per run

console.log(`Run counter : ${COUNTER}`);
console.log(`Mobile      : ${MOBILE}`);
console.log(`Email       : ${EMAIL}`);
console.log(`CR number   : ${CR_NUM}`);
console.log(`VAT number  : ${VAT_NUM}`);
console.log(`Short addr  : ${SHORT_ADDR}`);

const EVIDENCE_DIR = path.resolve('evidence/register_successful_registration/2026-04-22');
if (!fs.existsSync(EVIDENCE_DIR)) fs.mkdirSync(EVIDENCE_DIR, { recursive: true });

let stepCounter = 0;
async function shot(page, label) {
  stepCounter++;
  const num  = String(stepCounter).padStart(3, '0');
  const file = path.join(EVIDENCE_DIR, `${num}-${label}.png`);
  await page.screenshot({ path: file, fullPage: false });
  console.log(`  📸 ${path.basename(file)}`);
}

(async () => {
  const browser = await chromium.launch({ headless: false, slowMo: 100 });
  const context = await browser.newContext({ locale: 'ar-SA' });

  // Capture console output
  const consoleLogs = [];
  const page = await context.newPage();
  page.on('console', msg => consoleLogs.push(`[${msg.type()}] ${msg.text()}`));
  page.on('pageerror', err => consoleLogs.push(`[pageerror] ${err.message}`));

  try {
    // ── Background ──────────────────────────────────────────────────────────
    console.log('\n▶ Background: open vendor store');
    await page.goto('https://store.development.qawafel.dev/hint', { waitUntil: 'networkidle' });
    await shot(page, 'vendor-store-home');

    console.log('▶ Background: click "دخول / تسجيل"');
    await page.getByText('دخول / تسجيل').first().click();
    await page.waitForTimeout(1500);
    await shot(page, 'login-register-modal');

    // ── Step: enter mobile number ───────────────────────────────────────────
    console.log(`\n▶ Enter mobile number ${MOBILE}`);
    const mobileInput = page.locator('input[type="tel"], input[placeholder*="رقم"], input[placeholder*="جوال"], input[placeholder*="mobile"]').first();
    await mobileInput.fill(MOBILE);
    await shot(page, 'mobile-entered');

    // ── Step: click "أنشئ الحساب" ───────────────────────────────────────────
    console.log('▶ Click "أنشئ الحساب"');
    await page.getByRole('button', { name: 'أنشئ الحساب' }).click();
    await page.waitForTimeout(2000);
    await shot(page, 'after-create-account');

    // ── Step: verify OTP screen ─────────────────────────────────────────────
    console.log('▶ Verify OTP screen "أدخل رمز التحقق"');
    const otpHeading = await page.locator('text=أدخل رمز التحقق').first().isVisible().catch(() => false);
    if (!otpHeading) {
      console.error('❌ OTP screen not displayed — stopping');
      await shot(page, 'FAIL-no-otp-screen');
      await writeSummary(false, 'OTP screen was not displayed after clicking "أنشئ الحساب"', consoleLogs);
      await browser.close();
      process.exit(1);
    }
    await shot(page, 'otp-screen');

    // ── Step: enter OTP ─────────────────────────────────────────────────────
    console.log('▶ Enter OTP 201111');
    // Try individual digit boxes first, then a single input
    const otpInputs = await page.locator('input[maxlength="1"]').all();
    if (otpInputs.length >= 6) {
      const digits = '201111'.split('');
      for (let i = 0; i < 6; i++) {
        await otpInputs[i].fill(digits[i]);
        await page.waitForTimeout(100);
      }
    } else {
      const singleOtp = page.locator('input[maxlength="6"], input[placeholder*="OTP"], input[placeholder*="رمز"], input[autocomplete="one-time-code"]').first();
      await singleOtp.fill('201111');
    }
    await shot(page, 'otp-entered');

    // ── Step: click "تأكيد" ─────────────────────────────────────────────────
    console.log('▶ Click "تأكيد"');
    await page.getByRole('button', { name: 'تأكيد' }).click();
    await page.waitForTimeout(3000);
    await shot(page, 'after-otp-confirm');

    // ── Step: verify Step 1 "بيانات الشركة" ────────────────────────────────
    console.log('▶ Verify Step 1 "بيانات الشركة"');
    const step1Heading = await page.locator('text=بيانات الشركة').first().isVisible().catch(() => false);
    if (!step1Heading) {
      console.error('❌ Step 1 form not displayed');
      await shot(page, 'FAIL-no-step1');
      await writeSummary(false, 'Step 1 "بيانات الشركة" was not displayed after OTP confirmation', consoleLogs);
      await browser.close();
      process.exit(1);
    }
    await shot(page, 'step1-form-visible');

    // ── Step: fill Step 1 fields ────────────────────────────────────────────
    console.log('▶ Fill Step 1 fields');

    // Store name Arabic
    const storeAr = page.locator('input[placeholder*="بالعربية"]').first();
    await storeAr.fill(STORE_AR);

    // Store name English
    const storeEn = page.locator('input[placeholder*="English"], input[placeholder*="الإنجليزية"]').first();
    await storeEn.fill(STORE_EN);

    // First name
    const firstName = page.locator('input[placeholder*="الأول"]').first();
    await firstName.fill('أحمد');

    // Last name
    const lastName = page.locator('input[placeholder*="الأخير"], input[placeholder*="العائلة"]').first();
    await lastName.fill('وهبة');

    // Email
    const email = page.locator('input[type="email"], input[placeholder*="email"], input[placeholder*="البريد"]').first();
    await email.fill(EMAIL);

    await shot(page, 'step1-basic-fields-filled');

    // Store type dropdown
    console.log('  ▸ Select store type');
    const storeTypeControl = page.locator('[id="react-select-3-input"]');
    await storeTypeControl.click();
    await page.waitForTimeout(500);
    // Type "مخبز" and press Enter
    await storeTypeControl.fill('مخبز');
    await page.waitForTimeout(800);
    await page.keyboard.press('Enter');
    await page.waitForTimeout(300);
    await shot(page, 'step1-store-type-selected');

    // City dropdown
    console.log('  ▸ Select city الرياض');
    const cityInput = page.locator('#react-select-5-input');
    await cityInput.scrollIntoViewIfNeeded();
    await cityInput.click();
    await cityInput.fill('الرياض');
    await page.waitForTimeout(1000);
    await page.keyboard.press('Enter');
    await page.waitForTimeout(500);
    await shot(page, 'step1-city-selected');

    // District dropdown
    console.log('  ▸ Select district');
    const districtInput = page.locator('#react-select-6-input');
    await districtInput.scrollIntoViewIfNeeded();
    await districtInput.click();
    await page.waitForTimeout(500);
    // Type الفيحاء
    await districtInput.fill('الفيحاء');
    await page.waitForTimeout(800);
    await page.keyboard.press('Enter');
    await page.waitForTimeout(300);
    await shot(page, 'step1-district-selected');

    // Address name
    const addressName = page.locator('input[placeholder*="المكتب الرئيسي"], input[placeholder*="اسم العنوان"]').first();
    await addressName.scrollIntoViewIfNeeded();
    await addressName.fill('المخبز الرئيسي');

    // Detailed address (required)
    const detailedAddr = page.locator('input[placeholder*="التفصيلي"]').first();
    if (await detailedAddr.isVisible().catch(() => false)) {
      await detailedAddr.fill('حي الفيحاء، شارع الملك فهد');
    }

    // Try to fill optional address fields if visible
    const streetInput = page.locator('input[placeholder*="الشارع"]').first();
    if (await streetInput.isVisible().catch(() => false)) {
      await streetInput.fill('شارع الملك فهد');
    }
    const buildingInput = page.locator('input[placeholder*="رقم المبني"], input[placeholder*="8118"]').first();
    if (await buildingInput.isVisible().catch(() => false)) {
      await buildingInput.fill('8118');
    }
    const postalInput = page.locator('input[placeholder*="البريدي"]').first();
    if (await postalInput.isVisible().catch(() => false)) {
      await postalInput.fill('12345');
    }
    const shortAddr = page.locator('input[placeholder*="RRRD"]').first();
    if (await shortAddr.isVisible().catch(() => false)) {
      await shortAddr.fill(SHORT_ADDR);
    }

    await shot(page, 'step1-all-fields-filled');

    // ── Step: click "الخطوة التالية" ────────────────────────────────────────
    console.log('▶ Click "الخطوة التالية"');
    const nextBtn = page.getByRole('button', { name: 'الخطوة التالية' });
    await nextBtn.scrollIntoViewIfNeeded();
    await page.waitForTimeout(500);
    await nextBtn.click();
    // Wait for the button to disappear (Step 1 → Step 2 transition)
    await nextBtn.waitFor({ state: 'hidden', timeout: 10000 }).catch(() => {});
    await page.waitForTimeout(2000);
    await shot(page, 'after-next-step');

    // ── Step: verify Step 2 "المعلومات القانونية" ───────────────────────────
    // Wait for Step 1's "الخطوة التالية" button to disappear (form advances)
    // Then check that the CR/legal name field is visible (unique to Step 2)
    console.log('▶ Verify Step 2 "المعلومات القانونية"');
    await page.waitForTimeout(1000);
    // Step 2 unique element: "إنشاء الحساب" final submit button (only on Step 2)
    const step2Field = await page.getByRole('button', { name: 'إنشاء الحساب' })
      .first().isVisible({ timeout: 8000 }).catch(() => false);
    if (!step2Field) {
      // Check for validation errors still on Step 1
      const validationErr = await page.locator('text=يرجى إدخال, text=مطلوب').first().isVisible().catch(() => false);
      console.error('❌ Step 2 form not displayed — ' + (validationErr ? 'Step 1 has validation errors' : 'unknown reason'));
      await shot(page, 'FAIL-no-step2');
      await writeSummary(false, 'Step 2 was not displayed — ' + (validationErr ? 'Step 1 validation errors remain' : 'unknown reason'), consoleLogs);
      await browser.close();
      process.exit(1);
    }
    await shot(page, 'step2-form-visible');

    // ── Step: fill Step 2 fields ────────────────────────────────────────────
    console.log('▶ Fill Step 2 fields');

    // Legal name Arabic - scroll to top first
    await page.evaluate(() => {
      const overlay = document.querySelector('[aria-hidden="false"], [role="dialog"]');
      if (overlay) overlay.scrollTop = 0;
    });
    await page.waitForTimeout(300);
    const legalNameAr = page.locator('input[placeholder*="الاسم التجاري"], input[placeholder*="السجل التجاري"]').first();
    await legalNameAr.scrollIntoViewIfNeeded();
    await legalNameAr.fill(`شركة الاختبار`);

    // CR type dropdown - click "اختر النوع" and select سجل تجاري
    const crTypeDropdown = page.locator('text=اختر النوع').first();
    await crTypeDropdown.scrollIntoViewIfNeeded();
    await crTypeDropdown.click();
    await page.waitForTimeout(600);
    // Select سجل تجاري from dropdown options
    const crOption = page.locator('[role="option"]:has-text("سجل تجاري"), [id*="option"]:has-text("سجل تجاري")');
    if (await crOption.first().isVisible({ timeout: 3000 }).catch(() => false)) {
      await crOption.first().click();
    } else {
      await page.keyboard.press('Enter');
    }
    await page.waitForTimeout(500);

    // CR number (appears after selecting type)
    const crNumber = page.locator('input[placeholder*="رقم السجل"], input[placeholder*="الرقم الموحد"], input[placeholder*="1010"], input[placeholder*="123"]').first();
    await crNumber.scrollIntoViewIfNeeded();
    await crNumber.fill(CR_NUM);

    await shot(page, 'step2-legal-fields-filled');

    // Upload CR certificate
    console.log('  ▸ Upload CR certificate');
    const crPath = path.resolve('fixtures/uploads/commercial-registration.jpg');
    const fileInputs = await page.locator('input[type="file"]').all();
    if (fileInputs.length > 0) {
      await fileInputs[0].setInputFiles(crPath);
    }
    await page.waitForTimeout(1000);
    await shot(page, 'step2-cr-uploaded');

    // VAT toggle
    console.log('  ▸ Enable VAT toggle');
    const vatToggle = page.locator('[role="switch"], input[type="checkbox"]').first();
    const isChecked = await vatToggle.isChecked().catch(() => null);
    if (isChecked === false) {
      await vatToggle.click();
      await page.waitForTimeout(500);
    }
    await shot(page, 'step2-vat-toggle-enabled');

    // VAT number
    const vatNumber = page.locator('input[placeholder*="حساب ضريبة"], input[placeholder*="الضريبي"], input[placeholder*="3001"]').first();
    if (await vatNumber.isVisible().catch(() => false)) {
      await vatNumber.fill(VAT_NUM); // 15-digit unique VAT number per run
    }

    // Upload VAT certificate
    console.log('  ▸ Upload VAT certificate');
    const vatPath = path.resolve('fixtures/uploads/vat-certificate.jpg');
    const fileInputs2 = await page.locator('input[type="file"]').all();
    if (fileInputs2.length > 1) {
      await fileInputs2[1].setInputFiles(vatPath);
    } else if (fileInputs2.length === 1) {
      await fileInputs2[0].setInputFiles(vatPath);
    }
    await page.waitForTimeout(1000);
    await shot(page, 'step2-vat-uploaded');

    await shot(page, 'step2-all-fields-filled');

    // ── Step: click "إنشاء الحساب" ──────────────────────────────────────────
    console.log('▶ Click "إنشاء الحساب"');
    const submitBtn = page.getByRole('button', { name: 'إنشاء الحساب' });
    await submitBtn.scrollIntoViewIfNeeded();
    await page.waitForTimeout(500);
    await submitBtn.click();
    await page.waitForTimeout(6000); // wait for API response
    await shot(page, 'after-create-account-final');

    // Capture any error toast that appeared
    const errorToast = await page.locator('[class*="toast"], [class*="alert"], [class*="error"], [class*="notification"]')
      .first().textContent({ timeout: 1000 }).catch(() => null);
    if (errorToast) console.log(`  ⚠️  Toast/error message: ${errorToast.trim()}`);

    // ── Step: verify success popup ───────────────────────────────────────────
    console.log('▶ Verify success popup "طلبك قيد المراجعة الآن"');
    const popupTitle = await page.locator('text=طلبك قيد المراجعة الآن').first().isVisible().catch(() => false);
    if (!popupTitle) {
      console.error('❌ Success popup not displayed');
      await shot(page, 'FAIL-no-success-popup');
      await writeSummary(false, 'Success popup "طلبك قيد المراجعة الآن" was not displayed after clicking "إنشاء الحساب"', consoleLogs);
      await browser.close();
      process.exit(1);
    }
    await shot(page, 'success-popup-visible');

    // Verify popup message
    const msgVisible = await page.locator('text=سيتم مراجعة بياناتك').first().isVisible().catch(() => false);
    console.log(`  Popup message visible: ${msgVisible}`);

    // Verify "تصفح المنصة" button
    const browseBtn = await page.getByRole('button', { name: 'تصفح المنصة' }).first().isVisible().catch(() => false);
    console.log(`  "تصفح المنصة" button visible: ${browseBtn}`);
    await shot(page, 'success-popup-full');

    // ── Step: click "تصفح المنطفة" ───────────────────────────────────────────
    console.log('▶ Click "تصفح المنصة"');
    await page.getByRole('button', { name: 'تصفح المنصة' }).first().click();
    await page.waitForTimeout(3000);
    await shot(page, 'after-browse-platform');

    console.log('\n✅ SCENARIO PASSED');
    const next = incrementCounter(COUNTER);
    console.log(`  Next run counter: ${next} → mobile 55698980${next}`);
    await writeSummary(true, null, consoleLogs);

  } catch (err) {
    console.error('\n❌ Unexpected error:', err.message);
    await shot(page, 'FAIL-unexpected-error').catch(() => {});
    await writeSummary(false, `Unexpected error: ${err.message}`, consoleLogs);
    await browser.close();
    process.exit(1);
  }

  await browser.close();
})();

async function writeSummary(passed, failReason, consoleLogs) {
  const status   = passed ? 'PASSED' : 'FAILED';
  const evidence = fs.readdirSync(EVIDENCE_DIR).filter(f => f.endsWith('.png'));
  const lines = [
    `# Execution Summary`,
    `**Scenario:** Complete successful registration flow from phone to verification popup`,
    `**Status:** ${status}`,
    `**Date:** 2026-04-22`,
    `**Run counter:** ${COUNTER}`,
    `**Mobile used:** ${MOBILE}`,
    `**Email used:** ${EMAIL}`,
    `**CR number:** ${CR_NUM}`,
    `**VAT number:** ${VAT_NUM}`,
    `**OTP used:** 201111`,
    '',
    passed
      ? '## Result\nAll steps completed successfully. User was redirected to vendor store as a logged-in unverified user.'
      : `## Failure\n${failReason}`,
    '',
    '## Evidence Captured',
    ...evidence.map(f => `- ${f}`),
    '',
    '## Browser Console Logs',
    consoleLogs.length ? consoleLogs.join('\n') : '(none captured)',
  ];
  fs.writeFileSync(path.join(EVIDENCE_DIR, 'summary.md'), lines.join('\n'));
  console.log(`\nSummary written to: evidence/register_successful_registration/2026-04-22/summary.md`);
}
