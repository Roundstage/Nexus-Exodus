// Recolor indexed DMI palettes without touching pixel indices or BYOND metadata.
// Run: node tools/RecolorViltrumiteSkins.cjs [--preview]
// Optional preview requires sharp (available in the bundled Codex Node runtime).
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const zlib = require('node:zlib');
const crypto = require('node:crypto');

const root = path.resolve(__dirname, '..');
const sourceDir = path.join(root, 'ArtSource/Viltrumite/Originals');
const outputDir = path.join(root, 'src/Icons/PlayerIcons/BaseIcons/Viltrumite');
const proofDir = path.join(root, 'artifacts/ViltrumiteSkins');
const tones = ['White', 'Tan', 'Black'];
const bodies = ['Male', 'Female', 'Bulk'];
// Light to dark; keep every original shading step, including deep skin shadows.
const skin = {
  Female: ['ffe2c7', 'f7c5ae', 'efa895', 'e79886', 'df8877', 'b86b5e', '5f312c'],
  Bulk: ['ffe2c7', 'f7c5ae', 'efa895', 'e79886', 'df8877', 'b86b5e', '904e44'],
  Male: ['ffe2c7', 'f7c5ae', 'efa895', 'e79886', 'df8877', 'b86b5e', '904e44', '5f312c'],
};
const targetSkin = {
  Female: {
    Tan: ['edc59f', 'dfac8b', 'ce9273', 'c08365', 'b47659', '985d49', '4f2b26'],
    Black: ['b5805e', '9e6849', '885638', '77472f', '683c29', '512e23', '301b19'],
  },
  Bulk: {
    Tan: ['edc59f', 'dfac8b', 'ce9273', 'c08365', 'b47659', '985d49', '744235'],
    Black: ['b5805e', '9e6849', '885638', '77472f', '683c29', '512e23', '3f231d'],
  },
  Male: {
    Tan: ['edc59f', 'dfac8b', 'ce9273', 'c08365', 'b47659', '985d49', '744235', '4f2b26'],
    Black: ['b5805e', '9e6849', '885638', '77472f', '683c29', '512e23', '3f231d', '301b19'],
  },
};
// These palette entries belong to irises, never to outlines, sclera or clothing.
// The supplied Male base has two brown iris shades; keep black outlines intact.
const eyes = {
  Male: { '663300': '0000cc', '996600': '0099ff' },
  Female: { '4c3325': '0000cc', '392920': '0099ff' },
  Bulk: { '330000': '0000cc', '663300': '0099ff' },
};

function crc32(bytes) {
  let crc = 0xffffffff;
  for (const byte of bytes) {
    crc ^= byte;
    for (let bit = 0; bit < 8; bit++) crc = (crc >>> 1) ^ ((crc & 1) ? 0xedb88320 : 0);
  }
  return (crc ^ 0xffffffff) >>> 0;
}

function chunks(bytes) {
  assert.equal(bytes.subarray(0, 8).toString('hex'), '89504e470d0a1a0a');
  const result = [];
  for (let offset = 8; offset < bytes.length;) {
    const length = bytes.readUInt32BE(offset);
    const type = bytes.toString('ascii', offset + 4, offset + 8);
    const raw = bytes.subarray(offset, offset + length + 12);
    assert.equal(raw.length, length + 12, 'Truncated PNG chunk');
    assert.equal(crc32(raw.subarray(4, length + 8)), raw.readUInt32BE(length + 8), `${type} CRC`);
    result.push({ type, raw, data: raw.subarray(8, length + 8) });
    offset += raw.length;
  }
  return result;
}

function description(parts) {
  const chunk = parts.find(p => p.type === 'zTXt' && p.data.subarray(0, 11).toString() === 'Description');
  assert(chunk, 'Missing DMI Description');
  return zlib.inflateSync(chunk.data.subarray(13)).toString('utf8');
}

function exportVariant(body, tone) {
  const source = fs.readFileSync(path.join(sourceDir, `${body}.dmi`));
  const original = chunks(source);
  const header = original.find(c => c.type === 'IHDR').data;
  assert.equal(header[9], 3, 'Expected indexed PNG');
  const paletteChunk = original.find(c => c.type === 'PLTE');
  const palette = Buffer.from(paletteChunk.data);
  const alpha = original.find(c => c.type === 'tRNS').data;
  const mapping = { ...eyes[body] };
  if (tone !== 'White') skin[body].forEach((color, i) => { mapping[color] = targetSkin[body][tone][i]; });
  const found = new Set();
  for (let i = 0; i < palette.length; i += 3) {
    const color = palette.subarray(i, i + 3).toString('hex');
    // A duplicate color in the transparent slot must stay transparent and unchanged.
    if (mapping[color] && alpha[i / 3] !== 0) {
      Buffer.from(mapping[color], 'hex').copy(palette, i);
      found.add(color);
    }
  }
  assert.deepEqual([...found].sort(), Object.keys(mapping).sort(), `${body}: missing palette entries`);
  const replacement = Buffer.from(paletteChunk.raw);
  palette.copy(replacement, 8);
  replacement.writeUInt32BE(crc32(replacement.subarray(4, replacement.length - 4)), replacement.length - 4);
  const result = Buffer.concat([source.subarray(0, 8), ...original.map(c => c.type === 'PLTE' ? replacement : c.raw)]);
  const generated = chunks(result);
  original.forEach((chunk, i) => {
    if (chunk.type !== 'PLTE') assert.deepEqual(generated[i].raw, chunk.raw, `${body}/${tone}: changed ${chunk.type}`);
  });
  const metadata = description(generated);
  const stateCount = (metadata.match(/^state = /gm) || []).length;
  let frameCount = 0;
  for (const state of metadata.split(/^state = /m).slice(1)) {
    frameCount += Number(state.match(/dirs = (\d+)/)[1]) * Number(state.match(/frames = (\d+)/)[1]);
  }
  const name = `Viltrumite${body}${tone}.dmi`;
  fs.writeFileSync(path.join(outputDir, name), result);
  return { name, body, tone, sourceSha256: crypto.createHash('sha256').update(source).digest('hex'),
    sha256: crypto.createHash('sha256').update(result).digest('hex'), stateCount, frameCount,
    sheet: [header.readUInt32BE(0), header.readUInt32BE(4)], paletteChanges: mapping,
    unchangedPixelIndices: true, unchangedTransparency: true, unchangedDmiMetadata: true };
}

async function renderPreview() {
  const sharp = require('sharp');
  const width = 1256, height = 720;
  const overlays = [];
  const labels = ['Masculino', 'Feminino', 'Gordo'];
  let svg = `<svg width="${width}" height="${height}"><style>text{font-family:Arial,sans-serif;fill:#eef2f8}</style><text x="28" y="38" font-size="25" font-weight="bold">Viltrumitas · olhos azuis</text>`;
  tones.forEach((tone, col) => {
    svg += `<text x="${165 + col * 360}" y="77" font-size="19">${['Branco', 'Tan', 'Dark'][col]}</text>`;
  });
  for (let row = 0; row < bodies.length; row++) {
    const body = bodies[row];
    svg += `<text x="28" y="${159 + row * 195}" font-size="18">${labels[row]}</text>`;
    for (let col = 0; col < tones.length; col++) {
      const file = path.join(outputDir, `Viltrumite${body}${tones[col]}.dmi`);
      const metadata = await sharp(file).metadata();
      // DMI ordering differs between sources: locate the stationary idle state.
      let start = 0, idleFound = false;
      for (const state of description(chunks(fs.readFileSync(file))).split(/^state = /m).slice(1)) {
        if (state.startsWith('""') && !/movement = 1/.test(state)) { idleFound = true; break; }
        start += Number(state.match(/dirs = (\d+)/)[1]) * Number(state.match(/frames = (\d+)/)[1]);
      }
      assert(idleFound, `${body}: missing stationary idle state`);
      for (let dir = 0; dir < 4; dir++) {
        const frame = start + dir;
        const tile = await sharp(file).extract({ left: (frame % (metadata.width / 32)) * 32,
          top: Math.floor(frame / (metadata.width / 32)) * 32, width: 32, height: 32 })
          .resize(80, 80, { kernel: 'nearest' }).png().toBuffer();
        overlays.push({ input: tile, left: 162 + col * 360 + dir * 80, top: 102 + row * 195 });
      }
      const frame = start;
      const face = await sharp(file).extract({ left: (frame % (metadata.width / 32)) * 32 + 9,
        top: Math.floor(frame / (metadata.width / 32)) * 32 + 6, width: 14, height: 12 })
        .resize(84, 72, { kernel: 'nearest' }).png().toBuffer();
      overlays.push({ input: face, left: 260 + col * 360, top: 192 + row * 195 });
    }
  }
  svg += '<text x="28" y="701" font-size="14" fill="#b8c4d4">Frames 32×32 · Direções: sul, norte, leste, oeste · Detalhe do rosto abaixo</text></svg>';
  overlays.unshift({ input: Buffer.from(svg), left: 0, top: 0 });
  const preview = await sharp({ create: { width, height, channels: 4, background: '#263342' } })
    .composite(overlays).png().toBuffer();
  fs.writeFileSync(path.join(proofDir, 'Preview.png'), preview);
  await sharp(preview).extract({ left: 0, top: 0, width, height: 286 }).png().toFile(path.join(proofDir, 'MalePreview.png'));
}

async function main() {
  fs.mkdirSync(outputDir, { recursive: true });
  fs.mkdirSync(proofDir, { recursive: true });
  const variants = bodies.flatMap(body => tones.map(tone => exportVariant(body, tone)));
  fs.writeFileSync(path.join(proofDir, 'Validation.json'), JSON.stringify({ variants }, null, 2) + '\n');
  if (process.argv.includes('--preview')) await renderPreview();
  console.log(`Validated ${variants.length} DMI variants: only PLTE colors changed; all image data, alpha, states, directions, delays and hotspots preserved.`);
}
main().catch(error => { console.error(error); process.exitCode = 1; });
