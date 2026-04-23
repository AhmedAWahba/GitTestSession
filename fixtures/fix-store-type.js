async (page) => {
  // Scroll to top
  await page.evaluate(() => {
    const drawer = document.querySelector('[class*="drawer-content"]');
    if (drawer) {
      const scrollable = drawer.querySelector('[class*="overflow"]');
      if (scrollable) scrollable.scrollTop = 0;
    }
  });
  await page.waitForTimeout(300);
  
  // Click the store type dropdown (react-select-3)
  const storeTypeInput = page.locator('#react-select-3-input');
  await storeTypeInput.scrollIntoViewIfNeeded();
  await storeTypeInput.click();
  await page.waitForTimeout(500);
  
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/031-store-type-dropdown.png'});
  
  // Select first option
  await page.keyboard.press('Enter');
  await page.waitForTimeout(500);
  
  // Verify store type is selected
  const selectValues = await page.evaluate(() => {
    const singles = document.querySelectorAll('[class*="singleValue"]');
    return Array.from(singles).map(s => s.textContent.trim());
  });
  
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/032-store-type-selected.png'});
  
  // Now try next step
  const nextBtn = page.locator('button:has-text("الخطوة التالية")');
  await nextBtn.scrollIntoViewIfNeeded();
  await nextBtn.click();
  await page.waitForTimeout(3000);
  
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/033-after-store-type-fix.png'});
  
  const hasStep2 = await page.evaluate(() => {
    return document.body.innerText.includes('الاسم القانوني') || document.body.innerText.includes('السجل التجاري/الرقم الموحد');
  });
  
  return { selectValues, hasStep2 };
}
