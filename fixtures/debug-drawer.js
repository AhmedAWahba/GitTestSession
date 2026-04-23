async (page) => {
  // Get the full inner HTML/text of the drawer
  const drawerContent = await page.evaluate(() => {
    const drawer = document.querySelector('[class*="drawer-content"]');
    if (!drawer) return 'no drawer';
    // Check if step 2 content exists somewhere (even if hidden)
    const allText = drawer.innerText;
    const hasStep2 = allText.includes('الاسم القانوني') || allText.includes('السجل التجاري/الرقم الموحد');
    // Find the form and check its sections
    const form = drawer.querySelector('form');
    if (!form) return 'no form in drawer';
    
    // Check all children of form
    const children = Array.from(form.children);
    const childInfo = children.map(c => ({
      tag: c.tagName,
      display: c.style.display,
      text: c.innerText?.substring(0, 80) || '',
      visible: c.offsetHeight > 0
    }));
    
    return { hasStep2, childrenCount: children.length, childInfo };
  });
  
  return drawerContent;
}
