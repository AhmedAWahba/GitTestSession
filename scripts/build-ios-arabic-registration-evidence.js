const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');

const [initialPath, validationPath, referencePath] = process.argv.slice(2);
assert(initialPath && validationPath && referencePath, 'Provide the initial, validation and reference screenshot paths.');
const originals = [initialPath, validationPath, referencePath].map(file => {
  const bytes = fs.readFileSync(file);
  return { file, hash: crypto.createHash('sha256').update(bytes).digest('hex'), source: `data:image/png;base64,${bytes.toString('base64')}` };
});
const outputDir = path.resolve(__dirname, '..', 'evidence', 'UI comparison of registration', 'ios-arabic-1.0.0-22');

(async () => {
  const browser = await chromium.launch();
  try {
    const page = await browser.newPage({ viewport: { width: 1400, height: 1900 }, deviceScaleFactor: 1 });
    await page.setContent('<!doctype html><html><body></body></html>');
    const outputs = await page.evaluate(async originals => {
      const images = await Promise.all(originals.map(async original => {
        const image = new Image();
        image.src = original.source;
        await image.decode();
        return image;
      }));
      const crop = { x: 20, y: 350, width: 790, height: 400 };
      const panelWidth = 620;
      const panelHeight = 330;
      const imageTop = 102;
      const comparison = document.createElement('canvas');
      comparison.width = 1332;
      comparison.height = 530;
      const context = comparison.getContext('2d');
      context.fillStyle = '#f2f4f7';
      context.fillRect(0, 0, comparison.width, comparison.height);
      context.fillStyle = '#111827';
      context.font = '700 22px Arial';
      context.fillText('iOS Registration - Arabic Email Validation Wording Differs from Reference', 28, 52);
      const panels = [
        { image: images[2], x: 28, label: 'Supplied reference - expected wording' },
        { image: images[1], x: 684, label: 'iOS 1.0.0 (22) - actual wording' }
      ];
      for (const panel of panels) {
        assertBounds(panel.image, crop);
        context.fillStyle = '#374151';
        context.font = '700 15px Arial';
        context.fillText(panel.label, panel.x, imageTop - 10);
        context.fillStyle = '#ffffff';
        context.fillRect(panel.x - 4, imageTop - 4, panelWidth + 8, panelHeight + 8);
        context.strokeStyle = '#d1d5db';
        context.lineWidth = 1;
        context.strokeRect(panel.x - 4, imageTop - 4, panelWidth + 8, panelHeight + 8);
        context.drawImage(panel.image, crop.x, crop.y, crop.width, crop.height, panel.x, imageTop, panelWidth, crop.height * panelWidth / crop.width);
      }
      const scale = panelWidth / crop.width;
      context.strokeStyle = '#dc2626';
      context.lineWidth = 4;
      context.strokeRect(684 + (24 - crop.x) * scale, imageTop + (680 - crop.y) * scale, 780 * scale, 46 * scale);
      context.fillStyle = '#dc2626';
      context.font = '700 16px Arial';
      const captions = [
        '1. The iOS email-validation message uses different Arabic wording from the supplied reference.',
        'Original fields and message text are preserved; only relevant regions are cropped and proportionally resized.'
      ];
      captions.forEach((caption, index) => {
        if (context.measureText(caption).width > comparison.width - 56) throw new Error('Caption exceeds image width');
        context.fillText(caption, 28, 467 + index * 24);
      });

      const highlighted = document.createElement('canvas');
      highlighted.width = images[0].naturalWidth;
      highlighted.height = images[0].naturalHeight;
      const highlightContext = highlighted.getContext('2d');
      highlightContext.drawImage(images[0], 0, 0);
      const passwordBox = { x: 24, y: 742, width: 780, height: 112 };
      assertBounds(images[0], passwordBox);
      highlightContext.strokeStyle = '#dc2626';
      highlightContext.lineWidth = 5;
      highlightContext.strokeRect(passwordBox.x, passwordBox.y, passwordBox.width, passwordBox.height);
      return [
        { name: 'ios-arabic-email-validation-comparison.png', width: comparison.width, height: comparison.height, png: comparison.toDataURL('image/png').split(',')[1] },
        { name: 'ios-password-placeholder-highlight.png', width: highlighted.width, height: highlighted.height, png: highlighted.toDataURL('image/png').split(',')[1] }
      ];

      function assertBounds(image, region) {
        if (region.x < 0 || region.y < 0 || region.x + region.width > image.naturalWidth || region.y + region.height > image.naturalHeight) {
          throw new Error('Image region exceeds original screenshot dimensions');
        }
      }
    }, originals);
    fs.mkdirSync(outputDir, { recursive: true });
    for (const output of outputs) {
      const file = path.join(outputDir, output.name);
      const bytes = Buffer.from(output.png, 'base64');
      fs.writeFileSync(file, bytes);
      assert(bytes.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])));
      assert.equal(bytes.readUInt32BE(16), output.width);
      assert.equal(bytes.readUInt32BE(20), output.height);
      console.log(JSON.stringify({ file, width: output.width, height: output.height }));
    }
    for (const original of originals) {
      assert.equal(crypto.createHash('sha256').update(fs.readFileSync(original.file)).digest('hex'), original.hash, 'An original screenshot changed');
    }
    console.log('Original screenshot hashes unchanged. Two evidence PNGs generated.');
  } finally {
    await browser.close();
  }
})().catch(error => {
  console.error(error);
  process.exitCode = 1;
});