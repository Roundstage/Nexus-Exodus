const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const os = require('node:os');
const cp = require('node:child_process');
const root = path.resolve(__dirname, '..');
let playwright;
for (const candidate of [process.env.NEXUS_PLAYWRIGHT_MODULE, 'playwright', path.join(root, '.codex-tmp/balance-workbook/node_modules/playwright')].filter(Boolean)) {
  try { playwright = require(candidate); break; } catch (error) { if (error.code !== 'MODULE_NOT_FOUND') throw error; }
}
if (!playwright) throw new Error('Install playwright or set NEXUS_PLAYWRIGHT_MODULE.');
const { chromium } = playwright;
const output = path.join(root, '.codex-tmp/MilestoneShop');
const css = fs.readFileSync(path.join(root, 'src/Code/UI/Browser/MilestoneShop.css'), 'utf8');
const js = fs.readFileSync(path.join(root, 'src/Code/UI/Browser/MilestoneShop.js'), 'utf8');
const catalog = fs.readFileSync(path.join(root, 'src/Code/PlayerMechanics/Milestones.dm'), 'utf8');
const shopSource = fs.readFileSync(path.join(root, 'src/Code/UI/MilestoneShop.dm'), 'utf8');
const hudSource = fs.readFileSync(path.join(root, 'src/Code/UI/HudLibrary.dm'), 'utf8');
const categoryIconSource = shopSource.split('var/list/milestone_shop_art_layout')[0];
const iconKinds = [...new Set([...categoryIconSource.matchAll(/return "([^"]+)"/g)].map(match => match[1]))];
const artLayout = JSON.parse(fs.readFileSync(path.join(root, 'src/Images/Milestones/MilestoneIcons.json'), 'utf8'));

// Export the actual shared HUD renderer in a tiny headless world. No game client or saves.
const themeDirectory = path.join(output, 'HudTheme');
fs.mkdirSync(path.join(themeDirectory, 'src/Icons/Unsorted'), { recursive: true });
fs.copyFileSync(path.join(root, 'src/Icons/Unsorted/UserNamesBarsUi.png'), path.join(themeDirectory, 'src/Icons/Unsorted/UserNamesBarsUi.png'));
fs.mkdirSync(path.join(themeDirectory, 'src/Images/Milestones'), { recursive: true });
for (const filename of ['MilestoneIcons.png', 'MilestoneIcons.json']) fs.copyFileSync(path.join(root, 'src/Images/Milestones', filename), path.join(themeDirectory, 'src/Images/Milestones', filename));
const iconProc = hudSource.slice(hudSource.indexOf('proc/getNexusPixelInterfaceIcon('), hudSource.indexOf('proc/getNexusPixelInterfaceIconResource('));
const themeProc = hudSource.slice(hudSource.indexOf('proc/getNexusHudBrowserCss('), hudSource.indexOf('client/var/tmp', hudSource.indexOf('proc/getNexusHudBrowserCss(')));
const artProc = shopSource.slice(shopSource.indexOf('var/list/milestone_shop_art_layout'), shopSource.indexOf('proc/getMilestoneShopIconResource'));
const themeFixture = `var/list/nexus_pixel_interface_icon_cache = list()\n${iconProc}\n${themeProc}\n${artProc}\nworld/New()\n\tfor(var/kind in list(${iconKinds.map(kind => `"${kind}"`).join(',')}))\n\t\tfcopy(getNexusPixelInterfaceIcon(kind), "[kind].png")\n\tfor(var/milestone_id in list(${artLayout.ids.map(id => `"${id}"`).join(',')}))\n\t\tfcopy(getMilestoneShopIcon(milestone_id), "[milestone_id].png")\n\tfdel("HudTheme.css")\n\ttext2file(getNexusHudBrowserCss("bronze"), "HudTheme.css")\n\tshutdown()\n`;
fs.writeFileSync(path.join(themeDirectory, 'HudTheme.dme'), themeFixture);
const byondBin = process.env.NEXUS_BYOND_BIN || path.join(os.tmpdir(), 'Nexus-Exodus-BYOND-516.1686/byond/bin');
const compileOutput = cp.execFileSync(path.join(byondBin, process.platform === 'win32' ? 'dm.exe' : 'DreamMaker'), ['HudTheme.dme'], { cwd: themeDirectory, encoding: 'utf8', windowsHide: true, timeout: 30000 });
assert(compileOutput.includes('0 errors, 0 warnings'), compileOutput);
cp.execFileSync(path.join(byondBin, process.platform === 'win32' ? 'dd.exe' : 'DreamDaemon'), ['HudTheme.dmb', '-invisible', '-safe', '-cd', themeDirectory, '-log', path.join(themeDirectory, 'Export.log')], { cwd: themeDirectory, windowsHide: true, timeout: 15000 });
const themeCss = fs.readFileSync(path.join(themeDirectory, 'HudTheme.css'), 'utf8').replace(/url\('Silkscreen(Regular|Bold).ttf'\)/g, (_, weight) => `url('data:font/ttf;base64,${fs.readFileSync(path.join(root, 'src/Fonts', `Silkscreen${weight}.ttf`)).toString('base64')}')`);
function iconForKind(kind) { return `data:image/png;base64,${fs.readFileSync(path.join(themeDirectory, `${kind}.png`)).toString('base64')}`; }
function lookupIconKind(source, value) {
  for (const match of source.matchAll(/if\(([^\n]+)\) return "([^"]+)"/g)) {
    if ([...match[1].matchAll(/"([^"]+)"/g)].some(item => item[1] === value)) return match[2];
  }
}
// Read authored definitions and the actual BYOND-cropped artwork in browser fixtures.
const definitions = [...catalog.matchAll(/milestone_catalog\["([^"]+)"\] = new \/datum\/MilestoneDefinition\("[^"]+", "([^"]+)", "([^"]+)", (\d+), (\d+), "([^"]+)"([^\r\n]*)/g)].map(match => {
  const [, id, name, description, cost, maxRank, category, tail] = match;
  const exclusiveGroup = tail.match(/, null, "([^"]+)"\)/)?.[1] || null;
  const icon = iconForKind(id);
  return { id, name, description: JSON.parse('"' + description + '"'), cost: Number(cost), maxRank: Number(maxRank), category, exclusiveGroup, icon };
});
assert.equal(definitions.length, (catalog.match(/= new \/datum\/MilestoneDefinition\(/g) || []).length, 'Fixture parser omitted an authored milestone');
assert(definitions.length >= 49);
assert.deepEqual(artLayout.ids, definitions.map(entry => entry.id), 'Artwork index does not cover the live catalog');
assert.equal(new Set(definitions.map(entry => entry.icon)).size, definitions.length, 'Milestone artwork is duplicated');
function fixture(points = 8, owned = {}) {
  const entries = definitions.map(entry => {
    const rank = owned[entry.id] || 0;
    const chosen = entry.exclusiveGroup && definitions.find(other => other.exclusiveGroup === entry.exclusiveGroup && owned[other.id]);
    const reason = chosen && chosen.id !== entry.id ? `You chose ${chosen.name}. Choose only one damage style.` :
      points < entry.cost ? `Requires ${entry.cost} Milestone Points.` : '';
    return { ...entry, rank, exclusiveChoice: chosen?.id || '', reason: rank >= entry.maxRank ? '' : reason,
      state: rank >= entry.maxRank ? 'owned' : reason ? 'locked' : 'available' };
  });
  return { ref: '[0x210001]', character: 'Aster', race: 'Human', points, earned: 8, cap: 22, entries,
    categories: ['Builds', ...new Set(entries.map(entry => entry.category).filter(value => value !== 'Builds'))],
    categoryIcons: Object.fromEntries(['All', ...new Set(entries.map(entry => entry.category))].map(category => [category, iconForKind(lookupIconKind(categoryIconSource, category) || 'milestones')])),
    damageStyle: entries.find(entry => entry.exclusiveGroup === 'secondary_damage_stat' && entry.rank)?.name || '', notice: '' };
}
function html(config) {
  // BYOND url_encode uses form encoding: spaces become +, literal + becomes %2B.
  const encoded = new URLSearchParams({ config: JSON.stringify(config) }).toString().slice('config='.length);
  const bootstrap = shopSource.match(/<script>(window\.milestoneShopConfig=.*?)<\/script>/)[1].replace('[encoded_config]', () => encoded);
  return `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Nexus Milestone Shop preview</title><style>${themeCss}</style><style>${css}</style></head><body class="nexus-hud milestone-shop"><script>${bootstrap}window.sent=[];window.milestoneShopTestTransport=function(url){window.sent.push(url);};</script><script>${js}</script></body></html>`;
}
(async () => {
  fs.mkdirSync(output, { recursive: true });
  const browser = await chromium.launch({ executablePath: process.env.NEXUS_BROWSER_EXECUTABLE || (process.platform === 'win32' ? 'C:/Program Files/Google/Chrome/Application/chrome.exe' : undefined), headless: true });
  try {
    const page = await browser.newPage({ viewport: { width: 1280, height: 820 } });
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    let config = fixture();
    await page.route('http://milestone-shop.test/**', route => route.fulfill({ contentType: 'text/html', body: html(config) }));
    await page.goto('http://milestone-shop.test/');
    assert.equal(await page.locator('[data-id="momentum_damage"] .card-name').textContent(), 'Momentum Damage', 'BYOND transport replaced spaces with plus signs');
    const atlas = `data:image/png;base64,${fs.readFileSync(path.join(root, 'src/Images/Milestones/MilestoneIcons.png')).toString('base64')}`;
    const wrongCrops = await page.evaluate(async ({ atlas, size, columns }) => {
      async function load(src) { const img = new Image(); img.src = src; await img.decode(); return img; }
      const sheet = await load(atlas);
      const canvas = document.createElement('canvas'); canvas.width = canvas.height = size;
      const context = canvas.getContext('2d');
      const wrong = [];
      for (var i = 0; i < milestoneShopConfig.entries.length; i++) {
        const entry = milestoneShopConfig.entries[i];
        const icon = await load(entry.icon);
        if (icon.naturalWidth !== size || icon.naturalHeight !== size) { wrong.push(entry.id); continue; }
        context.clearRect(0, 0, size, size);
        context.drawImage(sheet, (i % columns) * size, Math.floor(i / columns) * size, size, size, 0, 0, size, size);
        const expected = context.getImageData(0, 0, size, size).data;
        context.clearRect(0, 0, size, size); context.drawImage(icon, 0, 0);
        const actual = context.getImageData(0, 0, size, size).data;
        let mismatched = 0;
        for (var p = 0; p < actual.length; p++) if (Math.abs(actual[p] - expected[p]) > 2) mismatched++;
        if (mismatched / actual.length > .01) wrong.push(entry.id);
      }
      return wrong;
    }, { atlas, size: artLayout.size, columns: artLayout.columns });
    assert.deepEqual(wrongCrops, [], 'BYOND crops the wrong atlas cells');
    assert.equal(await page.locator('.milestone-card').count(), definitions.length);
    assert.equal(await page.locator('.wallet.balance strong').textContent(), '8');
    assert.equal(await page.locator('.style-count').textContent(), '0 / 1');
    await page.locator('[data-id="momentum_damage"]').click();
    assert.equal(await page.locator('.detail h2').textContent(), 'Momentum Damage');
    assert.equal(await page.evaluate(() => sent.length), 0, 'Selecting a card purchased it');
    assert.equal(await page.locator('.exclusive-panel .style-option').count(), 3);
    await page.locator('[data-category="Builds"]').click();
    await page.locator('.purchase-button').click();
    assert(await page.locator('.purchase-button').isDisabled(), 'Repeated purchases were not disabled while awaiting the server');
    assert.equal(await page.evaluate(() => sent.length), 1);
    const purchaseUrl = new URL(await page.evaluate(() => sent[0]));
    assert.equal(purchaseUrl.searchParams.get('node'), 'momentum_damage');
    assert.equal(purchaseUrl.searchParams.get('rank'), '0');
    assert.equal(purchaseUrl.searchParams.get('src'), '[0x210001]');

    config = fixture(4, { momentum_damage: 1 });
    config.notice = 'Purchased Momentum Damage, rank 1/1.';
    await page.reload();
    assert.equal(await page.locator('.category-chip.active').getAttribute('data-category'), 'Builds', 'Server response lost the filter');
    assert.equal(await page.locator('.detail h2').textContent(), 'Momentum Damage', 'Server response lost the selected card');
    assert.equal(await page.locator('.wallet.balance strong').textContent(), '4');
    assert.equal(await page.locator('.style-count').textContent(), '1 / 1');
    assert(await page.locator('.purchase-button').isDisabled());
    await page.locator('[data-id="precision_damage"]').focus();
    await page.keyboard.press('Enter');
    assert.equal(await page.locator('.detail h2').textContent(), 'Precision Damage');
    assert((await page.locator('.purchase-reason').textContent()).includes('Momentum Damage'));
    assert(await page.locator('.purchase-button').isDisabled());
    assert.equal(await page.evaluate(() => sent.length), 0, 'Inspecting a locked card dispatched a purchase');
    await page.locator('.style-option').filter({ hasText: 'Fortified Damage' }).click();
    assert((await page.locator('.full-description').textContent()).includes('Resistance'));
    await page.locator('[data-id="versatile_training"]').click();
    assert(await page.locator('.purchase-button').isEnabled(), 'Exclusive style blocked an unrelated milestone');
    assert.equal(await page.locator('.rank-track span').count(), 3);

    await page.locator('[data-category="All"]').click();
    await page.locator('.search').fill('WILLPOWER');
    assert(await page.locator('.milestone-card').count() > 2, 'Search did not match descriptions across categories');
    await page.reload();
    assert.equal(await page.locator('.search').inputValue(), 'WILLPOWER', 'Purchase/reload lost search text');
    await page.locator('.search').fill('no-such-milestone');
    assert(await page.locator('.empty').isVisible());
    await page.getByRole('button', { name: 'Clear filters', exact: true }).click();
    await page.locator('.filter-buyable').click();
    assert.equal(await page.locator('.milestone-card').count(), config.entries.filter(entry => entry.state === 'available').length);
    assert.equal(await page.locator('.milestone-card.locked, .milestone-card.owned').count(), 0);
    await page.locator('.filter-buyable').click();
    await page.locator('.catalog').evaluate(element => { element.scrollTop = 350; element.dispatchEvent(new Event('scroll')); });
    await page.reload();
    assert.equal(await page.locator('.catalog').evaluate(element => element.scrollTop), 350, 'Shop refresh lost catalog scroll');

    config = fixture(0, { iron_will: 3, momentum_damage: 1 });
    config.character = 'D\'Ávila + Ally <img src=x onerror="window.injected=true">';
    config.notice = 'Bonus +10% / A+B & two  spaces\nNext line.';
    await page.reload();
    assert.equal(await page.locator('.character').textContent(), config.character + ' / ' + config.race, 'Character text did not survive form decoding');
    assert.equal(await page.locator('.notice').textContent(), config.notice, 'Form decoding changed literal plus signs, spacing or line breaks');
    assert.deepEqual(await page.evaluate(() => milestoneShopConfig.entries.map(entry => [entry.name, entry.description, entry.category, entry.reason])), config.entries.map(entry => [entry.name, entry.description, entry.category, entry.reason]), 'Milestone copy changed during transport');
    assert.equal(await page.locator('.character img').count(), 0, 'Character name became HTML');
    assert.equal(await page.evaluate(() => window.injected), undefined);
    await page.locator('[data-id="iron_will"]').click();
    assert(await page.locator('.purchase-button').isDisabled(), 'Maxed rank remained purchasable');
    await page.locator('[data-id="keen_edge"]').click();
    assert(await page.locator('.purchase-button').isDisabled(), 'Insufficient MP remained purchasable');

    config = fixture(9, { momentum_damage: 1, iron_will: 1 });
    config.earned = 14;
    await page.reload();
    await page.locator('.catalog').evaluate(element => { element.scrollTop = 0; });
    await page.locator('[data-id="precision_damage"]').click();
    for (const width of [1280, 1000, 760, 660, 480, 360]) {
      await page.setViewportSize({ width, height: 820 });
      assert(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth), `Page overflowed at ${width}px`);
      for (const selector of ['.catalog', '.detail', '.milestone-card']) {
        assert(await page.locator(selector).first().evaluate(element => element.scrollWidth <= element.clientWidth + 1), `${selector} clipped at ${width}px`);
      }
      assert(await page.locator('.purchase-button').isVisible(), `Detail purchase status inaccessible at ${width}px`);
      const textProblems = await page.locator('.card-name, .description, .cost, .rank, .badge').evaluateAll(elements => elements.filter(element => {
        const style = getComputedStyle(element);
        return style.fontFamily.includes('Silkscreen') || parseFloat(style.fontSize) < 12 || element.scrollWidth > element.clientWidth + 1 || element.scrollHeight > element.clientHeight + 1;
      }).map(element => element.textContent));
      assert.deepEqual(textProblems, [], `Milestone text clipped or used unreadable type at ${width}px`);
      if (width > 660) {
        const bounds = await page.locator('.purchase-button').boundingBox();
        assert(bounds.y >= 0 && bounds.y + bounds.height <= 820, `Purchase action required scrolling at ${width}px`);
      }
      if (width === 1280 || width === 1000 || width === 480) await page.screenshot({ path: path.join(output, `MilestoneShop${width}.png`), fullPage: true });
    }
    await page.setViewportSize({ width: 1280, height: 820 });
    await page.locator('[data-id="versatile_training"]').click();
    assert.equal(await page.locator('.full-description p').count(), 2, 'Effects lost paragraph spacing');
    await page.locator('.catalog').evaluate(element => { element.scrollTop = 0; });
    await page.screenshot({ path: path.join(output, 'MilestoneShopReadable1280.png') });
    await page.locator('[data-id="versatile_training"]').screenshot({ path: path.join(output, 'VersatileTraining.png') });
    assert.equal(await page.getByRole('button', { name: 'Progression Trees', exact: true }).count(), 0, 'Milestones still links to Progression Trees');
    await page.getByRole('button', { name: 'Close', exact: true }).click();
    const navigation = await page.evaluate(() => sent);
    assert(!navigation.some(url => url.includes('action=category')), 'Milestones emitted a Progression Trees navigation request');
    assert(navigation.some(url => url.includes('action=close')));
    assert.deepEqual(errors, [], 'Browser runtime errors');
    fs.writeFileSync(path.join(output, 'MilestoneShopPreview.html'), html(config));
    console.log(`PASS: ${definitions.length} live Milestones with distinct verified BYOND artwork crops; readable, unclipped text at six viewport sizes; selection, purchase, rank snapshot, exclusive states, affordability, filters, persistence, escaping and navigation. Preview: ${output}`);
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
