// Native 32px DMI tailoring. Requires sharp; no generated/resampled sprite art.
// node tools/BuildViltrumiteClothing.cjs
const fs = require('node:fs');
const path = require('node:path');
const zlib = require('node:zlib');
const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const originals = path.join(root, 'ArtSource/Viltrumite/Originals');
const destination = path.join(root, 'src/Icons/PlayerIcons/Clothes/Viltrumite');
const artifacts = path.join(root, 'artifacts/ViltrumiteClothing');

function crc32(bytes) {
  let crc = 0xffffffff;
  for (const byte of bytes) {
    crc ^= byte;
    for (let bit = 0; bit < 8; bit++) crc = (crc >>> 1) ^ ((crc & 1) ? 0xedb88320 : 0);
  }
  return (crc ^ 0xffffffff) >>> 0;
}
function pngChunk(type, data) {
  const b = Buffer.alloc(data.length + 12);
  b.writeUInt32BE(data.length); b.write(type, 4, 'ascii'); data.copy(b, 8);
  b.writeUInt32BE(crc32(b.subarray(4, b.length - 4)), b.length - 4);
  return b;
}
async function readDmi(file) {
  const bytes = fs.readFileSync(file);
  let description;
  for (let o = 8; o < bytes.length;) {
    const n = bytes.readUInt32BE(o), type = bytes.toString('ascii', o + 4, o + 8);
    const data = bytes.subarray(o + 8, o + 8 + n);
    if (type === 'zTXt' && data.subarray(0, 11).toString() === 'Description') description = zlib.inflateSync(data.subarray(13)).toString();
    if (type === 'tEXt' && data.subarray(0, 11).toString() === 'Description') description = data.subarray(12).toString();
    o += n + 12;
  }
  assert(description && description.includes('width = 32') && description.includes('height = 32'));
  const { data, info } = await sharp(bytes).ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  const frames = [], states = [];
  for (const block of description.split(/^state = /m).slice(1)) {
    const state = { name: block.match(/^"(.*)"/)[1], dirs: Number(block.match(/dirs = (\d+)/)[1]),
      count: Number(block.match(/frames = (\d+)/)[1]), moving: /movement = 1/.test(block), start: frames.length };
    states.push(state);
    for (let animation = 0; animation < state.count; animation++) for (let dir = 0; dir < state.dirs; dir++) {
      const index = frames.length, pixels = Buffer.alloc(32 * 32 * 4);
      for (let y = 0; y < 32; y++) {
        const offset = ((Math.floor(index / (info.width / 32)) * 32 + y) * info.width + index % (info.width / 32) * 32) * 4;
        data.copy(pixels, y * 128, offset, offset + 128);
      }
      frames.push({ state, animation, dir, index, pixels });
    }
  }
  return { description, frames, states, info, bytes };
}
const rgba = hex => [...Buffer.from(hex, 'hex'), 255];
function colorAt(pixels, x, y) { return pixels.subarray((y * 32 + x) * 4, (y * 32 + x) * 4 + 3).toString('hex'); }
function visible(pixels, x, y) { return x >= 0 && y >= 0 && x < 32 && y < 32 && pixels[(y * 32 + x) * 4 + 3] > 0; }
function put(pixels, x, y, color) { if (x >= 0 && y >= 0 && x < 32 && y < 32) pixels.set(color, (y * 32 + x) * 4); }
function firstRow(pixels) {
  for (let y = 0; y < 32; y++) for (let x = 0; x < 32; x++) if (visible(pixels, x, y)) return y;
}
function turnFor(frame) {
  if (frame.state.name === 'KO') return 1;
  if (frame.state.name === 'KB') return frame.animation;
  return 0;
}
function fromUpright(x, y, turn) {
  if (turn === 1) return [31 - y, x];
  if (turn === 2) return [31 - x, 31 - y];
  if (turn === 3) return [y, 31 - x];
  return [x, y];
}
function uprightPixels(frame) {
  const p = Buffer.alloc(4096), turn = turnFor(frame);
  for (let y = 0; y < 32; y++) for (let x = 0; x < 32; x++) {
    const [sx, sy] = fromUpright(x, y, turn);
    frame.pixels.copy(p, (y * 32 + x) * 4, (sy * 32 + sx) * 4, (sy * 32 + sx) * 4 + 4);
  }
  return p;
}
const suitColors = {
  '000000': '1a1c1e', 'ffe2c7': 'dde4ec', 'f7c5ae': 'c6cdd4',
  'efa895': 'a9b4c2', 'e79886': '9ea8b3', 'df8877': '7e8894',
  'b86b5e': '5c646e', '904e44': '3c434d',
};
function bulkJumpsuit(frame) {
  const src = uprightPixels(frame), out = Buffer.alloc(4096), top = firstRow(src);
  // Keep the complete head and neckline transparent. Arms outside this box can
  // extend beside the head during attacks and still need a correctly fitted sleeve.
  const headBottom = top + 9;
  const flight = frame.state.name === 'Flight';
  const headLeft = 10, headRight = 21;
  for (let y = 0; y < 32; y++) for (let x = 0; x < 32; x++) {
    if (!visible(src, x, y)) continue;
    if (y <= headBottom && x >= headLeft && x <= headRight) continue;
    const skinColor = colorAt(src, x, y);
    assert(suitColors[skinColor], `Unmasked Bulk face pixel ${frame.index}:${x},${y} ${skinColor}`);
    let garment = suitColors[skinColor];
    // A charcoal collar, narrow waist seam and boots match the existing uniform.
    if (y === headBottom + 1 && x >= 13 && x <= 18) garment = '5c646e';
    if (!flight && y >= 29) garment = skinColor === '000000' ? '141618' : '5c646e';
    if (!flight && y === headBottom + 9 && x >= 11 && x <= 20) garment = '5c646e';
    const [dx, dy] = fromUpright(x, y, turnFor(frame));
    put(out, dx, dy, rgba(garment));
  }
  return out;
}
const uniformColors = {
  '240404': '1a1c1e', '450c0c': '7e8894', '701414': 'c6cdd4', 'a31d1d': 'dde4ec',
  '27272a': '1a1c1e', '52525b': '7e8894', 'a1a1aa': 'c6cdd4', 'd4d4d8': 'dde4ec',
};
function skirtUniform(targetFrame, female, royal) {
  const s = targetFrame.state;
  const sourceState = royal.states.find(t => t.name === s.name && t.moving === s.moving);
  assert(sourceState, `Missing uniform state ${s.name}/${s.moving}`);
  const sourceFrame = royal.frames[sourceState.start + Math.min(targetFrame.animation, sourceState.count - 1) * sourceState.dirs + Math.min(targetFrame.dir, sourceState.dirs - 1)];
  const src = uprightPixels(sourceFrame), out = Buffer.alloc(4096);
  const turn = turnFor(sourceFrame);
  let shift = 0;
  if (s.name === '' && !s.moving) {
    shift = firstRow(targetFrame.pixels) - firstRow(female.frames[s.start + targetFrame.dir].pixels);
  }
  // The source royal uniform already has an upper tunic and pleated overskirt.
  // Compress only the skirt depth: six source rows become four, with no boots.
  // Rotated knockback/KO poses are tailored in upright coordinates then restored.
  const sidewaysFlight = s.name === 'Flight' && targetFrame.dir >= 2;
  const foreshortenedFlight = s.name === 'Flight' && targetFrame.dir < 2;
  for (let y = 0; y < 32; y++) for (let x = 0; x < 32; x++) {
    if (!visible(src, x, y)) continue;
    let dy = y;
    if (!sidewaysFlight && !foreshortenedFlight) {
      if (y >= 29) continue;
      if (y >= 23) dy = 23 + Math.floor((y - 23) * 0.65);
    }
    const c = colorAt(src, x, y);
    const [ox, oy] = fromUpright(x, dy, turn);
    put(out, ox, oy + shift, rgba(uniformColors[c] || c));
  }
  // Join the original split panels into a continuous short A-line hem.
  if (!sidewaysFlight && !foreshortenedFlight) for (let y = 23; y <= 26; y++) {
    const xs = [];
    for (let x = 0; x < 32; x++) {
      const [ox, oy] = fromUpright(x, y, turn);
      if (visible(out, ox, oy + shift)) xs.push(x);
    }
    if (xs.length) for (let x = Math.min(...xs); x <= Math.max(...xs); x++) {
      const [ox, oy] = fromUpright(x, y, turn);
      if (!visible(out, ox, oy + shift)) put(out, ox, oy + shift, rgba(y === 26 ? '7e8894' : 'c6cdd4'));
    }
  }
  return out;
}
async function writeDmi(name, source, frames) {
  const { width, height } = source.info, pixels = Buffer.alloc(width * height * 4);
  frames.forEach((p, i) => {
    assert(p.some((value, j) => j % 4 === 3 && value), `${name}: empty frame ${i}`);
    for (let y = 0; y < 32; y++) p.copy(pixels, ((Math.floor(i / (width / 32)) * 32 + y) * width + i % (width / 32) * 32) * 4, y * 128, y * 128 + 128);
  });
  const png = await sharp(pixels, { raw: { width, height, channels: 4 } }).png().toBuffer();
  const metadata = pngChunk('zTXt', Buffer.concat([Buffer.from('Description\0\0'), zlib.deflateSync(source.description)]));
  const result = Buffer.concat([png.subarray(0, 33), metadata, png.subarray(33)]);
  const file = path.join(destination, `${name}.dmi`);
  fs.writeFileSync(file, result);
  const decoded = await readDmi(file);
  assert.equal(decoded.description, source.description);
  frames.forEach((p, i) => assert.deepEqual(decoded.frames[i].pixels, p));
  return { file: path.relative(root, file).replaceAll('\\', '/'), frames: frames.length, states: source.states.length,
    sha256: crypto.createHash('sha256').update(result).digest('hex'), metadataPreserved: true, allFramesNonempty: true };
}
async function pngFrame(pixels, scale) {
  return sharp(pixels, { raw: { width: 32, height: 32, channels: 4 } }).resize(32 * scale, 32 * scale, { kernel: 'nearest' }).png().toBuffer();
}
function over(base, overlay) {
  const result = Buffer.from(base);
  for (let i = 0; i < result.length; i += 4) if (overlay[i + 3]) overlay.copy(result, i, i, i + 4);
  return result;
}
async function preview(bulk, female, suit, uniform) {
  const width = 1296, height = 680, overlays = [];
  const jumpsuit = await readDmi(path.join(destination, 'ViltrumiteSoldierRobe.dmi'));
  const jumpsuitIdle = jumpsuit.states.find(s => s.name === '' && !s.moving);
  let svg = `<svg width="${width}" height="${height}"><style>text{font-family:Arial,sans-serif;fill:#edf2f7}</style><text x="28" y="38" font-size="24" font-weight="bold">Novos uniformes viltrumitas</text>`;
  const products = [{ body: 'Female', source: female, art: uniform, start: 0, label: 'Uniforme com saia curta sobre a jumpsuit' },
    { body: 'Bulk', source: bulk, art: suit, start: 16, label: 'Jumpsuit Bulk' }];
  for (let row = 0; row < 2; row++) {
    const p = products[row], top = 120 + row * 280;
    svg += `<text x="28" y="${top - 20}" font-size="20">${p.label}</text>`;
    for (let col = 0; col < 3; col++) {
      const tone = ['White', 'Tan', 'Black'][col];
      const skin = await readDmi(path.join(root, `src/Icons/PlayerIcons/BaseIcons/Viltrumite/Viltrumite${p.body}${tone}.dmi`));
      svg += `<text x="${28 + col * 424}" y="${top + 10}" font-size="15">${['Branco', 'Tan', 'Negro'][col]}</text>`;
      for (let dir = 0; dir < 4; dir++) {
        let dressed = skin.frames[p.start + dir].pixels;
        if (p.body === 'Female') dressed = over(dressed, jumpsuit.frames[jumpsuitIdle.start + dir].pixels);
        overlays.push({ input: await pngFrame(over(dressed, p.art[p.start + dir]), 3), left: 22 + col * 424 + dir * 96, top: top + 20 });
      }
    }
    const poses = ['Flight', 'Attack', 'KO', 'Meditate'].map(name => p.source.frames.find(f => f.state.name === name && f.dir === (name === 'Flight' ? 2 : 0)));
    svg += `<text x="28" y="${top + 158}" font-size="14">Voo / combate / queda / meditação</text>`;
    for (let i = 0; i < poses.length; i++) overlays.push({ input: await pngFrame(over(poses[i].pixels, p.art[poses[i].index]), 2), left: 375 + i * 120, top: top + 125 });
  }
  svg += '<text x="28" y="661" font-size="14">Camadas transparentes · 32×32 · Estados, direções e tempos preservados</text></svg>';
  overlays.push({ input: Buffer.from(svg), left: 0, top: 0 });
  await sharp({ create: { width, height, channels: 4, background: '#263342' } }).composite(overlays).png().toFile(path.join(artifacts, 'Preview.png'));
  for (const p of products) {
    const cols = 8, tile = 112, rows = Math.ceil(p.art.length / cols), layers = [];
    let labels = `<svg width="${cols * tile}" height="${rows * 128}"><style>text{font:10px monospace;fill:white}</style>`;
    for (const f of p.source.frames) {
      const x = f.index % cols * tile, y = Math.floor(f.index / cols) * 128;
      labels += `<text x="${x + 2}" y="${y + 12}">${f.index} ${f.state.name || (f.state.moving ? 'Walk' : 'Idle')} ${f.dir}/${f.animation}</text>`;
      layers.push({ input: await pngFrame(over(f.pixels, p.art[f.index]), 3), left: x, top: y + 20 });
    }
    labels += '</svg>'; layers.push({ input: Buffer.from(labels), left: 0, top: 0 });
    await sharp({ create: { width: cols * tile, height: rows * 128, channels: 4, background: '#526271' } }).composite(layers).png().toFile(path.join(artifacts, `${p.body}AllFrames.png`));
  }
}
async function main() {
  fs.mkdirSync(artifacts, { recursive: true });
  const bulk = await readDmi(path.join(originals, 'Bulk.dmi'));
  const female = await readDmi(path.join(originals, 'Female.dmi'));
  const royal = await readDmi(path.join(originals, 'RoyalRobe.dmi'));
  const suit = bulk.frames.map(bulkJumpsuit), uniform = female.frames.map(f => skirtUniform(f, female, royal));
  // Bulk tailoring must never add pixels beyond the body silhouette.
  suit.forEach((p, index) => { for (let i = 3; i < p.length; i += 4) assert(!p[i] || bulk.frames[index].pixels[i], `Bulk silhouette leak in frame ${index}`); });
  const results = [];
  results.push(await writeDmi('ViltrumiteBulkJumpsuit', bulk, suit));
  results.push(await writeDmi('ViltrumiteSkirtUniform', female, uniform));
  fs.writeFileSync(path.join(artifacts, 'Validation.json'), JSON.stringify({ bulkSilhouettePreserved: true, results }, null, 2) + '\n');
  await preview(bulk, female, suit, uniform);
  console.log(JSON.stringify(results, null, 2));
}
main().catch(e => { console.error(e); process.exitCode = 1; });
