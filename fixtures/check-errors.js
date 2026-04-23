async (page) => {
  const errors = await page.evaluate(() => {
    const errorEls = document.querySelectorAll('[class*="text-red"], .text-destructive');
    return Array.from(errorEls).map(e => e.textContent.trim()).filter(t => t.length > 0);
  });
  
  // Also check if step 2 indicator is active
  const step2 = await page.evaluate(() => {
    const text = document.body.innerText;
    return text.includes('المعلومات القانونية') ? 'step2 text found' : 'no step2';
  });
  
  // Try clicking next step button again
  const nextBtn = page.locator('button:has-text("الخطوة التالية")');
  await nextBtn.scrollIntoViewIfNeeded();
  await nextBtn.click();
  await page.waitForTimeout(3000);
  
  // Check again
  const errors2 = await page.evaluate(() => {
    const errorEls = document.querySelectorAll('[class*="text-red"], .text-destructive');
    return Array.from(errorEls).map(e => e.textContent.trim()).filter(t => t.length > 0);
  });
  
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/024-after-retry-next.png'});
  
  return { errorsBeforeClick: errors, errorsAfterClick: errors2, step2 };
}
