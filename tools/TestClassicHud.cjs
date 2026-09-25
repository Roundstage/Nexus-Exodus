const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
let playwright;
for (const candidate of [process.env.NEXUS_PLAYWRIGHT_MODULE, 'playwright', path.join(root, '.codex-tmp/balance-workbook/node_modules/playwright')].filter(Boolean)) {
  try { playwright = require(candidate); break; } catch (error) { if (error.code !== 'MODULE_NOT_FOUND') throw error; }
}
if (!playwright) throw new Error('Install playwright or set NEXUS_PLAYWRIGHT_MODULE to its installed module path.');
const { chromium } = playwright;
const css = fs.readFileSync(path.join(root, 'src/Code/UI/Browser/ClassicHud.css'), 'utf8').replace(/url\('Silkscreen(Regular|Bold).ttf'\)/g, (_, weight) => `url('data:font/ttf;base64,${fs.readFileSync(path.join(root, 'src/Fonts', `Silkscreen${weight}.ttf`)).toString('base64')}')`);
const js = fs.readFileSync(path.join(root, 'src/Code/UI/Browser/ClassicHud.js'), 'utf8');
const output = path.join(root, 'artifacts/ClassicHud');
fs.mkdirSync(output, { recursive: true });
async function mount(page, id, width, height, scale = 0) {
  // A native browse() navigation replaces timers/listeners from the old document.
  await page.goto('about:blank');
  const config = { id, kind:id.startsWith('bar_')?'bar':id, ref: 'fixture', generation: '1', geometry: { x: 0, y: 0, w: width, h: height }, viewport: { w: 1366, h: 768 } };
  if (scale) {
    Object.assign(config.geometry, { scale, content_w: width, content_h: height, w: Math.ceil(width * scale), h: Math.ceil(height * scale) });
    width = config.geometry.w; height = config.geometry.h;
  }
  await page.setViewportSize({ width, height });
  await page.setContent(`<!doctype html><html><head><style>${css}</style></head><body><script>window.classicConfig=${JSON.stringify(config)};window.sent=[];window.classicTestTransport=u=>sent.push(u);</script><script>${js}</script>`);
}
async function update(page, data) { await page.evaluate(data => classicUpdate(JSON.stringify(data)), data); }
(async () => {
  const executablePath = process.env.NEXUS_BROWSER_EXECUTABLE || (process.platform === 'win32' ? 'C:/Program Files/Google/Chrome/Application/chrome.exe' : undefined);
  const browser = await chromium.launch({ executablePath, headless: true });
  try {
    const page = await browser.newPage();
    const errors = []; page.on('pageerror', error => errors.push(String(error)));
    await mount(page, 'chat', 550, 318);
    const messages = Array.from({ length: 20 }, (_, i) => `<span>[SYSTEM] Message ${i}: short readable text.</span>`);
    await update(page, { channel: 'all', messages, fontSize: 13 });
    for (const action of ['SAY', 'OOC', 'EMOTE']) assert.equal(await page.locator('.footer').getByRole('button', { name: action, exact: true }).count(), 1, `Chat is missing its permanent ${action} action`);
    const metrics = await page.locator('.messages').evaluate(node => ({ line: parseFloat(getComputedStyle(node).lineHeight), height: node.clientHeight, overflow: node.scrollWidth > node.clientWidth }));
    assert(metrics.height / metrics.line >= 8, 'Minimum chat cannot fit eight short lines');
    assert(!metrics.overflow, 'Chat overflows horizontally');
    await page.locator('.messages').evaluate(node => { node.scrollTop = 25; node.dispatchEvent(new Event('scroll')); });
    await update(page, { channel: 'all', messages: [...messages, '<b>New combat message</b>'], fontSize: 13 });
    assert.equal(await page.locator('.messages').evaluate(node => node.scrollTop), 25, 'New arrivals stole history position');
    assert(await page.locator('.latest').isVisible(), 'Missing new-message indicator');
    await page.locator('.latest').click();
    const longMessages = [...messages, 'A'.repeat(900), '<p>A long roleplay paragraph. '.repeat(30) + '</p>'];
    await update(page, { channel: 'all', messages: longMessages, fontSize: 13 });
    assert(await page.locator('.messages').evaluate(node => node.scrollWidth <= node.clientWidth), 'Long words overflow');
    await page.screenshot({ path: path.join(output, 'ChatMinimum.png') });
    await mount(page, 'chat', 420, 230);
    await update(page, { channel: 'all', messages, fontSize: 13 });
    await page.mouse.move(415, 225); await page.mouse.down(); await page.mouse.move(500, 290, { steps: 6 }); await page.mouse.up();
    const geometry = await page.evaluate(() => classicGeometryForTest());
    assert(geometry.w > 420 && geometry.h > 230, 'Corner drag did not resize');
    assert(await page.evaluate(() => sent.some(url => url.includes('action=geometry'))), 'Drag geometry was not persisted');
    // Adopt rounded server geometry even when it arrives during the drag guard.
    await update(page, { channel: 'all', messages, geometry: { x: 24, y: 60, w: 420, h: 230 } });
    await page.waitForFunction(() => classicGeometryForTest().x === 24 && classicGeometryForTest().y === 60);
    for (const width of [638, 360, 240, 638]) {
      await page.setViewportSize({ width, height: 220 });
      await page.waitForFunction(() => {
        const node = document.querySelector('.messages');
        return node.scrollHeight - node.clientHeight - node.scrollTop < 12;
      });
      assert(await page.locator('.messages').evaluate(node => node.scrollWidth <= node.clientWidth), `Chat overflow at ${width}px`);
      for (const control of await page.locator('.footer button, .channels button').all()) {
        const box = await control.boundingBox();
        assert(box.x >= 0 && box.x + box.width <= width && box.y + box.height <= 220, `Chat control clipped at ${width}px`);
      }
    }
    await mount(page, 'bar', 490, 70);
    assert.equal(await page.evaluate(() => getComputedStyle(document.documentElement).backgroundColor), 'rgba(0, 0, 0, 0)', 'Hotbar document root is not transparent');
    assert.equal(await page.evaluate(() => getComputedStyle(document.body).backgroundColor), 'rgba(0, 0, 0, 0)', 'Hotbar document body is not transparent');
    const slots = Array.from({ length: 12 }, (_, i) => ({ slot: i + 1, name: `Skill ${i}`, key: String(i + 1), state: i === 0 ? 'cooldown' : 'ready', remaining: i === 0 ? 8 : 0, duration: 10, label: i === 0 ? '8s' : 'Ready' }));
    await update(page, { slots });
    assert.equal(await page.locator('.slot').count(), 12);
    assert.equal(await page.locator('.shade').first().evaluate(node => node.style.getPropertyValue('--cooldown')), '80%');
    await page.locator('.slot').nth(1).click();
    assert(await page.evaluate(() => sent.some(url => url.includes('action=use') && url.includes('value=2'))));
    await page.locator('.slot').nth(0).dragTo(page.locator('.slot').nth(2));
    assert(await page.evaluate(() => sent.some(url => url.includes('action=swap') && url.includes('from=1'))), 'Slot drag did not preserve slot identity');
    await mount(page, 'bar', 541, 94);
    const wrappedSlots = [...slots, { ...slots[0], slot: 13, name: 'Last skill', state: 'ready' }];
    await update(page, { slots: wrappedSlots, columns: 12, size: 40 });
    // Resize the native control without another payload: the grid must reflow now.
    for (const [width, height, columns] of [[541, 94, 12], [240, 137, 5], [68, 567, 1], [541, 94, 12]]) {
      await page.setViewportSize({ width, height });
      await page.waitForFunction(expected => getComputedStyle(document.querySelector('.slots')).gridTemplateColumns.split(' ').length === expected, columns);
      assert(await page.locator('.slots').evaluate(node => node.scrollWidth <= node.clientWidth && node.scrollHeight <= node.clientHeight), `Hotbar clips at ${width}x${height}`);
      const last = await page.locator('.slot').last().boundingBox();
      assert(last.y + last.height <= height, `Last slot is hidden at ${width}x${height}`);
    }
    await page.locator('.slot').last().click();
    assert(await page.evaluate(() => sent.some(url => url.includes('action=use') && url.includes('value=13'))), 'Reflow changed slot identity');
    await page.setViewportSize({ width: 240, height: 94 });
    await page.locator('.slot').last().scrollIntoViewIfNeeded();
    assert(await page.locator('.slots').evaluate(node => node.scrollWidth <= node.clientWidth), 'Scrollbar forced horizontal slot clipping');
    await page.setViewportSize({ width: 80, height: 160 });
    await page.locator('.slot').last().scrollIntoViewIfNeeded();
    assert(await page.locator('.slots').evaluate(node => node.scrollWidth <= node.clientWidth), 'Minimum vertical bar clipped a slot beside its scrollbar');
    await page.locator('.slot').last().click();
    await mount(page, 'bar', 541, 94, 1);
    await update(page, { slots: wrappedSlots, columns: 12, size: 40 });
    for (const scale of [0.75, 0.5, 1]) {
      const width = Math.ceil(541 * scale), height = Math.ceil(94 * scale);
      await page.setViewportSize({ width, height });
      // Native resize arrives before the next data payload. Keep all twelve
      // logical columns and shrink their pixels instead of wrapping the grid.
      await page.waitForFunction(expected => Math.abs(document.querySelector('.slot').getBoundingClientRect().width - expected) < 1, 40 * scale);
      await update(page, { slots: wrappedSlots, columns: 12, size: 40, geometry: { x: 0, y: 0, w: width, h: height, scale, content_w: 541, content_h: 94 } });
      assert.equal(await page.locator('.slots').evaluate(node => getComputedStyle(node).gridTemplateColumns.split(' ').length), 12, 'Window scaling changed hotbar columns');
      const last = await page.locator('.slot').last().boundingBox();
      assert(last.x + last.width <= width && last.y + last.height <= height, 'Scaled hotbar clipped its final slot');
      await page.locator('.slot').last().click();
      assert(await page.evaluate(() => sent.some(url => url.includes('action=use') && url.includes('value=13'))), 'Scaled shortcut lost its click target');
    }
    await mount(page, 'chat', 550, 318, 0.5);
    await update(page, { channel: 'all', messages, fontSize: 13 });
    const chatTypography = await page.locator('.chat-entry span').first().evaluate(node => ({ font: getComputedStyle(node).fontFamily, transform: getComputedStyle(node).textTransform, size: getComputedStyle(node).fontSize, text: node.textContent }));
    assert(chatTypography.font.startsWith('Arial') && chatTypography.transform === 'none' && chatTypography.size === '13px' && chatTypography.text.includes('short readable text'), 'Chat no longer preserves mixed case in a readable font');
    assert.equal(await page.locator('.shell').evaluate(node => node.clientWidth), 542, 'Scaled chat changed its logical content width');
    const head = await page.locator('.head').boundingBox();
    await page.mouse.move(head.x + 15, head.y + 5); await page.mouse.down();
    await page.mouse.move(head.x + 45, head.y + 25); await page.mouse.up();
    const scaledDrag = await page.evaluate(() => classicGeometryForTest());
    assert.equal(scaledDrag.x, 30); assert.equal(scaledDrag.y, 20);
    assert.equal(scaledDrag.content_w, 550, 'Scaled drag resized the content');
    for (const control of await page.locator('.footer button, .channels button').all()) {
      const box = await control.boundingBox();
      assert(box.x + box.width <= 275 && box.y + box.height <= 159, 'Scaled chat clipped a button');
    }
    await page.locator('.footer').getByRole('button', { name: 'OOC', exact: true }).click();
    assert(await page.evaluate(() => sent.some(url => url.includes('action=chat') && url.includes('value=ooc'))), 'Scaled chat button lost its action');
    const scaledGrip = await page.locator('.grip.se').boundingBox();
    const gripX = scaledGrip.x + scaledGrip.width / 2, gripY = scaledGrip.y + scaledGrip.height / 2;
    await page.mouse.move(gripX, gripY); await page.mouse.down();
    await page.mouse.move(gripX + 20, gripY + 10); await page.mouse.up();
    const scaledResize = await page.evaluate(() => classicGeometryForTest());
    assert.equal(scaledResize.w, 295); assert.equal(scaledResize.h, 169);
    assert.equal(scaledResize.content_w, 590); assert.equal(scaledResize.content_h, 338);
    await page.setViewportSize({ width: 275, height: 13 });
    await update(page, { channel: 'all', messages, geometry: { x: 0, y: 0, w: 275, h: 13, scale: 0.5, content_w: 550, content_h: 26, collapsed: true } });
    await page.waitForFunction(() => document.body.classList.contains('collapsed'));
    assert(await page.locator('.footer').isHidden(), 'Scaled collapsed chat kept its footer');
    await page.locator('.head').getByRole('button', { name: '×', exact: true }).click();
    assert(await page.evaluate(() => sent.some(url => url.includes('action=close'))), 'Scaled collapsed header cannot be closed');
    // Exercise the production scaling script used when an embedded list is
    // replaced by item/skill details, including resizing with no data refresh.
    const detailSource = fs.readFileSync(path.join(root, 'src/Code/UI/ActionHud.dm'), 'utf8');
    const detailScript = detailSource.match(/function nexusFitEmbeddedDetail\(\)[\s\S]*?window\.classicUpdate=nexusFitEmbeddedDetail;/)[0].replace(/\[state\["w"\]\]/g, '460');
    await page.goto('about:blank');
    await page.setViewportSize({ width: 230, height: 340 });
    await page.setContent(`<html><head><script>${detailScript}</script></head><body style="margin:0"><button style="width:80px;height:30px">BACK</button><div style="height:900px">Details</div></body></html>`);
    assert.equal((await page.getByRole('button').boundingBox()).width, 40, 'Embedded details did not scale');
    await page.setViewportSize({ width: 460, height: 680 });
    await page.waitForFunction(() => document.querySelector('button').getBoundingClientRect().width === 80);
    assert(await page.evaluate(() => document.documentElement.scrollWidth <= document.documentElement.clientWidth), 'Embedded details overflow horizontally');
    await mount(page, 'menu', 380, 430);
    assert.equal(await page.getByRole('button', { name: 'All native tabs', exact: true }).count(), 0, 'Menu still exposes retired native tabs');
    await update(page, { sections: { actions: 'Actions / Other', playtest: 'Playtest', factions: 'Factions', sagas: 'Sagas' }, section: 'actions', commands: [{ label: 'Playtest rewards', value: 'Playtest', token: 'test' }, { label: 'Other command', value: 'Other', token: 'other' }] });
    assert.equal(await page.locator('.grip').count(), 0, 'Fixed menu still exposes resize grips');
    await page.locator('input').fill('Playtest');
    assert.equal(await page.locator('.row:visible').count(), 1, 'Command search lost category matching');
    assert.equal(await page.locator('.row:visible').getAttribute('draggable'), 'true', 'Commands cannot be dragged to hotbar');
    // BYOND skin dimensions and the embedded browser's CSS viewport need not
    // match (display/browser scaling or a resize still in flight). A routine
    // payload must never enlarge the contents beyond the actual control.
    const menuData = { sections: { actions: 'Actions / Other', factions: 'Factions' }, section: 'actions', commands: Array.from({ length: 40 }, (_, i) => ({ label: 'Command ' + i, token: 'command-' + i, group: 'Other' })) };
    for (const nativeScale of [0.75, 1, 1.35]) {
      await mount(page, 'menu', 460, 680, nativeScale);
      const nativeGeometry = await page.evaluate(() => ({ ...classicConfig.geometry }));
      for (const browserScale of [1, 1.25, 1.5, 2]) {
        const width = Math.floor(nativeGeometry.w / browserScale), height = Math.floor(nativeGeometry.h / browserScale);
        await page.setViewportSize({ width, height });
        // Repeat a server update after local fitting: this used to restore
        // the larger native scale and crop both edges of the menu again.
        await update(page, { ...menuData, geometry: nativeGeometry });
        await update(page, { ...menuData, geometry: nativeGeometry });
        for (const control of await page.locator('.head button, .footer button, select').all()) {
          const box = await control.boundingBox();
          assert(box.x >= 0 && box.y >= 0 && box.x + box.width <= width + 0.1 && box.y + box.height <= height + 0.1, `Menu control clipped after refresh at native ${nativeScale}, browser ${browserScale}`);
        }
        await page.evaluate(() => { sent.length = 0; });
        await page.locator('.row').last().scrollIntoViewIfNeeded();
        await page.locator('.row').last().click();
        await page.getByRole('button', { name: 'Reset HUD', exact: true }).click();
        await page.locator('.head').getByRole('button', { name: '×', exact: true }).click();
        assert(await page.evaluate(() => sent.some(u => u.includes('action=command') && u.includes('value=command-39')) && sent.some(u => u.includes('action=reset')) && sent.some(u => u.includes('action=close'))), 'Fitted menu lost command/footer/header click targets');
        assert.equal(await page.evaluate(() => classicGeometryForTest().scale), nativeScale, 'Local browser fitting changed persisted native geometry');
        if (nativeScale === 1 && browserScale === 1.25) await page.screenshot({ path: path.join(output, 'MenuViewportFit.png') });
      }
    }
    await mount(page, 'inventory', 460, 680);
    await update(page, { rows: [{ label: 'ITEMS CARRIED', value: '2', token: '' }, { label: 'Viltrumite Soldier Robe', value: 'Equipped', token: 'item-ref' }] });
    assert.equal(await page.locator('.panel-actions').count(), 1, 'Inventory item actions are missing');
    for (const action of ['USE', 'BAR', 'EXAMINE']) {
      await page.evaluate(() => { sent.length = 0; });
      await page.locator('.panel-actions').getByRole('button', { name: action, exact: true }).click();
      assert(await page.evaluate(expected => sent.some(url => url.includes('action=' + expected)), action === 'USE' ? 'panel_use' : action === 'BAR' ? 'panel_bar' : 'panel_examine'), `Inventory ${action} action was not routed`);
    }
    assert.equal(await page.locator('.grip').count(), 0, 'Fixed menu still exposes resize grips');
    await mount(page, 'bar', 526, 82);
    await update(page, { slots, columns: 12, size: 40, locked: false });
    const commandDrag = await page.evaluateHandle(() => { const d = new DataTransfer(); d.setData('text/plain', 'classic-command:owned-verb'); return d; });
    await page.locator('.slot').nth(2).dispatchEvent('drop', { dataTransfer: commandDrag });
    assert(await page.evaluate(() => sent.some(url => url.includes('action=assign') && url.includes('classic-command'))), 'Verb drop not routed to server');
    await page.evaluate(() => { sent.length = 0; });
    await update(page, { slots, columns: 12, size: 40, locked: true });
    await page.locator('.slot').nth(2).dispatchEvent('drop', { dataTransfer: commandDrag });
    assert.equal(await page.evaluate(() => sent.length), 0, 'Locked bar accepted a drop');
    await commandDrag.dispose();
    const barIcons = ['Beam','Melee','Defensive','Support','Buff','Item'].map(kind=>'data:image/jpeg;base64,'+fs.readFileSync(path.join(root,`src/Icons/UI/HotbarIcons/${kind}.jpg`)).toString('base64'));
    const mmoSlots = Array.from({length:36},(_,i)=>({slot:i+1,name:['Beam','Pressure Punch','Guard','Support','Power Up','Item'][i%6],key:(i>=24?'CTRL+':i>=12?'SHIFT+':'')+['1','2','3','4','5','6','R','T','F','G','Q','E'][i%12],icon:i%12<6?barIcons[i%6]:null,state:i%12>=6?'empty':i%4===0?'cooldown':'ready',remaining:i%12<6&&i%4===0?8+i:0,duration:60,label:'Ready'}));
    const largeSlots=[...mmoSlots,...mmoSlots.slice(0,13).map((s,i)=>({...s,slot:37+i}))];
    await mount(page,'bar_15',541,185);
    await update(page,{slots:largeSlots,columns:15,size:40,locked:false,name:'Combat'});
    assert.equal(await page.locator('.slot').count(),49,'Slots beyond 36 are missing');
    await page.locator('.slot').nth(36).click();
    assert(await page.evaluate(()=>sent.some(u=>u.includes('action=use')&&u.includes('value=37')&&u.includes('widget=bar_15'))),'Dynamic bar or slot identity was lost');
    await mount(page,'bar',541,137);
    await update(page,{slots:mmoSlots,columns:12,size:40,locked:false,name:'Combat'});
    assert(await page.locator('.slots').evaluate(n=>n.scrollHeight<=n.clientHeight && n.scrollWidth<=n.clientWidth),'Compact rows do not fit');
    await page.screenshot({path:path.join(output,'HotbarLayout.png')});
    const editorCss = fs.readFileSync(path.join(root, 'src/Code/UI/Browser/HotbarEditor.css'), 'utf8');
    const editorJs = fs.readFileSync(path.join(root, 'src/Code/UI/Browser/HotbarEditor.js'), 'utf8');
    const editorConfig = {ref:'fixture', selected:2, bar:'bar_15',bars:[{id:'bar_15',name:'Combat',count:49},{id:'bar_16',name:'Support',count:5},{id:'bar_17',name:'Items',count:7},{id:'bar_18',name:'Other',count:1}], page:1,pages:5,count:49,name:'Combat',slots:mmoSlots.slice(0,12), actions:[{token:'classic-command:meditate',name:'Meditate',group:'Other'},{token:'classic-skill:punch',name:'Pressure Punch',group:'Melee'}], bindings:[{key:'CTRL+SHIFT+Q',name:'Manual Attack',slot:0,fingerprint:'expected-owner'}], keys:['Q','R','1','2','Space','F1','F2','F4'],columns:12,size:40,locked:false};
    editorConfig.bindings.push({key:'J',name:'Meditate',slot:2,fingerprint:'slot-two'});
    await page.setViewportSize({width:860,height:620});
    await page.setContent(`<!doctype html><html><head><style>${css}${editorCss}</style></head><body><script>window.hotbarConfig=${JSON.stringify(editorConfig)};window.sent=[];window.hotbarTestTransport=u=>sent.push(u);</script><script>${editorJs}</script></body></html>`);
    await page.getByRole('button', {name:'Capture key',exact:true}).click();
    await page.keyboard.press('Control+Shift+Q');
    assert(await page.locator('.conflict').isVisible(), 'Existing binding was silently overwritten');
    assert.equal(await page.evaluate(() => sent.length), 0);
    await page.getByRole('button', {name:'Replace binding',exact:true}).click();
    assert(await page.evaluate(() => sent.some(url=>url.includes('slot=2')&&url.includes('ctrl=1')&&url.includes('shift=1')&&url.includes('replace=expected-owner'))), 'Modified key or conflict acknowledgement lost');
    await page.getByRole('searchbox').fill('Meditate');
    assert.equal(await page.locator('.action-card:visible').count(),1);
    await page.locator('.action-card:visible').dragTo(page.locator('.editor-slot').nth(3));
    assert(await page.evaluate(() => sent.some(url=>url.includes('action=assign')&&url.includes('slot=4')&&url.includes('classic-command'))));
    await page.getByRole('searchbox').fill('');
    await page.getByRole('button',{name:'+ Bar',exact:true}).click();
    assert(await page.evaluate(()=>sent.some(u=>u.includes('action=add_bar'))),'Cannot add another bar');
    await page.getByRole('button',{name:'+ 12 slots',exact:true}).click();
    assert(await page.evaluate(()=>sent.some(u=>u.includes('action=add_slot')&&u.includes('count=12'))),'Cannot grow a bar');
    await page.getByRole('button',{name:'Next',exact:true}).click();
    assert(await page.evaluate(()=>sent.some(u=>u.includes('action=page')&&u.includes('page=2'))),'Cannot reach slots on later pages');
    await page.getByRole('combobox',{name:'Bar',exact:true}).selectOption('bar_18');
    assert(await page.evaluate(()=>sent.some(u=>u.includes('action=select_bar')&&u.includes('bar=bar_18'))),'Cannot select bars beyond the old three-bar cap');
    await page.getByRole('combobox',{name:'Bar',exact:true}).selectOption('bar_15');
    await page.locator('.editor-slot:visible').nth(1).click();
    await page.screenshot({path:path.join(output,'HotbarEditor.png')});
    for(const width of [600,380]) { await page.setViewportSize({width,height:620}); assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'Editor overflow at '+width); }
    await page.getByRole('button',{name:'Capture key',exact:true}).click();
    await page.keyboard.press('Escape');
    assert.equal(await page.getByRole('button',{name:'Capture key',exact:true}).count(),1,'Escape did not cancel key capture');
    await page.setViewportSize({width:860,height:620});
    await page.getByRole('button',{name:'Hotkeys only',exact:true}).click();
    assert(await page.locator('.editor-slots').isHidden(),'Independent hotkeys still require selecting a bar slot');
    assert(await page.getByRole('button',{name:'Capture key',exact:true}).isDisabled(),'Direct capture is enabled without choosing an action');
    await page.getByRole('searchbox').fill('Meditate');
    await page.locator('.action-card:visible').click();
    await page.evaluate(()=>{window.sent=[];});
    await page.getByRole('button',{name:'Capture key',exact:true}).click();
    await page.keyboard.press('Control+Shift+Q');
    assert(await page.locator('.conflict').isVisible(),'Direct binding skipped a conflicting key');
    assert.equal(await page.evaluate(()=>sent.length),0);
    await page.getByRole('button',{name:'Replace binding',exact:true}).click();
    assert(await page.evaluate(()=>sent.some(u=>{const q=new URL(u).searchParams;return q.get('action')==='bind'&&q.get('mode')==='direct'&&q.get('token')==='classic-command:meditate'&&q.get('replace')==='expected-owner';})),'Direct binding lost its action or conflict acknowledgement');
    await page.getByRole('combobox',{name:'Key',exact:true}).selectOption('R');
    await page.getByLabel('Double tap',{exact:true}).check();
    await page.getByRole('button',{name:'Bind',exact:true}).click();
    assert(await page.evaluate(()=>sent.some(u=>{const q=new URL(u).searchParams;return q.get('mode')==='direct'&&q.get('key')==='R'&&q.get('double')==='1';})),'Manual independent double-tap binding failed');
    assert(!await page.evaluate(()=>sent.some(u=>new URL(u).searchParams.get('action')==='assign')),'Direct binding assigned an action to a bar');
    await page.locator('.other-bindings').getByRole('button',{name:'Unbind',exact:true}).click();
    assert(await page.evaluate(()=>sent.some(u=>new URL(u).searchParams.get('action')==='unbind')),'Independent shortcut cannot be removed');
    await page.screenshot({path:path.join(output,'IndependentHotkeys.png')});
    for(const width of [600,380]) { await page.setViewportSize({width,height:620}); assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),'Independent editor overflow at '+width); }
    await page.getByRole('button',{name:'Bar slots',exact:true}).click();
    await page.getByRole('button',{name:'Move to hotkeys only',exact:true}).click();
    assert(await page.evaluate(()=>sent.some(u=>{const q=new URL(u).searchParams;return q.get('action')==='detach_slot'&&q.get('slot')==='2';})),'Cannot remove a bar action while keeping its keys');
    const noBarConfig={...editorConfig,mode:'direct',pendingAction:'classic-command:meditate',bar:'',bars:[],slots:[],bindings:[]};
    await page.goto('about:blank');
    await page.setContent(`<!doctype html><html><head><style>${css}${editorCss}</style></head><body><script>window.hotbarConfig=${JSON.stringify(noBarConfig)};window.sent=[];window.hotbarTestTransport=u=>sent.push(u);</script><script>${editorJs}</script></body></html>`);
    await page.getByRole('button',{name:'Capture key',exact:true}).click();
    await page.keyboard.press('R');
    assert(await page.evaluate(()=>sent.some(u=>{const q=new URL(u).searchParams;return q.get('action')==='bind'&&q.get('mode')==='direct'&&q.get('token')==='classic-command:meditate';})),'Independent hotkeys require an existing bar');
    assert.equal(errors.length, 0, errors.join('\n'));
    console.log('PASS: chat reflow/history, resize, browser viewport fitting/clicks, cooldowns, reorder, verb drops, lock, editor search/drag, independent hotkeys, modifier capture/conflicts, responsive layouts and JS errors.');
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
