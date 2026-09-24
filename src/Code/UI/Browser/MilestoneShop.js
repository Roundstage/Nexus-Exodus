(function () {
  'use strict';
  var config = window.milestoneShopConfig;
  var entries = config.entries;
  var byId = {};
  var state = { category: 'All', query: '', buyable: false, selected: '', scroll: 0 };
  var storageKey = 'nexusMilestoneShop:' + config.ref;
  var pending = false;
  var restoringScroll = true;
  var i;
  for (i = 0; i < entries.length; i++) byId[entries[i].id] = entries[i];
  try {
    var saved = JSON.parse(sessionStorage.getItem(storageKey));
    if (saved) {
      if (config.categories.indexOf(saved.category) >= 0) state.category = saved.category;
      state.query = typeof saved.query === 'string' ? saved.query.slice(0, 60) : '';
      state.buyable = saved.buyable === true;
      state.selected = byId[saved.selected] ? saved.selected : '';
      state.scroll = Math.max(0, Number(saved.scroll) || 0);
    }
  } catch (error) { /* A disabled storage policy must not prevent purchases. */ }

  function node(tag, className, text) {
    var element = document.createElement(tag);
    if (className) element.className = className;
    if (text !== undefined) element.textContent = text;
    return element;
  }
  function button(className, text, action) {
    var element = node('button', className, text);
    element.type = 'button';
    element.onclick = action;
    return element;
  }
  function persist() {
    try { sessionStorage.setItem(storageKey, JSON.stringify(state)); } catch (error) { /* Optional. */ }
  }
  function send(action, fields) {
    persist();
    var url = 'byond://?src=' + encodeURIComponent(config.ref) + '&action=' + encodeURIComponent(action);
    for (var key in fields) {
      if (Object.prototype.hasOwnProperty.call(fields, key)) url += '&' + encodeURIComponent(key) + '=' + encodeURIComponent(fields[key]);
    }
    if (window.milestoneShopTestTransport) window.milestoneShopTestTransport(url);
    else window.location.href = url;
  }
  function illustration(entry, className) {
    var frame = node('span', 'art ' + (className || ''));
    if (entry.icon) {
      var img = node('img');
      img.src = entry.icon;
      img.alt = '';
      frame.appendChild(img);
    } else frame.textContent = entry.name.charAt(0);
    return frame;
  }
  function isStyle(entry) { return entry.exclusiveGroup === 'secondary_damage_stat'; }
  function status(entry) {
    if (entry.state === 'owned') return isStyle(entry) ? 'Chosen style' : 'Max rank';
    if (entry.exclusiveChoice) return 'Locked by ' + byId[entry.exclusiveChoice].name;
    if (entry.state === 'locked') return entry.reason;
    return entry.rank ? 'Upgrade available' : 'Available';
  }
  function select(id, moveFocus) {
    state.selected = id;
    persist();
    var cards = catalog.querySelectorAll('.milestone-card');
    for (var index = 0; index < cards.length; index++) {
      var selected = cards[index].getAttribute('data-id') === id;
      cards[index].classList.toggle('selected', selected);
      cards[index].setAttribute('aria-pressed', String(selected));
    }
    renderDetail();
    if (moveFocus) detail.focus();
  }

  var shell = node('div', 'shop');
  var header = node('header', 'shop-header hud-frame');
  var top = node('div', 'top');
  top.appendChild(illustration({ icon: config.categoryIcons.All }, 'title-icon'));
  var title = node('div', 'title');
  title.appendChild(node('div', 'eyebrow', 'NEXUS EXODUS'));
  title.appendChild(node('h1', 'hud-title', 'Milestones'));
  title.appendChild(node('p', 'character', config.character + (config.race ? ' / ' + config.race : '')));
  top.appendChild(title);
  var wallets = node('div', 'wallets');
  function wallet(label, value, caption, className) {
    var box = node('div', 'wallet hud-panel ' + (className || ''));
    box.appendChild(node('span', 'eyebrow', label));
    box.appendChild(node('strong', '', value));
    box.appendChild(node('small', '', caption));
    wallets.appendChild(box);
  }
  wallet('MILESTONE POINTS', String(config.points), 'available to spend', 'balance');
  wallet('EARNED', config.earned + ' / ' + config.cap, 'lifetime MP');
  top.appendChild(wallets);
  top.appendChild(button('close-button hud-button danger', 'Close', function () { send('close', {}); }));
  header.appendChild(top);
  var nav = node('div', 'shop-nav');
  var active = node('span', 'nav-active hud-tab active', 'Milestones');
  active.appendChild(node('small', '', String(entries.length)));
  nav.appendChild(active);
  nav.appendChild(node('span', 'nav-note', 'Independent picks. Make every point count.'));
  header.appendChild(nav);
  shell.appendChild(header);

  var tools = node('section', 'shop-tools');
  var searchRow = node('div', 'search-row');
  var search = node('input', 'search');
  search.type = 'search';
  search.maxLength = 60;
  search.placeholder = 'Search milestones, effects or categories...';
  search.setAttribute('aria-label', 'Search milestones');
  search.value = state.query;
  search.oninput = function () { state.query = search.value; refreshFilters(); };
  searchRow.appendChild(search);
  var buyableCount = entries.filter(function (entry) { return entry.state === 'available'; }).length;
  var buyable = button('filter-buyable hud-tab', 'Buyable now ' + buyableCount, function () { state.buyable = !state.buyable; refreshFilters(); });
  searchRow.appendChild(buyable);
  tools.appendChild(searchRow);
  var chips = node('div', 'categories');
  chips.setAttribute('aria-label', 'Milestone categories');
  var categoryNames = ['All'].concat(config.categories);
  categoryNames.forEach(function (category) {
    var count = entries.filter(function (entry) { return category === 'All' || entry.category === category; }).length;
    var chip = button('category-chip hud-tab', '', function () { state.category = category; refreshFilters(); });
    chip.appendChild(illustration({ icon: config.categoryIcons[category] }, 'category-icon'));
    chip.appendChild(node('span', 'category-name', category));
    chip.appendChild(node('small', '', String(count)));
    chip.setAttribute('data-category', category);
    chips.appendChild(chip);
  });
  shell.appendChild(tools);
  var notice = node('div', 'notice', config.notice || '');
  notice.setAttribute('role', 'status');
  if (!config.notice) notice.hidden = true;
  shell.appendChild(notice);

  var workspace = node('main', 'workspace');
  var categoryPanel = node('nav', 'category-panel hud-frame');
  categoryPanel.setAttribute('aria-label', 'Milestone categories');
  categoryPanel.appendChild(node('h2', 'panel-heading', 'Categories'));
  categoryPanel.appendChild(chips);
  workspace.appendChild(categoryPanel);
  var catalog = node('section', 'catalog');
  catalog.setAttribute('aria-label', 'Milestone catalog');
  catalog.onscroll = function () { if (restoringScroll) return; state.scroll = catalog.scrollTop; persist(); };
  workspace.appendChild(catalog);
  var detail = node('aside', 'detail hud-frame');
  detail.tabIndex = -1;
  detail.setAttribute('aria-label', 'Milestone details');
  workspace.appendChild(detail);
  shell.appendChild(workspace);
  document.body.appendChild(shell);

  function refreshFilters() {
    state.scroll = 0;
    renderCatalog();
    persist();
  }
  function renderCatalog() {
    catalog.textContent = '';
    buyable.classList.toggle('active', state.buyable);
    buyable.setAttribute('aria-pressed', String(state.buyable));
    for (var index = 0; index < chips.children.length; index++) {
      var chip = chips.children[index];
      var isActive = chip.getAttribute('data-category') === state.category;
      chip.classList.toggle('active', isActive);
      chip.setAttribute('aria-pressed', String(isActive));
    }
    var banner = button('style-banner hud-panel', '', function () {
      state.category = 'Builds'; state.query = ''; search.value = ''; state.buyable = false;
      refreshFilters(); select('momentum_damage', true);
    });
    var bannerText = node('span');
    bannerText.appendChild(node('strong', '', config.damageStyle ? 'Damage style: ' + config.damageStyle : 'Choose your damage style'));
    bannerText.appendChild(node('small', '', 'Momentum, Precision or Fortified. Only one can be purchased.'));
    banner.appendChild(bannerText);
    banner.appendChild(node('span', 'style-count', config.damageStyle ? '1 / 1' : '0 / 1'));
    catalog.appendChild(banner);
    var query = state.query.toLowerCase().trim();
    var matches = entries.filter(function (entry) {
      return (state.category === 'All' || entry.category === state.category) &&
        (!state.buyable || entry.state === 'available') &&
        (!query || (entry.name + ' ' + entry.description + ' ' + entry.category).toLowerCase().indexOf(query) >= 0);
    });
    config.categories.forEach(function (category) {
      var group = matches.filter(function (entry) { return entry.category === category; });
      if (!group.length) return;
      var section = node('section', 'category-section');
      var heading = node('h2', '', category);
      heading.appendChild(node('small', '', String(group.length)));
      section.appendChild(heading);
      var grid = node('div', 'card-grid');
      group.forEach(function (entry) {
        var card = button('milestone-card hud-card ' + entry.state + (state.selected === entry.id ? ' selected' : ''), '', function () { select(entry.id, true); });
        card.setAttribute('data-id', entry.id);
        card.setAttribute('aria-pressed', String(state.selected === entry.id));
        card.setAttribute('aria-label', entry.name + ', rank ' + entry.rank + ' of ' + entry.maxRank + ', ' + status(entry));
        card.appendChild(illustration(entry, 'card-art'));
        var cardTop = node('span', 'card-top');
        cardTop.appendChild(node('strong', 'card-name', entry.name));
        cardTop.appendChild(node('span', 'cost', entry.cost + ' MP' + (entry.maxRank > 1 ? ' / rank' : '')));
        card.appendChild(cardTop);
        card.appendChild(node('span', 'description', entry.description));
        var meta = node('span', 'card-meta');
        meta.appendChild(node('span', 'rank', 'Rank ' + entry.rank + ' / ' + entry.maxRank));
        if (isStyle(entry) && !entry.exclusiveChoice) meta.appendChild(node('span', 'badge exclusive', 'Choose one'));
        else meta.appendChild(node('span', 'badge', status(entry)));
        card.appendChild(meta);
        grid.appendChild(card);
      });
      section.appendChild(grid);
      catalog.appendChild(section);
    });
    if (!matches.length) {
      var empty = node('div', 'empty');
      empty.appendChild(node('h2', '', 'No matching milestones'));
      empty.appendChild(node('p', '', 'Try another search or clear your filters.'));
      empty.appendChild(button('secondary-button hud-button', 'Clear filters', function () {
        state.category = 'All'; state.query = ''; state.buyable = false; search.value = ''; refreshFilters();
      }));
      catalog.appendChild(empty);
    }
    catalog.scrollTop = state.scroll;
  }
  function renderDetail() {
    detail.textContent = '';
    var content = node('div', 'detail-content');
    detail.appendChild(content);
    var entry = byId[state.selected];
    if (!entry) {
      var welcome = node('div', 'detail-welcome');
      welcome.appendChild(illustration({ icon: config.categoryIcons.All }, 'detail-symbol'));
      welcome.appendChild(node('div', 'eyebrow', 'YOUR NEXT MILESTONE'));
      welcome.appendChild(node('h2', '', 'Shape your build'));
      welcome.appendChild(node('p', '', 'Select a milestone to see its full effect, ranks and cost before purchasing.'));
      welcome.appendChild(node('p', 'subtle', 'Earn 5 starting MP and 1 per later game year, up to 22 lifetime MP.'));
      content.appendChild(welcome);
      return;
    }
    var hero = node('div', 'detail-hero');
    hero.appendChild(illustration(entry, 'detail-art'));
    hero.appendChild(node('div', 'eyebrow', entry.category + (isStyle(entry) ? ' / DAMAGE STYLE' : '')));
    hero.appendChild(node('h2', '', entry.name));
    content.appendChild(hero);
    var effects = node('div', 'full-description');
    entry.description.split('\n').forEach(function (paragraph) {
      if (paragraph.trim()) effects.appendChild(node('p', '', paragraph));
    });
    content.appendChild(effects);
    var facts = node('div', 'detail-facts');
    facts.appendChild(node('span', '', 'Rank ' + entry.rank + ' / ' + entry.maxRank));
    facts.appendChild(node('strong', '', entry.cost + ' MP' + (entry.maxRank > 1 ? ' per rank' : '')));
    content.appendChild(facts);
    if (entry.maxRank > 1) {
      var ranks = node('div', 'rank-track');
      ranks.setAttribute('aria-label', entry.rank + ' of ' + entry.maxRank + ' ranks owned');
      for (var rank = 1; rank <= entry.maxRank; rank++) ranks.appendChild(node('span', rank <= entry.rank ? 'filled' : '', String(rank)));
      content.appendChild(ranks);
    }
    if (entry.exclusiveGroup) {
      var exclusive = node('section', 'exclusive-panel hud-panel');
      exclusive.appendChild(node('h3', '', isStyle(entry) ? 'Damage styles / choose one' : 'Exclusive choice'));
      exclusive.appendChild(node('p', '', 'Purchasing one locks the other choices for this character.'));
      entries.filter(function (other) { return other.exclusiveGroup === entry.exclusiveGroup; }).forEach(function (other) {
        var choice = button('style-option' + (other.id === entry.id ? ' current' : ''), '', function () { select(other.id, true); });
        choice.appendChild(node('span', '', other.name));
        choice.appendChild(node('small', '', other.rank ? 'Chosen' : other.id === entry.id ? 'Viewing' : 'Compare'));
        exclusive.appendChild(choice);
      });
      content.appendChild(exclusive);
    }
    var purchase = node('div', 'purchase-area');
    var reason = node('p', 'purchase-reason', entry.reason || status(entry));
    purchase.appendChild(reason);
    var label = entry.state === 'owned' ? 'Maximum rank reached' : entry.state === 'locked' ? 'Unavailable' :
      (entry.rank ? 'Upgrade to rank ' + (entry.rank + 1) : 'Purchase milestone') + ' / ' + entry.cost + ' MP';
    var buy = button('purchase-button hud-button', pending ? 'Waiting for purchase...' : label, function () {
      if (pending || entry.state !== 'available') return;
      pending = true;
      renderDetail();
      send('milestone', { node: entry.id, rank: entry.rank });
    });
    buy.disabled = pending || entry.state !== 'available';
    purchase.appendChild(buy);
    if (entry.state === 'available') purchase.appendChild(node('small', 'balance-after', (config.points - entry.cost) + ' MP remaining after purchase'));
    detail.appendChild(purchase);
  }
  renderCatalog();
  renderDetail();
  function restoreAfterFonts() {
    catalog.scrollTop = state.scroll;
    restoringScroll = false;
  }
  if (document.fonts && document.fonts.ready) document.fonts.ready.then(restoreAfterFonts);
  else restoreAfterFonts();
})();
