async (page) => {
  await page.locator('input[type=password]').fill('Ax111994');
  await page.locator('button', { hasText: 'Log In' }).click();
  await page.waitForTimeout(8000);
  await page.screenshot({ path: 'evidence/clickup-after-login.png' });
  return page.url();
}
