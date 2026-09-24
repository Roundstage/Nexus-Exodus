// Exercise native label/radio focus with the creator's production markup and CSS.
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
let playwright;
for (const candidate of [process.env.NEXUS_PLAYWRIGHT_MODULE, 'playwright', path.join(root, '.codex-tmp/balance-workbook/node_modules/playwright')].filter(Boolean)) {
  try { playwright = require(candidate); break; } catch (error) { if (error.code !== 'MODULE_NOT_FOUND') throw error; }
}
if (!playwright) throw new Error('Install playwright or set NEXUS_PLAYWRIGHT_MODULE.');
const source = fs.readFileSync(path.join(root, 'src/Code/CharacterCreation/NexusCharacterCreation.dm'), 'utf8');
const hud = fs.readFileSync(path.join(root, 'src/Code/UI/HudLibrary.dm'), 'utf8');
const themeSource = hud.slice(hud.indexOf('proc/getNexusHudBrowserCss('), hud.indexOf('client/var/tmp', hud.indexOf('proc/getNexusHudBrowserCss(')));
const colors = Object.fromEntries([...themeSource.split('if(theme')[0].matchAll(/var\/(\w+) = "([^"]+)"/g)].map(match => [match[1], match[2]]));
let theme = themeSource.match(/return \{"([\s\S]*?)"\}/)[1].replace(/(?<!\\)\[(\w+)\]/g, (_, name) => colors[name]);
theme = theme.replace(/\\([\[\]])/g, '$1').replace(/url\('Silkscreen(Regular|Bold).ttf'\)/g, (_, weight) => `url('data:font/ttf;base64,${fs.readFileSync(path.join(root, 'src/Fonts', `Silkscreen${weight}.ttf`)).toString('base64')}')`);
const cssSource = source.slice(source.indexOf('var/css ='), source.indexOf('var/pending_custom_js'));
const css = [...cssSource.matchAll(/(?:var\/css =|css \+=) \{"([\s\S]*?)"\}/g)].map(match => match[1]).join('\n');
assert(css.includes('.race-scroll'), 'Creator CSS was not extracted');
const descriptionStart = source.indexOf('proc/nexusRaceDescription(');
const descriptionSource = source.slice(descriptionStart, source.indexOf('upForm/NexusCharacterCreator', descriptionStart));
const descriptions = Object.fromEntries([...descriptionSource.matchAll(/if\("([^"]+)"\) return "([^"]+)"/g)].map(match => [match[1], match[2]]));
const races = Object.keys(descriptions).sort();
assert(races.length >= 18 && races.at(-1) === 'Viltrumite', 'Missing the long production race list');
const choiceTemplate = source.match(/race_list_html \+= "([^\n]+)"/)[1].replace(/\\"/g, '"');
const choices = races.map(race => choiceTemplate.replaceAll('[html_encode(race_name)]', race).replace('[html_encode(first_icon_alias)]', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLttAAAAABJRU5ErkJggg==')).join('');
let body = source.match(/var\/body = \{"([\s\S]*?)"\}/)[1];
body = body.replace('[race_list_html]', choices).replace(/\[[^\]]*\]/g, '').replace('class="wizard-stage" data-stage="0"', 'class="wizard-stage active" data-stage="0"');
const functions = ['checkedValue', 'setVisible', 'selectFirst', 'selectRace'].map(name => {
  const line = source.split(/\r?\n/).find(line => line.trim().startsWith(`function ${name}(`));
  assert(line, `Missing production ${name}`);
  return line.trim().replace(/\\([\[\]])/g, '$1');
}).join('\n');
// The race handler is real; unrelated attribute/clothing calculations are outside this focus test.
const script = `var descriptions=${JSON.stringify(descriptions)};${functions}
function updateClothingAvailability(){} function updateClothing(){} function traitChanged(){}
document.getElementsByName('selected_race')[0].checked=true;selectRace(document.getElementsByName('selected_race')[0].value);`;
const html = `<!doctype html><html><head><meta charset="utf-8"><style>${theme}</style><style>${css}</style></head><body class="nexus-hud">${body}<script>${script}</script></body></html>`;
const output = path.join(root, '.codex-tmp/CharacterCreationScroll');
fs.mkdirSync(output, { recursive: true });
fs.writeFileSync(path.join(output, 'Preview.html'), html);

async function layout(page) {
  return page.evaluate(() => {
    const panel = document.querySelector('.race-menu');
    const list = document.querySelector('.race-scroll');
    const title = panel.querySelector('h2').getBoundingClientRect();
    return { panelScroll: panel.scrollTop, listScroll: list.scrollTop, listHeight: list.clientHeight, titleY: title.y, pageScroll: document.scrollingElement.scrollTop };
  });
}

(async () => {
  const browser = await playwright.chromium.launch({ executablePath: process.env.NEXUS_BROWSER_EXECUTABLE || (process.platform === 'win32' ? 'C:/Program Files/Google/Chrome/Application/chrome.exe' : undefined), headless: true });
  try {
    const page = await browser.newPage();
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    for (const [width, height] of [[1180, 760], [1180, 640], [1000, 760]]) {
      await page.setViewportSize({ width, height });
      await page.setContent(html);
      await page.evaluate(() => document.fonts.ready);
      const initial = await layout(page);
      await page.locator('.race-scroll').evaluate(list => { list.scrollTop = list.scrollHeight; });
      const bottom = await layout(page);
      assert(bottom.listScroll > 0, 'Fixture did not overflow the race list');
      await page.locator('.race-entry').filter({ has: page.locator('input[value="Viltrumite"]') }).locator('span').click();
      const selected = await layout(page);
      await page.screenshot({ path: path.join(output, `Selected${width}x${height}.png`) });
      assert.equal(await page.locator('input[value="Viltrumite"]').isChecked(), true);
      assert.equal(await page.locator('#raceDescription').textContent(), descriptions.Viltrumite);
      assert.equal(selected.panelScroll, 0, 'Selecting a lower race scrolled the outer panel and hid its heading');
      assert.equal(selected.titleY, initial.titleY, 'Lineage heading moved on selection');
      assert.equal(selected.listScroll, bottom.listScroll, 'Clicking a visible lower race changed the list position');
      assert.equal(selected.listHeight, initial.listHeight, 'Race list changed size on selection');
      assert.equal(selected.pageScroll, 0, 'Selection scrolled the whole creator');
      await page.keyboard.press('ArrowUp');
      assert.equal(await page.locator('input[value="Tsujin"]').isChecked(), true, 'Keyboard race selection stopped working');
      assert.equal((await layout(page)).panelScroll, 0, 'Keyboard selection moved the outer panel');
      await page.locator('.race-scroll').hover();
      await page.mouse.wheel(0, -2000);
      await page.waitForFunction(() => document.querySelector('.race-scroll').scrollTop === 0);
      await page.locator('.race-entry').filter({ has: page.locator('input[value="Alien"]') }).locator('span').click();
      assert.equal(await page.locator('input[value="Alien"]').isChecked(), true);
      assert.equal((await layout(page)).panelScroll, 0, 'Returning to the first race moved the outer panel');
    }
    assert.deepEqual(errors, [], 'Creator browser errors');
    console.log('PASS: lower-race click, heading/list geometry, scroll position, keyboard selection and wheel recovery at three viewport sizes.');
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
