async (page) => {
  // Find the form section that contains المعلومات القانونية and scroll it to view
  await page.evaluate(() => {
    const sections = document.querySelectorAll('section');
    for (const sec of sections) {
      if (sec.style.display !== 'none' && sec.textContent.includes('المعلومات القانونية')) {
        sec.scrollIntoView();
        break;
      }
    }
  });
  await page.waitForTimeout(500);
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/026-step2-visible.png'});
  
  // Check the visible section content
  const content = await page.evaluate(() => {
    const sections = document.querySelectorAll('section');
    const results = [];
    for (const sec of sections) {
      results.push({
        display: sec.style.display,
        text: sec.textContent.substring(0, 100)
      });
    }
    return results;
  });
  
  return content;
}
