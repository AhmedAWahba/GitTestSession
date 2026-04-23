async (page) => {
  // Set up response listener before clicking
  let apiResponse = null;
  const handler = async (response) => {
    const url = response.url();
    if (url.includes('customers') || url.includes('register') || url.includes('address')) {
      try {
        const json = await response.json();
        apiResponse = { url, status: response.status(), body: JSON.stringify(json).substring(0, 500) };
      } catch(e) {
        apiResponse = { url, status: response.status(), error: e.message };
      }
    }
  };
  page.on('response', handler);
  
  // Click next step
  const nextBtn = page.locator('button:has-text("الخطوة التالية")');
  await nextBtn.scrollIntoViewIfNeeded();
  await nextBtn.click();
  await page.waitForTimeout(5000);
  
  page.off('response', handler);
  
  // Check console errors
  const consoleErrors = await page.evaluate(() => {
    return window.__consoleErrors || [];
  });
  
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/028-after-click-with-listener.png'});
  
  // Check if step 2 appeared
  const hasStep2 = await page.evaluate(() => {
    return document.body.innerText.includes('الاسم القانوني') || document.body.innerText.includes('السجل التجاري/الرقم الموحد');
  });
  
  return { apiResponse, hasStep2 };
}
