// Preserve the original; prepare a small PNG for the game's browser interfaces.
const fs = require('node:fs');
const path = require('node:path');
const { createHash } = require('node:crypto');
const sharp = require('sharp');
const root = path.resolve(__dirname, '../..');
const [id, source] = process.argv.slice(2);
const manifest = JSON.parse(fs.readFileSync(path.join(root, 'artifacts/SkillArtwork/Manifest.json'), 'utf8'));
const skill = manifest.skills.find(entry => entry.id === id);
if (!skill || !source) throw new Error('Known skill ID and generated PNG path required.');
(async () => {
  const original = path.join(root, skill.original);
  const asset = path.join(root, skill.asset);
  fs.mkdirSync(path.dirname(original), { recursive: true });
  fs.mkdirSync(path.dirname(asset), { recursive: true });
  const buffer = fs.readFileSync(source);
  const sha256 = createHash('sha256').update(buffer).digest('hex');
  if (fs.existsSync(original) && createHash('sha256').update(fs.readFileSync(original)).digest('hex') !== sha256) throw new Error('Existing original differs; keep revisions separate.');
  fs.writeFileSync(original, buffer);
  const metadata = await sharp(buffer).metadata();
  if (!metadata.width || metadata.width !== metadata.height) throw new Error(`${id}: expected a square image.`);
  await sharp(buffer).resize(128, 128, { kernel: 'lanczos3' }).png({ compressionLevel: 9 }).toFile(asset);
  const records = path.join(root, 'artifacts/SkillArtwork/Records');
  fs.mkdirSync(records, { recursive: true });
  const record = { id, original: skill.original, asset: skill.asset, originalWidth: metadata.width, originalHeight: metadata.height, sha256, promptSha256: createHash('sha256').update(skill.prompt).digest('hex'), approvedSample: skill.approvedSample };
  fs.writeFileSync(path.join(records, `${id}.json`), JSON.stringify(record, null, 2) + '\n');
  console.log(`${id}: original saved; 128 px interface PNG prepared.`);
})().catch(error => { console.error(error); process.exitCode = 1; });
