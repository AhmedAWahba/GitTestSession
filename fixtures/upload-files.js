async (page) => {
  const inputs = await page.locator('input[type=file]').all();
  const filePath = 'fixtures/uploads/commercial-registration.jpg';
  for (let i = 0; i < inputs.length; i++) {
    await inputs[i].setInputFiles(filePath);
  }
  return 'uploaded to ' + inputs.length + ' inputs';
}
