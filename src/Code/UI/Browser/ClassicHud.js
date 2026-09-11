(function () {
  'use strict';
  var config = window.classicConfig, id = config.kind || config.id, widgetId = config.id, data = {}, geometry = config.geometry, viewport = config.viewport;
  var dragging = null, pendingGeometry = false, lastRows = '', lastMessages = [], lastChannel = '', following = true;
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
    section = el('select'); section.setAttribute('aria-label', 'Category'); section.onchange = function () { topic('section', { value: section.value }); lastRows = ''; };
    var categoryToolbar = el('nav', 'toolbar'); categoryToolbar.appendChild(section); shell.insertBefore(categoryToolbar, toolbar);
    footer.appendChild(button('Appearance / Clothes', 'settings')); footer.appendChild(button('Ki Settings', 'ki_settings'));
    footer.appendChild(button('Inventory', 'inventory')); footer.appendChild(button('Skills', 'skills'));
    footer.appendChild(button('All native tabs', 'legacy')); footer.appendChild(button('Reset HUD', 'reset'));
    ['stats', 'sense', 'target', 'bar', 'chat'].forEach(function (widget) { footer.appendChild(button(widget.toUpperCase(), 'widget', widget)); });
  }
  if (id === 'target') { toolbar.remove(); footer.remove(); }
  if (id === 'sense' || id === 'stats') footer.remove();
  if (id === 'chat') {
    body.className += ' messages'; channels = el('div', 'channels'); toolbar.appendChild(channels);
    ['all', 'combat', 'ic', 'ooc'].forEach(function (channel) { channels.appendChild(button(channel.toUpperCase(), 'channel', channel)); });
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
      var item = el(row.token && !panelActions ? 'button' : 'div', 'row' + (row.token ? ' action' : '') + (panelActions ? ' panel-row' : ''));
      item.appendChild(el('span', 'label', row.label)); item.appendChild(el('span', 'value', row.value));
      if (row.token && !panelActions) { item.type = 'button'; item.onclick = function () { topic(command ? 'command' : 'row', { value: row.token }); }; }
      if (panelActions) { var actions = el('span', 'panel-actions'); actions.appendChild(button('USE', 'panel_use', row.token)); actions.appendChild(button('BAR', 'panel_bar', row.token)); actions.appendChild(button('EXAMINE', 'panel_examine', row.token)); item.appendChild(actions); }
      if (command && row.token) { item.draggable = true; item.title = 'Drag this verb to the hotbar'; item.ondragstart = function(event) { event.dataTransfer.setData('text/plain', 'classic-command:' + row.token); }; }
      body.appendChild(item);
    }
    (rows || []).forEach(function (row) { add(row, false); }); (commands || []).forEach(function (row) { add(row, true); });
    if (!body.children.length) body.appendChild(el('div', 'empty', data.empty || 'No entries available in this context.'));
    filterRows(); body.scrollTop = scroll;
  }
  function renderChat() {
    var messages = data.messages || [], changedChannel = lastChannel !== data.channel;
    var same = !changedChannel && JSON.stringify(messages) === JSON.stringify(lastMessages); if (same) return;
    var oldTop = body.scrollTop, oldHeight = body.scrollHeight, wasFollowing = following || changedChannel;
    // Append overlapping history rather than replacing it: selection and scroll survive arrivals.
    var overlap = 0;
    if (!changedChannel) {
      for (var n = Math.min(lastMessages.length, messages.length); n > 0; n--) {
        if (lastMessages.slice(lastMessages.length - n).join('\u0000') === messages.slice(0, n).join('\u0000')) { overlap = n; break; }
      }
    }
    if (!overlap) body.textContent = '';
    else while (body.children.length > overlap) body.removeChild(body.firstChild);
    var removedHeight = overlap ? oldHeight - body.scrollHeight : 0;
    for (var i = overlap; i < messages.length; i++) { var item = el('div', 'chat-entry'); item.innerHTML = messages[i]; body.appendChild(item); }
    if (wasFollowing) { body.scrollTop = body.scrollHeight; latest.hidden = true; }
    else { body.scrollTop = Math.max(0, oldTop - Math.max(0, removedHeight)); latest.hidden = false; }
    following = wasFollowing; lastMessages = messages.slice(); lastChannel = data.channel;
    Array.prototype.forEach.call(channels.children, function (node) { node.classList.toggle('active', node.textContent.toLowerCase() === data.channel); });
  }
  function openSlotMenu(slot, event) {
    event.preventDefault(); var old = document.querySelector('.context'); if (old) old.remove();
    var menu = el('div', 'context');
    menu.appendChild(button('Hotkeys', 'hotkeys', slot)); if (!data.locked) { menu.appendChild(button('Assign', 'assign', slot)); menu.appendChild(button('Clear', 'clear', slot)); }
    var close = el('button', '', '×'); close.onclick = function () { menu.remove(); }; menu.appendChild(close); shell.appendChild(menu);
  }
  function renderSlots(slots) {
    var columns = Math.max(1, Math.min(data.columns || 12, Math.floor((document.body.clientWidth - 25) / ((data.size || 40) + 3)) || 1));
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
    var minW = id === 'bar' ? (data.size || 40) + 28 : 240, minH = id === 'bar' ? 52 : 120;
    g.w = Math.max(minW, Math.min(viewport.w, g.w)); g.h = Math.max(minH, Math.min(viewport.h, g.h));
    g.x = Math.max(0, Math.min(viewport.w - g.w, g.x)); g.y = Math.max(0, Math.min(viewport.h - (g.collapsed ? 26 : g.h), g.y));
    ['x', 'y', 'w', 'h'].forEach(function (key) { g[key] = Math.round(g[key]); }); return g;
  }
  function applyGeometry() {
    navigate('byond://winset?id=mapwindow.classic_' + widgetId + '&pos=' + geometry.x + ',' + geometry.y + '&size=' + geometry.w + 'x' + (geometry.collapsed ? 26 : geometry.h));
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
    geometry = clampGeometry(g, edge); applyGeometry();
  }
  function endDrag() {
    if (!dragging) return; dragging = null; if (document.releaseCapture) document.releaseCapture();
    pendingGeometry = true; topic('geometry', geometry); setTimeout(function () { pendingGeometry = false; }, 500);
  }
  var down = window.PointerEvent ? 'pointerdown' : 'mousedown', move = window.PointerEvent ? 'pointermove' : 'mousemove', up = window.PointerEvent ? 'pointerup' : 'mouseup';
  head.addEventListener(down, function (event) { startDrag(event, 'move'); });
  if (['menu', 'inventory', 'skills'].indexOf(id) === -1) ['e', 'w', 's', 'se'].forEach(function (edge) { var grip = el('div', 'grip ' + edge); grip.setAttribute('aria-label', 'Resize'); grip.addEventListener(down, function (event) { startDrag(event, edge); }); shell.appendChild(grip); });
  document.addEventListener(move, moveDrag); document.addEventListener(up, endDrag); window.addEventListener('blur', endDrag);
  document.addEventListener('keydown', function (event) { if (event.key === 'Escape' && document.activeElement !== query) focusMap(); });
  // Apply local geometry immediately; server updates are only needed after the drag ends.
  window.classicGeometryForTest = function () { return geometry; };
  topic('ready');
}());
