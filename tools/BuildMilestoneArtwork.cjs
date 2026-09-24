// Small, authored vector emblems, rasterized for BYOND's icon/resource pipeline.
// Run with the same NEXUS_PLAYWRIGHT_MODULE / NEXUS_BROWSER_EXECUTABLE as TestMilestoneShop.
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
let playwright;
for (const candidate of [process.env.NEXUS_PLAYWRIGHT_MODULE, 'playwright', path.join(root, '.codex-tmp/balance-workbook/node_modules/playwright')].filter(Boolean)) {
  try { playwright = require(candidate); break; } catch (error) { if (error.code !== 'MODULE_NOT_FOUND') throw error; }
}
if (!playwright) throw new Error('Install playwright or set NEXUS_PLAYWRIGHT_MODULE.');
const line = d => `<path d="${d}"/>`;
const circle = (x, y, r) => `<circle cx="${x}" cy="${y}" r="${r}"/>`;
const group = (transform, content) => `<g transform="${transform}">${content}</g>`;
const fill = d => `<path d="${d}" fill="currentColor" fill-opacity=".18"/>`;
const spark = line('M0 -5V5M-5 0H5');
const shield = fill('M32 12L48 18V31Q48 43 32 52Q16 43 16 31V18Z');
const flame = fill('M32 10C36 22 46 24 44 38C43 48 35 52 27 48C17 44 17 33 23 25L26 34C33 27 27 20 32 10Z');
const fist = fill('M19 43L15 32V23Q15 19 19 19H23V17Q23 13 27 15L29 17Q31 13 35 16L37 19Q42 16 45 21L48 29L43 43ZM20 43V50H41V43M23 20V28M30 19V27M37 21V28M18 32H30L36 36');
const sword = fill('M21 39L43 13L51 11L50 20L26 43ZM17 36L30 47M21 43L14 51');
const target = circle(32, 32, 18) + circle(32, 32, 10) + circle(32, 32, 2);
const book = fill('M32 21Q20 13 12 19V47Q22 42 32 49Q42 42 52 47V19Q43 13 32 21ZM32 22V48');
const bolt = fill('M35 10L19 34H30L26 54L46 28H34Z');
const heart = fill('M32 49L16 34C5 21 23 11 32 23C41 11 59 21 48 34Z');
const arrow = line('M12 33H49M40 24L49 33L40 42');
const gem = fill('M32 12L48 26L42 46L23 51L15 30ZM15 30L32 34L48 26M32 12V34L23 51M32 34L42 46');
const pick = line('M20 49L41 21M13 22Q32 9 50 27M23 19L44 34');
const hammer = fill('M14 16L21 10L40 25L33 34ZM30 31L42 50L48 46L36 27');
const colors = { Resolve: '#eca29b', Combat: '#eea36f', 'Martial Arts': '#e4bd82', Weapon: '#d6c4a6', Ki: '#83cfe3', Survival: '#9ac5aa', Fire: '#f0a267', Growth: '#accb82', Culture: '#cbb5e7', Scholarship: '#94cbc7', Craft: '#e0b283', Builds: '#e4c275' };
const drawings = {
  iron_will: shield + line('M29 23H35M32 23V39M29 39H35'),
  will_of_fire: group('translate(8 8) scale(.75)', shield) + group('translate(14 9) scale(.58)', flame),
  steadfast_spirit: heart + line('M12 34H23L27 28L32 39L37 30L41 34H53'),
  rapid_recovery: line('M15 22A22 22 0 1 1 11 38M15 12V23H5M25 33H41M33 25V41'),
  rapid_deployment: group('translate(5 0)', arrow) + line('M10 21H28M7 44H26M7 33H13'),
  controlled_fury: group('translate(4 6) scale(.8)', flame) + line('M12 17V10H22M42 10H52V20M52 43V53H42M22 53H12V44'),
  unarmed_mastery: fist,
  deft_hands: line('M23 47L13 33Q12 28 16 28L23 33V18Q23 12 27 17V29V12Q31 7 32 13V29V15Q36 10 37 16V30V21Q41 16 42 22V38L37 48Z') + group('translate(50 16)', spark),
  one_two_punch: group('translate(3 12) scale(.6)', fist) + group('translate(22 0) scale(.68)', fist),
  burning_fists: group('translate(6 -2) scale(.8)', flame) + group('translate(10 22) scale(.65)', fist),
  way_of_the_fist: circle(32, 32, 23) + group('translate(7 6) scale(.78)', fist),
  way_of_the_open_palm: line('M25 49L15 35Q13 29 18 29L25 35V20Q25 14 29 19V29V13Q33 8 34 14V29V17Q38 11 39 18V30V23Q43 17 44 24V40L38 49Z') + line('M10 20L15 23M17 10L21 16M46 11L43 16M51 23L56 21'),
  weapon_training: sword,
  swordsman: sword + group('translate(64 0) scale(-1 1)', sword),
  bleeding_edge: group('translate(-3 -4)', sword) + fill('M45 34C45 34 38 43 38 47A7 7 0 0 0 52 47C52 42 45 34 45 34Z'),
  thundering_blows: group('translate(-5 3) scale(.85)', hammer) + group('translate(26 -1) scale(.65)', bolt),
  exploit_weakness: group('translate(5 3) scale(.88)', shield) + line('M34 17L28 29L37 34L28 46M9 29L23 35L11 39'),
  ki_manipulation: circle(32, 29, 10) + line('M22 16Q34 9 43 20M19 44L13 35L10 39L18 52H44L53 39L49 35L42 44M24 29H40M32 21V37'),
  bulls_eye: target + line('M32 9V19M32 45V55M9 32H19M45 32H55'),
  energy_marksmanship: group('translate(14 0) scale(.85)', target) + line('M9 51L40 25M30 26L40 25L37 35M9 39L18 32'),
  forceful_negotiator: circle(42, 31, 11) + line('M9 20L29 24M7 31H29M9 43L29 38M53 15L57 11M54 46L58 50'),
  concentrated_fire: target + line('M7 10L24 24M7 10L8 18M57 10L40 24M57 10L56 18M32 56V40'),
  this_drill_will_pierce_the_heavens: fill('M32 9L16 44H48ZM25 24L38 28M20 34L43 38') + line('M22 49V54M32 49V58M42 49V54M12 17L17 22M52 17L47 22'),
  turtle_shell: fill('M18 20L29 15L42 20L47 33L41 46L27 50L17 43L13 30ZM29 15L27 26L37 31L47 33M27 26L19 35L17 43M19 35L30 40L41 46M30 40L37 31M11 19L16 23M44 16L42 21M12 47L18 42M44 49L40 44M25 52V56'),
  sturdy_build: shield + line('M23 26H41M23 35H41M28 20V26M36 26V35M28 35V44'),
  desperate_struggle: heart + group('translate(17 9) scale(.5)', bolt) + line('M10 46L15 42M50 42L55 46'),
  challengers_mark: shield + group('translate(12 8) scale(.62)', target),
  venomous_intent: fill('M32 10C32 10 17 28 17 38A15 15 0 0 0 47 38C47 28 32 10 32 10Z') + line('M26 32L29 35M38 32L35 35M26 42Q32 47 38 42'),
  crushing_resolve: shield + line('M34 14L28 27L38 33L27 49M8 26L13 30M51 30L56 26'),
  salt_of_the_earth: group('translate(10 -1) scale(.67)', flame) + fill('M10 50L18 40L27 45L37 39L54 50Z') + line('M18 55H47'),
  fire_lord: group('translate(7 10) scale(.78)', flame) + fill('M17 12L24 18L32 9L40 18L48 12L44 25H21Z'),
  smolder: group('translate(8 21) scale(.5)', flame) + line('M26 29Q19 23 27 18Q34 12 28 7M39 33Q33 27 42 22Q49 18 43 12M15 53H49'),
  roleplay_scholar: group('translate(1 16) scale(.72)', book) + fill('M25 10H52V26H39L31 32V26H25Z') + line('M31 16H45M31 21H40'),
  patient_growth: circle(32, 32, 21) + line('M32 17V32L42 38M16 50L21 46') + fill('M26 45Q19 33 13 36Q11 45 26 45Z'),
  arcane_memory: group('translate(2 11) scale(.94)', book) + group('translate(32 14)', spark) + circle(32, 14, 9),
  language_savant: fill('M10 13H40V33H24L16 41V33H10ZM45 24H54V47H45L37 54V47H29V39') + line('M16 21H33M16 27H27M37 32H47M37 39H46'),
  custom_language: fill('M10 14H46V39H28L17 50V39H10Z') + line('M19 30L25 21L31 30M21 27H29M37 47L49 33L53 37L41 51L36 52Z'),
  scientific_method: fill('M24 12H40M27 12V27L15 47Q14 51 20 51H45Q51 51 48 46L37 27V12M21 38H43') + circle(29, 43, 2) + circle(36, 34, 2),
  liberal_arts: fill('M8 24L32 13L56 24L32 35ZM18 30V42Q32 51 46 42V30M54 25V42') + line('M25 52H40'),
  profession_specialist: group('translate(-1 5) scale(.8)', pick) + group('translate(20 4) scale(.78)', hammer),
  mining_expert: group('translate(-3 -4) scale(.94)', pick) + group('translate(27 28) scale(.5)', gem),
  ore_whisperer: group('translate(1 5) scale(.85)', gem) + line('M44 14Q60 25 47 40M44 23Q50 29 45 34'),
  master_blacksmith: fill('M11 36H53L46 43H38V49H45V54H19V49H26V43H19Z') + group('translate(13 0) scale(.55)', hammer) + group('translate(49 20)', spark),
  versatile_training: line('M13 28V39M20 24V43M20 33H44M44 24V43M51 28V39') + group('translate(32 13)', spark) + line('M22 51H42'),
  momentum_damage: group('translate(14 0) scale(.88)', bolt) + line('M9 20H26M7 32H20M10 45H22'),
  precision_damage: circle(32, 32, 20) + circle(32, 32, 10) + line('M12 52L42 22M33 22H42V31'),
  fortified_damage: shield + group('translate(19 14) scale(.42)', sword),
  sweeping_impact: line('M9 27Q32 6 55 27M13 35Q32 18 51 35M20 44L32 33L44 44M32 33V54') + circle(12, 27, 2) + circle(52, 27, 2),
  echoing_assault: group('translate(9 12) scale(.65)', fist) + line('M43 17Q55 30 43 44M50 11Q67 30 50 50M11 18H19M7 26H14'),
  keen_edge: group('translate(-3 5) scale(.88)', sword) + group('translate(46 17)', spark) + line('M41 33L47 29'),
  unencumbered_combatant: circle(34, 15, 5) + line('M31 23L25 35L16 31M31 23L40 30L49 27M26 33L38 41L46 50M27 34L20 44L10 45M7 20H19M7 26H16'),
};
const catalog = fs.readFileSync(path.join(root, 'src/Code/PlayerMechanics/Milestones.dm'), 'utf8');
const entries = [...catalog.matchAll(/milestone_catalog\["([^"]+)"\] = new \/datum\/MilestoneDefinition\("[^"]+", "([^"]+)", "[^"]+", \d+, \d+, "([^"]+)"/g)].map(([, id, name, category]) => ({ id, name, category }));
assert.deepEqual(Object.keys(drawings).sort(), entries.map(entry => entry.id).sort(), 'Every live Milestone must have its own authored emblem.');
assert.equal(new Set(Object.values(drawings)).size, entries.length, 'Milestone emblems must be distinct.');
const size = 96, columns = 7, rows = Math.ceil(entries.length / columns);
const cells = entries.map((entry, index) => `<svg x="${index % columns * size}" y="${Math.floor(index / columns) * size}" width="${size}" height="${size}" viewBox="0 0 64 64"><title>${entry.name}</title><rect x="1" y="1" width="62" height="62" rx="6" fill="#201a14" stroke="#8b6c42"/><rect x="4" y="4" width="56" height="56" rx="4" fill="#292219" stroke="#443724"/><g color="${colors[entry.category]}" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">${drawings[entry.id]}</g></svg>`).join('\n');
const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${columns * size}" height="${rows * size}">${cells}</svg>`;
const sourceDir = path.join(root, 'ArtSource/Milestones');
const outputDir = path.join(root, 'src/Images/Milestones');
async function main() {
  fs.mkdirSync(sourceDir, { recursive: true });
  fs.mkdirSync(outputDir, { recursive: true });
  fs.writeFileSync(path.join(sourceDir, 'MilestoneIcons.svg'), svg + '\n');
  fs.writeFileSync(path.join(outputDir, 'MilestoneIcons.json'), JSON.stringify({ size, columns, ids: entries.map(entry => entry.id) }, null, 2) + '\n');
  const browser = await playwright.chromium.launch({ executablePath: process.env.NEXUS_BROWSER_EXECUTABLE || (process.platform === 'win32' ? 'C:/Program Files/Google/Chrome/Application/chrome.exe' : undefined), headless: true });
  try {
    const page = await browser.newPage({ viewport: { width: columns * size, height: rows * size }, deviceScaleFactor: 1 });
    await page.setContent(`<style>html,body{margin:0;background:transparent}svg{display:block}</style>${svg}`);
    await page.screenshot({ path: path.join(outputDir, 'MilestoneIcons.png'), omitBackground: true });
  } finally { await browser.close(); }
  console.log(`Built ${entries.length} distinct Milestone icons (${size}px), source SVG, PNG atlas and runtime index.`);
}
main().catch(error => { console.error(error); process.exitCode = 1; });
