# _libs

## Overview
Auto-generated first-pass proc summaries based on signature names. Refine descriptions during refactors.

## Files
- `src/Code/_libs/absolutepositions/AbsolutePositions.dm`
- `src/Code/_libs/callback/Callback.dm`
- `src/Code/_libs/callback/Chain.dm`
- `src/Code/_libs/callback/Function.dm`
- `src/Code/_libs/callback/Method.dm`
- `src/Code/_libs/dmm_suite/_preprocessor_and_utilities.dm`
- `src/Code/_libs/dmm_suite/map_placeholders.dm`
- `src/Code/_libs/dmm_suite/reader.dm`
- `src/Code/_libs/dmm_suite/writer.dm`
- `src/Code/_libs/iconprocs/IconProcs.dm`
- `src/Code/_libs/kii_lighting/_lighting.dm`
- `src/Code/_libs/kii_lighting/daynight.dm`
- `src/Code/_libs/kii_lighting/spotlight.dm`
- `src/Code/_libs/kii_maptext_inputs/enter submission.dm`
- `src/Code/_libs/kii_maptext_inputs/key tracking.dm`
- `src/Code/_libs/kii_maptext_inputs/maptext inputs.dm`
- `src/Code/_libs/kii_weather/despawn.dm`
- `src/Code/_libs/kii_weather/kiiWeather.dm`
- `src/Code/_libs/list/List.dm`
- `src/Code/_libs/math/Math.dm`
- `src/Code/_libs/pathfinder/notes.dm`
- `src/Code/_libs/pathfinder/pathfinder.dm`
- `src/Code/_libs/pathfinder/pathfinder_astar.dm`
- `src/Code/_libs/pathfinder/pathnode.dm`
- `src/Code/_libs/priorityqueue/PriorityQueue.dm`
- `src/Code/_libs/texthandling/TextHandling.dm`
- `src/Code/_libs/time/Time.dm`
- `src/Code/_libs/upform/demo/demo.dm`
- `src/Code/_libs/upform/lib.dm`
- `src/Code/_libs/vectors/MatrixVectorSupport.dm`
- `src/Code/_libs/vectors/Vector.dm`

## Proc Reference

### src/Code/_libs/absolutepositions/AbsolutePositions.dm

#### atom/movable/proc/SetLoc
- Signature: `SetLoc(Loc, StepX = 0, StepY = 0)`
- Inputs: Loc, StepX = 0, StepY = 0
- Purpose: Set Loc.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### atom/movable/proc/SetPosition
- Signature: `SetPosition(Px, Py, Z)`
- Inputs: Px, Py, Z
- Purpose: Set Position.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### atom/movable/proc/SetCenter
- Signature: `SetCenter(Cx, Cy, Z)`
- Inputs: Cx, Cy, Z
- Purpose: Set Center.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### atom/movable/proc/Translate
- Signature: `Translate(X, Y)`
- Inputs: X, Y
- Purpose: Handle translate.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/Project
- Signature: `Project(Distance, Angle)`
- Inputs: Distance, Angle
- Purpose: Handle project.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/callback/Callback.dm

#### proc/Calls
- Signature: `proc/Calls()`
- Inputs: None
- Purpose: Handle calls.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/callback/Chain.dm

#### proc/_Match
- Signature: `proc/_Match(list/list, target)`
- Inputs: list/list, target
- Purpose: Handle match.
- Returns: none (implicit).
- Side effects: see implementation.

#### callback/chain/New
- Signature: `New(list/calls)`
- Inputs: list/calls
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### callback/chain/Call
- Signature: `Call(...)`
- Inputs: ...
- Purpose: Handle call.
- Returns: none (implicit).
- Side effects: see implementation.

#### callback/chain/Calls
- Signature: `Calls()`
- Inputs: None
- Purpose: Handle calls.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/callback/Function.dm

#### proc/function
- Signature: `proc/function(path)`
- Inputs: path
- Purpose: Handle function.
- Returns: none (implicit).
- Side effects: see implementation.

#### callback/function/New
- Signature: `New(path)`
- Inputs: path
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### callback/function/Call
- Signature: `Call(...)`
- Inputs: ...
- Purpose: Handle call.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/callback/Method.dm

#### proc/Method
- Signature: `proc/Method(path)`
- Inputs: path
- Purpose: Handle method.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Callback
- Signature: `proc/Callback(path, list/callback_args)`
- Inputs: path, list/callback_args
- Purpose: Handle callback.
- Returns: none (implicit).
- Side effects: see implementation.

#### callback/method/New
- Signature: `New(datum/source, path)`
- Inputs: datum/source, path
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### callback/method/Call
- Signature: `Call(...)`
- Inputs: ...
- Purpose: Handle call.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/dmm_suite/_preprocessor_and_utilities.dm

#### proc/text2list
- Signature: `proc/text2list(splitString, delimiter)`
- Inputs: splitString, delimiter
- Purpose: Handle text2list.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/list2text
- Signature: `proc/list2text(list/l, d = "")`
- Inputs: list/l, d = ""
- Purpose: Handle list2text.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/dmm_suite/map_placeholders.dm

#### dmm_suite/comment/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### dmm_suite/underlay/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/dmm_suite/reader.dm

#### dmm_suite/read_map
- Signature: `read_map(dmm_text as text, coordX as num, coordY as num, coordZ as num)`
- Inputs: dmm_text as text, coordX as num, coordY as num, coordZ as num
- Purpose: Handle read map.
- Returns: none (implicit).
- Side effects: see implementation.

#### dmm_suite/load_map
- Signature: `load_map(dmm_file as file, z_offset as num)`
- Inputs: dmm_file as file, z_offset as num
- Purpose: Load map.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### dmm_suite/proc/parse_grid
- Signature: `parse_grid(models as text, xcrd, ycrd, zcrd)`
- Inputs: models as text, xcrd, ycrd, zcrd
- Purpose: Handle parse grid.
- Returns: none (implicit).
- Side effects: see implementation.

#### dmm_suite/proc/loadModel
- Signature: `loadModel(atomPath, list/attributes, list/strings, xcrd, ycrd, zcrd)`
- Inputs: atomPath, list/attributes, list/strings, xcrd, ycrd, zcrd
- Purpose: Load Model.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### dmm_suite/proc/loadAttribute
- Signature: `loadAttribute(value, list/strings)`
- Inputs: value, list/strings
- Purpose: Load Attribute.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### atom/New
- Signature: `atom/New(turf/newLoc)`
- Inputs: turf/newLoc
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### dmm_suite/preloader/New
- Signature: `New(turf/loadLocation, list/_attributes)`
- Inputs: turf/loadLocation, list/_attributes
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### dmm_suite/preloader/proc/load
- Signature: `load(atom/newAtom)`
- Inputs: atom/newAtom
- Purpose: Handle load.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/dmm_suite/writer.dm

#### dmm_suite/write_map
- Signature: `write_map(turf/turf1, turf/turf2, flags as num)`
- Inputs: turf/turf1, turf/turf2, flags as num
- Purpose: Handle write map.
- Returns: none (implicit).
- Side effects: see implementation.

#### dmm_suite/write_cube
- Signature: `write_cube(startX as num, startY as num, startZ as num, width as num, height as num, depth as num, flags as num)`
- Inputs: startX as num, startY as num, startZ as num, width as num, height as num, depth as num, flags as num
- Purpose: Handle write cube.
- Returns: none (implicit).
- Side effects: see implementation.

#### dmm_suite/write_area
- Signature: `write_area(area/save_area, flags as num)`
- Inputs: area/save_area, flags as num
- Purpose: Handle write area.
- Returns: none (implicit).
- Side effects: see implementation.

#### dmm_suite/proc/writeDimensions
- Signature: `writeDimensions(startX, startY, startZ, width, height, depth, list/templates, list/templateBuffer)`
- Inputs: startX, startY, startZ, width, height, depth, list/templates, list/templateBuffer
- Purpose: Handle write dimensions.
- Returns: none (implicit).
- Side effects: see implementation.

#### dmm_suite/proc/makeTemplate
- Signature: `makeTemplate(turf/model as turf, flags as num)`
- Inputs: turf/model as turf, flags as num
- Purpose: Handle make template.
- Returns: none (implicit).
- Side effects: see implementation.

#### dmm_suite/proc/checkAttributes
- Signature: `checkAttributes(atom/A, underlay)`
- Inputs: atom/A, underlay
- Purpose: Check Attributes.
- Returns: none (implicit).
- Side effects: see implementation.

#### dmm_suite/proc/computeKeyIndex
- Signature: `computeKeyIndex(keyIndex, keyLength)`
- Inputs: keyIndex, keyLength
- Purpose: Handle compute key index.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/iconprocs/IconProcs.dm

#### proc/ChangeOpacity
- Signature: `proc/ChangeOpacity(opacity = 1.0)`
- Inputs: opacity = 1.0
- Purpose: Handle change opacity.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GrayScale
- Signature: `proc/GrayScale()`
- Inputs: None
- Purpose: Handle gray scale.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ColorTone
- Signature: `proc/ColorTone(tone)`
- Inputs: tone
- Purpose: Handle color tone.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/MinColors
- Signature: `proc/MinColors(icon)`
- Inputs: icon
- Purpose: Handle min colors.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/MaxColors
- Signature: `proc/MaxColors(icon)`
- Inputs: icon
- Purpose: Handle max colors.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Opaque
- Signature: `proc/Opaque(background = "#000000")`
- Inputs: background = "#000000"
- Purpose: Handle opaque.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/BecomeAlphaMask
- Signature: `proc/BecomeAlphaMask()`
- Inputs: None
- Purpose: Handle become alpha mask.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/UseAlphaMask
- Signature: `proc/UseAlphaMask(mask)`
- Inputs: mask
- Purpose: Handle use alpha mask.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/AddAlphaMask
- Signature: `proc/AddAlphaMask(mask)`
- Inputs: mask
- Purpose: Add Alpha Mask.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/ReadRGB
- Signature: `proc/ReadRGB(rgb)`
- Inputs: rgb
- Purpose: Handle read rgb.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ReadHSV
- Signature: `proc/ReadHSV(hsv)`
- Inputs: hsv
- Purpose: Handle read hsv.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/HSVtoRGB
- Signature: `proc/HSVtoRGB(hsv)`
- Inputs: hsv
- Purpose: Handle hsvto rgb.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/RGBtoHSV
- Signature: `proc/RGBtoHSV(rgb)`
- Inputs: rgb
- Purpose: Handle rgbto hsv.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/hsv
- Signature: `proc/hsv(hue, sat, val, alpha)`
- Inputs: hue, sat, val, alpha
- Purpose: Handle hsv.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/BlendHSV
- Signature: `proc/BlendHSV(hsv1, hsv2, amount)`
- Inputs: hsv1, hsv2, amount
- Purpose: Handle blend hsv.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/BlendRGB
- Signature: `proc/BlendRGB(rgb1, rgb2, amount)`
- Inputs: rgb1, rgb2, amount
- Purpose: Handle blend rgb.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/BlendRGBasHSV
- Signature: `proc/BlendRGBasHSV(rgb1, rgb2, amount)`
- Inputs: rgb1, rgb2, amount
- Purpose: Handle blend rgbas hsv.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/HueToAngle
- Signature: `proc/HueToAngle(hue)`
- Inputs: hue
- Purpose: Handle hue to angle.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/AngleToHue
- Signature: `proc/AngleToHue(angle)`
- Inputs: angle
- Purpose: Handle angle to hue.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/RotateHue
- Signature: `proc/RotateHue(hsv, angle)`
- Inputs: hsv, angle
- Purpose: Handle rotate hue.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GrayScale
- Signature: `proc/GrayScale(rgb)`
- Inputs: rgb
- Purpose: Handle gray scale.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ColorTone
- Signature: `proc/ColorTone(rgb, tone)`
- Inputs: rgb, tone
- Purpose: Handle color tone.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/kii_lighting/_lighting.dm

#### obj/*/screen/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/proc/is_occluder
- Signature: `is_occluder()`
- Inputs: None
- Purpose: Return whether occluder.
- Returns: boolean flag.
- Side effects: none expected.

#### atom/proc/is_emitter
- Signature: `is_emitter()`
- Inputs: None
- Purpose: Return whether emitter.
- Returns: boolean flag.
- Side effects: none expected.

#### atom/movable/proc/make_occlude
- Signature: `make_occlude( _type = STATIC, dynamic_mask = null)`
- Inputs: _type = STATIC, dynamic_mask = null
- Purpose: Handle make occlude.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/make_emissive
- Signature: `make_emissive( _type = STATIC, dynamic_mask = null )`
- Inputs: _type = STATIC, dynamic_mask = null
- Purpose: Handle make emissive.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/kii_lighting/daynight.dm

#### */proc/draw_global_lighting
- Signature: `draw_global_lighting()`
- Inputs: None
- Purpose: Handle draw global lighting.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/proc/draw_lighting
- Signature: `draw_lighting()`
- Inputs: None
- Purpose: Handle draw lighting.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/kii_lighting/spotlight.dm

#### spotlight/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/toggle_spotlight
- Signature: `toggle_spotlight(i = 1)`
- Inputs: i = 1
- Purpose: Toggle spotlight.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### atom/proc/draw_spotlight
- Signature: `draw_spotlight(x_os = 0, y_os = 0, hex = null, size_modi = 1, alph = 255)`
- Inputs: x_os = 0, y_os = 0, hex = null, size_modi = 1, alph = 255
- Purpose: Handle draw spotlight.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/proc/edit_spotlight
- Signature: `edit_spotlight(x_os, y_os, hex, size_modi, alph)`
- Inputs: x_os, y_os, hex, size_modi, alph
- Purpose: Handle edit spotlight.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/proc/toggle_spotlight
- Signature: `toggle_spotlight( i )`
- Inputs: i
- Purpose: Toggle spotlight.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### turf/toggle_spotlight
- Signature: `toggle_spotlight(i = 1)`
- Inputs: i = 1
- Purpose: Toggle spotlight.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/_libs/kii_maptext_inputs/enter submission.dm

#### client/proc/enter_submit
- Signature: `enter_submit()`
- Inputs: None
- Purpose: Handle enter submit.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/kii_maptext_inputs/key tracking.dm

#### proc/num2sym
- Signature: `num2sym(n as num)`
- Inputs: n as num
- Purpose: Handle num2sym.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/sym2Sym
- Signature: `sym2Sym(n as text)`
- Inputs: n as text
- Purpose: Handle sym2 sym.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/verb/key_down
- Signature: `key_down( key as text )`
- Inputs: key as text
- Purpose: Handle key down.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/verb/key_up
- Signature: `key_up( key as text)`
- Inputs: key as text
- Purpose: Handle key up.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/kii_maptext_inputs/maptext inputs.dm

#### obj/input_box/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/input_box/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/input_box/proc/get_text2disp
- Signature: `get_text2disp()`
- Inputs: None
- Purpose: Return text2disp.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### client/Click
- Signature: `Click(object)`
- Inputs: object
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/proc/draw_input
- Signature: `draw_input(_name, _loc, _width = 240, _height = 20, _default_text, _offset = 0, _is_password = 0, _enter_context)`
- Inputs: _name, _loc, _width = 240, _height = 20, _default_text, _offset = 0, _is_password = 0, _enter_context
- Purpose: Handle draw input.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/proc/get_ibox
- Signature: `get_ibox(i_box = "empty")`
- Inputs: i_box = "empty"
- Purpose: Return ibox.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### client/proc/unselect_ibox
- Signature: `unselect_ibox(obj/input_box/i)`
- Inputs: obj/input_box/i
- Purpose: Handle unselect ibox.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/proc/erase_input
- Signature: `erase_input(_id_tag = "empty")`
- Inputs: _id_tag = "empty"
- Purpose: Handle erase input.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/kii_weather/despawn.dm

#### atom/movable/proc/despawn
- Signature: `despawn(_delay = 0, fadeout = 0)`
- Inputs: _delay = 0, fadeout = 0
- Purpose: Handle despawn.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/kii_weather/kiiWeather.dm

#### proc/weather_tick
- Signature: `weather_tick()`
- Inputs: None
- Purpose: Handle weather tick.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/proc/local_weather
- Signature: `local_weather()`
- Inputs: None
- Purpose: Handle local weather.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/rain
- Signature: `rain()`
- Inputs: None
- Purpose: Handle rain.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/snow
- Signature: `snow()`
- Inputs: None
- Purpose: Handle snow.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/leaves
- Signature: `leaves()`
- Inputs: None
- Purpose: Handle leaves.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/storm
- Signature: `storm()`
- Inputs: None
- Purpose: Handle storm.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/blizzard
- Signature: `blizzard()`
- Inputs: None
- Purpose: Handle blizzard.
- Returns: none (implicit).
- Side effects: see implementation.

#### area/rainy_area/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/list/List.dm

#### dd_sortedObjectList
- Signature: `dd_sortedObjectList(list/incoming)`
- Inputs: list/incoming
- Purpose: Handle dd sorted object list.
- Returns: none (implicit).
- Side effects: see implementation.

#### dd_sortedtextlist
- Signature: `dd_sortedtextlist(list/incoming, case_sensitive)`
- Inputs: list/incoming, case_sensitive
- Purpose: Handle dd sortedtextlist.
- Returns: none (implicit).
- Side effects: see implementation.

#### dd_sortedTextList
- Signature: `dd_sortedTextList(list/incoming)`
- Inputs: list/incoming
- Purpose: Handle dd sorted text list.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/dd_sortedObjectList
- Signature: `proc/dd_sortedObjectList(list/incoming)`
- Inputs: list/incoming
- Purpose: Handle dd sorted object list.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/dd_sortedtextlist
- Signature: `proc/dd_sortedtextlist(list/incoming, case_sensitive = 0)`
- Inputs: list/incoming, case_sensitive = 0
- Purpose: Handle dd sortedtextlist.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/dd_sortedTextList
- Signature: `proc/dd_sortedTextList(list/incoming)`
- Inputs: list/incoming
- Purpose: Handle dd sorted text list.
- Returns: none (implicit).
- Side effects: see implementation.

#### datum/proc/dd_SortValue
- Signature: `datum/proc/dd_SortValue()`
- Inputs: None
- Purpose: Handle dd sort value.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/math/Math.dm

#### math/int/HandleOutput
- Signature: `HandleOutput(x)`
- Inputs: x
- Purpose: Handle Output.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/HandleOutput
- Signature: `HandleOutput(x)`
- Inputs: x
- Purpose: Handle Output.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Lerp
- Signature: `Lerp(a, b, t)`
- Inputs: a, b, t
- Purpose: Handle lerp.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Cerp
- Signature: `Cerp(a, b, t)`
- Inputs: a, b, t
- Purpose: Handle cerp.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Bias
- Signature: `Bias(x, bias)`
- Inputs: x, bias
- Purpose: Handle bias.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Sigmoid
- Signature: `Sigmoid(x)`
- Inputs: x
- Purpose: Handle sigmoid.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Falloff
- Signature: `Falloff(x, r = 0.01)`
- Inputs: x, r = 0.01
- Purpose: Handle falloff.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Exp
- Signature: `Exp(n)`
- Inputs: n
- Purpose: Handle exp.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Pow
- Signature: `Pow(x, y=2)`
- Inputs: x, y=2
- Purpose: Handle pow.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Hypot
- Signature: `Hypot(a, b)`
- Inputs: a, b
- Purpose: Handle hypot.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Sin
- Signature: `Sin(x)`
- Inputs: x
- Purpose: Handle sin.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Arcsin
- Signature: `Arcsin(x)`
- Inputs: x
- Purpose: Handle arcsin.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Cos
- Signature: `Cos(x)`
- Inputs: x
- Purpose: Handle cos.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Arccos
- Signature: `Arccos(x)`
- Inputs: x
- Purpose: Handle arccos.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Tan
- Signature: `Tan(x)`
- Inputs: x
- Purpose: Handle tan.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/arctanL
- Signature: `arctanL(x, y)`
- Inputs: x, y
- Purpose: Handle arctan l.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Clamp
- Signature: `Clamp(num, a, b)`
- Inputs: num, a, b
- Purpose: Handle clamp.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Min
- Signature: `Min(a, b)`
- Inputs: a, b
- Purpose: Handle min.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Max
- Signature: `Max(a, b)`
- Inputs: a, b
- Purpose: Handle max.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Abs
- Signature: `Abs(x)`
- Inputs: x
- Purpose: Handle abs.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/IsEven
- Signature: `IsEven(x)`
- Inputs: x
- Purpose: Return whether Even.
- Returns: boolean flag.
- Side effects: none expected.

#### math/proc/Prob
- Signature: `Prob(x)`
- Inputs: x
- Purpose: Handle prob.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Rand
- Signature: `Rand(a, b)`
- Inputs: a, b
- Purpose: Handle rand.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Seed
- Signature: `Seed(x)`
- Inputs: x
- Purpose: Handle seed.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Floor
- Signature: `Floor(x)`
- Inputs: x
- Purpose: Handle floor.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/FloorN
- Signature: `FloorN(x, N)`
- Inputs: x, N
- Purpose: Handle floor n.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Ceil
- Signature: `Ceil(x)`
- Inputs: x
- Purpose: Handle ceil.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/CeilN
- Signature: `CeilN(x, N)`
- Inputs: x, N
- Purpose: Handle ceil n.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Round
- Signature: `Round(x, y)`
- Inputs: x, y
- Purpose: Handle round.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Sqrt
- Signature: `Sqrt(x)`
- Inputs: x
- Purpose: Handle sqrt.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Log
- Signature: `Log(x)`
- Inputs: x
- Purpose: Handle log.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Log10
- Signature: `Log10(x)`
- Inputs: x
- Purpose: Handle log10.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Mean
- Signature: `Mean()`
- Inputs: None
- Purpose: Handle mean.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Mode
- Signature: `Mode()`
- Inputs: None
- Purpose: Handle mode.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Factorial
- Signature: `Factorial(n, r=0)`
- Inputs: n, r=0
- Purpose: Handle factorial.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Delta
- Signature: `Delta(a1, a2)`
- Inputs: a1, a2
- Purpose: Handle delta.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Line
- Signature: `Line(slope, x, y_intercept = 0)`
- Inputs: slope, x, y_intercept = 0
- Purpose: Handle line.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Slope
- Signature: `Slope(x1, y1, x2, y2)`
- Inputs: x1, y1, x2, y2
- Purpose: Handle slope.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/ValueFromPercentInRange
- Signature: `ValueFromPercentInRange(min, max, percent)`
- Inputs: min, max, percent
- Purpose: Handle value from percent in range.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/PercentFromValueInRange
- Signature: `PercentFromValueInRange(min, max, value)`
- Inputs: min, max, value
- Purpose: Handle percent from value in range.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/Inverse
- Signature: `Inverse(n)`
- Inputs: n
- Purpose: Handle inverse.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/InRange
- Signature: `InRange(val, min, max, inclusive = 1)`
- Inputs: val, min, max, inclusive = 1
- Purpose: Handle in range.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/PlotLine
- Signature: `PlotLine(x1, y1, x2, y2)`
- Inputs: x1, y1, x2, y2
- Purpose: Handle plot line.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/PlotLineLow
- Signature: `PlotLineLow(x1, y1, x2, y2)`
- Inputs: x1, y1, x2, y2
- Purpose: Handle plot line low.
- Returns: none (implicit).
- Side effects: see implementation.

#### math/proc/PlotLineHigh
- Signature: `PlotLineHigh(x1, y1, x2, y2)`
- Inputs: x1, y1, x2, y2
- Purpose: Handle plot line high.
- Returns: none (implicit).
- Side effects: see implementation.

#### simple_vector/New
- Signature: `New(_x = 1, _y = 1, _z = 1)`
- Inputs: _x = 1, _y = 1, _z = 1
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/pathfinder/notes.dm

#### */distance
- Signature: `distance(a, b)`
- Inputs: a, b
- Purpose: Handle distance.
- Returns: none (implicit).
- Side effects: see implementation.

#### */neighbors
- Signature: `neighbors(a)`
- Inputs: a
- Purpose: Handle neighbors.
- Returns: none (implicit).
- Side effects: see implementation.

#### */weight
- Signature: `weight(a)`
- Inputs: a
- Purpose: Handle weight.
- Returns: none (implicit).
- Side effects: see implementation.

#### */pathfinder/astar/demo type. The changed functionality is this/weight
- Signature: `weight(turf/a)`
- Inputs: turf/a
- Purpose: Handle weight.
- Returns: none (implicit).
- Side effects: see implementation.

#### */pathfinder/astar/demo type. The changed functionality is this/neighbors
- Signature: `neighbors(turf/a)`
- Inputs: turf/a
- Purpose: Handle neighbors.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/pathfinder/pathfinder.dm

#### pathfinder/proc/weight
- Signature: `weight(turf/t)`
- Inputs: turf/t
- Purpose: Handle weight.
- Returns: none (implicit).
- Side effects: see implementation.

#### pathfinder/proc/distance
- Signature: `distance(turf/a, turf/b)	// the distance heuristic between a and b`
- Inputs: turf/a, turf/b
- Purpose: Handle distance.
- Returns: none (implicit).
- Side effects: see implementation.

#### pathfinder/proc/neighbors
- Signature: `neighbors(turf/a)	// return a heterogenous list of neighboring objects`
- Inputs: turf/a
- Purpose: Handle neighbors.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/pathfinder/pathfinder_astar.dm

#### pathfinder/astar/search
- Signature: `search(start, end)`
- Inputs: start, end
- Purpose: Handle search.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/pathfinder/pathnode.dm

#### pathnode/New
- Signature: `New(source, parent, g, h)`
- Inputs: source, parent, g, h
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### pathnode/proc/cmp
- Signature: `cmp(pathnode/a, pathnode/b)`
- Inputs: pathnode/a, pathnode/b
- Purpose: Handle cmp.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/priorityqueue/PriorityQueue.dm

#### PriorityQueue/New
- Signature: `New(compare)`
- Inputs: compare
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### PriorityQueue/proc/IsEmpty
- Signature: `IsEmpty()`
- Inputs: None
- Purpose: Return whether Empty.
- Returns: boolean flag.
- Side effects: none expected.

#### PriorityQueue/proc/Enqueue
- Signature: `Enqueue(d)`
- Inputs: d
- Purpose: Handle enqueue.
- Returns: none (implicit).
- Side effects: see implementation.

#### PriorityQueue/proc/Dequeue
- Signature: `Dequeue()`
- Inputs: None
- Purpose: Handle dequeue.
- Returns: none (implicit).
- Side effects: see implementation.

#### PriorityQueue/proc/Remove
- Signature: `Remove(i)`
- Inputs: i
- Purpose: Handle remove.
- Returns: none (implicit).
- Side effects: see implementation.

#### PriorityQueue/proc/_Fix
- Signature: `_Fix(i)`
- Inputs: i
- Purpose: Handle fix.
- Returns: none (implicit).
- Side effects: see implementation.

#### PriorityQueue/proc/List
- Signature: `List()`
- Inputs: None
- Purpose: Handle list.
- Returns: none (implicit).
- Side effects: see implementation.

#### PriorityQueue/proc/RemoveItem
- Signature: `RemoveItem(i)`
- Inputs: i
- Purpose: Remove Item.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/_libs/texthandling/TextHandling.dm

#### dd_file2list
- Signature: `dd_file2list(file_path, separator = "\n")`
- Inputs: file_path, separator = "\n"
- Purpose: Handle dd file2list.
- Returns: none (implicit).
- Side effects: see implementation.

#### dd_replacetext
- Signature: `dd_replacetext(text, search_string, replacement_string)`
- Inputs: text, search_string, replacement_string
- Purpose: Handle dd replacetext.
- Returns: none (implicit).
- Side effects: see implementation.

#### dd_replaceText
- Signature: `dd_replaceText(text, search_string, replacement_string)`
- Inputs: text, search_string, replacement_string
- Purpose: Handle dd replace text.
- Returns: none (implicit).
- Side effects: see implementation.

#### dd_hasprefix
- Signature: `dd_hasprefix(text, prefix)`
- Inputs: text, prefix
- Purpose: Handle dd hasprefix.
- Returns: none (implicit).
- Side effects: see implementation.

#### dd_hasPrefix
- Signature: `dd_hasPrefix(text, prefix)`
- Inputs: text, prefix
- Purpose: Handle dd has prefix.
- Returns: none (implicit).
- Side effects: see implementation.

#### dd_hassuffix
- Signature: `dd_hassuffix(text, suffix)`
- Inputs: text, suffix
- Purpose: Handle dd hassuffix.
- Returns: none (implicit).
- Side effects: see implementation.

#### dd_hasSuffix
- Signature: `dd_hasSuffix(text, suffix)`
- Inputs: text, suffix
- Purpose: Handle dd has suffix.
- Returns: none (implicit).
- Side effects: see implementation.

#### dd_text2list
- Signature: `dd_text2list(text, separator)`
- Inputs: text, separator
- Purpose: Handle dd text2list.
- Returns: none (implicit).
- Side effects: see implementation.

#### dd_text2List
- Signature: `dd_text2List(text, separator)`
- Inputs: text, separator
- Purpose: Handle dd text2 list.
- Returns: none (implicit).
- Side effects: see implementation.

#### dd_list2text
- Signature: `dd_list2text(list/the_list, separator)`
- Inputs: list/the_list, separator
- Purpose: Handle dd list2text.
- Returns: none (implicit).
- Side effects: see implementation.

#### dd_centertext
- Signature: `dd_centertext(message, length)`
- Inputs: message, length
- Purpose: Handle dd centertext.
- Returns: none (implicit).
- Side effects: see implementation.

#### dd_limittext
- Signature: `dd_limittext(message, length)`
- Inputs: message, length
- Purpose: Handle dd limittext.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/dd_file2list
- Signature: `dd_file2list(file_path, separator = "\n")`
- Inputs: file_path, separator = "\n"
- Purpose: Handle dd file2list.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/dd_replacetext
- Signature: `dd_replacetext(text, search_string, replacement_string)`
- Inputs: text, search_string, replacement_string
- Purpose: Handle dd replacetext.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/dd_replaceText
- Signature: `dd_replaceText(text, search_string, replacement_string)`
- Inputs: text, search_string, replacement_string
- Purpose: Handle dd replace text.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/dd_hasprefix
- Signature: `dd_hasprefix(text, prefix)`
- Inputs: text, prefix
- Purpose: Handle dd hasprefix.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/dd_hasPrefix
- Signature: `dd_hasPrefix(text, prefix)`
- Inputs: text, prefix
- Purpose: Handle dd has prefix.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/dd_hassuffix
- Signature: `dd_hassuffix(text, suffix)`
- Inputs: text, suffix
- Purpose: Handle dd hassuffix.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/dd_hasSuffix
- Signature: `dd_hasSuffix(text, suffix)`
- Inputs: text, suffix
- Purpose: Handle dd has suffix.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/dd_text2list
- Signature: `dd_text2list(text, separator)`
- Inputs: text, separator
- Purpose: Handle dd text2list.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/dd_text2List
- Signature: `dd_text2List(text, separator)`
- Inputs: text, separator
- Purpose: Handle dd text2 list.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/dd_list2text
- Signature: `dd_list2text(list/the_list, separator)`
- Inputs: list/the_list, separator
- Purpose: Handle dd list2text.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/dd_centertext
- Signature: `dd_centertext(message, length)`
- Inputs: message, length
- Purpose: Handle dd centertext.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/dd_limittext
- Signature: `dd_limittext(message, length)`
- Inputs: message, length
- Purpose: Handle dd limittext.
- Returns: none (implicit).
- Side effects: see implementation.

#### dd_grep
- Signature: `dd_grep(regex, file_or_text)`
- Inputs: regex, file_or_text
- Purpose: Handle dd grep.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/test/texthandling/verb/dd_list2text_test
- Signature: `obj/test/texthandling/verb/dd_list2text_test()`
- Inputs: None
- Purpose: Handle dd list2text test.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/time/Time.dm

#### time/proc/FromSeconds
- Signature: `FromSeconds(t)`
- Inputs: t
- Purpose: Handle from seconds.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/FromMinutes
- Signature: `FromMinutes(t)`
- Inputs: t
- Purpose: Handle from minutes.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/FromHours
- Signature: `FromHours(t)`
- Inputs: t
- Purpose: Handle from hours.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/FromDays
- Signature: `FromDays(t)`
- Inputs: t
- Purpose: Handle from days.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/FromWeeks
- Signature: `FromWeeks(t)`
- Inputs: t
- Purpose: Handle from weeks.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/FromMonths
- Signature: `FromMonths(t)`
- Inputs: t
- Purpose: Handle from months.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/FromYears
- Signature: `FromYears(t)`
- Inputs: t
- Purpose: Handle from years.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/ToSeconds
- Signature: `ToSeconds(t)`
- Inputs: t
- Purpose: Handle to seconds.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/ToMinutes
- Signature: `ToMinutes(t)`
- Inputs: t
- Purpose: Handle to minutes.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/ToHours
- Signature: `ToHours(t)`
- Inputs: t
- Purpose: Handle to hours.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/ToDays
- Signature: `ToDays(t)`
- Inputs: t
- Purpose: Handle to days.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/ToWeeks
- Signature: `ToWeeks(t)`
- Inputs: t
- Purpose: Handle to weeks.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/ToMonths
- Signature: `ToMonths(t)`
- Inputs: t
- Purpose: Handle to months.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/ToYears
- Signature: `ToYears(t)`
- Inputs: t
- Purpose: Handle to years.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/ToRoundedSeconds
- Signature: `ToRoundedSeconds(t)`
- Inputs: t
- Purpose: Handle to rounded seconds.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/ToRoundedMinutes
- Signature: `ToRoundedMinutes(t)`
- Inputs: t
- Purpose: Handle to rounded minutes.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/ToRoundedHours
- Signature: `ToRoundedHours(t)`
- Inputs: t
- Purpose: Handle to rounded hours.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/ToRoundedDays
- Signature: `ToRoundedDays(t)`
- Inputs: t
- Purpose: Handle to rounded days.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/ToRoundedWeeks
- Signature: `ToRoundedWeeks(t)`
- Inputs: t
- Purpose: Handle to rounded weeks.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/ToRoundedMonths
- Signature: `ToRoundedMonths(t)`
- Inputs: t
- Purpose: Handle to rounded months.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/ToRoundedYears
- Signature: `ToRoundedYears(t)`
- Inputs: t
- Purpose: Handle to rounded years.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/GetRoundedTime
- Signature: `GetRoundedTime(t)`
- Inputs: t
- Purpose: Return Rounded Time.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### time/proc/CheckCooldownWorld
- Signature: `CheckCooldownWorld(savedTime, cooldown)`
- Inputs: savedTime, cooldown
- Purpose: Check Cooldown World.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/GetTimeElapsedWorld
- Signature: `GetTimeElapsedWorld(savedTime)`
- Inputs: savedTime
- Purpose: Return Time Elapsed World.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### time/proc/GetTimeRemainingWorld
- Signature: `GetTimeRemainingWorld(savedTime, cooldown)`
- Inputs: savedTime, cooldown
- Purpose: Return Time Remaining World.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### time/proc/CheckCooldownGMT
- Signature: `CheckCooldownGMT(savedTime, cooldown)`
- Inputs: savedTime, cooldown
- Purpose: Check Cooldown GMT.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/GetTimeElapsedGMT
- Signature: `GetTimeElapsedGMT(savedTime)`
- Inputs: savedTime
- Purpose: Return Time Elapsed GMT.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### time/proc/GetTimeRemainingGMT
- Signature: `GetTimeRemainingGMT(savedTime, cooldown)`
- Inputs: savedTime, cooldown
- Purpose: Return Time Remaining GMT.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### time/proc/CheckCooldownGlobal
- Signature: `CheckCooldownGlobal(savedTime, cooldown)`
- Inputs: savedTime, cooldown
- Purpose: Check Cooldown Global.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/GetTimeElapsedGlobal
- Signature: `GetTimeElapsedGlobal(savedTime)`
- Inputs: savedTime
- Purpose: Return Time Elapsed Global.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### time/proc/GetTimeRemainingGlobal
- Signature: `GetTimeRemainingGlobal(savedTime, cooldown)`
- Inputs: savedTime, cooldown
- Purpose: Return Time Remaining Global.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### time/proc/CheckCooldown
- Signature: `CheckCooldown(savedTime, cooldown, timebase = 0)`
- Inputs: savedTime, cooldown, timebase = 0
- Purpose: Check Cooldown.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/GetTimeElapsed
- Signature: `GetTimeElapsed(savedTime, timebase = 0)`
- Inputs: savedTime, timebase = 0
- Purpose: Return Time Elapsed.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### time/proc/GetTimeRemaining
- Signature: `GetTimeRemaining(savedTime, cooldown, timebase = 0)`
- Inputs: savedTime, cooldown, timebase = 0
- Purpose: Return Time Remaining.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### time/proc/RecordWorld
- Signature: `RecordWorld()`
- Inputs: None
- Purpose: Handle record world.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/RecordGMT
- Signature: `RecordGMT()`
- Inputs: None
- Purpose: Handle record gmt.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/RecordGlobal
- Signature: `RecordGlobal()`
- Inputs: None
- Purpose: Handle record global.
- Returns: none (implicit).
- Side effects: see implementation.

#### time/proc/Record
- Signature: `Record(timebase = 0)`
- Inputs: timebase = 0
- Purpose: Handle record.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/upform/demo/demo.dm

#### world/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### world/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Login
- Signature: `Login()`
- Inputs: None
- Purpose: Handle client login setup.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Logout
- Signature: `Logout()`
- Inputs: None
- Purpose: Handle client logout cleanup.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ViewInfo
- Signature: `ViewInfo(mob/M)`
- Inputs: mob/M
- Purpose: Handle view info.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/EditInfo
- Signature: `EditInfo()`
- Inputs: None
- Purpose: Handle edit info.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/intro
- Signature: `intro()`
- Inputs: None
- Purpose: Handle intro.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/timed
- Signature: `timed()`
- Inputs: None
- Purpose: Handle timed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/default
- Signature: `default()`
- Inputs: None
- Purpose: Handle default.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/intro/GenerateBody
- Signature: `GenerateBody()`
- Inputs: None
- Purpose: Handle generate body.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/timed/GenerateBody
- Signature: `GenerateBody()`
- Inputs: None
- Purpose: Handle generate body.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/default/Link
- Signature: `Link(list/href_list)`
- Inputs: list/href_list
- Purpose: Handle link.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/default/GenerateBody
- Signature: `GenerateBody()`
- Inputs: None
- Purpose: Handle generate body.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/playerlist/Link
- Signature: `Link(list/href_list, client/C)`
- Inputs: list/href_list, client/C
- Purpose: Handle link.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/playerlist/GenerateBody
- Signature: `GenerateBody()`
- Inputs: None
- Purpose: Handle generate body.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/viewinfo/Link
- Signature: `Link(list/href_list, client/C)`
- Inputs: list/href_list, client/C
- Purpose: Handle link.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/viewinfo/canDisplayForm
- Signature: `canDisplayForm(client/C)`
- Inputs: client/C
- Purpose: Return whether Display Form.
- Returns: boolean flag.
- Side effects: none expected.

#### upForm/viewinfo/PreSettings
- Signature: `PreSettings()`
- Inputs: None
- Purpose: Handle pre settings.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/viewinfo/GenerateBody
- Signature: `GenerateBody()`
- Inputs: None
- Purpose: Handle generate body.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/editinfo/Link
- Signature: `Link(list/href_list)`
- Inputs: list/href_list
- Purpose: Handle link.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/editinfo/canDisplayForm
- Signature: `canDisplayForm(client/C)`
- Inputs: client/C
- Purpose: Return whether Display Form.
- Returns: boolean flag.
- Side effects: none expected.

#### upForm/editinfo/FormInitTempVars
- Signature: `FormInitTempVars()`
- Inputs: None
- Purpose: Handle form init temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/editinfo/FormSetTempVars
- Signature: `FormSetTempVars(fname)`
- Inputs: fname
- Purpose: Handle form set temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/editinfo/ProcessVariable
- Signature: `ProcessVariable(fname, name, value)`
- Inputs: fname, name, value
- Purpose: Process Variable.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/editinfo/FormSubmitSuccess
- Signature: `FormSubmitSuccess(fname, client/C)`
- Inputs: fname, client/C
- Purpose: Handle form submit success.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/editinfo/GenerateBody
- Signature: `GenerateBody(list/errors=list())`
- Inputs: list/errors=list(
- Purpose: Handle generate body.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/upform/lib.dm

#### mob/Login
- Signature: `mob/Login()`
- Inputs: None
- Purpose: Handle client login setup.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/proc/upForm_isViewingForm
- Signature: `upForm_isViewingForm(form)`
- Inputs: form
- Purpose: Handle up form is viewing form.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/upForm_isValidHost
- Signature: `upForm_isValidHost(datum/host)`
- Inputs: datum/host
- Purpose: Handle up form is valid host.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/upForm_isValidFormPath
- Signature: `upForm_isValidFormPath(path)`
- Inputs: path
- Purpose: Handle up form is valid form path.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/upForm_getClientTarget
- Signature: `upForm_getClientTarget(_target)`
- Inputs: _target
- Purpose: Handle up form get client target.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/upForm_formatViewerList
- Signature: `upForm_formatViewerList(list/viewers)`
- Inputs: list/viewers
- Purpose: Handle up form format viewer list.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/upForm_UpdateForms
- Signature: `upForm_UpdateForms(form)`
- Inputs: form
- Purpose: Handle up form update forms.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/upForm
- Signature: `upForm(arg1, arg2, arg3, arg4)`
- Inputs: arg1, arg2, arg3, arg4
- Purpose: Handle up form.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/New
- Signature: `New(client/_owner, datum/_host, list/_viewers)`
- Inputs: client/_owner, datum/_host, list/_viewers
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/Topic
- Signature: `Topic(href, list/href_list)`
- Inputs: href, list/href_list
- Purpose: Handle topic.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/proc/getOwner
- Signature: `getOwner()`
- Inputs: None
- Purpose: Return Owner.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### upForm/proc/getHost
- Signature: `getHost()`
- Inputs: None
- Purpose: Return Host.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### upForm/proc/InitViewers
- Signature: `InitViewers(list/viewer_list)`
- Inputs: list/viewer_list
- Purpose: Initialize Viewers.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/proc/SetViewer
- Signature: `SetViewer(client/C)`
- Inputs: client/C
- Purpose: Set Viewer.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### upForm/proc/AddViewer
- Signature: `AddViewer(client/C)`
- Inputs: client/C
- Purpose: Add Viewer.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### upForm/proc/RemoveViewer
- Signature: `RemoveViewer(client/C)`
- Inputs: client/C
- Purpose: Remove Viewer.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### upForm/proc/isViewer
- Signature: `isViewer(client/C) // is this client a current viewer?`
- Inputs: client/C
- Purpose: Return whether Viewer.
- Returns: boolean flag.
- Side effects: none expected.

#### upForm/proc/canBeViewer
- Signature: `canBeViewer(client/C) // is this client capable of being a viewer`
- Inputs: client/C
- Purpose: Return whether Be Viewer.
- Returns: boolean flag.
- Side effects: none expected.

#### upForm/proc/canDisplayForm
- Signature: `canDisplayForm(client/C)`
- Inputs: client/C
- Purpose: Return whether Display Form.
- Returns: boolean flag.
- Side effects: none expected.

#### upForm/proc/InitSettings
- Signature: `InitSettings()`
- Inputs: None
- Purpose: Initialize Settings.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/proc/InitPredefinedScript
- Signature: `InitPredefinedScript()`
- Inputs: None
- Purpose: Initialize Predefined Script.
- Returns: none (implicit).
- Side effects: see implementation.

#### }/hasTimeStarted
- Signature: `hasTimeStarted()`
- Inputs: None
- Purpose: Return whether Time Started.
- Returns: boolean flag.
- Side effects: none expected.

#### }/InitTimer
- Signature: `InitTimer()`
- Inputs: None
- Purpose: Initialize Timer.
- Returns: none (implicit).
- Side effects: see implementation.

#### }/StartTimer
- Signature: `StartTimer(time)`
- Inputs: time
- Purpose: Start Timer.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### }/TimeUp
- Signature: `TimeUp()`
- Inputs: None
- Purpose: Handle time up.
- Returns: none (implicit).
- Side effects: see implementation.

#### }/SendResource
- Signature: `SendResource(target, rsc, rsc_name)`
- Inputs: target, rsc, rsc_name
- Purpose: Handle send resource.
- Returns: none (implicit).
- Side effects: see implementation.

#### }/LoadResource
- Signature: `LoadResource(rsc, rsc_name)`
- Inputs: rsc, rsc_name
- Purpose: Load Resource.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### }/InitResources
- Signature: `InitResources(target)`
- Inputs: target
- Purpose: Initialize Resources.
- Returns: none (implicit).
- Side effects: see implementation.

#### }/isValidForm
- Signature: `isValidForm(fname)`
- Inputs: fname
- Purpose: Return whether Valid Form.
- Returns: boolean flag.
- Side effects: none expected.

#### }/isValidFormVar
- Signature: `isValidFormVar(fname, fvar)`
- Inputs: fname, fvar
- Purpose: Return whether Valid Form Var.
- Returns: boolean flag.
- Side effects: none expected.

#### }/getFormVar
- Signature: `getFormVar(fname, fvar)`
- Inputs: fname, fvar
- Purpose: Return Form Var.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### }/setFormVar
- Signature: `setFormVar(fname, fvar, fval)`
- Inputs: fname, fvar, fval
- Purpose: Set Form Var.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### }/initFormVar
- Signature: `initFormVar(fname, fvar, fval)`
- Inputs: fname, fvar, fval
- Purpose: Initialize Form Var.
- Returns: none (implicit).
- Side effects: see implementation.

#### }/FormSubmitSuccess
- Signature: `FormSubmitSuccess(fname, client/C)`
- Inputs: fname, client/C
- Purpose: Handle form submit success.
- Returns: none (implicit).
- Side effects: see implementation.

#### }/FormSubmitError
- Signature: `FormSubmitError(fname, list/errors, client/C)`
- Inputs: fname, list/errors, client/C
- Purpose: Handle form submit error.
- Returns: none (implicit).
- Side effects: see implementation.

#### }/FormInitTempVars
- Signature: `FormInitTempVars()`
- Inputs: None
- Purpose: Handle form init temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### }/FormSetTempVars
- Signature: `FormSetTempVars(fname)`
- Inputs: fname
- Purpose: Handle form set temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### }/ProcessVariable
- Signature: `ProcessVariable(fname, name, value, client/C)`
- Inputs: fname, name, value, client/C
- Purpose: Process Variable.
- Returns: none (implicit).
- Side effects: see implementation.

#### }/HandleFormLinks
- Signature: `HandleFormLinks(list/params, client/C)`
- Inputs: list/params, client/C
- Purpose: Handle Form Links.
- Returns: none (implicit).
- Side effects: see implementation.

#### }/ProcessForm
- Signature: `ProcessForm(fname, list/params, client/C)`
- Inputs: fname, list/params, client/C
- Purpose: Process Form.
- Returns: none (implicit).
- Side effects: see implementation.

#### }/GenerateBody
- Signature: `GenerateBody(list/errors)`
- Inputs: list/errors
- Purpose: Handle generate body.
- Returns: none (implicit).
- Side effects: see implementation.

#### }/RefreshPage
- Signature: `RefreshPage(list/errors)`
- Inputs: list/errors
- Purpose: Handle refresh page.
- Returns: none (implicit).
- Side effects: see implementation.

#### }/DisplayPage
- Signature: `DisplayPage()`
- Inputs: None
- Purpose: Handle display page.
- Returns: none (implicit).
- Side effects: see implementation.

#### }/RemovePage
- Signature: `RemovePage(client/C)`
- Inputs: client/C
- Purpose: Remove Page.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### }/DisplayBrowserText
- Signature: `DisplayBrowserText(text, target)`
- Inputs: text, target
- Purpose: Handle display browser text.
- Returns: none (implicit).
- Side effects: see implementation.

#### }/UpdatePage
- Signature: `UpdatePage(bodyText, jsText)`
- Inputs: bodyText, jsText
- Purpose: Update Page.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### </html>/ClosePages
- Signature: `ClosePages()`
- Inputs: None
- Purpose: Handle close pages.
- Returns: none (implicit).
- Side effects: see implementation.

#### </html>/DeleteForm
- Signature: `DeleteForm()`
- Inputs: None
- Purpose: Delete Form.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/_libs/vectors/MatrixVectorSupport.dm

#### matrix/Translate
- Signature: `Translate(x, y)`
- Inputs: x, y
- Purpose: Handle translate.
- Returns: none (implicit).
- Side effects: see implementation.

#### matrix/Scale
- Signature: `Scale(x, y)`
- Inputs: x, y
- Purpose: Handle scale.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/_libs/vectors/Vector.dm

#### proc/dir2vector
- Signature: `proc/dir2vector(dir)`
- Inputs: dir
- Purpose: Handle dir2vector.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/X
- Signature: `proc/X()`
- Inputs: None
- Purpose: Handle x.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Y
- Signature: `proc/Y()`
- Inputs: None
- Purpose: Handle y.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Z
- Signature: `proc/Z()`
- Inputs: None
- Purpose: Handle z.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/With
- Signature: `proc/With(x = _x, y = _y, z = _z)`
- Inputs: x = _x, y = _y, z = _z
- Purpose: Handle with.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Text
- Signature: `proc/Text(figures = 6)`
- Inputs: figures = 6
- Purpose: Handle text.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/operator/
- Signature: `proc/operator/(arg)`
- Inputs: arg
- Purpose: Handle .
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Subtract
- Signature: `proc/Subtract(vector/vector)`
- Inputs: vector/vector
- Purpose: Handle subtract.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Negate
- Signature: `proc/Negate()`
- Inputs: None
- Purpose: Handle negate.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Scale
- Signature: `proc/Scale(scalar)`
- Inputs: scalar
- Purpose: Handle scale.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Multiply
- Signature: `proc/Multiply(vector/vector)`
- Inputs: vector/vector
- Purpose: Handle multiply.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Transform
- Signature: `proc/Transform(matrix/matrix)`
- Inputs: matrix/matrix
- Purpose: Handle transform.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Divide
- Signature: `proc/Divide(vector/vector)`
- Inputs: vector/vector
- Purpose: Handle divide.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/CrossZ
- Signature: `proc/CrossZ(vector/vector)`
- Inputs: vector/vector
- Purpose: Handle cross z.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/LengthSquared
- Signature: `proc/LengthSquared()`
- Inputs: None
- Purpose: Handle length squared.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Length
- Signature: `proc/Length()`
- Inputs: None
- Purpose: Handle length.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Direction
- Signature: `proc/Direction()`
- Inputs: None
- Purpose: Handle direction.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/HasDirection
- Signature: `proc/HasDirection()`
- Inputs: None
- Purpose: Return whether Direction.
- Returns: boolean flag.
- Side effects: none expected.

#### proc/DirectionOrZero
- Signature: `proc/DirectionOrZero()`
- Inputs: None
- Purpose: Handle direction or zero.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/HasLength
- Signature: `proc/HasLength()`
- Inputs: None
- Purpose: Return whether Length.
- Returns: boolean flag.
- Side effects: none expected.

#### proc/Rotation
- Signature: `proc/Rotation(vector/from = Vector.north)`
- Inputs: vector/from = Vector.north
- Purpose: Handle rotation.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/WithLength
- Signature: `proc/WithLength(length)`
- Inputs: length
- Purpose: Handle with length.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/WithLengthOrZero
- Signature: `proc/WithLengthOrZero(length)`
- Inputs: length
- Purpose: Handle with length or zero.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ClampLength
- Signature: `proc/ClampLength(upper)`
- Inputs: upper
- Purpose: Handle clamp length.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ToDir
- Signature: `proc/ToDir()`
- Inputs: None
- Purpose: Handle to dir.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ToCardinalDir
- Signature: `proc/ToCardinalDir()`
- Inputs: None
- Purpose: Handle to cardinal dir.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ToExactDir
- Signature: `proc/ToExactDir()`
- Inputs: None
- Purpose: Handle to exact dir.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Clamp
- Signature: `proc/Clamp(vector/lower, vector/upper)`
- Inputs: vector/lower, vector/upper
- Purpose: Handle clamp.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DegreesTo
- Signature: `proc/DegreesTo(vector/other)`
- Inputs: vector/other
- Purpose: Handle degrees to.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DegreesFrom
- Signature: `proc/DegreesFrom(vector/other)`
- Inputs: vector/other
- Purpose: Handle degrees from.
- Returns: none (implicit).
- Side effects: see implementation.

#### vector/New
- Signature: `New(x = 0, y = 0, z = 0)`
- Inputs: x = 0, y = 0, z = 0
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.
