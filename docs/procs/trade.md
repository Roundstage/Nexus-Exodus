# Secure Player Trading

`src/Code/PlayerMechanics/Trade.dm` implements an atomic player-to-player exchange for carried items, Resources, and Arcane Essence. The `Other > Trade` verb can invite an available player within one tile.

## Transaction flow

1. The recipient explicitly accepts the invitation.
2. Either player may add carried items or set Resources and Arcane Essence. Every mutation increments the offer revision and clears both acceptances.
3. Both players accept the same revision. The session captures a fingerprint covering the item references, saved scalar item state, special Android blueprint contents, and both currency offers.
4. Both players independently finalize the sealed offer. Immediately before transfer, the session verifies the fingerprint, revision, ownership, item eligibility, balances, proximity, and both post-trade inventory capacities again.
5. Items move through their normal `Move(new_owner)` hooks without yielding. Currency balances change only after every item move succeeds; failed item movement is rolled back before any currency is touched.

Closing the browser does not silently cancel or accept anything. `Other > Trade` reopens an active session, while the explicit cancel action ends it. A lightweight session monitor cancels if either character disconnects, leaves the character, enters an invalid realm, or moves more than two tiles away.

## Item eligibility and disclosure

### datum/NexusTradeSession/proc/getItemError(obj/items/item, mob/owner)

- Requires an actual `/obj/items` instance whose `loc` and tracked `item_list` owner agree.
- Honors `obj.Givable` and rejects equipped or installed items until their suffix is cleared.
- Preserves the existing direct-transfer restriction on force fields.
- Rejects items or containers whose saved graph exceeds the secure traversal limits, contains unsupported values/non-object contents, or forms an unsupported list/content cycle. Nested items must independently be transferable: containers cannot bypass `Givable`, equipped/installed or active-suffix restrictions, the Force Field restriction, or active-state exclusions.
- Keeps ordinary armor, swords, guns, ammunition, shuriken, simulators, gravity generators, and forged equipment eligible once they are unequipped and idle. Short-lived asynchronous states (gun fire/customization, ammunition reload, gravity upgrade, stun-control cooldown, navigation, vacuum collection, injections, Magic Vault prompts, armed bombs, active glamours/moons, and pending cleanup) must finish before the item can enter an offer.
- Defers Robotics Tools as the sole whole-type legacy exclusion because their multi-stage body/module state machine cannot yet provide the same bounded ownership guarantees.

### getNexusTradeItemDisclosure(obj/items/item)

The review and final-confirmation pages show the item's immutable type path alongside its current name, description, status, base value, upgrade value, full saved scalar/list configuration, and a state seal. Names alone are never treated as proof of identity. Container contents are recursively sealed and displayed with exact type, depth, scalar seal, and full scalar/list configuration, bounded to eight levels, 200 objects, and 1,000 saved-graph entries. Removing, replacing, or changing a nested item invalidates the accepted offer. Magic Vaults additionally show their stored Arcane Essence and access code in an always-visible value panel.

Android blueprints additionally disclose whether they are blank. Filled Android designs show the stored design's name and exact type, race/class, replicated combat stats and modifiers, power and energy facts, a complete expandable saved-scalar configuration for the Body, and a bounded saved-list manifest covering milestones, mutations, energy state, and other persisted list state. Saved lists are sealed in order with text, path, resource, icon, datum, and atom-key associations, bounded to eight levels and 1,000 aggregate entries across the design, its direct components/modules, and module abilities. Persisted datum values such as Energy, Seal, and EnergySchedule are recursively sealed and disclosed with shared-reference and cycle handling; unsupported values still reject the design. Every stored module shows exact type, cost, status, effects, abilities, description, saved scalar/list configuration, and the full saved scalar/list configuration of each replicated module ability. Passworded modules disclose their actual access code/frequency with a warning that the seller may retain it. Every direct stored component or skill is enumerated even when it costs nothing, with exact type, replication status, value, description, and full scalar/list configuration. Filled object designs show value plus a concise set of consequential replicated combat, ammunition, timing, range, storage, upgrade, ship, turret, and access-code settings. Expandable full scalar and list configurations show the object-design state covered by the seal, so uncommon and future object types cannot conceal consequential persisted settings. A separate design seal covers all of these contents. Resetting or otherwise mutating a blueprint after acceptance changes the offer fingerprint and forces both players back through review.

Items in an active offer have their instance verbs suspended and are unavailable through the standard hotkey and inventory-tab dispatch paths. Legacy actions that yield for prompts, browser/icon selection, or timers capture their initiating user and location, then revalidate live ownership, offer status, selected targets, and range before every mutation or deletion. This includes container and blueprint selection, vault and DNA prompts, science/magic consumables, guns and ammunition, forged/customizable equipment, navigation/transport devices, and delayed healing or utility actions. Suspended actions therefore cannot mutate, delete, or move buyer property after trade completion.

## Currency handling

- Resources are offered as non-negative whole units and transferred through the characters' existing resource objects.
- Arcane Essence is offered as a non-negative finite amount normalized to `0.1`, matching the existing vault and magic UI convention. Trade transfers do not increase lifetime-earned essence.
- Both gross offers are validated against live balances at final commit; the resulting balance update is a net exchange.
