async (page) => {
  // Scroll to top first
  await page.evaluate(() => {
    const form = document.querySelector('form');
    if (form) form.scrollTop = 0;
  });
  await page.waitForTimeout(300);

  // Fill company name Arabic
  await page.locator('input[placeholder*="بالعربية"]').fill('مخبز الاختبار');
  // Fill company name English
  await page.locator('input[placeholder*="English"]').fill('Test Bakery');
  
  // Select store type dropdown
  await page.evaluate(() => {
    const dropdown = document.getElementById('react-select-3-input');
    if (dropdown) dropdown.closest('[class*="control"]').click();
  });
  await page.waitForTimeout(500);
  await page.evaluate(() => {
    const options = document.querySelectorAll('[id*="option"]');
    if (options.length > 0) options[0].click();
  });
  await page.waitForTimeout(300);

  // Fill first name & last name
  await page.locator('input[placeholder*="الأول"]').fill('أحمد');
  await page.locator('input[placeholder*="الأخير"]').fill('وهبة');
  
  // Fill email
  await page.locator('input[placeholder*="email"]').fill('test.bakery820@example.com');
  
  // Fill address name
  const addressInput = page.locator('input[placeholder*="المكتب الرئيسي"]');
  await addressInput.fill('المخبز الرئيسي');
  
  // Fill detailed address
  await page.locator('input[placeholder*="التفصيلي"]').fill('حي النزهة، شارع الملك فهد');
  
  // Select city
  await page.evaluate(() => {
    const dropdown = document.getElementById('react-select-5-input');
    if (dropdown) dropdown.closest('[class*="control"]').click();
  });
  await page.waitForTimeout(500);
  await page.evaluate(() => {
    const options = document.querySelectorAll('[id*="option"]');
    const riyadh = Array.from(options).find(o => o.textContent.includes('الرياض'));
    if (riyadh) riyadh.click();
    else if (options.length > 0) options[0].click();
  });
  await page.waitForTimeout(500);

  // Select district
  await page.evaluate(() => {
    const dropdown = document.getElementById('react-select-6-input');
    if (dropdown) dropdown.closest('[class*="control"]').click();
  });
  await page.waitForTimeout(500);
  await page.evaluate(() => {
    const options = document.querySelectorAll('[id*="option"]');
    if (options.length > 0) options[0].click();
  });
  await page.waitForTimeout(300);

  // Fill street name
  await page.locator('input[placeholder*="الشارع"]').fill('شارع الملك فهد');
  // Fill building number
  await page.locator('input[placeholder="أدخل رقم المبني (مثال:8118)"]').fill('8118');
  // Fill postal code
  await page.locator('input[placeholder*="البريدي"]').fill('12345');
  // Fill short address
  await page.locator('input[placeholder*="RRRD2929"]').fill('TSTB8200');
  // Fill sub address (optional)
  await page.locator('input[placeholder*="الفرعي"]').fill('1234');
  
  await page.waitForTimeout(500);
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/015-step1-filled-valid.png'});
  
  // Click next
  const nextBtn = page.locator('button:has-text("الخطوة التالية")');
  await nextBtn.scrollIntoViewIfNeeded();
  await nextBtn.click();
  await page.waitForTimeout(3000);
  
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/016-step2-legal-info.png'});
  
  const bodyText = await page.evaluate(() => document.body.innerText.substring(0, 300));
  return bodyText;
}
