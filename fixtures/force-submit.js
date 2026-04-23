async (page) => {
  // Listen to ALL requests
  let requests = [];
  const reqHandler = (request) => {
    if (request.url().includes('api') || request.url().includes('customer') || request.method() === 'POST') {
      requests.push({ url: request.url(), method: request.method() });
    }
  };
  page.on('request', reqHandler);
  
  // Submit form using Playwright's proper click
  await page.locator('button.btn-flat-green:has-text("الخطوة التالية")').click({force: true});
  await page.waitForTimeout(5000);
  
  page.off('request', reqHandler);
  
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/029-after-force-click.png'});
  
  const currentText = await page.evaluate(() => {
    const drawer = document.querySelector('[class*="drawer-content"]');
    return drawer ? drawer.innerText.substring(0, 200) : 'no drawer';
  });
  
  return { requests, currentText };
}
