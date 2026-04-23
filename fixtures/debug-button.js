async (page) => {
  // Let's look at the actual button - check if it exists and is enabled
  const btnInfo = await page.evaluate(() => {
    const btns = Array.from(document.querySelectorAll('button'));
    const next = btns.find(b => b.textContent.includes('الخطوة التالية'));
    if (!next) return 'not found';
    const rect = next.getBoundingClientRect();
    const style = getComputedStyle(next);
    return {
      disabled: next.disabled,
      type: next.type,
      visible: next.offsetParent !== null,
      inViewport: rect.top >= 0 && rect.bottom <= window.innerHeight,
      rect: { top: rect.top, bottom: rect.bottom, left: rect.left, right: rect.right },
      pointerEvents: style.pointerEvents,
      opacity: style.opacity,
      zIndex: style.zIndex,
      overflow: style.overflow,
      parentTag: next.parentElement?.tagName,
      formAction: next.form?.action || 'no form',
      onclick: next.onclick ? 'has onclick' : 'no onclick',
      classList: next.className.substring(0, 100)
    };
  });
  
  return btnInfo;
}
