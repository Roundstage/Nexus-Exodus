// Render the production hotbar with artwork fixtures; no BYOND client or live world.
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const { chromium } = require('playwright');
const root = path.resolve(__dirname, '../..');
const output = path.join(root, 'artifacts/SkillArtwork');
const manifest = JSON.parse(fs.readFileSync(path.join(output, 'Manifest.json')));
const ids = ['DoubleSunday', 'TyrantLancer', 'WolfFangFist', 'RockThrow', 'Shield', 'Zanzoken', 'Heal', 'SolarFlare', 'Slice', 'Kamehameha', 'GodFist', 'FrostNova'];
const skills = ids.map(id => {
 const skill = manifest.skills.find(s => s.id === id);
 assert(skill && fs.existsSync(path.join(root, skill.asset)), 'Missing hotbar artwork: ' + id);
 return skill;
});
const css = fs.readFileSync(path.join(root, 'src/Code/UI/Browser/ClassicHud.css'), 'utf8').replace(/url\('Silkscreen(Regular|Bold).ttf'\)/g, (_, weight) => `url('data:font/ttf;base64,${fs.readFileSync(path.join(root, 'src/Fonts', `Silkscreen${weight}.ttf`)).toString('base64')}')`);
const js = fs.readFileSync(path.join(root, 'src/Code/UI/Browser/ClassicHud.js'), 'utf8');
(async () => {
 const browser = await chromium.launch({ channel: 'chrome', headless: true });
 try {
  const page = await browser.newPage({ viewport: { width: 558, height: 82 }, deviceScaleFactor: 1 });
  const errors = [];
  page.on('pageerror', error => errors.push(String(error)));
  await page.route('https://skill-artwork-preview.invalid/**', route => {
   const id = new URL(route.request().url()).pathname.replace(/^\/nexus_skill_|\.png$/g, '');
   const skill = skills.find(s => s.id === id);
   return skill ? route.fulfill({ contentType: 'image/png', path: path.join(root, skill.asset) }) : route.abort();
  });
  const config = { id: 'bar', kind: 'bar', ref: 'fixture', generation: '1', geometry: { x: 0, y: 0, w: 558, h: 82 }, viewport: { w: 1366, h: 768 } };
  await page.setContent(`<!doctype html><html><head><base href="https://skill-artwork-preview.invalid/"><style>${css}</style></head><body><script>window.classicConfig=${JSON.stringify(config)};window.classicTestTransport=function(){};</script><script>${js}</script>`);
  const slots = skills.map((s, i) => ({ slot: i + 1, position: i + 1, name: s.name, key: ['1','2','3','4','5','6','R','T','F','G','Q','E'][i], icon: `nexus_skill_${s.id}.png`, state: 'ready', label: 'Ready', fallback: false }));
  await page.evaluate(data => classicUpdate(JSON.stringify(data)), { slots, columns: 12, size: 40, locked: false, name: 'Combat' });
  await page.evaluate(() => Promise.all([...document.images].map(im => im.decode())));
  await page.evaluate(() => document.fonts.ready);
  assert.equal(await page.locator('.slot img').count(), 12);
  assert(await page.locator('.slot img').evaluateAll(images => images.every(im => im.naturalWidth === 128 && getComputedStyle(im).imageRendering === 'auto')), 'Hotbar artwork failed to load or uses pixelated sampling');
  assert.deepEqual(errors, []);
  await page.screenshot({ path: path.join(output, 'HotbarPreview.png'), omitBackground: true });
  console.log('PASS: production hotbar rendered 12 distinct artwork resources with smooth sampling.');
 } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
