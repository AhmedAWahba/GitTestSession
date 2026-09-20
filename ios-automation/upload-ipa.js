// Uploads a local .ipa to BrowserStack App Automate and stores the returned app_url.
// Usage: node ios-automation/upload-ipa.js
// Requires BROWSERSTACK_USERNAME, BROWSERSTACK_ACCESS_KEY, BROWSERSTACK_IPA_PATH in .env.

const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

async function main() {
  const { BROWSERSTACK_USERNAME, BROWSERSTACK_ACCESS_KEY, BROWSERSTACK_IPA_PATH } = process.env;

  if (!BROWSERSTACK_USERNAME || !BROWSERSTACK_ACCESS_KEY) {
    throw new Error('Set BROWSERSTACK_USERNAME and BROWSERSTACK_ACCESS_KEY in ios-automation/.env');
  }

  const ipaPath = path.resolve(__dirname, BROWSERSTACK_IPA_PATH || '../builds/app-ios.ipa');
  if (!fs.existsSync(ipaPath)) {
    throw new Error(`IPA not found at ${ipaPath}. Set BROWSERSTACK_IPA_PATH in ios-automation/.env`);
  }

  const auth = Buffer.from(`${BROWSERSTACK_USERNAME}:${BROWSERSTACK_ACCESS_KEY}`).toString('base64');
  const form = new FormData();
  form.append('file', new Blob([fs.readFileSync(ipaPath)]), path.basename(ipaPath));

  const response = await fetch('https://api-cloud.browserstack.com/app-automate/upload', {
    method: 'POST',
    headers: { Authorization: `Basic ${auth}` },
    body: form,
  });

  const result = await response.json();
  if (!response.ok || !result.app_url) {
    throw new Error(`Upload failed: ${response.status} ${JSON.stringify(result)}`);
  }

  console.log('Uploaded. app_url:', result.app_url);

  const envPath = path.join(__dirname, '.env');
  const envContent = fs.existsSync(envPath) ? fs.readFileSync(envPath, 'utf8') : '';
  const updated = envContent.match(/^BROWSERSTACK_APP_ID=.*$/m)
    ? envContent.replace(/^BROWSERSTACK_APP_ID=.*$/m, `BROWSERSTACK_APP_ID=${result.app_url}`)
    : `${envContent}\nBROWSERSTACK_APP_ID=${result.app_url}\n`;
  fs.writeFileSync(envPath, updated);
  console.log('Saved BROWSERSTACK_APP_ID to ios-automation/.env');
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
