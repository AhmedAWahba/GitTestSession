async (page) => {
  // Scroll to top of the form in drawer
  await page.evaluate(() => {
    const drawer = document.querySelector('[class*="drawer-content"]');
    if (drawer) {
      const scrollable = drawer.querySelector('[class*="overflow"]');
      if (scrollable) scrollable.scrollTop = 0;
      else drawer.scrollTop = 0;
    }
  });
  await page.waitForTimeout(500);
  await page.screenshot({path: 'evidence/register_form_validation/2026-04-22/030-form-top-check.png'});
  
  // Get ALL input values to verify they're actually set
  const inputs = await page.evaluate(() => {
    const drawer = document.querySelector('[class*="drawer-content"]');
    if (!drawer) return 'no drawer';
    const allInputs = drawer.querySelectorAll('input, select, textarea');
    return Array.from(allInputs).map(inp => ({
      type: inp.type,
      name: inp.name || '',
      placeholder: (inp.placeholder || '').substring(0, 30),
      value: inp.value,
      visible: inp.offsetParent !== null
    })).filter(i => i.visible);
  });
  
  // Check select values (react-select)
  const selectValues = await page.evaluate(() => {
    const singles = document.querySelectorAll('[class*="singleValue"]');
    return Array.from(singles).map(s => s.textContent.trim());
  });
  
  return { visibleInputs: inputs, selectValues };
}
