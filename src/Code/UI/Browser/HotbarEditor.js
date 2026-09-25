(function () {
  'use strict';
  var c = window.hotbarConfig, selected = c.selected || 1, capture = false, chosen = '', combo = null, mode = c.mode === 'direct' ? 'direct' : 'slot';
  function el(tag, cls, text) { var n = document.createElement(tag); if (cls) n.className = cls; if (text != null) n.textContent = text; return n; }
  function send(action, values) {
    var q = {src:c.ref, action:action, slot:selected,bar:c.bar,mode:mode,token:chosen}; Object.keys(values || {}).forEach(function(k){q[k]=values[k];});
    var url = 'byond://?' + Object.keys(q).map(function(k){return encodeURIComponent(k)+'='+encodeURIComponent(q[k]);}).join('&');
    if (window.hotbarTestTransport) window.hotbarTestTransport(url); else window.location.href = url;
  }
  function button(text, fn) {var n=el('button','',text);n.type='button';n.onclick=fn;return n;}
  document.body.className='hotbar-editor';
  var shell=el('main','shell'), head=el('header','head'), title=el('b','title','HOTBAR / HOTKEYS');
  head.appendChild(title); head.appendChild(button('Show bar',function(){send('open_bar');})); head.appendChild(button('Close',function(){send('close');})); shell.appendChild(head);
  var main=el('div','editor-main'), work=el('section','workspace'), aside=el('aside','catalog');main.appendChild(work);main.appendChild(aside);shell.appendChild(main);document.body.appendChild(shell);
  var modes=el('nav','binding-modes'),slotMode=button('Bar slots',function(){setMode('slot');}),directMode=button('Hotkeys only',function(){setMode('direct');});
  modes.setAttribute('aria-label','Hotkey destination');modes.appendChild(slotMode);modes.appendChild(directMode);work.appendChild(modes);
  var modeHint=el('p','hint');work.appendChild(modeHint);
  var banks=el('nav','bank-tabs'),barSelect=el('select');barSelect.setAttribute('aria-label','Bar');work.appendChild(banks);
  (c.bars||[]).forEach(function(bar){var option=el('option','',bar.name+' ('+bar.count+' slots)');option.value=bar.id;option.selected=bar.id===c.bar;barSelect.appendChild(option);});
  barSelect.onchange=function(){send('select_bar',{bar:barSelect.value});};banks.appendChild(barSelect);
  banks.appendChild(button('+ Bar',function(){send('add_bar');}));
  banks.appendChild(button('Delete bar',function(){if(c.bar&&confirm('Delete this bar and its slot bindings?'))send('remove_bar');}));
  var growth=el('nav','slot-growth');work.appendChild(growth);
  growth.appendChild(button('+ Slot',function(){send('add_slot',{count:1});}));growth.appendChild(button('+ 12 slots',function(){send('add_slot',{count:12});}));
  growth.appendChild(button('Remove slot',function(){if(selected&&confirm('Remove this slot and its key bindings?'))send('remove_slot');}));
  if(c.pages>1){growth.appendChild(button('Previous',function(){send('page',{page:Math.max(1,c.page-1)});}));growth.appendChild(el('small','','Page '+c.page+' / '+c.pages));growth.appendChild(button('Next',function(){send('page',{page:Math.min(c.pages,c.page+1)});}));}
  var slots=el('div','editor-slots'); work.appendChild(slots);
  c.slots.forEach(function(s){
    var n=button('',function(){select(s.slot);});n.className='editor-slot';n.dataset.slot=s.slot;n.draggable=true;
    if(s.icon){var img=el('img');img.src=s.icon;img.alt='';n.appendChild(img);}
    n.appendChild(el('small','','#'+(s.position||s.slot)));n.appendChild(el('b','slot-name',s.state==='empty'?'Empty':s.name));n.appendChild(el('span','slot-key',s.key||'No key'));
    n.ondragstart=function(e){e.dataTransfer.setData('text/plain','classic-slot:'+s.slot);};
    n.ondragover=function(e){e.preventDefault();n.classList.add('drag-over');};n.ondragleave=function(){n.classList.remove('drag-over');};
    n.ondrop=function(e){e.preventDefault();select(s.slot);var token=e.dataTransfer.getData('text/plain');if(token.indexOf('classic-slot:')===0)send('swap',{from:token.slice(13)});else if(/^classic-(skill|action|command):/.test(token))send('assign',{token:token});};
    slots.appendChild(n);
  });
  var controls=el('section','key-controls'), label=el('b','group'), status=el('p','notice',c.notice||'Click Capture, then press a key with optional Ctrl, Shift or Alt.');work.appendChild(controls);controls.appendChild(label);
  var captureButton=button('Capture key',function(){capture=true;captureButton.textContent='Press a combination…';captureButton.focus();status.textContent='Press your combination. Escape cancels capture.';});
  var clearButton=button('Clear action',function(){send('clear_slot');}),detachButton=button('Move to hotkeys only',function(){send('detach_slot');});
  controls.appendChild(captureButton);controls.appendChild(clearButton);controls.appendChild(detachButton);
  var manual=el('div','manual'), keySelect=el('select');keySelect.setAttribute('aria-label','Key');
  c.keys.filter(function(k){return k!=='F1'&&k!=='F2';}).forEach(function(k){var o=el('option','',k);o.value=k;keySelect.appendChild(o);});manual.appendChild(keySelect);
  function check(text){var l=el('label'),i=el('input');i.type='checkbox';l.appendChild(i);l.appendChild(document.createTextNode(text));manual.appendChild(l);return i;}
  var ctrl=check('Ctrl'),shift=check('Shift'),alt=check('Alt'),double=check('Double tap');
  var bindButton=button('Bind',function(){prepare({key:keySelect.value,ctrl:ctrl.checked?1:0,shift:shift.checked?1:0,alt:alt.checked?1:0,double:double.checked?1:0});});
  manual.appendChild(bindButton);controls.appendChild(manual);controls.appendChild(status);
  var conflict=el('div','conflict');conflict.hidden=true;controls.appendChild(conflict);
  function prepare(value){
    if(mode==='direct'&&!chosen){status.textContent='Choose an action from the list first.';return;}
    capture=false;captureButton.textContent='Capture key';combo=value;
    var canonical=(value.double?'DOUBLE:':'')+(value.ctrl?'CTRL+':'')+(value.shift?'SHIFT+':'')+(value.alt?'ALT+':'')+value.key;
    var existing=c.bindings.filter(function(b){return b.key===canonical&&(mode==='direct'||b.slot!==selected);})[0];
    if(existing){conflict.textContent='Replace '+canonical+' → '+existing.name+'? ';conflict.hidden=false;conflict.appendChild(button('Replace binding',function(){combo.replace=existing.fingerprint;send('bind',combo);}));conflict.appendChild(button('Cancel',function(){conflict.hidden=true;}));}
    else send('bind',combo);
  }
  var aliases={ArrowUp:'North',ArrowDown:'South',ArrowLeft:'West',ArrowRight:'East',' ':'Space',Enter:'Return',Backspace:'Back'};
  document.addEventListener('keydown',function(e){
    if(!capture)return;e.preventDefault();e.stopPropagation();
    if(e.key==='Escape'){capture=false;captureButton.textContent='Capture key';status.textContent='Capture cancelled.';return;}
    if(['Control','Shift','Alt','Meta'].indexOf(e.key)!==-1)return;
    if(e.metaKey){status.textContent='The Windows key is reserved.';return;}
    var key=aliases[e.key]||e.key;
    if(/^Numpad[0-9]$/.test(e.code))key=e.code;
    var found=c.keys.filter(function(k){return k.toLowerCase()===key.toLowerCase();})[0];
    if(!found||found==='F1'||found==='F2'||(e.altKey&&found==='F4')){status.textContent='This key is reserved or unsupported. Choose another.';return;}
    prepare({key:found,ctrl:e.ctrlKey?1:0,shift:e.shiftKey?1:0,alt:e.altKey?1:0,double:double.checked?1:0});
  },true);
  var bindings=el('div','bindings');controls.appendChild(bindings);
  function select(index){selected=index;var slot=c.slots.filter(function(s){return s.slot===index;})[0];
    Array.prototype.forEach.call(slots.children,function(n){n.classList.toggle('selected',Number(n.dataset.slot)===index);});
    bindings.textContent='';c.bindings.filter(function(b){return b.slot===selected;}).forEach(function(b){var row=el('div');row.appendChild(el('span','',b.key));row.appendChild(button('Unbind',function(){send('unbind',{key:b.key});}));bindings.appendChild(row);});
    updateMode();
  }
  var layout=el('section','layout');layout.appendChild(el('b','group','BAR LAYOUT'));work.appendChild(layout);
  function option(label,values,current){var l=el('label','',label),s=el('select');values.forEach(function(v){var o=el('option','',String(v));o.value=v;o.selected=v===current;s.appendChild(o);});l.appendChild(s);layout.appendChild(l);return s;}
  var nameLabel=el('label','','Name'),barName=el('input');barName.value=c.name||'';barName.maxLength=80;nameLabel.appendChild(barName);layout.appendChild(nameLabel);
  var columnLabel=el('label','','Columns'),columns=el('input');columns.type='number';columns.min=1;columns.max=Math.max(1,c.count||1);columns.value=c.columns||1;columns.setAttribute('aria-label','Columns');columnLabel.appendChild(columns);layout.appendChild(columnLabel);
  var size=option('Icon size',[32,40,48,56,64],c.size),lock=option('Lock bar',['Off','On'],c.locked?'On':'Off');
  layout.appendChild(button('Apply layout',function(){send('layout',{name:barName.value,columns:columns.value,size:size.value,locked:lock.value==='On'?1:0});}));
  layout.appendChild(button('Hide bar',function(){send('hide_bar');}));
  var other=el('section','other-bindings');other.appendChild(el('b','group','HOTKEYS WITHOUT BAR SLOTS'));
  var directBindings=c.bindings.filter(function(b){return !b.slot;});
  directBindings.forEach(function(b){var row=el('div','binding-row');row.appendChild(el('span','',b.key+' → '+b.name));if(b.token)row.appendChild(button('Select action',function(){chooseAction(b.token);setMode('direct');}));row.appendChild(button('Unbind',function(){send('unbind',{key:b.key});}));other.appendChild(row);});
  if(!directBindings.length)other.appendChild(el('p','hint','No independent hotkeys yet. Choose an action and bind a key.'));work.appendChild(other);
  aside.appendChild(el('b','group','ACTIONS & VERBS'));var search=el('input');search.type='search';search.placeholder='Search skills, items, verbs…';search.setAttribute('aria-label','Search actions');aside.appendChild(search);
  var catalogHint=el('p','hint');aside.appendChild(catalogHint);
  var assign=button('Assign selected action',function(){if(chosen)send('assign',{token:chosen});});assign.disabled=true;aside.appendChild(assign);
  var list=el('div','action-list');aside.appendChild(list);
  c.actions.forEach(function(a){var n=button('',function(){chooseAction(a.token);});n.className='action-card';n.dataset.token=a.token;n.draggable=true;n.appendChild(el('b','',a.name));n.appendChild(el('small','',a.group||'Action'));n.ondragstart=function(e){e.dataTransfer.setData('text/plain',a.token);};list.appendChild(n);});
  search.oninput=function(){var q=search.value.toLowerCase();Array.prototype.forEach.call(list.children,function(n){n.hidden=n.textContent.toLowerCase().indexOf(q)===-1;});};
  function chooseAction(token){
    if(!c.actions.some(function(a){return a.token===token;}))return;
    chosen=token;assign.disabled=false;Array.prototype.forEach.call(list.children,function(row){row.classList.toggle('selected',row.dataset.token===token);});updateMode();
  }
  function setMode(value){mode=value;updateMode();}
  function updateMode(){
    var direct=mode==='direct',slot=c.slots.filter(function(s){return s.slot===selected;})[0],action=c.actions.filter(function(a){return a.token===chosen;})[0];
    capture=false;conflict.hidden=true;captureButton.textContent='Capture key';
    slotMode.setAttribute('aria-pressed',String(!direct));directMode.setAttribute('aria-pressed',String(direct));
    modeHint.textContent=direct?'Choose an action, then bind a key. It works without taking a bar slot.':'Select a slot, then drag or choose an action. Keys stay with the slot when actions move.';
    catalogHint.textContent=direct?'Select the action for your independent hotkey.':'Drag to a slot here or in the game. Or select an action and click Assign.';
    [banks,growth,slots,layout,clearButton,detachButton,bindings,assign].forEach(function(n){n.hidden=direct;});other.hidden=!direct;
    label.textContent=direct?(action?'ACTION: '+action.name:'CHOOSE AN ACTION'):(slot?'SLOT '+(slot.position||selected):'ADD A SLOT TO START');
    captureButton.disabled=bindButton.disabled=direct?!action:!slot;
    detachButton.disabled=!slot||slot.state==='empty'||!c.bindings.some(function(b){return b.slot===selected;});
  }
  if(c.pendingAction)chooseAction(c.pendingAction);
  select(selected);
}());
