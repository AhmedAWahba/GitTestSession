const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { pathToFileURL } = require('node:url');
const { chromium } = require('playwright');

const root = path.resolve(__dirname, '..');
const bilingual = process.argv.includes('--bilingual');
const sourceDir = path.join(root, 'evidence', 'registration-validation', bilingual ? '2026-10-26' : '2026-10-25');
const outputDir = path.join(root, 'evidence', 'UI comparison of registration');
const template = path.join(__dirname, 'merge-template.html');

const jobs = [
  {
    id: 'english-confirmation-message',
    title: 'Registration - English Confirmation Error: Copy Differs',
    left: { source: 'prototype/en/confirmation/mismatch-blur.png', x: 250, y: 120, width: 570, height: 275 },
    right: { source: 'en/confirmation/mismatch-blur.png', x: 70, y: 760, width: 570, height: 275 },
    boxes: [{ x: 17, y: 225, width: 535, height: 38 }],
    captions: [
      '1. Prototype: "Passwords do not match." UAT: "does not match password".',
      '   The mismatch error exists in UAT; this is a wording difference, not a missing rule.',
      '   Both captures use different password and confirmation values, followed by blur.',
      'Scope: account setup only. Cropped source viewports differ; not a pixel-diff baseline.'
    ]
  },
  {
    id: 'arabic-confirmation-message',
    title: 'Registration - Arabic Confirmation Error: Copy Differs',
    left: { source: 'prototype/ar/confirmation/mismatch-blur.png', x: 250, y: 140, width: 570, height: 275 },
    right: { source: 'ar/confirmation/mismatch-blur.png', x: 70, y: 760, width: 570, height: 275 },
    boxes: [{ x: 17, y: 225, width: 535, height: 45 }],
    captions: [
      '1. Prototype and UAT show different Arabic wording for the same confirmation mismatch.',
      '   UAT provides an Arabic inline error; the translation is present, but copy differs.',
      '   Compare the red error text beneath Confirm Password in the two panels.',
      'Scope: account setup only. Cropped source viewports differ; not a pixel-diff baseline.'
    ]
  },
  {
    id: 'arabic-empty-submit-feedback',
    title: 'Registration - Arabic Empty Submit: Inline Feedback Missing at Submit',
    left: { source: 'prototype/ar/account/empty-submit.png', x: 250, y: 210, width: 570, height: 370 },
    right: { source: 'ar/account/empty-submit.png', x: 70, y: 610, width: 570, height: 370 },
    boxes: [
      { x: 142, y: 16, width: 238, height: 61 },
      { x: 17, y: 141, width: 535, height: 18 },
      { x: 17, y: 256, width: 535, height: 18 }
    ],
    captions: [
      '1. Arabic UAT invokes an English browser-required popup on untouched empty submission.',
      '2-3. Prototype shows Arabic inline email/password guidance; UAT omits it at this trigger.',
      'Required errors DO appear in Arabic after touching/clearing fields: not absent everywhere.',
      'Browser language: en-US. Account setup only; source viewports differ, not pixel-aligned.'
    ]
  },
  {
    id: 'arabic-back-untranslated',
    title: 'Registration - Arabic Navigation: Back Translation Missing in UAT',
    left: { source: 'prototype/ar/account/navigation.png', x: 250, y: 280, width: 570, height: 270 },
    right: { source: 'ar/account/empty-submit.png', x: 70, y: 280, width: 570, height: 270 },
    boxes: [{ x: 455, y: 97, width: 95, height: 43 }],
    captions: [
      '1. Prototype displays Arabic navigation text; UAT retains the English word "Back".',
      '   Surrounding UAT headings and labels are Arabic, and the application is in RTL mode.',
      '   This is a missing navigation translation, separate from field validation.',
      'Scope: account setup only. Cropped source viewports differ; not a pixel-diff baseline.'
    ]
  }
];

const bilingualJobs = [
  {
    id: 'business-unn-arabic-missing',
    title: 'Business Validation - UNN Format Error Not Translated to Arabic',
    left: { source: 'en/business/unn-short.png', x: 40, y: 450, width: 620, height: 160 },
    right: { source: 'ar/business/unn-short.png', x: 40, y: 450, width: 620, height: 160 },
    boxes: [{ x: 0, y: 111, width: 620, height: 40 }],
    captions: [
      '1. The UNN format error remains English with Arabic selected (lang=ar, dir=rtl).',
      '   Required-field errors translate, but short/long/prefix/letters errors do not.',
      'Both panels are UAT captures, not prototype comparisons. Values were restored afterward.'
    ]
  },
  {
    id: 'business-vat-arabic-missing',
    title: 'Business Validation - VAT Format Error Not Translated to Arabic',
    left: { source: 'en/business/vat-short.png', x: 40, y: 585, width: 620, height: 160 },
    right: { source: 'ar/business/vat-short.png', x: 40, y: 585, width: 620, height: 160 },
    boxes: [{ x: 0, y: 100, width: 620, height: 40 }],
    captions: [
      '1. The VAT format error remains English with Arabic selected (lang=ar, dir=rtl).',
      '   The same fallback appears for invalid length, prefix, suffix, and letters.',
      'Both panels are UAT captures, not prototype comparisons. Values were restored afterward.'
    ]
  },
  {
    id: 'business-tin-arabic-missing',
    title: 'Business Validation - TIN Format Error and Hint Not Translated',
    left: { source: 'en/business/tin-short.png', x: 40, y: 710, width: 620, height: 200 },
    right: { source: 'ar/business/tin-short.png', x: 40, y: 710, width: 620, height: 200 },
    boxes: [{ x: 0, y: 126, width: 620, height: 70 }],
    captions: [
      '1. The optional-field hint and TIN format error remain English in Arabic mode.',
      '   Blank TIN is accepted; a populated TIN must contain exactly ten digits.',
      'Both panels are UAT captures, not prototype comparisons. Values were restored afterward.'
    ]
  },
  {
    id: 'business-owner-arabic-missing',
    title: 'Business Validation - Ownership Rejection Not Translated to Arabic',
    left: { source: 'en/business/owner-mismatch.png', x: 40, y: 330, width: 620, height: 110 },
    right: { source: 'ar/business/owner-mismatch.png', x: 40, y: 330, width: 620, height: 110 },
    boxes: [{ x: 0, y: 0, width: 620, height: 105 }],
    captions: [
      '1. A fresh registry check in Arabic returned the ownership rejection in English.',
      '   The ownership block may be correct; the missing Arabic translation is the finding.',
      'Both panels are UAT captures, not prototype comparisons. No business was created.'
    ]
  }
];

const categories = {
  'arabic-back-untranslated': '01-confirmed-bugs',
  'business-unn-arabic-missing': '01-confirmed-bugs',
  'business-vat-arabic-missing': '01-confirmed-bugs',
  'business-tin-arabic-missing': '01-confirmed-bugs',
  'business-owner-arabic-missing': '01-confirmed-bugs',
  'english-confirmation-message': '02-design-copy-differences',
  'arabic-confirmation-message': '02-design-copy-differences',
  'arabic-empty-submit-feedback': '03-needs-confirmation'
};

function comparisonPaths(job, isBilingual = bilingual) {
  const category = categories[job.id];
  assert(category, `Missing classification for ${job.id}`);
  const cropDir = path.join(outputDir, '04-source-crops');
  return {
    id: job.id,
    category,
    output: path.join(outputDir, category, `${job.id}-comparison.png`),
    leftPath: path.join(cropDir, `${job.id}-${isBilingual ? 'english-uat' : 'prototype'}-crop.png`),
    rightPath: path.join(cropDir, `${job.id}-${isBilingual ? 'arabic-uat' : 'uat'}-crop.png`),
    legacyOutput: path.join(outputDir, `${job.id}-comparison.png`),
    legacyLeftPath: path.join(outputDir, `${job.id}-prototype-crop.png`),
    legacyRightPath: path.join(outputDir, `${job.id}-uat-crop.png`)
  };
}

async function captureCrop(browser, spec, destination) {
  const source = path.join(sourceDir, spec.source);
  assert(fs.existsSync(source), `Missing source screenshot: ${source}`);
  const page = await browser.newPage({ viewport: { width: 1600, height: 1800 }, deviceScaleFactor: 1 });
  try {
    await page.goto(pathToFileURL(source).href);
    await page.evaluate(async (crop) => {
      const image = document.querySelector('img');
      await image.decode();
      if (crop.x + crop.width > image.naturalWidth || crop.y + crop.height > image.naturalHeight) {
        throw new Error('Crop exceeds source screenshot dimensions');
      }
      const canvas = document.createElement('canvas');
      canvas.width = crop.width;
      canvas.height = crop.height;
      canvas.getContext('2d').drawImage(image, crop.x, crop.y, crop.width, crop.height, 0, 0, crop.width, crop.height);
      document.body.replaceChildren(canvas);
      document.body.style.cssText = 'margin:0;background:white';
      canvas.style.display = 'block';
    }, spec);
    await page.locator('canvas').screenshot({ path: destination });
  } finally {
    await page.close();
  }
}

(async () => {
  if (process.argv.includes('--list')) {
    const plan = [
      ...jobs.map(job => comparisonPaths(job, false)),
      ...bilingualJobs.map(job => comparisonPaths(job, true))
    ];
    console.log(JSON.stringify(plan, null, 2));
    return;
  }
  fs.mkdirSync(outputDir, { recursive: true });
  const browser = await chromium.launch();
  try {
    for (const job of bilingual ? bilingualJobs : jobs) {
      const { leftPath, rightPath, output } = comparisonPaths(job);
      fs.mkdirSync(path.dirname(output), { recursive: true });
      fs.mkdirSync(path.dirname(leftPath), { recursive: true });
      await captureCrop(browser, job.left, leftPath);
      await captureCrop(browser, job.right, rightPath);
      const config = {
        title: job.title,
        leftLabel: bilingual ? 'English UAT - actual' : 'Prototype - reference',
        rightLabel: bilingual ? 'Arabic UAT - actual (expected Arabic)' : 'UAT (apex.qawafel.dev) - actual',
        leftSrc: pathToFileURL(leftPath).href,
        rightSrc: pathToFileURL(rightPath).href,
        boxes: job.boxes,
        captions: job.captions
      };
      const url = pathToFileURL(template);
      url.searchParams.set('config', encodeURIComponent(JSON.stringify(config)));
      const page = await browser.newPage({ viewport: { width: 1600, height: 1000 }, deviceScaleFactor: 1 });
      try {
        await page.goto(url.href);
        await page.waitForFunction(() => window.__renderDone === true, null, { timeout: 15000 });
        const dimensions = await page.locator('canvas').evaluate(canvas => ({ width: canvas.width, height: canvas.height }));
        assert.equal(dimensions.width, 92 + Math.max(job.left.width, job.right.width) * 2);
        await page.locator('canvas').screenshot({ path: output });
        const bytes = fs.readFileSync(output);
        assert(bytes.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])));
        console.log(JSON.stringify({ output, ...dimensions }));
      } finally {
        await page.close();
      }
    }
  } finally {
    await browser.close();
  }
})().catch(error => {
  console.error(error);
  process.exitCode = 1;
});