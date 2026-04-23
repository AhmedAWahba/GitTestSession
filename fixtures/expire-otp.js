async (page) => {
  // Override Date.now to return a time far in the future (+10 minutes)
  await page.evaluate(() => {
    const realDateNow = Date.now.bind(Date);
    const offset = 10 * 60 * 1000;
    Date.now = () => realDateNow() + offset;
    const OrigDate = window.Date;
    window.Date = class extends OrigDate {
      constructor(...args) {
        if (args.length === 0) { super(realDateNow() + offset); } else { super(...args); }
      }
      static now() { return realDateNow() + offset; }
    };
  });
  await page.waitForTimeout(2000);
  const resendText = await page.evaluate(() => {
    const links = Array.from(document.querySelectorAll('a, span, button'));
    const resend = links.find(el => el.textContent.includes('إعادة إرسال'));
    return resend ? resend.textContent.trim() : 'not found';
  });
  return { resendText };
}
