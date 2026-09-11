const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '../..');
const folder = path.join(root, 'artifacts/SkillArtwork');
const catalog = JSON.parse(fs.readFileSync(path.join(folder, 'Catalog.json'), 'utf8'));
const sample = JSON.parse(fs.readFileSync(path.join(root, 'artifacts/SkillArtSample/Prompts.json'), 'utf8'));
const excluded = new Map();
for (const type of ['/obj/Buff/Preset', '/obj/Buff/Ultimate', '/obj/KiWeaponTechnique', '/obj/Attacks', '/obj/Attacks/NexusStance', '/obj/Attacks/NexusMeleeTechnique', '/obj/Attacks/NexusMeleeTechnique/Viltrumite', '/obj/Attacks/NexusSpecialStyle', '/obj/Attacks/NexusSpecialStyle/ChargedProjectile', '/obj/Attacks/NexusAreaTechnique', '/obj/Attacks/RoleplayBeam', '/obj/MilestoneTechnique', '/obj/Ability', '/obj/Ability/Blast', '/obj/ArcaneSpell', '/obj/ArcaneSpell/Projectile']) excluded.set(type, 'Abstract or generic implementation parent, not a distinct player technique.');
for (const type of ['/obj/Ability/Blast/TestBlast', '/obj/NexusSmokeSkillAction', '/obj/Attacks/Noob_Ray']) excluded.set(type, 'Test or developer-only object.');
const controls = new Set(['/obj/Auto_Attack','/obj/Defend','/obj/Flash_Step','/obj/Evade','/obj/Injure','/obj/Grab','/obj/Manual_Attack','/obj/Lunge','/obj/Train','/obj/Meditate','/obj/Power_Up','/obj/Power_Down']);
const types = catalog.types.filter(item => {
  if (excluded.has(item.type)) return false;
  if (item.item) { excluded.set(item.type, 'Inventory item; retains its actual item sprite.'); return false; }
  if (!item.skill && !item.cost && !controls.has(item.type) && !['/obj/Goo_Trap','/obj/Body_Swap','/obj/Scrap_Absorb','/obj/Vampire_Bite'].includes(item.type)) {
    excluded.set(item.type, 'Interface command or utility proxy, not a skill.'); return false;
  }
  return true;
});
for (const node of catalog.nodes) {
  if (node.kind === 'skill' && !excluded.has(node.type) && !types.some(item => item.type === node.type)) types.push({ type: node.type, name: node.name, description: node.description, category: node.branch, skill: 1 });
}
const subjectsPath = path.join(__dirname, 'VisualBriefs.json');
const subjects = fs.existsSync(subjectsPath) ? JSON.parse(fs.readFileSync(subjectsPath, 'utf8')) : {};
for (const [type, name, description] of [
  ['/mob/verb/Transform', 'Transform', 'Choose and enter an available primary racial transformation.'],
  ['/mob/verb/Revert_Transformation', 'Revert Transformation', 'Return from the active primary transformation to the base form.'],
  ['/mob/Bio_Android/verb/Revert_to_Larval_Form', 'Larval Form', 'Revert a Bio-Android to its larval form.']
]) types.push({ type, name, description, category: 'Transformation', skill: 1 });
const style = sample.skills[0].prompt.split('\nAbility:')[0];
const seen = new Set();
const skills = types.map(item => {
  const approved = sample.skills.find(entry => entry.type === item.type);
  let id = approved?.id || item.type.split('/').at(-1).split('_').map(word => word.slice(0,1).toUpperCase() + word.slice(1)).join('');
  if (item.type.startsWith('/obj/Buff/Preset/')) id = 'Buff' + id;
  if (item.type.startsWith('/obj/Buff/Ultimate/')) id = 'Ultimate' + id;
  if (item.type.startsWith('/obj/MilestoneTechnique/')) id = 'Milestone' + id;
  if (seen.has(id)) throw new Error(`Duplicate artwork ID: ${id}`);
  seen.add(id);
  const nodes = catalog.nodes.filter(node => node.type === item.type);
  const primary = nodes.find(node => node.category === 'Combat') || nodes.find(node => node.category === 'Racial') || nodes[0];
  const description = approved?.description || item.description || primary?.description || '';
  const name = approved?.name || item.name.replace(/([a-z])([A-Z])/g, '$1 $2');
  const category = item.type.startsWith('/obj/Arcane') ? 'Magic' : item.type.includes('/Viltrumite') ? 'Viltrumite' : item.type.startsWith('/obj/Milestone') ? 'Milestones' : primary?.category === 'Combat' ? primary.branch : item.category || 'Ability';
  const brief = subjects[id];
  const subject = approved?.subject || brief?.subject || '';
  const artDescription = brief?.description || description;
  return { id, type: item.type, name, category, description, artDescription, subject, approvedSample: !!approved,
    prompt: approved?.prompt || `${style}\nAbility: ${name}.\nGameplay description (reference only; do not write it): ${artDescription}\nSubject: ${subject}\nKeep the large focal silhouette unmistakable and visually different from other abilities.`,
    original: `artifacts/SkillArtwork/Originals/${id}.png`, asset: `src/Icons/UI/SkillArtwork/${id}.png`, nodes: nodes.map(node => node.id) };
});
const manifest = { generator: 'Built-in image_gen, one image per skill', style: 'User-approved SkillArtSample', skills, excluded: [...excluded].map(([type, reason]) => ({ type, reason })) };
fs.writeFileSync(path.join(folder, 'Manifest.json'), JSON.stringify(manifest, null, 2) + '\n');
console.log(`${skills.length} unique skill artworks (${skills.filter(skill => skill.approvedSample).length} approved samples reused).`);
console.log('Missing visual briefs: ' + skills.filter(skill => !skill.subject).map(skill => skill.id).join(', '));
