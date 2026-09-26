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
assert(source.includes('body = "<!doctype html>[body]"'), 'Creator must use the standards mode exercised by these fixtures');
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
const bodyTemplate = source.match(/var\/body = \{"([\s\S]*?)"\}/)[1];
let body = bodyTemplate;
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
const sprite = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLttAAAAABJRU5ErkJggg==';
const clothingTemplate = source.match(/clothing_html \+= "([^\n]+)"/)[1].replace(/\\"/g, '"');
const clothes = Array.from({ length: 72 }, (_, i) => clothingTemplate.replaceAll('[clothing_id]', 'clothes' + i).replace('[html_encode(starter_race_scope)]', '*').replace('[html_encode(clothing_alias)]', sprite).replace('[html_encode(clothing.name)]', 'Outfit ' + i)).join('');
const statTemplate = source.match(/stats_html \+= "([^\n]+)"/)[1].replace(/\\"/g, '"');
const statIds = ['energy','strength','endurance','speed','force','resistance','offense','defense','regeneration','recovery','anger'];
const stats = statIds.map(id => statTemplate.replaceAll('[stat_id]', id).replaceAll('[stat_name]', id)).join('');
const wizardFunctions = ['validateStage','showStage','goStage','buildReview','selectedClothing','updateClothing','saveCreatorState','restoreCreatorState','currentProfile','effectiveStatCap','apexGenomeSelected','formatStat','updateStatDisplay','updatePoints','adjustStat'].map(name => {
  const line = source.split(/\r?\n/).find(line => line.trim().startsWith(`function ${name}(`));
  assert(line, `Missing production ${name}`);
  return line.trim().replaceAll('[nexus_starter_clothing_limit]', '4').replace(/\\([\[\]])/g, '$1');
}).join('\n');
const profile = { budget: 1, caps: Object.fromEntries(statIds.map(id => [id, 10])), base: {}, racialPoints: {}, steps: {} };
const responsiveBody = bodyTemplate.replace('[race_list_html]', choices).replace('[clothing_html]', clothes).replace('[stats_html]', stats)
  .replace('[clothing_upload_html]', [1,2,3,4].map(i => `<a href="#" class="hud-button upload-button">Import Layer ${i}</a>`).join(''))
  .replace('[icon_panels_html]', `<label class="portrait-choice"><input name="body_icon_id" type="radio" value="fixture" checked><span><img src="${sprite}"></span></label>`)
  .replace('[age_control]', '<label class="field-label">Age<input name="age" type="number" value="18"></label>')
  .replace('[nexus_starter_clothing_limit]', '4').replace(/\[[^\]]*\]/g, '');
const responsiveHtml = `<!doctype html><html><head><meta charset="utf-8"><style>${theme}</style><style>${css}</style></head><body class="nexus-hud">${responsiveBody}<script>${script}
var currentStage=0,stageNames=['Lineage','Race','Appearance','Attributes','Review'],previewDirection=0,previewFlight=false,creatorStorageKey='responsive-fixture',statIds=${JSON.stringify(statIds)},profiles={'Alien|':${JSON.stringify(profile)}};
${wizardFunctions}
function updatePreview(){} showStage();updatePoints();
document.getElementById('creatorForm').onsubmit=function(event){event.preventDefault();window.submittedCreator=Object.fromEntries(new FormData(this));};
</script></body></html>`;
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
    page.on('dialog', dialog => dialog.accept());
    for (const [width, height] of [[1440,900],[1180,640],[1000,640],[900,600],[800,480],[640,480],[480,640],[360,640],[640,360]]) {
      await page.setViewportSize({ width, height });
      await page.setContent(responsiveHtml);
      await page.evaluate(() => document.fonts.ready);
      for (let stage = 0; stage < 2; stage++) await page.locator('#nextButton').click();
      const name = page.locator('[name="character_name"]');
      const nameBox = await name.boundingBox();
      assert(nameBox.y >= 0 && nameBox.y + nameBox.height < height, `Name hidden on arrival at ${width}x${height}`);
      // Trigger the same empty-name validation seen in the report, then recover.
      await page.locator('#nextButton').click();
      assert.equal(await page.evaluate(() => currentStage), 2);
      assert.equal(await name.evaluate(node => node === document.activeElement), true);
      await name.fill('Responsive Hero');
      await page.locator('[name="gender"][value="female"]').locator('..').locator('span').click();
      for (const control of await page.locator('.preview-controls button,.custom-upload-grid a').all()) {
        await control.scrollIntoViewIfNeeded();
        const box = await control.boundingBox();
        assert(box.x >= 0 && box.x + box.width <= width && box.y >= 0 && box.y + box.height <= height, `Appearance control clipped at ${width}x${height}`);
      }
      const lastOutfit = page.locator('.clothing-choice').last();
      await lastOutfit.locator('span').click();
      assert.equal(await lastOutfit.locator('input').isChecked(), true);
      assert.equal(await page.locator('#clothingCount').textContent(), '1 / 4');
      assert(await page.locator('.clothing-grid').evaluate(node => node.clientHeight > 0 && node.scrollHeight > node.clientHeight), 'Clothing must remain a bounded, usable list');
      for (const button of await page.locator('.wizard-nav button').all()) {
        const box = await button.boundingBox();
        assert(box.y >= 0 && box.y + box.height <= height, 'Navigation escaped the viewport');
      }
      assert(await page.evaluate(() => document.scrollingElement.scrollHeight <= innerHeight && document.scrollingElement.scrollWidth <= innerWidth), 'Creator scroll escaped to the outer document');
      assert(await page.locator('.wizard-content').evaluate(node => node.scrollWidth <= node.clientWidth), `Wizard overflowed horizontally at ${width}px`);
      await page.locator('#nextButton').click();
      await page.locator('.stat-row').first().getByRole('button', { name: '+', exact: true }).click();
      assert.equal(await page.locator('#pointsRemaining').textContent(), '0');
      await page.locator('#nextButton').click();
      assert((await page.locator('#reviewSummary').textContent()).includes('Responsive Hero'));
      await page.getByRole('button', { name: 'Begin Journey' }).click();
      const submitted = await page.evaluate(() => submittedCreator);
      assert.equal(submitted.character_name, 'Responsive Hero'); assert.equal(submitted.gender, 'female');
      assert.equal(submitted.clothing_ids, 'clothes71'); assert.equal(submitted.stat_energy, '1');
      await page.locator('#backButton').click(); await page.locator('#backButton').click();
      assert.equal(await name.inputValue(), 'Responsive Hero', 'Going back lost the character name');
      await page.setViewportSize({ width: 1180, height: 760 });
      await name.scrollIntoViewIfNeeded();
      assert.equal(await name.inputValue(), 'Responsive Hero', 'Resizing lost creation state');
      await page.screenshot({ path: path.join(output, `AppearanceFrom${width}x${height}.png`) });
    }
    assert.deepEqual(errors, [], 'Creator browser errors');
    console.log('PASS: lineage focus/scroll recovery and complete creator navigation, name validation, clothing, attributes, submission and resize at nine viewport sizes.');
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
