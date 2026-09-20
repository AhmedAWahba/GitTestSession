#!/usr/bin/env node
/**
 * Visual regression: capture matching screens from two systems, diff them,
 * and emit a single-pair highlighted comparison image plus an HTML report.
 *
 * Usage:
 *   node scripts/visual-diff.js --config scenarios/visual-diff.config.json
 *
 * Requires: npm install --save-dev pixelmatch pngjs
 */
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');
const { PNG } = require('pngjs');
const pixelmatch = require('pixelmatch');

const MAX_IMAGES_PER_BATCH = 20;

function readConfig(configPath) {
  return JSON.parse(fs.readFileSync(configPath, 'utf8'));
}

async function captureScreen({ browser, url, selector, viewport, storageStatePath }) {
  const context = await browser.newContext({
    viewport,
    storageState: storageStatePath && fs.existsSync(storageStatePath) ? storageStatePath : undefined,
  });
  const page = await context.newPage();
  await page.goto(url, { waitUntil: 'networkidle' });

  // Wait for real content instead of a fixed timeout.
  await page.waitForFunction(() => document.querySelectorAll('table tbody tr').length > 0, null, { timeout: 15000 }).catch(() => {});

  const target = selector ? page.locator(selector).first() : page.locator('body');
  const buffer = await target.screenshot();
  await context.close();
  return PNG.sync.read(buffer);
}

function toSameSize(a, b) {
  const width = Math.max(a.width, b.width);
  const height = Math.max(a.height, b.height);
  const pad = (img) => {
    if (img.width === width && img.height === height) return img;
    const out = new PNG({ width, height });
    PNG.bitblt(img, out, 0, 0, img.width, img.height, 0, 0);
    return out;
  };
  return [pad(a), pad(b), width, height];
}

function findDiffBoxes(diffPng, width, height, maxBoxes = 2) {
  // Cluster diff pixels into a small number of bounding boxes via simple flood-fill grouping.
  const visited = new Uint8Array(width * height);
  const boxes = [];
  const isDiff = (x, y) => {
    const idx = (width * y + x) * 4;
    return diffPng.data[idx] === 255 && diffPng.data[idx + 1] === 0 && diffPng.data[idx + 2] === 0;
  };

  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const i = y * width + x;
      if (visited[i] || !isDiff(x, y)) continue;
      // BFS to collect one connected diff cluster.
      const stack = [[x, y]];
      let minX = x, maxX = x, minY = y, maxY = y;
      visited[i] = 1;
      while (stack.length) {
        const [cx, cy] = stack.pop();
        minX = Math.min(minX, cx); maxX = Math.max(maxX, cx);
        minY = Math.min(minY, cy); maxY = Math.max(maxY, cy);
        for (const [dx, dy] of [[1, 0], [-1, 0], [0, 1], [0, -1]]) {
          const nx = cx + dx, ny = cy + dy;
          if (nx < 0 || ny < 0 || nx >= width || ny >= height) continue;
          const ni = ny * width + nx;
          if (visited[ni] || !isDiff(nx, ny)) continue;
          visited[ni] = 1;
          stack.push([nx, ny]);
        }
      }
      boxes.push({ x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1, area: (maxX - minX + 1) * (maxY - minY + 1) });
    }
  }

  return boxes.sort((a, b) => b.area - a.area).slice(0, maxBoxes);
}

async function renderMergedImage({ browser, prototypePath, uatPath, boxes, title, outPath }) {
  const page = await browser.newPage();
  const html = `<!doctype html><html><head><style>
    body{margin:0;background:#edf1f5;font-family:Arial,sans-serif}
    canvas{display:block}
  </style></head><body><canvas id="c"></canvas><script>
    const boxes = ${JSON.stringify(boxes)};
    const img1 = new Image(); const img2 = new Image();
    let loaded = 0;
    function ready() { loaded++; if (loaded === 2) draw(); }
    img1.onload = ready; img2.onload = ready;
    img1.src = ${JSON.stringify('file:///' + prototypePath.replace(/\\\\/g, '/'))};
    img2.src = ${JSON.stringify('file:///' + uatPath.replace(/\\\\/g, '/'))};
    function draw() {
      const gap = 40, pad = 24, headerH = 70, footerH = 60;
      const panelW = Math.max(img1.width, img2.width);
      const panelH = Math.max(img1.height, img2.height);
      const canvas = document.getElementById('c');
      canvas.width = panelW * 2 + gap + pad * 2;
      canvas.height = headerH + panelH + footerH + pad * 2;
      const ctx = canvas.getContext('2d');
      ctx.fillStyle = '#edf1f5'; ctx.fillRect(0, 0, canvas.width, canvas.height);
      ctx.fillStyle = '#111827'; ctx.font = '700 22px Arial';
      ctx.fillText(${JSON.stringify(title)}, pad, 34);
      ctx.font = '700 16px Arial';
      ctx.fillText('Prototype', pad, headerH - 6);
      ctx.fillText('UAT (actual)', pad + panelW + gap, headerH - 6);
      ctx.drawImage(img1, pad, headerH);
      const uatX = pad + panelW + gap;
      ctx.drawImage(img2, uatX, headerH);
      ctx.strokeStyle = '#dc2626'; ctx.lineWidth = 4;
      ctx.fillStyle = '#dc2626'; ctx.font = '700 18px Arial';
      boxes.forEach((b, i) => {
        ctx.strokeRect(uatX + b.x - 6, headerH + b.y - 6, b.width + 12, b.height + 12);
        ctx.fillText(String(i + 1), uatX + b.x - 22, headerH + b.y + 14);
      });
    }
  </script></body></html>`;
  await page.setContent(html);
  await page.waitForTimeout(300);
  await page.locator('canvas').screenshot({ path: outPath });
  await page.close();
}

async function run(configPath) {
  const config = readConfig(configPath);
  const runDir = path.join('evidence', `${new Date().toISOString().replace(/[:.]/g, '-')}-visual-diff`);
  fs.mkdirSync(runDir, { recursive: true });

  const browser = await chromium.launch({ headless: false });
  const reportRows = [];
  let batchIndex = 1;
  let imagesInBatch = 0;

  for (const screen of config.screens) {
    if (imagesInBatch >= MAX_IMAGES_PER_BATCH) { batchIndex++; imagesInBatch = 0; }
    const screenDir = path.join(runDir, `batch_${String(batchIndex).padStart(2, '0')}`, screen.slug);
    fs.mkdirSync(screenDir, { recursive: true });

    const prototypePng = await captureScreen({ browser, url: screen.prototypeUrl, selector: screen.selector, viewport: config.viewport, storageStatePath: screen.prototypeStorageState });
    const uatPng = await captureScreen({ browser, url: screen.uatUrl, selector: screen.selector, viewport: config.viewport, storageStatePath: screen.uatStorageState });

    const prototypePath = path.join(screenDir, '01-prototype.png');
    const uatPath = path.join(screenDir, '01-uat.png');
    fs.writeFileSync(prototypePath, PNG.sync.write(prototypePng));
    fs.writeFileSync(uatPath, PNG.sync.write(uatPng));
    imagesInBatch += 2;

    const [a, b, width, height] = toSameSize(prototypePng, uatPng);
    const diff = new PNG({ width, height });
    const diffPixelCount = pixelmatch(a.data, b.data, diff.data, width, height, { threshold: 0.15 });
    const diffMaskPath = path.join(screenDir, '01-diffmask.png');
    fs.writeFileSync(diffMaskPath, PNG.sync.write(diff));
    imagesInBatch += 1;

    const boxes = findDiffBoxes(diff, width, height, 2);
    const mergedPath = path.join(screenDir, '01-merged-highlighted.png');
    await renderMergedImage({
      browser,
      prototypePath: path.resolve(prototypePath),
      uatPath: path.resolve(uatPath),
      boxes,
      title: `${screen.title} — Prototype vs UAT`,
      outPath: mergedPath,
    });
    imagesInBatch += 1;

    reportRows.push({ screen: screen.title, diffPixelCount, regions: boxes.length, mergedPath: path.relative(runDir, mergedPath) });
  }

  await browser.close();

  const reportHtml = `<!doctype html><html><head><meta charset="utf-8"><title>UI Visual Diff Report</title></head><body>
    <h1>User Management — Visual Diff Report</h1>
    <p>Run: ${new Date().toISOString()}</p>
    <table border="1" cellpadding="6" cellspacing="0">
      <tr><th>Screen</th><th>Diff pixels</th><th>Regions</th><th>Image</th></tr>
      ${reportRows.map(r => `<tr><td>${r.screen}</td><td>${r.diffPixelCount}</td><td>${r.regions}</td><td><img src="${r.mergedPath}" width="900"></td></tr>`).join('\n')}
    </table>
  </body></html>`;
  fs.writeFileSync(path.join(runDir, 'report.html'), reportHtml);
  fs.writeFileSync(path.join(runDir, 'report.json'), JSON.stringify(reportRows, null, 2));

  console.log(`Report written to ${path.join(runDir, 'report.html')}`);
}

const configArgIndex = process.argv.indexOf('--config');
const configPath = configArgIndex >= 0 ? process.argv[configArgIndex + 1] : null;
if (!configPath) {
  console.error('Usage: node scripts/visual-diff.js --config <path-to-config.json>');
  process.exit(1);
}
run(configPath).catch((err) => { console.error(err); process.exit(1); });
