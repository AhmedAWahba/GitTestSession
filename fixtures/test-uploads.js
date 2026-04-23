async (page) => {
  const results = {};
  
  // Test 1: Upload oversized file (5MB JPG)
  const fileInput = page.locator('input[type="file"]');
  
  try {
    await fileInput.setInputFiles('fixtures/uploads/large-file.jpg');
    await page.waitForTimeout(2000);
    await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/035-large-file-upload.png'});
    
    // Check for error message
    const errors = await page.evaluate(() => {
      const errorEls = document.querySelectorAll('[class*="text-red"], .text-destructive, [class*="error"]');
      return Array.from(errorEls).map(e => e.textContent.trim()).filter(t => t.length > 0);
    });
    
    // Check if file was accepted
    const uploaded = await page.evaluate(() => {
      const fileNames = document.querySelectorAll('[class*="file-name"], [class*="uploaded"]');
      return Array.from(fileNames).map(f => f.textContent.trim());
    });
    
    results.largeFile = { errors, uploaded, accepted: errors.length === 0 };
  } catch(e) {
    results.largeFile = { error: e.message };
  }
  
  // Remove the file if uploaded
  const deleteBtn = await page.evaluate(() => {
    const btns = document.querySelectorAll('button');
    for (const btn of btns) {
      if (btn.querySelector('svg') && btn.closest('[class*="file"]')) {
        btn.click();
        return 'deleted';
      }
    }
    // Try finding delete icon near uploaded file
    const trash = document.querySelector('[class*="trash"], [class*="delete"], [class*="remove"]');
    if (trash) { trash.click(); return 'trashed'; }
    return 'no delete button';
  });
  await page.waitForTimeout(500);
  
  // Test 2: Upload .exe file (unsupported format)
  try {
    await fileInput.setInputFiles('fixtures/uploads/fake-image.exe');
    await page.waitForTimeout(2000);
    await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/036-exe-file-upload.png'});
    
    const errors2 = await page.evaluate(() => {
      const errorEls = document.querySelectorAll('[class*="text-red"], .text-destructive, [class*="error"]');
      return Array.from(errorEls).map(e => e.textContent.trim()).filter(t => t.length > 0);
    });
    
    results.exeFile = { errors: errors2, accepted: errors2.length === 0 };
  } catch(e) {
    results.exeFile = { error: e.message };
  }
  
  // Test 3: Upload .svg file (not in accepted list)
  try {
    await fileInput.setInputFiles('fixtures/uploads/test.svg');
    await page.waitForTimeout(2000);
    await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/037-svg-file-upload.png'});
    
    const errors3 = await page.evaluate(() => {
      const errorEls = document.querySelectorAll('[class*="text-red"], .text-destructive, [class*="error"]');
      return Array.from(errorEls).map(e => e.textContent.trim()).filter(t => t.length > 0);
    });
    
    results.svgFile = { errors: errors3, accepted: errors3.length === 0 };
  } catch(e) {
    results.svgFile = { error: e.message };
  }
  
  return results;
}
