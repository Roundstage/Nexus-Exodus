// Create a disposable native-client fixture. Never changes the live world's login or saves.
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const cp = require('node:child_process');
const root = path.resolve(__dirname, '..');
const target = fs.mkdtempSync(path.join(os.tmpdir(), 'Nexus-ClassicPreview-'));
const files = cp.execFileSync('git', ['-c', 'core.quotepath=false', 'ls-files', '--cached', '--others', '--exclude-standard'], { cwd: root, encoding: 'utf8' }).trim().split(/\r?\n/);
for (const relative of new Set(files)) {
  if (relative.startsWith('data/') || relative.startsWith('artifacts/')) continue;
  const source = path.join(root, relative); if (!fs.existsSync(source) || !fs.statSync(source).isFile()) continue;
  const dest = path.join(target, relative); fs.mkdirSync(path.dirname(dest), { recursive: true }); fs.copyFileSync(source, dest);
}
function change(relative, transform) { const file = path.join(target, relative); fs.writeFileSync(file, transform(fs.readFileSync(file, 'utf8').replace(/\r\n/g, '\n'))); }
change('src/Code/UI/UIStuff.dm', s => s.replace('client/New()', 'client/proc/previewOriginalNew()').replace('\t. = ..()\n\t// The legacy Bars', '\t. = TRUE\n\t// The legacy Bars'));
change('src/Code/CoreFunctions/MainWorld.dm', s => s.replace('mob/Login()', 'mob/proc/previewOriginalLogin()'));
change('src/Code/UI/ClassicHud.dm', s => s.replace('var/action = href_list["action"]', 'var/action = href_list["action"]\n\t\tworld.log << "CLASSIC_PREVIEW action=[action] widget=[id] value=[href_list["value"]]"'));
// Prevent client account exports while manipulating disposable fixture preferences.
change('src/Code/UI/SavePlayerSettings.dm', s => s.replace('save_player_settings()\n', 'save_player_settings()\n\t\treturn\n'));
const fixture = `
client/New()
\t. = ..()
\tmob = new /mob/ClassicHudPreview
\tstatobj = mob
\teye = mob
\tshow_verb_panel = TRUE
\tshow_map = TRUE
\tclients |= src
\tspawn(10) mob.prepareClassicPreview()

mob/ClassicHudPreview
\tLogin()
\t\treturn

mob/proc/prepareClassicPreview()
\tplayerCharacter = TRUE
\tname = "HUD Preview"
\ticon = 'src/Icons/PlayerIcons/BaseIcons/ExGenesisHumans/NewTanMale.dmi'
\tSENSE_SYSTEM_SHOW_STAT_BUILD = TRUE
\tRace = "Human"
\tBP = 10000
\tbase_bp = 10000
\tmax_ki = 3000
\tKi = 2600
\tHealth = 90
\tloc = locate(100,100,1)
\tcurrent_area = get_area()
\tplayers |= src
\tcurrent_area.mob_list |= src
\tcurrent_area.player_list |= src
\tnexus_interface_layout = "overlay"
\tnew /obj/Sense(src)
\tnew /obj/Advanced_Sense(src)
\tnew /obj/Sense3(src)
\tnew /obj/RockThrow(src)
\tnew /obj/PressurePunch(src)
\tnew /obj/Attacks/NexusMeleeTechnique/Slice(src)
\tnew /obj/Giant_Form(src)
\tvar/obj/Keep_Body/support = new(src)
\tsupport.next_use = world.realtime + 900
\tvar/mob/target = new /mob/ClassicHudPreview(locate(103,100,1))
\ttarget.name = "Training rival"
\ttarget.icon = icon
\ttarget.Race = "Human"
\ttarget.BP = 12000
\ttarget.base_bp = 12000
\ttarget.max_ki = 3000
\ttarget.Ki = 2400
\ttarget.Health = 82
\ttarget.current_area = current_area
\tcurrent_area.mob_list |= target
\tcurrent_area.player_list |= target
\tTarget = target
\tselected_target = target
\tlast_logon = world.time - 100
\tclient.view = "31x21"
\twinset(src,"mainwindow","title='Classic HUD native preview';is-visible=true;is-maximized=true")
\twinset(src,"mainwindow.helpAlert","is-visible=false")
\tinitializeNexusChatHud()
\tinitializeActionHud()
\tinitializeNexusHotkeys()
\tvar/obj/PressurePunch/punch = locate() in src
\tbindNexusHotkey("1", list("kind" = "slot", "slot" = 1))
\tnexus_classic_slots = null
\tinitializeClassicSlots()
\tnexus_classic_slots[1] = classicBindingForObject(punch)
\tinitializeClassicBars()
\tvar/support_bar = createClassicBar()
\taddClassicBarSlots(support_bar, 12)
\tnexus_classic_bars[support_bar]["columns"] = 7
\tfitClassicBar(support_bar)
\tfitClassicBar()
\tshowClassicWidget("sense")
\tshowClassicWidget("target")
\tshowClassicWidget("stats")
\tfor(var/i in 1 to 25) client.receiveNexusHudChatMessage("Preview message [i]: the rival changes stance.", "ic")
\tclient.receiveNexusHudChatMessage("A longer roleplay message for checking wrapping, readable text, and scrolling inside a compact chat without covering the fight.", "ic")
\tworld.log << "CLASSIC_PREVIEW_READY"
\tspawn() while(src && client)
\t\ttarget.Health = 60 + (world.time % 35)
\t\ttarget.Ki = 1500 + (world.time % 1000)
\t\tsleep(10)
`;
fs.writeFileSync(path.join(target, 'ClassicHudPreview.dm'), fixture);
change('DU.dme', s => `${s}\n#include "ClassicHudPreview.dm"\n`);
console.log(target);
