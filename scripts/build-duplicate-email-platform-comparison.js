const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');

const [webSource, androidSource, iosSource] = process.argv.slice(2);
assert(webSource && androidSource && iosSource, 'Provide the Web, Android and iOS screenshot paths, in that order.');

const output = path.resolve(__dirname, '..', 'evidence', 'UI comparison of registration', 'cross-platform', 'duplicate-email-web-android-ios-comparison.png');
const specifications = [
  {
    platform: 'Web', source: webSource,
    crop: { x: 275, y: 20, width: 550, height: 880 },
    highlight: { x: 283, y: 325, width: 521, height: 28 }
  },
  {
    platform: 'Android', source: androidSource,
    crop: { x: 35, y: 380, width: 1130, height: 1900 },
    highlight: { x: 47, y: 982, width: 1108, height: 58 }
  },
  {
    platform: 'iOS', source: iosSource,
    crop: { x: 20, y: 0, width: 790, height: 1080 },
    highlight: { x: 27, y: 354, width: 775, height: 43 }
  }
];

const originalHashes = specifications.map(specification => crypto.createHash('sha256').update(fs.readFileSync(specification.source)).digest('hex'));
const sources = specifications.map(specification => {
  const buffer = fs.readFileSync(specification.source);
  const mime = /\.jpe?g$/i.test(specification.source) ? 'image/jpeg' : 'image/png';
  return { ...specification, source: `data:${mime};base64,${buffer.toString('base64')}` };
});

(async () => {
  const browser = await chromium.launch();
  try {
    const page = await browser.newPage({ viewport: { width: 2000, height: 900 }, deviceScaleFactor: 1 });
    await page.setContent('<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Duplicate-email comparison</title><style>html,body{margin:0;background:#f2f4f7}canvas{display:block}</style></head><body><canvas></canvas></body></html>');
    const result = await page.evaluate(async specifications => {
      const loaded = await Promise.all(specifications.map(async specification => {
        const image = new Image();
        image.src = specification.source;
        await image.decode();
        const { crop, highlight } = specification;
        if (crop.x + crop.width > image.naturalWidth || crop.y + crop.height > image.naturalHeight) {
          throw new Error(`Crop exceeds ${specification.platform} source dimensions`);
        }
        if (highlight.x < crop.x || highlight.y < crop.y || highlight.x + highlight.width > crop.x + crop.width || highlight.y + highlight.height > crop.y + crop.height) {
          throw new Error(`Highlight exceeds ${specification.platform} crop`);
        }
        return { specification, image, width: image.naturalWidth, height: image.naturalHeight };
      }));

      const padding = 28;
      const gap = 36;
      const panelWidth = 620;
      const panelHeight = 1060;
      const imageTop = 102;
      const captions = [
        '1. Web shows "has already been taken"; Android and iOS show "An account already exists for this email."',
        '2. Android has no adjacent sign-in action in this capture; its error text and field outline are brown/orange.',
        '3. iOS additionally displays "Sign In Instead" beside the error; the field outline remains neutral.',
        'Original email fields and messages are preserved. Relevant regions are cropped and resized proportionally; source files are unchanged.'
      ];
      const canvas = document.querySelector('canvas');
      canvas.width = padding * 2 + panelWidth * loaded.length + gap * (loaded.length - 1);
      canvas.height = imageTop + panelHeight + 30 + captions.length * 22 + padding;
      const context = canvas.getContext('2d');
      context.fillStyle = '#f2f4f7';
      context.fillRect(0, 0, canvas.width, canvas.height);
      context.fillStyle = '#111827';
      context.font = '700 22px Arial';
      context.fillText('Registration - Duplicate-email Validation Differs Across Web, Android and iOS', padding, padding + 24);

      const placements = loaded.map(({ specification, image, width, height }, index) => {
        const panelX = padding + index * (panelWidth + gap);
        const scale = panelWidth / specification.crop.width;
        const drawHeight = specification.crop.height * scale;
        if (drawHeight > panelHeight) throw new Error(`${specification.platform} image exceeds its panel`);
        context.fillStyle = '#374151';
        context.font = '700 15px Arial';
        context.fillText(`${specification.platform} - actual`, panelX, imageTop - 10);
        context.fillStyle = '#ffffff';
        context.fillRect(panelX - 4, imageTop - 4, panelWidth + 8, panelHeight + 8);
        context.strokeStyle = '#d1d5db';
        context.lineWidth = 1;
        context.strokeRect(panelX - 4, imageTop - 4, panelWidth + 8, panelHeight + 8);
        context.imageSmoothingEnabled = true;
        context.imageSmoothingQuality = 'high';
        context.drawImage(image, specification.crop.x, specification.crop.y, specification.crop.width, specification.crop.height, panelX, imageTop, panelWidth, drawHeight);
        const highlight = specification.highlight;
        context.strokeStyle = '#dc2626';
        context.lineWidth = 4;
        context.strokeRect(panelX + (highlight.x - specification.crop.x) * scale, imageTop + (highlight.y - specification.crop.y) * scale, highlight.width * scale, highlight.height * scale);
        context.fillStyle = '#dc2626';
        context.font = '700 20px Arial';
        context.fillText(String(index + 1), panelX - 20, imageTop + (highlight.y - specification.crop.y) * scale + 18);
        return { platform: specification.platform, sourceWidth: width, sourceHeight: height, panelWidth, panelHeight, drawHeight };
      });

      context.fillStyle = '#dc2626';
      context.font = '700 16px Arial';
      captions.forEach((caption, index) => {
        if (context.measureText(caption).width > canvas.width - padding * 2) throw new Error('Comparison caption exceeds the canvas width');
        context.fillText(caption, padding, imageTop + panelHeight + 30 + index * 22);
      });
      return { width: canvas.width, height: canvas.height, platforms: placements };
    }, sources);
    fs.mkdirSync(path.dirname(output), { recursive: true });
    await page.locator('canvas').screenshot({ path: output });
    const bytes = fs.readFileSync(output);
    assert(bytes.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])));
    assert.equal(bytes.readUInt32BE(16), result.width);
    assert.equal(bytes.readUInt32BE(20), result.height);
    specifications.forEach((specification, index) => {
      assert.equal(crypto.createHash('sha256').update(fs.readFileSync(specification.source)).digest('hex'), originalHashes[index], 'Source file changed');
    });
    console.log(JSON.stringify({ output, ...result, emailRedacted: false, screenshotTextRewritten: false, sourceFilesUnchanged: true, style: 'equal-sized expanded-context panels with reference-style highlights and captions' }, null, 2));
  } finally {
    await browser.close();
  }
})().catch(error => {
  console.error(error);
  process.exitCode = 1;
});