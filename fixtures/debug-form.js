async (page) => {
  // Check ALL overlays/modals on page
  const overlays = await page.evaluate(() => {
    const fixed = document.querySelectorAll('[class*="fixed"]');
    return Array.from(fixed).map(el => ({
      ariaHidden: el.getAttribute('aria-hidden'),
      display: el.style.display,
      visibility: getComputedStyle(el).visibility,
      classes: el.className.substring(0, 80),
      hasForm: !!el.querySelector('form'),
      text: el.innerText.substring(0, 100)
    }));
  });
  
  // Check if form exists and what step it shows
  const formState = await page.evaluate(() => {
    const forms = document.querySelectorAll('form');
    if (forms.length === 0) return 'no form';
    const lastForm = forms[forms.length - 1];
    const sections = lastForm.querySelectorAll('section');
    return Array.from(sections).map(s => ({
      display: s.style.display,
      text: s.innerText.substring(0, 100),
      visible: s.offsetParent !== null
    }));
  });
  
  return { overlays: overlays.filter(o => o.hasForm || o.text.includes('المعلومات')), formState };
}
