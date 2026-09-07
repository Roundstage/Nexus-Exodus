# Melee VFX review

Reviewed NexusMeleeTechnique and the Viltrumite casts. All NexusMeleeTechnique attacks inherit an impact icon and showImpact through resolveNexusTechniqueHit; many Unarmed and sword subtypes already choose their own asset. Viltrumite casts inherited the generic impact, and their approaches used generic afterimages.

Rush, Relentless Pursuit and Nolan's Combination now use bounded pale-blue silhouette trails during their actual collision-aware approach. Pursuit gets an arrival pressure ring; it still causes no hit or damage. All successful Viltrumite hits layer a brief warm flash and white pressure ring over the inherited impact, including Rib Breaker, Conqueror's Grip, Meteor Drop, Spear Hand and Punishing Reversal. Nolan's final successful hit adds a larger pressure burst. Failed hits do not emit success impacts.

Dragon Rush already has an animation/SFX loop; shared Unarmed and sword techniques have impact hooks. This review does not claim every legacy melee verb has bespoke VFX.

Visual helpers: VisualEffects/ViltrumiteEffects.dm. Movement speed, collision, target checks and combat values remain in their original logic. Snapshot production stops with the approach or after twelve samples; each snapshot fades and returns to the effect pool after four ticks. Native approach afterimages are disabled for these three casts to avoid duplicate trails.
