async (page) => {
  const context = page.context();
  const googlePage = context.pages().find((p) => p.url().includes('accounts.google.com'));
  if (!googlePage) {
    return { error: 'Google login tab not found', pages: context.pages().map((p) => p.url()) };
  }

  await googlePage.bringToFront();
  await googlePage.locator('input[type="email"]').fill('ahmedwahba@qawafel.sa');
  await googlePage.getByRole('button', { name: /next/i }).click();
  await googlePage.waitForLoadState('networkidle');

  await googlePage.locator('input[type="password"]').fill('$Wahba2092!');
  await googlePage.getByRole('button', { name: /next/i }).click();
  await googlePage.waitForTimeout(8000);

  const pages = context.pages().map((p) => ({ url: p.url(), title: p.url() }));
  await googlePage.screenshot({ path: 'evidence/figma-google-after-login.png' });
  return { googleUrl: googlePage.url(), pages };
}
