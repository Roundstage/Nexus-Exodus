(function () {
  'use strict';
  var config = window.classicConfig, id = config.kind || config.id, widgetId = config.id, data = {}, geometry = config.geometry, viewport = config.viewport;
  var dragging = null, pendingGeometry = false, lastRows = '', lastMessageId = 0, lastChannel = '', following = true;
  var contextToken = null, contextPoint = null;
  function el(tag, cls, text) { var node = document.createElement(tag); if (cls) node.className = cls; if (text != null) node.textContent = text; return node; }
  function navigate(url) { if (window.classicTestTransport) window.classicTestTransport(url); else window.location.href = url; }
  function topic(action, values) {
    var url = 'byond://?src=' + encodeURIComponent(config.ref) + '&widget=' + widgetId + '&generation=' + config.generation + '&action=' + action;
    Object.keys(values || {}).forEach(function (key) { url += '&' + key + '=' + encodeURIComponent(values[key]); }); navigate(url);
  }
  function focusMap() { navigate('byond://winset?id=&mapwindow.macro=macro&mapwindow.map.focus=true'); }
  function button(text, action, value) { var node = el('button', '', text); node.type = 'button'; node.onclick = function () { topic(action, value == null ? {} : { value: value }); }; return node; }
  document.documentElement.className = id;
  document.body.className = id;
  var shell = el('main', 'shell'), head = el('header', 'head'), title = el('b', 'title', id === 'bar' ? 'SKILLS' : id.toUpperCase());
  head.appendChild(title); head.appendChild(button('–', 'collapse')); head.appendChild(button('×', 'close')); shell.appendChild(head);
  var toolbar = el('nav', 'toolbar'), body = el('section', 'body'), footer = el('nav', 'footer');
  shell.appendChild(toolbar); shell.appendChild(body); shell.appendChild(footer); document.body.appendChild(shell);
  function applyContentScale() {
    if (!geometry.scale) return;
    var width = geometry.content_w, height = geometry.content_h;
    // Native skin pixels can differ from browser CSS pixels. Always fit the
    // actual viewport, including after payloads and while native resize catches
    // up, or the close buttons, footer and scrollbar can be clipped again.
    var scale = Math.min(window.innerWidth / width, window.innerHeight / height);
    if (!(scale > 0) || !isFinite(scale)) return;
    shell.style.width = width + 'px'; shell.style.height = height + 'px';
    shell.style.transformOrigin = '0 0'; shell.style.transform = 'scale(' + scale + ')';
  }
  var query, section, latest, channels;
  if (id === 'menu' || id === 'sense' || id === 'stats') {
    query = el('input'); query.type = 'search'; query.placeholder = id === 'sense' ? 'Find a signature…' : 'Find a command or information…'; query.setAttribute('aria-label', query.placeholder);
    query.oninput = filterRows; toolbar.appendChild(query);
    // Native macros must not consume letters while searching inside a browser control.
    query.onfocus = function () { topic('typing', { value: 1 }); setTimeout(function () { navigate('byond://winset?id=mapwindow&macro=classictyping'); }, 0); };
    query.onblur = function () { topic('typing', { value: 0 }); setTimeout(function () { navigate('byond://winset?id=mapwindow&macro=macro'); }, 0); };
    query.onkeydown = function (event) { if (event.key === 'Escape') { query.blur(); focusMap(); } event.stopPropagation(); };
  }
  if (id === 'menu') {
    section = el('select'); section.setAttribute('aria-label', 'Category'); section.onchange = function () { closeContext(); topic('section', { value: section.value }); lastRows = ''; };
    var categoryToolbar = el('nav', 'toolbar'); categoryToolbar.appendChild(section); shell.insertBefore(categoryToolbar, toolbar);
    footer.appendChild(button('Appearance / Clothes', 'settings')); footer.appendChild(button('Ki Settings', 'ki_settings'));
    footer.appendChild(button('Inventory', 'inventory')); footer.appendChild(button('Skills', 'skills'));
    footer.appendChild(button('Reset HUD', 'reset'));
    ['stats', 'sense', 'target', 'bar', 'chat'].forEach(function (widget) { footer.appendChild(button(widget.toUpperCase(), 'widget', widget)); });
  }
  if (id === 'target') { toolbar.remove(); footer.remove(); }
  if (id === 'sense' || id === 'stats') footer.remove();
  if (id === 'chat') {
    body.className += ' messages'; channels = el('div', 'channels'); toolbar.appendChild(channels);
    ['all', 'combat', 'ic', 'ooc'].forEach(function (channel) { channels.appendChild(button(channel.toUpperCase(), 'channel', channel)); });
    var clearChat = button('CLEAR', 'clear_chat'); clearChat.title = 'Clear live chat in all channels. Saved logs are kept.'; toolbar.appendChild(clearChat);
    ['say', 'ooc', 'emote'].forEach(function (action) { footer.appendChild(button(action.toUpperCase(), 'chat', action)); });
    footer.appendChild(button('LOGS', 'chat', 'logs')); footer.appendChild(button('CMD', 'chat', 'cmd'));
    latest = el('button', 'latest', 'New messages ↓'); latest.hidden = true; shell.appendChild(latest);
    latest.onclick = function () { following = true; body.scrollTop = body.scrollHeight; latest.hidden = true; };
    body.onscroll = function () { following = body.scrollHeight - body.clientHeight - body.scrollTop < 12; if (following) latest.hidden = true; };
  }
  if (id === 'bar') {
    toolbar.remove(); footer.remove();
    head.textContent = '';
    var handle = el('span', 'bar-handle', '⋮'); handle.title = 'Drag to move the bar'; head.appendChild(handle);
    var keysButton = button('K', 'hotkeys'); keysButton.title = 'Hotbar / Hotkeys'; head.appendChild(keysButton);
    var lockButton = button('L', 'lock'); head.appendChild(lockButton);
    head.setAttribute('aria-label', 'Hotbar controls');
    body.className += ' slots';
  }
  function filterRows() {
    var needle = query ? query.value.trim().toLowerCase() : '';
    Array.prototype.forEach.call(body.querySelectorAll('.row'), function (row) { row.hidden = !!needle && row.textContent.toLowerCase().indexOf(needle) === -1; });
    var group;
    Array.prototype.forEach.call(body.children, function (node) {
      if (node.classList.contains('group')) { group = node; group.hidden = true; }
      else if (node.classList.contains('row') && !node.hidden && group) group.hidden = false;
    });
  }
  function renderRows(rows, commands) {
    var signature = JSON.stringify([rows, commands]); if (signature === lastRows) return; lastRows = signature;
    var scroll = body.scrollTop; body.textContent = ''; var previousGroup;
    function add(row, command) {
      if (row.group && row.group !== previousGroup && id !== 'target') { body.appendChild(el('div', 'group', row.group)); previousGroup = row.group; }
      var panelActions = (id === 'inventory' || id === 'skills') && row.token;
      var worldRow = id === 'menu' && data.section === 'world' && row.token;
      var item = el(row.token && !panelActions && !worldRow ? 'button' : 'div', 'row' + (row.token ? ' action' : '') + (panelActions || worldRow ? ' panel-row' : '') + (worldRow ? ' world-row' : ''));
      if (panelActions || worldRow) {
        var copy = el('span', 'panel-copy'); copy.appendChild(el('span', 'label', row.label));
        if (row.value) copy.appendChild(el('span', 'item-status', row.value));
        item.appendChild(copy);
      } else { item.appendChild(el('span', 'label', row.label)); item.appendChild(el('span', 'value', row.value)); }
      if (row.token && !panelActions && !worldRow) { item.type = 'button'; item.onclick = function () { topic(command ? 'command' : 'row', { value: row.token }); }; }
      if (row.token && !command) {
        item.oncontextmenu = function (event) {
          event.preventDefault(); event.stopPropagation(); closeContext();
          contextToken = row.token;
          var bounds = shell.getBoundingClientRect(), scale = bounds.width / shell.offsetWidth || 1;
          contextPoint = { x: (event.clientX - bounds.left) / scale, y: (event.clientY - bounds.top) / scale };
          topic('context', { value: row.token });
        };
      }
      if (panelActions) { var actions = el('span', 'panel-actions'); actions.appendChild(button('USE', 'panel_use', row.token)); actions.appendChild(button('BAR', 'panel_bar', row.token)); actions.appendChild(button('EXAMINE', 'panel_examine', row.token)); item.appendChild(actions); }
      if (worldRow && row.actions && row.actions.length) {
        var worldActions = el('span', 'panel-actions');
        row.actions.forEach(function (option) {
          var actionButton = el('button', '', option.label); actionButton.type = 'button';
          actionButton.onclick = function () { topic('context_action', { value: row.token, option: option.id }); };
          worldActions.appendChild(actionButton);
        });
        item.appendChild(worldActions);
      }
      if (command && row.token) { item.draggable = true; item.title = 'Drag this verb to the hotbar'; item.ondragstart = function(event) { event.dataTransfer.setData('text/plain', 'classic-command:' + row.token); }; }
      body.appendChild(item);
    }
    (rows || []).forEach(function (row) { add(row, false); }); (commands || []).forEach(function (row) { add(row, true); });
    if (!body.children.length) body.appendChild(el('div', 'empty', data.empty || 'No entries available in this context.'));
    filterRows(); body.scrollTop = scroll;
  }
  function renderChat() {
    var messages = data.messages || [], changedChannel = lastChannel !== data.channel;
    var reset = !!data.reset;
    // A fresh document/channel must receive a snapshot before applying deltas.
    if (changedChannel && !reset) { data.messages = null; topic('chat_sync'); return; }
    var needsTrim = body.firstChild && body.firstChild._chatId < data.firstId;
    if (!reset && !needsTrim && !messages.length) return;
    var oldTop = body.scrollTop, oldHeight = body.scrollHeight, wasFollowing = following || changedChannel;
    if (reset) { body.textContent = ''; lastMessageId = 0; }
    else while (body.firstChild && body.firstChild._chatId < data.firstId) body.removeChild(body.firstChild);
    var removedHeight = reset ? 0 : oldHeight - body.scrollHeight;
    var fragment = document.createDocumentFragment(), added = 0;
    for (var i = 0; i < messages.length; i++) {
      var message = messages[i];
      if (message.id <= lastMessageId || message.id < data.firstId) continue;
      var item = el('div', 'chat-entry'); item._chatId = message.id; item.innerHTML = message.html;
      fragment.appendChild(item); lastMessageId = message.id; added++;
    }
    body.appendChild(fragment);
    // Defense in depth; normal pruning is driven by the server's firstId.
    while (body.children.length > 300) body.removeChild(body.firstChild);
    if (wasFollowing) { body.scrollTop = body.scrollHeight; latest.hidden = true; }
    else { body.scrollTop = Math.max(0, oldTop - Math.max(0, removedHeight)); if (added) latest.hidden = false; }
    if (!body.children.length) { latest.hidden = true; wasFollowing = true; }
    following = wasFollowing; lastChannel = data.channel;
    // The DOM owns displayed text; do not also retain the received HTML payload.
    data.messages = null;
    Array.prototype.forEach.call(channels.children, function (node) { node.classList.toggle('active', node.textContent.toLowerCase() === data.channel); });
  }
  function openSlotMenu(slot, event) {
    event.preventDefault(); var old = document.querySelector('.context'); if (old) old.remove();
    var menu = el('div', 'context');
    menu.appendChild(button('Hotkeys', 'hotkeys', slot)); if (!data.locked) { menu.appendChild(button('Assign', 'assign', slot)); menu.appendChild(button('Clear', 'clear', slot)); }
    var close = el('button', '', '×'); close.onclick = function () { menu.remove(); }; menu.appendChild(close); shell.appendChild(menu);
  }
  function closeContext() {
    var old = document.querySelector('.context'); if (old) old.remove();
    contextToken = null; contextPoint = null;
  }
  window.classicContext = function (payload) {
    var response; try { response = typeof payload === 'string' ? JSON.parse(payload) : payload; } catch (_) { return; }
    if (!contextToken || response.token !== contextToken) return;
    var old = document.querySelector('.context'); if (old) old.remove();
    var menu = el('div', 'context row-context'); menu.setAttribute('role', 'menu');
    menu.appendChild(el('b', 'context-title', response.label));
    (response.options || []).forEach(function (option) {
      var node = el('button', '', option.label); node.type = 'button'; node.setAttribute('role', 'menuitem');
      node.onclick = function (event) { event.stopPropagation(); topic('context_action', { value: response.token, option: option.id }); closeContext(); };
      menu.appendChild(node);
    });
    if (!(response.options || []).length) menu.appendChild(el('span', '', 'No actions available.'));
    shell.appendChild(menu);
    menu.style.left = Math.max(0, Math.min(contextPoint.x, shell.clientWidth - menu.offsetWidth)) + 'px';
    menu.style.top = Math.max(0, Math.min(contextPoint.y, shell.clientHeight - menu.offsetHeight)) + 'px';
    var first = menu.querySelector('button'); if (first) first.focus();
  };
  document.addEventListener('mousedown', function (event) { if (!event.target.closest('.context')) closeContext(); });
  document.addEventListener('keydown', function (event) { if (event.key === 'Escape') closeContext(); });
  function renderSlots(slots) {
    var columns = Math.max(1, Math.min(data.columns || 12, Math.floor((body.clientWidth - 3) / ((data.size || 40) + 3)) || 1));
    body.style.gridTemplateColumns = 'repeat(' + columns + ',' + (data.size || 40) + 'px)';
    body.style.setProperty('--slot-size', (data.size || 40) + 'px');
    lockButton.textContent = data.locked ? 'L' : 'U'; lockButton.title = data.locked ? 'Unlock bar' : 'Lock bar'; lockButton.classList.toggle('active', !!data.locked);
    document.body.classList.toggle('bar-locked', !!data.locked);
    head.title = data.name || 'Hotbar';
    while (body.children.length > slots.length) body.lastChild.remove();
    slots.forEach(function (slot, index) {
      var node = body.children[index];
      if (!node) {
        node = el('button', 'slot'); node.type = 'button'; node.draggable = true;
        node.appendChild(el('img')); node.appendChild(el('span', 'shade')); node.appendChild(el('span', 'key')); node.appendChild(el('span', 'count')); node.appendChild(el('span', 'fallback'));
        node.onclick = function () { var s = this._slot; topic(s.state === 'empty' ? 'assign' : 'use', { value: s.slot }); };
        node.oncontextmenu = function (event) { openSlotMenu(this._slot.slot, event); };
        node.ondragstart = function (event) { if(data.locked){event.preventDefault();return;} event.dataTransfer.setData('text/plain', 'classic-slot:' + this._slot.slot); event.dataTransfer.effectAllowed = 'move'; };
        node.ondragover = function (event) { event.preventDefault(); this.classList.add('drag-over'); };
        node.ondragleave = function () { this.classList.remove('drag-over'); };
        node.ondrop = function (event) {
          event.preventDefault(); this.classList.remove('drag-over'); if(data.locked)return; var token = event.dataTransfer.getData('text/plain');
          if (token.indexOf('classic-slot:') === 0) topic('swap', { value: this._slot.slot, from: token.slice(13) });
          else if (/^classic-(skill|action|command):/.test(token)) topic('assign', { value: this._slot.slot, token: token });
        };
        body.appendChild(node);
      }
      node.draggable = !data.locked; node._slot = slot; node.className = 'slot ' + slot.state;
      node.title = slot.name + (slot.key ? ' [' + slot.key + ']' : '') + ' — ' + slot.label + '\nRight click to assign or clear. Drag to reorder.';
      node.setAttribute('aria-label', node.title);
      var image = node.children[0]; if (slot.icon && image.getAttribute('src') !== slot.icon) image.src = slot.icon; image.hidden = !slot.icon;
      node.children[1].style.setProperty('--cooldown', slot.remaining > 0 ? Math.min(100, 100 * slot.remaining / Math.max(slot.duration || slot.remaining, slot.remaining)) + '%' : '0%');
      node.children[2].textContent = (slot.key || '').split(' / ')[0].replace('DOUBLE:', '2×').replace('CTRL+', 'C-').replace('SHIFT+', 'S-').replace('ALT+', 'A-');
      node.children[4].textContent = slot.fallback && !(slot.remaining > 0) ? slot.name.split(/\s+/).map(function (word) { return word.charAt(0); }).join('').slice(0, 3).toUpperCase() : '';
      node.children[3].textContent = slot.remaining > 0 ? (slot.remaining >= 60 ? Math.ceil(slot.remaining / 60) + 'm' : Math.ceil(slot.remaining)) : (slot.state === 'empty' ? '+' : (slot.state === 'resource' ? 'LOW' : (slot.state === 'unavailable' ? '×' : '')));
    });
  }
  window.classicUpdate = function (payload) {
    try { data = typeof payload === 'string' ? JSON.parse(payload) : payload; } catch (_) { return; }
    if (!dragging && !pendingGeometry && data.geometry) geometry = data.geometry;
    if (data.viewport) viewport = data.viewport;
    document.body.classList.toggle('collapsed', !!geometry.collapsed);
    applyContentScale();
    if (id === 'chat') { body.style.fontSize = (data.fontSize || 13) + 'px'; renderChat(); }
    else if (id === 'bar') renderSlots(data.slots || []);
    else {
      if (id === 'target') title.textContent = data.name ? 'TARGET / ' + data.name : 'TARGET';
      if (section && JSON.stringify(data.sections) !== section._signature) {
        section.textContent = ''; Object.keys(data.sections || {}).forEach(function (key) { var option = el('option', '', data.sections[key]); option.value = key; section.appendChild(option); }); section._signature = JSON.stringify(data.sections);
      }
      if (section) section.value = data.section;
      renderRows(data.rows, data.commands);
    }
  };
  function clampGeometry(g, edge) {
    var scale = g.scale || 1;
    var minW = (id === 'bar' ? (data.size || 40) + 40 : 240) * scale, minH = (id === 'bar' ? 52 : 120) * scale;
    g.w = Math.max(minW, Math.min(viewport.w, g.w)); g.h = g.collapsed ? Math.ceil(26 * scale) : Math.max(minH, Math.min(viewport.h, g.h));
    g.x = Math.max(0, Math.min(viewport.w - g.w, g.x)); g.y = Math.max(0, Math.min(viewport.h - (g.collapsed ? Math.ceil(26 * scale) : g.h), g.y));
    ['x', 'y', 'w', 'h'].forEach(function (key) { g[key] = Math.round(g[key]); }); return g;
  }
  function applyGeometry() {
    applyContentScale();
    navigate('byond://winset?id=mapwindow.classic_' + widgetId + '&pos=' + geometry.x + ',' + geometry.y + '&size=' + geometry.w + 'x' + (geometry.collapsed ? Math.ceil(26 * (geometry.scale || 1)) : geometry.h));
    if (window.classicTestGeometry) window.classicTestGeometry(geometry);
  }
  function startDrag(event, edge) {
    if (event.button !== 0 || event.target.closest('button') || (id === 'bar' && data.locked)) return;
    event.preventDefault(); dragging = { x: event.screenX, y: event.screenY, initial: Object.assign({}, geometry), edge: edge, capture: event.currentTarget };
    if (event.currentTarget.setPointerCapture && event.pointerId != null) event.currentTarget.setPointerCapture(event.pointerId);
    else if (document.body.setCapture) document.body.setCapture();
  }
  function moveDrag(event) {
    if (!dragging) return; var deltaX = event.screenX - dragging.x, deltaY = event.screenY - dragging.y, g = Object.assign({}, dragging.initial), edge = dragging.edge;
    if (edge === 'move') { g.x += deltaX; g.y += deltaY; }
    else { if (edge.indexOf('e') !== -1) g.w += deltaX; if (edge.indexOf('s') !== -1) g.h += deltaY; if (edge === 'w') { g.w -= deltaX; g.x += deltaX; } }
    geometry = clampGeometry(g, edge);
    if (geometry.scale && edge !== 'move') {
      geometry.content_w = geometry.w / geometry.scale;
      geometry.content_h = geometry.collapsed ? 26 : geometry.h / geometry.scale;
    }
    applyGeometry();
  }
  function endDrag() {
    if (!dragging) return; dragging = null; if (document.releaseCapture) document.releaseCapture();
    pendingGeometry = true; topic('geometry', geometry); setTimeout(function () {
      pendingGeometry = false;
      if (!dragging && data.geometry) {
        geometry = data.geometry;
        document.body.classList.toggle('collapsed', !!geometry.collapsed);
        applyContentScale();
      }
    }, 500);
  }
  var down = window.PointerEvent ? 'pointerdown' : 'mousedown', move = window.PointerEvent ? 'pointermove' : 'mousemove', up = window.PointerEvent ? 'pointerup' : 'mouseup';
  head.addEventListener(down, function (event) { startDrag(event, 'move'); });
  if (['menu', 'inventory', 'skills'].indexOf(id) === -1) ['e', 'w', 's', 'se'].forEach(function (edge) { var grip = el('div', 'grip ' + edge); grip.setAttribute('aria-label', 'Resize'); grip.addEventListener(down, function (event) { startDrag(event, edge); }); shell.appendChild(grip); });
  document.addEventListener(move, moveDrag); document.addEventListener(up, endDrag); window.addEventListener('blur', endDrag);
  document.addEventListener('keydown', function (event) { if (event.key === 'Escape' && document.activeElement !== query) focusMap(); });
  // Native BROWSER resize does not wait for the next gameplay payload.
  window.addEventListener('resize', function () {
    applyContentScale();
    if (id === 'bar') renderSlots(data.slots || []);
    if (id === 'chat' && following) body.scrollTop = body.scrollHeight;
  });
  // Apply local geometry immediately; server updates are only needed after the drag ends.
  window.classicGeometryForTest = function () { return geometry; };
  document.body.classList.toggle('collapsed', !!geometry.collapsed);
  applyContentScale();
  topic('ready');
}());
