async (page) => {
  // Click on city react-select by its ID
  const cityInput = page.locator('#react-select-5-input');
  await cityInput.scrollIntoViewIfNeeded();
  await cityInput.click();
  await page.waitForTimeout(500);
  
  // Screenshot the dropdown
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/020-city-dropdown-open.png'});
  
  // Type الرياض and select
  await cityInput.fill('الرياض');
  await page.waitForTimeout(1000);
  await page.keyboard.press('Enter');
  await page.waitForTimeout(500);
  
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/021-city-selected.png'});
  
  // Click on district react-select
  const districtInput = page.locator('#react-select-6-input');
  await districtInput.scrollIntoViewIfNeeded();
  await districtInput.click();
  await page.waitForTimeout(500);
  
  // Select first option
  await page.keyboard.press('Enter');
  await page.waitForTimeout(500);
  
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/022-district-selected.png'});
  
  // Verify city & district are selected
  const values = await page.evaluate(() => {
    const selects = document.querySelectorAll('[class*="singleValue"]');
    return Array.from(selects).map(s => s.textContent.trim());
  });
  
  return values;
}
