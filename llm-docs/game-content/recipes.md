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

