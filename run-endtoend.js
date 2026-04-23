/**
 * Feature file : scenarios/Admin/endtoend.feature
 * Scenario     : Complete end-to-end flow — registration, admin approval, user verification check
 * Evidence     : evidence/endtoend/<timestamp>/
 */

const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const CONFIG = {
  vendorStoreUrl: 'https://store.development.qawafel.dev/hint',
  adminUrl: 'https://admin.development.qawafel.dev',
  verificationCenterUrl: 'https://admin.development.qawafel.dev/verification-center/list',
  adminEmail: 'ahmedwahba@qawafel.sa',
  adminPassword: 'Ahmedwahba@123',
  otp: '201111',
  counterFile: path.resolve('fixtures/run-counter.json'),
  uploads: {
    cr: path.resolve('fixtures/uploads/commercial-registration.jpg'),
    vat: path.resolve('fixtures/uploads/vat-certificate.jpg'),
  },
};

function readCounter() {
  if (fs.existsSync(CONFIG.counterFile)) {
    return JSON.parse(fs.readFileSync(CONFIG.counterFile, 'utf8')).counter;
  }
  return 3;
}

function incrementCounter(counter) {
  const next = counter + 1;
  fs.writeFileSync(CONFIG.counterFile, JSON.stringify({ counter: next }, null, 2));
  return next;
}

const counter = readCounter();
const runData = {
  counter,
  mobile: `55698980${counter}`,
  email: `test.reg.qawafel${counter}@example.com`,
  crNumber: `10${String(Date.now()).slice(-8)}`,           // 10-digit unique per run (timestamp-based)
  vatNumber: `300${String(Date.now()).slice(-12)}`,        // 15-digit unique per run (timestamp-based)
  shortAddress: `TSTB${String(counter).padStart(4, '0')}`,
  storeNameArabic: 'مخبز الاختبار',
  storeNameEnglish: 'Test Bakery',
  legalNameArabic: 'شركة الاختبار',
};

const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
const evidenceDir = path.resolve(`evidence/endtoend/${timestamp}`);
fs.mkdirSync(evidenceDir, { recursive: true });

let stepCounter = 0;
let activePage = null;
const consoleLogs = [];

function logHeader() {
  console.log('============================================');
  console.log(' E2E: Registration -> Admin Approval -> OK ');
  console.log('============================================');
  console.log(`Run counter : ${runData.counter}`);
  console.log(`Mobile      : ${runData.mobile}`);
  console.log(`Email       : ${runData.email}`);
  console.log(`CR number   : ${runData.crNumber}`);
  console.log(`VAT number  : ${runData.vatNumber}`);
  console.log(`Short addr  : ${runData.shortAddress}`);
  console.log(`Evidence    : ${evidenceDir}`);
  console.log('');
}

function logPhase(title) {
  console.log(`\n=== ${title} ===`);
}

function attachPageLogs(page, prefix) {
  activePage = page;
  page.on('console', message => consoleLogs.push(`[${prefix}][${message.type()}] ${message.text()}`));
  page.on('pageerror', error => consoleLogs.push(`[${prefix}][pageerror] ${error.message}`));
}

async function shot(page, label) {
  stepCounter += 1;
  const file = path.join(evidenceDir, `${String(stepCounter).padStart(3, '0')}-${label}.png`);
  await page.screenshot({ path: file, fullPage: false });
  console.log(`  [shot] ${path.basename(file)}`);
}

async function fail(reason, label) {
  console.error(`\nFAIL: ${reason}`);
  if (activePage) {
    await shot(activePage, label).catch(() => {});
  }
  throw new Error(reason);
}

async function isVisible(locator, timeout = 4000) {
  return locator.isVisible({ timeout }).catch(() => false);
}

async function fillIfVisible(locator, value) {
  if (await locator.isVisible().catch(() => false)) {
    await locator.fill(value);
    return true;
  }
  return false;
}

async function firstVisibleLocator(factories, timeout = 1200) {
  for (const factory of factories) {
    const locator = factory().first();
    if (await locator.isVisible({ timeout }).catch(() => false)) {
      return locator;
    }
  }
  return null;
}

async function clickFirstVisibleButton(page, names) {
  const locator = await firstVisibleLocator(names.map(name => () => page.getByRole('button', { name })));
  if (!locator) {
    return false;
  }
  await locator.scrollIntoViewIfNeeded().catch(() => {});
  await locator.click();
  return true;
}

async function fillOtp(page, code) {
  const digitInputs = await page.locator('input[maxlength="1"]').all();
  if (digitInputs.length >= code.length) {
    for (let index = 0; index < code.length; index += 1) {
      await digitInputs[index].fill(code[index]);
      await page.waitForTimeout(80);
    }
    return;
  }

  const singleInput = await firstVisibleLocator([
    () => page.locator('input[maxlength="6"]'),
    () => page.locator('input[autocomplete="one-time-code"]'),
    () => page.locator('input[placeholder*="رمز"]'),
  ]);

  if (!singleInput) {
    await fail('OTP input not found', 'FAIL-no-otp-input');
  }

  await singleInput.fill(code);
}

async function setFileInput(page, index, filePath) {
  const inputs = await page.locator('input[type="file"]').all();
  if (inputs.length > index) {
    await inputs[index].setInputFiles(filePath);
  }
}

async function openVendorLogin(page, labelPrefix) {
  console.log('Open vendor store');
  await page.goto(CONFIG.vendorStoreUrl, { waitUntil: 'networkidle' });
  await shot(page, `${labelPrefix}-store-home`);

  console.log('Open login modal');
  await page.getByText('دخول / تسجيل').first().click();
  await page.waitForTimeout(1500);
  await shot(page, `${labelPrefix}-login-modal`);
}

async function fillRegistrationStep1(page) {
  console.log('Fill registration step 1');
  await page.locator('input[placeholder*="بالعربية"]').first().fill(runData.storeNameArabic);
  await page.locator('input[placeholder*="English"], input[placeholder*="الإنجليزية"]').first().fill(runData.storeNameEnglish);
  await page.locator('input[placeholder*="الأول"]').first().fill('أحمد');
  await page.locator('input[placeholder*="الأخير"], input[placeholder*="العائلة"]').first().fill('وهبة');
  await page.locator('input[type="email"], input[placeholder*="email"], input[placeholder*="البريد"]').first().fill(runData.email);

  const storeType = page.locator('[id="react-select-3-input"]');
  await storeType.click();
  await page.waitForTimeout(400);
  await storeType.fill('مخبز');
  await page.waitForTimeout(600);
  await page.keyboard.press('Enter');

  const cityInput = page.locator('#react-select-5-input');
  await cityInput.scrollIntoViewIfNeeded();
  await cityInput.click();
  await cityInput.fill('الرياض');
  await page.waitForTimeout(800);
  await page.keyboard.press('Enter');

  const districtInput = page.locator('#react-select-6-input');
  await districtInput.scrollIntoViewIfNeeded();
  await districtInput.click();
  await page.waitForTimeout(300);
  await districtInput.fill('الفيحاء');
  await page.waitForTimeout(600);
  await page.keyboard.press('Enter');

  await page.locator('input[placeholder*="المكتب الرئيسي"], input[placeholder*="اسم العنوان"]').first().fill('المخبز الرئيسي');
  await fillIfVisible(page.locator('input[placeholder*="التفصيلي"]').first(), 'حي الفيحاء، شارع الملك فهد');
  await fillIfVisible(page.locator('input[placeholder*="الشارع"]').first(), 'شارع الملك فهد');
  await fillIfVisible(page.locator('input[placeholder*="رقم المبني"], input[placeholder*="8118"]').first(), '8118');
  await fillIfVisible(page.locator('input[placeholder*="البريدي"]').first(), '12345');
  await fillIfVisible(page.locator('input[placeholder*="RRRD"]').first(), runData.shortAddress);
}

async function fillRegistrationStep2(page) {
  console.log('Fill registration step 2');
  await page.evaluate(() => {
    const container = document.querySelector('[aria-hidden="false"]');
    if (container) {
      container.scrollTop = 0;
    }
  });
  await page.waitForTimeout(300);

  await page.locator('input[placeholder*="الاسم التجاري"], input[placeholder*="السجل التجاري"]').first().fill(runData.legalNameArabic);

  const crTypeDropdown = page.locator('text=اختر النوع').first();
  await crTypeDropdown.scrollIntoViewIfNeeded();
  await crTypeDropdown.click();
  await page.waitForTimeout(500);

  const crOption = await firstVisibleLocator([
    () => page.locator('[role="option"]:has-text("سجل تجاري")'),
    () => page.locator('[id*="option"]:has-text("سجل تجاري")'),
  ]);
  if (crOption) {
    await crOption.click();
  } else {
    await page.keyboard.press('Enter');
  }

  await page.locator('input[placeholder*="رقم السجل"], input[placeholder*="الرقم الموحد"], input[placeholder*="1010"], input[placeholder*="123"]').first().fill(runData.crNumber);
  await setFileInput(page, 0, CONFIG.uploads.cr);

  const vatToggle = page.locator('[role="switch"], input[type="checkbox"]').first();
  if (await vatToggle.isVisible().catch(() => false) && await vatToggle.isChecked().catch(() => null) === false) {
    await vatToggle.click();
  }

  await fillIfVisible(page.locator('input[placeholder*="حساب ضريبة"], input[placeholder*="الضريبي"], input[placeholder*="3001"]').first(), runData.vatNumber);
  await setFileInput(page, 1, CONFIG.uploads.vat);
}

async function loginAdmin(page) {
  console.log('Admin login');
  await page.goto(CONFIG.adminUrl, { waitUntil: 'networkidle' });
  await page.locator('input[type="email"], input[placeholder*="email"], input[name="email"]').first().fill(CONFIG.adminEmail);
  await page.locator('input[type="password"]').first().fill(CONFIG.adminPassword);
  await shot(page, 'p2-admin-credentials');

  const clicked = await clickFirstVisibleButton(page, ['تسجيل الدخول', 'Login', 'Sign in']);
  if (!clicked) {
    const submit = page.locator('button[type="submit"]').first();
    if (await submit.isVisible().catch(() => false)) {
      await submit.click();
    } else {
      await fail('Admin submit button not found', 'p2-FAIL-no-admin-submit');
    }
  }

  await page.waitForTimeout(4000);
  await shot(page, 'p2-admin-logged-in');
}

async function findPendingRequest(page) {
  console.log('Find pending request');
  await page.goto(CONFIG.verificationCenterUrl, { waitUntil: 'networkidle' });
  await page.waitForTimeout(1500);
  await shot(page, 'p2-verification-center');

  const searchInput = page.locator('input[placeholder*="Search"], input[placeholder*="بحث"]').first();
  if (await searchInput.isVisible({ timeout: 2500 }).catch(() => false)) {
    await searchInput.fill(runData.mobile);
    await page.waitForTimeout(1500);
    await shot(page, 'p2-search-by-mobile');
  }

  const row = await firstVisibleLocator([
    () => page.locator(`td:has-text("${runData.storeNameEnglish}")`),
    () => page.locator(`a:has-text("${runData.storeNameEnglish}")`),
    () => page.locator(`text=${runData.mobile}`),
  ], 5000);

  if (!row) {
    await fail(`Pending request not found for ${runData.mobile}`, 'p2-FAIL-no-pending-row');
  }

  await shot(page, 'p2-pending-row-found');
  return row;
}

async function phase1Register(browser) {
  logPhase('PHASE 1 - User Registration');
  const context = await browser.newContext({ locale: 'ar-SA' });
  const page = await context.newPage();
  attachPageLogs(page, 'user');

  await openVendorLogin(page, 'p1');

  console.log(`Enter mobile ${runData.mobile}`);
  await page.locator('input[type="tel"], input[placeholder*="رقم"], input[placeholder*="جوال"]').first().fill(runData.mobile);
  await shot(page, 'p1-mobile-entered');

  if (!await clickFirstVisibleButton(page, ['أنشئ الحساب'])) {
    await fail('Phase 1: Create account button not found', 'p1-FAIL-no-create-account');
  }
  await page.waitForTimeout(2000);
  await shot(page, 'p1-after-create-account');

  if (!await isVisible(page.locator('text=أدخل رمز التحقق').first(), 8000)) {
    await fail('Phase 1: OTP screen not displayed', 'p1-FAIL-no-otp-screen');
  }
  await shot(page, 'p1-otp-screen');

  console.log(`Enter OTP ${CONFIG.otp}`);
  await fillOtp(page, CONFIG.otp);
  await shot(page, 'p1-otp-entered');

  if (!await clickFirstVisibleButton(page, ['تأكيد'])) {
    await fail('Phase 1: OTP confirm button not found', 'p1-FAIL-no-otp-confirm');
  }
  await page.waitForTimeout(3000);
  await shot(page, 'p1-after-otp-confirm');

  if (!await isVisible(page.locator('text=بيانات الشركة').first(), 8000)) {
    await fail('Phase 1: Step 1 form not displayed', 'p1-FAIL-no-step1');
  }
  await shot(page, 'p1-step1-visible');

  await fillRegistrationStep1(page);
  await shot(page, 'p1-step1-filled');

  const nextButton = page.getByRole('button', { name: 'الخطوة التالية' });
  await nextButton.scrollIntoViewIfNeeded();
  await nextButton.click();
  await nextButton.waitFor({ state: 'hidden', timeout: 10000 }).catch(() => {});
  await page.waitForTimeout(2000);
  await shot(page, 'p1-after-next-step');

  if (!await isVisible(page.getByRole('button', { name: 'إنشاء الحساب' }).first(), 8000)) {
    await fail('Phase 1: Step 2 form not displayed', 'p1-FAIL-no-step2');
  }
  await shot(page, 'p1-step2-visible');

  await fillRegistrationStep2(page);
  await shot(page, 'p1-step2-filled');

  const submitButton = page.getByRole('button', { name: 'إنشاء الحساب' });
  await submitButton.scrollIntoViewIfNeeded();
  await submitButton.click();
  await page.waitForTimeout(6000);
  await shot(page, 'p1-after-submit');

  if (!await isVisible(page.locator('text=طلبك قيد المراجعة الآن').first(), 8000)) {
    await fail('Phase 1: Success popup not displayed after submit', 'p1-FAIL-no-success-popup');
  }
  await shot(page, 'p1-success-popup');
  console.log('Phase 1 passed');

  if (!await clickFirstVisibleButton(page, ['تصفح المنصة'])) {
    await fail('Phase 1: Browse platform button not found', 'p1-FAIL-no-browse-button');
  }
  await page.waitForTimeout(2000);
  await shot(page, 'p1-vendor-store-logged-in');
  await context.close();
}

async function phase2Approve(browser) {
  logPhase('PHASE 2 - Admin Approval');
  const context = await browser.newContext();
  const page = await context.newPage();
  attachPageLogs(page, 'admin');

  await loginAdmin(page);
  const requestRow = await findPendingRequest(page);

  console.log('Open request detail');
  await requestRow.click();
  await page.waitForTimeout(2000);
  await shot(page, 'p2-request-detail');

  const verifyButton = page.getByRole('button', { name: 'Verify Retailer' });
  if (!await isVisible(verifyButton, 5000)) {
    await fail('Phase 2: Verify Retailer button not found', 'p2-FAIL-no-verify-button');
  }
  await verifyButton.scrollIntoViewIfNeeded();
  await shot(page, 'p2-verify-button-visible');
  await verifyButton.click();
  await page.waitForTimeout(2000);

  await clickFirstVisibleButton(page, ['تأكيد', 'Confirm', 'نعم']);
  // wait for confirm dialog to close before checking state
  await page.locator('[role="dialog"]').waitFor({ state: 'hidden', timeout: 10000 }).catch(() => {});
  await page.waitForTimeout(3000);
  await shot(page, 'p2-after-approval');

  const acceptedState = await isVisible(page.locator('text=Accepted').first(), 8000);
  const successToast = await isVisible(page.locator('text=Verification Accepted Successfully').first(), 5000);
  await shot(page, 'p2-status-after-approval');

  if (!acceptedState && !successToast) {
    await fail('Phase 2: Could not confirm accepted state after approval', 'p2-FAIL-no-accepted-state');
  }

  console.log(`Phase 2 passed (Accepted=${acceptedState}, Toast=${successToast})`);
  await context.close();
}

async function phase3Verify(browser) {
  logPhase('PHASE 3 - User Checks Verified State');
  const context = await browser.newContext({ locale: 'ar-SA' });
  const page = await context.newPage();
  attachPageLogs(page, 'user2');

  await openVendorLogin(page, 'p3');

  console.log(`Log back in as ${runData.mobile}`);
  await page.locator('input[type="tel"], input[placeholder*="رقم"], input[placeholder*="جوال"]').first().fill(runData.mobile);
  await shot(page, 'p3-mobile-entered');

  // Click whatever submit button is present (may be "أنشئ الحساب" or "تسجل الدخول")
  const step1Clicked = await clickFirstVisibleButton(page, ['أرسل رمز التحقق', 'تسجل الدخول', 'تسجيل الدخول', 'دخول', 'أنشئ الحساب'])
    || await (async () => { const b = page.locator('button[type="submit"]').first(); if (await b.isVisible({timeout:2000}).catch(()=>false)) { await b.click(); return true; } return false; })();

  if (!step1Clicked) {
    await fail('Phase 3: First-step button not found', 'p3-FAIL-no-login-trigger');
  }
  await page.waitForTimeout(2000);
  await shot(page, 'p3-after-step1');

  // If we landed on a login page (has "تسجل الدخول" button), click it to send OTP
  const loginPageBtn = page.getByRole('button', { name: /تسجل الدخول|تسجيل الدخول/ }).first();
  if (await loginPageBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
    await loginPageBtn.click();
    await page.waitForTimeout(2000);
  }
  await shot(page, 'p3-after-send-otp');

  // wait for OTP screen to appear (up to 10s) before trying to fill
  await page.locator('input[maxlength="1"], input[maxlength="6"], input[autocomplete="one-time-code"]')
    .first().waitFor({ state: 'visible', timeout: 10000 }).catch(() => {});

  await fillOtp(page, CONFIG.otp);
  if (!await clickFirstVisibleButton(page, ['تأكيد'])) {
    await fail('Phase 3: Login confirm button not found', 'p3-FAIL-no-login-confirm');
  }
  await page.waitForTimeout(4000);
  await shot(page, 'p3-logged-in');

  const loginToastVisible = await isVisible(page.locator('text=تم تسجيل الدخول بنجاح').first(), 3000);
  const unverifiedRibbonVisible = await isVisible(
    page.locator('text=تأكيد الحساب, text=توثيق الحساب, text=غير موثق').first(),
    3000,
  );
  await shot(page, 'p3-home-after-login');

  if (!loginToastVisible) {
    await fail('Phase 3: User login success toast not observed', 'p3-FAIL-no-login-success');
  }
  if (unverifiedRibbonVisible) {
    await fail('Phase 3: Unverified ribbon is still visible after admin approval', 'p3-FAIL-still-unverified');
  }

  console.log('Phase 3 passed (login succeeded and unverified ribbon is gone)');
  await context.close();
}

function writeSummary(passed, failureReason) {
  const evidence = fs.existsSync(evidenceDir)
    ? fs.readdirSync(evidenceDir).filter(file => file.endsWith('.png'))
    : [];

  const lines = [
    '# E2E Execution Summary',
    '**Scenario:** End-to-End Registration -> Admin Approval -> User Verification Check',
    '**Feature:** scenarios/Admin/endtoend.feature',
    `**Status:** ${passed ? 'PASSED' : 'FAILED'}`,
    `**Date:** ${timestamp}`,
    `**Run counter:** ${runData.counter}`,
    `**Mobile:** ${runData.mobile}`,
    `**Email:** ${runData.email}`,
    `**CR number:** ${runData.crNumber}`,
    `**VAT number:** ${runData.vatNumber}`,
    `**Short address:** ${runData.shortAddress}`,
    '',
    passed
      ? '## Result\n- Phase 1 passed\n- Phase 2 passed\n- Phase 3 passed'
      : `## Failure\n${failureReason}`,
    '',
    '## Evidence Captured',
    ...evidence.map(file => `- ${file}`),
    '',
    '## Browser Console Logs',
    consoleLogs.length ? consoleLogs.slice(-50).join('\n') : '(none captured)',
  ];

  fs.writeFileSync(path.join(evidenceDir, 'summary.md'), lines.join('\n'));
  console.log(`\nSummary -> evidence/endtoend/${timestamp}/summary.md`);
}

async function main() {
  logHeader();
  const browser = await chromium.launch({ headless: false, slowMo: 80 });

  try {
    await phase1Register(browser);
    await phase2Approve(browser);
    await phase3Verify(browser);

    const next = incrementCounter(runData.counter);
    console.log('\nSUCCESS: end-to-end scenario completed');
    console.log(`Next run counter: ${next} -> mobile 55698980${next}`);
    writeSummary(true, null);
  } catch (error) {
    writeSummary(false, error.message);
    await browser.close();
    process.exit(1);
  }

  await browser.close();
}

main();
