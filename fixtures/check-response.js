async (page) => {
  let responses = {};
  const handler = async (response) => {
    const url = response.url();
    if (url.includes('customers/register') || url.includes('customers/addresses')) {
      try {
        responses[url.split('/').pop()] = await response.json();
      } catch(e) {
        responses['error'] = e.message;
      }
    }
  };
  page.on('response', handler);
  
  // Click Create Account button
  const btns = await page.locator('button').all();
  for (const btn of btns) {
    const text = await btn.textContent();
    if (text && text.includes('إنشاء')) {
      await btn.click();
      break;
    }
  }

  // Wait for response
  await page.waitForTimeout(5000);
  page.off('response', handler);
  return responses;
}
