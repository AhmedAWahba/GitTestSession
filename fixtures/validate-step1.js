async (page) => {
  // Scroll to and click "الخطوة التالية"
  await page.evaluate(() => {
    const btn = Array.from(document.querySelectorAll('button')).find(b => b.textContent.includes('الخطوة التالية'));
    if (btn) btn.scrollIntoView();
  });
  await page.waitForTimeout(300);
  
  const nextBtn = page.locator('button:has-text("الخطوة التالية")');
  await nextBtn.click();
  await page.waitForTimeout(1000);
  
  // Scroll to top
  await page.evaluate(() => {
    const form = document.querySelector('form');
    if (form) form.scrollTop = 0;
  });
  await page.waitForTimeout(300);
  
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/014-revalidation-with-invalid-data.png'});
  
  // Collect all error messages
  const errors = await page.evaluate(() => {
    const errorEls = document.querySelectorAll('[class*="text-red"], [class*="error"], .text-destructive');
    return Array.from(errorEls).map(e => e.textContent.trim()).filter(t => t.length > 0);
  });
  
  return errors;
}
