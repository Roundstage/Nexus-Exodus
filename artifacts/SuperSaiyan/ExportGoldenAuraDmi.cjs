// Preserve the Aseprite pixels and attach BYOND animation metadata.
const fs = require('node:fs');
const path = require('node:path');
const source = fs.readFileSync(path.join(__dirname, 'GoldenAuraSheet.png'));
const output = path.resolve(__dirname, '../../src/Icons/Ki/GoldenAura.dmi');
function crc32(bytes) {
  let crc = 0xffffffff;
  for (const byte of bytes) {
    crc ^= byte;
    for (let bit = 0; bit < 8; bit++) crc = (crc >>> 1) ^ ((crc & 1) ? 0xedb88320 : 0);
  }
  return (crc ^ 0xffffffff) >>> 0;
}
if (source.readUInt32BE(16) !== 768 || source.readUInt32BE(20) !== 384) throw Error('Unexpected sheet dimensions');
const metadata = '# BEGIN DMI\nversion = 4.0\n\twidth = 96\n\theight = 128\nstate = ""\n\tdirs = 1\n\tframes = 24\n\tdelay = ' + Array(24).fill('0.5').join(',') + '\n\tloop = 0\n# END DMI\n';
const data = Buffer.from('Description\0' + metadata, 'latin1');
const type = Buffer.from('tEXt');
const chunk = Buffer.alloc(data.length + 12);
chunk.writeUInt32BE(data.length);
type.copy(chunk, 4); data.copy(chunk, 8);
chunk.writeUInt32BE(crc32(Buffer.concat([type, data])), data.length + 8);
const chunks = [source.subarray(0, 8)];
for (let offset = 8; offset < source.length;) {
  const length = source.readUInt32BE(offset);
  const kind = source.toString('ascii', offset + 4, offset + 8);
  if (kind !== 'tEXt' && kind !== 'zTXt' && kind !== 'iTXt') chunks.push(source.subarray(offset, offset + length + 12));
  if (kind === 'IHDR') chunks.push(chunk);
  offset += length + 12;
}
fs.writeFileSync(output, Buffer.concat(chunks));
console.log(output + ': 24 aura frames, 96x128, 1.2 second loop.');
