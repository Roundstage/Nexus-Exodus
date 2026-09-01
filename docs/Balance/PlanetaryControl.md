# Planetary Control

## Rules

- Each of the nine canonical planets has one persistent control point: Earth, Namekian, Braal, Atlantis, Arconia, Ice, Desert, Jungle, and Android.
- An unclaimed point can be claimed from `Other > Planetary Control` by a rank 7 League leader on that planet.
- Control belongs to a League, while one exact character is recorded as its governor and control-point holder.
- The title is portable. To conquer a ruled planet, stand beside its governor anywhere outside a safe zone after they are knocked out with 0 Willpower and click the character. Choose the carried planet, if there is more than one, then choose an eligible League and confirm the seizure.
- A character who belongs to the ruling League cannot seize its point for a second League. Account slots are distinct holders, and a second simultaneous capture cannot reuse an old ownership revision.
- Conquest resets both tax rates to 0%, but the treasury remains attached to the captured point as spoils.
- A holder who dies or deletes the owning character leaves the point immediately abandoned. A conscious holder who leaves or is expelled from the ruling League does the same; leaving or expelling is blocked while that holder is KO so it cannot cancel a conquest prompt.
- A holder who remains unavailable for 72 hours also leaves an abandoned, claimable point. Abandoned points suspend taxation, management, and Braal ruler powers while preserving their treasury for the next claimant.
- Braal's throne now reports and opens this system; it can no longer replace the ruler simply by being bumped.

## Taxes

The ruler can set separate Resource and Arcane Essence income taxes from 0% to 25%. The game calls the requested "Mana Essence" currency **Arcane Essence**.

Taxes are withheld once from new income earned on the current planet. They do not repeatedly drain an existing balance, and transfers, refunds, bank withdrawals, secure trades, and Magic Vault withdrawals are not treated as new income. A dropped Resource balance carries a tax-exempt amount through bag merging and CyberDrone transport, so recollecting it does not tax the same money twice. Taxable Resource income includes generated resource bags, theft, mining, drill extraction, salvage, bounty rewards, race and tournament winnings, villain-League paychecks, and money wishes. Generated Arcane Essence is taxed through its central gain path.

Fractional tax remainders are retained per character and current policy, so repeated small Resource or Arcane Essence gains cannot avoid the configured rate. Settled and obsolete remainder keys are removed rather than growing every character save indefinitely.

Members of the ruling League are exempt. Herans pay by default but may explicitly choose `Refuse planetary taxes`; that preference has no effect while the character is any other race.

The governor and rank 6+ officers of the ruling League may change rates and withdraw either currency from the persistent planetary treasury while on that planet. Ownership changes, policy changes, and withdrawals save immediately; tax receipts are also flushed by the periodic control-state save loop.

Planet jurisdiction includes its canonical surface, planet-local `/area/Inside` interiors, mining caves remembered across relogs, and the interior of a large ship while that ship is landed on the planet. Direct teleports and Arcane Portal endpoints propagate cave jurisdiction. Space, tournaments, prisons, afterlife areas, and independent realms remain outside planetary taxation.

## Persistence and identity

Control state is stored separately in `data/PlanetControl` (or the playtest namespace). Authority checks use the League's stable `league_id`, not its editable name. Governor identity uses account, character slot, and character creation timestamp so another slot cannot impersonate the holder. Holder presence is refreshed by the periodic save loop, and older control saves initialize the new presence field safely during migration.
