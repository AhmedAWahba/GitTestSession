const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');

const [englishPath, arabicPath] = process.argv.slice(2);
assert(englishPath && arabicPath, 'Provide the English and Arabic Android screenshot paths.');
const specifications = [
  { file: englishPath, label: 'Android - English baseline', crop: { x: 35, y: 380, width: 1130, height: 720 } },
  { file: arabicPath, label: 'Android - Arabic actual', crop: { x: 35, y: 500, width: 1130, height: 630 } }
];
const originals = specifications.map(specification => {
  const bytes = fs.readFileSync(specification.file);
  return { ...specification, hash: crypto.createHash('sha256').update(bytes).digest('hex'), source: `data:image/jpeg;base64,${bytes.toString('base64')}` };
});
const output = path.resolve(__dirname, '..', 'evidence', 'UI comparison of registration', 'android-arabic', 'android-duplicate-email-localization-comparison.png');

(async () => {
  const browser = await chromium.launch();
  try {
    const page = await browser.newPage({ viewport: { width: 1400, height: 900 }, deviceScaleFactor: 1 });
    await page.setContent('<!doctype html><html lang="en"><body></body></html>');
    const result = await page.evaluate(async originals => {
      const loaded = await Promise.all(originals.map(async original => {
        const image = new Image();
        image.src = original.source;
        await image.decode();
        const { crop } = original;
        if (crop.x + crop.width > image.naturalWidth || crop.y + crop.height > image.naturalHeight) throw new Error('Crop exceeds source dimensions');
        return { ...original, image };
      }));
      const canvas = document.createElement('canvas');
      canvas.width = 1332;
      canvas.height = 640;
      const context = canvas.getContext('2d');
      context.fillStyle = '#f2f4f7';
      context.fillRect(0, 0, canvas.width, canvas.height);
      context.fillStyle = '#111827';
      context.font = '700 22px Arial';
      context.fillText('Android Registration - Duplicate-email Error Remains English in Arabic Mode', 28, 52);
      const imageTop = 102;
      const panelWidth = 620;
      const panelHeight = 410;
      loaded.forEach((original, index) => {
        const panelX = 28 + index * 656;
        context.fillStyle = '#374151';
        context.font = '700 15px Arial';
        context.fillText(original.label, panelX, 92);
        context.fillStyle = '#ffffff';
        context.fillRect(panelX - 4, imageTop - 4, panelWidth + 8, panelHeight + 8);
        context.strokeStyle = '#d1d5db';
        context.lineWidth = 1;
        context.strokeRect(panelX - 4, imageTop - 4, panelWidth + 8, panelHeight + 8);
        const scale = panelWidth / original.crop.width;
        const imageHeight = original.crop.height * scale;
        if (imageHeight > panelHeight) throw new Error('Screenshot exceeds panel height');
        context.imageSmoothingEnabled = true;
        context.imageSmoothingQuality = 'high';
        context.drawImage(original.image, original.crop.x, original.crop.y, original.crop.width, original.crop.height, panelX, imageTop, panelWidth, imageHeight);
        if (index === 1) {
          context.strokeStyle = '#dc2626';
          context.lineWidth = 4;
          context.strokeRect(panelX + (430 - original.crop.x) * scale, imageTop + (1030 - original.crop.y) * scale, 730 * scale, 65 * scale);
          context.fillStyle = '#dc2626';
          context.font = '700 20px Arial';
          context.fillText('1', panelX + (430 - original.crop.x) * scale - 23, imageTop + (1030 - original.crop.y) * scale + 18);
        }
      });
      context.fillStyle = '#dc2626';
      context.font = '700 16px Arial';
      const captions = [
        '1. The Arabic screen retains "An account already exists for this email." in English.',
        'The surrounding heading and field labels are Arabic. Expected: localized Arabic duplicate-email feedback.',
        'English baseline left; Arabic actual right. Original screenshot text is unchanged; password fields are outside the crops.'
      ];
      captions.forEach((caption, index) => {
        if (context.measureText(caption).width > canvas.width - 56) throw new Error('Caption exceeds image width');
        context.fillText(caption, 28, 552 + index * 24);
      });
      return { png: canvas.toDataURL('image/png').split(',')[1], width: canvas.width, height: canvas.height };
    }, originals);
    const bytes = Buffer.from(result.png, 'base64');
    assert(bytes.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])));
    assert.equal(bytes.readUInt32BE(16), result.width);
    assert.equal(bytes.readUInt32BE(20), result.height);
    fs.mkdirSync(path.dirname(output), { recursive: true });
    fs.writeFileSync(output, bytes);
    for (const original of originals) assert.equal(crypto.createHash('sha256').update(fs.readFileSync(original.file)).digest('hex'), original.hash, 'Original screenshot changed');
    console.log(JSON.stringify({ output, width: result.width, height: result.height, originalFilesUnchanged: true, passwordFieldsExcluded: true }, null, 2));
  } finally {
    await browser.close();
  }
})().catch(error => {
  console.error(error);
  process.exitCode = 1;
});