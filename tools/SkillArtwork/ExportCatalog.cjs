// Read compiled DM defaults from a disposable, mapless environment.
// Never starts the real world or modifies its source, maps, or saves.
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const cp = require('node:child_process');
const root = path.resolve(__dirname, '../..');
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'Nexus-SkillArtwork-'));
const byond = path.join(os.tmpdir(), 'Nexus-Exodus-BYOND-516.1686/byond');
fs.symlinkSync(path.join(root, 'src'), path.join(scratch, 'src'), 'junction');
let environment = fs.readFileSync(path.join(root, 'DU.dme'), 'utf8');
environment = environment.replace(/^#include "[^"\r\n]+\.dmm".*$/gm, '');
environment = environment.replace(/#include "src[\\/]Code[\\/]CoreFunctions[\\/]MainWorld.dm"/, '#include "ExportWorld.dm"');
environment = environment.replace(/#include "(?!src[\\/])([^"\r\n]+)"/g, (match, file) => {
  if (file === 'ExportWorld.dm') return match;
  const source = path.join(root, file);
  if (fs.existsSync(source)) fs.copyFileSync(source, path.join(scratch, file));
  return match;
});
const mainWorld = fs.readFileSync(path.join(root, 'src/Code/CoreFunctions/MainWorld.dm'), 'utf8')
  .replace('\tNew()', '\tproc/skillArtworkOriginalWorldNew()')
  .replace(/(hub_password\s*=).*/, '$1 ""').replace(/(hub\s*=).*/, '$1 ""');
fs.writeFileSync(path.join(scratch, 'ExportWorld.dm'), mainWorld);
fs.writeFileSync(path.join(scratch, 'ExportCatalog.dm'), `world/New()
\tspawn(0)
\t\tinitializeProgressionTreeCatalog()
\t\tvar/list/output = list()
\t\tvar/list/skill_types = list()
\t\tfor(var/skill_type in typesof(/obj))
\t\t\tif(!initial(skill_type:Skill) && !initial(skill_type:can_hotbar) && !initial(skill_type:Cost_To_Learn)) continue
\t\t\tvar/list/entry = list("type" = "[skill_type]", "name" = initial(skill_type:name), "description" = initial(skill_type:desc), "skill" = initial(skill_type:Skill), "hotbar" = initial(skill_type:can_hotbar), "category" = initial(skill_type:hotbar_type), "cost" = initial(skill_type:Cost_To_Learn), "illegal" = (skill_type in Illegal_learnables), "item" = ispath(skill_type, /obj/items), "verbs" = initial(skill_type:verbs))
\t\t\tskill_types += list(entry)
\t\toutput["types"] = skill_types
\t\tvar/list/nodes = list()
\t\tfor(var/node_id in progression_node_catalog)
\t\t\tvar/datum/ProgressionNode/node = progression_node_catalog[node_id]
\t\t\tif(node.reward_kind != "skill" && node.reward_kind != "magic") continue
\t\t\tnodes += list(list("id" = node.id, "name" = node.name, "description" = node.description, "category" = node.category, "branch" = node.branch, "type" = "[node.reward_type]", "kind" = node.reward_kind))
\t\toutput["nodes"] = nodes
\t\ttext2file(json_encode(output), "Catalog.json")
\t\tworld.log << "SKILL_ARTWORK_CATALOG_EXPORTED"
\t\tshutdown()
`);
fs.writeFileSync(path.join(scratch, 'Catalog.dme'), environment + '\n#include "ExportCatalog.dm"\n');
const env = { ...process.env, BYOND_SYSTEM: byond, __COMPAT_LAYER: 'RunAsInvoker' };
const compile = cp.spawnSync(path.join(byond, 'bin/dm.exe'), ['Catalog.dme'], { cwd: scratch, env, encoding: 'utf8', windowsHide: true, timeout: 180000 });
process.stdout.write(compile.stdout || ''); process.stderr.write(compile.stderr || '');
if (compile.status !== 0) throw new Error(`Catalog compile failed (${scratch}).`);
const run = cp.spawnSync(path.join(byond, 'bin/dd.exe'), ['Catalog.dmb', '-safe', '-invisible', '-log', 'Export.log'], { cwd: scratch, env, encoding: 'utf8', windowsHide: true, timeout: 60000 });
process.stdout.write(run.stdout || ''); process.stderr.write(run.stderr || '');
if (!fs.existsSync(path.join(scratch, 'Catalog.json'))) throw new Error(`Catalog export failed (${scratch}).`);
const destination = path.join(root, 'artifacts/SkillArtwork');
fs.mkdirSync(destination, { recursive: true });
fs.copyFileSync(path.join(scratch, 'Catalog.json'), path.join(destination, 'Catalog.json'));
console.log(`Exported catalog to ${destination}; temporary fixture: ${scratch}`);
