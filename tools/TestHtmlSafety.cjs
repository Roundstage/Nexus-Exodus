// Run after Invoke-ByondSmoke.ps1 -KeepTemp. Fixtures are produced by the real DM renderer.
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
let playwright;
for (const candidate of [process.env.NEXUS_PLAYWRIGHT_MODULE, 'playwright', path.join(root, '.codex-tmp/balance-workbook/node_modules/playwright')].filter(Boolean)) {
  try { playwright = require(candidate); break; } catch (error) { if (error.code !== 'MODULE_NOT_FOUND') throw error; }
}
if (!playwright) throw new Error('Install playwright or set NEXUS_PLAYWRIGHT_MODULE.');
const fixturePath = process.argv[2];
assert(fixturePath, 'Pass the html-safety-fixtures.json path from a kept BYOND smoke run.');
const fragments = JSON.parse(fs.readFileSync(fixturePath, 'utf8'));
assert(fragments.length >= 12, 'Missing actual DM sanitizer fixtures');
const creator = fs.readFileSync(path.join(root, 'src/Code/CharacterCreation/NexusCharacterCreation.dm'), 'utf8');
const review = creator.split(/\r?\n/).find(line => line.trim().startsWith('function buildReview()')).trim().replace(/\\([\[\]])/g, '$1');
assert(!review.includes('innerHTML'), 'Character review must render input through text nodes');
const sourceFiles = fs.readdirSync(path.join(root, 'src/Code'), { recursive: true }).filter(name => name.endsWith('.dm') && !name.includes('_libs'));
for (const name of sourceFiles) {
  const source = fs.readFileSync(path.join(root, 'src/Code', name), 'utf8');
  assert(!/\b[a-z-]+\s*=\s*'[^'\r\n]*?\[html_encode\(/.test(source), `${name}: single-quoted attribute must use the explicit attribute encoder`);
}

(async () => {
  const browser = await playwright.chromium.launch({ executablePath: process.env.NEXUS_BROWSER_EXECUTABLE || (process.platform === 'win32' ? 'C:/Program Files/Google/Chrome/Application/chrome.exe' : undefined), headless: true });
  try {
    const page = await browser.newPage();
    const requests = [], errors = [], dialogs = [];
    await page.route('**/*', route => { requests.push(route.request().url()); return route.abort(); });
    page.on('pageerror', error => errors.push(error.message));
    page.on('dialog', dialog => { dialogs.push(dialog.message()); dialog.dismiss(); });
    await page.setContent('<!doctype html><html><body><main id="messages"></main><button id="sentinel">Trusted control</button></body></html>');
    await page.evaluate(fragments => {
      for (const html of fragments) {
        const entry = document.createElement('div');
        entry.innerHTML = html;
        document.getElementById('messages').appendChild(entry);
      }
    }, fragments);
    const parsed = await page.evaluate(() => {
      const root = document.getElementById('messages');
      const allowedTags = new Set('b strong i em u s strike small big sub sup p div span pre blockquote center font h1 h2 h3 h4 h5 h6 ul ol li table thead tbody tfoot tr td th br hr'.split(' '));
      const allowedAttributes = new Set(['style', 'color', 'size', 'face']);
      return {
        unexpected: Array.from(root.querySelectorAll('*')).flatMap(node => [
          ...(allowedTags.has(node.localName) ? [] : [node.localName]),
          ...Array.from(node.attributes).filter(attribute => !allowedAttributes.has(attribute.name)).map(attribute => attribute.name)
        ]),
        sentinel: document.getElementById('sentinel').textContent
      };
    });
    assert.deepEqual(parsed.unexpected, [], 'Browser parser reconstructed active tags or attributes');
    assert.equal(parsed.sentinel, 'Trusted control');
    assert.deepEqual(requests, [], 'Sanitized fragments initiated network requests');
    assert.deepEqual(dialogs, [], 'Sanitized fragments executed an event handler');

    await page.setContent('<!doctype html><input name="character_name"><div id="alienPoints">50</div><div id="reviewSummary"></div>');
    await page.addScriptTag({ content: `function selectedClothing(){return [];} function checkedValue(){return window.testField;} ${review}` });
    for (const payload of ['<img src=x onerror=alert(1)>', '</h3><script>alert(1)</script>', '\" autofocus onfocus=alert(1) x=\"', "A & B < C ' D"]) {
      await page.locator('[name=character_name]').fill(payload);
      const result = await page.evaluate(value => {
        window.testField = value;
        buildReview();
        return { heading: document.querySelector('#reviewSummary h3').textContent, forbidden: document.querySelectorAll('#reviewSummary img,#reviewSummary script,#reviewSummary [onfocus]').length };
      }, payload);
      assert.equal(result.heading, payload);
      assert.equal(result.forbidden, 0);
    }
    assert.deepEqual(errors, []);
    assert.deepEqual(dialogs, []);
    assert.deepEqual(requests, []);
    console.log(`PASS: ${fragments.length} real DM HTML fixtures parsed inertly, hostile creator names/fields remain text, and quoted-attribute audit passed.`);
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
