'use strict';
// Coordinates are BYOND coordinates; rows in a serialized block run north to south.
const crypto = require('node:crypto');
const hash = value => crypto.createHash('sha256').update(value).digest('hex');
function splitOutside(text, separator) {
 const parts = []; let start = 0, quote = '', escaped = false; const nesting = [];
 for (let i = 0; i < text.length; i++) {
  const c = text[i];
  if (quote) { if (escaped) escaped = false; else if (c === '\\') escaped = true; else if (c === quote) quote = ''; continue; }
  if (c === '"' || c === "'") { quote = c; continue; }
  if ('({['.includes(c)) nesting.push(c);
  else if (')}]'.includes(c)) { if (nesting.pop() !== ({')':'(', '}':'{', ']':'['})[c]) throw Error('Unbalanced atom stack'); }
  else if (c === separator && !nesting.length) { parts.push(text.slice(start, i).trim()); start = i + 1; }
 }
 if (quote || nesting.length) throw Error('Unterminated atom stack');
 parts.push(text.slice(start).trim());
 if(separator === ',' && parts.some(part=>!part)) throw Error('Empty atom in stack');
 return parts.filter(Boolean);
}
function canonical(stack) {
 const atoms = splitOutside(stack, ',').map(atom => {
  const m = atom.match(/^(\/[A-Za-z_][\w]*(?:\/[A-Za-z_][\w]*)*)\s*(?:\{([\s\S]*)\})?$/);
  if (!m) throw Error(`Malformed atom: ${atom}`);
  if (m[2] === undefined) return m[1];
  const seen = new Set();
  const vars = splitOutside(m[2], ';').map(v => {
   const a = v.match(/^([A-Za-z_]\w*)\s*=\s*([\s\S]+)$/);
   if (!a || seen.has(a[1])) throw Error(`Malformed or duplicate variable: ${v}`);
   seen.add(a[1]); return [a[1], a[2].trim()];
  }).sort((a,b) => a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0);
  return m[1] + (vars.length ? '{' + vars.map(([k,v]) => `${k} = ${v}`).join('; ') + '}' : '');
 });
 if (atoms.filter(a => /^\/turf(?:\/|\{|$)/.test(a)).length !== 1 || atoms.filter(a => /^\/area(?:\/|\{|$)/.test(a)).length !== 1) throw Error('Every tile needs exactly one turf and one area');
 if (!atoms.at(-1).startsWith('/area') || !atoms.at(-2)?.startsWith('/turf')) throw Error('Expected objects, turf, area stack order');
 return atoms.join(',');
}
function parse(text) {
 text = text.replace(/^\uFEFF/, '').replace(/\r\n/g, '\n');
 let p = 0, keyLength = 0; const palette = new Map(), blocks = [];
 function skip() { while (p < text.length) { if (/\s/.test(text[p])) p++; else if (text.startsWith('//', p)) { const end = text.indexOf('\n', p); p = end < 0 ? text.length : end + 1; } else if (text.startsWith('/*',p)) { const end = text.indexOf('*/',p+2); if(end < 0) throw Error('Unterminated comment'); p=end+2; } else break; } }
 while (true) {
  skip(); if (p === text.length) break;
  if (text[p] === '"') {
   const m = text.slice(p).match(/^"([A-Za-z]+)"\s*=\s*\(/); if (!m) throw Error(`Malformed dictionary at ${p}`);
   const key = m[1]; if (palette.has(key)) throw Error(`Duplicate key ${key}`);
   if (keyLength && key.length !== keyLength) throw Error('Inconsistent key width'); keyLength = key.length;
   p += m[0].length; const start = p; let depth = 1, quote = '', escaped = false;
   for (; p < text.length; p++) {
    const c = text[p]; if (quote) { if(escaped) escaped=false; else if(c === '\\') escaped=true; else if(c === quote) quote=''; continue; }
    if(c === '"' || c === "'") quote=c;
    else if(c === '(') depth++;
    else if(c === ')' && --depth === 0) break;
   }
   if(depth) throw Error('Unterminated dictionary'); palette.set(key, canonical(text.slice(start,p))); p++;
  } else {
   const m = text.slice(p).match(/^\((\d+),\s*(\d+),\s*(\d+)\)\s*=\s*\{"\n([\s\S]*?)\n"\}/);
   if (!m) throw Error(`Malformed coordinate block at ${p}`);
   blocks.push({x:+m[1], y:+m[2], z:+m[3], rows:m[4].split('\n')}); p += m[0].length;
  }
 }
 if (!palette.size || !blocks.length) throw Error('Empty map');
 const cells = new Map(); let width=0, height=0;
 for(const b of blocks) {
  if(b.x < 1 || b.y < 1 || b.z !== 1) throw Error('Expected positive XY and one local Z=1');
  const rowWidth=b.rows[0].length / keyLength;
  if(!Number.isInteger(rowWidth) || !rowWidth) throw Error('Invalid row width');
  for(let row=0;row<b.rows.length;row++) {
   if(b.rows[row].length !== rowWidth*keyLength) throw Error('Ragged block');
   for(let col=0;col<rowWidth;col++) {
    const key=b.rows[row].slice(col*keyLength,(col+1)*keyLength), x=b.x+col, y=b.y+b.rows.length-1-row, id=`${x},${y}`;
    if(!palette.has(key)) throw Error(`Undefined key ${key}`);
    if(cells.has(id)) throw Error(`Overlapping coordinate ${id}`);
    cells.set(id,palette.get(key)); width=Math.max(width,x); height=Math.max(height,y);
   }
  }
 }
 if(cells.size !== width*height) throw Error('Map has coordinate holes');
 const grid=Array.from({length:height},(_,row)=>Array.from({length:width},(_,col)=>cells.get(`${col+1},${height-row}`)));
 return {width,height,grid,palette};
}
function serialize(grid) {
 if(!grid.length || !grid[0].length || grid.some(r=>r.length !== grid[0].length)) throw Error('Invalid grid');
 const values=[...new Set(grid.flat().map(canonical))].sort(), alphabet='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
 let width=1; while(alphabet.length ** width < values.length) width++;
 const keys=values.map((_,n)=> { let key=''; for(let i=0;i<width;i++){key=alphabet[n%alphabet.length]+key;n=Math.floor(n/alphabet.length);} return key; });
 const lookup=new Map(values.map((v,i)=>[v,keys[i]]));
 return values.map((v,i)=>`"${keys[i]}" = (${v})`).join('\n')+'\n\n(1,1,1) = {"\n'+grid.map(r=>r.map(v=>lookup.get(canonical(v))).join('')).join('\n')+'\n"}\n';
}
module.exports={hash,splitOutside,canonical,parse,serialize};
