// Connects to the current app screen on BrowserStack, saves a screenshot and the
// accessibility tree to ios-automation/output/. Run this after every navigation step
// to discover real element locators before wiring them into run-ios-registration.js.
//
// Usage: node ios-automation/capture-screen.js <label>
// Example: node ios-automation/capture-screen.js account-setup-empty

const fs = require('fs');
const path = require('path');
const { remote } = require('webdriverio');
const { getRemoteOptions } = require('./capabilities');

const OUTPUT_DIR = path.join(__dirname, 'output');

async function main() {
  const label = process.argv[2] || `capture-${Date.now()}`;
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });

  const driver = await remote(getRemoteOptions(`capture: ${label}`));
  try {
    await driver.saveScreenshot(path.join(OUTPUT_DIR, `${label}.png`));
    const source = await driver.getPageSource();
    fs.writeFileSync(path.join(OUTPUT_DIR, `${label}.xml`), source);
    console.log(`Saved ${label}.png and ${label}.xml to ios-automation/output/`);
  } finally {
    await driver.deleteSession();
  }
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
