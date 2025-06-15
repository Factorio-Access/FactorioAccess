# Game Content

## Table of Contents

- [README](#readme)
- [controls-reference](#controls-reference)
- [entities-complete](#entities-complete)
- [entities](#entities)
- [game-mechanics](#game-mechanics)
- [game-progression-guide](#game-progression-guide)
- [index](#index)
- [items](#items)
- [recipes-detailed](#recipes-detailed)
- [recipes](#recipes)
- [technologies-detailed](#technologies-detailed)
- [technologies](#technologies)
- [tips-and-tricks-complete](#tips-and-tricks-complete)
- [tips-and-tricks](#tips-and-tricks)

---

## README

# Factorio Game Content Reference

This directory contains extracted game content from Factorio, organized for easy reference.

## Contents

- **[items.md](items.md)** - All items in the game with their properties
- **[recipes.md](recipes.md)** - All crafting recipes and their requirements
- **[technologies.md](technologies.md)** - Research tree and technology descriptions
- **[entities.md](entities.md)** - Buildings, machines, and other entities
- **[tips-and-tricks.md](tips-and-tricks.md)** - Helpful gameplay tips

## Statistics

- Total items: 216
- Total recipes: 193
- Total technologies: 192
- Total entities: 9
- Total tips: 65

## How to Use This Reference

This reference is extracted directly from Factorio's game files and provides:

1. **Items** - Every item you can hold, craft, or use
2. **Recipes** - How to craft items, what machines are needed
3. **Technologies** - What research unlocks which recipes and capabilities
4. **Entities** - Buildings, machines, and structures you can place

Each entry includes the internal name (used in commands/mods) and localized display name.

---

## controls-reference

# Factorio Controls Reference

Complete list of game controls and their functions.

## Movement

### Toggle exoskeleton
- **Control ID:** `toggle-equipment-movement-bonus`

## Other

### Artillery targeting remote
- **Control ID:** `give-artillery-targeting-remote`

### Copper wire connection mode
- **Control ID:** `give-copper-wire`

### Copy
- **Control ID:** `copy`

### Cut
- **Control ID:** `cut`

### Discharge defense remote
- **Control ID:** `give-discharge-defense-remote`

### Green wire connection mode
- **Control ID:** `give-green-wire`

### Make new blueprint
- **Control ID:** `give-blueprint`

### Make new blueprint book
- **Control ID:** `give-blueprint-book`

### Make new deconstruction planner
- **Control ID:** `give-deconstruction-planner`

### Make new upgrade planner
- **Control ID:** `give-upgrade-planner`

### Red wire connection mode
- **Control ID:** `give-red-wire`

### Spidertron remote
- **Control ID:** `give-spidertron-remote`

### Toggle personal logistic requests
- **Control ID:** `toggle-personal-logistic-requests`

### Toggle personal roboport
- **Control ID:** `toggle-personal-roboport`

---

## entities-complete

# Factorio Entities - Complete List

All buildings, machines, and placeable entities in Factorio.


## S Curve

### __core__/sound/deconstruct-medium.bnvib
- **Internal name:** `__core__/sound/deconstruct-medium.bnvib`
- **Type:** S-curve
- **Source:** sounds.lua

### __core__/sound/deconstruct-small.bnvib
- **Internal name:** `__core__/sound/deconstruct-small.bnvib`
- **Type:** S-curve
- **Source:** sounds.lua

### __core__/sound/deconstruct-small.ogg
- **Internal name:** `__core__/sound/deconstruct-small.ogg`
- **Type:** S-curve
- **Source:** sounds.lua


## Accumulator

### __base__/graphics/entity/fast-inserter/fast-inserter-hand-base.png
- **Internal name:** `__base__/graphics/entity/fast-inserter/fast-inserter-hand-base.png`
- **Type:** accumulator
- **Source:** entities.lua


## Acid

### Curved rail
- **Internal name:** `curved-rail-a`
- **Type:** acid
- **Source:** trains.lua

### Straight rail
- **Internal name:** `straight-rail`
- **Type:** acid
- **Source:** trains.lua

### __base__/graphics/entity/acid-splash/acid-splash-3.png
- **Internal name:** `__base__/graphics/entity/acid-splash/acid-splash-3.png`
- **Type:** acid
- **Source:** enemy-projectiles.lua

### __base__/graphics/entity/acid-sticker/acid-sticker.png
- **Internal name:** `__base__/graphics/entity/acid-sticker/acid-sticker.png`
- **Type:** acid
- **Source:** enemy-projectiles.lua

### __base__/graphics/entity/car/car-shadow-1.png
- **Internal name:** `__base__/graphics/entity/car/car-shadow-1.png`
- **Type:** acid
- **Source:** entities.lua

### __base__/graphics/entity/cargo-wagon/minimap-representation/cargo-wagon-selected-minimap-representation.png
- **Internal name:** `__base__/graphics/entity/cargo-wagon/minimap-representation/cargo-wagon-selected-minimap-representation.png`
- **Type:** acid
- **Source:** trains.lua

### __base__/graphics/entity/construction-robot/construction-robot.png
- **Internal name:** `__base__/graphics/entity/construction-robot/construction-robot.png`
- **Type:** acid
- **Source:** flying-robots.lua

### __base__/graphics/entity/defender-robot/defender-robot-shadow.png
- **Internal name:** `__base__/graphics/entity/defender-robot/defender-robot-shadow.png`
- **Type:** acid
- **Source:** flying-robots.lua

### __base__/graphics/entity/factorio-logo/factorio-logo-22tiles.png
- **Internal name:** `__base__/graphics/entity/factorio-logo/factorio-logo-22tiles.png`
- **Type:** acid
- **Source:** factorio-logo.lua

### __base__/graphics/entity/fluid-wagon/minimap-representation/fluid-wagon-minimap-representation.png
- **Internal name:** `__base__/graphics/entity/fluid-wagon/minimap-representation/fluid-wagon-minimap-representation.png`
- **Type:** acid
- **Source:** trains.lua

### __base__/graphics/entity/inserter/inserter-hand-closed.png
- **Internal name:** `__base__/graphics/entity/inserter/inserter-hand-closed.png`
- **Type:** acid
- **Source:** entities.lua

### __base__/graphics/entity/laser-turret/laser-turret-raising-mask.png
- **Internal name:** `__base__/graphics/entity/laser-turret/laser-turret-raising-mask.png`
- **Type:** acid
- **Source:** turrets.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_North-fluid.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_North-fluid.png`
- **Type:** acid
- **Source:** entities.lua

### __base__/sound/steam-engine-90bpm.ogg
- **Internal name:** `__base__/sound/steam-engine-90bpm.ogg`
- **Type:** acid
- **Source:** entities.lua

### __base__/sound/train-engine-start.ogg
- **Internal name:** `__base__/sound/train-engine-start.ogg`
- **Type:** acid
- **Source:** trains.lua

### __core__/graphics/arrows/underground-lines.png
- **Internal name:** `__core__/graphics/arrows/underground-lines.png`
- **Type:** acid
- **Source:** entities.lua

### acid-stream-worm-medium
- **Internal name:** `acid-stream-worm-medium`
- **Type:** acid
- **Source:** enemy-projectiles.lua

### dummy-rail-support
- **Internal name:** `dummy-rail-support`
- **Type:** acid
- **Source:** trains.lua


## Ammo Turret

### __base__/graphics/entity/gun-turret/gun-turret-shooting-3.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-shooting-3.png`
- **Type:** ammo-turret
- **Source:** turrets.lua


## Area

### Flamethrower turret
- **Internal name:** `flamethrower-turret`
- **Type:** area
- **Description:** Fires a stream of burning liquid at enemies.
- **Health:** 1400
- **Source:** fire.lua

### Nuclear explosion
- **Internal name:** `nuke-explosion`
- **Type:** area
- **Source:** atomic-bomb.lua

### __base__/graphics/entity/acid-projectile/projectile-shadow.png
- **Internal name:** `__base__/graphics/entity/acid-projectile/projectile-shadow.png`
- **Type:** area
- **Source:** fire.lua

### __base__/graphics/entity/burner-inserter/burner-inserter-hand-base.png
- **Internal name:** `__base__/graphics/entity/burner-inserter/burner-inserter-hand-base.png`
- **Type:** area
- **Source:** entities.lua

### __base__/graphics/entity/combat-robot-capsule/defender-capsule-mask.png
- **Internal name:** `__base__/graphics/entity/combat-robot-capsule/defender-capsule-mask.png`
- **Type:** area
- **Source:** projectiles.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-south-mask.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-south-mask.png`
- **Type:** area
- **Source:** fire.lua

### __core__/sound/deconstruct-ghost.ogg
- **Internal name:** `__core__/sound/deconstruct-ghost.ogg`
- **Type:** area
- **Source:** entities.lua

### slowdown-capsule
- **Internal name:** `slowdown-capsule`
- **Type:** area
- **Source:** projectiles.lua


## Arithmetic Combinator

### Arithmetic combinator
- **Internal name:** `arithmetic-combinator`
- **Type:** arithmetic-combinator
- **Description:** Performs arithmetic operations on circuit network signals.
- **Health:** 150
- **Source:** circuit-network.lua


## Arrow

### __base__/graphics/entity/boiler/boiler-S-idle.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-S-idle.png`
- **Type:** arrow
- **Source:** entities.lua

### __base__/sound/car-breaks.ogg
- **Internal name:** `__base__/sound/car-breaks.ogg`
- **Type:** arrow
- **Source:** entities.lua


## Artillery Flare

### __base__/sound/car-engine-driving.ogg
- **Internal name:** `__base__/sound/car-engine-driving.ogg`
- **Type:** artillery-flare
- **Source:** entities.lua


## Artillery Projectile

### poison-capsule-metal-particle
- **Internal name:** `poison-capsule-metal-particle`
- **Type:** artillery-projectile
- **Source:** projectiles.lua


## Artillery Turret

### __base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-2.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-2.png`
- **Type:** artillery-turret
- **Source:** turrets.lua


## Artillery Wagon

### __base__/sound/cargo-wagon/cargo-wagon-opening-loop.ogg
- **Internal name:** `__base__/sound/cargo-wagon/cargo-wagon-opening-loop.ogg`
- **Type:** artillery-wagon
- **Source:** trains.lua


## Assembling Machine

### Wooden chest
- **Internal name:** `wooden-chest`
- **Type:** assembling-machine
- **Health:** 100
- **Source:** entities.lua

### __base__/graphics/entity/boiler/boiler-W-shadow.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-W-shadow.png`
- **Type:** assembling-machine
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-corner-left.png
- **Internal name:** `__base__/graphics/entity/wall/wall-corner-left.png`
- **Type:** assembling-machine
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-ending-left-shadow.png
- **Internal name:** `__base__/graphics/entity/wall/wall-ending-left-shadow.png`
- **Type:** assembling-machine
- **Source:** entities.lua


## Beacon

### Assembling machine 1
- **Internal name:** `assembling-machine-1`
- **Type:** beacon
- **Health:** 300
- **Source:** entities.lua


## Beam

### __base__/graphics/entity/construction-robot/construction-robot-working.png
- **Internal name:** `__base__/graphics/entity/construction-robot/construction-robot-working.png`
- **Type:** beam
- **Source:** flying-robots.lua

### __base__/graphics/entity/destroyer-robot/destroyer-robot-mask.png
- **Internal name:** `__base__/graphics/entity/destroyer-robot/destroyer-robot-mask.png`
- **Type:** beam
- **Source:** flying-robots.lua

### __base__/graphics/entity/distractor-robot/distractor-robot.png
- **Internal name:** `__base__/graphics/entity/distractor-robot/distractor-robot.png`
- **Type:** beam
- **Source:** flying-robots.lua

### __base__/graphics/entity/gun-turret/gun-turret-shooting-mask-3.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-shooting-mask-3.png`
- **Type:** beam
- **Source:** turrets.lua

### __base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-1.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-1.png`
- **Type:** beam
- **Source:** turrets.lua

### __base__/graphics/entity/laser-turret/laser-body.png
- **Internal name:** `__base__/graphics/entity/laser-turret/laser-body.png`
- **Type:** beam
- **Source:** beams.lua

### laser-beam
- **Internal name:** `laser-beam`
- **Type:** beam
- **Source:** beams.lua


## Boiler

### __base__/graphics/entity/pipe/pipe-corner-up-right.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-corner-up-right.png`
- **Type:** boiler
- **Source:** entities.lua

### __base__/sound/lab.ogg
- **Internal name:** `__base__/sound/lab.ogg`
- **Type:** boiler
- **Source:** entities.lua


## Burner

### Lab
- **Internal name:** `lab`
- **Type:** burner
- **Health:** 150
- **Source:** entities.lua

### Stone furnace
- **Internal name:** `stone-furnace`
- **Type:** burner
- **Health:** 200
- **Source:** entities.lua

### __base__/graphics/entity/electric-furnace/electric-furnace-shadow.png
- **Internal name:** `__base__/graphics/entity/electric-furnace/electric-furnace-shadow.png`
- **Type:** burner
- **Source:** entities.lua

### __base__/graphics/entity/electric-mining-drill/electric-mining-drill-shadow.png
- **Internal name:** `__base__/graphics/entity/electric-mining-drill/electric-mining-drill-shadow.png`
- **Type:** burner
- **Source:** mining-drill.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_East-fluid.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_East-fluid.png`
- **Type:** burner
- **Source:** entities.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_South-underwater.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_South-underwater.png`
- **Type:** burner
- **Source:** entities.lua

### __base__/graphics/entity/pipe/pipe-straight-horizontal-window.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-straight-horizontal-window.png`
- **Type:** burner
- **Source:** entities.lua

### __base__/graphics/entity/pipe/pipe-t-right.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-t-right.png`
- **Type:** burner
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-single.png
- **Internal name:** `__base__/graphics/entity/wall/wall-single.png`
- **Type:** burner
- **Source:** entities.lua


## Burner Generator

### __base__/graphics/entity/electric-furnace/electric-furnace.png
- **Internal name:** `__base__/graphics/entity/electric-furnace/electric-furnace.png`
- **Type:** burner-generator
- **Source:** entities.lua


## Car

### Deconstructible tile proxy
- **Internal name:** `deconstructible-tile-proxy`
- **Type:** car
- **Source:** entities.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_South-shadow.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_South-shadow.png`
- **Type:** car
- **Source:** entities.lua


## Cargo Landing Pad

### signal-black
- **Internal name:** `signal-black`
- **Type:** cargo-landing-pad
- **Source:** entities.lua


## Cargo Pod

### __base__/graphics/entity/electric-furnace/electric-furnace-propeller-2.png
- **Internal name:** `__base__/graphics/entity/electric-furnace/electric-furnace-propeller-2.png`
- **Type:** cargo-pod
- **Source:** entities.lua


## Chain

### __base__/graphics/entity/beam/beam-body-4.png
- **Internal name:** `__base__/graphics/entity/beam/beam-body-4.png`
- **Type:** chain
- **Source:** beams.lua


## Character

### __base__/graphics/entity/accumulator/accumulator-reflection.png
- **Internal name:** `__base__/graphics/entity/accumulator/accumulator-reflection.png`
- **Type:** character
- **Source:** entities.lua


## Character Corpse

### __base__/graphics/entity/accumulator/accumulator-shadow.png
- **Internal name:** `__base__/graphics/entity/accumulator/accumulator-shadow.png`
- **Type:** character-corpse
- **Source:** entities.lua


## Cliff

### __base__/sound/deconstruct-bricks.ogg
- **Internal name:** `__base__/sound/deconstruct-bricks.ogg`
- **Type:** cliff
- **Source:** entity-util.lua


## Cluster

### __base__/sound/assembling-machine-t1-1.ogg
- **Internal name:** `__base__/sound/assembling-machine-t1-1.ogg`
- **Type:** cluster
- **Source:** entities.lua

### __base__/sound/assembling-machine-t2-1.ogg
- **Internal name:** `__base__/sound/assembling-machine-t2-1.ogg`
- **Type:** cluster
- **Source:** entities.lua


## Combat Robot

### __base__/graphics/entity/defender-robot/defender-robot.png
- **Internal name:** `__base__/graphics/entity/defender-robot/defender-robot.png`
- **Type:** combat-robot
- **Source:** flying-robots.lua

### __base__/graphics/entity/distractor-robot/distractor-robot-mask.png
- **Internal name:** `__base__/graphics/entity/distractor-robot/distractor-robot-mask.png`
- **Type:** combat-robot
- **Source:** flying-robots.lua


## Constant Combinator

### Constant combinator
- **Internal name:** `constant-combinator`
- **Type:** constant-combinator
- **Description:** Outputs constant circuit network signals.
- **Health:** 120
- **Source:** circuit-network.lua


## Container

### Chest capsule
- **Internal name:** `crash-site-chest-1`
- **Type:** container
- **Description:** A container from the crashed ship. It might contain useful items.
- **Source:** crash-site.lua

### Factorio logo 11 tiles
- **Internal name:** `factorio-logo-11tiles`
- **Type:** container
- **Source:** factorio-logo.lua

### __base__/graphics/entity/burner-inserter/burner-inserter-hand-base-shadow.png
- **Internal name:** `__base__/graphics/entity/burner-inserter/burner-inserter-hand-base-shadow.png`
- **Type:** container
- **Source:** entities.lua

### __base__/graphics/entity/crash-site-chests/crash-site-chest-1-shadow.png
- **Internal name:** `__base__/graphics/entity/crash-site-chests/crash-site-chest-1-shadow.png`
- **Type:** container
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-chests/crash-site-chest-2.png
- **Internal name:** `__base__/graphics/entity/crash-site-chests/crash-site-chest-2.png`
- **Type:** container
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-ground.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-ground.png`
- **Type:** container
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-big-1-shadow.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-big-1-shadow.png`
- **Type:** container
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-big-2.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-big-2.png`
- **Type:** container
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-1-ground.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-1-ground.png`
- **Type:** container
- **Source:** crash-site.lua

### __base__/graphics/entity/pipe/pipe-cross.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-cross.png`
- **Type:** container
- **Source:** entities.lua

### __base__/graphics/entity/pipe/pipe-t-left.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-t-left.png`
- **Type:** container
- **Source:** entities.lua

### crash-site-spaceship-wreck-big-1
- **Internal name:** `crash-site-spaceship-wreck-big-1`
- **Type:** container
- **Source:** crash-site.lua


## Corpse

### 1x2 remnants
- **Internal name:** `1x2-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### Behemoth biter
- **Internal name:** `behemoth-biter`
- **Type:** corpse
- **Source:** enemies.lua

### Big remnants
- **Internal name:** `big-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### Big spitter
- **Internal name:** `big-spitter`
- **Type:** corpse
- **Source:** enemies.lua

### Medium remnants
- **Internal name:** `medium-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### Medium small remnants
- **Internal name:** `medium-small-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### Rail ending remnants
- **Internal name:** `rail-ending-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### Small remnants
- **Internal name:** `small-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### Small scorchmark
- **Internal name:** `small-scorchmark`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/assembling-machine-1/remnants/assembling-machine-1-remnants.png
- **Internal name:** `__base__/graphics/entity/assembling-machine-1/remnants/assembling-machine-1-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/assembling-machine-2/remnants/assembling-machine-2-remnants.png
- **Internal name:** `__base__/graphics/entity/assembling-machine-2/remnants/assembling-machine-2-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/big-electric-pole/remnants/big-electric-pole-base-remnants.png
- **Internal name:** `__base__/graphics/entity/big-electric-pole/remnants/big-electric-pole-base-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/big-electric-pole/remnants/big-electric-pole-top-remnants.png
- **Internal name:** `__base__/graphics/entity/big-electric-pole/remnants/big-electric-pole-top-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/boiler/remnants/boiler-remnants.png
- **Internal name:** `__base__/graphics/entity/boiler/remnants/boiler-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/burner-inserter/remnants/burner-inserter-remnants.png
- **Internal name:** `__base__/graphics/entity/burner-inserter/remnants/burner-inserter-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/burner-mining-drill/remnants/burner-mining-drill-remnants.png
- **Internal name:** `__base__/graphics/entity/burner-mining-drill/remnants/burner-mining-drill-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/car/remnants/car-remnants.png
- **Internal name:** `__base__/graphics/entity/car/remnants/car-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/car/remnants/mask/car-remnants-mask.png
- **Internal name:** `__base__/graphics/entity/car/remnants/mask/car-remnants-mask.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/electric-furnace/remnants/electric-furnace-remnants.png
- **Internal name:** `__base__/graphics/entity/electric-furnace/remnants/electric-furnace-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/electric-mining-drill/remnants/electric-mining-drill-remnants.png
- **Internal name:** `__base__/graphics/entity/electric-mining-drill/remnants/electric-mining-drill-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/fast-inserter/remnants/fast-inserter-remnants.png
- **Internal name:** `__base__/graphics/entity/fast-inserter/remnants/fast-inserter-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/fast-splitter/remnants/fast-splitter-remnants.png
- **Internal name:** `__base__/graphics/entity/fast-splitter/remnants/fast-splitter-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/fast-transport-belt/remnants/fast-transport-belt-remnants.png
- **Internal name:** `__base__/graphics/entity/fast-transport-belt/remnants/fast-transport-belt-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/gun-turret/gun-turret-raising.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-raising.png`
- **Type:** corpse
- **Source:** turrets.lua

### __base__/graphics/entity/gun-turret/remnants/gun-turret-remnants.png
- **Internal name:** `__base__/graphics/entity/gun-turret/remnants/gun-turret-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/gun-turret/remnants/mask/gun-turret-remnants-mask.png
- **Internal name:** `__base__/graphics/entity/gun-turret/remnants/mask/gun-turret-remnants-mask.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/inserter/remnants/inserter-remnants.png
- **Internal name:** `__base__/graphics/entity/inserter/remnants/inserter-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/iron-chest/remnants/iron-chest-remnants.png
- **Internal name:** `__base__/graphics/entity/iron-chest/remnants/iron-chest-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/lab/remnants/lab-remnants.png
- **Internal name:** `__base__/graphics/entity/lab/remnants/lab-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/long-handed-inserter/remnants/long-handed-inserter-remnants.png
- **Internal name:** `__base__/graphics/entity/long-handed-inserter/remnants/long-handed-inserter-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/medium-electric-pole/remnants/medium-electric-pole-base-remnants.png
- **Internal name:** `__base__/graphics/entity/medium-electric-pole/remnants/medium-electric-pole-base-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/medium-electric-pole/remnants/medium-electric-pole-top-remnants.png
- **Internal name:** `__base__/graphics/entity/medium-electric-pole/remnants/medium-electric-pole-top-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/offshore-pump/remnants/offshore-pump-remnants-variation-1.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/remnants/offshore-pump-remnants-variation-1.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/offshore-pump/remnants/offshore-pump-remnants-variation-2.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/remnants/offshore-pump-remnants-variation-2.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/pipe-to-ground/remnants/pipe-to-ground-remnants.png
- **Internal name:** `__base__/graphics/entity/pipe-to-ground/remnants/pipe-to-ground-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/pipe/remnants/pipe-remnants.png
- **Internal name:** `__base__/graphics/entity/pipe/remnants/pipe-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/radar/remnants/radar-remnants.png
- **Internal name:** `__base__/graphics/entity/radar/remnants/radar-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/rail-chain-signal/remnants/rail-chain-signal-remnants.png
- **Internal name:** `__base__/graphics/entity/rail-chain-signal/remnants/rail-chain-signal-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/rail-endings/rail-endings-background.png
- **Internal name:** `__base__/graphics/entity/rail-endings/rail-endings-background.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/rail-endings/rail-endings-metals.png
- **Internal name:** `__base__/graphics/entity/rail-endings/rail-endings-metals.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/rail-signal/remnants/rail-signal-remnants.png
- **Internal name:** `__base__/graphics/entity/rail-signal/remnants/rail-signal-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/remnants/1x2-remnants.png
- **Internal name:** `__base__/graphics/entity/remnants/1x2-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/remnants/big-remnants.png
- **Internal name:** `__base__/graphics/entity/remnants/big-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/remnants/medium-remnants.png
- **Internal name:** `__base__/graphics/entity/remnants/medium-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/remnants/medium-small-remnants.png
- **Internal name:** `__base__/graphics/entity/remnants/medium-small-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/remnants/small-remnants.png
- **Internal name:** `__base__/graphics/entity/remnants/small-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/scorchmark/small-scorchmark-tintable-top.png
- **Internal name:** `__base__/graphics/entity/scorchmark/small-scorchmark-tintable-top.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/scorchmark/small-scorchmark-tintable.png
- **Internal name:** `__base__/graphics/entity/scorchmark/small-scorchmark-tintable.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/scorchmark/small-scorchmark-top.png
- **Internal name:** `__base__/graphics/entity/scorchmark/small-scorchmark-top.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/scorchmark/small-scorchmark.png
- **Internal name:** `__base__/graphics/entity/scorchmark/small-scorchmark.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/small-electric-pole/remnants/small-electric-pole-base-remnants.png
- **Internal name:** `__base__/graphics/entity/small-electric-pole/remnants/small-electric-pole-base-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/small-electric-pole/remnants/small-electric-pole-top-remnants.png
- **Internal name:** `__base__/graphics/entity/small-electric-pole/remnants/small-electric-pole-top-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/splitter/remnants/splitter-remnants.png
- **Internal name:** `__base__/graphics/entity/splitter/remnants/splitter-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/steam-engine/remnants/steam-engine-remnants.png
- **Internal name:** `__base__/graphics/entity/steam-engine/remnants/steam-engine-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/steel-chest/remnants/steel-chest-remnants.png
- **Internal name:** `__base__/graphics/entity/steel-chest/remnants/steel-chest-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/steel-furnace/remnants/steel-furnace-remnants.png
- **Internal name:** `__base__/graphics/entity/steel-furnace/remnants/steel-furnace-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/stone-furnace/remnants/stone-furnace-remnants.png
- **Internal name:** `__base__/graphics/entity/stone-furnace/remnants/stone-furnace-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/transport-belt/remnants/transport-belt-remnants.png
- **Internal name:** `__base__/graphics/entity/transport-belt/remnants/transport-belt-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/underground-belt/remnants/underground-belt-remnants.png
- **Internal name:** `__base__/graphics/entity/underground-belt/remnants/underground-belt-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/wall/remnants/wall-remnants.png
- **Internal name:** `__base__/graphics/entity/wall/remnants/wall-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### __base__/graphics/entity/wooden-chest/remnants/wooden-chest-remnants.png
- **Internal name:** `__base__/graphics/entity/wooden-chest/remnants/wooden-chest-remnants.png`
- **Type:** corpse
- **Source:** remnants.lua

### assembling-machine-1-remnants
- **Internal name:** `assembling-machine-1-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### assembling-machine-2-remnants
- **Internal name:** `assembling-machine-2-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### big-electric-pole-remnants
- **Internal name:** `big-electric-pole-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### boiler-remnants
- **Internal name:** `boiler-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### burner-inserter-remnants
- **Internal name:** `burner-inserter-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### burner-mining-drill-remnants
- **Internal name:** `burner-mining-drill-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### car-remnants
- **Internal name:** `car-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### curved-rail-a-remnants
- **Internal name:** `curved-rail-a-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### curved-rail-b-remnants
- **Internal name:** `curved-rail-b-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### electric-furnace-remnants
- **Internal name:** `electric-furnace-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### electric-mining-drill-remnants
- **Internal name:** `electric-mining-drill-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### fast-inserter-remnants
- **Internal name:** `fast-inserter-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### fast-splitter-remnants
- **Internal name:** `fast-splitter-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### fast-transport-belt-remnants
- **Internal name:** `fast-transport-belt-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### gate-remnants
- **Internal name:** `gate-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### gun-turret-remnants
- **Internal name:** `gun-turret-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### half-diagonal-rail-remnants
- **Internal name:** `half-diagonal-rail-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### inserter-remnants
- **Internal name:** `inserter-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### iron-chest-remnants
- **Internal name:** `iron-chest-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### lab-remnants
- **Internal name:** `lab-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### legacy-curved-rail-remnants
- **Internal name:** `legacy-curved-rail-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### legacy-straight-rail-remnants
- **Internal name:** `legacy-straight-rail-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### long-handed-inserter-remnants
- **Internal name:** `long-handed-inserter-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### medium-electric-pole-remnants
- **Internal name:** `medium-electric-pole-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### offshore-pump-remnants
- **Internal name:** `offshore-pump-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### pipe-remnants
- **Internal name:** `pipe-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### pipe-to-ground-remnants
- **Internal name:** `pipe-to-ground-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### radar-remnants
- **Internal name:** `radar-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### rail-chain-signal-remnants
- **Internal name:** `rail-chain-signal-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### rail-signal-remnants
- **Internal name:** `rail-signal-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### splitter-remnants
- **Internal name:** `splitter-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### steam-engine-remnants
- **Internal name:** `steam-engine-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### steel-chest-remnants
- **Internal name:** `steel-chest-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### steel-furnace-remnants
- **Internal name:** `steel-furnace-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### stone-furnace-remnants
- **Internal name:** `stone-furnace-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### straight-rail-remnants
- **Internal name:** `straight-rail-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### transport-belt-remnants
- **Internal name:** `transport-belt-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### tree_dead_grey_trunk
- **Internal name:** `tree_dead_grey_trunk`
- **Type:** corpse
- **Source:** trees.lua

### underground-belt-remnants
- **Internal name:** `underground-belt-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### wall-remnants
- **Internal name:** `wall-remnants`
- **Type:** corpse
- **Source:** remnants.lua

### wooden-chest-remnants
- **Internal name:** `wooden-chest-remnants`
- **Type:** corpse
- **Source:** remnants.lua


## Create Entity

### Poison cloud
- **Internal name:** `poison-cloud`
- **Type:** create-entity
- **Source:** projectiles.lua

### Rocket
- **Internal name:** `rocket`
- **Type:** create-entity
- **Source:** projectiles.lua

### __base__/graphics/entity/artillery-projectile/artillery-shoot-map-visualization.png
- **Internal name:** `__base__/graphics/entity/artillery-projectile/artillery-shoot-map-visualization.png`
- **Type:** create-entity
- **Source:** projectiles.lua

### __base__/graphics/entity/cliff-explosives/cliff-explosives.png
- **Internal name:** `__base__/graphics/entity/cliff-explosives/cliff-explosives.png`
- **Type:** create-entity
- **Source:** projectiles.lua

### __base__/graphics/entity/combat-robot-capsule/destroyer-capsule-mask.png
- **Internal name:** `__base__/graphics/entity/combat-robot-capsule/destroyer-capsule-mask.png`
- **Type:** create-entity
- **Source:** projectiles.lua

### __base__/graphics/entity/destroyer-robot/destroyer-robot.png
- **Internal name:** `__base__/graphics/entity/destroyer-robot/destroyer-robot.png`
- **Type:** create-entity
- **Source:** flying-robots.lua

### __base__/graphics/entity/grenade/grenade-shadow.png
- **Internal name:** `__base__/graphics/entity/grenade/grenade-shadow.png`
- **Type:** create-entity
- **Source:** projectiles.lua

### __base__/graphics/entity/lab/lab-light.png
- **Internal name:** `__base__/graphics/entity/lab/lab-light.png`
- **Type:** create-entity
- **Source:** entities.lua

### __base__/graphics/entity/laser/laser-to-tint-medium.png
- **Internal name:** `__base__/graphics/entity/laser/laser-to-tint-medium.png`
- **Type:** create-entity
- **Source:** projectiles.lua

### __base__/graphics/entity/sparks/sparks-05.png
- **Internal name:** `__base__/graphics/entity/sparks/sparks-05.png`
- **Type:** create-entity
- **Source:** flying-robots.lua

### __base__/sound/fight/defender-robot-loop.ogg
- **Internal name:** `__base__/sound/fight/defender-robot-loop.ogg`
- **Type:** create-entity
- **Source:** flying-robots.lua

### atomic-rocket
- **Internal name:** `atomic-rocket`
- **Type:** create-entity
- **Source:** atomic-bomb.lua

### cluster-grenade
- **Internal name:** `cluster-grenade`
- **Type:** create-entity
- **Source:** projectiles.lua

### crash-site-spaceship-wreck-small-3
- **Internal name:** `crash-site-spaceship-wreck-small-3`
- **Type:** create-entity
- **Source:** crash-site.lua

### defender-capsule
- **Internal name:** `defender-capsule`
- **Type:** create-entity
- **Source:** projectiles.lua

### stone-furnace-explosion
- **Internal name:** `stone-furnace-explosion`
- **Type:** create-entity
- **Source:** explosions.lua

### transport-belt-explosion-base
- **Internal name:** `transport-belt-explosion-base`
- **Type:** create-entity
- **Source:** explosions.lua

### wooden-chest-wooden-splinter-particle-medium
- **Internal name:** `wooden-chest-wooden-splinter-particle-medium`
- **Type:** create-entity
- **Source:** explosions.lua


## Create Explosion

### Laser bubble
- **Internal name:** `laser-bubble`
- **Type:** create-explosion
- **Source:** explosions.lua

### __base__/graphics/entity/sparks/sparks-04.png
- **Internal name:** `__base__/graphics/entity/sparks/sparks-04.png`
- **Type:** create-explosion
- **Source:** flying-robots.lua

### assembling-machine-2-explosion
- **Internal name:** `assembling-machine-2-explosion`
- **Type:** create-explosion
- **Source:** explosions.lua

### atomic-bomb-wave-spawns-nuclear-smoke
- **Internal name:** `atomic-bomb-wave-spawns-nuclear-smoke`
- **Type:** create-explosion
- **Source:** atomic-bomb.lua

### buffer-chest-metal-particle-medium
- **Internal name:** `buffer-chest-metal-particle-medium`
- **Type:** create-explosion
- **Source:** explosions.lua

### electric-furnace-explosion
- **Internal name:** `electric-furnace-explosion`
- **Type:** create-explosion
- **Source:** explosions.lua

### medium-electric-pole-metal-particle-small
- **Internal name:** `medium-electric-pole-metal-particle-small`
- **Type:** create-explosion
- **Source:** explosions.lua

### small-worm-die
- **Internal name:** `small-worm-die`
- **Type:** create-explosion
- **Source:** explosions.lua

### storage-tank-metal-particle-medium
- **Internal name:** `storage-tank-metal-particle-medium`
- **Type:** create-explosion
- **Source:** explosions.lua


## Create Fire

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-2-shadow.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-2-shadow.png`
- **Type:** create-fire
- **Source:** crash-site.lua

### __base__/graphics/entity/fire-flame/fire-flame-01.png
- **Internal name:** `__base__/graphics/entity/fire-flame/fire-flame-01.png`
- **Type:** create-fire
- **Source:** fire.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-east-shadow.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-east-shadow.png`
- **Type:** create-fire
- **Source:** fire.lua


## Create Particle

### Blood explosion huge
- **Internal name:** `blood-explosion-huge`
- **Type:** create-particle
- **Source:** explosions.lua

### Blood explosion small
- **Internal name:** `blood-explosion-small`
- **Type:** create-particle
- **Source:** explosions.lua

### Blood fountain hit spray
- **Internal name:** `blood-fountain-hit-spray`
- **Type:** create-particle
- **Source:** hit-effects.lua

### Defender
- **Internal name:** `defender`
- **Type:** create-particle
- **Health:** 60
- **Source:** flying-robots.lua

### Distractor
- **Internal name:** `distractor`
- **Type:** create-particle
- **Health:** 180
- **Source:** flying-robots.lua

### Grenade explosion
- **Internal name:** `grenade-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### Massive explosion
- **Internal name:** `massive-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### Rock damaged explosion
- **Internal name:** `rock-damaged-explosion`
- **Type:** create-particle
- **Source:** hit-effects.lua

### Spark explosion higher
- **Internal name:** `spark-explosion-higher`
- **Type:** create-particle
- **Source:** hit-effects.lua

### Uranium cannon shell explosion
- **Internal name:** `uranium-cannon-shell-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### __base__/sound/car-metal-impact-6.ogg
- **Internal name:** `__base__/sound/car-metal-impact-6.ogg`
- **Type:** create-particle
- **Source:** explosions.lua

### accumulator-metal-particle-big
- **Internal name:** `accumulator-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### accumulator-metal-particle-medium
- **Internal name:** `accumulator-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### accumulator-metal-particle-small
- **Internal name:** `accumulator-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### arithmetic-combinator-metal-particle-medium
- **Internal name:** `arithmetic-combinator-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### arithmetic-combinator-metal-particle-small
- **Internal name:** `arithmetic-combinator-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### artillery-cannon-muzzle-flash
- **Internal name:** `artillery-cannon-muzzle-flash`
- **Type:** create-particle
- **Source:** explosions.lua

### artillery-turret-explosion
- **Internal name:** `artillery-turret-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### artillery-wagon-metal-particle-big-yellow
- **Internal name:** `artillery-wagon-metal-particle-big-yellow`
- **Type:** create-particle
- **Source:** explosions.lua

### artillery-wagon-metal-particle-medium
- **Internal name:** `artillery-wagon-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### artillery-wagon-metal-particle-small
- **Internal name:** `artillery-wagon-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### assembling-machine-1-metal-particle-big
- **Internal name:** `assembling-machine-1-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### assembling-machine-1-metal-particle-medium
- **Internal name:** `assembling-machine-1-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### assembling-machine-3-explosion
- **Internal name:** `assembling-machine-3-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### assembling-machine-3-metal-particle-big
- **Internal name:** `assembling-machine-3-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### beacon-metal-particle-big
- **Internal name:** `beacon-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### beacon-metal-particle-medium
- **Internal name:** `beacon-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### big-electric-pole-metal-particle-small
- **Internal name:** `big-electric-pole-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### big-rock-stone-particle-small
- **Internal name:** `big-rock-stone-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### big-rock-stone-particle-tiny
- **Internal name:** `big-rock-stone-particle-tiny`
- **Type:** create-particle
- **Source:** explosions.lua

### big-spitter-die
- **Internal name:** `big-spitter-die`
- **Type:** create-particle
- **Source:** explosions.lua

### biter-spawner-die
- **Internal name:** `biter-spawner-die`
- **Type:** create-particle
- **Source:** explosions.lua

### blood-particle
- **Internal name:** `blood-particle`
- **Type:** create-particle
- **Source:** biter-die-effects.lua

### blood-particle-carpet
- **Internal name:** `blood-particle-carpet`
- **Type:** create-particle
- **Source:** biter-die-effects.lua

### blood-particle-carpet-small
- **Internal name:** `blood-particle-carpet-small`
- **Type:** create-particle
- **Source:** biter-die-effects.lua

### blood-particle-lower-layer
- **Internal name:** `blood-particle-lower-layer`
- **Type:** create-particle
- **Source:** biter-die-effects.lua

### blood-particle-lower-layer-small
- **Internal name:** `blood-particle-lower-layer-small`
- **Type:** create-particle
- **Source:** biter-die-effects.lua

### boiler-explosion
- **Internal name:** `boiler-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### boiler-metal-particle-medium
- **Internal name:** `boiler-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### brown-dust-vehicle-particle
- **Internal name:** `brown-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### bulk-inserter-metal-particle-medium
- **Internal name:** `bulk-inserter-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### bulk-inserter-metal-particle-small
- **Internal name:** `bulk-inserter-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### burner-mining-drill-glass-particle-small
- **Internal name:** `burner-mining-drill-glass-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### burner-mining-drill-mechanical-component-particle-medium
- **Internal name:** `burner-mining-drill-mechanical-component-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### burner-mining-drill-metal-particle-medium
- **Internal name:** `burner-mining-drill-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### cable-and-electronics-particle-small-medium
- **Internal name:** `cable-and-electronics-particle-small-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### car-explosion
- **Internal name:** `car-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### car-metal-particle-big
- **Internal name:** `car-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### cargo-wagon-explosion
- **Internal name:** `cargo-wagon-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### cargo-wagon-metal-particle-big
- **Internal name:** `cargo-wagon-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### cargo-wagon-metal-particle-medium
- **Internal name:** `cargo-wagon-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### centrifuge-explosion
- **Internal name:** `centrifuge-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### centrifuge-metal-particle-big
- **Internal name:** `centrifuge-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### centrifuge-metal-particle-medium
- **Internal name:** `centrifuge-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### chemical-plant-explosion
- **Internal name:** `chemical-plant-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### chemical-plant-metal-particle-big
- **Internal name:** `chemical-plant-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### constant-combinator-explosion
- **Internal name:** `constant-combinator-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### constant-combinator-metal-particle-big
- **Internal name:** `constant-combinator-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### constant-combinator-metal-particle-medium
- **Internal name:** `constant-combinator-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### construction-robot-explosion
- **Internal name:** `construction-robot-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### construction-robot-metal-particle-medium
- **Internal name:** `construction-robot-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### decider-combinator-explosion
- **Internal name:** `decider-combinator-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### decider-combinator-metal-particle-big
- **Internal name:** `decider-combinator-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### defender-robot-explosion
- **Internal name:** `defender-robot-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### destroyer-robot-explosion
- **Internal name:** `destroyer-robot-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### destroyer-robot-metal-particle-medium
- **Internal name:** `destroyer-robot-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### dirt-1-dust-particle
- **Internal name:** `dirt-1-dust-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-1-dust-tank-front-particle
- **Internal name:** `dirt-1-dust-tank-front-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-1-dust-vehicle-particle
- **Internal name:** `dirt-1-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-1-stone-character-particle-tiny
- **Internal name:** `dirt-1-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-1-stone-vehicle-particle-small
- **Internal name:** `dirt-1-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-1-stone-vehicle-particle-tiny
- **Internal name:** `dirt-1-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-2-dust-particle
- **Internal name:** `dirt-2-dust-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-2-dust-tank-front-particle
- **Internal name:** `dirt-2-dust-tank-front-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-2-dust-vehicle-particle
- **Internal name:** `dirt-2-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-2-stone-character-particle-tiny
- **Internal name:** `dirt-2-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-2-stone-vehicle-particle-small
- **Internal name:** `dirt-2-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-2-stone-vehicle-particle-tiny
- **Internal name:** `dirt-2-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-3-dust-particle
- **Internal name:** `dirt-3-dust-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-3-dust-tank-front-particle
- **Internal name:** `dirt-3-dust-tank-front-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-3-dust-vehicle-particle
- **Internal name:** `dirt-3-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-3-stone-character-particle-tiny
- **Internal name:** `dirt-3-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-3-stone-vehicle-particle-small
- **Internal name:** `dirt-3-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-3-stone-vehicle-particle-tiny
- **Internal name:** `dirt-3-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-4-dust-particle
- **Internal name:** `dirt-4-dust-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-4-dust-tank-front-particle
- **Internal name:** `dirt-4-dust-tank-front-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-4-dust-vehicle-particle
- **Internal name:** `dirt-4-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-4-stone-character-particle-tiny
- **Internal name:** `dirt-4-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-4-stone-vehicle-particle-small
- **Internal name:** `dirt-4-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-4-stone-vehicle-particle-tiny
- **Internal name:** `dirt-4-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-5-dust-particle
- **Internal name:** `dirt-5-dust-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-5-dust-tank-front-particle
- **Internal name:** `dirt-5-dust-tank-front-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-5-dust-vehicle-particle
- **Internal name:** `dirt-5-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-5-stone-character-particle-tiny
- **Internal name:** `dirt-5-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-5-stone-vehicle-particle-small
- **Internal name:** `dirt-5-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-5-stone-vehicle-particle-tiny
- **Internal name:** `dirt-5-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-6-dust-particle
- **Internal name:** `dirt-6-dust-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-6-dust-tank-front-particle
- **Internal name:** `dirt-6-dust-tank-front-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-6-dust-vehicle-particle
- **Internal name:** `dirt-6-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-6-stone-character-particle-tiny
- **Internal name:** `dirt-6-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-6-stone-vehicle-particle-small
- **Internal name:** `dirt-6-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-6-stone-vehicle-particle-tiny
- **Internal name:** `dirt-6-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-7-dust-tank-front-particle
- **Internal name:** `dirt-7-dust-tank-front-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-7-dust-vehicle-particle
- **Internal name:** `dirt-7-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-7-stone-character-particle-tiny
- **Internal name:** `dirt-7-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-7-stone-vehicle-particle-small
- **Internal name:** `dirt-7-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dirt-7-stone-vehicle-particle-tiny
- **Internal name:** `dirt-7-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### display-panel-explosion
- **Internal name:** `display-panel-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### distractor-robot-metal-particle-small
- **Internal name:** `distractor-robot-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### dry-dirt-dust-particle
- **Internal name:** `dry-dirt-dust-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dry-dirt-dust-tank-front-particle
- **Internal name:** `dry-dirt-dust-tank-front-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dry-dirt-dust-vehicle-particle
- **Internal name:** `dry-dirt-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dry-dirt-stone-character-particle-tiny
- **Internal name:** `dry-dirt-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dry-dirt-stone-vehicle-particle-small
- **Internal name:** `dry-dirt-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### dry-dirt-stone-vehicle-particle-tiny
- **Internal name:** `dry-dirt-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### electric-mining-drill-long-metal-particle-medium
- **Internal name:** `electric-mining-drill-long-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### electric-mining-drill-mechanical-component-particle-medium
- **Internal name:** `electric-mining-drill-mechanical-component-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### entity-name.uranium-cannon-explosion
- **Internal name:** `entity-name.uranium-cannon-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### explosion-remnants-particle
- **Internal name:** `explosion-remnants-particle`
- **Type:** create-particle
- **Source:** explosions.lua

### express-splitter-explosion
- **Internal name:** `express-splitter-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### express-splitter-long-metal-particle-medium
- **Internal name:** `express-splitter-long-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### express-splitter-metal-particle-medium
- **Internal name:** `express-splitter-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### express-splitter-metal-particle-small
- **Internal name:** `express-splitter-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### express-transport-belt-explosion-base
- **Internal name:** `express-transport-belt-explosion-base`
- **Type:** create-particle
- **Source:** explosions.lua

### express-transport-belt-metal-particle-medium
- **Internal name:** `express-transport-belt-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### express-transport-belt-metal-particle-small
- **Internal name:** `express-transport-belt-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### express-underground-belt-explosion-base
- **Internal name:** `express-underground-belt-explosion-base`
- **Type:** create-particle
- **Source:** explosions.lua

### express-underground-belt-metal-particle-medium
- **Internal name:** `express-underground-belt-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### fast-splitter-long-metal-particle-medium
- **Internal name:** `fast-splitter-long-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### fast-splitter-mechanical-component-particle-medium
- **Internal name:** `fast-splitter-mechanical-component-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### fast-splitter-metal-particle-big
- **Internal name:** `fast-splitter-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### fast-splitter-metal-particle-small
- **Internal name:** `fast-splitter-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### fast-transport-belt-explosion
- **Internal name:** `fast-transport-belt-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### fast-transport-belt-explosion-base
- **Internal name:** `fast-transport-belt-explosion-base`
- **Type:** create-particle
- **Source:** explosions.lua

### fast-transport-belt-mechanical-component-particle-medium
- **Internal name:** `fast-transport-belt-mechanical-component-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### fast-underground-belt-explosion
- **Internal name:** `fast-underground-belt-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### fast-underground-belt-metal-particle-medium
- **Internal name:** `fast-underground-belt-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### fast-underground-belt-metal-particle-medium-red
- **Internal name:** `fast-underground-belt-metal-particle-medium-red`
- **Type:** create-particle
- **Source:** explosions.lua

### fast-underground-belt-metal-particle-small
- **Internal name:** `fast-underground-belt-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### flamethrower-turret-explosion
- **Internal name:** `flamethrower-turret-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### fluid-wagon-explosion
- **Internal name:** `fluid-wagon-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### fluid-wagon-metal-particle-big
- **Internal name:** `fluid-wagon-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### fluid-wagon-metal-particle-medium
- **Internal name:** `fluid-wagon-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### fluid-wagon-metal-particle-small
- **Internal name:** `fluid-wagon-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### flying-robot-damaged-explosion-particle
- **Internal name:** `flying-robot-damaged-explosion-particle`
- **Type:** create-particle
- **Source:** hit-effects.lua

### gate-metal-particle-medium
- **Internal name:** `gate-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### gate-metal-particle-small
- **Internal name:** `gate-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### grass-1-stone-character-particle-tiny
- **Internal name:** `grass-1-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### grass-1-stone-vehicle-particle-small
- **Internal name:** `grass-1-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### grass-1-stone-vehicle-particle-tiny
- **Internal name:** `grass-1-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### grass-2-stone-vehicle-particle-small
- **Internal name:** `grass-2-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### grass-2-stone-vehicle-particle-tiny
- **Internal name:** `grass-2-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### grass-3-stone-character-particle-tiny
- **Internal name:** `grass-3-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### grass-3-stone-vehicle-particle-small
- **Internal name:** `grass-3-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### grass-3-stone-vehicle-particle-tiny
- **Internal name:** `grass-3-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### grass-3-vegetation-character-particle-small-medium
- **Internal name:** `grass-3-vegetation-character-particle-small-medium`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### grass-3-vegetation-vehicle-particle-small-medium
- **Internal name:** `grass-3-vegetation-vehicle-particle-small-medium`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### grass-4-stone-vehicle-particle-small
- **Internal name:** `grass-4-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### grass-4-stone-vehicle-particle-tiny
- **Internal name:** `grass-4-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### gun-turret-metal-particle-medium
- **Internal name:** `gun-turret-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### gun-turret-metal-particle-small
- **Internal name:** `gun-turret-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### guts-entrails-particle-big
- **Internal name:** `guts-entrails-particle-big`
- **Type:** create-particle
- **Source:** biter-die-effects.lua

### heat-exchanger-metal-particle-big
- **Internal name:** `heat-exchanger-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### heat-pipe-explosion
- **Internal name:** `heat-pipe-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### heat-pipe-metal-particle-medium
- **Internal name:** `heat-pipe-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### heat-pipe-metal-particle-small
- **Internal name:** `heat-pipe-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### inserter-explosion
- **Internal name:** `inserter-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### inserter-metal-particle-medium
- **Internal name:** `inserter-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### inserter-metal-particle-small
- **Internal name:** `inserter-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### internal-fluids-particle
- **Internal name:** `internal-fluids-particle`
- **Type:** create-particle
- **Source:** biter-die-effects.lua

### iron-chest-metal-particle-small
- **Internal name:** `iron-chest-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### lab-explosion
- **Internal name:** `lab-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### lab-metal-particle-big
- **Internal name:** `lab-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### lamp-glass-particle-small
- **Internal name:** `lamp-glass-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### land-mine-explosion
- **Internal name:** `land-mine-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### landfill-dust-particle
- **Internal name:** `landfill-dust-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### landfill-dust-tank-front-particle
- **Internal name:** `landfill-dust-tank-front-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### landfill-dust-vehicle-particle
- **Internal name:** `landfill-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### landfill-stone-character-particle-tiny
- **Internal name:** `landfill-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### landfill-stone-vehicle-particle-small
- **Internal name:** `landfill-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### landfill-stone-vehicle-particle-tiny
- **Internal name:** `landfill-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### laser-turret-explosion
- **Internal name:** `laser-turret-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### laser-turret-metal-particle-big
- **Internal name:** `laser-turret-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### locomotive-mechanical-component-particle-medium
- **Internal name:** `locomotive-mechanical-component-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### locomotive-metal-particle-small
- **Internal name:** `locomotive-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### logistic-robot-explosion
- **Internal name:** `logistic-robot-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### medium-spitter-die
- **Internal name:** `medium-spitter-die`
- **Type:** create-particle
- **Source:** explosions.lua

### nuclear-ground
- **Internal name:** `nuclear-ground`
- **Type:** create-particle
- **Source:** explosions.lua

### nuclear-ground-dust-particle
- **Internal name:** `nuclear-ground-dust-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### nuclear-ground-dust-tank-front-particle
- **Internal name:** `nuclear-ground-dust-tank-front-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### nuclear-ground-dust-vehicle-particle
- **Internal name:** `nuclear-ground-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### nuclear-ground-stone-character-particle-tiny
- **Internal name:** `nuclear-ground-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### nuclear-ground-stone-vehicle-particle-small
- **Internal name:** `nuclear-ground-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### nuclear-ground-stone-vehicle-particle-tiny
- **Internal name:** `nuclear-ground-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### nuclear-reactor-explosion
- **Internal name:** `nuclear-reactor-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### nuclear-reactor-mechanical-component-particle-medium
- **Internal name:** `nuclear-reactor-mechanical-component-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### nuclear-reactor-metal-particle-small
- **Internal name:** `nuclear-reactor-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### offshore-pump-glass-particle-small
- **Internal name:** `offshore-pump-glass-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### offshore-pump-mechanical-component-particle-medium
- **Internal name:** `offshore-pump-mechanical-component-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### oil-refinery-explosion
- **Internal name:** `oil-refinery-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### oil-refinery-metal-particle-big
- **Internal name:** `oil-refinery-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### oil-refinery-metal-particle-big-tint
- **Internal name:** `oil-refinery-metal-particle-big-tint`
- **Type:** create-particle
- **Source:** explosions.lua

### passive-provider-chest-metal-particle-medium
- **Internal name:** `passive-provider-chest-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### passive-provider-chest-metal-particle-small
- **Internal name:** `passive-provider-chest-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### pipe-explosion-base
- **Internal name:** `pipe-explosion-base`
- **Type:** create-particle
- **Source:** explosions.lua

### pipe-metal-particle-medium
- **Internal name:** `pipe-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### pipe-to-ground-explosion-base
- **Internal name:** `pipe-to-ground-explosion-base`
- **Type:** create-particle
- **Source:** explosions.lua

### power-switch-metal-particle-medium
- **Internal name:** `power-switch-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### power-switch-metal-particle-small
- **Internal name:** `power-switch-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### programmable-speaker-wooden-splinter-particle-medium
- **Internal name:** `programmable-speaker-wooden-splinter-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### programmable-speaker-wooden-splinter-particle-small
- **Internal name:** `programmable-speaker-wooden-splinter-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### pump-explosion
- **Internal name:** `pump-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### pump-metal-particle-big
- **Internal name:** `pump-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### pumpjack-mechanical-component-particle-medium
- **Internal name:** `pumpjack-mechanical-component-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### pumpjack-metal-particle-small
- **Internal name:** `pumpjack-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### radar-explosion
- **Internal name:** `radar-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### radar-long-metal-particle-medium
- **Internal name:** `radar-long-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### rail-chain-signal-explosion
- **Internal name:** `rail-chain-signal-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### rail-chain-signal-glass-particle-small
- **Internal name:** `rail-chain-signal-glass-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### rail-chain-signal-metal-particle-medium
- **Internal name:** `rail-chain-signal-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### rail-chain-signal-metal-particle-small
- **Internal name:** `rail-chain-signal-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### rail-explosion
- **Internal name:** `rail-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### rail-signal-explosion
- **Internal name:** `rail-signal-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### rail-signal-glass-particle-small-yellow
- **Internal name:** `rail-signal-glass-particle-small-yellow`
- **Type:** create-particle
- **Source:** explosions.lua

### rail-signal-metal-particle-medium
- **Internal name:** `rail-signal-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### rail-wooden-splinter-particle-medium
- **Internal name:** `rail-wooden-splinter-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### red-desert-0-dust-particle
- **Internal name:** `red-desert-0-dust-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-0-dust-tank-front-particle
- **Internal name:** `red-desert-0-dust-tank-front-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-0-dust-vehicle-particle
- **Internal name:** `red-desert-0-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-0-stone-character-particle-tiny
- **Internal name:** `red-desert-0-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-0-stone-vehicle-particle-small
- **Internal name:** `red-desert-0-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-0-stone-vehicle-particle-tiny
- **Internal name:** `red-desert-0-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-1-dust-particle
- **Internal name:** `red-desert-1-dust-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-1-dust-tank-front-particle
- **Internal name:** `red-desert-1-dust-tank-front-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-1-dust-vehicle-particle
- **Internal name:** `red-desert-1-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-1-stone-character-particle-tiny
- **Internal name:** `red-desert-1-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-1-stone-vehicle-particle-small
- **Internal name:** `red-desert-1-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-1-stone-vehicle-particle-tiny
- **Internal name:** `red-desert-1-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-2-dust-particle
- **Internal name:** `red-desert-2-dust-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-2-dust-tank-front-particle
- **Internal name:** `red-desert-2-dust-tank-front-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-2-dust-vehicle-particle
- **Internal name:** `red-desert-2-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-2-stone-character-particle-tiny
- **Internal name:** `red-desert-2-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-2-stone-vehicle-particle-small
- **Internal name:** `red-desert-2-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-2-stone-vehicle-particle-tiny
- **Internal name:** `red-desert-2-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-3-dust-particle
- **Internal name:** `red-desert-3-dust-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-3-dust-tank-front-particle
- **Internal name:** `red-desert-3-dust-tank-front-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-3-dust-vehicle-particle
- **Internal name:** `red-desert-3-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-3-stone-character-particle-tiny
- **Internal name:** `red-desert-3-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-3-stone-vehicle-particle-small
- **Internal name:** `red-desert-3-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### red-desert-3-stone-vehicle-particle-tiny
- **Internal name:** `red-desert-3-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### requester-chest-metal-particle-small
- **Internal name:** `requester-chest-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### roboport-explosion
- **Internal name:** `roboport-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### roboport-metal-particle-big
- **Internal name:** `roboport-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### roboport-metal-particle-medium
- **Internal name:** `roboport-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### roboport-metal-particle-small
- **Internal name:** `roboport-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### rock-damage-stone-particle-tiny
- **Internal name:** `rock-damage-stone-particle-tiny`
- **Type:** create-particle
- **Source:** hit-effects.lua

### rocket-silo-metal-particle-small
- **Internal name:** `rocket-silo-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### sand-1-dust-particle
- **Internal name:** `sand-1-dust-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### sand-1-dust-tank-front-particle
- **Internal name:** `sand-1-dust-tank-front-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### sand-1-dust-vehicle-particle
- **Internal name:** `sand-1-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### sand-1-stone-character-particle-tiny
- **Internal name:** `sand-1-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### sand-1-stone-vehicle-particle-small
- **Internal name:** `sand-1-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### sand-1-stone-vehicle-particle-tiny
- **Internal name:** `sand-1-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### sand-2-dust-particle
- **Internal name:** `sand-2-dust-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### sand-2-dust-tank-front-particle
- **Internal name:** `sand-2-dust-tank-front-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### sand-2-dust-vehicle-particle
- **Internal name:** `sand-2-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### sand-2-stone-character-particle-tiny
- **Internal name:** `sand-2-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### sand-2-stone-vehicle-particle-small
- **Internal name:** `sand-2-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### sand-2-stone-vehicle-particle-tiny
- **Internal name:** `sand-2-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### sand-3-dust-particle
- **Internal name:** `sand-3-dust-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### sand-3-dust-tank-front-particle
- **Internal name:** `sand-3-dust-tank-front-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### sand-3-dust-vehicle-particle
- **Internal name:** `sand-3-dust-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### sand-3-stone-character-particle-tiny
- **Internal name:** `sand-3-stone-character-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### sand-3-stone-vehicle-particle-small
- **Internal name:** `sand-3-stone-vehicle-particle-small`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### sand-3-stone-vehicle-particle-tiny
- **Internal name:** `sand-3-stone-vehicle-particle-tiny`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### selector-combinator-metal-particle-medium
- **Internal name:** `selector-combinator-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### selector-combinator-metal-particle-small
- **Internal name:** `selector-combinator-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### shallow-water-2-vehicle-particle
- **Internal name:** `shallow-water-2-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### shallow-water-vehicle-particle
- **Internal name:** `shallow-water-vehicle-particle`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### small-biter-die
- **Internal name:** `small-biter-die`
- **Type:** create-particle
- **Source:** explosions.lua

### small-electric-pole-explosion
- **Internal name:** `small-electric-pole-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### small-electric-pole-wooden-splinter-particle-medium
- **Internal name:** `small-electric-pole-wooden-splinter-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### small-electric-pole-wooden-splinter-particle-small
- **Internal name:** `small-electric-pole-wooden-splinter-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### small-spitter-die
- **Internal name:** `small-spitter-die`
- **Type:** create-particle
- **Source:** explosions.lua

### solar-panel-explosion
- **Internal name:** `solar-panel-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### solar-panel-long-metal-particle-medium
- **Internal name:** `solar-panel-long-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### solar-panel-metal-particle-small
- **Internal name:** `solar-panel-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### spidertron-glass-particle-small
- **Internal name:** `spidertron-glass-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### spidertron-long-metal-particle-medium
- **Internal name:** `spidertron-long-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### spidertron-metal-particle-small
- **Internal name:** `spidertron-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### spitter-spawner-die
- **Internal name:** `spitter-spawner-die`
- **Type:** create-particle
- **Source:** explosions.lua

### splitter-explosion
- **Internal name:** `splitter-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### splitter-mechanical-component-particle-medium
- **Internal name:** `splitter-mechanical-component-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### splitter-metal-particle-big
- **Internal name:** `splitter-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### steam-engine-metal-particle-big
- **Internal name:** `steam-engine-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### steam-engine-metal-particle-medium
- **Internal name:** `steam-engine-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### steam-engine-metal-particle-small
- **Internal name:** `steam-engine-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### steam-turbine-mechanical-component-particle-medium
- **Internal name:** `steam-turbine-mechanical-component-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### steam-turbine-metal-particle-medium
- **Internal name:** `steam-turbine-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### steam-turbine-metal-particle-small
- **Internal name:** `steam-turbine-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### steel-chest-explosion
- **Internal name:** `steel-chest-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### steel-furnace-explosion
- **Internal name:** `steel-furnace-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### storage-chest-explosion
- **Internal name:** `storage-chest-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### substation-explosion
- **Internal name:** `substation-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### substation-metal-particle-big
- **Internal name:** `substation-metal-particle-big`
- **Type:** create-particle
- **Source:** explosions.lua

### tank-metal-particle-medium
- **Internal name:** `tank-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### tank-metal-particle-small
- **Internal name:** `tank-metal-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### train-stop-explosion
- **Internal name:** `train-stop-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### train-stop-glass-particle-small
- **Internal name:** `train-stop-glass-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### train-stop-metal-particle-medium
- **Internal name:** `train-stop-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### transport-belt-wooden-splinter-particle-medium
- **Internal name:** `transport-belt-wooden-splinter-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### tree_09
- **Internal name:** `tree_09`
- **Type:** create-particle
- **Source:** trees.lua

### tree_09_brown
- **Internal name:** `tree_09_brown`
- **Type:** create-particle
- **Source:** trees.lua

### underground-belt-explosion-base
- **Internal name:** `underground-belt-explosion-base`
- **Type:** create-particle
- **Source:** explosions.lua

### underground-belt-metal-particle-medium
- **Internal name:** `underground-belt-metal-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### uranium-cannon-explosion
- **Internal name:** `uranium-cannon-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### vegetation-character-particle-small-medium
- **Internal name:** `vegetation-character-particle-small-medium`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### vegetation-vehicle-particle-small-medium
- **Internal name:** `vegetation-vehicle-particle-small-medium`
- **Type:** create-particle
- **Source:** movement-triggers.lua

### wall-explosion
- **Internal name:** `wall-explosion`
- **Type:** create-particle
- **Source:** explosions.lua

### wall-stone-particle-medium
- **Internal name:** `wall-stone-particle-medium`
- **Type:** create-particle
- **Source:** explosions.lua

### wall-stone-particle-small
- **Internal name:** `wall-stone-particle-small`
- **Type:** create-particle
- **Source:** explosions.lua

### wooden-chest-explosion
- **Internal name:** `wooden-chest-explosion`
- **Type:** create-particle
- **Source:** explosions.lua


## Create Smoke

### __base__/graphics/entity/assembling-machine-2/assembling-machine-2.png
- **Internal name:** `__base__/graphics/entity/assembling-machine-2/assembling-machine-2.png`
- **Type:** create-smoke
- **Source:** entities.lua

### __core__/sound/build-ghost-small.ogg
- **Internal name:** `__core__/sound/build-ghost-small.ogg`
- **Type:** create-smoke
- **Source:** entities.lua


## Create Sticker

### __base__/graphics/entity/beam/beam-body-1.png
- **Internal name:** `__base__/graphics/entity/beam/beam-body-1.png`
- **Type:** create-sticker
- **Source:** beams.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-north.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-north.png`
- **Type:** create-sticker
- **Source:** fire.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-west.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-west.png`
- **Type:** create-sticker
- **Source:** fire.lua

### acid-splash-fire-worm-small
- **Internal name:** `acid-splash-fire-worm-small`
- **Type:** create-sticker
- **Source:** enemy-projectiles.lua


## Create Trivial Smoke

### __base__/sound/fight/car-no-fuel-1.ogg
- **Internal name:** `__base__/sound/fight/car-no-fuel-1.ogg`
- **Type:** create-trivial-smoke
- **Source:** entities.lua

### accumulator-explosion
- **Internal name:** `accumulator-explosion`
- **Type:** create-trivial-smoke
- **Source:** explosions.lua

### assembling-machine-1-explosion
- **Internal name:** `assembling-machine-1-explosion`
- **Type:** create-trivial-smoke
- **Source:** explosions.lua

### atomic-bomb-wave-spawns-cluster-nuke-explosion
- **Internal name:** `atomic-bomb-wave-spawns-cluster-nuke-explosion`
- **Type:** create-trivial-smoke
- **Source:** atomic-bomb.lua

### burner-inserter-mechanical-component-particle-medium
- **Internal name:** `burner-inserter-mechanical-component-particle-medium`
- **Type:** create-trivial-smoke
- **Source:** explosions.lua

### distractor-robot-metal-particle-medium
- **Internal name:** `distractor-robot-metal-particle-medium`
- **Type:** create-trivial-smoke
- **Source:** explosions.lua

### offshore-pump-metal-particle-small
- **Internal name:** `offshore-pump-metal-particle-small`
- **Type:** create-trivial-smoke
- **Source:** explosions.lua

### passive-provider-chest-explosion
- **Internal name:** `passive-provider-chest-explosion`
- **Type:** create-trivial-smoke
- **Source:** explosions.lua


## Crude Oil

### Fire
- **Internal name:** `fire-flame`
- **Type:** crude-oil
- **Source:** fire.lua


## Curved Rail B

### Curved rail
- **Internal name:** `curved-rail-b`
- **Type:** curved-rail-b
- **Source:** trains.lua


## Custom Input

### crash-site-spaceship-wreck-small-4
- **Internal name:** `crash-site-spaceship-wreck-small-4`
- **Type:** custom-input
- **Source:** crash-site.lua


## Damage

### Medium tinted scorchmark
- **Internal name:** `medium-scorchmark-tintable`
- **Type:** damage
- **Source:** projectiles.lua

### Steam engine
- **Internal name:** `steam-engine`
- **Type:** damage
- **Description:** Consumes steam to create electric energy.
- **Health:** 400
- **Source:** entities.lua

### __base__/graphics/entity/beam/tileable-beam-END.png
- **Internal name:** `__base__/graphics/entity/beam/tileable-beam-END.png`
- **Type:** damage
- **Source:** beams.lua

### __base__/graphics/entity/big-electric-pole/big-electric-pole.png
- **Internal name:** `__base__/graphics/entity/big-electric-pole/big-electric-pole.png`
- **Type:** damage
- **Source:** entities.lua

### __base__/graphics/entity/boiler/boiler-reflection.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-reflection.png`
- **Type:** damage
- **Source:** entities.lua

### __base__/graphics/entity/burner-inserter/burner-inserter-hand-open.png
- **Internal name:** `__base__/graphics/entity/burner-inserter/burner-inserter-hand-open.png`
- **Type:** damage
- **Source:** entities.lua

### __base__/graphics/entity/burner-inserter/burner-inserter-platform.png
- **Internal name:** `__base__/graphics/entity/burner-inserter/burner-inserter-platform.png`
- **Type:** damage
- **Source:** entities.lua

### __base__/graphics/entity/combat-robot-capsule/distractor-capsule-shadow.png
- **Internal name:** `__base__/graphics/entity/combat-robot-capsule/distractor-capsule-shadow.png`
- **Type:** damage
- **Source:** projectiles.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-north-mask.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-north-mask.png`
- **Type:** damage
- **Source:** fire.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-west-mask.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-west-mask.png`
- **Type:** damage
- **Source:** fire.lua

### __base__/graphics/entity/laser-turret/laser-end-light.png
- **Internal name:** `__base__/graphics/entity/laser-turret/laser-end-light.png`
- **Type:** damage
- **Source:** beams.lua

### __base__/graphics/entity/laser-turret/laser-ground-light-body.png
- **Internal name:** `__base__/graphics/entity/laser-turret/laser-ground-light-body.png`
- **Type:** damage
- **Source:** beams.lua

### __base__/graphics/entity/slowdown-capsule/slowdown-capsule.png
- **Internal name:** `__base__/graphics/entity/slowdown-capsule/slowdown-capsule.png`
- **Type:** damage
- **Source:** projectiles.lua

### __base__/graphics/entity/sparks/sparks-06.png
- **Internal name:** `__base__/graphics/entity/sparks/sparks-06.png`
- **Type:** damage
- **Source:** flying-robots.lua

### __base__/sound/creatures/spawner.ogg
- **Internal name:** `__base__/sound/creatures/spawner.ogg`
- **Type:** damage
- **Source:** enemies.lua

### __core__/sound/build-ghost-tile.ogg
- **Internal name:** `__core__/sound/build-ghost-tile.ogg`
- **Type:** damage
- **Source:** entities.lua

### acid-sticker-small
- **Internal name:** `acid-sticker-small`
- **Type:** damage
- **Source:** enemy-projectiles.lua

### artillery-smoke
- **Internal name:** `artillery-smoke`
- **Type:** damage
- **Source:** projectiles.lua

### cliff-explosives
- **Internal name:** `cliff-explosives`
- **Type:** damage
- **Source:** projectiles.lua

### flamethrower-fire-stream
- **Internal name:** `flamethrower-fire-stream`
- **Type:** damage
- **Source:** fire.lua

### grenade
- **Internal name:** `grenade`
- **Type:** damage
- **Source:** projectiles.lua

### laser
- **Internal name:** `laser`
- **Type:** damage
- **Source:** projectiles.lua


## Decider Combinator

### Decider combinator
- **Internal name:** `decider-combinator`
- **Type:** decider-combinator
- **Description:** Compares circuit network signals.
- **Health:** 150
- **Source:** circuit-network.lua


## Deconstructible Tile Proxy

### __base__/graphics/entity/iron-chest/iron-chest-shadow.png
- **Internal name:** `__base__/graphics/entity/iron-chest/iron-chest-shadow.png`
- **Type:** deconstructible-tile-proxy
- **Source:** entities.lua


## Deliver Impact Combination

### __base__/sound/armor-close.ogg
- **Internal name:** `__base__/sound/armor-close.ogg`
- **Type:** deliver-impact-combination
- **Source:** sounds.lua

### __base__/sound/artillery-close.ogg
- **Internal name:** `__base__/sound/artillery-close.ogg`
- **Type:** deliver-impact-combination
- **Source:** sounds.lua

### __base__/sound/cargo-wagon-close.ogg
- **Internal name:** `__base__/sound/cargo-wagon-close.ogg`
- **Type:** deliver-impact-combination
- **Source:** sounds.lua

### __base__/sound/cargo-wagon-open.ogg
- **Internal name:** `__base__/sound/cargo-wagon-open.ogg`
- **Type:** deliver-impact-combination
- **Source:** sounds.lua

### __base__/sound/express-transport-belt.ogg
- **Internal name:** `__base__/sound/express-transport-belt.ogg`
- **Type:** deliver-impact-combination
- **Source:** sounds.lua

### __base__/sound/fast-transport-belt.ogg
- **Internal name:** `__base__/sound/fast-transport-belt.ogg`
- **Type:** deliver-impact-combination
- **Source:** sounds.lua

### __base__/sound/open-close/ammo-large-close.ogg
- **Internal name:** `__base__/sound/open-close/ammo-large-close.ogg`
- **Type:** deliver-impact-combination
- **Source:** sounds.lua

### __base__/sound/open-close/ammo-large-open.ogg
- **Internal name:** `__base__/sound/open-close/ammo-large-open.ogg`
- **Type:** deliver-impact-combination
- **Source:** sounds.lua

### __base__/sound/open-close/combinator-close.ogg
- **Internal name:** `__base__/sound/open-close/combinator-close.ogg`
- **Type:** deliver-impact-combination
- **Source:** sounds.lua

### __base__/sound/open-close/drill-close.ogg
- **Internal name:** `__base__/sound/open-close/drill-close.ogg`
- **Type:** deliver-impact-combination
- **Source:** sounds.lua

### __base__/sound/pipe.ogg
- **Internal name:** `__base__/sound/pipe.ogg`
- **Type:** deliver-impact-combination
- **Source:** sounds.lua

### __base__/sound/train-breaks.ogg
- **Internal name:** `__base__/sound/train-breaks.ogg`
- **Type:** deliver-impact-combination
- **Source:** sounds.lua

### __base__/sound/train-wagon-wheels.ogg
- **Internal name:** `__base__/sound/train-wagon-wheels.ogg`
- **Type:** deliver-impact-combination
- **Source:** sounds.lua

### __base__/sound/transport-belt.ogg
- **Internal name:** `__base__/sound/transport-belt.ogg`
- **Type:** deliver-impact-combination
- **Source:** sounds.lua

### __core__/sound/deconstruct-large.ogg
- **Internal name:** `__core__/sound/deconstruct-large.ogg`
- **Type:** deliver-impact-combination
- **Source:** sounds.lua


## Destroy Decoratives

### __base__/graphics/entity/combat-robot-capsule/defender-capsule.png
- **Internal name:** `__base__/graphics/entity/combat-robot-capsule/defender-capsule.png`
- **Type:** destroy-decoratives
- **Source:** projectiles.lua

### explosive-cannon-projectile
- **Internal name:** `explosive-cannon-projectile`
- **Type:** destroy-decoratives
- **Source:** projectiles.lua


## Direct

### Artillery turret
- **Internal name:** `artillery-turret`
- **Type:** direct
- **Description:** Long-range cannon targeting enemy bases.
- **Source:** turrets.lua

### Behemoth worm
- **Internal name:** `behemoth-worm-turret`
- **Type:** direct
- **Source:** turrets.lua

### Blood explosion big
- **Internal name:** `blood-explosion-big`
- **Type:** direct
- **Source:** explosions.lua

### Ground explosion
- **Internal name:** `ground-explosion`
- **Type:** direct
- **Source:** explosions.lua

### Small biter corpse
- **Internal name:** `small-biter-corpse`
- **Type:** direct
- **Source:** enemies.lua

### Wall damaged explosion
- **Internal name:** `wall-damaged-explosion`
- **Type:** direct
- **Source:** hit-effects.lua

### __base__/graphics/entity/accumulator/accumulator-discharge.png
- **Internal name:** `__base__/graphics/entity/accumulator/accumulator-discharge.png`
- **Type:** direct
- **Source:** entities.lua

### __base__/graphics/entity/acid-projectile/acid-projectile-tail.png
- **Internal name:** `__base__/graphics/entity/acid-projectile/acid-projectile-tail.png`
- **Type:** direct
- **Source:** enemy-projectiles.lua

### __base__/graphics/entity/acid-splash/acid-splash-1-shadow.png
- **Internal name:** `__base__/graphics/entity/acid-splash/acid-splash-1-shadow.png`
- **Type:** direct
- **Source:** enemy-projectiles.lua

### __base__/graphics/entity/acid-splash/acid-splash-3-shadow.png
- **Internal name:** `__base__/graphics/entity/acid-splash/acid-splash-3-shadow.png`
- **Type:** direct
- **Source:** enemy-projectiles.lua

### __base__/graphics/entity/artillery-projectile/shell.png
- **Internal name:** `__base__/graphics/entity/artillery-projectile/shell.png`
- **Type:** direct
- **Source:** projectiles.lua

### __base__/graphics/entity/beam/beam-body-3.png
- **Internal name:** `__base__/graphics/entity/beam/beam-body-3.png`
- **Type:** direct
- **Source:** beams.lua

### __base__/graphics/entity/combat-robot-capsule/destroyer-capsule-shadow.png
- **Internal name:** `__base__/graphics/entity/combat-robot-capsule/destroyer-capsule-shadow.png`
- **Type:** direct
- **Source:** projectiles.lua

### __base__/graphics/entity/combat-robot-capsule/distractor-capsule.png
- **Internal name:** `__base__/graphics/entity/combat-robot-capsule/distractor-capsule.png`
- **Type:** direct
- **Source:** projectiles.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-2-ground.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-2-ground.png`
- **Type:** direct
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-3.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-3.png`
- **Type:** direct
- **Source:** crash-site.lua

### __base__/graphics/entity/destroyer-robot/destroyer-robot-shadow.png
- **Internal name:** `__base__/graphics/entity/destroyer-robot/destroyer-robot-shadow.png`
- **Type:** direct
- **Source:** flying-robots.lua

### __base__/graphics/entity/electric-furnace/electric-furnace-reflection.png
- **Internal name:** `__base__/graphics/entity/electric-furnace/electric-furnace-reflection.png`
- **Type:** direct
- **Source:** entities.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-east.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-east.png`
- **Type:** direct
- **Source:** fire.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-muzzle-fire.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-muzzle-fire.png`
- **Type:** direct
- **Source:** fire.lua

### __base__/graphics/entity/gun-turret/gun-turret-base.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-base.png`
- **Type:** direct
- **Source:** turrets.lua

### __base__/graphics/entity/gun-turret/gun-turret-shooting-1.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-shooting-1.png`
- **Type:** direct
- **Source:** turrets.lua

### __base__/graphics/entity/gun-turret/gun-turret-shooting-mask-4.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-shooting-mask-4.png`
- **Type:** direct
- **Source:** turrets.lua

### __base__/graphics/entity/lab/lab.png
- **Internal name:** `__base__/graphics/entity/lab/lab.png`
- **Type:** direct
- **Source:** entities.lua

### __base__/graphics/entity/laser-turret/laser-body-light.png
- **Internal name:** `__base__/graphics/entity/laser-turret/laser-body-light.png`
- **Type:** direct
- **Source:** beams.lua

### __base__/graphics/entity/laser-turret/laser-ground-light-head.png
- **Internal name:** `__base__/graphics/entity/laser-turret/laser-ground-light-head.png`
- **Type:** direct
- **Source:** beams.lua

### __base__/graphics/entity/long-handed-inserter/long-handed-inserter-platform.png
- **Internal name:** `__base__/graphics/entity/long-handed-inserter/long-handed-inserter-platform.png`
- **Type:** direct
- **Source:** entities.lua

### __base__/graphics/entity/piercing-bullet/piercing-bullet.png
- **Internal name:** `__base__/graphics/entity/piercing-bullet/piercing-bullet.png`
- **Type:** direct
- **Source:** projectiles.lua

### __base__/graphics/entity/poison-capsule/poison-capsule.png
- **Internal name:** `__base__/graphics/entity/poison-capsule/poison-capsule.png`
- **Type:** direct
- **Source:** projectiles.lua

### __base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png
- **Internal name:** `__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png`
- **Type:** direct
- **Source:** entities.lua

### __base__/graphics/entity/smoke-construction/smoke-01.png
- **Internal name:** `__base__/graphics/entity/smoke-construction/smoke-01.png`
- **Type:** direct
- **Source:** flying-robots.lua

### __base__/graphics/entity/sparks/sparks-02.png
- **Internal name:** `__base__/graphics/entity/sparks/sparks-02.png`
- **Type:** direct
- **Source:** flying-robots.lua

### __base__/sound/creatures/projectile-acid-burn-1.ogg
- **Internal name:** `__base__/sound/creatures/projectile-acid-burn-1.ogg`
- **Type:** direct
- **Source:** enemy-projectiles.lua

### __base__/sound/creatures/projectile-acid-burn-long-2.ogg
- **Internal name:** `__base__/sound/creatures/projectile-acid-burn-long-2.ogg`
- **Type:** direct
- **Source:** enemy-projectiles.lua

### __base__/sound/fire-1.ogg
- **Internal name:** `__base__/sound/fire-1.ogg`
- **Type:** direct
- **Source:** fire.lua

### __core__/sound/build-ghost-medium.ogg
- **Internal name:** `__core__/sound/build-ghost-medium.ogg`
- **Type:** direct
- **Source:** entities.lua

### acid-stream-worm-small
- **Internal name:** `acid-stream-worm-small`
- **Type:** direct
- **Source:** enemy-projectiles.lua

### active-provider-chest-metal-particle-medium
- **Internal name:** `active-provider-chest-metal-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### arithmetic-combinator-explosion
- **Internal name:** `arithmetic-combinator-explosion`
- **Type:** direct
- **Source:** explosions.lua

### artillery-wagon-explosion
- **Internal name:** `artillery-wagon-explosion`
- **Type:** direct
- **Source:** explosions.lua

### assembling-machine-2-metal-particle-medium
- **Internal name:** `assembling-machine-2-metal-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### assembling-machine-3-metal-particle-small
- **Internal name:** `assembling-machine-3-metal-particle-small`
- **Type:** direct
- **Source:** explosions.lua

### atomic-bomb-wave
- **Internal name:** `atomic-bomb-wave`
- **Type:** direct
- **Source:** atomic-bomb.lua

### atomic-bomb-wave-spawns-fire-smoke-explosion
- **Internal name:** `atomic-bomb-wave-spawns-fire-smoke-explosion`
- **Type:** direct
- **Source:** atomic-bomb.lua

### atomic-bomb-wave-spawns-nuke-shockwave-explosion
- **Internal name:** `atomic-bomb-wave-spawns-nuke-shockwave-explosion`
- **Type:** direct
- **Source:** atomic-bomb.lua

### big-biter-die
- **Internal name:** `big-biter-die`
- **Type:** direct
- **Source:** explosions.lua

### big-electric-pole-explosion
- **Internal name:** `big-electric-pole-explosion`
- **Type:** direct
- **Source:** explosions.lua

### big-worm-die
- **Internal name:** `big-worm-die`
- **Type:** direct
- **Source:** explosions.lua

### blood-particle-small
- **Internal name:** `blood-particle-small`
- **Type:** direct
- **Source:** biter-die-effects.lua

### boiler-metal-particle-big
- **Internal name:** `boiler-metal-particle-big`
- **Type:** direct
- **Source:** explosions.lua

### burner-inserter-metal-particle-medium
- **Internal name:** `burner-inserter-metal-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### burner-mining-drill-explosion
- **Internal name:** `burner-mining-drill-explosion`
- **Type:** direct
- **Source:** explosions.lua

### car-metal-particle-small
- **Internal name:** `car-metal-particle-small`
- **Type:** direct
- **Source:** explosions.lua

### cargo-pod-container-remnants
- **Internal name:** `cargo-pod-container-remnants`
- **Type:** direct
- **Source:** explosions.lua

### centrifuge-mechanical-component-particle-medium
- **Internal name:** `centrifuge-mechanical-component-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### chemical-plant-glass-particle-small
- **Internal name:** `chemical-plant-glass-particle-small`
- **Type:** direct
- **Source:** explosions.lua

### decider-combinator-metal-particle-small
- **Internal name:** `decider-combinator-metal-particle-small`
- **Type:** direct
- **Source:** explosions.lua

### defender-robot-metal-particle-medium
- **Internal name:** `defender-robot-metal-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### distractor-robot-explosion
- **Internal name:** `distractor-robot-explosion`
- **Type:** direct
- **Source:** explosions.lua

### electric-furnace-metal-particle-medium
- **Internal name:** `electric-furnace-metal-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### electric-mining-drill-metal-particle-big
- **Internal name:** `electric-mining-drill-metal-particle-big`
- **Type:** direct
- **Source:** explosions.lua

### explosion-stone-particle-small
- **Internal name:** `explosion-stone-particle-small`
- **Type:** direct
- **Source:** explosions.lua

### express-splitter-mechanical-component-particle-medium
- **Internal name:** `express-splitter-mechanical-component-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### express-transport-belt-mechanical-component-particle-medium
- **Internal name:** `express-transport-belt-mechanical-component-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### express-underground-belt-metal-particle-medium-blue
- **Internal name:** `express-underground-belt-metal-particle-medium-blue`
- **Type:** direct
- **Source:** explosions.lua

### fast-inserter-metal-particle-medium
- **Internal name:** `fast-inserter-metal-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### fast-splitter-explosion
- **Internal name:** `fast-splitter-explosion`
- **Type:** direct
- **Source:** explosions.lua

### fast-transport-belt-metal-particle-small
- **Internal name:** `fast-transport-belt-metal-particle-small`
- **Type:** direct
- **Source:** explosions.lua

### flame-thrower-turret-metal-particle-medium
- **Internal name:** `flame-thrower-turret-metal-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### gate-explosion
- **Internal name:** `gate-explosion`
- **Type:** direct
- **Source:** explosions.lua

### glass-particle-small
- **Internal name:** `glass-particle-small`
- **Type:** direct
- **Source:** explosions.lua

### gun-turret-explosion
- **Internal name:** `gun-turret-explosion`
- **Type:** direct
- **Source:** explosions.lua

### heat-exchanger-metal-particle-medium
- **Internal name:** `heat-exchanger-metal-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### iron-chest-explosion
- **Internal name:** `iron-chest-explosion`
- **Type:** direct
- **Source:** explosions.lua

### lab-long-metal-particle-medium
- **Internal name:** `lab-long-metal-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### lamp-explosion
- **Internal name:** `lamp-explosion`
- **Type:** direct
- **Source:** explosions.lua

### laser-beam-no-sound
- **Internal name:** `laser-beam-no-sound`
- **Type:** direct
- **Source:** beams.lua

### laser-turret-metal-particle-small
- **Internal name:** `laser-turret-metal-particle-small`
- **Type:** direct
- **Source:** explosions.lua

### locomotive-metal-particle-big
- **Internal name:** `locomotive-metal-particle-big`
- **Type:** direct
- **Source:** explosions.lua

### logistic-robot-metal-particle-medium
- **Internal name:** `logistic-robot-metal-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### long-handed-inserter-metal-particle-medium
- **Internal name:** `long-handed-inserter-metal-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### medium-electric-pole-explosion
- **Internal name:** `medium-electric-pole-explosion`
- **Type:** direct
- **Source:** explosions.lua

### nuclear-reactor-metal-particle-medium
- **Internal name:** `nuclear-reactor-metal-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### offshore-pump-metal-particle-big
- **Internal name:** `offshore-pump-metal-particle-big`
- **Type:** direct
- **Source:** explosions.lua

### oil-refinery-metal-particle-small
- **Internal name:** `oil-refinery-metal-particle-small`
- **Type:** direct
- **Source:** explosions.lua

### pipe-glass-particle-small
- **Internal name:** `pipe-glass-particle-small`
- **Type:** direct
- **Source:** explosions.lua

### pipe-to-ground-metal-particle-small
- **Internal name:** `pipe-to-ground-metal-particle-small`
- **Type:** direct
- **Source:** explosions.lua

### programmable-speaker-explosion
- **Internal name:** `programmable-speaker-explosion`
- **Type:** direct
- **Source:** explosions.lua

### pump-metal-particle-small
- **Internal name:** `pump-metal-particle-small`
- **Type:** direct
- **Source:** explosions.lua

### pumpjack-metal-particle-big
- **Internal name:** `pumpjack-metal-particle-big`
- **Type:** direct
- **Source:** explosions.lua

### radar-metal-particle-medium
- **Internal name:** `radar-metal-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### rail-signal-glass-particle-small-red
- **Internal name:** `rail-signal-glass-particle-small-red`
- **Type:** direct
- **Source:** explosions.lua

### rail-tie-particle
- **Internal name:** `rail-tie-particle`
- **Type:** direct
- **Source:** explosions.lua

### requester-chest-explosion
- **Internal name:** `requester-chest-explosion`
- **Type:** direct
- **Source:** explosions.lua

### rock-damage-stone-particle-medium
- **Internal name:** `rock-damage-stone-particle-medium`
- **Type:** direct
- **Source:** hit-effects.lua

### rocket-silo-metal-particle-big
- **Internal name:** `rocket-silo-metal-particle-big`
- **Type:** direct
- **Source:** explosions.lua

### selector-combinator-explosion
- **Internal name:** `selector-combinator-explosion`
- **Type:** direct
- **Source:** explosions.lua

### shotgun-pellet
- **Internal name:** `shotgun-pellet`
- **Type:** direct
- **Source:** projectiles.lua

### slowdown-capsule-particle
- **Internal name:** `slowdown-capsule-particle`
- **Type:** direct
- **Source:** explosions.lua

### spark-particle
- **Internal name:** `spark-particle`
- **Type:** direct
- **Source:** hit-effects.lua

### spidertron-mechanical-component-particle-medium
- **Internal name:** `spidertron-mechanical-component-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### spidertron-metal-particle-big
- **Internal name:** `spidertron-metal-particle-big`
- **Type:** direct
- **Source:** explosions.lua

### splitter-metal-particle-small
- **Internal name:** `splitter-metal-particle-small`
- **Type:** direct
- **Source:** explosions.lua

### steam-turbine-explosion
- **Internal name:** `steam-turbine-explosion`
- **Type:** direct
- **Source:** explosions.lua

### steel-chest-metal-particle-small
- **Internal name:** `steel-chest-metal-particle-small`
- **Type:** direct
- **Source:** explosions.lua

### steel-furnace-metal-particle-medium
- **Internal name:** `steel-furnace-metal-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### stone-furnace-stone-particle-medium
- **Internal name:** `stone-furnace-stone-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### storage-chest-metal-particle-small
- **Internal name:** `storage-chest-metal-particle-small`
- **Type:** direct
- **Source:** explosions.lua

### storage-tank-explosion
- **Internal name:** `storage-tank-explosion`
- **Type:** direct
- **Source:** explosions.lua

### substation-long-metal-particle-medium
- **Internal name:** `substation-long-metal-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### tank-explosion
- **Internal name:** `tank-explosion`
- **Type:** direct
- **Source:** explosions.lua

### train-stop-metal-particle-small
- **Internal name:** `train-stop-metal-particle-small`
- **Type:** direct
- **Source:** explosions.lua

### transport-belt-explosion
- **Internal name:** `transport-belt-explosion`
- **Type:** direct
- **Source:** explosions.lua

### transport-belt-metal-particle-medium
- **Internal name:** `transport-belt-metal-particle-medium`
- **Type:** direct
- **Source:** explosions.lua

### tree_dry_hairy
- **Internal name:** `tree_dry_hairy`
- **Type:** direct
- **Source:** trees.lua

### underground-belt-metal-particle-medium-yellow
- **Internal name:** `underground-belt-metal-particle-medium-yellow`
- **Type:** direct
- **Source:** explosions.lua


## Display Panel

### alarms
- **Internal name:** `alarms`
- **Type:** display-panel
- **Source:** circuit-network.lua


## Electric

### Character
- **Internal name:** `character`
- **Type:** electric
- **Source:** entities.lua

### Fast inserter
- **Internal name:** `fast-inserter`
- **Type:** electric
- **Health:** 150
- **Source:** entities.lua

### __base__/graphics/entity/assembling-machine-1/assembling-machine-1.png
- **Internal name:** `__base__/graphics/entity/assembling-machine-1/assembling-machine-1.png`
- **Type:** electric
- **Source:** entities.lua

### __base__/graphics/entity/beam/beam-head.png
- **Internal name:** `__base__/graphics/entity/beam/beam-head.png`
- **Type:** electric
- **Source:** beams.lua

### __base__/graphics/entity/boiler/boiler-W-light.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-W-light.png`
- **Type:** electric
- **Source:** entities.lua

### __base__/graphics/entity/car/car-1.png
- **Internal name:** `__base__/graphics/entity/car/car-1.png`
- **Type:** electric
- **Source:** entities.lua

### __base__/graphics/entity/car/car-shadow-3.png
- **Internal name:** `__base__/graphics/entity/car/car-shadow-3.png`
- **Type:** electric
- **Source:** entities.lua

### __base__/graphics/entity/character/level1_dead_effect_map.png
- **Internal name:** `__base__/graphics/entity/character/level1_dead_effect_map.png`
- **Type:** electric
- **Source:** entities.lua

### __base__/graphics/entity/electric-furnace/electric-furnace-heater.png
- **Internal name:** `__base__/graphics/entity/electric-furnace/electric-furnace-heater.png`
- **Type:** electric
- **Source:** entities.lua

### __base__/graphics/entity/electric-mining-drill/electric-mining-drill-horizontal-front.png
- **Internal name:** `__base__/graphics/entity/electric-mining-drill/electric-mining-drill-horizontal-front.png`
- **Type:** electric
- **Source:** mining-drill.lua

### __base__/graphics/entity/electric-mining-drill/electric-mining-drill-smoke-front.png
- **Internal name:** `__base__/graphics/entity/electric-mining-drill/electric-mining-drill-smoke-front.png`
- **Type:** electric
- **Source:** mining-drill.lua

### __base__/graphics/entity/fast-inserter/fast-inserter-hand-closed.png
- **Internal name:** `__base__/graphics/entity/fast-inserter/fast-inserter-hand-closed.png`
- **Type:** electric
- **Source:** entities.lua

### __base__/graphics/entity/fish/fish-1.png
- **Internal name:** `__base__/graphics/entity/fish/fish-1.png`
- **Type:** electric
- **Source:** entities.lua

### __base__/graphics/entity/gun-turret/gun-turret-shooting-mask-2.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-shooting-mask-2.png`
- **Type:** electric
- **Source:** turrets.lua

### __base__/graphics/entity/long-handed-inserter/long-handed-inserter-hand-closed.png
- **Internal name:** `__base__/graphics/entity/long-handed-inserter/long-handed-inserter-hand-closed.png`
- **Type:** electric
- **Source:** entities.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_North.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_North.png`
- **Type:** electric
- **Source:** entities.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_West-glass.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_West-glass.png`
- **Type:** electric
- **Source:** entities.lua

### __base__/graphics/entity/pipe/fluid-flow-low-temperature.png
- **Internal name:** `__base__/graphics/entity/pipe/fluid-flow-low-temperature.png`
- **Type:** electric
- **Source:** entities.lua

### __base__/graphics/entity/programmable-speaker/programmable-speaker.png
- **Internal name:** `__base__/graphics/entity/programmable-speaker/programmable-speaker.png`
- **Type:** electric
- **Source:** circuit-network.lua

### __base__/graphics/entity/stone-furnace/stone-furnace-reflection.png
- **Internal name:** `__base__/graphics/entity/stone-furnace/stone-furnace-reflection.png`
- **Type:** electric
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-corner-left-shadow.png
- **Internal name:** `__base__/graphics/entity/wall/wall-corner-left-shadow.png`
- **Type:** electric
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-diode-red.png
- **Internal name:** `__base__/graphics/entity/wall/wall-diode-red.png`
- **Type:** electric
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-filling.png
- **Internal name:** `__base__/graphics/entity/wall/wall-filling.png`
- **Type:** electric
- **Source:** entities.lua

### __base__/graphics/entity/wooden-chest/wooden-chest-shadow.png
- **Internal name:** `__base__/graphics/entity/wooden-chest/wooden-chest-shadow.png`
- **Type:** electric
- **Source:** entities.lua

### __base__/sound/combinator.ogg
- **Internal name:** `__base__/sound/combinator.ogg`
- **Type:** electric
- **Source:** circuit-network.lua

### __base__/sound/fight/laser-beam.ogg
- **Internal name:** `__base__/sound/fight/laser-beam.ogg`
- **Type:** electric
- **Source:** beams.lua

### __base__/sound/programmable-speaker/alarm-1.ogg
- **Internal name:** `__base__/sound/programmable-speaker/alarm-1.ogg`
- **Type:** electric
- **Source:** circuit-network.lua

### __core__/graphics/light-cone.png
- **Internal name:** `__core__/graphics/light-cone.png`
- **Type:** electric
- **Source:** entities.lua

### signal-cyan
- **Internal name:** `signal-cyan`
- **Type:** electric
- **Source:** entities.lua


## Electric Energy Interface

### __base__/graphics/entity/wall/wall-diode-green.png
- **Internal name:** `__base__/graphics/entity/wall/wall-diode-green.png`
- **Type:** electric-energy-interface
- **Source:** entities.lua


## Electric Pole

### __base__/graphics/entity/offshore-pump/offshore-pump_North-legs.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_North-legs.png`
- **Type:** electric-pole
- **Source:** entities.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_South-legs.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_South-legs.png`
- **Type:** electric-pole
- **Source:** entities.lua

### __base__/graphics/entity/pipe/pipe-ending-right.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-ending-right.png`
- **Type:** electric-pole
- **Source:** entities.lua


## Electric Turret

### __base__/graphics/entity/gun-turret/gun-turret-shooting-mask-1.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-shooting-mask-1.png`
- **Type:** electric-turret
- **Source:** turrets.lua


## Elevated Curved Rail A

### dummy-elevated-straight-rail
- **Internal name:** `dummy-elevated-straight-rail`
- **Type:** elevated-curved-rail-a
- **Source:** trains.lua


## Elevated Straight Rail

### dummy-rail-ramp
- **Internal name:** `dummy-rail-ramp`
- **Type:** elevated-straight-rail
- **Source:** trains.lua


## Entity

### Small biter
- **Internal name:** `small-biter`
- **Type:** entity
- **Source:** enemies.lua


## Entity Ghost

### Iron chest
- **Internal name:** `iron-chest`
- **Type:** entity-ghost
- **Health:** 200
- **Source:** entities.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_East-shadow.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_East-shadow.png`
- **Type:** entity-ghost
- **Source:** entities.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_East.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_East.png`
- **Type:** entity-ghost
- **Source:** entities.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_South.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_South.png`
- **Type:** entity-ghost
- **Source:** entities.lua


## Explosion

### Big artillery explosion
- **Internal name:** `big-artillery-explosion`
- **Type:** explosion
- **Source:** explosions.lua

### Big explosion
- **Internal name:** `big-explosion`
- **Type:** explosion
- **Source:** explosions.lua

### Blood fountain
- **Internal name:** `blood-fountain`
- **Type:** explosion
- **Source:** explosions.lua

### Blood fountain big
- **Internal name:** `blood-fountain-big`
- **Type:** explosion
- **Source:** explosions.lua

### Explosion
- **Internal name:** `explosion`
- **Type:** explosion
- **Source:** explosions.lua

### Explosion hit
- **Internal name:** `explosion-hit`
- **Type:** explosion
- **Source:** explosions.lua

### Factorio logo 22 tiles
- **Internal name:** `factorio-logo-22tiles`
- **Type:** explosion
- **Source:** factorio-logo.lua

### Fluid wagon
- **Internal name:** `fluid-wagon`
- **Type:** explosion
- **Health:** 600
- **Source:** trains.lua

### Inserter
- **Internal name:** `inserter`
- **Type:** explosion
- **Health:** 150
- **Source:** entities.lua

### Item on ground
- **Internal name:** `item-on-ground`
- **Type:** explosion
- **Description:** Can be picked up by pressing __CONTROL__pick-items__.\nCan be dropped manually [tip=z-dropping] or by entities like [entity=burner-mining-drill].
- **Source:** entities.lua

### Laser turret
- **Internal name:** `laser-turret`
- **Type:** explosion
- **Health:** 1000
- **Source:** turrets.lua

### Medium explosion
- **Internal name:** `medium-explosion`
- **Type:** explosion
- **Source:** explosions.lua

### Medium spitter
- **Internal name:** `medium-spitter`
- **Type:** explosion
- **Source:** enemies.lua

### Small spitter corpse
- **Internal name:** `small-spitter-corpse`
- **Type:** explosion
- **Source:** enemies.lua

### Spark explosion
- **Internal name:** `spark-explosion`
- **Type:** explosion
- **Source:** hit-effects.lua

### Spitter spawner
- **Internal name:** `spitter-spawner`
- **Type:** explosion
- **Source:** enemies.lua

### Trees
- **Internal name:** `tree-proxy`
- **Type:** explosion
- **Source:** entities.lua

### Wall
- **Internal name:** `stone-wall`
- **Type:** explosion
- **Health:** 350
- **Source:** entities.lua

### __base__/graphics/entity/artillery-turret/artillery-turret-base-shadow.png
- **Internal name:** `__base__/graphics/entity/artillery-turret/artillery-turret-base-shadow.png`
- **Type:** explosion
- **Source:** turrets.lua

### __base__/graphics/entity/car/car-4.png
- **Internal name:** `__base__/graphics/entity/car/car-4.png`
- **Type:** explosion
- **Source:** entities.lua

### __base__/graphics/entity/car/car-mask-5.png
- **Internal name:** `__base__/graphics/entity/car/car-mask-5.png`
- **Type:** explosion
- **Source:** entities.lua

### __base__/graphics/entity/car/car-turret-1.png
- **Internal name:** `__base__/graphics/entity/car/car-turret-1.png`
- **Type:** explosion
- **Source:** entities.lua

### __base__/graphics/entity/cargo-wagon/minimap-representation/cargo-wagon-minimap-representation.png
- **Internal name:** `__base__/graphics/entity/cargo-wagon/minimap-representation/cargo-wagon-minimap-representation.png`
- **Type:** explosion
- **Source:** trains.lua

### __base__/graphics/entity/combat-robot-capsule/destroyer-capsule.png
- **Internal name:** `__base__/graphics/entity/combat-robot-capsule/destroyer-capsule.png`
- **Type:** explosion
- **Source:** projectiles.lua

### __base__/graphics/entity/laser-turret/laser-turret-raising-shadow.png
- **Internal name:** `__base__/graphics/entity/laser-turret/laser-turret-raising-shadow.png`
- **Type:** explosion
- **Source:** turrets.lua

### __base__/graphics/entity/laser-turret/laser-turret-shooting-mask.png
- **Internal name:** `__base__/graphics/entity/laser-turret/laser-turret-shooting-mask.png`
- **Type:** explosion
- **Source:** turrets.lua

### __base__/graphics/entity/pipe/pipe-corner-down-right.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-corner-down-right.png`
- **Type:** explosion
- **Source:** entities.lua

### __base__/graphics/entity/pipe/pipe-straight-vertical.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-straight-vertical.png`
- **Type:** explosion
- **Source:** entities.lua

### __base__/graphics/entity/steam-engine/steam-engine-V-shadow.png
- **Internal name:** `__base__/graphics/entity/steam-engine/steam-engine-V-shadow.png`
- **Type:** explosion
- **Source:** entities.lua

### __base__/sound/car-door-close.ogg
- **Internal name:** `__base__/sound/car-door-close.ogg`
- **Type:** explosion
- **Source:** entities.lua

### __base__/sound/train-wheels.ogg
- **Internal name:** `__base__/sound/train-wheels.ogg`
- **Type:** explosion
- **Source:** trains.lua

### acid-stream-spitter-behemoth
- **Internal name:** `acid-stream-spitter-behemoth`
- **Type:** explosion
- **Source:** enemies.lua

### active-provider-chest-explosion
- **Internal name:** `active-provider-chest-explosion`
- **Type:** explosion
- **Source:** explosions.lua

### artillery-wagon-mechanical-component-particle-medium
- **Internal name:** `artillery-wagon-mechanical-component-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### assembling-machine-1-metal-particle-small
- **Internal name:** `assembling-machine-1-metal-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### assembling-machine-2-metal-particle-big
- **Internal name:** `assembling-machine-2-metal-particle-big`
- **Type:** explosion
- **Source:** explosions.lua

### assembling-machine-3-metal-particle-medium
- **Internal name:** `assembling-machine-3-metal-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### beacon-metal-particle-small
- **Internal name:** `beacon-metal-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### behemoth-spitter-die
- **Internal name:** `behemoth-spitter-die`
- **Type:** explosion
- **Source:** explosions.lua

### boiler-metal-particle-small
- **Internal name:** `boiler-metal-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### buffer-chest-metal-particle-small
- **Internal name:** `buffer-chest-metal-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### burner-inserter-explosion
- **Internal name:** `burner-inserter-explosion`
- **Type:** explosion
- **Source:** explosions.lua

### car-metal-particle-medium
- **Internal name:** `car-metal-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### cargo-pod-container-explosion-delay
- **Internal name:** `cargo-pod-container-explosion-delay`
- **Type:** explosion
- **Source:** explosions.lua

### cargo-wagon-metal-particle-small
- **Internal name:** `cargo-wagon-metal-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### centrifuge-long-metal-particle-medium
- **Internal name:** `centrifuge-long-metal-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### centrifuge-metal-particle-small
- **Internal name:** `centrifuge-metal-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### chemical-plant-metal-particle-medium
- **Internal name:** `chemical-plant-metal-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### chemical-plant-metal-particle-small
- **Internal name:** `chemical-plant-metal-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### constant-combinator-metal-particle-small
- **Internal name:** `constant-combinator-metal-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### construction-robot-metal-particle-small
- **Internal name:** `construction-robot-metal-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### decider-combinator-metal-particle-medium
- **Internal name:** `decider-combinator-metal-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### destroyer-robot-metal-particle-small
- **Internal name:** `destroyer-robot-metal-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### display-panel-metal-particle-medium
- **Internal name:** `display-panel-metal-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### dummy
- **Internal name:** `dummy`
- **Type:** explosion
- **Source:** enemies.lua

### electric-furnace-metal-particle-big
- **Internal name:** `electric-furnace-metal-particle-big`
- **Type:** explosion
- **Source:** explosions.lua

### electric-mining-drill-explosion
- **Internal name:** `electric-mining-drill-explosion`
- **Type:** explosion
- **Source:** explosions.lua

### explosion-gunshot
- **Internal name:** `explosion-gunshot`
- **Type:** explosion
- **Source:** explosions.lua

### explosion-gunshot-small
- **Internal name:** `explosion-gunshot-small`
- **Type:** explosion
- **Source:** explosions.lua

### explosion-stone-particle-medium
- **Internal name:** `explosion-stone-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### express-splitter-metal-particle-big
- **Internal name:** `express-splitter-metal-particle-big`
- **Type:** explosion
- **Source:** explosions.lua

### express-underground-belt-metal-particle-small
- **Internal name:** `express-underground-belt-metal-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### fast-inserter-explosion
- **Internal name:** `fast-inserter-explosion`
- **Type:** explosion
- **Source:** explosions.lua

### fast-transport-belt-metal-particle-medium
- **Internal name:** `fast-transport-belt-metal-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### flame-thrower-turret-metal-particle-big
- **Internal name:** `flame-thrower-turret-metal-particle-big`
- **Type:** explosion
- **Source:** explosions.lua

### fluid-wagon-long-metal-particle-medium
- **Internal name:** `fluid-wagon-long-metal-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### gate-stone-particle-small
- **Internal name:** `gate-stone-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### heat-exchanger-explosion
- **Internal name:** `heat-exchanger-explosion`
- **Type:** explosion
- **Source:** explosions.lua

### lab-glass-particle-small
- **Internal name:** `lab-glass-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### laser-turret-metal-particle-medium
- **Internal name:** `laser-turret-metal-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### locomotive-explosion
- **Internal name:** `locomotive-explosion`
- **Type:** explosion
- **Source:** explosions.lua

### long-handed-inserter-explosion
- **Internal name:** `long-handed-inserter-explosion`
- **Type:** explosion
- **Source:** explosions.lua

### medium-biter-die
- **Internal name:** `medium-biter-die`
- **Type:** explosion
- **Source:** explosions.lua

### medium-worm-die
- **Internal name:** `medium-worm-die`
- **Type:** explosion
- **Source:** explosions.lua

### nuclear-reactor-metal-particle-big
- **Internal name:** `nuclear-reactor-metal-particle-big`
- **Type:** explosion
- **Source:** explosions.lua

### offshore-pump-explosion
- **Internal name:** `offshore-pump-explosion`
- **Type:** explosion
- **Source:** explosions.lua

### oil-refinery-metal-particle-medium
- **Internal name:** `oil-refinery-metal-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### pipe-metal-particle-small
- **Internal name:** `pipe-metal-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### pipe-to-ground-metal-particle-medium
- **Internal name:** `pipe-to-ground-metal-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### pump-metal-particle-medium
- **Internal name:** `pump-metal-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### pumpjack-explosion
- **Internal name:** `pumpjack-explosion`
- **Type:** explosion
- **Source:** explosions.lua

### radar-metal-particle-big
- **Internal name:** `radar-metal-particle-big`
- **Type:** explosion
- **Source:** explosions.lua

### rail-long-metal-particle-medium
- **Internal name:** `rail-long-metal-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### rail-signal-metal-particle-small
- **Internal name:** `rail-signal-metal-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### rock-damage-stone-particle-small
- **Internal name:** `rock-damage-stone-particle-small`
- **Type:** explosion
- **Source:** hit-effects.lua

### rocket-silo-explosion
- **Internal name:** `rocket-silo-explosion`
- **Type:** explosion
- **Source:** explosions.lua

### slowdown-capsule-explosion
- **Internal name:** `slowdown-capsule-explosion`
- **Type:** explosion
- **Source:** explosions.lua

### small-dusty-explosion-smoke
- **Internal name:** `small-dusty-explosion-smoke`
- **Type:** explosion
- **Source:** explosions.lua

### small-electric-pole-metal-particle-small
- **Internal name:** `small-electric-pole-metal-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### solar-panel-glass-particle-small
- **Internal name:** `solar-panel-glass-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### spidertron-explosion
- **Internal name:** `spidertron-explosion`
- **Type:** explosion
- **Source:** explosions.lua

### splitter-metal-particle-medium
- **Internal name:** `splitter-metal-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### steam-engine-mechanical-component-particle-medium
- **Internal name:** `steam-engine-mechanical-component-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### steel-chest-metal-particle-medium
- **Internal name:** `steel-chest-metal-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### steel-furnace-metal-particle-big
- **Internal name:** `steel-furnace-metal-particle-big`
- **Type:** explosion
- **Source:** explosions.lua

### stone-furnace-stone-particle-big
- **Internal name:** `stone-furnace-stone-particle-big`
- **Type:** explosion
- **Source:** explosions.lua

### storage-chest-metal-particle-medium
- **Internal name:** `storage-chest-metal-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### train-stop-long-metal-particle-medium
- **Internal name:** `train-stop-long-metal-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### transport-belt-mechanical-component-particle-medium
- **Internal name:** `transport-belt-mechanical-component-particle-medium`
- **Type:** explosion
- **Source:** explosions.lua

### underground-belt-metal-particle-small
- **Internal name:** `underground-belt-metal-particle-small`
- **Type:** explosion
- **Source:** explosions.lua

### wall-stone-particle-tiny
- **Internal name:** `wall-stone-particle-tiny`
- **Type:** explosion
- **Source:** explosions.lua

### wooden-chest-wooden-splinter-particle-small
- **Internal name:** `wooden-chest-wooden-splinter-particle-small`
- **Type:** explosion
- **Source:** explosions.lua


## Fire

### Chest capsule
- **Internal name:** `crash-site-chest-2`
- **Type:** fire
- **Description:** A container from the crashed ship. It might contain useful items.
- **Source:** crash-site.lua

### Express transport belt
- **Internal name:** `express-transport-belt`
- **Type:** fire
- **Health:** 170
- **Source:** transport-belts.lua

### Express underground belt
- **Internal name:** `express-underground-belt`
- **Type:** fire
- **Description:** Used to allow a belt to cross entities or impassable terrain.
- **Health:** 170
- **Source:** transport-belts.lua

### Fast transport belt
- **Internal name:** `fast-transport-belt`
- **Type:** fire
- **Health:** 160
- **Source:** transport-belts.lua

### Fast underground belt
- **Internal name:** `fast-underground-belt`
- **Type:** fire
- **Description:** Used to allow a belt to cross entities or impassable terrain.
- **Health:** 160
- **Source:** transport-belts.lua

### Half diagonal rail
- **Internal name:** `half-diagonal-rail`
- **Type:** fire
- **Source:** trains.lua

### Item request slot
- **Internal name:** `item-request-proxy`
- **Type:** fire
- **Description:** This is to indicate a request for construction bots to deliver an item to this entity. __CONTROL__mine__ to delete the item request.
- **Source:** entities.lua

### Lamp
- **Internal name:** `small-lamp`
- **Type:** fire
- **Health:** 100
- **Source:** entities.lua

### Legacy curved rail
- **Internal name:** `legacy-curved-rail`
- **Type:** fire
- **Source:** trains.lua

### Radar
- **Internal name:** `radar`
- **Type:** fire
- **Description:** Scans the nearby sectors, and actively reveals an area around it.
- **Health:** 250
- **Source:** entities.lua

### Transport belt
- **Internal name:** `transport-belt`
- **Type:** fire
- **Health:** 150
- **Source:** transport-belts.lua

### __base__/graphics/entity/artillery-turret/artillery-turret-reflection.png
- **Internal name:** `__base__/graphics/entity/artillery-turret/artillery-turret-reflection.png`
- **Type:** fire
- **Source:** turrets.lua

### __base__/graphics/entity/boiler/boiler-S-fire.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-S-fire.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/boiler/boiler-W-fire.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-W-fire.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/burner-inserter/burner-inserter-hand-closed-shadow.png
- **Internal name:** `__base__/graphics/entity/burner-inserter/burner-inserter-hand-closed-shadow.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/car/car-3.png
- **Internal name:** `__base__/graphics/entity/car/car-3.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/car/car-mask-2.png
- **Internal name:** `__base__/graphics/entity/car/car-mask-2.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/character/character-reflection.png
- **Internal name:** `__base__/graphics/entity/character/character-reflection.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/character/footprints.png
- **Internal name:** `__base__/graphics/entity/character/footprints.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/crash-site-chests/crash-site-chest-1-ground.png
- **Internal name:** `__base__/graphics/entity/crash-site-chests/crash-site-chest-1-ground.png`
- **Type:** fire
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-chests/crash-site-chest-2-shadow.png
- **Internal name:** `__base__/graphics/entity/crash-site-chests/crash-site-chest-2-shadow.png`
- **Type:** fire
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-big-1-ground.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-big-1-ground.png`
- **Type:** fire
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-big-2-shadow.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-big-2-shadow.png`
- **Type:** fire
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-1.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-1.png`
- **Type:** fire
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-2-ground.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-2-ground.png`
- **Type:** fire
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-2-shadow.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-2-shadow.png`
- **Type:** fire
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-3-ground.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-3-ground.png`
- **Type:** fire
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-3-shadow.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-3-shadow.png`
- **Type:** fire
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-1-ground.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-1-ground.png`
- **Type:** fire
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-1-shadow.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-1-shadow.png`
- **Type:** fire
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-4-ground.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-4-ground.png`
- **Type:** fire
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-4.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-4.png`
- **Type:** fire
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship.png`
- **Type:** fire
- **Source:** crash-site.lua

### __base__/graphics/entity/defender-robot/defender-robot-mask.png
- **Internal name:** `__base__/graphics/entity/defender-robot/defender-robot-mask.png`
- **Type:** fire
- **Source:** flying-robots.lua

### __base__/graphics/entity/distractor-robot/distractor-robot-shadow.png
- **Internal name:** `__base__/graphics/entity/distractor-robot/distractor-robot-shadow.png`
- **Type:** fire
- **Source:** flying-robots.lua

### __base__/graphics/entity/factorio-logo/factorio-logo-11tiles.png
- **Internal name:** `__base__/graphics/entity/factorio-logo/factorio-logo-11tiles.png`
- **Type:** fire
- **Source:** factorio-logo.lua

### __base__/graphics/entity/fast-inserter/fast-inserter-platform.png
- **Internal name:** `__base__/graphics/entity/fast-inserter/fast-inserter-platform.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/fast-transport-belt/fast-transport-belt.png
- **Internal name:** `__base__/graphics/entity/fast-transport-belt/fast-transport-belt.png`
- **Type:** fire
- **Source:** transport-belts.lua

### __base__/graphics/entity/fast-underground-belt/fast-underground-belt-structure-back-patch.png
- **Internal name:** `__base__/graphics/entity/fast-underground-belt/fast-underground-belt-structure-back-patch.png`
- **Type:** fire
- **Source:** transport-belts.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-north-shadow.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-north-shadow.png`
- **Type:** fire
- **Source:** fire.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-west-shadow.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-west-shadow.png`
- **Type:** fire
- **Source:** fire.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-gun-extension-mask.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-gun-extension-mask.png`
- **Type:** fire
- **Source:** fire.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-gun-extension-shadow.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-gun-extension-shadow.png`
- **Type:** fire
- **Source:** fire.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-gun-extension.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-gun-extension.png`
- **Type:** fire
- **Source:** fire.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-gun.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-gun.png`
- **Type:** fire
- **Source:** fire.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-led-indicator-south.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-led-indicator-south.png`
- **Type:** fire
- **Source:** fire.lua

### __base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-3.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-3.png`
- **Type:** fire
- **Source:** turrets.lua

### __base__/graphics/entity/inserter/inserter-hand-base.png
- **Internal name:** `__base__/graphics/entity/inserter/inserter-hand-base.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/laser-turret/laser-turret-base.png
- **Internal name:** `__base__/graphics/entity/laser-turret/laser-turret-base.png`
- **Type:** fire
- **Source:** turrets.lua

### __base__/graphics/entity/laser-turret/laser-turret-shooting-shadow.png
- **Internal name:** `__base__/graphics/entity/laser-turret/laser-turret-shooting-shadow.png`
- **Type:** fire
- **Source:** turrets.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_East-legs.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_East-legs.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_East-underwater.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_East-underwater.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_South-glass.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_South-glass.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_West-legs.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_West-legs.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_West.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_West.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/pipe-to-ground/pipe-to-ground-right.png
- **Internal name:** `__base__/graphics/entity/pipe-to-ground/pipe-to-ground-right.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/pipe/fluid-flow-high-temperature.png
- **Internal name:** `__base__/graphics/entity/pipe/fluid-flow-high-temperature.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/pipe/pipe-corner-up-left.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-corner-up-left.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/pipe/pipe-ending-up.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-ending-up.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/pipe/pipe-horizontal-window-background.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-horizontal-window-background.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/pipe/pipe-straight-vertical-single.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-straight-vertical-single.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/radar/radar-shadow.png
- **Internal name:** `__base__/graphics/entity/radar/radar-shadow.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/small-lamp/lamp.png
- **Internal name:** `__base__/graphics/entity/small-lamp/lamp.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/stone-furnace/stone-furnace-light.png
- **Internal name:** `__base__/graphics/entity/stone-furnace/stone-furnace-light.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/stone-furnace/stone-furnace.png
- **Internal name:** `__base__/graphics/entity/stone-furnace/stone-furnace.png`
- **Type:** fire
- **Source:** entities.lua

### __base__/graphics/entity/underground-belt/underground-belt-structure-back-patch.png
- **Internal name:** `__base__/graphics/entity/underground-belt/underground-belt-structure-back-patch.png`
- **Type:** fire
- **Source:** transport-belts.lua

### __base__/sound/car-engine-start.ogg
- **Internal name:** `__base__/sound/car-engine-start.ogg`
- **Type:** fire
- **Source:** entities.lua

### __base__/sound/cargo-wagon/cargo-wagon-opened.ogg
- **Internal name:** `__base__/sound/cargo-wagon/cargo-wagon-opened.ogg`
- **Type:** fire
- **Source:** trains.lua

### __base__/sound/character-corpse-close.ogg
- **Internal name:** `__base__/sound/character-corpse-close.ogg`
- **Type:** fire
- **Source:** entities.lua

### __base__/sound/express-underground-belt.ogg
- **Internal name:** `__base__/sound/express-underground-belt.ogg`
- **Type:** fire
- **Source:** transport-belts.lua

### __base__/sound/heartbeat.ogg
- **Internal name:** `__base__/sound/heartbeat.ogg`
- **Type:** fire
- **Source:** entities.lua

### __base__/sound/train-door-open.ogg
- **Internal name:** `__base__/sound/train-door-open.ogg`
- **Type:** fire
- **Source:** trains.lua

### __base__/sound/underground-belt.ogg
- **Internal name:** `__base__/sound/underground-belt.ogg`
- **Type:** fire
- **Source:** transport-belts.lua

### __base__/sound/wooden-chest-open.ogg
- **Internal name:** `__base__/sound/wooden-chest-open.ogg`
- **Type:** fire
- **Source:** entities.lua

### acid-stream-spitter-medium
- **Internal name:** `acid-stream-spitter-medium`
- **Type:** fire
- **Source:** enemies.lua

### crash-site-spaceship-wreck-big-2
- **Internal name:** `crash-site-spaceship-wreck-big-2`
- **Type:** fire
- **Source:** crash-site.lua

### dummy-elevated-curved-rail-a
- **Internal name:** `dummy-elevated-curved-rail-a`
- **Type:** fire
- **Source:** trains.lua

### highlight-box
- **Internal name:** `highlight-box`
- **Type:** fire
- **Source:** entities.lua

### light-smoke
- **Internal name:** `light-smoke`
- **Type:** fire
- **Source:** entities.lua

### signal-red
- **Internal name:** `signal-red`
- **Type:** fire
- **Source:** entities.lua

### signal-yellow
- **Internal name:** `signal-yellow`
- **Type:** fire
- **Source:** entities.lua


## Fish

### __base__/graphics/entity/pipe/pipe-straight-horizontal.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-straight-horizontal.png`
- **Type:** fish
- **Source:** entities.lua


## Fluid

### Coal
- **Internal name:** `coal`
- **Type:** fluid
- **Source:** resources.lua


## Fluid Turret

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-gun-active.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-gun-active.png`
- **Type:** fluid-turret
- **Source:** fire.lua


## Fluid Wagon

### __base__/sound/train-engine-stop.ogg
- **Internal name:** `__base__/sound/train-engine-stop.ogg`
- **Type:** fluid-wagon
- **Source:** trains.lua


## Furnace

### __base__/graphics/entity/offshore-pump/offshore-pump_East-glass.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_East-glass.png`
- **Type:** furnace
- **Source:** entities.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_North-underwater.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_North-underwater.png`
- **Type:** furnace
- **Source:** entities.lua

### __base__/graphics/entity/pipe/disabled-visualization.png
- **Internal name:** `__base__/graphics/entity/pipe/disabled-visualization.png`
- **Type:** furnace
- **Source:** entities.lua


## Gate

### __base__/graphics/entity/offshore-pump/offshore-pump_West-underwater.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_West-underwater.png`
- **Type:** gate
- **Source:** entities.lua


## Generator

### __base__/graphics/entity/pipe/pipe-ending-left.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-ending-left.png`
- **Type:** generator
- **Source:** entities.lua


## Heat

### car-smoke
- **Internal name:** `car-smoke`
- **Type:** heat
- **Source:** entities.lua


## Heat Interface

### __base__/graphics/entity/electric-furnace/electric-furnace-light.png
- **Internal name:** `__base__/graphics/entity/electric-furnace/electric-furnace-light.png`
- **Type:** heat-interface
- **Source:** entities.lua


## Heat Pipe

### __base__/graphics/entity/car/car-2.png
- **Internal name:** `__base__/graphics/entity/car/car-2.png`
- **Type:** heat-pipe
- **Source:** entities.lua


## Heavy Oil

### fire-flame-on-tree
- **Internal name:** `fire-flame-on-tree`
- **Type:** heavy-oil
- **Source:** fire.lua


## Highlight Box

### __base__/graphics/entity/offshore-pump/offshore-pump_North-shadow.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_North-shadow.png`
- **Type:** highlight-box
- **Source:** entities.lua


## Impact

### Cargo wagon
- **Internal name:** `cargo-wagon`
- **Type:** impact
- **Health:** 600
- **Source:** trains.lua

### Cliff
- **Internal name:** `cliff`
- **Type:** impact
- **Source:** entities.lua

### Pollution absorbed by damaging trees
- **Internal name:** `tree-dying-proxy`
- **Type:** impact
- **Source:** entities.lua

### __base__/graphics/entity/boiler/boiler-S-light.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-S-light.png`
- **Type:** impact
- **Source:** entities.lua

### __base__/graphics/entity/burner-inserter/burner-inserter-hand-open-shadow.png
- **Internal name:** `__base__/graphics/entity/burner-inserter/burner-inserter-hand-open-shadow.png`
- **Type:** impact
- **Source:** entities.lua

### __base__/graphics/entity/car/car-5.png
- **Internal name:** `__base__/graphics/entity/car/car-5.png`
- **Type:** impact
- **Source:** entities.lua

### __base__/graphics/entity/car/car-mask-4.png
- **Internal name:** `__base__/graphics/entity/car/car-mask-4.png`
- **Type:** impact
- **Source:** entities.lua

### __base__/graphics/entity/crash-site-chests/crash-site-chest-1.png
- **Internal name:** `__base__/graphics/entity/crash-site-chests/crash-site-chest-1.png`
- **Type:** impact
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-chests/crash-site-chest-2-ground.png
- **Internal name:** `__base__/graphics/entity/crash-site-chests/crash-site-chest-2-ground.png`
- **Type:** impact
- **Source:** crash-site.lua

### __base__/graphics/entity/factorio-logo/factorio-logo-16tiles.png
- **Internal name:** `__base__/graphics/entity/factorio-logo/factorio-logo-16tiles.png`
- **Type:** impact
- **Source:** factorio-logo.lua

### __base__/graphics/entity/laser-turret/laser-turret-raising.png
- **Internal name:** `__base__/graphics/entity/laser-turret/laser-turret-raising.png`
- **Type:** impact
- **Source:** turrets.lua

### __base__/graphics/entity/offshore-pump/offshore-pump-reflection.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump-reflection.png`
- **Type:** impact
- **Source:** entities.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_West-shadow.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_West-shadow.png`
- **Type:** impact
- **Source:** entities.lua

### __base__/graphics/entity/pipe-to-ground/visualization.png
- **Internal name:** `__base__/graphics/entity/pipe-to-ground/visualization.png`
- **Type:** impact
- **Source:** entities.lua

### __base__/graphics/entity/pipe/pipe-corner-down-left.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-corner-down-left.png`
- **Type:** impact
- **Source:** entities.lua

### __base__/graphics/entity/pipe/pipe-ending-down.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-ending-down.png`
- **Type:** impact
- **Source:** entities.lua

### __base__/graphics/entity/pipe/pipe-straight-vertical-window.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-straight-vertical-window.png`
- **Type:** impact
- **Source:** entities.lua

### __base__/graphics/entity/pipe/pipe-vertical-window-background.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-vertical-window-background.png`
- **Type:** impact
- **Source:** entities.lua

### __base__/graphics/entity/pipe/steam.png
- **Internal name:** `__base__/graphics/entity/pipe/steam.png`
- **Type:** impact
- **Source:** entities.lua

### __base__/graphics/entity/radar/radar-integration.png
- **Internal name:** `__base__/graphics/entity/radar/radar-integration.png`
- **Type:** impact
- **Source:** entities.lua

### __base__/graphics/entity/small-lamp/lamp-shadow.png
- **Internal name:** `__base__/graphics/entity/small-lamp/lamp-shadow.png`
- **Type:** impact
- **Source:** entities.lua

### __base__/graphics/entity/steam-engine/steam-engine-V.png
- **Internal name:** `__base__/graphics/entity/steam-engine/steam-engine-V.png`
- **Type:** impact
- **Source:** entities.lua

### __base__/graphics/entity/stone-furnace/stone-furnace-ground-light.png
- **Internal name:** `__base__/graphics/entity/stone-furnace/stone-furnace-ground-light.png`
- **Type:** impact
- **Source:** entities.lua

### __base__/graphics/entity/stone-furnace/stone-furnace-shadow.png
- **Internal name:** `__base__/graphics/entity/stone-furnace/stone-furnace-shadow.png`
- **Type:** impact
- **Source:** entities.lua

### __base__/sound/car-engine-stop.ogg
- **Internal name:** `__base__/sound/car-engine-stop.ogg`
- **Type:** impact
- **Source:** entities.lua

### __base__/sound/cargo-wagon/cargo-wagon-closed.ogg
- **Internal name:** `__base__/sound/cargo-wagon/cargo-wagon-closed.ogg`
- **Type:** impact
- **Source:** trains.lua

### __base__/sound/open-close/electric-small-open.ogg
- **Internal name:** `__base__/sound/open-close/electric-small-open.ogg`
- **Type:** impact
- **Source:** entities.lua

### __base__/sound/radar.ogg
- **Internal name:** `__base__/sound/radar.ogg`
- **Type:** impact
- **Source:** entities.lua

### __base__/sound/train-engine.ogg
- **Internal name:** `__base__/sound/train-engine.ogg`
- **Type:** impact
- **Source:** trains.lua

### dummy-elevated-curved-rail-b
- **Internal name:** `dummy-elevated-curved-rail-b`
- **Type:** impact
- **Source:** trains.lua

### signal-green
- **Internal name:** `signal-green`
- **Type:** impact
- **Source:** entities.lua

### signal-pink
- **Internal name:** `signal-pink`
- **Type:** impact
- **Source:** entities.lua


## Infinity Cargo Wagon

### __base__/graphics/entity/train-stop/train-stop-east-light-1.png
- **Internal name:** `__base__/graphics/entity/train-stop/train-stop-east-light-1.png`
- **Type:** infinity-cargo-wagon
- **Source:** trains.lua


## Infinity Container

### Electric furnace
- **Internal name:** `electric-furnace`
- **Type:** infinity-container
- **Health:** 350
- **Source:** entities.lua


## Infinity Pipe

### __base__/sound/electric-furnace.ogg
- **Internal name:** `__base__/sound/electric-furnace.ogg`
- **Type:** infinity-pipe
- **Source:** entities.lua


## Input

### Long-handed inserter
- **Internal name:** `long-handed-inserter`
- **Type:** input
- **Health:** 160
- **Source:** entities.lua

### Tiles
- **Internal name:** `tile-proxy`
- **Type:** input
- **Source:** entities.lua

### __base__/graphics/entity/car/car-light.png
- **Internal name:** `__base__/graphics/entity/car/car-light.png`
- **Type:** input
- **Source:** entities.lua

### __base__/graphics/entity/pipe/fluid-background.png
- **Internal name:** `__base__/graphics/entity/pipe/fluid-background.png`
- **Type:** input
- **Source:** entities.lua

### __base__/graphics/entity/pipe/pipe-t-up.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-t-up.png`
- **Type:** input
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-patch-shadow.png
- **Internal name:** `__base__/graphics/entity/wall/wall-patch-shadow.png`
- **Type:** input
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-patch.png
- **Internal name:** `__base__/graphics/entity/wall/wall-patch.png`
- **Type:** input
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-t-shadow.png
- **Internal name:** `__base__/graphics/entity/wall/wall-t-shadow.png`
- **Type:** input
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-t.png
- **Internal name:** `__base__/graphics/entity/wall/wall-t.png`
- **Type:** input
- **Source:** entities.lua

### __base__/sound/wooden-chest-close.ogg
- **Internal name:** `__base__/sound/wooden-chest-close.ogg`
- **Type:** input
- **Source:** entities.lua


## Inserter

### __base__/graphics/entity/long-handed-inserter/long-handed-inserter-hand-open.png
- **Internal name:** `__base__/graphics/entity/long-handed-inserter/long-handed-inserter-hand-open.png`
- **Type:** inserter
- **Source:** entities.lua

### __base__/sound/character-corpse-open.ogg
- **Internal name:** `__base__/sound/character-corpse-open.ogg`
- **Type:** inserter
- **Source:** entities.lua

### __base__/sound/eat-5.ogg
- **Internal name:** `__base__/sound/eat-5.ogg`
- **Type:** inserter
- **Source:** entities.lua

### character-footprint-particle
- **Internal name:** `character-footprint-particle`
- **Type:** inserter
- **Source:** entities.lua


## Instant

### Assembling machine 2
- **Internal name:** `assembling-machine-2`
- **Type:** instant
- **Health:** 350
- **Source:** entities.lua

### Big electric pole
- **Internal name:** `big-electric-pole`
- **Type:** instant
- **Health:** 150
- **Source:** entities.lua

### Biter spawner
- **Internal name:** `biter-spawner`
- **Type:** instant
- **Source:** enemies.lua

### Burner inserter
- **Internal name:** `burner-inserter`
- **Type:** instant
- **Health:** 100
- **Source:** entities.lua

### Enemy damaged explosion
- **Internal name:** `enemy-damaged-explosion`
- **Type:** instant
- **Source:** hit-effects.lua

### Entity ghost
- **Internal name:** `entity-ghost`
- **Type:** instant
- **Description:** Building plan of an entity, more in [tip=ghost-building]
- **Source:** entities.lua

### Flying robot damaged explosion
- **Internal name:** `flying-robot-damaged-explosion`
- **Type:** instant
- **Source:** hit-effects.lua

### Huge scorchmark
- **Internal name:** `huge-scorchmark`
- **Type:** instant
- **Source:** atomic-bomb.lua

### Logistic robot
- **Internal name:** `logistic-robot`
- **Type:** instant
- **Description:** Transports items between logistic chests.
- **Source:** flying-robots.lua

### Tile ghost
- **Internal name:** `tile-ghost`
- **Type:** instant
- **Source:** entities.lua

### __base__/graphics/entity/acid-splash/acid-splash-4.png
- **Internal name:** `__base__/graphics/entity/acid-splash/acid-splash-4.png`
- **Type:** instant
- **Source:** enemy-projectiles.lua

### __base__/graphics/entity/artillery-projectile/shell-shadow.png
- **Internal name:** `__base__/graphics/entity/artillery-projectile/shell-shadow.png`
- **Type:** instant
- **Source:** projectiles.lua

### __base__/graphics/entity/beam/tileable-beam-START.png
- **Internal name:** `__base__/graphics/entity/beam/tileable-beam-START.png`
- **Type:** instant
- **Source:** beams.lua

### __base__/graphics/entity/blue-laser/blue-laser.png
- **Internal name:** `__base__/graphics/entity/blue-laser/blue-laser.png`
- **Type:** instant
- **Source:** projectiles.lua

### __base__/graphics/entity/bullet/bullet.png
- **Internal name:** `__base__/graphics/entity/bullet/bullet.png`
- **Type:** instant
- **Source:** projectiles.lua

### __base__/graphics/entity/burner-inserter/burner-inserter-hand-closed.png
- **Internal name:** `__base__/graphics/entity/burner-inserter/burner-inserter-hand-closed.png`
- **Type:** instant
- **Source:** entities.lua

### __base__/graphics/entity/car/car-reflection.png
- **Internal name:** `__base__/graphics/entity/car/car-reflection.png`
- **Type:** instant
- **Source:** entities.lua

### __base__/graphics/entity/cluster-grenade/cluster-grenade.png
- **Internal name:** `__base__/graphics/entity/cluster-grenade/cluster-grenade.png`
- **Type:** instant
- **Source:** projectiles.lua

### __base__/graphics/entity/combat-robot-capsule/defender-capsule-shadow.png
- **Internal name:** `__base__/graphics/entity/combat-robot-capsule/defender-capsule-shadow.png`
- **Type:** instant
- **Source:** projectiles.lua

### __base__/graphics/entity/combat-robot-capsule/distractor-capsule-mask.png
- **Internal name:** `__base__/graphics/entity/combat-robot-capsule/distractor-capsule-mask.png`
- **Type:** instant
- **Source:** projectiles.lua

### __base__/graphics/entity/construction-robot/construction-robot-shadow.png
- **Internal name:** `__base__/graphics/entity/construction-robot/construction-robot-shadow.png`
- **Type:** instant
- **Source:** flying-robots.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-2.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-2.png`
- **Type:** instant
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-3-shadow.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-3-shadow.png`
- **Type:** instant
- **Source:** crash-site.lua

### __base__/graphics/entity/flamethrower-fire-stream/flamethrower-explosion.png
- **Internal name:** `__base__/graphics/entity/flamethrower-fire-stream/flamethrower-explosion.png`
- **Type:** instant
- **Source:** fire.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-east-mask.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-east-mask.png`
- **Type:** instant
- **Source:** fire.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-south-shadow.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-south-shadow.png`
- **Type:** instant
- **Source:** fire.lua

### __base__/graphics/entity/grenade/grenade.png
- **Internal name:** `__base__/graphics/entity/grenade/grenade.png`
- **Type:** instant
- **Source:** projectiles.lua

### __base__/graphics/entity/lab/lab-integration.png
- **Internal name:** `__base__/graphics/entity/lab/lab-integration.png`
- **Type:** instant
- **Source:** entities.lua

### __base__/graphics/entity/laser-turret/laser-end.png
- **Internal name:** `__base__/graphics/entity/laser-turret/laser-end.png`
- **Type:** instant
- **Source:** beams.lua

### __base__/graphics/entity/laser-turret/laser-ground-light-tail.png
- **Internal name:** `__base__/graphics/entity/laser-turret/laser-ground-light-tail.png`
- **Type:** instant
- **Source:** beams.lua

### __base__/graphics/entity/poison-capsule/poison-capsule-shadow.png
- **Internal name:** `__base__/graphics/entity/poison-capsule/poison-capsule-shadow.png`
- **Type:** instant
- **Source:** projectiles.lua

### __base__/graphics/entity/small-electric-pole/small-electric-pole-reflection.png
- **Internal name:** `__base__/graphics/entity/small-electric-pole/small-electric-pole-reflection.png`
- **Type:** instant
- **Source:** entities.lua

### __base__/graphics/entity/sparks/sparks-03.png
- **Internal name:** `__base__/graphics/entity/sparks/sparks-03.png`
- **Type:** instant
- **Source:** flying-robots.lua

### __core__/graphics/icons/alerts/fuel-icon-red.png
- **Internal name:** `__core__/graphics/icons/alerts/fuel-icon-red.png`
- **Type:** instant
- **Source:** fire.lua

### __core__/sound/build-ghost-large.ogg
- **Internal name:** `__core__/sound/build-ghost-large.ogg`
- **Type:** instant
- **Source:** entities.lua

### acid-splash-worm-small
- **Internal name:** `acid-splash-worm-small`
- **Type:** instant
- **Source:** enemy-projectiles.lua

### active-provider-chest-metal-particle-small
- **Internal name:** `active-provider-chest-metal-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### arithmetic-combinator-metal-particle-big
- **Internal name:** `arithmetic-combinator-metal-particle-big`
- **Type:** instant
- **Source:** explosions.lua

### artillery-wagon-metal-particle-big
- **Internal name:** `artillery-wagon-metal-particle-big`
- **Type:** instant
- **Source:** explosions.lua

### assembling-machine-2-metal-particle-small
- **Internal name:** `assembling-machine-2-metal-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### assembling-machine-mechanical-component-particle-medium
- **Internal name:** `assembling-machine-mechanical-component-particle-medium`
- **Type:** instant
- **Source:** explosions.lua

### atomic-bomb-ground-zero-projectile
- **Internal name:** `atomic-bomb-ground-zero-projectile`
- **Type:** instant
- **Source:** atomic-bomb.lua

### atomic-fire-smoke
- **Internal name:** `atomic-fire-smoke`
- **Type:** instant
- **Source:** atomic-bomb.lua

### atomic-nuke-shockwave
- **Internal name:** `atomic-nuke-shockwave`
- **Type:** instant
- **Source:** atomic-bomb.lua

### beacon-explosion
- **Internal name:** `beacon-explosion`
- **Type:** instant
- **Source:** explosions.lua

### behemoth-biter-die
- **Internal name:** `behemoth-biter-die`
- **Type:** instant
- **Source:** explosions.lua

### behemoth-worm-die
- **Internal name:** `behemoth-worm-die`
- **Type:** instant
- **Source:** explosions.lua

### big-electric-pole-long-metal-particle-medium
- **Internal name:** `big-electric-pole-long-metal-particle-medium`
- **Type:** instant
- **Source:** explosions.lua

### big-rock-stone-particle-medium
- **Internal name:** `big-rock-stone-particle-medium`
- **Type:** instant
- **Source:** explosions.lua

### buffer-chest-explosion
- **Internal name:** `buffer-chest-explosion`
- **Type:** instant
- **Source:** explosions.lua

### bulk-inserter-explosion
- **Internal name:** `bulk-inserter-explosion`
- **Type:** instant
- **Source:** explosions.lua

### burner-inserter-metal-particle-small
- **Internal name:** `burner-inserter-metal-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### burner-mining-drill-metal-particle-big
- **Internal name:** `burner-mining-drill-metal-particle-big`
- **Type:** instant
- **Source:** explosions.lua

### cannon-projectile
- **Internal name:** `cannon-projectile`
- **Type:** instant
- **Source:** projectiles.lua

### cargo-pod-container-explosion
- **Internal name:** `cargo-pod-container-explosion`
- **Type:** instant
- **Source:** explosions.lua

### chemical-plant-mechanical-component-particle-medium
- **Internal name:** `chemical-plant-mechanical-component-particle-medium`
- **Type:** instant
- **Source:** explosions.lua

### concrete-stone-particle-small
- **Internal name:** `concrete-stone-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### defender-robot-metal-particle-small
- **Internal name:** `defender-robot-metal-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### electric-furnace-metal-particle-small
- **Internal name:** `electric-furnace-metal-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### electric-mining-drill-metal-particle-medium
- **Internal name:** `electric-mining-drill-metal-particle-medium`
- **Type:** instant
- **Source:** explosions.lua

### explosion-stone-particle-tiny
- **Internal name:** `explosion-stone-particle-tiny`
- **Type:** instant
- **Source:** explosions.lua

### explosive-rocket
- **Internal name:** `explosive-rocket`
- **Type:** instant
- **Source:** projectiles.lua

### explosive-uranium-cannon-projectile
- **Internal name:** `explosive-uranium-cannon-projectile`
- **Type:** instant
- **Source:** projectiles.lua

### express-transport-belt-explosion
- **Internal name:** `express-transport-belt-explosion`
- **Type:** instant
- **Source:** explosions.lua

### express-underground-belt-explosion
- **Internal name:** `express-underground-belt-explosion`
- **Type:** instant
- **Source:** explosions.lua

### fast-inserter-metal-particle-small
- **Internal name:** `fast-inserter-metal-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### fast-splitter-metal-particle-medium
- **Internal name:** `fast-splitter-metal-particle-medium`
- **Type:** instant
- **Source:** explosions.lua

### fast-underground-belt-explosion-base
- **Internal name:** `fast-underground-belt-explosion-base`
- **Type:** instant
- **Source:** explosions.lua

### fire-sticker
- **Internal name:** `fire-sticker`
- **Type:** instant
- **Source:** fire.lua

### flame-thrower-turret-metal-particle-small
- **Internal name:** `flame-thrower-turret-metal-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### gate-metal-particle-big
- **Internal name:** `gate-metal-particle-big`
- **Type:** instant
- **Source:** explosions.lua

### gun-turret-metal-particle-big
- **Internal name:** `gun-turret-metal-particle-big`
- **Type:** instant
- **Source:** explosions.lua

### guts-entrails-particle-small-medium
- **Internal name:** `guts-entrails-particle-small-medium`
- **Type:** instant
- **Source:** biter-die-effects.lua

### guts-entrails-particle-spawner
- **Internal name:** `guts-entrails-particle-spawner`
- **Type:** instant
- **Source:** biter-die-effects.lua

### heat-exchanger-metal-particle-small
- **Internal name:** `heat-exchanger-metal-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### iron-chest-metal-particle-medium
- **Internal name:** `iron-chest-metal-particle-medium`
- **Type:** instant
- **Source:** explosions.lua

### lab-mechanical-component-particle-medium
- **Internal name:** `lab-mechanical-component-particle-medium`
- **Type:** instant
- **Source:** explosions.lua

### lamp-metal-particle-small
- **Internal name:** `lamp-metal-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### locomotive-metal-particle-medium
- **Internal name:** `locomotive-metal-particle-medium`
- **Type:** instant
- **Source:** explosions.lua

### logistic-robot-metal-particle-small
- **Internal name:** `logistic-robot-metal-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### long-handed-inserter-metal-particle-small
- **Internal name:** `long-handed-inserter-metal-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### medium-electric-pole-long-metal-particle-medium
- **Internal name:** `medium-electric-pole-long-metal-particle-medium`
- **Type:** instant
- **Source:** explosions.lua

### nuclear-reactor-glass-particle-small
- **Internal name:** `nuclear-reactor-glass-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### offshore-pump-metal-particle-medium
- **Internal name:** `offshore-pump-metal-particle-medium`
- **Type:** instant
- **Source:** explosions.lua

### oil-refinery-long-metal-particle-medium
- **Internal name:** `oil-refinery-long-metal-particle-medium`
- **Type:** instant
- **Source:** explosions.lua

### pipe-explosion
- **Internal name:** `pipe-explosion`
- **Type:** instant
- **Source:** explosions.lua

### pipe-to-ground-explosion
- **Internal name:** `pipe-to-ground-explosion`
- **Type:** instant
- **Source:** explosions.lua

### poison-capsule
- **Internal name:** `poison-capsule`
- **Type:** instant
- **Source:** projectiles.lua

### power-switch-explosion
- **Internal name:** `power-switch-explosion`
- **Type:** instant
- **Source:** explosions.lua

### programmable-speaker-metal-particle-small
- **Internal name:** `programmable-speaker-metal-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### pump-glass-particle-small
- **Internal name:** `pump-glass-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### pumpjack-metal-particle-medium
- **Internal name:** `pumpjack-metal-particle-medium`
- **Type:** instant
- **Source:** explosions.lua

### radar-metal-particle-small
- **Internal name:** `radar-metal-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### rail-signal-glass-particle-small-green
- **Internal name:** `rail-signal-glass-particle-small-green`
- **Type:** instant
- **Source:** explosions.lua

### rail-stone-particle-small
- **Internal name:** `rail-stone-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### requester-chest-metal-particle-medium
- **Internal name:** `requester-chest-metal-particle-medium`
- **Type:** instant
- **Source:** explosions.lua

### rocket-silo-metal-particle-medium
- **Internal name:** `rocket-silo-metal-particle-medium`
- **Type:** instant
- **Source:** explosions.lua

### selector-combinator-metal-particle-big
- **Internal name:** `selector-combinator-metal-particle-big`
- **Type:** instant
- **Source:** explosions.lua

### slowdown-capsule-particle-big
- **Internal name:** `slowdown-capsule-particle-big`
- **Type:** instant
- **Source:** explosions.lua

### spark-particle-debris
- **Internal name:** `spark-particle-debris`
- **Type:** instant
- **Source:** hit-effects.lua

### spidertron-metal-particle-medium
- **Internal name:** `spidertron-metal-particle-medium`
- **Type:** instant
- **Source:** explosions.lua

### splitter-long-metal-particle-medium
- **Internal name:** `splitter-long-metal-particle-medium`
- **Type:** instant
- **Source:** explosions.lua

### steam-engine-explosion
- **Internal name:** `steam-engine-explosion`
- **Type:** instant
- **Source:** explosions.lua

### steam-turbine-metal-particle-big
- **Internal name:** `steam-turbine-metal-particle-big`
- **Type:** instant
- **Source:** explosions.lua

### steel-furnace-metal-particle-small
- **Internal name:** `steel-furnace-metal-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### stone-furnace-stone-particle-small
- **Internal name:** `stone-furnace-stone-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### storage-tank-metal-particle-big
- **Internal name:** `storage-tank-metal-particle-big`
- **Type:** instant
- **Source:** explosions.lua

### tank-metal-particle-big
- **Internal name:** `tank-metal-particle-big`
- **Type:** instant
- **Source:** explosions.lua

### tintable-water-particle
- **Internal name:** `tintable-water-particle`
- **Type:** instant
- **Source:** explosions.lua

### transport-belt-metal-particle-small
- **Internal name:** `transport-belt-metal-particle-small`
- **Type:** instant
- **Source:** explosions.lua

### tree_dead_dry_hairy
- **Internal name:** `tree_dead_dry_hairy`
- **Type:** instant
- **Source:** trees.lua

### underground-belt-explosion
- **Internal name:** `underground-belt-explosion`
- **Type:** instant
- **Source:** explosions.lua


## Invoke Tile Trigger

### uranium-cannon-projectile
- **Internal name:** `uranium-cannon-projectile`
- **Type:** invoke-tile-trigger
- **Source:** projectiles.lua


## Item Entity

### __base__/sound/furnace.ogg
- **Internal name:** `__base__/sound/furnace.ogg`
- **Type:** item-entity
- **Source:** entities.lua


## Item Request Proxy

### Small electric pole
- **Internal name:** `small-electric-pole`
- **Type:** item-request-proxy
- **Health:** 100
- **Source:** entities.lua


## Lab

### __base__/sound/offshore-pump.ogg
- **Internal name:** `__base__/sound/offshore-pump.ogg`
- **Type:** lab
- **Source:** entities.lua


## Lamp

### Fish
- **Internal name:** `fish`
- **Type:** lamp
- **Health:** 20
- **Source:** entities.lua


## Lane Splitter

### __core__/graphics/arrows/underground-lines-remove.png
- **Internal name:** `__core__/graphics/arrows/underground-lines-remove.png`
- **Type:** lane-splitter
- **Source:** transport-belts.lua


## Laser

### Medium worm
- **Internal name:** `medium-worm-turret`
- **Type:** laser
- **Source:** turrets.lua

### Small worm
- **Internal name:** `small-worm-turret`
- **Type:** laser
- **Source:** turrets.lua

### __base__/graphics/entity/car/car-shadow-2.png
- **Internal name:** `__base__/graphics/entity/car/car-shadow-2.png`
- **Type:** laser
- **Source:** entities.lua

### __base__/graphics/entity/inserter/inserter-hand-open.png
- **Internal name:** `__base__/graphics/entity/inserter/inserter-hand-open.png`
- **Type:** laser
- **Source:** entities.lua

### __base__/graphics/entity/laser-turret/laser-turret-base-shadow.png
- **Internal name:** `__base__/graphics/entity/laser-turret/laser-turret-base-shadow.png`
- **Type:** laser
- **Source:** turrets.lua

### __base__/graphics/entity/steam-engine/steam-engine-reflection.png
- **Internal name:** `__base__/graphics/entity/steam-engine/steam-engine-reflection.png`
- **Type:** laser
- **Source:** entities.lua

### water-wube
- **Internal name:** `water-wube`
- **Type:** laser
- **Source:** factorio-logo.lua


## Legacy Straight Rail

### Legacy straight rail
- **Internal name:** `legacy-straight-rail`
- **Type:** legacy-straight-rail
- **Source:** trains.lua


## Light Oil

### fire-smoke-without-glow
- **Internal name:** `fire-smoke-without-glow`
- **Type:** light-oil
- **Source:** fire.lua


## Linked Container

### __base__/graphics/entity/electric-furnace/electric-furnace-ground-light.png
- **Internal name:** `__base__/graphics/entity/electric-furnace/electric-furnace-ground-light.png`
- **Type:** linked-container
- **Source:** entities.lua


## Loader

### __base__/graphics/entity/fast-underground-belt/fast-underground-belt-structure-front-patch.png
- **Internal name:** `__base__/graphics/entity/fast-underground-belt/fast-underground-belt-structure-front-patch.png`
- **Type:** loader
- **Source:** transport-belts.lua

### __base__/graphics/entity/fast-underground-belt/fast-underground-belt-structure.png
- **Internal name:** `__base__/graphics/entity/fast-underground-belt/fast-underground-belt-structure.png`
- **Type:** loader
- **Source:** transport-belts.lua


## Logistic Container

### Pipe
- **Internal name:** `pipe`
- **Type:** logistic-container
- **Health:** 100
- **Source:** entities.lua

### __base__/graphics/entity/radar/radar-reflection.png
- **Internal name:** `__base__/graphics/entity/radar/radar-reflection.png`
- **Type:** logistic-container
- **Source:** entities.lua

### __base__/graphics/entity/radar/radar.png
- **Internal name:** `__base__/graphics/entity/radar/radar.png`
- **Type:** logistic-container
- **Source:** entities.lua

### __base__/graphics/entity/small-lamp/lamp-light.png
- **Internal name:** `__base__/graphics/entity/small-lamp/lamp-light.png`
- **Type:** logistic-container
- **Source:** entities.lua

### __base__/sound/open-close/electric-small-close.ogg
- **Internal name:** `__base__/sound/open-close/electric-small-close.ogg`
- **Type:** logistic-container
- **Source:** entities.lua


## Logistic Robot

### __base__/graphics/entity/logistic-robot/logistic-robot-shadow.png
- **Internal name:** `__base__/graphics/entity/logistic-robot/logistic-robot-shadow.png`
- **Type:** logistic-robot
- **Source:** flying-robots.lua


## Mining Drill

### __base__/graphics/entity/electric-mining-drill/electric-mining-drill-horizontal.png
- **Internal name:** `__base__/graphics/entity/electric-mining-drill/electric-mining-drill-horizontal.png`
- **Type:** mining-drill
- **Source:** mining-drill.lua

### __base__/graphics/entity/electric-mining-drill/electric-mining-drill-smoke.png
- **Internal name:** `__base__/graphics/entity/electric-mining-drill/electric-mining-drill-smoke.png`
- **Type:** mining-drill
- **Source:** mining-drill.lua

### __base__/graphics/entity/electric-mining-drill/electric-mining-drill.png
- **Internal name:** `__base__/graphics/entity/electric-mining-drill/electric-mining-drill.png`
- **Type:** mining-drill
- **Source:** mining-drill.lua


## Nested Result

### __base__/graphics/entity/beam/beam-body-2.png
- **Internal name:** `__base__/graphics/entity/beam/beam-body-2.png`
- **Type:** nested-result
- **Source:** beams.lua

### poison-capsule-smoke
- **Internal name:** `poison-capsule-smoke`
- **Type:** nested-result
- **Source:** projectiles.lua


## Noise Expression

### __base__/graphics/entity/tree/02/tree-02-reflection.png
- **Internal name:** `__base__/graphics/entity/tree/02/tree-02-reflection.png`
- **Type:** noise-expression
- **Source:** trees.lua

### __base__/graphics/entity/tree/03/tree-03-reflection.png
- **Internal name:** `__base__/graphics/entity/tree/03/tree-03-reflection.png`
- **Type:** noise-expression
- **Source:** trees.lua

### __base__/graphics/entity/tree/04/tree-04-reflection.png
- **Internal name:** `__base__/graphics/entity/tree/04/tree-04-reflection.png`
- **Type:** noise-expression
- **Source:** trees.lua

### __base__/graphics/entity/tree/05/tree-05-reflection.png
- **Internal name:** `__base__/graphics/entity/tree/05/tree-05-reflection.png`
- **Type:** noise-expression
- **Source:** trees.lua

### __base__/graphics/entity/tree/06/tree-06-reflection.png
- **Internal name:** `__base__/graphics/entity/tree/06/tree-06-reflection.png`
- **Type:** noise-expression
- **Source:** trees.lua

### __base__/graphics/entity/tree/07/tree-07-reflection.png
- **Internal name:** `__base__/graphics/entity/tree/07/tree-07-reflection.png`
- **Type:** noise-expression
- **Source:** trees.lua

### __base__/graphics/entity/tree/08/tree-08-reflection.png
- **Internal name:** `__base__/graphics/entity/tree/08/tree-08-reflection.png`
- **Type:** noise-expression
- **Source:** trees.lua

### __base__/graphics/entity/tree/09/tree-09-reflection.png
- **Internal name:** `__base__/graphics/entity/tree/09/tree-09-reflection.png`
- **Type:** noise-expression
- **Source:** trees.lua

### tree_01
- **Internal name:** `tree_01`
- **Type:** noise-expression
- **Source:** trees.lua

### tree_02
- **Internal name:** `tree_02`
- **Type:** noise-expression
- **Source:** trees.lua

### tree_02_red
- **Internal name:** `tree_02_red`
- **Type:** noise-expression
- **Source:** trees.lua

### tree_03
- **Internal name:** `tree_03`
- **Type:** noise-expression
- **Source:** trees.lua

### tree_04
- **Internal name:** `tree_04`
- **Type:** noise-expression
- **Source:** trees.lua

### tree_05
- **Internal name:** `tree_05`
- **Type:** noise-expression
- **Source:** trees.lua

### tree_06
- **Internal name:** `tree_06`
- **Type:** noise-expression
- **Source:** trees.lua

### tree_06_brown
- **Internal name:** `tree_06_brown`
- **Type:** noise-expression
- **Source:** trees.lua

### tree_07
- **Internal name:** `tree_07`
- **Type:** noise-expression
- **Source:** trees.lua

### tree_08
- **Internal name:** `tree_08`
- **Type:** noise-expression
- **Source:** trees.lua

### tree_08_brown
- **Internal name:** `tree_08_brown`
- **Type:** noise-expression
- **Source:** trees.lua

### tree_08_red
- **Internal name:** `tree_08_red`
- **Type:** noise-expression
- **Source:** trees.lua


## None

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-gun-mask.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-gun-mask.png`
- **Type:** none
- **Source:** fire.lua


## Normal

### Spaceship
- **Internal name:** `crash-site-spaceship`
- **Type:** normal
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-shadow.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-shadow.png`
- **Type:** normal
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-big-1.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-big-1.png`
- **Type:** normal
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-big-2-ground.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-big-2-ground.png`
- **Type:** normal
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-1-shadow.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-1-shadow.png`
- **Type:** normal
- **Source:** crash-site.lua

### crash-site-spaceship-wreck-medium-1
- **Internal name:** `crash-site-spaceship-wreck-medium-1`
- **Type:** normal
- **Source:** crash-site.lua


## Offshore Pump

### __base__/graphics/entity/pipe/fluid-flow-medium-temperature.png
- **Internal name:** `__base__/graphics/entity/pipe/fluid-flow-medium-temperature.png`
- **Type:** offshore-pump
- **Source:** entities.lua


## Optimized Particle

### __base__/graphics/entity/accumulator/accumulator-charge.png
- **Internal name:** `__base__/graphics/entity/accumulator/accumulator-charge.png`
- **Type:** optimized-particle
- **Source:** entities.lua


## Oriented

### Locomotive
- **Internal name:** `locomotive`
- **Type:** oriented
- **Description:** Runs automated schedules and pulls rolling stock.
- **Health:** 1000
- **Source:** trains.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_South-fluid.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_South-fluid.png`
- **Type:** oriented
- **Source:** entities.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_West-fluid.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_West-fluid.png`
- **Type:** oriented
- **Source:** entities.lua

### __base__/graphics/entity/pipe/visualization.png
- **Internal name:** `__base__/graphics/entity/pipe/visualization.png`
- **Type:** oriented
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-single-shadow.png
- **Internal name:** `__base__/graphics/entity/wall/wall-single-shadow.png`
- **Type:** oriented
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-vertical.png
- **Internal name:** `__base__/graphics/entity/wall/wall-vertical.png`
- **Type:** oriented
- **Source:** entities.lua


## Output

### Car
- **Internal name:** `car`
- **Type:** output
- **Health:** 450
- **Source:** entities.lua

### __base__/graphics/entity/long-handed-inserter/long-handed-inserter-hand-base.png
- **Internal name:** `__base__/graphics/entity/long-handed-inserter/long-handed-inserter-hand-base.png`
- **Type:** output
- **Source:** entities.lua

### __base__/graphics/entity/pipe/pipe-t-down.png
- **Internal name:** `__base__/graphics/entity/pipe/pipe-t-down.png`
- **Type:** output
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-ending-left.png
- **Internal name:** `__base__/graphics/entity/wall/wall-ending-left.png`
- **Type:** output
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-ending-right-shadow.png
- **Internal name:** `__base__/graphics/entity/wall/wall-ending-right-shadow.png`
- **Type:** output
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-ending-right.png
- **Internal name:** `__base__/graphics/entity/wall/wall-ending-right.png`
- **Type:** output
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-gate-shadow.png
- **Internal name:** `__base__/graphics/entity/wall/wall-gate-shadow.png`
- **Type:** output
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-gate.png
- **Internal name:** `__base__/graphics/entity/wall/wall-gate.png`
- **Type:** output
- **Source:** entities.lua

### __base__/graphics/entity/wooden-chest/wooden-chest.png
- **Internal name:** `__base__/graphics/entity/wooden-chest/wooden-chest.png`
- **Type:** output
- **Source:** entities.lua

### __base__/sound/car-crash.ogg
- **Internal name:** `__base__/sound/car-crash.ogg`
- **Type:** output
- **Source:** entities.lua


## Particle Source

### nuclear-smouldering-smoke-source
- **Internal name:** `nuclear-smouldering-smoke-source`
- **Type:** particle-source
- **Source:** atomic-bomb.lua


## Physical

### Behemoth biter corpse
- **Internal name:** `behemoth-biter-corpse`
- **Type:** physical
- **Source:** enemies.lua

### Behemoth spitter
- **Internal name:** `behemoth-spitter`
- **Type:** physical
- **Source:** enemies.lua

### Behemoth spitter corpse
- **Internal name:** `behemoth-spitter-corpse`
- **Type:** physical
- **Source:** enemies.lua

### Biter spawner corpse
- **Internal name:** `biter-spawner-corpse`
- **Type:** physical
- **Source:** enemies.lua

### Factorio logo 16 tiles
- **Internal name:** `factorio-logo-16tiles`
- **Type:** physical
- **Source:** factorio-logo.lua

### __base__
- **Internal name:** `__base__`
- **Type:** physical
- **Crafting speed:** 1
- **Energy usage:** 480kW
- **Source:** entities.lua

### __base__/graphics/entity/artillery-turret/artillery-turret-base.png
- **Internal name:** `__base__/graphics/entity/artillery-turret/artillery-turret-base.png`
- **Type:** physical
- **Source:** turrets.lua

### __base__/graphics/entity/big-electric-pole/big-electric-pole-shadow.png
- **Internal name:** `__base__/graphics/entity/big-electric-pole/big-electric-pole-shadow.png`
- **Type:** physical
- **Source:** entities.lua

### __base__/graphics/entity/car/car-mask-3.png
- **Internal name:** `__base__/graphics/entity/car/car-mask-3.png`
- **Type:** physical
- **Source:** entities.lua

### __base__/graphics/entity/construction-robot/construction-robot-reflection.png
- **Internal name:** `__base__/graphics/entity/construction-robot/construction-robot-reflection.png`
- **Type:** physical
- **Source:** entities.lua

### __base__/graphics/entity/gun-turret/gun-turret-reflection.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-reflection.png`
- **Type:** physical
- **Source:** turrets.lua

### __base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-4.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-4.png`
- **Type:** physical
- **Source:** turrets.lua

### __base__/graphics/entity/laser-turret/laser-turret-shooting-light.png
- **Internal name:** `__base__/graphics/entity/laser-turret/laser-turret-shooting-light.png`
- **Type:** physical
- **Source:** turrets.lua

### __base__/graphics/entity/logistic-robot/logistic-robot.png
- **Internal name:** `__base__/graphics/entity/logistic-robot/logistic-robot.png`
- **Type:** physical
- **Source:** flying-robots.lua

### __base__/graphics/entity/slowdown-capsule/slowdown-capsule-shadow.png
- **Internal name:** `__base__/graphics/entity/slowdown-capsule/slowdown-capsule-shadow.png`
- **Type:** physical
- **Source:** projectiles.lua

### __base__/graphics/entity/small-electric-pole/small-electric-pole-shadow.png
- **Internal name:** `__base__/graphics/entity/small-electric-pole/small-electric-pole-shadow.png`
- **Type:** physical
- **Source:** entities.lua

### __base__/graphics/entity/steam-engine/steam-engine-H-shadow.png
- **Internal name:** `__base__/graphics/entity/steam-engine/steam-engine-H-shadow.png`
- **Type:** physical
- **Source:** entities.lua

### __base__/graphics/entity/steam-engine/steam-engine-H.png
- **Internal name:** `__base__/graphics/entity/steam-engine/steam-engine-H.png`
- **Type:** physical
- **Source:** entities.lua

### __base__/sound/car-door-open.ogg
- **Internal name:** `__base__/sound/car-door-open.ogg`
- **Type:** physical
- **Source:** entities.lua

### __base__/sound/cargo-wagon/cargo-wagon-closing-loop.ogg
- **Internal name:** `__base__/sound/cargo-wagon/cargo-wagon-closing-loop.ogg`
- **Type:** physical
- **Source:** trains.lua

### __base__/sound/train-door-close.ogg
- **Internal name:** `__base__/sound/train-door-close.ogg`
- **Type:** physical
- **Source:** trains.lua

### __base__/sound/train-engine-driving.ogg
- **Internal name:** `__base__/sound/train-engine-driving.ogg`
- **Type:** physical
- **Source:** trains.lua

### __core__/graphics/cursor-boxes-32x32.png
- **Internal name:** `__core__/graphics/cursor-boxes-32x32.png`
- **Type:** physical
- **Source:** entities.lua

### acid-stream-spitter-small
- **Internal name:** `acid-stream-spitter-small`
- **Type:** physical
- **Source:** enemies.lua

### destroyer-capsule
- **Internal name:** `destroyer-capsule`
- **Type:** physical
- **Source:** projectiles.lua

### distractor-capsule
- **Internal name:** `distractor-capsule`
- **Type:** physical
- **Source:** projectiles.lua


## Pipe

### smoke
- **Internal name:** `smoke`
- **Type:** pipe
- **Source:** entities.lua


## Pipe To Ground

### __base__/graphics/entity/boiler/boiler-S-shadow.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-S-shadow.png`
- **Type:** pipe-to-ground
- **Source:** entities.lua


## Play Sound

### Construction robot
- **Internal name:** `construction-robot`
- **Type:** play-sound
- **Description:** Automatically build and repair friendly entities.
- **Source:** flying-robots.lua

### Destroyer
- **Internal name:** `destroyer`
- **Type:** play-sound
- **Health:** 60
- **Source:** flying-robots.lua

### __base__/graphics/entity/accumulator/accumulator.png
- **Internal name:** `__base__/graphics/entity/accumulator/accumulator.png`
- **Type:** play-sound
- **Source:** entities.lua

### __base__/graphics/entity/acid-splash/acid-splash-4-shadow.png
- **Internal name:** `__base__/graphics/entity/acid-splash/acid-splash-4-shadow.png`
- **Type:** play-sound
- **Source:** enemy-projectiles.lua

### __base__/graphics/entity/assembling-machine-2/assembling-machine-2-shadow.png
- **Internal name:** `__base__/graphics/entity/assembling-machine-2/assembling-machine-2-shadow.png`
- **Type:** play-sound
- **Source:** entities.lua

### __base__/graphics/entity/locomotive/minimap-representation/locomotive-minimap-representation.png
- **Internal name:** `__base__/graphics/entity/locomotive/minimap-representation/locomotive-minimap-representation.png`
- **Type:** play-sound
- **Source:** trains.lua

### __base__/graphics/entity/locomotive/minimap-representation/locomotive-selected-minimap-representation.png
- **Internal name:** `__base__/graphics/entity/locomotive/minimap-representation/locomotive-selected-minimap-representation.png`
- **Type:** play-sound
- **Source:** trains.lua

### __base__/graphics/entity/locomotive/reflection/locomotive-reflection.png
- **Internal name:** `__base__/graphics/entity/locomotive/reflection/locomotive-reflection.png`
- **Type:** play-sound
- **Source:** trains.lua

### __base__/graphics/entity/offshore-pump/offshore-pump_North-glass.png
- **Internal name:** `__base__/graphics/entity/offshore-pump/offshore-pump_North-glass.png`
- **Type:** play-sound
- **Source:** entities.lua

### __base__/graphics/entity/tree/01/tree-01-reflection.png
- **Internal name:** `__base__/graphics/entity/tree/01/tree-01-reflection.png`
- **Type:** play-sound
- **Source:** trees.lua

### __base__/graphics/entity/wall/wall-vertical-shadow.png
- **Internal name:** `__base__/graphics/entity/wall/wall-vertical-shadow.png`
- **Type:** play-sound
- **Source:** entities.lua

### __base__/sound/armor-open.ogg
- **Internal name:** `__base__/sound/armor-open.ogg`
- **Type:** play-sound
- **Source:** sounds.lua

### __base__/sound/artillery-open.ogg
- **Internal name:** `__base__/sound/artillery-open.ogg`
- **Type:** play-sound
- **Source:** sounds.lua

### __base__/sound/electric-network-open.ogg
- **Internal name:** `__base__/sound/electric-network-open.ogg`
- **Type:** play-sound
- **Source:** sounds.lua

### __base__/sound/fight/distractor-robot-loop.ogg
- **Internal name:** `__base__/sound/fight/distractor-robot-loop.ogg`
- **Type:** play-sound
- **Source:** flying-robots.lua

### __base__/sound/open-close/combinator-open.ogg
- **Internal name:** `__base__/sound/open-close/combinator-open.ogg`
- **Type:** play-sound
- **Source:** sounds.lua

### __base__/sound/open-close/drill-open.ogg
- **Internal name:** `__base__/sound/open-close/drill-open.ogg`
- **Type:** play-sound
- **Source:** sounds.lua

### __core__/sound/deconstruct-bricks.bnvib
- **Internal name:** `__core__/sound/deconstruct-bricks.bnvib`
- **Type:** play-sound
- **Source:** sounds.lua

### __core__/sound/deconstruct-large.bnvib
- **Internal name:** `__core__/sound/deconstruct-large.bnvib`
- **Type:** play-sound
- **Source:** sounds.lua

### __core__/sound/deconstruct-medium.ogg
- **Internal name:** `__core__/sound/deconstruct-medium.ogg`
- **Type:** play-sound
- **Source:** sounds.lua

### acid-particle
- **Internal name:** `acid-particle`
- **Type:** play-sound
- **Source:** biter-die-effects.lua

### lab-metal-particle-medium
- **Internal name:** `lab-metal-particle-medium`
- **Type:** play-sound
- **Source:** explosions.lua


## Pod Catalogue

### __base__/graphics/entity/big-electric-pole/big-electric-pole-reflection.png
- **Internal name:** `__base__/graphics/entity/big-electric-pole/big-electric-pole-reflection.png`
- **Type:** pod-catalogue
- **Source:** entities.lua


## Poison

### __core__/sound/deconstruct-ghost-tile.ogg
- **Internal name:** `__core__/sound/deconstruct-ghost-tile.ogg`
- **Type:** poison
- **Source:** entities.lua


## Power Switch

### __base__/graphics/entity/programmable-speaker/programmable-speaker-shadow.png
- **Internal name:** `__base__/graphics/entity/programmable-speaker/programmable-speaker-shadow.png`
- **Type:** power-switch
- **Source:** circuit-network.lua


## Programmable Speaker

### Programmable speaker
- **Internal name:** `programmable-speaker`
- **Type:** programmable-speaker
- **Description:** Connects to the circuit network in order to play alarms and musical notes, or show alerts.
- **Health:** 150
- **Source:** circuit-network.lua


## Projectile

### Big biter
- **Internal name:** `big-biter`
- **Type:** projectile
- **Source:** enemies.lua

### Medium biter corpse
- **Internal name:** `medium-biter-corpse`
- **Type:** projectile
- **Source:** enemies.lua

### Medium spitter corpse
- **Internal name:** `medium-spitter-corpse`
- **Type:** projectile
- **Source:** enemies.lua

### Small tinted scorchmark
- **Internal name:** `small-scorchmark-tintable`
- **Type:** projectile
- **Source:** projectiles.lua

### __base__/graphics/entity/gun-turret/gun-turret-shooting-4.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-shooting-4.png`
- **Type:** projectile
- **Source:** turrets.lua

### __base__/graphics/entity/smoke/smoke.png
- **Internal name:** `__base__/graphics/entity/smoke/smoke.png`
- **Type:** projectile
- **Source:** atomic-bomb.lua

### __base__/graphics/entity/sparks/sparks-01.png
- **Internal name:** `__base__/graphics/entity/sparks/sparks-01.png`
- **Type:** projectile
- **Source:** flying-robots.lua

### __base__/sound/creatures/spawner-spitter.ogg
- **Internal name:** `__base__/sound/creatures/spawner-spitter.ogg`
- **Type:** projectile
- **Source:** enemies.lua

### artillery-projectile
- **Internal name:** `artillery-projectile`
- **Type:** projectile
- **Source:** projectiles.lua

### blue-laser
- **Internal name:** `blue-laser`
- **Type:** projectile
- **Source:** projectiles.lua

### cluster-nuke-explosion
- **Internal name:** `cluster-nuke-explosion`
- **Type:** projectile
- **Source:** atomic-bomb.lua

### nuke-effects-nauvis
- **Internal name:** `nuke-effects-nauvis`
- **Type:** projectile
- **Source:** atomic-bomb.lua

### piercing-shotgun-pellet
- **Internal name:** `piercing-shotgun-pellet`
- **Type:** projectile
- **Source:** projectiles.lua

### smoke-fast
- **Internal name:** `smoke-fast`
- **Type:** projectile
- **Source:** projectiles.lua

### soft-fire-smoke
- **Internal name:** `soft-fire-smoke`
- **Type:** projectile
- **Source:** atomic-bomb.lua


## Proxy Container

### __base__/graphics/entity/electric-furnace/electric-furnace-propeller-1.png
- **Internal name:** `__base__/graphics/entity/electric-furnace/electric-furnace-propeller-1.png`
- **Type:** proxy-container
- **Source:** entities.lua


## Pump

### __base__/graphics/entity/pipe-to-ground/pipe-to-ground-left.png
- **Internal name:** `__base__/graphics/entity/pipe-to-ground/pipe-to-ground-left.png`
- **Type:** pump
- **Source:** entities.lua


## Push Back

### __base__/graphics/entity/beam/beam-tail.png
- **Internal name:** `__base__/graphics/entity/beam/beam-tail.png`
- **Type:** push-back
- **Source:** beams.lua


## Radar

### __base__/graphics/entity/stone-furnace/stone-furnace-fire.png
- **Internal name:** `__base__/graphics/entity/stone-furnace/stone-furnace-fire.png`
- **Type:** radar
- **Source:** entities.lua


## Rail Chain Signal

### __base__/graphics/entity/train-stop/train-stop-bottom.png
- **Internal name:** `__base__/graphics/entity/train-stop/train-stop-bottom.png`
- **Type:** rail-chain-signal
- **Source:** trains.lua


## Rail Remnants

### __base__/graphics/entity/gate/remnants/gate-remnants-var-1.png
- **Internal name:** `__base__/graphics/entity/gate/remnants/gate-remnants-var-1.png`
- **Type:** rail-remnants
- **Source:** remnants.lua

### __base__/graphics/entity/gate/remnants/gate-remnants-var-2.png
- **Internal name:** `__base__/graphics/entity/gate/remnants/gate-remnants-var-2.png`
- **Type:** rail-remnants
- **Source:** remnants.lua

### __base__/graphics/entity/gate/remnants/gate-remnants-var-3.png
- **Internal name:** `__base__/graphics/entity/gate/remnants/gate-remnants-var-3.png`
- **Type:** rail-remnants
- **Source:** remnants.lua

### __base__/graphics/entity/small-lamp/remnants/lamp-remnants.png
- **Internal name:** `__base__/graphics/entity/small-lamp/remnants/lamp-remnants.png`
- **Type:** rail-remnants
- **Source:** remnants.lua

### lamp-remnants
- **Internal name:** `lamp-remnants`
- **Type:** rail-remnants
- **Source:** remnants.lua

### small-electric-pole-remnants
- **Internal name:** `small-electric-pole-remnants`
- **Type:** rail-remnants
- **Source:** remnants.lua


## Rail Signal

### __base__/sound/fight/artillery-rotation-stop.ogg
- **Internal name:** `__base__/sound/fight/artillery-rotation-stop.ogg`
- **Type:** rail-signal
- **Source:** trains.lua


## Rail Support

### dummy-elevated-half-diagonal-rail
- **Internal name:** `dummy-elevated-half-diagonal-rail`
- **Type:** rail-support
- **Source:** trains.lua


## Reactor

### signal-G
- **Internal name:** `signal-G`
- **Type:** reactor
- **Source:** entities.lua


## Resource

### Copper ore
- **Internal name:** `copper-ore`
- **Type:** resource
- **Source:** resources.lua

### Iron ore
- **Internal name:** `iron-ore`
- **Type:** resource
- **Source:** resources.lua

### __base__/graphics/entity/
- **Internal name:** `__base__/graphics/entity/`
- **Type:** resource
- **Source:** resources.lua


## Rocket Silo

### signal-blue
- **Internal name:** `signal-blue`
- **Type:** rocket-silo
- **Source:** entities.lua


## Rocket Silo Rocket

### signal-white
- **Internal name:** `signal-white`
- **Type:** rocket-silo-rocket
- **Source:** entities.lua


## Rocket Silo Rocket Shadow

### signal-grey
- **Internal name:** `signal-grey`
- **Type:** rocket-silo-rocket-shadow
- **Source:** entities.lua


## Selector Combinator

### alarm-1
- **Internal name:** `alarm-1`
- **Type:** selector-combinator
- **Source:** circuit-network.lua


## Show Explosion On Chart

### __base__/graphics/entity/cliff-explosives/cliff-explosives-shadow.png
- **Internal name:** `__base__/graphics/entity/cliff-explosives/cliff-explosives-shadow.png`
- **Type:** show-explosion-on-chart
- **Source:** projectiles.lua


## Simple Entity

### parameter-
- **Internal name:** `parameter-`
- **Type:** simple-entity
- **Source:** entities.lua


## Simple Entity With Force

### __base__/graphics/entity/car/car-6.png
- **Internal name:** `__base__/graphics/entity/car/car-6.png`
- **Type:** simple-entity-with-force
- **Source:** entities.lua


## Simple Entity With Owner

### __base__/graphics/entity/car/car-mask-1.png
- **Internal name:** `__base__/graphics/entity/car/car-mask-1.png`
- **Type:** simple-entity-with-owner
- **Source:** entities.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-2.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-2.png`
- **Type:** simple-entity-with-owner
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-3.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-medium-3.png`
- **Type:** simple-entity-with-owner
- **Source:** crash-site.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-1.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-1.png`
- **Type:** simple-entity-with-owner
- **Source:** crash-site.lua

### crash-site-spaceship-wreck-medium-2
- **Internal name:** `crash-site-spaceship-wreck-medium-2`
- **Type:** simple-entity-with-owner
- **Source:** crash-site.lua

### crash-site-spaceship-wreck-medium-3
- **Internal name:** `crash-site-spaceship-wreck-medium-3`
- **Type:** simple-entity-with-owner
- **Source:** crash-site.lua

### crash-site-spaceship-wreck-small-1
- **Internal name:** `crash-site-spaceship-wreck-small-1`
- **Type:** simple-entity-with-owner
- **Source:** crash-site.lua


## Smoke With Trigger

### __base__/graphics/entity/assembling-machine-1/assembling-machine-1-shadow.png
- **Internal name:** `__base__/graphics/entity/assembling-machine-1/assembling-machine-1-shadow.png`
- **Type:** smoke-with-trigger
- **Source:** entities.lua

### __base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-3-ground.png
- **Internal name:** `__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-3-ground.png`
- **Type:** smoke-with-trigger
- **Source:** crash-site.lua

### __base__/graphics/entity/wall/wall-horizontal.png
- **Internal name:** `__base__/graphics/entity/wall/wall-horizontal.png`
- **Type:** smoke-with-trigger
- **Source:** entities.lua

### crash-site-spaceship-wreck-small-2
- **Internal name:** `crash-site-spaceship-wreck-small-2`
- **Type:** smoke-with-trigger
- **Source:** crash-site.lua


## Solar Panel

### __base__/graphics/entity/inserter/inserter-platform.png
- **Internal name:** `__base__/graphics/entity/inserter/inserter-platform.png`
- **Type:** solar-panel
- **Source:** entities.lua


## Speech Bubble

### __base__/sound/car-engine.ogg
- **Internal name:** `__base__/sound/car-engine.ogg`
- **Type:** speech-bubble
- **Source:** entities.lua


## Spider Leg

### __core__/graphics/empty.png
- **Internal name:** `__core__/graphics/empty.png`
- **Type:** spider-leg
- **Source:** entities.lua


## Spider Vehicle

### __base__/graphics/entity/car/car-turret-2.png
- **Internal name:** `__base__/graphics/entity/car/car-turret-2.png`
- **Type:** spider-vehicle
- **Source:** entities.lua


## Splitter

### __base__/graphics/entity/underground-belt/underground-belt-structure-front-patch.png
- **Internal name:** `__base__/graphics/entity/underground-belt/underground-belt-structure-front-patch.png`
- **Type:** splitter
- **Source:** transport-belts.lua

### __base__/sound/fast-underground-belt.ogg
- **Internal name:** `__base__/sound/fast-underground-belt.ogg`
- **Type:** splitter
- **Source:** transport-belts.lua


## Sticker

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-led-indicator-east.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-led-indicator-east.png`
- **Type:** sticker
- **Source:** fire.lua

### __base__/graphics/entity/wall/wall-corner-right-shadow.png
- **Internal name:** `__base__/graphics/entity/wall/wall-corner-right-shadow.png`
- **Type:** sticker
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-corner-right.png
- **Internal name:** `__base__/graphics/entity/wall/wall-corner-right.png`
- **Type:** sticker
- **Source:** entities.lua

### __base__/graphics/entity/wall/wall-horizontal-shadow.png
- **Internal name:** `__base__/graphics/entity/wall/wall-horizontal-shadow.png`
- **Type:** sticker
- **Source:** entities.lua

### acid-splash-worm-medium
- **Internal name:** `acid-splash-worm-medium`
- **Type:** sticker
- **Source:** enemy-projectiles.lua


## Storage Tank

### __base__/graphics/entity/pipe-to-ground/pipe-to-ground-down.png
- **Internal name:** `__base__/graphics/entity/pipe-to-ground/pipe-to-ground-down.png`
- **Type:** storage-tank
- **Source:** entities.lua


## Stream

### Big worm
- **Internal name:** `big-worm-turret`
- **Type:** stream
- **Source:** turrets.lua

### Gun turret
- **Internal name:** `gun-turret`
- **Type:** stream
- **Health:** 400
- **Source:** turrets.lua

### Water splash
- **Internal name:** `water-splash`
- **Type:** stream
- **Source:** enemy-projectiles.lua

### __base__/graphics/entity/acid-projectile/acid-projectile-head.png
- **Internal name:** `__base__/graphics/entity/acid-projectile/acid-projectile-head.png`
- **Type:** stream
- **Source:** enemy-projectiles.lua

### __base__/graphics/entity/acid-projectile/acid-projectile-shadow.png
- **Internal name:** `__base__/graphics/entity/acid-projectile/acid-projectile-shadow.png`
- **Type:** stream
- **Source:** enemy-projectiles.lua

### __base__/graphics/entity/acid-splash/acid-splash-1.png
- **Internal name:** `__base__/graphics/entity/acid-splash/acid-splash-1.png`
- **Type:** stream
- **Source:** enemy-projectiles.lua

### __base__/graphics/entity/acid-splash/acid-splash-2-shadow.png
- **Internal name:** `__base__/graphics/entity/acid-splash/acid-splash-2-shadow.png`
- **Type:** stream
- **Source:** enemy-projectiles.lua

### __base__/graphics/entity/acid-splash/acid-splash-2.png
- **Internal name:** `__base__/graphics/entity/acid-splash/acid-splash-2.png`
- **Type:** stream
- **Source:** enemy-projectiles.lua

### __base__/graphics/entity/flamethrower-fire-stream/flamethrower-fire-stream-spine.png
- **Internal name:** `__base__/graphics/entity/flamethrower-fire-stream/flamethrower-fire-stream-spine.png`
- **Type:** stream
- **Source:** fire.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-south.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-base-south.png`
- **Type:** stream
- **Source:** fire.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-gun-shadow.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-gun-shadow.png`
- **Type:** stream
- **Source:** fire.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-led-indicator-north.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-led-indicator-north.png`
- **Type:** stream
- **Source:** fire.lua

### __base__/graphics/entity/flamethrower-turret/flamethrower-turret-led-indicator-west.png
- **Internal name:** `__base__/graphics/entity/flamethrower-turret/flamethrower-turret-led-indicator-west.png`
- **Type:** stream
- **Source:** fire.lua

### __base__/graphics/entity/gun-turret/gun-turret-base-mask.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-base-mask.png`
- **Type:** stream
- **Source:** turrets.lua

### __base__/graphics/entity/gun-turret/gun-turret-raising-shadow.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-raising-shadow.png`
- **Type:** stream
- **Source:** turrets.lua

### __base__/graphics/entity/gun-turret/gun-turret-shooting-2.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-shooting-2.png`
- **Type:** stream
- **Source:** turrets.lua

### __base__/graphics/entity/laser-turret/laser-turret-reflection.png
- **Internal name:** `__base__/graphics/entity/laser-turret/laser-turret-reflection.png`
- **Type:** stream
- **Source:** turrets.lua

### __base__/sound/creatures/projectile-acid-burn-2.ogg
- **Internal name:** `__base__/sound/creatures/projectile-acid-burn-2.ogg`
- **Type:** stream
- **Source:** enemy-projectiles.lua

### __base__/sound/creatures/projectile-acid-burn-long-1.ogg
- **Internal name:** `__base__/sound/creatures/projectile-acid-burn-long-1.ogg`
- **Type:** stream
- **Source:** enemy-projectiles.lua

### __base__/sound/fight/projectile-acid-burn-loop.ogg
- **Internal name:** `__base__/sound/fight/projectile-acid-burn-loop.ogg`
- **Type:** stream
- **Source:** enemy-projectiles.lua


## Temporary Container

### Medium electric pole
- **Internal name:** `medium-electric-pole`
- **Type:** temporary-container
- **Health:** 100
- **Source:** entities.lua


## Tile Ghost

### __base__/graphics/entity/iron-chest/iron-chest.png
- **Internal name:** `__base__/graphics/entity/iron-chest/iron-chest.png`
- **Type:** tile-ghost
- **Source:** entities.lua


## Train Stop

### __base__/graphics/entity/fluid-wagon/minimap-representation/fluid-wagon-selected-minimap-representation.png
- **Internal name:** `__base__/graphics/entity/fluid-wagon/minimap-representation/fluid-wagon-selected-minimap-representation.png`
- **Type:** train-stop
- **Source:** trains.lua


## Transport Belt

### __base__/graphics/entity/express-transport-belt/express-transport-belt.png
- **Internal name:** `__base__/graphics/entity/express-transport-belt/express-transport-belt.png`
- **Type:** transport-belt
- **Source:** transport-belts.lua

### __base__/graphics/entity/transport-belt/transport-belt.png
- **Internal name:** `__base__/graphics/entity/transport-belt/transport-belt.png`
- **Type:** transport-belt
- **Source:** transport-belts.lua


## Tree

### __base__/graphics/entity/tree/
- **Internal name:** `__base__/graphics/entity/tree/`
- **Type:** tree
- **Source:** trees.lua

### tree-
- **Internal name:** `tree-`
- **Type:** tree
- **Health:** 20
- **Source:** trees.lua

### tree_09_red
- **Internal name:** `tree_09_red`
- **Type:** tree
- **Source:** trees.lua

### tree_dead_desert
- **Internal name:** `tree_dead_desert`
- **Type:** tree
- **Source:** trees.lua

### tree_dry
- **Internal name:** `tree_dry`
- **Type:** tree
- **Source:** trees.lua


## Trivial Smoke

### __base__/graphics/entity/smoke-fast/smoke-fast.png
- **Internal name:** `__base__/graphics/entity/smoke-fast/smoke-fast.png`
- **Type:** trivial-smoke
- **Source:** smoke-animations.lua

### nuclear-smoke
- **Internal name:** `nuclear-smoke`
- **Type:** trivial-smoke
- **Source:** atomic-bomb.lua

### smoke-building
- **Internal name:** `smoke-building`
- **Type:** trivial-smoke
- **Source:** smoke.lua

### smoke-explosion-lower-particle-small
- **Internal name:** `smoke-explosion-lower-particle-small`
- **Type:** trivial-smoke
- **Source:** smoke.lua

### smoke-explosion-particle
- **Internal name:** `smoke-explosion-particle`
- **Type:** trivial-smoke
- **Source:** smoke.lua

### smoke-explosion-particle-small
- **Internal name:** `smoke-explosion-particle-small`
- **Type:** trivial-smoke
- **Source:** smoke.lua

### smoke-explosion-particle-tiny
- **Internal name:** `smoke-explosion-particle-tiny`
- **Type:** trivial-smoke
- **Source:** smoke.lua

### smoke-train-stop
- **Internal name:** `smoke-train-stop`
- **Type:** trivial-smoke
- **Source:** smoke.lua

### tank-smoke
- **Internal name:** `tank-smoke`
- **Type:** trivial-smoke
- **Source:** smoke.lua

### train-smoke
- **Internal name:** `train-smoke`
- **Type:** trivial-smoke
- **Source:** smoke.lua

### turbine-smoke
- **Internal name:** `turbine-smoke`
- **Type:** trivial-smoke
- **Source:** smoke.lua


## Turret

### __base__/graphics/entity/gun-turret/gun-turret-raising-mask.png
- **Internal name:** `__base__/graphics/entity/gun-turret/gun-turret-raising-mask.png`
- **Type:** turret
- **Source:** turrets.lua

### __base__/graphics/entity/laser-turret/laser-turret-shooting.png
- **Internal name:** `__base__/graphics/entity/laser-turret/laser-turret-shooting.png`
- **Type:** turret
- **Source:** turrets.lua

### shell-particle
- **Internal name:** `shell-particle`
- **Type:** turret
- **Source:** turrets.lua


## Underground

### __base__/graphics/entity/boiler/boiler-W-idle.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-W-idle.png`
- **Type:** underground
- **Source:** entities.lua


## Underground Belt

### Underground belt
- **Internal name:** `underground-belt`
- **Type:** underground-belt
- **Description:** Used to allow a belt to cross entities or impassable terrain.
- **Health:** 150
- **Source:** transport-belts.lua

### __base__/graphics/entity/underground-belt/underground-belt-structure.png
- **Internal name:** `__base__/graphics/entity/underground-belt/underground-belt-structure.png`
- **Type:** underground-belt
- **Source:** transport-belts.lua


## Unit

### Big biter corpse
- **Internal name:** `big-biter-corpse`
- **Type:** unit
- **Source:** enemies.lua

### Big spitter corpse
- **Internal name:** `big-spitter-corpse`
- **Type:** unit
- **Source:** enemies.lua

### Medium biter
- **Internal name:** `medium-biter`
- **Type:** unit
- **Source:** enemies.lua

### Spitter spawner corpse
- **Internal name:** `spitter-spawner-corpse`
- **Type:** unit
- **Source:** enemies.lua

### acid-stream-spitter-big
- **Internal name:** `acid-stream-spitter-big`
- **Type:** unit
- **Source:** enemies.lua

### dummy-spider-unit
- **Internal name:** `dummy-spider-unit`
- **Type:** unit
- **Source:** enemies.lua


## Unit Spawner

### Small spitter
- **Internal name:** `small-spitter`
- **Type:** unit-spawner
- **Source:** enemies.lua


## Valve

### __base__/graphics/entity/pipe-to-ground/disabled-visualization.png
- **Internal name:** `__base__/graphics/entity/pipe-to-ground/disabled-visualization.png`
- **Type:** valve
- **Source:** entities.lua


## Virtual

### Artillery wagon
- **Internal name:** `artillery-wagon`
- **Type:** virtual
- **Health:** 600
- **Source:** trains.lua

### Boiler
- **Internal name:** `boiler`
- **Type:** virtual
- **Description:** Burns fuel to turn water into steam.
- **Health:** 200
- **Source:** entities.lua

### Offshore pump
- **Internal name:** `offshore-pump`
- **Type:** virtual
- **Description:** Pumps fluid from a body of water.
- **Health:** 150
- **Source:** entities.lua

### Pipe to ground
- **Internal name:** `pipe-to-ground`
- **Type:** virtual
- **Health:** 150
- **Source:** entities.lua

### Train stop
- **Internal name:** `train-stop`
- **Type:** virtual
- **Description:** Destinations for automated trains.
- **Health:** 250
- **Source:** trains.lua

### __base__/graphics/entity/artillery-wagon/minimap-representation/artillery-wagon-minimap-representation.png
- **Internal name:** `__base__/graphics/entity/artillery-wagon/minimap-representation/artillery-wagon-minimap-representation.png`
- **Type:** virtual
- **Source:** trains.lua

### __base__/graphics/entity/artillery-wagon/minimap-representation/artillery-wagon-selected-minimap-representation.png
- **Internal name:** `__base__/graphics/entity/artillery-wagon/minimap-representation/artillery-wagon-selected-minimap-representation.png`
- **Type:** virtual
- **Source:** trains.lua

### __base__/graphics/entity/artillery-wagon/reflection/artillery-wagon-reflection.png
- **Internal name:** `__base__/graphics/entity/artillery-wagon/reflection/artillery-wagon-reflection.png`
- **Type:** virtual
- **Source:** trains.lua

### __base__/graphics/entity/boiler/boiler-E-fire.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-E-fire.png`
- **Type:** virtual
- **Source:** entities.lua

### __base__/graphics/entity/boiler/boiler-E-idle.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-E-idle.png`
- **Type:** virtual
- **Source:** entities.lua

### __base__/graphics/entity/boiler/boiler-E-light.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-E-light.png`
- **Type:** virtual
- **Source:** entities.lua

### __base__/graphics/entity/boiler/boiler-E-patch.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-E-patch.png`
- **Type:** virtual
- **Source:** entities.lua

### __base__/graphics/entity/boiler/boiler-E-shadow.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-E-shadow.png`
- **Type:** virtual
- **Source:** entities.lua

### __base__/graphics/entity/boiler/boiler-N-fire.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-N-fire.png`
- **Type:** virtual
- **Source:** entities.lua

### __base__/graphics/entity/boiler/boiler-N-idle.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-N-idle.png`
- **Type:** virtual
- **Source:** entities.lua

### __base__/graphics/entity/boiler/boiler-N-light.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-N-light.png`
- **Type:** virtual
- **Source:** entities.lua

### __base__/graphics/entity/boiler/boiler-N-shadow.png
- **Internal name:** `__base__/graphics/entity/boiler/boiler-N-shadow.png`
- **Type:** virtual
- **Source:** entities.lua

### __base__/graphics/entity/fast-inserter/fast-inserter-hand-open.png
- **Internal name:** `__base__/graphics/entity/fast-inserter/fast-inserter-hand-open.png`
- **Type:** virtual
- **Source:** entities.lua

### __base__/graphics/entity/fish/fish-2.png
- **Internal name:** `__base__/graphics/entity/fish/fish-2.png`
- **Type:** virtual
- **Source:** entities.lua

### __base__/graphics/entity/lab/lab-shadow.png
- **Internal name:** `__base__/graphics/entity/lab/lab-shadow.png`
- **Type:** virtual
- **Source:** entities.lua

### __base__/graphics/entity/pipe-to-ground/pipe-to-ground-up.png
- **Internal name:** `__base__/graphics/entity/pipe-to-ground/pipe-to-ground-up.png`
- **Type:** virtual
- **Source:** entities.lua

### __base__/graphics/entity/train-stop/train-stop-ground.png
- **Internal name:** `__base__/graphics/entity/train-stop/train-stop-ground.png`
- **Type:** virtual
- **Source:** trains.lua

### __base__/graphics/entity/train-stop/train-stop-north-light-1.png
- **Internal name:** `__base__/graphics/entity/train-stop/train-stop-north-light-1.png`
- **Type:** virtual
- **Source:** trains.lua

### __base__/graphics/entity/train-stop/train-stop-shadow.png
- **Internal name:** `__base__/graphics/entity/train-stop/train-stop-shadow.png`
- **Type:** virtual
- **Source:** trains.lua

### __base__/graphics/entity/train-stop/train-stop-top-mask.png
- **Internal name:** `__base__/graphics/entity/train-stop/train-stop-top-mask.png`
- **Type:** virtual
- **Source:** trains.lua

### __base__/graphics/entity/train-stop/train-stop-top.png
- **Internal name:** `__base__/graphics/entity/train-stop/train-stop-top.png`
- **Type:** virtual
- **Source:** trains.lua

### __base__/sound/boiler.ogg
- **Internal name:** `__base__/sound/boiler.ogg`
- **Type:** virtual
- **Source:** entities.lua

### __base__/sound/fight/artillery-rotation-loop.ogg
- **Internal name:** `__base__/sound/fight/artillery-rotation-loop.ogg`
- **Type:** virtual
- **Source:** trains.lua

### __core__/graphics/arrows/gui-arrow-circle.png
- **Internal name:** `__core__/graphics/arrows/gui-arrow-circle.png`
- **Type:** virtual
- **Source:** entities.lua

### __core__/graphics/arrows/gui-arrow-medium.png
- **Internal name:** `__core__/graphics/arrows/gui-arrow-medium.png`
- **Type:** virtual
- **Source:** entities.lua

### orange-arrow-with-circle
- **Internal name:** `orange-arrow-with-circle`
- **Type:** virtual
- **Source:** entities.lua


## Void

### Character corpse
- **Internal name:** `character-corpse`
- **Type:** void
- **Source:** entities.lua

### __base__/graphics/entity/car/car-turret-shadow.png
- **Internal name:** `__base__/graphics/entity/car/car-turret-shadow.png`
- **Type:** void
- **Source:** entities.lua


## Wall

### __base__/graphics/entity/small-electric-pole/small-electric-pole.png
- **Internal name:** `__base__/graphics/entity/small-electric-pole/small-electric-pole.png`
- **Type:** wall
- **Source:** entities.lua

---

## entities

# Factorio Entities

This document lists entities (buildings, machines, etc.) available in Factorio.


## Ammo Turret

### Gun turret
- **Internal name:** `gun-turret`
- **Health:** 400
- **Source file:** turrets.lua


## Electric Turret

### Laser turret
- **Internal name:** `laser-turret`
- **Health:** 1000
- **Source file:** turrets.lua


## Mining Drill

### Burner mining drill
- **Internal name:** `burner-mining-drill`
- **Health:** 150
- **Source file:** mining-drill.lua

### Electric mining drill
- **Internal name:** `electric-mining-drill`
- **Health:** 300
- **Source file:** mining-drill.lua

### Pumpjack
- **Internal name:** `pumpjack`
- **Health:** 200
- **Source file:** mining-drill.lua


## Turret

### Behemoth worm
- **Internal name:** `behemoth-worm-turret`
- **Health:** 3000
- **Source file:** turrets.lua

### Big worm
- **Internal name:** `big-worm-turret`
- **Health:** 1500
- **Source file:** turrets.lua

### Medium worm
- **Internal name:** `medium-worm-turret`
- **Health:** 500
- **Source file:** turrets.lua

### Small worm
- **Internal name:** `small-worm-turret`
- **Health:** 200
- **Source file:** turrets.lua

---

## game-mechanics

# Factorio Game Mechanics

This document explains various game mechanics and concepts.

## Damage Types

- **Physical** (`physical`)
- **Impact** (`impact`)
- **Fire** (`fire`)
- **Laser** (`laser`)
- **Poison** (`poison`)
- **Explosion** (`explosion`)
- **Acid** (`acid`)
- **Electric** (`electric`)

## Modifiers and Bonuses

- **bulk-inserter-capacity-bonus:** Bulk inserter capacity: +__1__
- **inserter-stack-size-bonus:** Non-bulk inserter capacity: +__1__
- **laboratory-speed:** Lab research speed: +__1__
- **laboratory-productivity:** Lab research productivity: +__1__
- **maximum-following-robots-count:** Maximum following robots: +__1__
- **worker-robot-speed:** Worker robot speed: +__1__
- **worker-robot-storage:** Worker robot capacity: +__1__
- **character-logistic-trash-slots:** Character logistic trash slots: +__1__
- **character-mining-speed:** Character mining speed: +__1__
- **mining-drill-productivity-bonus:** Mining productivity: +__1__
- **beacon-distribution:** Beacon transmission bonus: +__1__
- **train-braking-force-bonus:** Train braking force: +__1__
- **rocket-damage-bonus:** Rocket damage: +__1__
- **rocket-shooting-speed-bonus:** Rocket shooting speed: +__1__
- **bullet-damage-bonus:** Bullet damage: +__1__
- **bullet-shooting-speed-bonus:** Bullet shooting speed: +__1__
- **shotgun-shell-damage-bonus:** Shotgun shell damage: +__1__
- **shotgun-shell-shooting-speed-bonus:** Shotgun shell shooting speed: +__1__
- **laser-damage-bonus:** Laser damage: +__1__
- **laser-shooting-speed-bonus:** Laser shooting speed: +__1__
- **electric-damage-bonus:** Electric damage: +__1__
- **gun-turret-attack-bonus:** Gun turret damage: +__1__
- **flamethrower-turret-attack-bonus:** Flamethrower turret damage: +__1__
- **flamethrower-damage-bonus:** Fire damage: +__1__
- **fluid-damage-modifier:** Fluid damage modifier
- **beam-damage-bonus:** Beam damage: +__1__
- **grenade-damage-bonus:** Grenade damage: +__1__
- **cannon-shell-damage-bonus:** Cannon shell damage: +__1__
- **cannon-shell-shooting-speed-bonus:** Cannon shell shooting speed: +__1__
- **artillery-range:** Artillery shell range: +__1__
- **artillery-shell-shooting-speed-bonus:** Artillery shell shooting speed: +__1__
- **artillery-shell-damage-bonus:** Artillery shell damage: +__1__
- **max-failed-attempts-per-tick-per-construction-queue:** Construction manager speed lower threshold: +__1__
- **max-successful-attempts-per-tick-per-construction-queue:** Construction manager speed upper threshold: +__1__
- **character-inventory-slots-bonus:** Character inventory slots: +__1__
- **character-health-bonus:** Character health: +__1__
- **worker-robot-battery:** Worker robot battery: +__1__
- **landmine-damage-bonus:** Land mine damage: +__1__
- **character-logistic-requests:** Character logistic requests
- **auto-character-logistic-trash-slots:** Character auto trash filters
- **character-build-distance:** Character build distance: +__1__
- **character-reach-distance:** Character reach distance: +__1__
- **character-resource-reach-distance:** Character resource reach distance: +__1__
- **character-item-pickup-distance:** Character item pickup distance: +__1__
- **character-item-drop-distance:** Character item drop distance: +__1__
- **character-loot-pickup-distance:** Character loot pickup distance: +__1__
- **character-running-speed:** Character walking speed: +__1__
- **character-crafting-speed:** Character crafting speed: +__1__
- **deconstruction-time-to-live:** Deconstruction lifetime: +__1__
- **follower-robot-lifetime:** Follower robot lifetime: +__1__
- **zoom-to-world-blueprint-enabled:** Zoom-to-world blueprint
- **zoom-to-world-deconstruction-planner-enabled:** Zoom-to-world deconstruction planner
- **zoom-to-world-upgrade-planner-enabled:** Zoom-to-world upgrade planner
- **zoom-to-world-enabled:** Zoom-to-world
- **zoom-to-world-ghost-building-enabled:** Zoom-to-world ghost building
- **zoom-to-world-selection-tool-enabled:** Zoom-to-world selection tool
- **rail-planner-allow-elevated-rails:** Rail planner will consider usage of elevated rails to avoid obstacles
- **create-ghost-on-entity-death:** Create ghosts when entities are destroyed

---

## game-progression-guide

# Factorio Game Progression Guide

This guide outlines the typical progression path through Factorio.

## Early Game (Manual Crafting)

### Starting Resources
- **Wood** - Obtained from trees
- **Stone** - Mined from stone patches
- **Coal** - Mined from coal patches
- **Iron ore** - Mined from iron ore patches
- **Copper ore** - Mined from copper ore patches

### First Tools and Machines
1. **Burner mining drill** - First automated mining
2. **Stone furnace** - Smelt ores into plates
3. **Burner inserter** - Move items between machines
4. **Wooden chest** - Store items

## Automation Phase

### Key Technologies
- **Automation** - Unlocks assembling machines
- **Logistics** - Better belts and inserters
- **Electronics** - Circuit production

### Production Chains
1. **Iron production:** Iron ore → Furnace → Iron plate
2. **Copper production:** Copper ore → Furnace → Copper plate
3. **Circuit production:** Copper plate + Iron plate → Electronic circuit

## Mid Game

### Power Generation
1. **Steam power:** Boiler + Steam engine
2. **Solar power:** Solar panels + Accumulators
3. **Nuclear power:** Nuclear reactor + Heat exchangers

### Advanced Production
- **Oil processing** - Crude oil → Petroleum/Heavy oil/Light oil
- **Advanced circuits** - Electronic circuits + Plastic + Copper cable
- **Processing units** - Advanced circuits + Electronic circuits + Sulfuric acid

## Late Game

### Rocket Launch
1. Build **Rocket silo**
2. Research **Rocket technology**
3. Craft **Rocket parts**
4. Launch **Satellite** for space science

### Infinite Research
After launching your first rocket, you unlock infinite research technologies:
- Mining productivity
- Worker robot speed
- Artillery range
- And more...

---

## index

# Factorio Game Content - Complete Reference

This directory contains a comprehensive extraction of Factorio game content, organized to help understand the player experience and game mechanics.

## 📚 Core Game Content

### [Items](items.md)
Complete list of all 216 items in Factorio including:
- Resources (wood, stone, ores)
- Intermediate products (gears, circuits, plates)
- Tools and equipment
- Ammunition and weapons
- Modules and upgrades

### [Recipes - Detailed](recipes-detailed.md)
All 193 crafting recipes with:
- Complete ingredient lists
- Crafting times
- Machine categories required
- Results and quantities

### [Technologies - Detailed](technologies-detailed.md)
The complete research tree with 193 technologies including:
- Prerequisites for each technology
- Science pack requirements
- Research times and costs
- Unlocked recipes and capabilities

### [Entities - Complete](entities-complete.md)
All 1,395 placeable entities including:
- Production buildings (furnaces, assemblers, refineries)
- Power generation (boilers, engines, solar panels)
- Logistics (belts, inserters, chests, trains)
- Defense structures (turrets, walls)
- Special buildings (labs, rocket silo)

## 🎮 Gameplay Guides

### [Tips and Tricks - Complete](tips-and-tricks-complete.md)
64 in-game tips organized by category covering:
- Basic mechanics
- Automation strategies
- Combat tips
- Advanced techniques

### [Game Progression Guide](game-progression-guide.md)
Step-by-step progression path:
- Early game manual crafting
- Setting up automation
- Power generation options
- Oil processing and advanced materials
- Rocket launch requirements

### [Controls Reference](controls-reference.md)
Complete list of game controls organized by:
- Movement controls
- Building and mining
- Inventory management
- Vehicle operation
- Map navigation

### [Game Mechanics](game-mechanics.md)
Detailed explanations of:
- Damage types and resistances
- Equipment functions
- Technology bonuses
- Logistics concepts

## 🔍 Quick Reference Sections

### Basic Resources
- **Wood** - From trees, used for early game items
- **Stone** - Mined resource, used for furnaces and bricks
- **Coal** - Fuel and chemical ingredient
- **Iron ore** → **Iron plate** - Most common material
- **Copper ore** → **Copper plate** - Electronics and wiring
- **Crude oil** - Refined into petroleum, light oil, heavy oil

### Key Production Chains
1. **Basic Circuits**: Iron plate + Copper cable → Electronic circuit
2. **Advanced Circuits**: Electronic circuit + Plastic + Copper cable → Advanced circuit
3. **Processing Units**: Advanced circuit + Electronic circuit + Sulfuric acid → Processing unit
4. **Science Packs**: Various recipes unlocked through research

### Machine Categories
- **Crafting**: Hand crafting and assembling machines
- **Smelting**: Furnaces (stone, steel, electric)
- **Oil-processing**: Oil refineries
- **Chemistry**: Chemical plants
- **Centrifuging**: Centrifuges for uranium processing

### Power Generation Tiers
1. **Burner Phase**: Coal-powered drills and inserters
2. **Steam Power**: Boiler → Steam engine
3. **Solar Power**: Solar panels + Accumulators
4. **Nuclear Power**: Nuclear reactor → Heat exchanger → Steam turbine

## 📊 Statistics

- **Total Items**: 216
- **Total Recipes**: 193
- **Total Technologies**: 193
- **Total Entities**: 1,395
- **Total Tips**: 64

## 🚀 Using This Reference

This reference is designed to help understand:
1. What can be built in the game
2. How to craft items and what's required
3. Research progression and unlocks
4. Building functions and capabilities
5. Optimal progression strategies

Each file uses consistent formatting:
- **Display names** for user-friendly reading
- **Internal names** in backticks for mod/command reference
- **Detailed properties** for each entry
- **Cross-references** between related content

This extraction represents the complete Factorio base game content as of the latest version.

---

## items

# Factorio Items

This document lists all items available in Factorio with their properties.


## Ammo

### Firearm magazine
- **Internal name:** `firearm-magazine`
- **Type:** ammo
- **Stack size:** 100
- **Weight:** 10

### Piercing rounds magazine
- **Internal name:** `piercing-rounds-magazine`
- **Type:** ammo
- **Stack size:** 100
- **Weight:** 20

### Uranium rounds magazine
- **Internal name:** `uranium-rounds-magazine`
- **Type:** ammo
- **Stack size:** 100
- **Weight:** 40

### Shotgun shells
- **Internal name:** `shotgun-shell`
- **Type:** ammo
- **Stack size:** 100
- **Weight:** 10

### Piercing shotgun shells
- **Internal name:** `piercing-shotgun-shell`
- **Type:** ammo
- **Stack size:** 100
- **Weight:** 20

### Cannon shell
- **Internal name:** `cannon-shell`
- **Type:** ammo
- **Stack size:** 100
- **Weight:** 20

### Explosive cannon shell
- **Internal name:** `explosive-cannon-shell`
- **Type:** ammo
- **Stack size:** 100
- **Weight:** 20

### Uranium cannon shell
- **Internal name:** `uranium-cannon-shell`
- **Type:** ammo
- **Stack size:** 100
- **Weight:** 40

### Explosive uranium cannon shell
- **Internal name:** `explosive-uranium-cannon-shell`
- **Type:** ammo
- **Stack size:** 100
- **Weight:** 40

### Artillery shell
- **Internal name:** `artillery-shell`
- **Type:** ammo
- **Stack size:** 1
- **Weight:** 100

### Rocket
- **Internal name:** `rocket`
- **Type:** ammo
- **Stack size:** 100
- **Weight:** 40

### Explosive rocket
- **Internal name:** `explosive-rocket`
- **Type:** ammo
- **Stack size:** 100
- **Weight:** 40

### Atomic bomb
- **Internal name:** `atomic-bomb`
- **Type:** ammo
- **Stack size:** 10
- **Weight:** 1.5

### Flamethrower ammo
- **Internal name:** `flamethrower-ammo`
- **Type:** ammo
- **Stack size:** 100
- **Weight:** 10


## Armor

### Light armor
- **Internal name:** `light-armor`
- **Type:** armor
- **Stack size:** 1

### Heavy armor
- **Internal name:** `heavy-armor`
- **Type:** armor
- **Stack size:** 1

### Modular armor
- **Internal name:** `modular-armor`
- **Type:** armor
- **Stack size:** 1

### Power armor
- **Internal name:** `power-armor`
- **Type:** armor
- **Stack size:** 1

### Power armor MK2
- **Internal name:** `power-armor-mk2`
- **Type:** armor
- **Stack size:** 1
- **Weight:** 1


## Belt

### transport-belt
- **Internal name:** `transport-belt`
- **Type:** item
- **Stack size:** 100
- **Places:** transport-belt

### fast-transport-belt
- **Internal name:** `fast-transport-belt`
- **Type:** item
- **Stack size:** 100
- **Places:** fast-transport-belt

### express-transport-belt
- **Internal name:** `express-transport-belt`
- **Type:** item
- **Stack size:** 100
- **Places:** express-transport-belt
- **Weight:** 10

### underground-belt
- **Internal name:** `underground-belt`
- **Type:** item
- **Stack size:** 50
- **Places:** underground-belt

### fast-underground-belt
- **Internal name:** `fast-underground-belt`
- **Type:** item
- **Stack size:** 50
- **Places:** fast-underground-belt

### express-underground-belt
- **Internal name:** `express-underground-belt`
- **Type:** item
- **Stack size:** 50
- **Places:** express-underground-belt
- **Weight:** 20

### splitter
- **Internal name:** `splitter`
- **Type:** item
- **Stack size:** 50
- **Places:** splitter
- **Weight:** 20

### fast-splitter
- **Internal name:** `fast-splitter`
- **Type:** item
- **Stack size:** 50
- **Places:** fast-splitter

### express-splitter
- **Internal name:** `express-splitter`
- **Type:** item
- **Stack size:** 50
- **Places:** express-splitter
- **Weight:** 20

### loader
- **Internal name:** `loader`
- **Type:** item
- **Stack size:** 50
- **Places:** loader

### fast-loader
- **Internal name:** `fast-loader`
- **Type:** item
- **Stack size:** 50
- **Places:** fast-loader

### express-loader
- **Internal name:** `express-loader`
- **Type:** item
- **Stack size:** 50
- **Places:** express-loader


## Capsule

### Grenade
- **Internal name:** `grenade`
- **Type:** capsule
- **Stack size:** 100
- **Weight:** 10

### Cluster grenade
- **Internal name:** `cluster-grenade`
- **Type:** capsule
- **Stack size:** 100
- **Weight:** 40

### Poison capsule
- **Internal name:** `poison-capsule`
- **Type:** capsule
- **Stack size:** 100
- **Weight:** 10

### Slowdown capsule
- **Internal name:** `slowdown-capsule`
- **Type:** capsule
- **Description:** Reduces the movement speed of affected enemies.
- **Stack size:** 100
- **Weight:** 10

### Defender capsule
- **Internal name:** `defender-capsule`
- **Type:** capsule
- **Stack size:** 100
- **Weight:** 10

### Distractor capsule
- **Internal name:** `distractor-capsule`
- **Type:** capsule
- **Stack size:** 100
- **Weight:** 20

### Destroyer capsule
- **Internal name:** `destroyer-capsule`
- **Type:** capsule
- **Stack size:** 100
- **Weight:** 40


## Circuit Network

### small-lamp
- **Internal name:** `small-lamp`
- **Type:** item
- **Stack size:** 50
- **Places:** small-lamp

### arithmetic-combinator
- **Internal name:** `arithmetic-combinator`
- **Type:** item
- **Stack size:** 50
- **Places:** arithmetic-combinator

### decider-combinator
- **Internal name:** `decider-combinator`
- **Type:** item
- **Stack size:** 50
- **Places:** decider-combinator

### selector-combinator
- **Internal name:** `selector-combinator`
- **Type:** item
- **Stack size:** 50
- **Places:** selector-combinator
- **Weight:** 20

### constant-combinator
- **Internal name:** `constant-combinator`
- **Type:** item
- **Stack size:** 50
- **Places:** constant-combinator

### power-switch
- **Internal name:** `power-switch`
- **Type:** item
- **Stack size:** 10
- **Places:** power-switch

### programmable-speaker
- **Internal name:** `programmable-speaker`
- **Type:** item
- **Stack size:** 10
- **Places:** programmable-speaker

### Display panel
- **Internal name:** `display-panel`
- **Type:** item
- **Stack size:** 10
- **Places:** display-panel


## Defensive Structure

### stone-wall
- **Internal name:** `stone-wall`
- **Type:** item
- **Stack size:** 100
- **Places:** stone-wall

### gate
- **Internal name:** `gate`
- **Type:** item
- **Stack size:** 50
- **Places:** gate

### radar
- **Internal name:** `radar`
- **Type:** item
- **Stack size:** 50
- **Places:** radar

### land-mine
- **Internal name:** `land-mine`
- **Type:** item
- **Description:** Explodes when enemies are nearby, damaging and stunning them.
- **Stack size:** 100
- **Places:** land-mine


## Energy

### boiler
- **Internal name:** `boiler`
- **Type:** item
- **Stack size:** 50
- **Places:** boiler

### steam-engine
- **Internal name:** `steam-engine`
- **Type:** item
- **Stack size:** 10
- **Places:** steam-engine

### Solar panel
- **Internal name:** `solar-panel`
- **Type:** item
- **Stack size:** 50
- **Places:** solar-panel

### accumulator
- **Internal name:** `accumulator`
- **Type:** item
- **Stack size:** 50
- **Places:** accumulator

### nuclear-reactor
- **Internal name:** `nuclear-reactor`
- **Type:** item
- **Stack size:** 10
- **Places:** nuclear-reactor
- **Weight:** 1

### heat-pipe
- **Internal name:** `heat-pipe`
- **Type:** item
- **Stack size:** 50
- **Places:** heat-pipe
- **Weight:** 20

### heat-exchanger
- **Internal name:** `heat-exchanger`
- **Type:** item
- **Stack size:** 50
- **Places:** heat-exchanger
- **Weight:** 40

### steam-turbine
- **Internal name:** `steam-turbine`
- **Type:** item
- **Stack size:** 10
- **Places:** steam-turbine


## Energy Pipe Distribution

### small-electric-pole
- **Internal name:** `small-electric-pole`
- **Type:** item
- **Stack size:** 50
- **Places:** small-electric-pole

### medium-electric-pole
- **Internal name:** `medium-electric-pole`
- **Type:** item
- **Stack size:** 50
- **Places:** medium-electric-pole

### big-electric-pole
- **Internal name:** `big-electric-pole`
- **Type:** item
- **Stack size:** 50
- **Places:** big-electric-pole

### substation
- **Internal name:** `substation`
- **Type:** item
- **Stack size:** 50
- **Places:** substation

### pipe
- **Internal name:** `pipe`
- **Type:** item
- **Stack size:** 100
- **Places:** pipe
- **Weight:** 5

### pipe-to-ground
- **Internal name:** `pipe-to-ground`
- **Type:** item
- **Stack size:** 50
- **Places:** pipe-to-ground

### pump
- **Internal name:** `pump`
- **Type:** item
- **Stack size:** 50
- **Places:** pump


## Equipment

### solar-panel-equipment
- **Internal name:** `solar-panel-equipment`
- **Type:** item
- **Description:** Provides power for equipment modules.
- **Stack size:** 20

### fission-reactor-equipment
- **Internal name:** `fission-reactor-equipment`
- **Type:** item
- **Description:** Provides power for equipment modules.
- **Stack size:** 20
- **Weight:** 0.25

### battery-equipment
- **Internal name:** `battery-equipment`
- **Type:** item
- **Stack size:** 20

### battery-mk2-equipment
- **Internal name:** `battery-mk2-equipment`
- **Type:** item
- **Stack size:** 20
- **Weight:** 100


## Extraction Machine

### burner-mining-drill
- **Internal name:** `burner-mining-drill`
- **Type:** item
- **Stack size:** 50
- **Places:** burner-mining-drill

### electric-mining-drill
- **Internal name:** `electric-mining-drill`
- **Type:** item
- **Stack size:** 50
- **Places:** electric-mining-drill

### offshore-pump
- **Internal name:** `offshore-pump`
- **Type:** item
- **Stack size:** 20
- **Places:** offshore-pump

### pumpjack
- **Internal name:** `pumpjack`
- **Type:** item
- **Stack size:** 20
- **Places:** pumpjack


## Gun

### Pistol
- **Internal name:** `pistol`
- **Type:** gun
- **Stack size:** 5

### Submachine gun
- **Internal name:** `submachine-gun`
- **Type:** gun
- **Stack size:** 5

### Vehicle machine gun
- **Internal name:** `tank-machine-gun`
- **Type:** gun
- **Stack size:** 1

### Vehicle machine gun
- **Internal name:** `vehicle-machine-gun`
- **Type:** gun
- **Stack size:** 1

### Vehicle flamethrower
- **Internal name:** `tank-flamethrower`
- **Type:** gun
- **Stack size:** 1

### Shotgun
- **Internal name:** `shotgun`
- **Type:** gun
- **Stack size:** 5

### Combat shotgun
- **Internal name:** `combat-shotgun`
- **Type:** gun
- **Stack size:** 5

### Rocket launcher
- **Internal name:** `rocket-launcher`
- **Type:** gun
- **Stack size:** 5

### Flamethrower
- **Internal name:** `flamethrower`
- **Type:** gun
- **Stack size:** 5

### Artillery cannon
- **Internal name:** `artillery-wagon-cannon`
- **Type:** gun
- **Stack size:** 1

### spidertron-rocket-launcher-1
- **Internal name:** `spidertron-rocket-launcher-1`
- **Type:** gun
- **Stack size:** 1

### spidertron-rocket-launcher-2
- **Internal name:** `spidertron-rocket-launcher-2`
- **Type:** gun
- **Stack size:** 1

### spidertron-rocket-launcher-3
- **Internal name:** `spidertron-rocket-launcher-3`
- **Type:** gun
- **Stack size:** 1

### spidertron-rocket-launcher-4
- **Internal name:** `spidertron-rocket-launcher-4`
- **Type:** gun
- **Stack size:** 1

### Tank cannon
- **Internal name:** `tank-cannon`
- **Type:** gun
- **Stack size:** 1


## Inserter

### burner-inserter
- **Internal name:** `burner-inserter`
- **Type:** item
- **Stack size:** 50
- **Places:** burner-inserter

### inserter
- **Internal name:** `inserter`
- **Type:** item
- **Stack size:** 50
- **Places:** inserter

### long-handed-inserter
- **Internal name:** `long-handed-inserter`
- **Type:** item
- **Stack size:** 50
- **Places:** long-handed-inserter

### fast-inserter
- **Internal name:** `fast-inserter`
- **Type:** item
- **Stack size:** 50
- **Places:** fast-inserter

### bulk-inserter
- **Internal name:** `bulk-inserter`
- **Type:** item
- **Stack size:** 50
- **Places:** bulk-inserter
- **Weight:** 20


## Intermediate Product

### Iron gear wheel
- **Internal name:** `iron-gear-wheel`
- **Type:** item
- **Stack size:** 100

### Iron stick
- **Internal name:** `iron-stick`
- **Type:** item
- **Stack size:** 100
- **Weight:** 0.5

### Copper cable
- **Internal name:** `copper-cable`
- **Type:** item
- **Stack size:** 200
- **Weight:** 0.25

### Barrel
- **Internal name:** `barrel`
- **Type:** item
- **Stack size:** 10
- **Weight:** 1

### Electronic circuit
- **Internal name:** `electronic-circuit`
- **Type:** item
- **Stack size:** 200

### Advanced circuit
- **Internal name:** `advanced-circuit`
- **Type:** item
- **Stack size:** 200

### Processing unit
- **Internal name:** `processing-unit`
- **Type:** item
- **Stack size:** 100

### Engine unit
- **Internal name:** `engine-unit`
- **Type:** item
- **Stack size:** 50
- **Weight:** 2.5

### Electric engine unit
- **Internal name:** `electric-engine-unit`
- **Type:** item
- **Stack size:** 50

### Flying robot frame
- **Internal name:** `flying-robot-frame`
- **Type:** item
- **Stack size:** 50

### Low density structure
- **Internal name:** `low-density-structure`
- **Type:** item
- **Stack size:** 50
- **Weight:** 5

### Rocket fuel
- **Internal name:** `rocket-fuel`
- **Type:** item
- **Stack size:** 20
- **Fuel value:** 100MJ
- **Fuel category:** chemical
- **Weight:** 10

### Rocket part
- **Internal name:** `rocket-part`
- **Type:** item
- **Stack size:** 5


## Logistic Network

### logistic-robot
- **Internal name:** `logistic-robot`
- **Type:** item
- **Stack size:** 50
- **Places:** logistic-robot

### construction-robot
- **Internal name:** `construction-robot`
- **Type:** item
- **Stack size:** 50
- **Places:** construction-robot

### active-provider-chest
- **Internal name:** `active-provider-chest`
- **Type:** item
- **Stack size:** 50
- **Places:** active-provider-chest

### passive-provider-chest
- **Internal name:** `passive-provider-chest`
- **Type:** item
- **Stack size:** 50
- **Places:** passive-provider-chest

### storage-chest
- **Internal name:** `storage-chest`
- **Type:** item
- **Stack size:** 50
- **Places:** storage-chest

### buffer-chest
- **Internal name:** `buffer-chest`
- **Type:** item
- **Stack size:** 50
- **Places:** buffer-chest

### requester-chest
- **Internal name:** `requester-chest`
- **Type:** item
- **Stack size:** 50
- **Places:** requester-chest

### roboport
- **Internal name:** `roboport`
- **Type:** item
- **Stack size:** 10
- **Places:** roboport
- **Weight:** 100


## Military Equipment

### energy-shield-equipment
- **Internal name:** `energy-shield-equipment`
- **Type:** item
- **Description:** Provides an energy shield to protect the character.
- **Stack size:** 20

### energy-shield-mk2-equipment
- **Internal name:** `energy-shield-mk2-equipment`
- **Type:** item
- **Stack size:** 20
- **Weight:** 100

### personal-laser-defense-equipment
- **Internal name:** `personal-laser-defense-equipment`
- **Type:** item
- **Stack size:** 20
- **Weight:** 200

### discharge-defense-equipment
- **Internal name:** `discharge-defense-equipment`
- **Type:** item
- **Description:** Damages, pushes back and stuns nearby enemies when activated using the remote.
- **Stack size:** 20


## Module

### beacon
- **Internal name:** `beacon`
- **Type:** item
- **Stack size:** 20
- **Places:** beacon

### Speed module
- **Internal name:** `speed-module`
- **Type:** module
- **Description:** Increases machine speed at a cost of increased energy consumption.
- **Stack size:** 50
- **Weight:** 20

### Speed module 2
- **Internal name:** `speed-module-2`
- **Type:** module
- **Stack size:** 50
- **Weight:** 20

### Speed module 3
- **Internal name:** `speed-module-3`
- **Type:** module
- **Stack size:** 50
- **Weight:** 20

### Efficiency module
- **Internal name:** `efficiency-module`
- **Type:** module
- **Description:** Decreases machine energy consumption. Minimum energy consumption is 20%.
- **Stack size:** 50
- **Weight:** 20

### Efficiency module 2
- **Internal name:** `efficiency-module-2`
- **Type:** module
- **Stack size:** 50
- **Weight:** 20

### Efficiency module 3
- **Internal name:** `efficiency-module-3`
- **Type:** module
- **Stack size:** 50
- **Weight:** 20

### Productivity module
- **Internal name:** `productivity-module`
- **Type:** module
- **Description:** Machine will create extra products at a cost of increased energy consumption and reduced speed.\nUsable only on intermediate products.
- **Stack size:** 50
- **Weight:** 20

### Productivity module 2
- **Internal name:** `productivity-module-2`
- **Type:** module
- **Stack size:** 50
- **Weight:** 20

### Productivity module 3
- **Internal name:** `productivity-module-3`
- **Type:** module
- **Stack size:** 50
- **Weight:** 20

### Empty module slot
- **Internal name:** `empty-module-slot`
- **Type:** item
- **Description:** An empty module slot in a machine. Used in upgrade planners to install new modules or uninstall existing modules.
- **Stack size:** 1


## Other

### Electric energy interface
- **Internal name:** `electric-energy-interface`
- **Type:** item
- **Stack size:** 50
- **Places:** electric-energy-interface

### Linked chest
- **Internal name:** `linked-chest`
- **Type:** item
- **Stack size:** 10
- **Places:** linked-chest

### Proxy container
- **Internal name:** `proxy-container`
- **Type:** item
- **Stack size:** 10
- **Places:** proxy-container

### Heat interface
- **Internal name:** `heat-interface`
- **Type:** item
- **Stack size:** 20
- **Places:** heat-interface

### lane-splitter
- **Internal name:** `lane-splitter`
- **Type:** item
- **Stack size:** 50
- **Places:** lane-splitter
- **Weight:** 10

### linked-belt
- **Internal name:** `linked-belt`
- **Type:** item
- **Stack size:** 10
- **Places:** linked-belt

### one-way-valve
- **Internal name:** `one-way-valve`
- **Type:** item
- **Stack size:** 10
- **Places:** one-way-valve

### overflow-valve
- **Internal name:** `overflow-valve`
- **Type:** item
- **Stack size:** 10
- **Places:** overflow-valve

### top-up-valve
- **Internal name:** `top-up-valve`
- **Type:** item
- **Stack size:** 10
- **Places:** top-up-valve

### infinity-cargo-wagon
- **Internal name:** `infinity-cargo-wagon`
- **Type:** item
- **Stack size:** 5
- **Places:** infinity-cargo-wagon

### Infinity chest
- **Internal name:** `infinity-chest`
- **Type:** item
- **Stack size:** 10
- **Places:** infinity-chest

### Infinity pipe
- **Internal name:** `infinity-pipe`
- **Type:** item
- **Stack size:** 10
- **Places:** infinity-pipe

### Simple entity with force
- **Internal name:** `simple-entity-with-force`
- **Type:** item
- **Stack size:** 50
- **Places:** simple-entity-with-force

### Simple entity with owner
- **Internal name:** `simple-entity-with-owner`
- **Type:** item
- **Stack size:** 50
- **Places:** simple-entity-with-owner

### Burner generator
- **Internal name:** `burner-generator`
- **Type:** item
- **Stack size:** 10
- **Places:** burner-generator


## Parameters

### parameter-
- **Internal name:** `parameter-`
- **Type:** item
- **Stack size:** 1


## Production Machine

### assembling-machine-1
- **Internal name:** `assembling-machine-1`
- **Type:** item
- **Stack size:** 50
- **Places:** assembling-machine-1

### assembling-machine-2
- **Internal name:** `assembling-machine-2`
- **Type:** item
- **Stack size:** 50
- **Places:** assembling-machine-2

### assembling-machine-3
- **Internal name:** `assembling-machine-3`
- **Type:** item
- **Stack size:** 50
- **Places:** assembling-machine-3
- **Weight:** 40

### oil-refinery
- **Internal name:** `oil-refinery`
- **Type:** item
- **Stack size:** 10
- **Places:** oil-refinery

### chemical-plant
- **Internal name:** `chemical-plant`
- **Type:** item
- **Stack size:** 10
- **Places:** chemical-plant

### centrifuge
- **Internal name:** `centrifuge`
- **Type:** item
- **Stack size:** 50
- **Places:** centrifuge

### Lab
- **Internal name:** `lab`
- **Type:** item
- **Stack size:** 10
- **Places:** lab


## Raw Material

### Iron plate
- **Internal name:** `iron-plate`
- **Type:** item
- **Stack size:** 100

### Copper plate
- **Internal name:** `copper-plate`
- **Type:** item
- **Stack size:** 100

### Steel plate
- **Internal name:** `steel-plate`
- **Type:** item
- **Stack size:** 100

### Solid fuel
- **Internal name:** `solid-fuel`
- **Type:** item
- **Stack size:** 50
- **Fuel value:** 12MJ
- **Fuel category:** chemical
- **Weight:** 1

### Plastic bar
- **Internal name:** `plastic-bar`
- **Type:** item
- **Stack size:** 100
- **Weight:** 500

### Sulfur
- **Internal name:** `sulfur`
- **Type:** item
- **Stack size:** 50
- **Weight:** 1

### Battery
- **Internal name:** `battery`
- **Type:** item
- **Stack size:** 200

### Explosives
- **Internal name:** `explosives`
- **Type:** item
- **Stack size:** 50
- **Weight:** 2


## Raw Resource

### Wood
- **Internal name:** `wood`
- **Type:** item
- **Stack size:** 100
- **Fuel value:** 2MJ
- **Fuel category:** chemical
- **Weight:** 2

### Coal
- **Internal name:** `coal`
- **Type:** item
- **Stack size:** 50
- **Fuel value:** 4MJ
- **Fuel category:** chemical
- **Weight:** 2

### Stone
- **Internal name:** `stone`
- **Type:** item
- **Stack size:** 50
- **Weight:** 2

### Iron ore
- **Internal name:** `iron-ore`
- **Type:** item
- **Stack size:** 50
- **Weight:** 2

### Copper ore
- **Internal name:** `copper-ore`
- **Type:** item
- **Stack size:** 50
- **Weight:** 2

### Uranium ore
- **Internal name:** `uranium-ore`
- **Type:** item
- **Stack size:** 50
- **Weight:** 5

### Raw fish
- **Internal name:** `raw-fish`
- **Type:** capsule
- **Stack size:** 100
- **Weight:** 1


## Science Pack

### Automation science pack
- **Internal name:** `automation-science-pack`
- **Type:** tool
- **Stack size:** 200
- **Weight:** 1

### Logistic science pack
- **Internal name:** `logistic-science-pack`
- **Type:** tool
- **Stack size:** 200
- **Weight:** 1

### Military science pack
- **Internal name:** `military-science-pack`
- **Type:** tool
- **Stack size:** 200
- **Weight:** 1

### Chemical science pack
- **Internal name:** `chemical-science-pack`
- **Type:** tool
- **Stack size:** 200
- **Weight:** 1

### Production science pack
- **Internal name:** `production-science-pack`
- **Type:** tool
- **Stack size:** 200
- **Weight:** 1

### Utility science pack
- **Internal name:** `utility-science-pack`
- **Type:** tool
- **Stack size:** 200
- **Weight:** 1

### Space science pack
- **Internal name:** `space-science-pack`
- **Type:** tool
- **Description:** Used by labs for research. Obtained by launching satellites into space.
- **Stack size:** 2000
- **Weight:** 1

### Coin
- **Internal name:** `coin`
- **Type:** item
- **Stack size:** 100000

### Science
- **Internal name:** `science`
- **Type:** item
- **Description:** Represents the overall research output.
- **Stack size:** 1


## Smelting Machine

### stone-furnace
- **Internal name:** `stone-furnace`
- **Type:** item
- **Stack size:** 50
- **Places:** stone-furnace

### steel-furnace
- **Internal name:** `steel-furnace`
- **Type:** item
- **Stack size:** 50
- **Places:** steel-furnace

### electric-furnace
- **Internal name:** `electric-furnace`
- **Type:** item
- **Stack size:** 50
- **Places:** electric-furnace
- **Weight:** 20


## Space Related

### rocket-silo
- **Internal name:** `rocket-silo`
- **Type:** item
- **Stack size:** 1
- **Places:** rocket-silo
- **Weight:** 10

### cargo-landing-pad
- **Internal name:** `cargo-landing-pad`
- **Type:** item
- **Stack size:** 1
- **Places:** cargo-landing-pad
- **Weight:** 1

### Satellite
- **Internal name:** `satellite`
- **Type:** item
- **Description:** Can be sent to space by the rocket silo to obtain space science packs.
- **Stack size:** 1
- **Weight:** 1


## Spawnables

### Copper wire
- **Internal name:** `copper-wire`
- **Type:** item
- **Description:** Used to manually connect and disconnect electric poles and power switches with __CONTROL__build__.
- **Stack size:** 1

### Green wire
- **Internal name:** `green-wire`
- **Type:** item
- **Description:** Used to connect machines to the circuit network using __CONTROL__build__.
- **Stack size:** 1

### Red wire
- **Internal name:** `red-wire`
- **Type:** item
- **Description:** Used to connect machines to the circuit network using __CONTROL__build__.
- **Stack size:** 1

### Discharge defense remote
- **Internal name:** `discharge-defense-remote`
- **Type:** capsule
- **Stack size:** 1

### Artillery targeting remote
- **Internal name:** `artillery-targeting-remote`
- **Type:** capsule
- **Description:** Allows firing artillery manually from the map or the world.
- **Stack size:** 1


## Storage

### wooden-chest
- **Internal name:** `wooden-chest`
- **Type:** item
- **Stack size:** 50
- **Places:** wooden-chest

### iron-chest
- **Internal name:** `iron-chest`
- **Type:** item
- **Stack size:** 50
- **Places:** iron-chest

### steel-chest
- **Internal name:** `steel-chest`
- **Type:** item
- **Stack size:** 50
- **Places:** steel-chest

### storage-tank
- **Internal name:** `storage-tank`
- **Type:** item
- **Stack size:** 50
- **Places:** storage-tank


## Terrain

### Stone brick
- **Internal name:** `stone-brick`
- **Type:** item
- **Stack size:** 100

### Concrete
- **Internal name:** `concrete`
- **Type:** item
- **Stack size:** 100
- **Weight:** 10

### Hazard concrete
- **Internal name:** `hazard-concrete`
- **Type:** item
- **Stack size:** 100
- **Weight:** 10

### Refined concrete
- **Internal name:** `refined-concrete`
- **Type:** item
- **Stack size:** 100
- **Weight:** 10

### Refined hazard concrete
- **Internal name:** `refined-hazard-concrete`
- **Type:** item
- **Stack size:** 100
- **Weight:** 10

### Landfill
- **Internal name:** `landfill`
- **Type:** item
- **Description:** Can be placed on water to create terrain you can build on.
- **Stack size:** 100

### Cliff explosives
- **Internal name:** `cliff-explosives`
- **Type:** capsule
- **Stack size:** 20


## Tool

### Repair pack
- **Internal name:** `repair-pack`
- **Type:** repair-tool
- **Description:** Used to repair friendly entities.
- **Stack size:** 100


## Train Transport

### train-stop
- **Internal name:** `train-stop`
- **Type:** item
- **Stack size:** 10
- **Places:** train-stop

### rail-signal
- **Internal name:** `rail-signal`
- **Type:** item
- **Stack size:** 50
- **Places:** rail-signal

### rail-chain-signal
- **Internal name:** `rail-chain-signal`
- **Type:** item
- **Stack size:** 50
- **Places:** rail-chain-signal


## Turret

### gun-turret
- **Internal name:** `gun-turret`
- **Type:** item
- **Stack size:** 50
- **Places:** gun-turret

### Laser turret
- **Internal name:** `laser-turret`
- **Type:** item
- **Stack size:** 50
- **Places:** laser-turret
- **Weight:** 40

### Flamethrower turret
- **Internal name:** `flamethrower-turret`
- **Type:** item
- **Stack size:** 50
- **Places:** flamethrower-turret
- **Weight:** 50

### Artillery turret
- **Internal name:** `artillery-turret`
- **Type:** item
- **Stack size:** 10
- **Places:** artillery-turret
- **Weight:** 200


## Uranium Processing

### Uranium-235
- **Internal name:** `uranium-235`
- **Type:** item
- **Stack size:** 100
- **Weight:** 50

### Uranium-238
- **Internal name:** `uranium-238`
- **Type:** item
- **Stack size:** 100
- **Weight:** 50

### Uranium fuel cell
- **Internal name:** `uranium-fuel-cell`
- **Type:** item
- **Stack size:** 50
- **Fuel value:** 8GJ
- **Fuel category:** nuclear
- **Weight:** 100

### Depleted uranium fuel cell
- **Internal name:** `depleted-uranium-fuel-cell`
- **Type:** item
- **Stack size:** 50
- **Weight:** 100

### Nuclear fuel
- **Internal name:** `nuclear-fuel`
- **Type:** item
- **Stack size:** 1
- **Fuel value:** 1.21GJ
- **Fuel category:** chemical
- **Weight:** 100


## Utility Equipment

### Belt immunity equipment
- **Internal name:** `belt-immunity-equipment`
- **Type:** item
- **Description:** Prevents belts from moving the character.
- **Stack size:** 20

### exoskeleton-equipment
- **Internal name:** `exoskeleton-equipment`
- **Type:** item
- **Description:** Increases your movement speed.
- **Stack size:** 20

### personal-roboport-equipment
- **Internal name:** `personal-roboport-equipment`
- **Type:** item
- **Description:** Allows construction bots to work from your inventory.
- **Stack size:** 20

### personal-roboport-mk2-equipment
- **Internal name:** `personal-roboport-mk2-equipment`
- **Type:** item
- **Stack size:** 20

### night-vision-equipment
- **Internal name:** `night-vision-equipment`
- **Type:** item
- **Description:** Allows you to see more clearly in darkness.
- **Stack size:** 20

---

## recipes-detailed

# Factorio Recipes - Detailed

Complete crafting recipes with ingredients and results.


## Advanced Crafting

### Engine unit
- **Internal name:** `engine-unit`
- **Crafting time:** 10 seconds
- **Category:** advanced-crafting
- **Enabled from start:** False
- **Ingredients:**
  - Engine unit: 1
  - Iron gear wheel: 1
  - pipe: 2


## Centrifuging

### Kovarex enrichment process
- **Internal name:** `kovarex-enrichment-process`
- **Crafting time:** 60 seconds
- **Category:** centrifuging
- **Enabled from start:** False
- **Ingredients:**
  - kovarex-enrichment-process: 40
  - Uranium-238: 5

### Nuclear fuel
- **Internal name:** `nuclear-fuel`
- **Crafting time:** 90 seconds
- **Category:** centrifuging
- **Enabled from start:** False
- **Ingredients:**
  - Nuclear fuel: 1
  - Rocket fuel: 1
  - Nuclear fuel: 1

### Nuclear fuel reprocessing
- **Internal name:** `nuclear-fuel-reprocessing`
- **Crafting time:** 60 seconds
- **Category:** centrifuging
- **Enabled from start:** False
- **Ingredients:**
  - nuclear-fuel-reprocessing: 5
  - Uranium-238: 3

### Uranium processing
- **Internal name:** `uranium-processing`
- **Crafting time:** 12 seconds
- **Category:** centrifuging
- **Enabled from start:** False
- **Ingredients:**
  - uranium-processing: 10
  - Uranium-235: 1


## Chemistry

### Battery
- **Internal name:** `battery`
- **Crafting time:** 4 seconds
- **Category:** chemistry
- **Enabled from start:** False
- **Ingredients:**
  - Battery: 20
  - Iron plate: 1
  - Copper plate: 1

### Explosives
- **Internal name:** `explosives`
- **Crafting time:** 0.5 seconds
- **Category:** chemistry
- **Enabled from start:** False

### Flamethrower ammo
- **Internal name:** `flamethrower-ammo`
- **Crafting time:** 6 seconds
- **Category:** chemistry
- **Enabled from start:** False
- **Ingredients:**
  - Flamethrower ammo: 5
  - crude-oil: 100

### Heavy oil cracking to light oil
- **Internal name:** `heavy-oil-cracking`
- **Crafting time:** 2 seconds
- **Category:** chemistry
- **Enabled from start:** False
- **Ingredients:**
  - heavy-oil-cracking: 30
  - heavy-oil: 40

### Light oil cracking to petroleum gas
- **Internal name:** `light-oil-cracking`
- **Crafting time:** 2 seconds
- **Category:** chemistry
- **Enabled from start:** False
- **Ingredients:**
  - light-oil-cracking: 30
  - light-oil: 30

### Plastic bar
- **Internal name:** `plastic-bar`
- **Crafting time:** 1 seconds
- **Category:** chemistry
- **Enabled from start:** False
- **Ingredients:**
  - Plastic bar: 20
  - Coal: 1

### Solid fuel from heavy oil
- **Internal name:** `solid-fuel-from-heavy-oil`
- **Crafting time:** 1 seconds
- **Category:** chemistry
- **Enabled from start:** False
- **Ingredients:**
  - solid-fuel-from-heavy-oil: 20

### Solid fuel from light oil
- **Internal name:** `solid-fuel-from-light-oil`
- **Crafting time:** 1 seconds
- **Category:** chemistry
- **Enabled from start:** False
- **Ingredients:**
  - solid-fuel-from-light-oil: 10

### Solid fuel from petroleum gas
- **Internal name:** `solid-fuel-from-petroleum-gas`
- **Crafting time:** 1 seconds
- **Category:** chemistry
- **Enabled from start:** False
- **Ingredients:**
  - solid-fuel-from-petroleum-gas: 20

### Sulfur
- **Internal name:** `sulfur`
- **Crafting time:** 1 seconds
- **Category:** chemistry
- **Enabled from start:** False
- **Ingredients:**
  - Sulfur: 30
  - petroleum-gas: 30

### lubricant
- **Internal name:** `lubricant`
- **Crafting time:** 1 seconds
- **Category:** chemistry
- **Enabled from start:** False
- **Ingredients:**
  - lubricant: 10

### sulfuric-acid
- **Internal name:** `sulfuric-acid`
- **Crafting time:** 1 seconds
- **Category:** chemistry
- **Enabled from start:** False
- **Ingredients:**
  - sulfuric-acid: 5
  - Iron plate: 1
  - water: 100


## Crafting

### Advanced circuit
- **Internal name:** `advanced-circuit`
- **Crafting time:** 6 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Advanced circuit: 2
  - Plastic bar: 2
  - Copper cable: 4

### Artillery shell
- **Internal name:** `artillery-shell`
- **Crafting time:** 15 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Artillery shell: 4
  - radar: 1
  - Explosives: 8

### Artillery turret
- **Internal name:** `artillery-turret`
- **Crafting time:** 40 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Artillery turret: 60
  - Concrete: 60
  - Iron gear wheel: 40
  - Advanced circuit: 20

### Atomic bomb
- **Internal name:** `atomic-bomb`
- **Crafting time:** 50 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Atomic bomb: 10
  - Explosives: 10
  - Uranium-235: 30

### Automation science pack
- **Internal name:** `automation-science-pack`
- **Crafting time:** 5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Automation science pack: 1
  - Iron gear wheel: 1

### Barrel
- **Internal name:** `barrel`
- **Crafting time:** 1 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Barrel: 1

### Belt immunity equipment
- **Internal name:** `belt-immunity-equipment`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Belt immunity equipment: 5
  - Steel plate: 10

### Cannon shell
- **Internal name:** `cannon-shell`
- **Crafting time:** 8 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Cannon shell: 2
  - Plastic bar: 2
  - Explosives: 1

### Chemical science pack
- **Internal name:** `chemical-science-pack`
- **Crafting time:** 24 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Chemical science pack: 2
  - Advanced circuit: 3
  - Sulfur: 1

### Cliff explosives
- **Internal name:** `cliff-explosives`
- **Crafting time:** 8 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Cliff explosives: 10
  - Grenade: 1
  - Barrel: 1

### Cluster grenade
- **Internal name:** `cluster-grenade`
- **Crafting time:** 8 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Cluster grenade: 7
  - Explosives: 5
  - Steel plate: 5

### Combat shotgun
- **Internal name:** `combat-shotgun`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Combat shotgun: 15
  - Iron gear wheel: 5
  - Copper plate: 10
  - Wood: 10

### Copper cable
- **Internal name:** `copper-cable`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Copper cable: 1
  - Copper cable: 2

### Defender capsule
- **Internal name:** `defender-capsule`
- **Crafting time:** 8 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Defender capsule: 3
  - Electronic circuit: 3
  - Iron gear wheel: 3

### Destroyer capsule
- **Internal name:** `destroyer-capsule`
- **Crafting time:** 15 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Destroyer capsule: 4
  - Speed module: 1

### Display panel
- **Internal name:** `display-panel`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Display panel: 1
  - Electronic circuit: 1
  - Display panel: 1

### Distractor capsule
- **Internal name:** `distractor-capsule`
- **Crafting time:** 15 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Distractor capsule: 4
  - Advanced circuit: 3

### Efficiency module
- **Internal name:** `efficiency-module`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Efficiency module: 5
  - Electronic circuit: 5

### Efficiency module 2
- **Internal name:** `efficiency-module-2`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Efficiency module 2: 4
  - Advanced circuit: 5
  - Processing unit: 5

### Efficiency module 3
- **Internal name:** `efficiency-module-3`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Efficiency module 3: 4
  - Advanced circuit: 5
  - Processing unit: 5

### Electronic circuit
- **Internal name:** `electronic-circuit`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Electronic circuit: 1
  - Copper cable: 3

### Explosive cannon shell
- **Internal name:** `explosive-cannon-shell`
- **Crafting time:** 8 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Explosive cannon shell: 2
  - Plastic bar: 2
  - Explosives: 2

### Explosive rocket
- **Internal name:** `explosive-rocket`
- **Crafting time:** 8 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Explosive rocket: 1
  - Explosives: 2

### Explosive uranium cannon shell
- **Internal name:** `explosive-uranium-cannon-shell`
- **Crafting time:** 12 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Explosive uranium cannon shell: 1
  - Uranium-238: 1

### Firearm magazine
- **Internal name:** `firearm-magazine`
- **Crafting time:** 1 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Firearm magazine: 4
  - Firearm magazine: 1

### Flamethrower
- **Internal name:** `flamethrower`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Flamethrower: 5
  - Iron gear wheel: 10

### Flamethrower turret
- **Internal name:** `flamethrower-turret`
- **Crafting time:** 20 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Flamethrower turret: 30
  - Iron gear wheel: 15
  - pipe: 10
  - Engine unit: 5

### Flying robot frame
- **Internal name:** `flying-robot-frame`
- **Crafting time:** 20 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Flying robot frame: 1
  - Battery: 2
  - Steel plate: 1
  - Electronic circuit: 3

### Grenade
- **Internal name:** `grenade`
- **Crafting time:** 8 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Grenade: 5
  - Coal: 10

### Hazard concrete
- **Internal name:** `hazard-concrete`
- **Crafting time:** 0.25 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Hazard concrete: 10

### Heavy armor
- **Internal name:** `heavy-armor`
- **Crafting time:** 8 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Heavy armor: 100
  - Steel plate: 50
  - Heavy armor: 1

### Iron gear wheel
- **Internal name:** `iron-gear-wheel`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Iron gear wheel: 2
  - Iron gear wheel: 1

### Iron stick
- **Internal name:** `iron-stick`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Iron stick: 1
  - Iron stick: 2

### Lab
- **Internal name:** `lab`
- **Crafting time:** 2 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Lab: 10
  - Iron gear wheel: 10
  - transport-belt: 4

### Landfill
- **Internal name:** `landfill`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Landfill: 50

### Laser turret
- **Internal name:** `laser-turret`
- **Crafting time:** 20 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Laser turret: 20
  - Electronic circuit: 20
  - Battery: 12

### Light armor
- **Internal name:** `light-armor`
- **Crafting time:** 3 seconds
- **Category:** crafting
- **Enabled from start:** True
- **Ingredients:**
  - Light armor: 40
  - Light armor: 1

### Logistic science pack
- **Internal name:** `logistic-science-pack`
- **Crafting time:** 6 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Logistic science pack: 1
  - transport-belt: 1

### Low density structure
- **Internal name:** `low-density-structure`
- **Crafting time:** 15 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Low density structure: 2
  - Copper plate: 20
  - Plastic bar: 5

### Military science pack
- **Internal name:** `military-science-pack`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Military science pack: 1
  - Grenade: 1
  - stone-wall: 2

### Modular armor
- **Internal name:** `modular-armor`
- **Crafting time:** 15 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Modular armor: 30
  - Steel plate: 50

### Piercing rounds magazine
- **Internal name:** `piercing-rounds-magazine`
- **Crafting time:** 6 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Piercing rounds magazine: 2
  - Steel plate: 1
  - Copper plate: 2

### Piercing shotgun shells
- **Internal name:** `piercing-shotgun-shell`
- **Crafting time:** 8 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Piercing shotgun shells: 2
  - Copper plate: 5
  - Steel plate: 2

### Pistol
- **Internal name:** `pistol`
- **Crafting time:** 5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Pistol: 5
  - Iron plate: 5

### Poison capsule
- **Internal name:** `poison-capsule`
- **Crafting time:** 8 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Poison capsule: 3
  - Electronic circuit: 3
  - Coal: 10

### Power armor
- **Internal name:** `power-armor`
- **Crafting time:** 20 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Power armor: 40
  - Electric engine unit: 20
  - Steel plate: 40
  - Power armor: 1

### Power armor MK2
- **Internal name:** `power-armor-mk2`
- **Crafting time:** 25 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Power armor MK2: 25
  - Speed module 2: 25
  - Processing unit: 60
  - Electric engine unit: 40
  - Low density structure: 30

### Production science pack
- **Internal name:** `production-science-pack`
- **Crafting time:** 21 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Production science pack: 1
  - Productivity module: 1
  - Rail: 30

### Productivity module
- **Internal name:** `productivity-module`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Productivity module: 5
  - Electronic circuit: 5

### Productivity module 2
- **Internal name:** `productivity-module-2`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Productivity module 2: 4
  - Advanced circuit: 5
  - Processing unit: 5

### Productivity module 3
- **Internal name:** `productivity-module-3`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Productivity module 3: 4
  - Advanced circuit: 5
  - Processing unit: 5

### Rail
- **Internal name:** `rail`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Rail: 1
  - Iron stick: 1
  - Steel plate: 1

### Refined hazard concrete
- **Internal name:** `refined-hazard-concrete`
- **Crafting time:** 0.25 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Refined hazard concrete: 10

### Repair pack
- **Internal name:** `repair-pack`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Repair pack: 2
  - Iron gear wheel: 2

### Rocket
- **Internal name:** `rocket`
- **Crafting time:** 4 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Rocket: 1
  - Iron plate: 2

### Rocket launcher
- **Internal name:** `rocket-launcher`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Rocket launcher: 5
  - Iron gear wheel: 5
  - Electronic circuit: 5

### Satellite
- **Internal name:** `satellite`
- **Crafting time:** 5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Satellite: 100
  - Solar panel: 100
  - accumulator: 100
  - radar: 5
  - Processing unit: 100
  - Rocket fuel: 50

### Shotgun
- **Internal name:** `shotgun`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Shotgun: 15
  - Iron gear wheel: 5
  - Copper plate: 10
  - Wood: 5

### Shotgun shells
- **Internal name:** `shotgun-shell`
- **Crafting time:** 3 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Shotgun shells: 2
  - Iron plate: 2

### Slowdown capsule
- **Internal name:** `slowdown-capsule`
- **Crafting time:** 8 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Slowdown capsule: 2
  - Electronic circuit: 2
  - Coal: 5

### Solar panel
- **Internal name:** `solar-panel`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Solar panel: 5
  - Electronic circuit: 15
  - Copper plate: 5

### Speed module
- **Internal name:** `speed-module`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Speed module: 5
  - Electronic circuit: 5

### Speed module 2
- **Internal name:** `speed-module-2`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Speed module 2: 4
  - Advanced circuit: 5
  - Processing unit: 5

### Speed module 3
- **Internal name:** `speed-module-3`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Speed module 3: 4
  - Advanced circuit: 5
  - Processing unit: 5

### Submachine gun
- **Internal name:** `submachine-gun`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Submachine gun: 10
  - Copper plate: 5
  - Iron plate: 10

### Uranium cannon shell
- **Internal name:** `uranium-cannon-shell`
- **Crafting time:** 12 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Uranium cannon shell: 1
  - Uranium-238: 1

### Uranium fuel cell
- **Internal name:** `uranium-fuel-cell`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Uranium fuel cell: 10
  - Uranium-235: 1
  - Uranium-238: 19

### Uranium rounds magazine
- **Internal name:** `uranium-rounds-magazine`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Uranium rounds magazine: 1
  - Uranium-238: 1

### Utility science pack
- **Internal name:** `utility-science-pack`
- **Crafting time:** 21 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - Utility science pack: 3
  - Processing unit: 2
  - Flying robot frame: 1

### accumulator
- **Internal name:** `accumulator`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - accumulator: 2
  - Battery: 5

### active-provider-chest
- **Internal name:** `active-provider-chest`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - active-provider-chest: 1
  - Electronic circuit: 3
  - Advanced circuit: 1

### arithmetic-combinator
- **Internal name:** `arithmetic-combinator`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - arithmetic-combinator: 5
  - Electronic circuit: 5

### artillery-wagon
- **Internal name:** `artillery-wagon`
- **Crafting time:** 4 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - artillery-wagon: 64
  - Iron gear wheel: 10
  - Steel plate: 40
  - pipe: 16
  - Advanced circuit: 20

### assembling-machine-1
- **Internal name:** `assembling-machine-1`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - assembling-machine-1: 3
  - Iron gear wheel: 5
  - Iron plate: 9

### assembling-machine-2
- **Internal name:** `assembling-machine-2`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - assembling-machine-2: 2
  - Electronic circuit: 3
  - Iron gear wheel: 5
  - assembling-machine-1: 1

### assembling-machine-3
- **Internal name:** `assembling-machine-3`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - assembling-machine-3: 4
  - assembling-machine-2: 2

### battery-equipment
- **Internal name:** `battery-equipment`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - battery-equipment: 5
  - Steel plate: 10

### battery-mk2-equipment
- **Internal name:** `battery-mk2-equipment`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - battery-mk2-equipment: 10
  - Processing unit: 15
  - Low density structure: 5

### beacon
- **Internal name:** `beacon`
- **Crafting time:** 15 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - beacon: 20
  - Advanced circuit: 20
  - Steel plate: 10
  - Copper cable: 10

### big-electric-pole
- **Internal name:** `big-electric-pole`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - big-electric-pole: 8
  - Steel plate: 5
  - Copper cable: 4

### boiler
- **Internal name:** `boiler`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - boiler: 1
  - pipe: 4
  - boiler: 1

### buffer-chest
- **Internal name:** `buffer-chest`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - buffer-chest: 1
  - Electronic circuit: 3
  - Advanced circuit: 1

### bulk-inserter
- **Internal name:** `bulk-inserter`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - bulk-inserter: 15
  - Electronic circuit: 15
  - Advanced circuit: 1
  - fast-inserter: 1

### burner-inserter
- **Internal name:** `burner-inserter`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - burner-inserter: 1
  - Iron gear wheel: 1

### burner-mining-drill
- **Internal name:** `burner-mining-drill`
- **Crafting time:** 2 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - burner-mining-drill: 3
  - stone-furnace: 1
  - Iron plate: 3

### car
- **Internal name:** `car`
- **Crafting time:** 2 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - car: 8
  - Iron plate: 20
  - Steel plate: 5

### cargo-landing-pad
- **Internal name:** `cargo-landing-pad`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - cargo-landing-pad: 200
  - Steel plate: 25
  - Processing unit: 10

### cargo-wagon
- **Internal name:** `cargo-wagon`
- **Crafting time:** 1 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - cargo-wagon: 10
  - Iron plate: 20
  - Steel plate: 20

### centrifuge
- **Internal name:** `centrifuge`
- **Crafting time:** 4 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - centrifuge: 100
  - Steel plate: 50
  - Advanced circuit: 100
  - Iron gear wheel: 100

### chemical-plant
- **Internal name:** `chemical-plant`
- **Crafting time:** 5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - chemical-plant: 5
  - Iron gear wheel: 5
  - Electronic circuit: 5
  - pipe: 5

### constant-combinator
- **Internal name:** `constant-combinator`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - constant-combinator: 5
  - Electronic circuit: 2

### construction-robot
- **Internal name:** `construction-robot`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - construction-robot: 1
  - Electronic circuit: 2

### decider-combinator
- **Internal name:** `decider-combinator`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - decider-combinator: 5
  - Electronic circuit: 5

### discharge-defense-equipment
- **Internal name:** `discharge-defense-equipment`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - discharge-defense-equipment: 5
  - Steel plate: 20
  - Laser turret: 10

### electric-furnace
- **Internal name:** `electric-furnace`
- **Crafting time:** 5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - electric-furnace: 10
  - Advanced circuit: 5
  - Stone brick: 10
  - electric-furnace: 1

### electric-mining-drill
- **Internal name:** `electric-mining-drill`
- **Crafting time:** 2 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - electric-mining-drill: 3
  - Iron gear wheel: 5
  - Iron plate: 10

### energy-shield-equipment
- **Internal name:** `energy-shield-equipment`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - energy-shield-equipment: 5
  - Steel plate: 10

### energy-shield-mk2-equipment
- **Internal name:** `energy-shield-mk2-equipment`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - energy-shield-mk2-equipment: 10
  - Processing unit: 5
  - Low density structure: 5

### exoskeleton-equipment
- **Internal name:** `exoskeleton-equipment`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - exoskeleton-equipment: 10
  - Electric engine unit: 30
  - Steel plate: 20

### express-loader
- **Internal name:** `express-loader`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - express-loader: 5
  - fast-loader: 1

### fast-inserter
- **Internal name:** `fast-inserter`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - fast-inserter: 2
  - Iron plate: 2
  - inserter: 1

### fast-loader
- **Internal name:** `fast-loader`
- **Crafting time:** 3 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - fast-loader: 5
  - loader: 1

### fast-splitter
- **Internal name:** `fast-splitter`
- **Crafting time:** 2 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - fast-splitter: 1
  - Iron gear wheel: 10
  - Electronic circuit: 10

### fast-transport-belt
- **Internal name:** `fast-transport-belt`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - fast-transport-belt: 5
  - transport-belt: 1

### fast-underground-belt
- **Internal name:** `fast-underground-belt`
- **Crafting time:** 2 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - fast-underground-belt: 40
  - underground-belt: 2

### fission-reactor-equipment
- **Internal name:** `fission-reactor-equipment`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - fission-reactor-equipment: 200
  - Low density structure: 50
  - Uranium fuel cell: 4

### fluid-wagon
- **Internal name:** `fluid-wagon`
- **Crafting time:** 1.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - fluid-wagon: 10
  - Steel plate: 16
  - pipe: 8
  - storage-tank: 1

### gate
- **Internal name:** `gate`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - gate: 1
  - Steel plate: 2
  - Electronic circuit: 2
  - gate: 1

### gun-turret
- **Internal name:** `gun-turret`
- **Crafting time:** 8 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - gun-turret: 10
  - Copper plate: 10
  - Iron plate: 20

### heat-exchanger
- **Internal name:** `heat-exchanger`
- **Crafting time:** 3 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - heat-exchanger: 10
  - Copper plate: 100
  - pipe: 10
  - heat-exchanger: 1

### heat-pipe
- **Internal name:** `heat-pipe`
- **Crafting time:** 1 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - heat-pipe: 10
  - Copper plate: 20
  - heat-pipe: 1

### inserter
- **Internal name:** `inserter`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - inserter: 1
  - Iron gear wheel: 1
  - Iron plate: 1

### iron-chest
- **Internal name:** `iron-chest`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** True
- **Ingredients:**
  - iron-chest: 8
  - iron-chest: 1

### land-mine
- **Internal name:** `land-mine`
- **Crafting time:** 5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - land-mine: 1
  - Explosives: 2

### loader
- **Internal name:** `loader`
- **Crafting time:** 1 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - loader: 5
  - Electronic circuit: 5
  - Iron gear wheel: 5
  - Iron plate: 5
  - transport-belt: 5

### locomotive
- **Internal name:** `locomotive`
- **Crafting time:** 4 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - locomotive: 20
  - Electronic circuit: 10
  - Steel plate: 30

### logistic-robot
- **Internal name:** `logistic-robot`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - logistic-robot: 1
  - Advanced circuit: 2

### long-handed-inserter
- **Internal name:** `long-handed-inserter`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - long-handed-inserter: 1
  - Iron plate: 1
  - inserter: 1

### medium-electric-pole
- **Internal name:** `medium-electric-pole`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - medium-electric-pole: 4
  - Steel plate: 2
  - Copper cable: 2

### night-vision-equipment
- **Internal name:** `night-vision-equipment`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - night-vision-equipment: 5
  - Steel plate: 10

### nuclear-reactor
- **Internal name:** `nuclear-reactor`
- **Crafting time:** 8 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - nuclear-reactor: 500
  - Steel plate: 500
  - Advanced circuit: 500
  - Copper plate: 500

### offshore-pump
- **Internal name:** `offshore-pump`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - offshore-pump: 3
  - Iron gear wheel: 2

### oil-refinery
- **Internal name:** `oil-refinery`
- **Crafting time:** 8 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - oil-refinery: 15
  - Iron gear wheel: 10
  - Stone brick: 10
  - Electronic circuit: 10
  - pipe: 10

### passive-provider-chest
- **Internal name:** `passive-provider-chest`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - passive-provider-chest: 1
  - Electronic circuit: 3
  - Advanced circuit: 1

### personal-laser-defense-equipment
- **Internal name:** `personal-laser-defense-equipment`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - personal-laser-defense-equipment: 20
  - Low density structure: 5
  - Laser turret: 5

### personal-roboport-equipment
- **Internal name:** `personal-roboport-equipment`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - personal-roboport-equipment: 10
  - Iron gear wheel: 40
  - Steel plate: 20
  - Battery: 45

### personal-roboport-mk2-equipment
- **Internal name:** `personal-roboport-mk2-equipment`
- **Crafting time:** 20 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - personal-roboport-mk2-equipment: 5
  - Processing unit: 100
  - Low density structure: 20

### pipe
- **Internal name:** `pipe`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - pipe: 1
  - pipe: 1

### pipe-to-ground
- **Internal name:** `pipe-to-ground`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - pipe-to-ground: 10
  - Iron plate: 5

### power-switch
- **Internal name:** `power-switch`
- **Crafting time:** 2 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - power-switch: 5
  - Copper cable: 5
  - Electronic circuit: 2

### programmable-speaker
- **Internal name:** `programmable-speaker`
- **Crafting time:** 2 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - programmable-speaker: 3
  - Iron stick: 4
  - Copper cable: 5
  - Electronic circuit: 4

### pump
- **Internal name:** `pump`
- **Crafting time:** 2 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - pump: 1
  - Steel plate: 1
  - pipe: 1

### pumpjack
- **Internal name:** `pumpjack`
- **Crafting time:** 5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - pumpjack: 5
  - Iron gear wheel: 10
  - Electronic circuit: 5
  - pipe: 10

### radar
- **Internal name:** `radar`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - radar: 5
  - Iron gear wheel: 5
  - Iron plate: 10

### rail-chain-signal
- **Internal name:** `rail-chain-signal`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - rail-chain-signal: 1
  - Iron plate: 5

### rail-signal
- **Internal name:** `rail-signal`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - rail-signal: 1
  - Iron plate: 5

### requester-chest
- **Internal name:** `requester-chest`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - requester-chest: 1
  - Electronic circuit: 3
  - Advanced circuit: 1

### roboport
- **Internal name:** `roboport`
- **Crafting time:** 5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - roboport: 45
  - Iron gear wheel: 45
  - Advanced circuit: 45

### rocket-silo
- **Internal name:** `rocket-silo`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - rocket-silo: 1000
  - Concrete: 1000
  - pipe: 100
  - Processing unit: 200
  - Electric engine unit: 200

### selector-combinator
- **Internal name:** `selector-combinator`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - selector-combinator: 2
  - decider-combinator: 5

### small-electric-pole
- **Internal name:** `small-electric-pole`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - small-electric-pole: 1
  - Copper cable: 2

### small-lamp
- **Internal name:** `small-lamp`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - small-lamp: 1
  - Copper cable: 3
  - Iron plate: 1

### solar-panel-equipment
- **Internal name:** `solar-panel-equipment`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - solar-panel-equipment: 1
  - Advanced circuit: 2
  - Steel plate: 5

### spidertron
- **Internal name:** `spidertron`
- **Crafting time:** 10 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - spidertron: 4
  - fission-reactor-equipment: 2
  - Rocket launcher: 4
  - Processing unit: 16
  - Low density structure: 150
  - radar: 2
  - Efficiency module 3: 2
  - Raw fish: 1

### splitter
- **Internal name:** `splitter`
- **Crafting time:** 1 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - splitter: 5
  - Iron plate: 5
  - transport-belt: 4

### steam-engine
- **Internal name:** `steam-engine`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - steam-engine: 8
  - pipe: 5
  - Iron plate: 10

### steam-turbine
- **Internal name:** `steam-turbine`
- **Crafting time:** 3 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - steam-turbine: 50
  - Copper plate: 50
  - pipe: 20
  - steam-turbine: 1

### steel-chest
- **Internal name:** `steel-chest`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - steel-chest: 8
  - steel-chest: 1

### steel-furnace
- **Internal name:** `steel-furnace`
- **Crafting time:** 3 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - steel-furnace: 6
  - Stone brick: 10
  - steel-furnace: 1

### stone-furnace
- **Internal name:** `stone-furnace`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - stone-furnace: 5
  - stone-furnace: 1

### stone-wall
- **Internal name:** `stone-wall`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - stone-wall: 5
  - stone-wall: 1

### storage-chest
- **Internal name:** `storage-chest`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - storage-chest: 1
  - Electronic circuit: 3
  - Advanced circuit: 1

### storage-tank
- **Internal name:** `storage-tank`
- **Crafting time:** 3 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - storage-tank: 20
  - Steel plate: 5

### substation
- **Internal name:** `substation`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - substation: 10
  - Advanced circuit: 5
  - Copper cable: 6

### tank
- **Internal name:** `tank`
- **Crafting time:** 5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - tank: 32
  - Steel plate: 50
  - Iron gear wheel: 15
  - Advanced circuit: 10

### train-stop
- **Internal name:** `train-stop`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - train-stop: 5
  - Iron plate: 6
  - Iron stick: 6
  - Steel plate: 3

### transport-belt
- **Internal name:** `transport-belt`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - transport-belt: 1
  - Iron gear wheel: 1

### underground-belt
- **Internal name:** `underground-belt`
- **Crafting time:** 1 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - underground-belt: 10
  - transport-belt: 5

### wooden-chest
- **Internal name:** `wooden-chest`
- **Crafting time:** 0.5 seconds
- **Category:** crafting
- **Enabled from start:** False
- **Ingredients:**
  - wooden-chest: 2
  - wooden-chest: 1


## Crafting With Fluid

### Concrete
- **Internal name:** `concrete`
- **Crafting time:** 10 seconds
- **Category:** crafting-with-fluid
- **Enabled from start:** False
- **Ingredients:**
  - Concrete: 5
  - Iron ore: 1
  - water: 100

### Electric engine unit
- **Internal name:** `electric-engine-unit`
- **Crafting time:** 10 seconds
- **Category:** crafting-with-fluid
- **Enabled from start:** False
- **Ingredients:**
  - Electric engine unit: 1
  - lubricant: 15
  - Electronic circuit: 2

### Processing unit
- **Internal name:** `processing-unit`
- **Crafting time:** 10 seconds
- **Category:** crafting-with-fluid
- **Enabled from start:** False
- **Ingredients:**
  - Processing unit: 20
  - Advanced circuit: 2
  - sulfuric-acid: 5

### Refined concrete
- **Internal name:** `refined-concrete`
- **Crafting time:** 15 seconds
- **Category:** crafting-with-fluid
- **Enabled from start:** False
- **Ingredients:**
  - Refined concrete: 20
  - Iron stick: 8
  - Steel plate: 1
  - water: 100

### Rocket fuel
- **Internal name:** `rocket-fuel`
- **Crafting time:** 15 seconds
- **Category:** crafting-with-fluid
- **Enabled from start:** False
- **Ingredients:**
  - Rocket fuel: 10
  - light-oil: 10

### express-splitter
- **Internal name:** `express-splitter`
- **Crafting time:** 2 seconds
- **Category:** crafting-with-fluid
- **Enabled from start:** False
- **Ingredients:**
  - express-splitter: 1
  - Iron gear wheel: 10
  - Advanced circuit: 10
  - lubricant: 80

### express-transport-belt
- **Internal name:** `express-transport-belt`
- **Crafting time:** 0.5 seconds
- **Category:** crafting-with-fluid
- **Enabled from start:** False
- **Ingredients:**
  - express-transport-belt: 10
  - fast-transport-belt: 1
  - lubricant: 20

### express-underground-belt
- **Internal name:** `express-underground-belt`
- **Crafting time:** 2 seconds
- **Category:** crafting-with-fluid
- **Enabled from start:** False
- **Ingredients:**
  - express-underground-belt: 80
  - fast-underground-belt: 2
  - lubricant: 40


## Oil Processing

### Advanced oil processing
- **Internal name:** `advanced-oil-processing`
- **Crafting time:** 5 seconds
- **Category:** oil-processing
- **Enabled from start:** False
- **Ingredients:**
  - advanced-oil-processing: 50
  - crude-oil: 100

### Basic oil processing
- **Internal name:** `basic-oil-processing`
- **Crafting time:** 5 seconds
- **Category:** oil-processing
- **Enabled from start:** False
- **Ingredients:**
  - basic-oil-processing: 100

### Coal liquefaction
- **Internal name:** `coal-liquefaction`
- **Crafting time:** 5 seconds
- **Category:** oil-processing
- **Enabled from start:** False
- **Ingredients:**
  - coal-liquefaction: 10
  - heavy-oil: 25
  - steam: 50


## Parameters

### parameter-
- **Internal name:** `parameter-`
- **Crafting time:** 0.5 seconds
- **Category:** parameters
- **Enabled from start:** False


## Rocket Building

### Rocket part
- **Internal name:** `rocket-part`
- **Crafting time:** 3 seconds
- **Category:** rocket-building
- **Enabled from start:** False
- **Ingredients:**
  - Rocket part: 10
  - Low density structure: 10
  - Rocket fuel: 10


## Smelting

### Copper plate
- **Internal name:** `copper-plate`
- **Crafting time:** 3.2 seconds
- **Category:** smelting
- **Enabled from start:** False
- **Ingredients:**
  - Copper plate: 1
  - Copper plate: 1

### Iron plate
- **Internal name:** `iron-plate`
- **Crafting time:** 3.2 seconds
- **Category:** smelting
- **Enabled from start:** False
- **Ingredients:**
  - Iron plate: 1
  - Iron plate: 1

### Steel plate
- **Internal name:** `steel-plate`
- **Crafting time:** 16 seconds
- **Category:** smelting
- **Enabled from start:** False
- **Ingredients:**
  - Steel plate: 5
  - Steel plate: 1

### Stone brick
- **Internal name:** `stone-brick`
- **Crafting time:** 3.2 seconds
- **Category:** smelting
- **Enabled from start:** True
- **Ingredients:**
  - Stone brick: 2
  - Stone brick: 1

---

## recipes

# Factorio Recipes

This document lists all crafting recipes available in Factorio.


## Advanced Crafting

### Engine unit
- **Internal name:** `engine-unit`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 1
- **Results:** {type="item", name="engine-unit", amount=1


## Centrifuging

### Uranium processing
- **Internal name:** `uranium-processing`
- **Crafting time:** 12 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "uranium-ore", amount = 10
- **Results:** 
      {
        type = "item",
        name = "uranium-235",
        probability = 0.007,
        amount = 1
      

### Nuclear fuel reprocessing
- **Internal name:** `nuclear-fuel-reprocessing`
- **Crafting time:** 60 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "depleted-uranium-fuel-cell", amount = 5
- **Results:** {type="item", name="uranium-238", amount=3

### Kovarex enrichment process
- **Internal name:** `kovarex-enrichment-process`
- **Crafting time:** 60 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "uranium-235", amount = 40, ignored_by_stats = 40
- **Results:** 
      {type = "item", name = "uranium-235", amount = 41, ignored_by_stats = 40, ignored_by_productivity = 40

### Nuclear fuel
- **Internal name:** `nuclear-fuel`
- **Crafting time:** 90 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "uranium-235", amount = 1
- **Results:** {type="item", name="nuclear-fuel", amount=1


## Chemistry

### Battery
- **Internal name:** `battery`
- **Crafting time:** 4 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "fluid", name = "sulfuric-acid", amount = 20
- **Results:** {type="item", name="battery", amount=1

### Explosives
- **Internal name:** `explosives`
- **Crafting time:** 4 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "sulfur", amount = 1
- **Results:** {type="item", name="explosives", amount=2

### Flamethrower ammo
- **Internal name:** `flamethrower-ammo`
- **Crafting time:** 6 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 5
- **Results:** {type="item", name="flamethrower-ammo", amount=1

### Plastic bar
- **Internal name:** `plastic-bar`
- **Crafting time:** 1 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "fluid", name = "petroleum-gas", amount = 20
- **Results:** 
      {type = "item", name = "plastic-bar", amount = 2

### Sulfur
- **Internal name:** `sulfur`
- **Crafting time:** 1 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "fluid", name = "water", amount = 30
- **Results:** 
      {type = "item", name = "sulfur", amount = 2

### Heavy oil cracking to light oil
- **Internal name:** `heavy-oil-cracking`
- **Crafting time:** 2 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "fluid", name = "water", amount = 30
- **Results:** 
      {type = "fluid", name = "light-oil", amount = 30

### Light oil cracking to petroleum gas
- **Internal name:** `light-oil-cracking`
- **Crafting time:** 2 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "fluid", name = "water", amount = 30
- **Results:** 
      {type = "fluid", name = "petroleum-gas", amount = 20

### Solid fuel from petroleum gas
- **Internal name:** `solid-fuel-from-petroleum-gas`
- **Crafting time:** 1 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "fluid", name = "petroleum-gas", amount = 20
- **Results:** 
      {type = "item", name = "solid-fuel", amount = 1

### Solid fuel from light oil
- **Internal name:** `solid-fuel-from-light-oil`
- **Crafting time:** 1 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "fluid", name = "light-oil", amount = 10
- **Results:** 
      {type = "item", name = "solid-fuel", amount = 1

### Solid fuel from heavy oil
- **Internal name:** `solid-fuel-from-heavy-oil`
- **Crafting time:** 1 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "fluid", name = "heavy-oil", amount = 20
- **Results:** 
      {type = "item", name = "solid-fuel", amount = 1

### lubricant
- **Internal name:** `lubricant`
- **Crafting time:** 1 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "fluid", name = "heavy-oil", amount = 10
- **Results:** 
      {type = "fluid", name = "lubricant", amount = 10

### sulfuric-acid
- **Internal name:** `sulfuric-acid`
- **Crafting time:** 1 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "sulfur", amount = 5
- **Results:** 
      {type = "fluid", name = "sulfuric-acid", amount = 50


## Crafting

### Advanced circuit
- **Internal name:** `advanced-circuit`
- **Crafting time:** 6 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "electronic-circuit", amount = 2
- **Results:** {type="item", name="advanced-circuit", amount=1

### Artillery shell
- **Internal name:** `artillery-shell`
- **Crafting time:** 15 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "explosive-cannon-shell", amount = 4
- **Results:** {type="item", name="artillery-shell", amount=1

### Artillery turret
- **Internal name:** `artillery-turret`
- **Crafting time:** 40 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 60
- **Results:** {type="item", name="artillery-turret", amount=1

### Atomic bomb
- **Internal name:** `atomic-bomb`
- **Crafting time:** 50 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "processing-unit", amount = 10
- **Results:** {type="item", name="atomic-bomb", amount=1

### Automation science pack
- **Internal name:** `automation-science-pack`
- **Crafting time:** 5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "copper-plate", amount = 1
- **Results:** {type="item", name="automation-science-pack", amount=1

### Barrel
- **Internal name:** `barrel`
- **Crafting time:** 1 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 1
- **Results:** {type="item", name="barrel", amount=1

### Belt immunity equipment
- **Internal name:** `belt-immunity-equipment`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "advanced-circuit", amount = 5
- **Results:** {type="item", name="belt-immunity-equipment", amount=1

### Cannon shell
- **Internal name:** `cannon-shell`
- **Crafting time:** 8 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 2
- **Results:** {type="item", name="cannon-shell", amount=1

### Chemical science pack
- **Internal name:** `chemical-science-pack`
- **Crafting time:** 24 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "engine-unit", amount = 2
- **Results:** {type="item", name="chemical-science-pack", amount=2

### Cliff explosives
- **Internal name:** `cliff-explosives`
- **Crafting time:** 8 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "explosives", amount = 10
- **Results:** {type="item", name="cliff-explosives", amount=1

### Cluster grenade
- **Internal name:** `cluster-grenade`
- **Crafting time:** 8 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "grenade", amount = 7
- **Results:** {type="item", name="cluster-grenade", amount=1

### Combat shotgun
- **Internal name:** `combat-shotgun`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 15
- **Results:** {type="item", name="combat-shotgun", amount=1

### Copper cable
- **Internal name:** `copper-cable`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "copper-plate", amount = 1
- **Results:** {type="item", name="copper-cable", amount=2

### Defender capsule
- **Internal name:** `defender-capsule`
- **Crafting time:** 8 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "piercing-rounds-magazine", amount = 3
- **Results:** {type="item", name="defender-capsule", amount=1

### Destroyer capsule
- **Internal name:** `destroyer-capsule`
- **Crafting time:** 15 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "distractor-capsule", amount = 4
- **Results:** {type="item", name="destroyer-capsule", amount=1

### Display panel
- **Internal name:** `display-panel`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "iron-plate", amount = 1
- **Results:** {type="item", name="display-panel", amount=1

### Distractor capsule
- **Internal name:** `distractor-capsule`
- **Crafting time:** 15 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "defender-capsule", amount = 4
- **Results:** {type="item", name="distractor-capsule", amount=1

### Efficiency module
- **Internal name:** `efficiency-module`
- **Crafting time:** 15 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "advanced-circuit", amount = 5
- **Results:** {type="item", name="efficiency-module", amount=1

### Efficiency module 2
- **Internal name:** `efficiency-module-2`
- **Crafting time:** 30 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "efficiency-module", amount = 4
- **Results:** {type="item", name="efficiency-module-2", amount=1

### Efficiency module 3
- **Internal name:** `efficiency-module-3`
- **Crafting time:** 60 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "efficiency-module-2", amount = 4
- **Results:** {type="item", name="efficiency-module-3", amount=1

### Electronic circuit
- **Internal name:** `electronic-circuit`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-plate", amount = 1
- **Results:** {type="item", name="electronic-circuit", amount=1

### Explosive cannon shell
- **Internal name:** `explosive-cannon-shell`
- **Crafting time:** 8 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 2
- **Results:** {type="item", name="explosive-cannon-shell", amount=1

### Explosive rocket
- **Internal name:** `explosive-rocket`
- **Crafting time:** 8 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "rocket", amount = 1
- **Results:** {type="item", name="explosive-rocket", amount=1

### Explosive uranium cannon shell
- **Internal name:** `explosive-uranium-cannon-shell`
- **Crafting time:** 12 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "explosive-cannon-shell", amount = 1
- **Results:** {type="item", name="explosive-uranium-cannon-shell", amount=1

### Firearm magazine
- **Internal name:** `firearm-magazine`
- **Crafting time:** 1 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "iron-plate", amount = 4
- **Results:** {type="item", name="firearm-magazine", amount=1

### Flamethrower
- **Internal name:** `flamethrower`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 5
- **Results:** {type="item", name="flamethrower", amount=1

### Flamethrower turret
- **Internal name:** `flamethrower-turret`
- **Crafting time:** 20 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 30
- **Results:** {type="item", name="flamethrower-turret", amount=1

### Flying robot frame
- **Internal name:** `flying-robot-frame`
- **Crafting time:** 20 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "electric-engine-unit", amount = 1
- **Results:** {type="item", name="flying-robot-frame", amount=1

### Grenade
- **Internal name:** `grenade`
- **Crafting time:** 8 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-plate", amount = 5
- **Results:** {type="item", name="grenade", amount=1

### Hazard concrete
- **Internal name:** `hazard-concrete`
- **Crafting time:** 0.25 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "concrete", amount = 10
- **Results:** {type="item", name="hazard-concrete", amount=10

### Heavy armor
- **Internal name:** `heavy-armor`
- **Crafting time:** 8 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "copper-plate", amount = 100
- **Results:** {type="item", name="heavy-armor", amount=1

### Iron gear wheel
- **Internal name:** `iron-gear-wheel`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "iron-plate", amount = 2
- **Results:** {type="item", name="iron-gear-wheel", amount=1

### Iron stick
- **Internal name:** `iron-stick`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "iron-plate", amount = 1
- **Results:** {type="item", name="iron-stick", amount=2

### Lab
- **Internal name:** `lab`
- **Crafting time:** 2 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "electronic-circuit", amount = 10
- **Results:** {type="item", name="lab", amount=1

### Landfill
- **Internal name:** `landfill`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "stone", amount = 50
- **Results:** {type="item", name="landfill", amount=1

### Laser turret
- **Internal name:** `laser-turret`
- **Crafting time:** 20 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 20
- **Results:** {type="item", name="laser-turret", amount=1

### Light armor
- **Internal name:** `light-armor`
- **Crafting time:** 3 seconds
- **Enabled from start:** True
- **Ingredients:** {type = "item", name = "iron-plate", amount = 40
- **Results:** {type="item", name="light-armor", amount=1

### Logistic science pack
- **Internal name:** `logistic-science-pack`
- **Crafting time:** 6 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "inserter", amount = 1
- **Results:** {type="item", name="logistic-science-pack", amount=1

### Low density structure
- **Internal name:** `low-density-structure`
- **Crafting time:** 15 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 2
- **Results:** {type="item", name="low-density-structure", amount=1

### Military science pack
- **Internal name:** `military-science-pack`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "piercing-rounds-magazine", amount = 1
- **Results:** {type="item", name="military-science-pack", amount=2

### Modular armor
- **Internal name:** `modular-armor`
- **Crafting time:** 15 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "advanced-circuit", amount = 30
- **Results:** {type="item", name="modular-armor", amount=1

### Piercing rounds magazine
- **Internal name:** `piercing-rounds-magazine`
- **Crafting time:** 6 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "firearm-magazine", amount = 2
- **Results:** {type="item", name="piercing-rounds-magazine", amount = 2

### Piercing shotgun shells
- **Internal name:** `piercing-shotgun-shell`
- **Crafting time:** 8 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "shotgun-shell", amount = 2
- **Results:** {type="item", name="piercing-shotgun-shell", amount=1

### Pistol
- **Internal name:** `pistol`
- **Crafting time:** 5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "copper-plate", amount = 5
- **Results:** {type="item", name="pistol", amount=1

### Poison capsule
- **Internal name:** `poison-capsule`
- **Crafting time:** 8 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 3
- **Results:** {type="item", name="poison-capsule", amount=1

### Power armor
- **Internal name:** `power-armor`
- **Crafting time:** 20 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "processing-unit", amount = 40
- **Results:** {type="item", name="power-armor", amount=1

### Power armor MK2
- **Internal name:** `power-armor-mk2`
- **Crafting time:** 25 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "efficiency-module-2", amount = 25
- **Results:** {type="item", name="power-armor-mk2", amount=1

### Production science pack
- **Internal name:** `production-science-pack`
- **Crafting time:** 21 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "electric-furnace", amount = 1
- **Results:** {type="item", name="production-science-pack", amount=3

### Productivity module
- **Internal name:** `productivity-module`
- **Crafting time:** 15 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "advanced-circuit", amount = 5
- **Results:** {type="item", name="productivity-module", amount=1

### Productivity module 2
- **Internal name:** `productivity-module-2`
- **Crafting time:** 30 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "productivity-module", amount = 4
- **Results:** {type="item", name="productivity-module-2", amount=1

### Productivity module 3
- **Internal name:** `productivity-module-3`
- **Crafting time:** 60 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "productivity-module-2", amount = 4
- **Results:** {type="item", name="productivity-module-3", amount=1

### Rail
- **Internal name:** `rail`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "stone", amount = 1
- **Results:** {type="item", name="rail", amount=2

### Refined hazard concrete
- **Internal name:** `refined-hazard-concrete`
- **Crafting time:** 0.25 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "refined-concrete", amount = 10
- **Results:** {type="item", name="refined-hazard-concrete", amount=10

### Repair pack
- **Internal name:** `repair-pack`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "electronic-circuit", amount = 2
- **Results:** {type="item", name="repair-pack", amount=1

### Rocket
- **Internal name:** `rocket`
- **Crafting time:** 4 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "explosives", amount = 1
- **Results:** {type="item", name="rocket", amount=1

### Rocket launcher
- **Internal name:** `rocket-launcher`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-plate", amount = 5
- **Results:** {type="item", name="rocket-launcher", amount=1

### Satellite
- **Internal name:** `satellite`
- **Crafting time:** 5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "low-density-structure", amount = 100
- **Results:** {type="item", name="satellite", amount=1

### Shotgun
- **Internal name:** `shotgun`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-plate", amount = 15
- **Results:** {type="item", name="shotgun", amount=1

### Shotgun shells
- **Internal name:** `shotgun-shell`
- **Crafting time:** 3 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "copper-plate", amount = 2
- **Results:** {type="item", name="shotgun-shell", amount=1

### Slowdown capsule
- **Internal name:** `slowdown-capsule`
- **Crafting time:** 8 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 2
- **Results:** {type="item", name="slowdown-capsule", amount=1

### Solar panel
- **Internal name:** `solar-panel`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 5
- **Results:** {type="item", name="solar-panel", amount=1

### Speed module
- **Internal name:** `speed-module`
- **Crafting time:** 15 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "advanced-circuit", amount = 5
- **Results:** {type="item", name="speed-module", amount=1

### Speed module 2
- **Internal name:** `speed-module-2`
- **Crafting time:** 30 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "speed-module", amount = 4
- **Results:** {type="item", name="speed-module-2", amount=1

### Speed module 3
- **Internal name:** `speed-module-3`
- **Crafting time:** 60 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "speed-module-2", amount = 4
- **Results:** {type="item", name="speed-module-3", amount=1

### Submachine gun
- **Internal name:** `submachine-gun`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-gear-wheel", amount = 10
- **Results:** {type="item", name="submachine-gun", amount=1

### Uranium cannon shell
- **Internal name:** `uranium-cannon-shell`
- **Crafting time:** 12 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "cannon-shell", amount = 1
- **Results:** {type="item", name="uranium-cannon-shell", amount=1

### Uranium fuel cell
- **Internal name:** `uranium-fuel-cell`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-plate", amount = 10
- **Results:** {type="item", name="uranium-fuel-cell", amount=10

### Uranium rounds magazine
- **Internal name:** `uranium-rounds-magazine`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "piercing-rounds-magazine", amount = 1
- **Results:** {type="item", name="uranium-rounds-magazine", amount=1

### Utility science pack
- **Internal name:** `utility-science-pack`
- **Crafting time:** 21 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "low-density-structure", amount = 3
- **Results:** {type="item", name="utility-science-pack", amount=3

### accumulator
- **Internal name:** `accumulator`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-plate", amount = 2
- **Results:** {type="item", name="accumulator", amount=1

### active-provider-chest
- **Internal name:** `active-provider-chest`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-chest", amount = 1
- **Results:** {type="item", name="active-provider-chest", amount=1

### arithmetic-combinator
- **Internal name:** `arithmetic-combinator`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "copper-cable", amount = 5
- **Results:** {type="item", name="arithmetic-combinator", amount=1

### artillery-wagon
- **Internal name:** `artillery-wagon`
- **Crafting time:** 4 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "engine-unit", amount = 64
- **Results:** {type="item", name="artillery-wagon", amount=1

### assembling-machine-1
- **Internal name:** `assembling-machine-1`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "electronic-circuit", amount = 3
- **Results:** {type="item", name="assembling-machine-1", amount=1

### assembling-machine-2
- **Internal name:** `assembling-machine-2`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 2
- **Results:** {type="item", name="assembling-machine-2", amount=1

### assembling-machine-3
- **Internal name:** `assembling-machine-3`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "speed-module", amount = 4
- **Results:** {type="item", name="assembling-machine-3", amount=1

### battery-equipment
- **Internal name:** `battery-equipment`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "battery", amount = 5
- **Results:** {type="item", name="battery-equipment", amount=1

### battery-mk2-equipment
- **Internal name:** `battery-mk2-equipment`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "battery-equipment", amount = 10
- **Results:** {type="item", name="battery-mk2-equipment", amount=1

### beacon
- **Internal name:** `beacon`
- **Crafting time:** 15 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "electronic-circuit", amount = 20
- **Results:** {type="item", name="beacon", amount=1

### big-electric-pole
- **Internal name:** `big-electric-pole`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-stick", amount = 8
- **Results:** {type="item", name="big-electric-pole", amount=1

### boiler
- **Internal name:** `boiler`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "stone-furnace", amount = 1
- **Results:** {type="item", name="boiler", amount=1

### buffer-chest
- **Internal name:** `buffer-chest`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-chest", amount = 1
- **Results:** {type="item", name="buffer-chest", amount=1

### bulk-inserter
- **Internal name:** `bulk-inserter`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-gear-wheel", amount = 15
- **Results:** {type="item", name="bulk-inserter", amount=1

### burner-inserter
- **Internal name:** `burner-inserter`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-plate", amount = 1
- **Results:** {type="item", name="burner-inserter", amount=1

### burner-mining-drill
- **Internal name:** `burner-mining-drill`
- **Crafting time:** 2 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-gear-wheel", amount = 3
- **Results:** {type="item", name="burner-mining-drill", amount=1

### car
- **Internal name:** `car`
- **Crafting time:** 2 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "engine-unit", amount = 8
- **Results:** {type="item", name="car", amount=1

### cargo-landing-pad
- **Internal name:** `cargo-landing-pad`
- **Crafting time:** 30 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "concrete", amount = 200
- **Results:** {type="item", name="cargo-landing-pad", amount=1

### cargo-wagon
- **Internal name:** `cargo-wagon`
- **Crafting time:** 1 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-gear-wheel", amount = 10
- **Results:** {type="item", name="cargo-wagon", amount=1

### centrifuge
- **Internal name:** `centrifuge`
- **Crafting time:** 4 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "concrete", amount = 100
- **Results:** {type="item", name="centrifuge", amount=1

### chemical-plant
- **Internal name:** `chemical-plant`
- **Crafting time:** 5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 5
- **Results:** {type="item", name="chemical-plant", amount=1

### constant-combinator
- **Internal name:** `constant-combinator`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "copper-cable", amount = 5
- **Results:** {type="item", name="constant-combinator", amount=1

### construction-robot
- **Internal name:** `construction-robot`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "flying-robot-frame", amount = 1
- **Results:** {type="item", name="construction-robot", amount=1

### decider-combinator
- **Internal name:** `decider-combinator`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "copper-cable", amount = 5
- **Results:** {type="item", name="decider-combinator", amount=1

### discharge-defense-equipment
- **Internal name:** `discharge-defense-equipment`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "processing-unit", amount = 5
- **Results:** {type="item", name="discharge-defense-equipment", amount=1

### electric-furnace
- **Internal name:** `electric-furnace`
- **Crafting time:** 5 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "steel-plate", amount = 10
- **Results:** {type="item", name="electric-furnace", amount=1

### electric-mining-drill
- **Internal name:** `electric-mining-drill`
- **Crafting time:** 2 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "electronic-circuit", amount = 3
- **Results:** {type="item", name="electric-mining-drill", amount=1

### energy-shield-equipment
- **Internal name:** `energy-shield-equipment`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "advanced-circuit", amount = 5
- **Results:** {type="item", name="energy-shield-equipment", amount=1

### energy-shield-mk2-equipment
- **Internal name:** `energy-shield-mk2-equipment`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "energy-shield-equipment", amount = 10
- **Results:** {type="item", name="energy-shield-mk2-equipment", amount=1

### exoskeleton-equipment
- **Internal name:** `exoskeleton-equipment`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "processing-unit", amount = 10
- **Results:** {type="item", name="exoskeleton-equipment", amount=1

### express-loader
- **Internal name:** `express-loader`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "express-transport-belt", amount = 5
- **Results:** {type="item", name="express-loader", amount=1

### fast-inserter
- **Internal name:** `fast-inserter`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "electronic-circuit", amount = 2
- **Results:** {type="item", name="fast-inserter", amount=1

### fast-loader
- **Internal name:** `fast-loader`
- **Crafting time:** 3 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "fast-transport-belt", amount = 5
- **Results:** {type="item", name="fast-loader", amount=1

### fast-splitter
- **Internal name:** `fast-splitter`
- **Crafting time:** 2 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "splitter", amount = 1
- **Results:** {type="item", name="fast-splitter", amount=1

### fast-transport-belt
- **Internal name:** `fast-transport-belt`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-gear-wheel", amount = 5
- **Results:** {type="item", name="fast-transport-belt", amount=1

### fast-underground-belt
- **Internal name:** `fast-underground-belt`
- **Crafting time:** 2 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-gear-wheel", amount = 40
- **Results:** {type="item", name="fast-underground-belt", amount=2

### fission-reactor-equipment
- **Internal name:** `fission-reactor-equipment`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "processing-unit", amount = 200
- **Results:** {type="item", name="fission-reactor-equipment", amount=1

### fluid-wagon
- **Internal name:** `fluid-wagon`
- **Crafting time:** 1.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-gear-wheel", amount = 10
- **Results:** {type="item", name="fluid-wagon", amount=1

### gate
- **Internal name:** `gate`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "stone-wall", amount = 1
- **Results:** {type="item", name="gate", amount=1

### gun-turret
- **Internal name:** `gun-turret`
- **Crafting time:** 8 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-gear-wheel", amount = 10
- **Results:** {type="item", name="gun-turret", amount=1

### heat-exchanger
- **Internal name:** `heat-exchanger`
- **Crafting time:** 3 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "steel-plate", amount = 10
- **Results:** {type="item", name="heat-exchanger", amount=1

### heat-pipe
- **Internal name:** `heat-pipe`
- **Crafting time:** 1 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "steel-plate", amount = 10
- **Results:** {type="item", name="heat-pipe", amount=1

### inserter
- **Internal name:** `inserter`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "electronic-circuit", amount = 1
- **Results:** {type="item", name="inserter", amount=1

### iron-chest
- **Internal name:** `iron-chest`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** True
- **Ingredients:** {type = "item", name = "iron-plate", amount = 8
- **Results:** {type="item", name="iron-chest", amount=1

### land-mine
- **Internal name:** `land-mine`
- **Crafting time:** 5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 1
- **Results:** {type="item", name="land-mine", amount=4

### loader
- **Internal name:** `loader`
- **Crafting time:** 1 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "inserter", amount = 5
- **Results:** {type="item", name="loader", amount=1

### locomotive
- **Internal name:** `locomotive`
- **Crafting time:** 4 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "engine-unit", amount = 20
- **Results:** {type="item", name="locomotive", amount=1

### logistic-robot
- **Internal name:** `logistic-robot`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "flying-robot-frame", amount = 1
- **Results:** {type="item", name="logistic-robot", amount=1

### long-handed-inserter
- **Internal name:** `long-handed-inserter`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-gear-wheel", amount = 1
- **Results:** {type="item", name="long-handed-inserter", amount=1

### medium-electric-pole
- **Internal name:** `medium-electric-pole`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-stick", amount = 4
- **Results:** {type="item", name="medium-electric-pole", amount=1

### night-vision-equipment
- **Internal name:** `night-vision-equipment`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "advanced-circuit", amount = 5
- **Results:** {type="item", name="night-vision-equipment", amount=1

### nuclear-reactor
- **Internal name:** `nuclear-reactor`
- **Crafting time:** 8 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "concrete", amount = 500
- **Results:** {type="item", name="nuclear-reactor", amount=1

### offshore-pump
- **Internal name:** `offshore-pump`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "pipe", amount = 3
- **Results:** {type="item", name="offshore-pump", amount=1

### oil-refinery
- **Internal name:** `oil-refinery`
- **Crafting time:** 8 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 15
- **Results:** {type="item", name="oil-refinery", amount=1

### passive-provider-chest
- **Internal name:** `passive-provider-chest`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-chest", amount = 1
- **Results:** {type="item", name="passive-provider-chest", amount=1

### personal-laser-defense-equipment
- **Internal name:** `personal-laser-defense-equipment`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "processing-unit", amount = 20
- **Results:** {type="item", name="personal-laser-defense-equipment", amount=1

### personal-roboport-equipment
- **Internal name:** `personal-roboport-equipment`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "advanced-circuit", amount = 10
- **Results:** {type="item", name="personal-roboport-equipment", amount=1

### personal-roboport-mk2-equipment
- **Internal name:** `personal-roboport-mk2-equipment`
- **Crafting time:** 20 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "personal-roboport-equipment", amount = 5
- **Results:** {type="item", name="personal-roboport-mk2-equipment", amount=1

### pipe
- **Internal name:** `pipe`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "iron-plate", amount = 1
- **Results:** {type="item", name="pipe", amount=1

### pipe-to-ground
- **Internal name:** `pipe-to-ground`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "pipe", amount = 10
- **Results:** {type="item", name="pipe-to-ground", amount=2

### power-switch
- **Internal name:** `power-switch`
- **Crafting time:** 2 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-plate", amount = 5
- **Results:** {type="item", name="power-switch", amount=1

### programmable-speaker
- **Internal name:** `programmable-speaker`
- **Crafting time:** 2 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-plate", amount = 3
- **Results:** {type="item", name="programmable-speaker", amount=1

### pump
- **Internal name:** `pump`
- **Crafting time:** 2 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "engine-unit", amount = 1
- **Results:** {type="item", name="pump", amount=1

### pumpjack
- **Internal name:** `pumpjack`
- **Crafting time:** 5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 5
- **Results:** {type="item", name="pumpjack", amount=1

### radar
- **Internal name:** `radar`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "electronic-circuit", amount = 5
- **Results:** {type="item", name="radar", amount=1

### rail-chain-signal
- **Internal name:** `rail-chain-signal`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "electronic-circuit", amount = 1
- **Results:** {type="item", name="rail-chain-signal", amount=1

### rail-signal
- **Internal name:** `rail-signal`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "electronic-circuit", amount = 1
- **Results:** {type="item", name="rail-signal", amount=1

### requester-chest
- **Internal name:** `requester-chest`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-chest", amount = 1
- **Results:** {type="item", name="requester-chest", amount=1

### roboport
- **Internal name:** `roboport`
- **Crafting time:** 5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 45
- **Results:** {type="item", name="roboport", amount=1

### rocket-silo
- **Internal name:** `rocket-silo`
- **Crafting time:** 30 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 1000
- **Results:** {type="item", name="rocket-silo", amount=1

### selector-combinator
- **Internal name:** `selector-combinator`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "advanced-circuit", amount = 2
- **Results:** {type="item", name="selector-combinator", amount=1

### small-electric-pole
- **Internal name:** `small-electric-pole`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "wood", amount = 1
- **Results:** {type="item", name="small-electric-pole", amount=2

### small-lamp
- **Internal name:** `small-lamp`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "electronic-circuit", amount = 1
- **Results:** {type="item", name="small-lamp", amount=1

### solar-panel-equipment
- **Internal name:** `solar-panel-equipment`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "solar-panel", amount = 1
- **Results:** {type="item", name="solar-panel-equipment", amount=1

### spidertron
- **Internal name:** `spidertron`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "exoskeleton-equipment", amount = 4
- **Results:** {type="item", name="spidertron", amount=1

### splitter
- **Internal name:** `splitter`
- **Crafting time:** 1 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "electronic-circuit", amount = 5
- **Results:** {type="item", name="splitter", amount=1

### steam-engine
- **Internal name:** `steam-engine`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-gear-wheel", amount = 8
- **Results:** {type="item", name="steam-engine", amount=1

### steam-turbine
- **Internal name:** `steam-turbine`
- **Crafting time:** 3 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "iron-gear-wheel", amount = 50
- **Results:** {type="item", name="steam-turbine", amount=1

### steel-chest
- **Internal name:** `steel-chest`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "steel-plate", amount = 8
- **Results:** {type="item", name="steel-chest", amount=1

### steel-furnace
- **Internal name:** `steel-furnace`
- **Crafting time:** 3 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "steel-plate", amount = 6
- **Results:** {type="item", name="steel-furnace", amount=1

### stone-furnace
- **Internal name:** `stone-furnace`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "stone", amount = 5
- **Results:** {type="item", name="stone-furnace", amount=1

### stone-wall
- **Internal name:** `stone-wall`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "stone-brick", amount = 5
- **Results:** {type="item", name="stone-wall", amount=1

### storage-chest
- **Internal name:** `storage-chest`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-chest", amount = 1
- **Results:** {type="item", name="storage-chest", amount=1

### storage-tank
- **Internal name:** `storage-tank`
- **Crafting time:** 3 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-plate", amount = 20
- **Results:** {type="item", name="storage-tank", amount=1

### substation
- **Internal name:** `substation`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "steel-plate", amount = 10
- **Results:** {type="item", name="substation", amount=1

### tank
- **Internal name:** `tank`
- **Crafting time:** 5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "engine-unit", amount = 32
- **Results:** {type="item", name="tank", amount=1

### train-stop
- **Internal name:** `train-stop`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "electronic-circuit", amount = 5
- **Results:** {type="item", name="train-stop", amount=1

### transport-belt
- **Internal name:** `transport-belt`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-plate", amount = 1
- **Results:** {type="item", name="transport-belt", amount=2

### underground-belt
- **Internal name:** `underground-belt`
- **Crafting time:** 1 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-plate", amount = 10
- **Results:** {type="item", name="underground-belt", amount=2

### wooden-chest
- **Internal name:** `wooden-chest`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "wood", amount = 2
- **Results:** {type="item", name="wooden-chest", amount=1


## Crafting With Fluid

### Concrete
- **Internal name:** `concrete`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "stone-brick", amount = 5
- **Results:** {type="item", name="concrete", amount=10

### Electric engine unit
- **Internal name:** `electric-engine-unit`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "engine-unit", amount = 1
- **Results:** {type="item", name="electric-engine-unit", amount=1

### Processing unit
- **Internal name:** `processing-unit`
- **Crafting time:** 10 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "electronic-circuit", amount = 20
- **Results:** {type="item", name="processing-unit", amount=1

### Refined concrete
- **Internal name:** `refined-concrete`
- **Crafting time:** 15 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "concrete", amount = 20
- **Results:** {type="item", name="refined-concrete", amount=10

### Rocket fuel
- **Internal name:** `rocket-fuel`
- **Crafting time:** 15 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "solid-fuel", amount = 10
- **Results:** {type="item", name="rocket-fuel", amount=1

### express-splitter
- **Internal name:** `express-splitter`
- **Crafting time:** 2 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "fast-splitter", amount = 1
- **Results:** {type="item", name="express-splitter", amount=1

### express-transport-belt
- **Internal name:** `express-transport-belt`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-gear-wheel", amount = 10
- **Results:** {type="item", name="express-transport-belt", amount=1

### express-underground-belt
- **Internal name:** `express-underground-belt`
- **Crafting time:** 2 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "iron-gear-wheel", amount = 80
- **Results:** {type="item", name="express-underground-belt", amount=2


## Oil Processing

### Basic oil processing
- **Internal name:** `basic-oil-processing`
- **Crafting time:** 5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "fluid", name = "crude-oil", amount = 100, fluidbox_index = 2
- **Results:** 
      {type = "fluid", name = "petroleum-gas", amount = 45, fluidbox_index = 3

### Advanced oil processing
- **Internal name:** `advanced-oil-processing`
- **Crafting time:** 5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "fluid", name = "water", amount = 50
- **Results:** 
      {type = "fluid", name = "heavy-oil", amount = 25

### Coal liquefaction
- **Internal name:** `coal-liquefaction`
- **Crafting time:** 5 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "coal", amount = 10
- **Results:** 
      {type = "fluid", name = "heavy-oil", amount = 90, ignored_by_stats = 25, ignored_by_productivity = 25


## Parameters

### parameter-
- **Internal name:** `parameter-`
- **Crafting time:** 0.5 seconds
- **Enabled from start:** False


## Rocket Building

### Rocket part
- **Internal name:** `rocket-part`
- **Crafting time:** 3 seconds
- **Enabled from start:** False
- **Ingredients:** 
      {type = "item", name = "processing-unit", amount = 10
- **Results:** {type="item", name="rocket-part", amount=1


## Smelting

### Copper plate
- **Internal name:** `copper-plate`
- **Crafting time:** 3.2 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "copper-ore", amount = 1
- **Results:** {type="item", name="copper-plate", amount=1

### Iron plate
- **Internal name:** `iron-plate`
- **Crafting time:** 3.2 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "iron-ore", amount = 1
- **Results:** {type="item", name="iron-plate", amount=1

### Steel plate
- **Internal name:** `steel-plate`
- **Crafting time:** 16 seconds
- **Enabled from start:** False
- **Ingredients:** {type = "item", name = "iron-plate", amount = 5
- **Results:** {type="item", name="steel-plate", amount=1

### Stone brick
- **Internal name:** `stone-brick`
- **Crafting time:** 3.2 seconds
- **Enabled from start:** True
- **Ingredients:** {type = "item", name = "stone", amount = 2
- **Results:** {type="item", name="stone-brick", amount=1

---

## technologies-detailed

# Factorio Technologies - Detailed

Complete technology tree with prerequisites and unlocks.

## Advanced circuit
- **Internal name:** `advanced-circuit`
- **Description:** More advanced integrated circuits.

## Advanced combinators
- **Internal name:** `advanced-combinators`

## Advanced material processing
- **Internal name:** `advanced-material-processing`
- **Description:** Faster and more flexible furnaces.

## Advanced oil processing
- **Internal name:** `advanced-oil-processing`
- **Description:** Crude oil refining with additional products that can be refined further.
- **Prerequisites:**
  - Chemical science pack

## Artillery
- **Internal name:** `artillery`
- **Description:** Long range cannon mounted on a turret or train wagon. Used to automatically fire at distant enemy structures, or can be manually targeted at even longer distances.

## Atomic bomb
- **Internal name:** `atomic-bomb`
- **Description:** Devastating form of rockets used to eradicate anything in huge areas at a time.

## Automated rail transportation
- **Internal name:** `automated-rail-transportation`
- **Description:** Enables building train stops and rail signals to set up automated train routes and coordinating multiple trains within the same rail network.

## Automation
- **Internal name:** `automation`
- **Description:** Key technology for automatic mass production.

## Automation science pack
- **Internal name:** `automation-science-pack`
- **Description:** Allows research of basic automation methods.

## Automobilism
- **Internal name:** `automobilism`
- **Description:** Engine-powered vehicle used for transportation.

## Battery
- **Internal name:** `battery`
- **Description:** Electrochemical cell that stores and provides energy to electrical devices.
- **Prerequisites:**
  - Sulfur processing

## Belt immunity equipment
- **Internal name:** `belt-immunity-equipment`
- **Description:** Inserted into armor to prevent you from being moved by transport belts.
- **Prerequisites:**
  - Portable solar panel

## Bulk inserter
- **Internal name:** `bulk-inserter`
- **Description:** Inserters that can move multiple items of the same type at a time.

## Chemical science pack
- **Internal name:** `chemical-science-pack`
- **Description:** Allows research of advanced items, making use of oil products.

## Circuit network
- **Internal name:** `circuit-network`
- **Description:** Gives you better control over your machines by interconnecting them with wires and making them react to signals.

## Cliff explosives
- **Internal name:** `cliff-explosives`
- **Description:** Barrels filled with enough explosives to tear down cliffs.
- **Prerequisites:**
  - Explosives
  - military-2

## Coal liquefaction
- **Internal name:** `coal-liquefaction`
- **Description:** A processing technique to turn coal into oil products with the use of steam and heavy oil.
- **Prerequisites:**
  - Advanced oil processing
  - Production science pack

## Concrete
- **Internal name:** `concrete`
- **Description:** Advanced building material also used for flooring.
- **Prerequisites:**
  - Advanced material processing
  - automation-2

## Construction robotics
- **Internal name:** `construction-robotics`
- **Description:** Construction robots can repair and build friendly entities. You can also order the robots to build new structures by placing a ghost there.

## Defender
- **Internal name:** `defender`
- **Description:** Most basic type of combat robot. Follows and helps the player for a short time period.

## Destroyer
- **Internal name:** `destroyer`
- **Description:** Most advanced type of combat robot. Follows and helps the player for a limited time period.

## Discharge defense
- **Internal name:** `discharge-defense-equipment`
- **Description:** Inserted into armor to damage, push back, and stun nearby enemies when activated using the remote.
- **Prerequisites:**
  - Laser turret
  - military-3
  - Power armor
  - Portable solar panel

## Distractor
- **Internal name:** `distractor`
- **Description:** Intermediate type of combat robot. Stays on the deployed position to shoot and distract enemies.

## Effect transmission
- **Internal name:** `effect-transmission`
- **Description:** The beacon transmits the effects of upgrade modules to nearby friendly entities. Transmission effects stack with diminishing returns.

## Efficiency module
- **Internal name:** `efficiency-module`
- **Description:** A module that reduces the energy consumption of a machine.

## Electric engine
- **Internal name:** `electric-engine`
- **Description:** Converts electricity into mechanical motion.
- **Prerequisites:**
  - Lubricant

## Electric mining drill
- **Internal name:** `electric-mining-drill`

## Electronics
- **Internal name:** `electronics`
- **Description:** Electronic components for basic signal processing.

## Energy shield MK2 equipment
- **Internal name:** `energy-shield-mk2-equipment`
- **Description:** Inserted into armor to absorb a large amount of damage.
- **Prerequisites:**
  - Energy shield equipment
  - military-3
  - Low density structure
  - Power armor

## Energy shield equipment
- **Internal name:** `energy-shield-equipment`
- **Description:** Inserted into armor to absorb damage.
- **Prerequisites:**
  - Portable solar panel
  - Military science pack

## Engine
- **Internal name:** `engine`
- **Description:** Converts fuel into mechanical motion. An essential part of all vehicles.
- **Prerequisites:**
  - Steel processing
  - Logistic science pack

## Exoskeleton equipment
- **Internal name:** `exoskeleton-equipment`
- **Description:** Inserted into armor to increase movement speed. You can equip multiple exoskeletons at once.
- **Prerequisites:**
  - Processing unit
  - Electric engine
  - Portable solar panel

## Explosive rocketry
- **Internal name:** `explosive-rocketry`
- **Description:** Extremely explosive rockets with a larger explosion radius.

## Explosives
- **Internal name:** `explosives`
- **Description:** Developing dangerous yet controllable explosives.
- **Prerequisites:**
  - Sulfur processing

## Fast inserter
- **Internal name:** `fast-inserter`
- **Description:** Inserters capable of faster motion through improved electronics.

## Flamethrower
- **Internal name:** `flamethrower`
- **Description:** Powerful hand-held and turret flamethrowers firing aggressive liquids at enemies, setting them on fire.

## Flammables
- **Internal name:** `flammables`
- **Description:** Developing more efficient fuel and more aggressive combustibles.
- **Prerequisites:**
  - Oil processing

## Fluid handling
- **Internal name:** `fluid-handling`
- **Description:** Various ways to store and transport fluids.
- **Prerequisites:**
  - automation-2
  - Engine

## Fluid wagon
- **Internal name:** `fluid-wagon`
- **Description:** Ability to transport fluids on rails. Fluid wagons are filled and emptied by pumps adjacent to straight rail segments.

## Gate
- **Internal name:** `gate`

## Gun turret
- **Internal name:** `gun-turret`
- **Description:** Basic defensive buildings that must be refilled with magazines.

## Heavy armor
- **Internal name:** `heavy-armor`
- **Description:** Heavy armor for more protection.

## Kovarex enrichment process
- **Internal name:** `kovarex-enrichment-process`
- **Description:** The process to create uranium-235 from uranium-238. It requires a large amount of uranium-235 as a catalyst.

## Lamp
- **Internal name:** `lamp`
- **Description:** Illumination for better visibility at night.

## Land mines
- **Internal name:** `land-mine`
- **Description:** Explosive traps built on the ground for enemies to walk over and trigger. Can be re-built by construction robots after exploding. Damage can be upgraded by researching stronger explosives.

## Landfill
- **Internal name:** `landfill`
- **Description:** Can be placed on water to create terrain you can build on.
- **Prerequisites:**
  - Logistic science pack

## Laser
- **Internal name:** `laser`
- **Description:** Focused light capable of causing damage.
- **Prerequisites:**
  - Battery
  - Chemical science pack

## Laser turret
- **Internal name:** `laser-turret`
- **Description:** Advanced defensive buildings that only require electricity.

## Logistic robotics
- **Internal name:** `logistic-robotics`
- **Description:** Logistic robots can deliver items to the character, or take unwanted items away.

## Logistic science pack
- **Internal name:** `logistic-science-pack`
- **Description:** Allows research of improved logistics, automation, and simple military.

## Logistic system
- **Internal name:** `logistic-system`
- **Description:** Unlocks additional logistic chests which expands the capabilities of the logistic robots. Requester chests request items from the logistic network. Active provider chests push their contents to be stored or used elsewhere. Buffer chests request specified items to be available for personal logistics and automated construction.

## Logistics
- **Internal name:** `logistics`
- **Description:** Faster and more flexible ways of transportation.

## Low density structure
- **Internal name:** `low-density-structure`
- **Description:** Light yet sturdy material, very useful for spaceships and personal equipment.

## Lubricant
- **Internal name:** `lubricant`
- **Description:** Converting heavy oils into lubricant, used to reduce friction in high-speed machines.
- **Prerequisites:**
  - Advanced oil processing

## Military
- **Internal name:** `military`
- **Description:** More effective means to defend yourself and your factory.

## Military science pack
- **Internal name:** `military-science-pack`
- **Description:** Allows research of further military options.

## Modular armor
- **Internal name:** `modular-armor`
- **Description:** Armor with a small grid for equipment modules that give you unique bonuses. Wearing it also increases your inventory size.

## Modules
- **Internal name:** `modules`
- **Description:** Allows you to research upgrade modules that can be inserted into machines.
- **Prerequisites:**
  - Advanced circuit

## Nightvision equipment
- **Internal name:** `night-vision-equipment`
- **Description:** Inserted into armor to allow you to see better at night.
- **Prerequisites:**
  - Portable solar panel

## Nuclear fuel reprocessing
- **Internal name:** `nuclear-fuel-reprocessing`
- **Description:** The process of reprocessing used uranium fuel cells to create uranium-238.

## Nuclear power
- **Internal name:** `nuclear-power`
- **Description:** Powerful and sophisticated method of power generation using uranium fuel cells.

## Oil gathering
- **Internal name:** `oil-gathering`
- **Description:** Gathering crude oil with pumpjacks.
- **Prerequisites:**
  - Fluid handling

## Oil processing
- **Internal name:** `oil-processing`
- **Description:** Crude oil refining used for manufacturing plastics, sulfur, and fuels.
- **Prerequisites:**
  - Oil gathering

## Personal battery
- **Internal name:** `battery-equipment`
- **Description:** Inserted into armor to store excess energy for later.
- **Prerequisites:**
  - Battery
  - Portable solar panel

## Personal battery MK2
- **Internal name:** `battery-mk2-equipment`
- **Description:** Inserted into armor to store a lot of energy for later.
- **Prerequisites:**
  - Personal battery
  - Low density structure
  - Power armor

## Personal laser defense
- **Internal name:** `personal-laser-defense-equipment`
- **Description:** Inserted into armor to automatically fire at nearby enemies.
- **Prerequisites:**
  - Laser turret
  - military-3
  - Low density structure
  - Power armor
  - Portable solar panel

## Personal roboport
- **Internal name:** `personal-roboport-equipment`
- **Description:** Inserted into armor to allow construction robots to work from your inventory.

## Personal roboport MK2
- **Internal name:** `personal-roboport-mk2-equipment`
- **Description:** Inserted into armor to allow many construction robots to work from your inventory.

## Plastics
- **Internal name:** `plastics`
- **Description:** Synthetic polymeric materials that can be molded into solid objects.
- **Prerequisites:**
  - Oil processing

## Portable fission reactor
- **Internal name:** `fission-reactor-equipment`
- **Description:** Inserted into armor to power other equipment.
- **Prerequisites:**
  - Utility science pack
  - Power armor
  - Military science pack
  - Nuclear power

## Portable solar panel
- **Internal name:** `solar-panel-equipment`
- **Description:** Inserted into armor to power other equipment, but useless at night.
- **Prerequisites:**
  - Modular armor
  - Solar energy

## Power armor
- **Internal name:** `power-armor`
- **Description:** Armor with a large equipment grid and inventory size bonus.

## Power armor MK2
- **Internal name:** `power-armor-mk2`
- **Description:** Armor with a huge equipment grid and inventory size bonus.

## Processing unit
- **Internal name:** `processing-unit`
- **Description:** Microprocessors for advanced computation.
- **Prerequisites:**
  - Chemical science pack

## Production science pack
- **Internal name:** `production-science-pack`
- **Description:** Allows research of more efficient machines and processes.

## Productivity module
- **Internal name:** `productivity-module`
- **Description:** A module that allows a machine to make more products from the same amount of ingredients, but it also increases energy consumption and reduces speed.

## Radar
- **Internal name:** `radar`
- **Description:** Machines to reveal a nearby area and explore further around.

## Railway
- **Internal name:** `railway`
- **Description:** Large-scale transportation over long distances.

## Repair pack
- **Internal name:** `repair-pack`
- **Description:** Tools to repair damaged machines.

## Robotics
- **Internal name:** `robotics`
- **Description:** Bodies of flying robots. Need to be specialized to do either logistic or construction tasks.
- **Prerequisites:**
  - Electric engine
  - Battery

## Rocket fuel
- **Internal name:** `rocket-fuel`
- **Description:** Sophisticated multipurpose fuel.

## Rocket silo
- **Internal name:** `rocket-silo`
- **Description:** Allows you to launch a rocket into space and win the game.

## Rocketry
- **Internal name:** `rocketry`
- **Description:** Personal rocket launcher for harassing enemies with rockets.

## Solar energy
- **Internal name:** `solar-energy`
- **Description:** Source of free electric energy, but useless at night.

## Space science pack
- **Internal name:** `space-science-pack`
- **Description:** Allows sending research rockets into space, and receiving scientific data from them used to produce space science packs.

## Speed module
- **Internal name:** `speed-module`
- **Description:** A module that makes a machine work faster, but it also increases its energy consumption.

## Spidertron
- **Internal name:** `spidertron`
- **Description:** A versatile vehicle capable of traversing rough terrain. It's equipped with fast-firing rocket launchers controlled by manual or automatic targeting. Can be driven manually or using the spidertron remote.

## Steam power
- **Internal name:** `steam-power`

## Steel axe
- **Internal name:** `steel-axe`
- **Description:** Increases your mining speed.

## Steel processing
- **Internal name:** `steel-processing`
- **Description:** Allows you to smelt steel from iron plates.

## Stone wall
- **Internal name:** `stone-wall`
- **Description:** Walls to protect your factory against attackers.

## Sulfur processing
- **Internal name:** `sulfur-processing`
- **Description:** A highly reactive non-metallic chemical used to produce sulfuric acid and explosive items.
- **Prerequisites:**
  - Oil processing

## Tank
- **Internal name:** `tank`
- **Description:** Powerful offensive vehicle capable of mounting various weapons and equipment.

## Toolbelt
- **Internal name:** `toolbelt`
- **Description:** Expands your inventory.
- **Prerequisites:**
  - Logistic science pack

## Uranium ammo
- **Internal name:** `uranium-ammo`
- **Description:** Advanced ammunition from uranium-238 for higher hardness and weight, resulting in massive damage.

## Uranium mining
- **Internal name:** `uranium-mining`
- **Description:** Allows you to use [fluid=sulfuric-acid] in [entity=electric-mining-drill] to mine [entity=uranium-ore]

## Uranium processing
- **Internal name:** `uranium-processing`
- **Description:** Uranium ore is processed in centrifuges into uranium-238, with a chance to result in a richer uranium-235. Both are needed to create uranium fuel cells.

## Utility science pack
- **Internal name:** `utility-science-pack`
- **Description:** Allows research of even more powerful weaponry, personal equipment, and robot coordination.

## advanced-material-processing-2
- **Internal name:** `advanced-material-processing-2`

## artillery-shell-range-1
- **Internal name:** `artillery-shell-range-1`

## artillery-shell-speed-1
- **Internal name:** `artillery-shell-speed-1`

## automation-2
- **Internal name:** `automation-2`
- **Description:** Assembling machines capable of processing fluid ingredients.

## automation-3
- **Internal name:** `automation-3`
- **Description:** Assembling machines capable of processing fluid ingredients, with additional speed and module slots.

## braking-force-1
- **Internal name:** `braking-force-1`

## braking-force-2
- **Internal name:** `braking-force-2`

## braking-force-3
- **Internal name:** `braking-force-3`

## braking-force-4
- **Internal name:** `braking-force-4`

## braking-force-5
- **Internal name:** `braking-force-5`

## braking-force-6
- **Internal name:** `braking-force-6`

## braking-force-7
- **Internal name:** `braking-force-7`

## efficiency-module-2
- **Internal name:** `efficiency-module-2`

## efficiency-module-3
- **Internal name:** `efficiency-module-3`

## electric-energy-accumulators
- **Internal name:** `electric-energy-accumulators`
- **Description:** Buildings that store excess electric energy for later.

## electric-energy-distribution-1
- **Internal name:** `electric-energy-distribution-1`

## electric-energy-distribution-2
- **Internal name:** `electric-energy-distribution-2`

## follower-robot-count-1
- **Internal name:** `follower-robot-count-1`

## follower-robot-count-5
- **Internal name:** `follower-robot-count-5`

## inserter-capacity-bonus-1
- **Internal name:** `inserter-capacity-bonus-1`

## inserter-capacity-bonus-2
- **Internal name:** `inserter-capacity-bonus-2`

## inserter-capacity-bonus-3
- **Internal name:** `inserter-capacity-bonus-3`

## inserter-capacity-bonus-4
- **Internal name:** `inserter-capacity-bonus-4`

## inserter-capacity-bonus-5
- **Internal name:** `inserter-capacity-bonus-5`

## inserter-capacity-bonus-6
- **Internal name:** `inserter-capacity-bonus-6`

## inserter-capacity-bonus-7
- **Internal name:** `inserter-capacity-bonus-7`

## laser-shooting-speed-1
- **Internal name:** `laser-shooting-speed-1`

## laser-shooting-speed-2
- **Internal name:** `laser-shooting-speed-2`

## laser-shooting-speed-3
- **Internal name:** `laser-shooting-speed-3`

## laser-shooting-speed-4
- **Internal name:** `laser-shooting-speed-4`

## laser-shooting-speed-5
- **Internal name:** `laser-shooting-speed-5`

## laser-shooting-speed-6
- **Internal name:** `laser-shooting-speed-6`

## laser-shooting-speed-7
- **Internal name:** `laser-shooting-speed-7`

## laser-weapons-damage-1
- **Internal name:** `laser-weapons-damage-1`

## laser-weapons-damage-2
- **Internal name:** `laser-weapons-damage-2`

## laser-weapons-damage-3
- **Internal name:** `laser-weapons-damage-3`

## laser-weapons-damage-4
- **Internal name:** `laser-weapons-damage-4`

## laser-weapons-damage-5
- **Internal name:** `laser-weapons-damage-5`

## laser-weapons-damage-6
- **Internal name:** `laser-weapons-damage-6`

## laser-weapons-damage-7
- **Internal name:** `laser-weapons-damage-7`

## logistics-2
- **Internal name:** `logistics-2`

## logistics-3
- **Internal name:** `logistics-3`

## military-2
- **Internal name:** `military-2`

## military-3
- **Internal name:** `military-3`

## military-4
- **Internal name:** `military-4`

## mining-productivity-1
- **Internal name:** `mining-productivity-1`

## mining-productivity-2
- **Internal name:** `mining-productivity-2`

## mining-productivity-3
- **Internal name:** `mining-productivity-3`

## mining-productivity-4
- **Internal name:** `mining-productivity-4`

## physical-projectile-damage-1
- **Internal name:** `physical-projectile-damage-1`

## physical-projectile-damage-2
- **Internal name:** `physical-projectile-damage-2`

## physical-projectile-damage-3
- **Internal name:** `physical-projectile-damage-3`

## physical-projectile-damage-4
- **Internal name:** `physical-projectile-damage-4`

## physical-projectile-damage-5
- **Internal name:** `physical-projectile-damage-5`

## physical-projectile-damage-6
- **Internal name:** `physical-projectile-damage-6`

## physical-projectile-damage-7
- **Internal name:** `physical-projectile-damage-7`

## productivity-module-2
- **Internal name:** `productivity-module-2`

## productivity-module-3
- **Internal name:** `productivity-module-3`

## refined-flammables-1
- **Internal name:** `refined-flammables-1`

## refined-flammables-2
- **Internal name:** `refined-flammables-2`

## refined-flammables-3
- **Internal name:** `refined-flammables-3`

## refined-flammables-4
- **Internal name:** `refined-flammables-4`

## refined-flammables-5
- **Internal name:** `refined-flammables-5`

## refined-flammables-6
- **Internal name:** `refined-flammables-6`

## refined-flammables-7
- **Internal name:** `refined-flammables-7`

## research-speed-1
- **Internal name:** `research-speed-1`

## research-speed-2
- **Internal name:** `research-speed-2`

## research-speed-3
- **Internal name:** `research-speed-3`

## research-speed-4
- **Internal name:** `research-speed-4`

## research-speed-5
- **Internal name:** `research-speed-5`

## research-speed-6
- **Internal name:** `research-speed-6`

## speed-module-2
- **Internal name:** `speed-module-2`

## speed-module-3
- **Internal name:** `speed-module-3`

## stronger-explosives-1
- **Internal name:** `stronger-explosives-1`

## stronger-explosives-2
- **Internal name:** `stronger-explosives-2`

## stronger-explosives-3
- **Internal name:** `stronger-explosives-3`

## stronger-explosives-4
- **Internal name:** `stronger-explosives-4`

## stronger-explosives-5
- **Internal name:** `stronger-explosives-5`

## stronger-explosives-6
- **Internal name:** `stronger-explosives-6`

## stronger-explosives-7
- **Internal name:** `stronger-explosives-7`

## weapon-shooting-speed-1
- **Internal name:** `weapon-shooting-speed-1`

## weapon-shooting-speed-2
- **Internal name:** `weapon-shooting-speed-2`

## weapon-shooting-speed-3
- **Internal name:** `weapon-shooting-speed-3`

## weapon-shooting-speed-4
- **Internal name:** `weapon-shooting-speed-4`

## weapon-shooting-speed-5
- **Internal name:** `weapon-shooting-speed-5`

## weapon-shooting-speed-6
- **Internal name:** `weapon-shooting-speed-6`

## worker-robots-speed-1
- **Internal name:** `worker-robots-speed-1`

## worker-robots-speed-2
- **Internal name:** `worker-robots-speed-2`

## worker-robots-speed-3
- **Internal name:** `worker-robots-speed-3`

## worker-robots-speed-4
- **Internal name:** `worker-robots-speed-4`

## worker-robots-speed-5
- **Internal name:** `worker-robots-speed-5`

## worker-robots-speed-6
- **Internal name:** `worker-robots-speed-6`

## worker-robots-storage-1
- **Internal name:** `worker-robots-storage-1`

## worker-robots-storage-2
- **Internal name:** `worker-robots-storage-2`

## worker-robots-storage-3
- **Internal name:** `worker-robots-storage-3`

---

## technologies

# Factorio Technologies

This document lists all research technologies available in Factorio.

## Advanced circuit
- **Internal name:** `advanced-circuit`
- **Description:** More advanced integrated circuits.
- **Unlocks recipes:** advanced-circuit

## Advanced combinators
- **Internal name:** `advanced-combinators`
- **Unlocks recipes:** selector-combinator

## Advanced material processing
- **Internal name:** `advanced-material-processing`
- **Description:** Faster and more flexible furnaces.
- **Unlocks recipes:** steel-furnace

## Advanced oil processing
- **Internal name:** `advanced-oil-processing`
- **Description:** Crude oil refining with additional products that can be refined further.
- **Unlocks recipes:** advanced-oil-processing

## Artillery
- **Internal name:** `artillery`
- **Description:** Long range cannon mounted on a turret or train wagon. Used to automatically fire at distant enemy structures, or can be manually targeted at even longer distances.
- **Unlocks recipes:** artillery-wagon

## Atomic bomb
- **Internal name:** `atomic-bomb`
- **Description:** Devastating form of rockets used to eradicate anything in huge areas at a time.
- **Unlocks recipes:** atomic-bomb

## Automated rail transportation
- **Internal name:** `automated-rail-transportation`
- **Description:** Enables building train stops and rail signals to set up automated train routes and coordinating multiple trains within the same rail network.
- **Unlocks recipes:** train-stop

## Automation
- **Internal name:** `automation`
- **Description:** Key technology for automatic mass production.
- **Unlocks recipes:** assembling-machine-1

## Automation science pack
- **Internal name:** `automation-science-pack`
- **Description:** Allows research of basic automation methods.
- **Unlocks recipes:** automation-science-pack

## Automobilism
- **Internal name:** `automobilism`
- **Description:** Engine-powered vehicle used for transportation.
- **Unlocks recipes:** car

## Battery
- **Internal name:** `battery`
- **Description:** Electrochemical cell that stores and provides energy to electrical devices.
- **Unlocks recipes:** battery

## Belt immunity equipment
- **Internal name:** `belt-immunity-equipment`
- **Description:** Inserted into armor to prevent you from being moved by transport belts.
- **Unlocks recipes:** belt-immunity-equipment

## Bulk inserter
- **Internal name:** `bulk-inserter`
- **Description:** Inserters that can move multiple items of the same type at a time.
- **Unlocks recipes:** bulk-inserter

## Chemical science pack
- **Internal name:** `chemical-science-pack`
- **Description:** Allows research of advanced items, making use of oil products.
- **Unlocks recipes:** chemical-science-pack

## Circuit network
- **Internal name:** `circuit-network`
- **Description:** Gives you better control over your machines by interconnecting them with wires and making them react to signals.

## Cliff explosives
- **Internal name:** `cliff-explosives`
- **Description:** Barrels filled with enough explosives to tear down cliffs.
- **Unlocks recipes:** cliff-explosives

## Coal liquefaction
- **Internal name:** `coal-liquefaction`
- **Description:** A processing technique to turn coal into oil products with the use of steam and heavy oil.
- **Unlocks recipes:** coal-liquefaction

## Concrete
- **Internal name:** `concrete`
- **Description:** Advanced building material also used for flooring.
- **Unlocks recipes:** concrete

## Construction robotics
- **Internal name:** `construction-robotics`
- **Description:** Construction robots can repair and build friendly entities. You can also order the robots to build new structures by placing a ghost there.
- **Unlocks recipes:** roboport

## Defender
- **Internal name:** `defender`
- **Description:** Most basic type of combat robot. Follows and helps the player for a short time period.
- **Unlocks recipes:** defender-capsule

## Destroyer
- **Internal name:** `destroyer`
- **Description:** Most advanced type of combat robot. Follows and helps the player for a limited time period.
- **Unlocks recipes:** destroyer-capsule

## Discharge defense
- **Internal name:** `discharge-defense-equipment`
- **Description:** Inserted into armor to damage, push back, and stun nearby enemies when activated using the remote.
- **Unlocks recipes:** discharge-defense-equipment

## Distractor
- **Internal name:** `distractor`
- **Description:** Intermediate type of combat robot. Stays on the deployed position to shoot and distract enemies.
- **Unlocks recipes:** distractor-capsule

## Effect transmission
- **Internal name:** `effect-transmission`
- **Description:** The beacon transmits the effects of upgrade modules to nearby friendly entities. Transmission effects stack with diminishing returns.
- **Unlocks recipes:** beacon

## Efficiency module
- **Internal name:** `efficiency-module`
- **Description:** A module that reduces the energy consumption of a machine.
- **Unlocks recipes:** efficiency-module

## Electric engine
- **Internal name:** `electric-engine`
- **Description:** Converts electricity into mechanical motion.
- **Unlocks recipes:** electric-engine-unit

## Electric mining drill
- **Internal name:** `electric-mining-drill`
- **Unlocks recipes:** electric-mining-drill

## Electronics
- **Internal name:** `electronics`
- **Description:** Electronic components for basic signal processing.
- **Unlocks recipes:** copper-cable

## Energy shield MK2 equipment
- **Internal name:** `energy-shield-mk2-equipment`
- **Description:** Inserted into armor to absorb a large amount of damage.
- **Unlocks recipes:** energy-shield-mk2-equipment

## Energy shield equipment
- **Internal name:** `energy-shield-equipment`
- **Description:** Inserted into armor to absorb damage.
- **Unlocks recipes:** energy-shield-equipment

## Engine
- **Internal name:** `engine`
- **Description:** Converts fuel into mechanical motion. An essential part of all vehicles.
- **Unlocks recipes:** engine-unit

## Exoskeleton equipment
- **Internal name:** `exoskeleton-equipment`
- **Description:** Inserted into armor to increase movement speed. You can equip multiple exoskeletons at once.
- **Unlocks recipes:** exoskeleton-equipment

## Explosive rocketry
- **Internal name:** `explosive-rocketry`
- **Description:** Extremely explosive rockets with a larger explosion radius.
- **Unlocks recipes:** explosive-rocket

## Explosives
- **Internal name:** `explosives`
- **Description:** Developing dangerous yet controllable explosives.
- **Unlocks recipes:** explosives

## Fast inserter
- **Internal name:** `fast-inserter`
- **Description:** Inserters capable of faster motion through improved electronics.
- **Unlocks recipes:** fast-inserter

## Flamethrower
- **Internal name:** `flamethrower`
- **Description:** Powerful hand-held and turret flamethrowers firing aggressive liquids at enemies, setting them on fire.
- **Unlocks recipes:** flamethrower

## Flammables
- **Internal name:** `flammables`
- **Description:** Developing more efficient fuel and more aggressive combustibles.

## Fluid handling
- **Internal name:** `fluid-handling`
- **Description:** Various ways to store and transport fluids.
- **Unlocks recipes:** storage-tank

## Fluid wagon
- **Internal name:** `fluid-wagon`
- **Description:** Ability to transport fluids on rails. Fluid wagons are filled and emptied by pumps adjacent to straight rail segments.
- **Unlocks recipes:** fluid-wagon

## Gate
- **Internal name:** `gate`
- **Unlocks recipes:** gate

## Gun turret
- **Internal name:** `gun-turret`
- **Description:** Basic defensive buildings that must be refilled with magazines.
- **Unlocks recipes:** gun-turret

## Heavy armor
- **Internal name:** `heavy-armor`
- **Description:** Heavy armor for more protection.
- **Unlocks recipes:** heavy-armor

## Kovarex enrichment process
- **Internal name:** `kovarex-enrichment-process`
- **Description:** The process to create uranium-235 from uranium-238. It requires a large amount of uranium-235 as a catalyst.
- **Unlocks recipes:** kovarex-enrichment-process

## Lamp
- **Internal name:** `lamp`
- **Description:** Illumination for better visibility at night.
- **Unlocks recipes:** small-lamp

## Land mines
- **Internal name:** `land-mine`
- **Description:** Explosive traps built on the ground for enemies to walk over and trigger. Can be re-built by construction robots after exploding. Damage can be upgraded by researching stronger explosives.
- **Unlocks recipes:** land-mine

## Landfill
- **Internal name:** `landfill`
- **Description:** Can be placed on water to create terrain you can build on.
- **Unlocks recipes:** landfill

## Laser
- **Internal name:** `laser`
- **Description:** Focused light capable of causing damage.

## Laser turret
- **Internal name:** `laser-turret`
- **Description:** Advanced defensive buildings that only require electricity.
- **Unlocks recipes:** laser-turret

## Logistic robotics
- **Internal name:** `logistic-robotics`
- **Description:** Logistic robots can deliver items to the character, or take unwanted items away.
- **Unlocks recipes:** roboport

## Logistic science pack
- **Internal name:** `logistic-science-pack`
- **Description:** Allows research of improved logistics, automation, and simple military.
- **Unlocks recipes:** logistic-science-pack

## Logistic system
- **Internal name:** `logistic-system`
- **Description:** Unlocks additional logistic chests which expands the capabilities of the logistic robots. Requester chests request items from the logistic network. Active provider chests push their contents to be stored or used elsewhere. Buffer chests request specified items to be available for personal logistics and automated construction.
- **Unlocks recipes:** active-provider-chest

## Logistics
- **Internal name:** `logistics`
- **Description:** Faster and more flexible ways of transportation.
- **Unlocks recipes:** underground-belt

## Low density structure
- **Internal name:** `low-density-structure`
- **Description:** Light yet sturdy material, very useful for spaceships and personal equipment.
- **Unlocks recipes:** low-density-structure

## Lubricant
- **Internal name:** `lubricant`
- **Description:** Converting heavy oils into lubricant, used to reduce friction in high-speed machines.
- **Unlocks recipes:** lubricant

## Military
- **Internal name:** `military`
- **Description:** More effective means to defend yourself and your factory.
- **Unlocks recipes:** submachine-gun

## Military science pack
- **Internal name:** `military-science-pack`
- **Description:** Allows research of further military options.
- **Unlocks recipes:** military-science-pack

## Modular armor
- **Internal name:** `modular-armor`
- **Description:** Armor with a small grid for equipment modules that give you unique bonuses. Wearing it also increases your inventory size.
- **Unlocks recipes:** modular-armor

## Modules
- **Internal name:** `modules`
- **Description:** Allows you to research upgrade modules that can be inserted into machines.

## Nightvision equipment
- **Internal name:** `night-vision-equipment`
- **Description:** Inserted into armor to allow you to see better at night.
- **Unlocks recipes:** night-vision-equipment

## Nuclear fuel reprocessing
- **Internal name:** `nuclear-fuel-reprocessing`
- **Description:** The process of reprocessing used uranium fuel cells to create uranium-238.
- **Unlocks recipes:** nuclear-fuel-reprocessing

## Nuclear power
- **Internal name:** `nuclear-power`
- **Description:** Powerful and sophisticated method of power generation using uranium fuel cells.
- **Unlocks recipes:** nuclear-reactor

## Oil gathering
- **Internal name:** `oil-gathering`
- **Description:** Gathering crude oil with pumpjacks.
- **Unlocks recipes:** pumpjack

## Oil processing
- **Internal name:** `oil-processing`
- **Description:** Crude oil refining used for manufacturing plastics, sulfur, and fuels.
- **Unlocks recipes:** oil-refinery

## Personal battery
- **Internal name:** `battery-equipment`
- **Description:** Inserted into armor to store excess energy for later.
- **Unlocks recipes:** battery-equipment

## Personal battery MK2
- **Internal name:** `battery-mk2-equipment`
- **Description:** Inserted into armor to store a lot of energy for later.
- **Unlocks recipes:** battery-mk2-equipment

## Personal laser defense
- **Internal name:** `personal-laser-defense-equipment`
- **Description:** Inserted into armor to automatically fire at nearby enemies.
- **Unlocks recipes:** personal-laser-defense-equipment

## Personal roboport
- **Internal name:** `personal-roboport-equipment`
- **Description:** Inserted into armor to allow construction robots to work from your inventory.
- **Unlocks recipes:** personal-roboport-equipment

## Personal roboport MK2
- **Internal name:** `personal-roboport-mk2-equipment`
- **Description:** Inserted into armor to allow many construction robots to work from your inventory.
- **Unlocks recipes:** personal-roboport-mk2-equipment

## Plastics
- **Internal name:** `plastics`
- **Description:** Synthetic polymeric materials that can be molded into solid objects.
- **Unlocks recipes:** plastic-bar

## Portable fission reactor
- **Internal name:** `fission-reactor-equipment`
- **Description:** Inserted into armor to power other equipment.
- **Unlocks recipes:** fission-reactor-equipment

## Portable solar panel
- **Internal name:** `solar-panel-equipment`
- **Description:** Inserted into armor to power other equipment, but useless at night.
- **Unlocks recipes:** solar-panel-equipment

## Power armor
- **Internal name:** `power-armor`
- **Description:** Armor with a large equipment grid and inventory size bonus.
- **Unlocks recipes:** power-armor

## Power armor MK2
- **Internal name:** `power-armor-mk2`
- **Description:** Armor with a huge equipment grid and inventory size bonus.
- **Unlocks recipes:** power-armor-mk2

## Processing unit
- **Internal name:** `processing-unit`
- **Description:** Microprocessors for advanced computation.
- **Unlocks recipes:** processing-unit

## Production science pack
- **Internal name:** `production-science-pack`
- **Description:** Allows research of more efficient machines and processes.
- **Unlocks recipes:** production-science-pack

## Productivity module
- **Internal name:** `productivity-module`
- **Description:** A module that allows a machine to make more products from the same amount of ingredients, but it also increases energy consumption and reduces speed.
- **Unlocks recipes:** productivity-module

## Radar
- **Internal name:** `radar`
- **Description:** Machines to reveal a nearby area and explore further around.
- **Unlocks recipes:** radar

## Railway
- **Internal name:** `railway`
- **Description:** Large-scale transportation over long distances.
- **Unlocks recipes:** rail

## Repair pack
- **Internal name:** `repair-pack`
- **Description:** Tools to repair damaged machines.
- **Unlocks recipes:** repair-pack

## Robotics
- **Internal name:** `robotics`
- **Description:** Bodies of flying robots. Need to be specialized to do either logistic or construction tasks.
- **Unlocks recipes:** flying-robot-frame

## Rocket fuel
- **Internal name:** `rocket-fuel`
- **Description:** Sophisticated multipurpose fuel.
- **Unlocks recipes:** rocket-fuel

## Rocket silo
- **Internal name:** `rocket-silo`
- **Description:** Allows you to launch a rocket into space and win the game.
- **Unlocks recipes:** rocket-silo

## Rocketry
- **Internal name:** `rocketry`
- **Description:** Personal rocket launcher for harassing enemies with rockets.
- **Unlocks recipes:** rocket-launcher

## Solar energy
- **Internal name:** `solar-energy`
- **Description:** Source of free electric energy, but useless at night.
- **Unlocks recipes:** solar-panel

## Space science pack
- **Internal name:** `space-science-pack`
- **Description:** Allows sending research rockets into space, and receiving scientific data from them used to produce space science packs.

## Speed module
- **Internal name:** `speed-module`
- **Description:** A module that makes a machine work faster, but it also increases its energy consumption.
- **Unlocks recipes:** speed-module

## Spidertron
- **Internal name:** `spidertron`
- **Description:** A versatile vehicle capable of traversing rough terrain. It's equipped with fast-firing rocket launchers controlled by manual or automatic targeting. Can be driven manually or using the spidertron remote.
- **Unlocks recipes:** spidertron

## Steam power
- **Internal name:** `steam-power`
- **Unlocks recipes:** pipe

## Steel axe
- **Internal name:** `steel-axe`
- **Description:** Increases your mining speed.

## Steel processing
- **Internal name:** `steel-processing`
- **Description:** Allows you to smelt steel from iron plates.
- **Unlocks recipes:** steel-plate

## Stone wall
- **Internal name:** `stone-wall`
- **Description:** Walls to protect your factory against attackers.
- **Unlocks recipes:** stone-wall

## Sulfur processing
- **Internal name:** `sulfur-processing`
- **Description:** A highly reactive non-metallic chemical used to produce sulfuric acid and explosive items.
- **Unlocks recipes:** sulfuric-acid

## Tank
- **Internal name:** `tank`
- **Description:** Powerful offensive vehicle capable of mounting various weapons and equipment.
- **Unlocks recipes:** tank

## Toolbelt
- **Internal name:** `toolbelt`
- **Description:** Expands your inventory.

## Uranium ammo
- **Internal name:** `uranium-ammo`
- **Description:** Advanced ammunition from uranium-238 for higher hardness and weight, resulting in massive damage.
- **Unlocks recipes:** uranium-rounds-magazine

## Uranium mining
- **Internal name:** `uranium-mining`
- **Description:** Allows you to use [fluid=sulfuric-acid] in [entity=electric-mining-drill] to mine [entity=uranium-ore]

## Uranium processing
- **Internal name:** `uranium-processing`
- **Description:** Uranium ore is processed in centrifuges into uranium-238, with a chance to result in a richer uranium-235. Both are needed to create uranium fuel cells.
- **Unlocks recipes:** centrifuge

## Utility science pack
- **Internal name:** `utility-science-pack`
- **Description:** Allows research of even more powerful weaponry, personal equipment, and robot coordination.
- **Unlocks recipes:** utility-science-pack

## advanced-material-processing-2
- **Internal name:** `advanced-material-processing-2`
- **Unlocks recipes:** electric-furnace

## artillery-shell-range-1
- **Internal name:** `artillery-shell-range-1`

## artillery-shell-speed-1
- **Internal name:** `artillery-shell-speed-1`

## automation-2
- **Internal name:** `automation-2`
- **Description:** Assembling machines capable of processing fluid ingredients.
- **Unlocks recipes:** assembling-machine-2

## automation-3
- **Internal name:** `automation-3`
- **Description:** Assembling machines capable of processing fluid ingredients, with additional speed and module slots.
- **Unlocks recipes:** assembling-machine-3

## braking-force-1
- **Internal name:** `braking-force-1`

## braking-force-2
- **Internal name:** `braking-force-2`

## braking-force-3
- **Internal name:** `braking-force-3`

## braking-force-4
- **Internal name:** `braking-force-4`

## braking-force-5
- **Internal name:** `braking-force-5`

## braking-force-6
- **Internal name:** `braking-force-6`

## braking-force-7
- **Internal name:** `braking-force-7`

## efficiency-module-2
- **Internal name:** `efficiency-module-2`
- **Unlocks recipes:** efficiency-module-2

## efficiency-module-3
- **Internal name:** `efficiency-module-3`
- **Unlocks recipes:** efficiency-module-3

## electric-energy-accumulators
- **Internal name:** `electric-energy-accumulators`
- **Description:** Buildings that store excess electric energy for later.
- **Unlocks recipes:** accumulator

## electric-energy-distribution-1
- **Internal name:** `electric-energy-distribution-1`
- **Unlocks recipes:** medium-electric-pole

## electric-energy-distribution-2
- **Internal name:** `electric-energy-distribution-2`
- **Unlocks recipes:** substation

## follower-robot-count-5
- **Internal name:** `follower-robot-count-5`

## inserter-capacity-bonus-1
- **Internal name:** `inserter-capacity-bonus-1`

## inserter-capacity-bonus-2
- **Internal name:** `inserter-capacity-bonus-2`

## inserter-capacity-bonus-3
- **Internal name:** `inserter-capacity-bonus-3`

## inserter-capacity-bonus-4
- **Internal name:** `inserter-capacity-bonus-4`

## inserter-capacity-bonus-5
- **Internal name:** `inserter-capacity-bonus-5`

## inserter-capacity-bonus-6
- **Internal name:** `inserter-capacity-bonus-6`

## inserter-capacity-bonus-7
- **Internal name:** `inserter-capacity-bonus-7`

## laser-shooting-speed-1
- **Internal name:** `laser-shooting-speed-1`

## laser-shooting-speed-2
- **Internal name:** `laser-shooting-speed-2`

## laser-shooting-speed-3
- **Internal name:** `laser-shooting-speed-3`

## laser-shooting-speed-4
- **Internal name:** `laser-shooting-speed-4`

## laser-shooting-speed-5
- **Internal name:** `laser-shooting-speed-5`

## laser-shooting-speed-6
- **Internal name:** `laser-shooting-speed-6`

## laser-shooting-speed-7
- **Internal name:** `laser-shooting-speed-7`

## laser-weapons-damage-1
- **Internal name:** `laser-weapons-damage-1`

## laser-weapons-damage-2
- **Internal name:** `laser-weapons-damage-2`

## laser-weapons-damage-3
- **Internal name:** `laser-weapons-damage-3`

## laser-weapons-damage-4
- **Internal name:** `laser-weapons-damage-4`

## laser-weapons-damage-5
- **Internal name:** `laser-weapons-damage-5`

## laser-weapons-damage-6
- **Internal name:** `laser-weapons-damage-6`

## laser-weapons-damage-7
- **Internal name:** `laser-weapons-damage-7`

## logistics-2
- **Internal name:** `logistics-2`
- **Unlocks recipes:** fast-transport-belt

## logistics-3
- **Internal name:** `logistics-3`
- **Unlocks recipes:** express-transport-belt

## military-2
- **Internal name:** `military-2`
- **Unlocks recipes:** piercing-rounds-magazine

## military-3
- **Internal name:** `military-3`
- **Unlocks recipes:** poison-capsule

## military-4
- **Internal name:** `military-4`
- **Unlocks recipes:** piercing-shotgun-shell

## mining-productivity-1
- **Internal name:** `mining-productivity-1`

## mining-productivity-2
- **Internal name:** `mining-productivity-2`

## mining-productivity-3
- **Internal name:** `mining-productivity-3`

## mining-productivity-4
- **Internal name:** `mining-productivity-4`

## physical-projectile-damage-1
- **Internal name:** `physical-projectile-damage-1`

## physical-projectile-damage-2
- **Internal name:** `physical-projectile-damage-2`

## physical-projectile-damage-3
- **Internal name:** `physical-projectile-damage-3`

## physical-projectile-damage-4
- **Internal name:** `physical-projectile-damage-4`

## physical-projectile-damage-5
- **Internal name:** `physical-projectile-damage-5`

## physical-projectile-damage-6
- **Internal name:** `physical-projectile-damage-6`

## physical-projectile-damage-7
- **Internal name:** `physical-projectile-damage-7`

## productivity-module-2
- **Internal name:** `productivity-module-2`
- **Unlocks recipes:** productivity-module-2

## productivity-module-3
- **Internal name:** `productivity-module-3`
- **Unlocks recipes:** productivity-module-3

## refined-flammables-1
- **Internal name:** `refined-flammables-1`

## refined-flammables-2
- **Internal name:** `refined-flammables-2`

## refined-flammables-3
- **Internal name:** `refined-flammables-3`

## refined-flammables-4
- **Internal name:** `refined-flammables-4`

## refined-flammables-5
- **Internal name:** `refined-flammables-5`

## refined-flammables-6
- **Internal name:** `refined-flammables-6`

## refined-flammables-7
- **Internal name:** `refined-flammables-7`

## research-speed-1
- **Internal name:** `research-speed-1`

## research-speed-2
- **Internal name:** `research-speed-2`

## research-speed-3
- **Internal name:** `research-speed-3`

## research-speed-4
- **Internal name:** `research-speed-4`

## research-speed-5
- **Internal name:** `research-speed-5`

## research-speed-6
- **Internal name:** `research-speed-6`

## speed-module-2
- **Internal name:** `speed-module-2`
- **Unlocks recipes:** speed-module-2

## speed-module-3
- **Internal name:** `speed-module-3`
- **Unlocks recipes:** speed-module-3

## stronger-explosives-1
- **Internal name:** `stronger-explosives-1`

## stronger-explosives-2
- **Internal name:** `stronger-explosives-2`

## stronger-explosives-3
- **Internal name:** `stronger-explosives-3`

## stronger-explosives-4
- **Internal name:** `stronger-explosives-4`

## stronger-explosives-5
- **Internal name:** `stronger-explosives-5`

## stronger-explosives-6
- **Internal name:** `stronger-explosives-6`

## stronger-explosives-7
- **Internal name:** `stronger-explosives-7`

## weapon-shooting-speed-1
- **Internal name:** `weapon-shooting-speed-1`

## weapon-shooting-speed-2
- **Internal name:** `weapon-shooting-speed-2`

## weapon-shooting-speed-3
- **Internal name:** `weapon-shooting-speed-3`

## weapon-shooting-speed-4
- **Internal name:** `weapon-shooting-speed-4`

## weapon-shooting-speed-5
- **Internal name:** `weapon-shooting-speed-5`

## weapon-shooting-speed-6
- **Internal name:** `weapon-shooting-speed-6`

## worker-robots-speed-1
- **Internal name:** `worker-robots-speed-1`

## worker-robots-speed-2
- **Internal name:** `worker-robots-speed-2`

## worker-robots-speed-3
- **Internal name:** `worker-robots-speed-3`

## worker-robots-speed-4
- **Internal name:** `worker-robots-speed-4`

## worker-robots-speed-5
- **Internal name:** `worker-robots-speed-5`

## worker-robots-speed-6
- **Internal name:** `worker-robots-speed-6`

## worker-robots-storage-1
- **Internal name:** `worker-robots-storage-1`

## worker-robots-storage-2
- **Internal name:** `worker-robots-storage-2`

## worker-robots-storage-3
- **Internal name:** `worker-robots-storage-3`

---

## tips-and-tricks-complete

# Factorio Tips and Tricks - Complete Guide

This guide contains all tips and tricks from the game, organized by category.

## Table of Contents

- [general](#general)

---

## general

### Active provider chest

[entity=active-provider-chest] actively tries to push its items to the logistic network.
If there are no requests for an item in an active provider chest, they will be moved to [entity=storage-chest].

### Additional info (Alt-mode)

Press [`show-info`] to toggle the detailed info overlay, also known as "Alt-mode".

### Automatic obstacle traversing

Dragging [entity=transport-belt] over an obstacle will automatically build [entity=underground-belt] transition when possible.

### Belt lanes

[entity=transport-belt] have two lanes that can be used to transport items and they can be used for different resources.
[entity=inserter] can pick up items from both lanes, but put items only on the far lane.

### Buffer chest

[entity=buffer-chest] acts as both a [entity=requester-chest] and [entity=passive-provider-chest].
They provide items for construction jobs, personal logistics, and requester chests with 'Request from buffer chests' enabled.

### Build by dragging

The quickest way to build in a straight line, such as a setup of [entity=stone-furnace], is to press [`build`] and hold while running in the desired direction.

### Bulk crafting

When hovering a crafting slot:
 - __ALT_CONTROL__1__craft-5__ to craft 5.
 - __ALT_CONTROL__1__craft-all__ to craft as much as possible.

### Burner inserter refueling

[entity=burner-inserter] can be refueled by other inserters, but they can also refuel themselves when working with fuel.

### Circuit network

The circuit network is a system that allows transfer of information between machines.
You can connect machines to the circuit network using [shortcut=give-red-wire] and [shortcut=give-green-wire].
The network can carry integer values of -2³¹(-2,147,483,648) .. 2³¹(2,147,483,647) individually for each signal type.
It is not required to use the circuit network to finish the game, but allows a lot of fun contraptions or fine tuned factory optimizations that wouldn't be possible without it.

### Clear cursor

When holding an item, you can clear it using [`clear-cursor`], which will return it to the [img=utility/hand] slot in the source inventory.
It also cancels rail planning, wire dragging and selection boxes.

### Construction robots

[entity=construction-robot] fulfills construction, deconstruction, upgrade and repair orders from the logistic network.
Construction orders are created by ghost building, [item=blueprint] usage, or when a friendly building is destroyed and needs to be rebuilt.
Deconstruction orders are created by selecting the desired entities by [item=deconstruction-planner].
Upgrade orders are created by the usage of [item=upgrade-planner].
These orders are also created when using the undo feature.

### Copy paste

The copy tool ([`copy`]) allows you to save selection to clipboard.
The paste tool ([`paste`]) retrieves the last copied selection to be built.
[`cycle-clipboard-forwards`] and [`cycle-clipboard-backwards`] allows you to scroll through the clipboard history.

### Copy-paste entity settings

[`copy-entity-settings`] and [`paste-entity-settings`] allows you to copy settings between entities.
For instance, you can copy-paste between [entity=assembling-machine-2] to set the recipe, or between chests to set the inventory limit.
__ALT_CONTROL__1__paste-entity-settings__ and drag can paste to multiple entities with a single stroke.

### Copy-paste entity settings

[`copy-entity-settings`] and [`paste-entity-settings`] allows you to copy settings between entities.
For instance, you can copy-paste between [entity=assembling-machine-2] to set the recipe, or between chests to set the inventory limit.
Hold down [`paste-entity-settings`] and move using [`move`] to quickly paste to multiple entities.

### Copy-paste filters

You can copy-paste between entities with configurable filters, requests, or filtered inventory slots, such as [entity=fast-inserter], [entity=splitter], [entity=requester-chest] or [entity=cargo-wagon].

### Copy-paste requester chest

You can copy-paste between [entity=requester-chest] to copy the logistic requests.
You can also copy-paste from an [entity=assembling-machine-2] to a [entity=requester-chest] to set the logistic request based on the recipe.

### Copy-paste spidertron

Copy-pasting between [entity=spidertron] will copy the color and logistic requests.
It will also try to copy the equipment grid, inserting the equipment from the player inventory if the items are available.

### Copy-paste trains

You can copy-paste between [entity=locomotive] to copy schedule and color.
You can copy-paste between [entity=train-stop] to copy the stop name and color.
Lastly you can copy-paste between [entity=locomotive] and [entity=train-stop] either way to copy the color.

### Dragging electric poles

If you build [entity=small-electric-pole] by dragging, it will automatically be built at the maximum connection distance.

### Dragging underground belts

If you build [entity=underground-belt] or [entity=pipe-to-ground] by dragging, it will automatically be built at the maximum connection distance.

### Electric network

Electric networks transfer energy from the producers like [entity=steam-engine] or [entity=solar-panel] to the consumers evenly.
__ALT_CONTROL__1__open-gui__ on an electric pole to show the statistics of its electric network.

### Electric pole connections

Electric poles will automatically connect to other electric poles within their 'wire reach'.
Connections can be manually added or removed using [shortcut=give-copper-wire].
All electric pole connections can be removed using [`remove-pole-cables`] on an electric pole.

### Entity pipette

Use [`pipette`] to put the selected entity in your cursor.
When used in remote view, a ghost of the selected entity will be put in your cursor instead.

### Entity transfers

__ALT_CONTROL__1__fast-entity-transfer__ on an entity to take items from it.
__ALT_CONTROL__1__fast-entity-transfer__ while holding an item to put it into the selected entity.


The tutorial teaches you different ways of transferring items to and from entities without opening them.

### Fast belt bending

Pressing [`rotate`] while dragging [entity=transport-belt] allows you to make seamless bends quickly.

### Fast replace

Building over an entity of the same type and size will perform a fast replace. Fast replacing will preserve properties of the original entity, such as the inventory contents and selected recipe.

### Fast replace belt & splitter

You can fast replace [entity=transport-belt] with [entity=splitter] and vice versa.

### Fast replace belt & underground belt

You can fast replace [entity=transport-belt] with [entity=underground-belt] and vice versa.
Any belts in between the entrance and exit of the underground belt will be mined automatically.
This fast replace feature also applies to [entity=pipe] and [entity=pipe-to-ground].

### Fast replace direction

You can use fast replace to quickly change the direction of entities.

### Gate over rail

[entity=gate] can be built over any vertical or horizontal [entity=straight-rail].
Trains will automatically open the gate to pass, and will not leave a hole in your defenses.

### Ghost building

__ALT_CONTROL__1__build-ghost__ while holding a buildable item to build it as an entity ghost.
Entity ghosts will be automatically built by any logistic networks in range.

### Ghost rail planner

The ghost rail planner is used to plan long stretches of new rail ghosts.
To use the ghost planner, hold __CONTROL_MODIFIER__build-ghost__ while rail planning.
You can also hold __CONTROL_MODIFIER__build-with-obstacle-avoidance__ to ghost rail plan with obstacle avoidance.

### Inserters

Inserters pick items up from one direction and place them on the opposite tile.
They can move items to and from [entity=transport-belt], [entity=iron-chest], [entity=burner-mining-drill], [entity=stone-furnace], and other machines.

### Insertion limits

An Inserter doesn't always fill up the entire target inventory. This allows other inserters to pick up their share of the items.
For example, if a [entity=boiler] has 5 or more items of [item=coal] in it, an inserter will not insert any more. This allows the other fuel to travel further down the transport belt to other boilers, instead of the first in the queue hoarding everything.
This also applies to [entity=gun-turret], [entity=assembling-machine-1], [entity=stone-furnace], [entity=lab] and more.

### Limiting chests

Chests can have their available inventory slots limited by selecting the red "X" inventory slot, and then blocking the desired slots.
Inserters will not be able to fill the blocked slots, so overall it reduces the chests capacity and prevents over-production.

### Logistic network

The logistic network is a powerful automated delivery network that utilizes flying robots to move items and perform automated construction.
It has 3 major components:
 - [entity=roboport] defines the area of network coverage, acts as a charging and storage point for robots.
 - [entity=logistic-robot] fulfills logistic orders and [entity=construction-robot] performs construction orders.
 - [tooltip=Provider chests,tips-and-tricks-item-description.storage-chest-list] supply the network with items.

### Long-handed inserters

[entity=long-handed-inserter] is an electric inserter that picks up and places items two tiles from its location instead of the usual one.

### Low power

If your power consumption is greater than your production capacity, your factory machines will work more slowly due to the insufficient supply.
Pay attention to the speed of your machines, if you want to identify insufficient power production before it's too late.
The best way to make sure you have enough power, is to check the electric network statistics and make sure the 'Satisfaction' bar is green and full.

### Passive provider chest

[entity=passive-provider-chest] supplies its items to the logistic network.
This means any items in the passive provider chests can be taken by robots to fulfill logistic or construction orders.

### Personal logistics

[entity=logistic-robot] moves items from logistic provider chests to fulfill personal logistic requests.
The personal logistic request has a minimum and maximum count, and the robots will bring items until you have more than the minimum count.
If you have more than the maximum count, the items will be moved to your logistic trash slots, to be taken away by the robots.

### Pole dragging coverage

If you build [entity=small-electric-pole] by dragging along electric machines, none in range will be skipped.

### Power switch connection

__ALT_CONTROL__1__build__ on an entity with [shortcut=give-copper-wire] in your cursor to connect an electric cable to it.
__ALT_CONTROL__1__remove-pole-cables__ on an entity to remove all cables.

### Pump connection

[entity=pump] will connect to a stationary [entity=fluid-wagon] when they are aligned correctly.
It is required for loading and unloading fluids from the [entity=fluid-wagon].

### Rail building

To activate the rail building mode, hold [item=rail] and press [`build`] over an existing piece of rail.
__ALT_CONTROL__1__build__ to confirm the placement of the desired piece of rail.
[`clear-cursor`] deactivates the rail building mode.

### Rail signals advanced

[entity=rail-chain-signal] determines its state based on the signals ahead of it to ensure that a train entering a block will be able to leave it.
They are used in conjuction with [entity=rail-signal] to build advanced railway intersections.


The tutorial teaches you how to use rail chain signals to build complex rail intersections and prevent deadlocks.

### Rail signals basic

[entity=rail-signal] divides rails into blocks. Each [entity=locomotive] will read the rail signals to prevent crashing into other trains.



The tutorial teaches you how to use rail signals to run multiple trains on the same rail system.

### Repair packs

While holding a [item=repair-pack] in your cursor, press [`build`] and hold on an entity to repair it.

### Requester chest

[entity=requester-chest] requests items from the logistic network.
[entity=logistic-robot] will move items from the logistic network to fulfill the requests.

### Rotating assembling machines

Some recipes require a fluid input to the [entity=assembling-machine-2], such as [recipe=electric-engine-unit]. An assembling machine with a fluid input can be rotated by using [`rotate`].

### Shoot targeting

You can shoot enemy targets pressing [`shoot-enemy`] with your cursor near the enemy.
You can shoot a selected neutral or friendly entity by pressing [`shoot-selected`].

### Shoot targeting

You can shoot enemy targets by holding [`shoot-enemy`].
When using a controller, all weapons will automatically aim to the closest enemy in an area. Use [`look`] to move the automatic targeting area.
You can shoot a selected neutral or friendly entity by pressing [`shoot-selected`].

### Spidertron control

[entity=spidertron] can be entered using [`toggle-driving`], and driven using __CONTROL_MOVE__.
It can also be controlled by [`give-spidertron-remote`]. [`use-item`] to send spidertron and [`alternative-use-item`] to queue move command.
[`select-for-cancel-deconstruct`] can be used to add another spidertron to the selection and [`deselect`] to deselect it.

### Splitters

[entity=splitter] is used to split, combine, or balance belts.
Incoming items are split equally if there is free space in both outputs, or routed to whatever output is free.
It can be configured to filter specific item, or to prioritize one of the inputs/outputs.

### Stack transfers

[`stack-transfer`] transfers a single stack.
[`inventory-transfer`] transfers all stacks of the given type. (Selecting an empty slot transfers the whole inventory.)
Using __CONTROL_RIGHT_CLICK__ instead of __CONTROL_LEFT_CLICK__ for the controls mentioned above will transfer half the quantity.

The tutorial explains it in more detail.

### Steam power

[entity=boiler] consumes burnable fuel such as [item=coal] to turn [fluid=water] into [fluid=steam].
[entity=steam-engine] consumes [fluid=steam] to produce electric energy, which is distributed to consumers in the electric network.

### Storage chest

[entity=storage-chest] stores the items taken from player trash slots and deconstruction orders.
Any items in the storage chests are also provided to be used for logistic or construction orders.
Storage chests can be filtered to only accept 1 type of item.

### Train stops

[entity=train-stop] is used to automate item transportation with trains by providing nameable locations for trains to travel to.



The tutorial teaches you how to build a train station, and how to set a simple train schedule.

### Train stops with the same name

[entity=train-stop] can share its name with other stops. Trains with that name in the schedule will be able to target any of the stops as their destination.
You can set the train limit for each train stop to control this behavior more precisely.

### Trains

Trains are useful for high throughput and long distance transportation.
Trains can be entered using [`toggle-driving`], and driven using __CONTROL_MOVE__.

### Transfer between labs

[entity=inserter] can be used to transfer science packs between [entity=lab].

### Usable items

Some items can be used in other ways than building entities in the world. For instance, you can throw [item=grenade] at enemies to damage them.
__ALT_CONTROL__1__build__ while holding a usable item in your cursor to apply its action.

### __CONTROL__confirm-gui__ to confirm

All the green buttons in the game can be 'confirmed' using [`confirm-gui`].

### __CONTROL__drop-cursor__ to drop items

Press [`drop-cursor`] to drop single items from your cursor.
You can drop to the ground, on to belts, and into entities.
Hold [`drop-cursor`] and drag the cursor across multiple entities to quickly drop single items into each.

### __CONTROL__flip-horizontal__ or __CONTROL__flip-vertical__ to flip entities

Most entities can be flipped, horizontally with [`flip-horizontal`] or vertically with [`flip-vertical`]. You can flip items in your hand, or hover over an entity to flip it in place.


---

---

## tips-and-tricks

# Factorio Tips and Tricks

This document contains helpful tips and tricks for playing Factorio.

## Active provider chest

[entity=active-provider-chest] actively tries to push its items to the logistic network.\nIf there are no requests for an item in an active provider chest, they will be moved to [entity=storage-chest].

## Additional info (Alt-mode)

Press __CONTROL__show-info__ to toggle the detailed info overlay, also known as "Alt-mode".

## Automatic obstacle traversing

Dragging [entity=transport-belt] over an obstacle will automatically build [entity=underground-belt] transition when possible.

## Belt lanes

[entity=transport-belt] have two lanes that can be used to transport items and they can be used for different resources.\n[entity=inserter] can pick up items from both lanes, but put items only on the far lane.

## Buffer chest

[entity=buffer-chest] acts as both a [entity=requester-chest] and [entity=passive-provider-chest].\nThey provide items for construction jobs, personal logistics, and requester chests with 'Request from buffer chests' enabled.

## Build by dragging

The quickest way to build in a straight line, such as a setup of [entity=stone-furnace], is to press __CONTROL__build__ and hold while running in the desired direction.

## Bulk crafting

When hovering a crafting slot:\n - __ALT_CONTROL__1__craft-5__ to craft 5.\n - __ALT_CONTROL__1__craft-all__ to craft as much as possible.

## Burner inserter refueling

[entity=burner-inserter] can be refueled by other inserters, but they can also refuel themselves when working with fuel.

## Circuit network

The circuit network is a system that allows transfer of information between machines.\nYou can connect machines to the circuit network using [shortcut=give-red-wire] and [shortcut=give-green-wire].\nThe network can carry integer values of -2³¹(-2,147,483,648) .. 2³¹(2,147,483,647) individually for each signal type.\nIt is not required to use the circuit network to finish the game, but allows a lot of fun contraptions or fine tuned factory optimizations that wouldn't be possible without it.

## Clear cursor

When holding an item, you can clear it using __CONTROL__clear-cursor__, which will return it to the [img=utility/hand] slot in the source inventory.\nIt also cancels rail planning, wire dragging and selection boxes.

## Construction robots

[entity=construction-robot] fulfills construction, deconstruction, upgrade and repair orders from the logistic network.\nConstruction orders are created by ghost building, [item=blueprint] usage, or when a friendly building is destroyed and needs to be rebuilt.\nDeconstruction orders are created by selecting the desired entities by [item=deconstruction-planner].\nUpgrade orders are created by the usage of [item=upgrade-planner].\nThese orders are also created when using the undo feature.

## Copy paste

The copy tool (__CONTROL__copy__) allows you to save selection to clipboard.\nThe paste tool (__CONTROL__paste__) retrieves the last copied selection to be built.\n__CONTROL__cycle-clipboard-forwards__ and __CONTROL__cycle-clipboard-backwards__ allows you to scroll through the clipboard history.

## Copy-paste entity settings

__CONTROL__copy-entity-settings__ and __CONTROL__paste-entity-settings__ allows you to copy settings between entities.\nFor instance, you can copy-paste between [entity=assembling-machine-2] to set the recipe, or between chests to set the inventory limit.\n__ALT_CONTROL__1__paste-entity-settings__ and drag can paste to multiple entities with a single stroke.

## Copy-paste entity settings

__CONTROL__copy-entity-settings__ and __CONTROL__paste-entity-settings__ allows you to copy settings between entities.\nFor instance, you can copy-paste between [entity=assembling-machine-2] to set the recipe, or between chests to set the inventory limit.\nHold down __CONTROL__paste-entity-settings__ and move using __CONTROL__move__ to quickly paste to multiple entities.

## Copy-paste filters

You can copy-paste between entities with configurable filters, requests, or filtered inventory slots, such as [entity=fast-inserter], [entity=splitter], [entity=requester-chest] or [entity=cargo-wagon].

## Copy-paste requester chest

You can copy-paste between [entity=requester-chest] to copy the logistic requests.\nYou can also copy-paste from an [entity=assembling-machine-2] to a [entity=requester-chest] to set the logistic request based on the recipe.

## Copy-paste spidertron

Copy-pasting between [entity=spidertron] will copy the color and logistic requests.\nIt will also try to copy the equipment grid, inserting the equipment from the player inventory if the items are available.

## Copy-paste trains

You can copy-paste between [entity=locomotive] to copy schedule and color.\nYou can copy-paste between [entity=train-stop] to copy the stop name and color.\nLastly you can copy-paste between [entity=locomotive] and [entity=train-stop] either way to copy the color.

## Dragging electric poles

If you build [entity=small-electric-pole] by dragging, it will automatically be built at the maximum connection distance.

## Dragging underground belts

If you build [entity=underground-belt] or [entity=pipe-to-ground] by dragging, it will automatically be built at the maximum connection distance.

## Electric network

Electric networks transfer energy from the producers like [entity=steam-engine] or [entity=solar-panel] to the consumers evenly.\n__ALT_CONTROL__1__open-gui__ on an electric pole to show the statistics of its electric network.

## Electric pole connections

Electric poles will automatically connect to other electric poles within their 'wire reach'.\nConnections can be manually added or removed using [shortcut=give-copper-wire].\nAll electric pole connections can be removed using __CONTROL__remove-pole-cables__ on an electric pole.

## Entity pipette

Use __CONTROL__pipette__ to put the selected entity in your cursor.\nWhen used in remote view, a ghost of the selected entity will be put in your cursor instead.

## Entity transfers

__ALT_CONTROL__1__fast-entity-transfer__ on an entity to take items from it.\n__ALT_CONTROL__1__fast-entity-transfer__ while holding an item to put it into the selected entity.\n\n\nThe tutorial teaches you different ways of transferring items to and from entities without opening them.

## Fast belt bending

Pressing __CONTROL__rotate__ while dragging [entity=transport-belt] allows you to make seamless bends quickly.

## Fast replace

Building over an entity of the same type and size will perform a fast replace. Fast replacing will preserve properties of the original entity, such as the inventory contents and selected recipe.

## Fast replace belt & splitter

You can fast replace [entity=transport-belt] with [entity=splitter] and vice versa.

## Fast replace belt & underground belt

You can fast replace [entity=transport-belt] with [entity=underground-belt] and vice versa.\nAny belts in between the entrance and exit of the underground belt will be mined automatically.\nThis fast replace feature also applies to [entity=pipe] and [entity=pipe-to-ground].

## Fast replace direction

You can use fast replace to quickly change the direction of entities.

## Gate over rail

[entity=gate] can be built over any vertical or horizontal [entity=straight-rail].\nTrains will automatically open the gate to pass, and will not leave a hole in your defenses.

## Ghost building

__ALT_CONTROL__1__build-ghost__ while holding a buildable item to build it as an entity ghost.\nEntity ghosts will be automatically built by any logistic networks in range.

## Ghost rail planner

The ghost rail planner is used to plan long stretches of new rail ghosts.\nTo use the ghost planner, hold __CONTROL_MODIFIER__build-ghost__ while rail planning.\nYou can also hold __CONTROL_MODIFIER__build-with-obstacle-avoidance__ to ghost rail plan with obstacle avoidance.

## Inserters

Inserters pick items up from one direction and place them on the opposite tile.\nThey can move items to and from [entity=transport-belt], [entity=iron-chest], [entity=burner-mining-drill], [entity=stone-furnace], and other machines.

## Insertion limits

An Inserter doesn't always fill up the entire target inventory. This allows other inserters to pick up their share of the items.\nFor example, if a [entity=boiler] has 5 or more items of [item=coal] in it, an inserter will not insert any more. This allows the other fuel to travel further down the transport belt to other boilers, instead of the first in the queue hoarding everything.\nThis also applies to [entity=gun-turret], [entity=assembling-machine-1], [entity=stone-furnace], [entity=lab] and more.

## Limiting chests

Chests can have their available inventory slots limited by selecting the red "X" inventory slot, and then blocking the desired slots.\nInserters will not be able to fill the blocked slots, so overall it reduces the chests capacity and prevents over-production.

## Logistic network

The logistic network is a powerful automated delivery network that utilizes flying robots to move items and perform automated construction.\nIt has 3 major components:\n - [entity=roboport] defines the area of network coverage, acts as a charging and storage point for robots.\n - [entity=logistic-robot] fulfills logistic orders and [entity=construction-robot] performs construction orders.\n - [tooltip=Provider chests,tips-and-tricks-item-description.storage-chest-list] supply the network with items.

## Long-handed inserters

[entity=long-handed-inserter] is an electric inserter that picks up and places items two tiles from its location instead of the usual one.

## Low power

If your power consumption is greater than your production capacity, your factory machines will work more slowly due to the insufficient supply.\nPay attention to the speed of your machines, if you want to identify insufficient power production before it's too late.\nThe best way to make sure you have enough power, is to check the electric network statistics and make sure the 'Satisfaction' bar is green and full.

## Passive provider chest

[entity=passive-provider-chest] supplies its items to the logistic network.\nThis means any items in the passive provider chests can be taken by robots to fulfill logistic or construction orders.

## Personal logistics

[entity=logistic-robot] moves items from logistic provider chests to fulfill personal logistic requests.\nThe personal logistic request has a minimum and maximum count, and the robots will bring items until you have more than the minimum count.\nIf you have more than the maximum count, the items will be moved to your logistic trash slots, to be taken away by the robots.

## Pole dragging coverage

If you build [entity=small-electric-pole] by dragging along electric machines, none in range will be skipped.

## Power switch connection

__ALT_CONTROL__1__build__ on an entity with [shortcut=give-copper-wire] in your cursor to connect an electric cable to it.\n__ALT_CONTROL__1__remove-pole-cables__ on an entity to remove all cables.

## Pump connection

[entity=pump] will connect to a stationary [entity=fluid-wagon] when they are aligned correctly.\nIt is required for loading and unloading fluids from the [entity=fluid-wagon].

## Rail building

To activate the rail building mode, hold [item=rail] and press __CONTROL__build__ over an existing piece of rail.\n__ALT_CONTROL__1__build__ to confirm the placement of the desired piece of rail.\n__CONTROL__clear-cursor__ deactivates the rail building mode.

## Rail signals advanced

[entity=rail-chain-signal] determines its state based on the signals ahead of it to ensure that a train entering a block will be able to leave it.\nThey are used in conjuction with [entity=rail-signal] to build advanced railway intersections.\n\n\nThe tutorial teaches you how to use rail chain signals to build complex rail intersections and prevent deadlocks.

## Rail signals basic

[entity=rail-signal] divides rails into blocks. Each [entity=locomotive] will read the rail signals to prevent crashing into other trains.\n\n\n\nThe tutorial teaches you how to use rail signals to run multiple trains on the same rail system.

## Repair packs

While holding a [item=repair-pack] in your cursor, press __CONTROL__build__ and hold on an entity to repair it.

## Requester chest

[entity=requester-chest] requests items from the logistic network.\n[entity=logistic-robot] will move items from the logistic network to fulfill the requests.

## Rotating assembling machines

Some recipes require a fluid input to the [entity=assembling-machine-2], such as [recipe=electric-engine-unit]. An assembling machine with a fluid input can be rotated by using __CONTROL__rotate__.

## Shoot targeting

You can shoot enemy targets pressing __CONTROL__shoot-enemy__ with your cursor near the enemy.\nYou can shoot a selected neutral or friendly entity by pressing __CONTROL__shoot-selected__.

## Shoot targeting

You can shoot enemy targets by holding __CONTROL__shoot-enemy__.\nWhen using a controller, all weapons will automatically aim to the closest enemy in an area. Use __CONTROL__look__ to move the automatic targeting area.\nYou can shoot a selected neutral or friendly entity by pressing __CONTROL__shoot-selected__.

## Spidertron control

[entity=spidertron] can be entered using __CONTROL__toggle-driving__, and driven using __CONTROL_MOVE__.\nIt can also be controlled by __CONTROL__give-spidertron-remote__. __CONTROL__use-item__ to send spidertron and __CONTROL__alternative-use-item__ to queue move command.\n__CONTROL__select-for-cancel-deconstruct__ can be used to add another spidertron to the selection and __CONTROL__deselect__ to deselect it.

## Splitters

[entity=splitter] is used to split, combine, or balance belts.\nIncoming items are split equally if there is free space in both outputs, or routed to whatever output is free.\nIt can be configured to filter specific item, or to prioritize one of the inputs/outputs.

## Stack transfers

__CONTROL__stack-transfer__ transfers a single stack.\n__CONTROL__inventory-transfer__ transfers all stacks of the given type. (Selecting an empty slot transfers the whole inventory.)\nUsing __CONTROL_RIGHT_CLICK__ instead of __CONTROL_LEFT_CLICK__ for the controls mentioned above will transfer half the quantity.\n\nThe tutorial explains it in more detail.

## Steam power

[entity=boiler] consumes burnable fuel such as [item=coal] to turn [fluid=water] into [fluid=steam].\n[entity=steam-engine] consumes [fluid=steam] to produce electric energy, which is distributed to consumers in the electric network.

## Storage chest

[entity=storage-chest] stores the items taken from player trash slots and deconstruction orders.\nAny items in the storage chests are also provided to be used for logistic or construction orders.\nStorage chests can be filtered to only accept 1 type of item.

## Train stops

[entity=train-stop] is used to automate item transportation with trains by providing nameable locations for trains to travel to.\n\n\n\nThe tutorial teaches you how to build a train station, and how to set a simple train schedule.

## Train stops with the same name

[entity=train-stop] can share its name with other stops. Trains with that name in the schedule will be able to target any of the stops as their destination.\nYou can set the train limit for each train stop to control this behavior more precisely.

## Trains

Trains are useful for high throughput and long distance transportation.\nTrains can be entered using __CONTROL__toggle-driving__, and driven using __CONTROL_MOVE__.

## Transfer between labs

[entity=inserter] can be used to transfer science packs between [entity=lab].

## Usable items

Some items can be used in other ways than building entities in the world. For instance, you can throw [item=grenade] at enemies to damage them.\n__ALT_CONTROL__1__build__ while holding a usable item in your cursor to apply its action.

## __CONTROL__confirm-gui__ to confirm

All the green buttons in the game can be 'confirmed' using __CONTROL__confirm-gui__.

## __CONTROL__drop-cursor__ to drop items

Press __CONTROL__drop-cursor__ to drop single items from your cursor.\nYou can drop to the ground, on to belts, and into entities.\nHold __CONTROL__drop-cursor__ and drag the cursor across multiple entities to quickly drop single items into each.

## __CONTROL__flip-horizontal__ or __CONTROL__flip-vertical__ to flip entities

Most entities can be flipped, horizontally with __CONTROL__flip-horizontal__ or vertically with __CONTROL__flip-vertical__. You can flip items in your hand, or hover over an entity to flip it in place.

## storage-chest-list

Chests providing its contents ordered by priority:\n[entity=active-provider-chest] Active provider chest\n[entity=buffer-chest] Buffer chest\n[entity=storage-chest] Storage chest\n[entity=passive-provider-chest] Passive provider chest

---

