async (page) => {
  // Try clicking the المعلومات القانونية step indicator
  await page.evaluate(() => {
    const els = document.querySelectorAll('*');
    for (const el of els) {
      if (el.childNodes.length === 1 && el.textContent.trim() === 'المعلومات القانونية') {
        el.click();
        return 'clicked indicator';
      }
    }
    return 'not found';
  });
  await page.waitForTimeout(2000);
  
  // Scroll form to top
  await page.evaluate(() => {
    const overlays = document.querySelectorAll('[aria-hidden="false"]');
    for (const overlay of overlays) {
      overlay.scrollTop = 0;
      const scrollable = overlay.querySelector('[class*="overflow"]');
      if (scrollable) scrollable.scrollTop = 0;
    }
  });
  await page.waitForTimeout(500);
  
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/027-step2-indicator-click.png'});
  
  // Get visible heading
  const heading = await page.evaluate(() => {
    const overlay = document.querySelector('[aria-hidden="false"]');
    if (!overlay) return 'no overlay';
    return overlay.innerText.substring(0, 300);
  });
  
  return heading;
}
