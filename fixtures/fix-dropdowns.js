async (page) => {
  // Find all react-select containers and click city dropdown
  const selectIds = await page.evaluate(() => {
    const inputs = document.querySelectorAll('[id*="react-select"][id*="input"]');
    return Array.from(inputs).map(i => ({ id: i.id, placeholder: i.placeholder || '', visible: i.offsetParent !== null }));
  });
  
  // Try clicking the city dropdown - look for "المدينة" label
  await page.evaluate(() => {
    const labels = document.querySelectorAll('label, p, div');
    for (const label of labels) {
      if (label.textContent.trim() === 'المدينة') {
        const parent = label.closest('div');
        const select = parent?.querySelector('[class*="control"]') || parent?.nextElementSibling?.querySelector('[class*="control"]');
        if (select) { select.click(); return 'clicked city'; }
      }
    }
    // Fallback: find all react-select controls
    const controls = document.querySelectorAll('[class*="indicatorContainer"]');
    if (controls.length >= 2) controls[1].click(); // Second select = city
    return 'fallback';
  });
  await page.waitForTimeout(1000);
  
  // Type to search for الرياض
  await page.keyboard.type('الرياض');
  await page.waitForTimeout(500);
  
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/017-city-dropdown.png'});
  
  // Select first option
  await page.keyboard.press('Enter');
  await page.waitForTimeout(500);
  
  // Now click district dropdown
  await page.evaluate(() => {
    const controls = document.querySelectorAll('[class*="indicatorContainer"]');
    if (controls.length >= 3) controls[2].click();
  });
  await page.waitForTimeout(1000);
  
  // Select first district
  await page.keyboard.press('Enter');
  await page.waitForTimeout(500);
  
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/018-after-dropdowns.png'});
  
  // Now try clicking next step
  const nextBtn = page.locator('button:has-text("الخطوة التالية")');
  await nextBtn.scrollIntoViewIfNeeded();
  await nextBtn.click();
  await page.waitForTimeout(3000);
  
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/019-step2-form.png'});
  
  const bodyText = await page.evaluate(() => document.body.innerText.substring(0, 500));
  return { selectIds, bodyText };
}
