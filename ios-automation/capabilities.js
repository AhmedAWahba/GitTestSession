// Shared WebdriverIO remote() options for BrowserStack App Automate (iOS).
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

function getCapabilities(sessionName) {
  const {
    BROWSERSTACK_APP_ID,
    BROWSERSTACK_DEVICE = 'iPhone 14',
    BROWSERSTACK_OS_VERSION = '16',
  } = process.env;

  if (!BROWSERSTACK_APP_ID) {
    throw new Error('BROWSERSTACK_APP_ID is not set. Run: node ios-automation/upload-ipa.js first.');
  }

  return {
    platformName: 'iOS',
    'appium:app': BROWSERSTACK_APP_ID,
    'appium:automationName': 'XCUITest',
    'bstack:options': {
      deviceName: BROWSERSTACK_DEVICE,
      osVersion: BROWSERSTACK_OS_VERSION,
      projectName: 'Apex Registration Comparison',
      buildName: 'iOS registration automation',
      sessionName: sessionName || 'iOS registration run',
      debug: true,
      networkLogs: true,
    },
  };
}

function getRemoteOptions(sessionName) {
  const { BROWSERSTACK_USERNAME, BROWSERSTACK_ACCESS_KEY } = process.env;
  if (!BROWSERSTACK_USERNAME || !BROWSERSTACK_ACCESS_KEY) {
    throw new Error('Set BROWSERSTACK_USERNAME and BROWSERSTACK_ACCESS_KEY in ios-automation/.env');
  }

  return {
    protocol: 'https',
    hostname: 'hub.browserstack.com',
    port: 443,
    path: '/wd/hub',
    user: BROWSERSTACK_USERNAME,
    key: BROWSERSTACK_ACCESS_KEY,
    capabilities: getCapabilities(sessionName),
    logLevel: 'warn',
  };
}

module.exports = { getRemoteOptions };
