// Render the review page; artwork files remain unchanged.
const fs = require('node:fs');
const path = require('node:path');
const { pathToFileURL } = require('node:url');
const { createHash } = require('node:crypto');
const { chromium } = require('playwright');

(async () => {
  const manifest = JSON.parse(fs.readFileSync(path.join(__dirname, 'Prompts.json'), 'utf8'));
  const hashes = manifest.skills.map(skill => createHash('sha256').update(fs.readFileSync(path.join(__dirname, `${skill.id}.png`))).digest('hex'));
  if (new Set(hashes).size !== 8) throw new Error('Expected eight distinct artwork files.');
  const browser = await chromium.launch({ headless: true, channel: process.env.SKILL_ART_BROWSER_CHANNEL || 'chrome' });
  try {
    const page = await browser.newPage({ viewport: { width: 1180, height: 960 }, deviceScaleFactor: 1 });
    await page.goto(pathToFileURL(path.join(__dirname, 'index.html')).href);
    await page.evaluate(async () => { await document.fonts.ready; await Promise.all([...document.images].map(image => image.decode())); });
    const result = await page.evaluate(() => ({
      art: [...document.querySelectorAll('.art')].map(image => ({ file: image.getAttribute('src'), width: image.naturalWidth, height: image.naturalHeight })),
      slotSizes: [...document.querySelectorAll('.slot')].map(slot => ({ width: slot.offsetWidth, height: slot.offsetHeight })),
      smallSizes: [...document.querySelectorAll('.smallbar img')].map(image => ({ width: image.offsetWidth, height: image.offsetHeight })),
      overflow: document.documentElement.scrollWidth > innerWidth
    }));
    if (result.art.length !== 8 || result.art.some(item => !item.width || item.width !== item.height)) throw new Error('Artwork is missing or not square.');
    if (result.slotSizes.some(item => item.width !== 40 || item.height !== 40)) throw new Error('Hotbar preview must have 40 px slots.');
    if (result.smallSizes.some(item => item.width !== 32 || item.height !== 32)) throw new Error('Reduced icons must measure 32 px.');
    if (result.overflow) throw new Error('Desktop preview overflows horizontally.');
    await page.screenshot({ path: path.join(__dirname, 'SkillArtSample.png'), fullPage: true });
    await page.setViewportSize({ width: 390, height: 844 });
    const mobileOverflow = await page.evaluate(() => document.documentElement.scrollWidth > innerWidth);
    if (mobileOverflow) throw new Error('Mobile preview overflows horizontally.');
    console.log(JSON.stringify({ ...result, mobileOverflow, screenshot: path.join(__dirname, 'SkillArtSample.png') }, null, 2));
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
