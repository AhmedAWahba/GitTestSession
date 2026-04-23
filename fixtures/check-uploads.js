async (page) => {
  // Scroll form to top
  await page.evaluate(() => {
    const drawer = document.querySelector('[class*="drawer-content"]');
    if (drawer) {
      const scrollable = drawer.querySelector('[class*="overflow"]');
      if (scrollable) scrollable.scrollTop = 0;
    }
  });
  await page.waitForTimeout(300);
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/034-step2-top.png'});
  
  // Get all file upload areas
  const uploads = await page.evaluate(() => {
    const fileInputs = document.querySelectorAll('input[type="file"]');
    const uploadAreas = document.querySelectorAll('[class*="dashed"], [class*="dropzone"]');
    const labels = [];
    // Find all upload-related text
    const allText = document.body.innerText;
    const matches = allText.match(/رفع.+/g);
    return {
      fileInputCount: fileInputs.length,
      fileInputDetails: Array.from(fileInputs).map(f => ({
        accept: f.accept,
        multiple: f.multiple,
        visible: f.offsetParent !== null
      })),
      uploadLabels: matches
    };
  });
  
  return uploads;
}
