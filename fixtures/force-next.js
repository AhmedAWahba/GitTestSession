async (page) => {
  // Force click the next button via evaluate
  const result = await page.evaluate(() => {
    const btns = Array.from(document.querySelectorAll('button'));
    const next = btns.find(b => b.textContent.includes('الخطوة التالية'));
    if (!next) return 'button not found';
    next.click();
    return 'clicked: ' + next.disabled + ' ' + next.textContent.trim();
  });
  
  await page.waitForTimeout(3000);
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/025-force-click-next.png'});
  
  // Check which step we are on
  const stepIndicator = await page.evaluate(() => {
    // Check if the المعلومات القانونية heading is visible
    const legal = document.querySelector('p.font-bold');
    const allText = Array.from(document.querySelectorAll('p.font-bold')).map(p => p.textContent);
    // Check for step 2 specific content
    const hasCommercialReg = document.body.innerText.includes('السجل التجاري');
    const hasTax = document.body.innerText.includes('ضريبة القيمة');
    return { headings: allText, hasCommercialReg, hasTax };
  });
  
  return { result, stepIndicator };
}
