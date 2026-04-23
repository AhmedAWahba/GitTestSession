const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const BASE_EVIDENCE = path.join(__dirname, 'evidence', 'vendor_app_login', '2026-04-23');
const LOGIN_URL = 'https://app.development.qawafel.dev/login';
const results = [];

// Per-scenario screenshot counter
let shotNum = 0;
function resetShots() { shotNum = 0; }
function nextShot() { return String(++shotNum).padStart(3, '0'); }

async function shot(page, dir, desc) {
  const name = `${nextShot()}-${desc}.png`;
  await page.screenshot({ path: path.join(dir, name), fullPage: true });
  console.log(`    📸 ${name}`);
}

function consoleTracker(page) {
  const errors = [];
  page.on('console', m => { if (m.type() === 'error') errors.push(m.text()); });
  return errors;
}

// Selectors discovered via diagnosis
const SEL = {
  mobile: "input[placeholder='5xxxxxxxxx']",
  loginBtn: "button:has-text('تسجيل الدخول')",
  verifyBtn: "button:has-text('متابعة')",
  errorIndicators: '[class*=error], [class*=alert], [role=alert], .Toastify, [class*=toast], [class*=destructive]',
};

async function freshPage(browser) {
  const ctx = await browser.newContext();
  const page = await ctx.newPage();
  return { ctx, page };
}

async function gotoLogin(page) {
  await page.goto(LOGIN_URL, { waitUntil: 'domcontentloaded', timeout: 30000 });
  // small extra wait for JS hydration
  await page.waitForTimeout(2000);
}

async function hasErrorOrValidation(page) {
  const body = await page.locator('body').innerText();
  const textMatch = /خطأ|error|غير صحيح|incorrect|invalid|wrong|مطلوب|required|غير موجود|not found|الرجاء|please|غير صالح|يرجى إدخال/i.test(body);
  const elVisible = await page.locator(SEL.errorIndicators).first().isVisible().catch(() => false);
  return { textMatch, elVisible, detected: textMatch || elVisible };
}

// Narrower check: did the login actually fail with an error (not just page text)?
async function loginWasRejected(page) {
  const body = await page.locator('body').innerText();
  const errorText = /خطأ|البيانات المدخلة غير صحيحة|غير موجود|not found|error|incorrect|invalid/i.test(body);
  const toastVisible = await page.locator('.Toastify, [class*=toast], [class*=destructive]').first().isVisible().catch(() => false);
  return errorText || toastVisible;
}

// After clicking login, detect whether we moved to an OTP screen or got an error
async function waitAfterLogin(page) {
  await page.waitForTimeout(3000);
}

// Fill individual OTP digit inputs (the app uses 6 separate inputs after the mobile field disappears)
async function fillOTP(page, otp) {
  const inputs = page.locator('input');
  const count = await inputs.count();
  if (count >= 4) {
    // Multiple OTP digit boxes — fill each
    for (let i = 0; i < Math.min(count, otp.length); i++) {
      const inp = inputs.nth(i);
      await inp.click();
      await inp.fill(otp[i]);
      await page.waitForTimeout(100);
    }
  } else {
    // Single input
    await inputs.first().fill(otp);
  }
}

async function typeOTP(page, otp) {
  // Use keyboard to type characters (for non-numeric test)
  const inputs = page.locator('input');
  const count = await inputs.count();
  for (let i = 0; i < Math.min(count, otp.length); i++) {
    await inputs.nth(i).click();
    await inputs.nth(i).pressSequentially(otp[i], { delay: 50 });
    await page.waitForTimeout(50);
  }
}

// ===================== SCENARIOS =====================

async function runScenario(browser, id, name, fn) {
  const dir = path.join(BASE_EVIDENCE, `scenario-${id}`);
  fs.mkdirSync(dir, { recursive: true });
  resetShots();
  console.log(`\n===== SCENARIO ${id}: ${name} =====`);
  const { ctx, page } = await freshPage(browser);
  const consoleErrs = consoleTracker(page);
  try {
    const result = await fn(page, dir);
    results.push({ id, name, ...result, consoleErrors: [...consoleErrs] });
  } catch (err) {
    await shot(page, dir, 'error-state').catch(() => {});
    console.log(`  ❌ FAIL — ${err.message.split('\n')[0]}`);
    results.push({ id, name, status: 'FAIL', error: err.message.split('\n')[0], consoleErrors: [...consoleErrs] });
  } finally {
    await ctx.close();
  }
}

// ---- Scenario 1: Successful login ----
async function s1(page, dir) {
  await gotoLogin(page);
  await shot(page, dir, 'login-page');

  await page.locator(SEL.mobile).fill('540000007');
  await shot(page, dir, 'mobile-entered');

  await page.locator(SEL.loginBtn).click();
  await waitAfterLogin(page);
  await shot(page, dir, 'after-login-click');

  // Check if we got an error instead of OTP page
  const { detected } = await hasErrorOrValidation(page);
  if (detected) {
    await shot(page, dir, 'login-rejected');
    const url = page.url();
    console.log(`  Mobile 540000007 was rejected by the server.`);
    console.log(`  ❌ FAIL — stayed on ${url}`);
    return { status: 'FAIL', detail: 'Mobile number rejected — not registered or invalid', url };
  }

  await fillOTP(page, '201111');
  await shot(page, dir, 'otp-entered');

  await page.locator(SEL.verifyBtn).click();
  await page.waitForTimeout(5000);
  await shot(page, dir, 'after-verify');

  const url = page.url();
  const passed = !url.includes('/login');
  console.log(`  URL: ${url}`);
  console.log(`  ${passed ? '✅ PASS' : '❌ FAIL'}`);
  return { status: passed ? 'PASS' : 'FAIL', url };
}

// ---- Scenario 2: Incorrect OTP ----
async function s2(page, dir) {
  await gotoLogin(page);
  await shot(page, dir, 'login-page');

  await page.locator(SEL.mobile).fill('540000007');
  await shot(page, dir, 'mobile-entered');

  await page.locator(SEL.loginBtn).click();
  await waitAfterLogin(page);
  await shot(page, dir, 'otp-page');

  const preCheck = await loginWasRejected(page);
  if (preCheck) {
    console.log(`  Mobile rejected before OTP step.`);
    return { status: 'FAIL', detail: 'Mobile rejected — cannot test OTP' };
  }

  await fillOTP(page, '000000');
  await shot(page, dir, 'wrong-otp-entered');

  await page.locator(SEL.verifyBtn).click();
  await page.waitForTimeout(3000);
  await shot(page, dir, 'after-verify');

  const { detected } = await hasErrorOrValidation(page);
  console.log(`  Error shown: ${detected}`);
  console.log(`  ${detected ? '✅ PASS' : '❌ FAIL'}`);
  return { status: detected ? 'PASS' : 'FAIL' };
}

// ---- Scenario 3: Unregistered mobile ----
async function s3(page, dir) {
  await gotoLogin(page);
  await shot(page, dir, 'login-page');

  await page.locator(SEL.mobile).fill('540000999');
  await shot(page, dir, 'unregistered-mobile');

  await page.locator(SEL.loginBtn).click();
  await waitAfterLogin(page);
  await shot(page, dir, 'after-login-click');

  const { detected } = await hasErrorOrValidation(page);
  console.log(`  Error shown: ${detected}`);
  console.log(`  ${detected ? '✅ PASS' : '❌ FAIL'}`);
  return { status: detected ? 'PASS' : 'FAIL' };
}

// ---- Scenario 4: Invalid mobile format ----
async function s4(page, dir) {
  await gotoLogin(page);
  await shot(page, dir, 'login-page');

  await page.locator(SEL.mobile).fill('123');
  await shot(page, dir, 'invalid-mobile');

  await page.locator(SEL.loginBtn).click();
  await page.waitForTimeout(2000);
  await shot(page, dir, 'after-login-click');

  const { detected } = await hasErrorOrValidation(page);
  console.log(`  Validation shown: ${detected}`);
  console.log(`  ${detected ? '✅ PASS' : '❌ FAIL'}`);
  return { status: detected ? 'PASS' : 'FAIL' };
}

// ---- Scenario 5: Empty mobile ----
async function s5(page, dir) {
  await gotoLogin(page);
  await shot(page, dir, 'login-page');
  await shot(page, dir, 'mobile-field-empty');

  await page.locator(SEL.loginBtn).click();
  await page.waitForTimeout(2000);
  await shot(page, dir, 'after-login-click');

  const { detected } = await hasErrorOrValidation(page);
  console.log(`  Validation shown: ${detected}`);
  console.log(`  ${detected ? '✅ PASS' : '❌ FAIL'}`);
  return { status: detected ? 'PASS' : 'FAIL' };
}

// ---- Scenario 6: Empty OTP ----
async function s6(page, dir) {
  await gotoLogin(page);
  await shot(page, dir, 'login-page');

  await page.locator(SEL.mobile).fill('540000007');
  await shot(page, dir, 'mobile-entered');

  await page.locator(SEL.loginBtn).click();
  await waitAfterLogin(page);
  await shot(page, dir, 'otp-page');

  const rejected = await loginWasRejected(page);
  if (rejected) {
    console.log(`  Mobile rejected before OTP step.`);
    return { status: 'FAIL', detail: 'Mobile rejected — cannot test empty OTP' };
  }

  await shot(page, dir, 'otp-field-empty');

  // Check if the verify button is disabled (app prevents submission with empty OTP)
  const verifyBtn = page.locator(SEL.verifyBtn);
  const btnExists = await verifyBtn.count() > 0;
  const btnDisabled = btnExists ? await verifyBtn.isDisabled().catch(() => false) : false;
  
  if (btnDisabled) {
    await shot(page, dir, 'verify-button-disabled');
    console.log(`  Verify button is DISABLED when OTP is empty.`);
    console.log(`  ✅ PASS — app prevents submission (button disabled)`);
    return { status: 'PASS', detail: 'Verify button disabled when OTP empty — submission prevented' };
  }

  // If not disabled, try clicking
  await verifyBtn.click({ timeout: 5000 }).catch(() => {});
  await page.waitForTimeout(2000);
  await shot(page, dir, 'after-verify-empty');

  const { detected } = await hasErrorOrValidation(page);
  console.log(`  Validation shown: ${detected}`);
  console.log(`  ${detected ? '✅ PASS' : '❌ FAIL'}`);
  return { status: detected ? 'PASS' : 'FAIL' };
}

// ---- Scenario 7: Whitespace mobile ----
async function s7(page, dir) {
  await gotoLogin(page);
  await shot(page, dir, 'login-page');

  await page.locator(SEL.mobile).fill('   ');
  await shot(page, dir, 'whitespace-mobile');

  await page.locator(SEL.loginBtn).click();
  await page.waitForTimeout(2000);
  await shot(page, dir, 'after-login-click');

  const { detected } = await hasErrorOrValidation(page);
  console.log(`  Validation shown: ${detected}`);
  console.log(`  ${detected ? '✅ PASS' : '❌ FAIL'}`);
  return { status: detected ? 'PASS' : 'FAIL' };
}

// ---- Scenario 8: Non-numeric OTP ----
async function s8(page, dir) {
  await gotoLogin(page);
  await shot(page, dir, 'login-page');

  await page.locator(SEL.mobile).fill('540000007');
  await shot(page, dir, 'mobile-entered');

  await page.locator(SEL.loginBtn).click();
  await waitAfterLogin(page);
  await shot(page, dir, 'otp-page');

  const preCheck = await loginWasRejected(page);
  if (preCheck) {
    console.log(`  Mobile rejected before OTP step.`);
    return { status: 'FAIL', detail: 'Mobile rejected — cannot test non-numeric OTP' };
  }

  await typeOTP(page, 'abc123');
  await shot(page, dir, 'non-numeric-otp');

  // Check if alpha chars were silently rejected
  const inputs = page.locator('input');
  const count = await inputs.count();
  let vals = '';
  for (let i = 0; i < count; i++) vals += await inputs.nth(i).inputValue().catch(() => '');
  const alphaRejected = !/[a-zA-Z]/.test(vals);

  // Check if button is disabled (non-numeric input rejected → fields empty → button disabled)
  const verifyBtn = page.locator(SEL.verifyBtn);
  const btnDisabled = await verifyBtn.isDisabled().catch(() => false);

  if (alphaRejected && btnDisabled) {
    await shot(page, dir, 'verify-button-disabled');
    console.log(`  Alpha rejected by field: ${alphaRejected}, Button disabled: ${btnDisabled}`);
    console.log(`  ✅ PASS — non-numeric chars rejected, button disabled`);
    return { status: 'PASS', detail: 'OTP field rejected non-numeric input; button disabled' };
  }

  await verifyBtn.click({ timeout: 5000 }).catch(() => {});
  await page.waitForTimeout(2000);
  await shot(page, dir, 'after-verify');

  const { detected } = await hasErrorOrValidation(page);
  const passed = detected || alphaRejected;
  console.log(`  Alpha rejected by field: ${alphaRejected}, Validation shown: ${detected}`);
  console.log(`  ${passed ? '✅ PASS' : '❌ FAIL'}`);
  return { status: passed ? 'PASS' : 'FAIL', detail: alphaRejected ? 'Field rejected non-numeric input' : undefined };
}

// ---- Scenario 9: Spaces-only OTP ----
async function s9(page, dir) {
  await gotoLogin(page);
  await shot(page, dir, 'login-page');

  await page.locator(SEL.mobile).fill('540000007');
  await shot(page, dir, 'mobile-entered');

  await page.locator(SEL.loginBtn).click();
  await waitAfterLogin(page);
  await shot(page, dir, 'otp-page');

  const preCheck = await loginWasRejected(page);
  if (preCheck) {
    console.log(`  Mobile rejected before OTP step.`);
    return { status: 'FAIL', detail: 'Mobile rejected — cannot test spaces OTP' };
  }

  const inputs = page.locator('input');
  const count = await inputs.count();
  for (let i = 0; i < count; i++) {
    await inputs.nth(i).fill(' ');
    await page.waitForTimeout(50);
  }
  await shot(page, dir, 'spaces-otp');

  // Check if button is disabled (spaces rejected → fields empty → button disabled)
  const verifyBtn = page.locator(SEL.verifyBtn);
  const btnDisabled = await verifyBtn.isDisabled().catch(() => false);

  if (btnDisabled) {
    await shot(page, dir, 'verify-button-disabled');
    console.log(`  Verify button DISABLED with spaces-only OTP.`);
    console.log(`  ✅ PASS — app prevents submission (button disabled)`);
    return { status: 'PASS', detail: 'Verify button disabled with spaces-only OTP — submission prevented' };
  }

  await verifyBtn.click({ timeout: 5000 }).catch(() => {});
  await page.waitForTimeout(3000);
  await shot(page, dir, 'after-verify');

  const { detected } = await hasErrorOrValidation(page);
  console.log(`  Error shown: ${detected}`);
  console.log(`  ${detected ? '✅ PASS' : '❌ FAIL'}`);
  return { status: detected ? 'PASS' : 'FAIL' };
}

// ===================== MAIN =====================

async function main() {
  console.log('🚀 Vendor App Login — 9 Scenarios');
  console.log(`Evidence: ${BASE_EVIDENCE}`);
  console.log(`URL: ${LOGIN_URL}\n`);

  const browser = await chromium.launch({ headless: false, slowMo: 400 });

  const scenarios = [
    // Rerun S6 and S9
    [6, 'Login fails when OTP is empty', s6],
    [9, 'Login fails with OTP containing only spaces', s9],
  ];

  for (const [id, name, fn] of scenarios) {
    await runScenario(browser, id, name, fn);
  }

  await browser.close();

  // Summary
  const pass = results.filter(r => r.status === 'PASS').length;
  const fail = results.filter(r => r.status === 'FAIL').length;
  console.log('\n\n==================== EXECUTION SUMMARY ====================');
  console.log(`Date: 2026-04-23  |  Total: ${results.length}  |  ✅ ${pass}  |  ❌ ${fail}`);
  console.log('-----------------------------------------------------------');
  for (const r of results) {
    const icon = r.status === 'PASS' ? '✅' : '❌';
    const extra = r.error ? ` — ${r.error}` : (r.detail ? ` — ${r.detail}` : (r.url ? ` — ${r.url}` : ''));
    console.log(`  ${icon} S${r.id}: ${r.name}${extra}`);
    if (r.consoleErrors?.length) console.log(`     Console: ${r.consoleErrors.slice(0,2).join('; ').substring(0,200)}`);
  }
  console.log('===========================================================');

  fs.writeFileSync(path.join(BASE_EVIDENCE, 'results.json'), JSON.stringify(results, null, 2));
  console.log(`\nResults → ${path.join(BASE_EVIDENCE, 'results.json')}`);
}

main().catch(e => { console.error('FATAL:', e); process.exit(1); });
