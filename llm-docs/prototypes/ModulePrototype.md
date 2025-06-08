# ModulePrototype

A [module](https://wiki.factorio.com/Module). They are used to affect the capabilities of existing machines, for example by increasing the crafting speed of a [crafting machine](prototype:CraftingMachinePrototype).

**Parent:** `ItemPrototype`

## Properties

### Mandatory Properties

#### category

**Type:** `ModuleCategoryID`

Used when upgrading modules: Ctrl + click modules into an entity and it will replace lower tier modules of the same category with higher tier modules.

#### effect

**Type:** `Effect`

The effect of the module on the machine it's inserted in, such as increased pollution.

#### tier

**Type:** `uint32`

Tier of the module inside its category. Used when upgrading modules: Ctrl + click modules into an entity and it will replace lower tier modules with higher tier modules if they have the same category.

### Optional Properties

#### art_style

**Type:** `string`

Chooses with what art style the module is shown inside [beacons](prototype:BeaconPrototype). See [BeaconModuleVisualizations::art_style](prototype:BeaconModuleVisualizations::art_style). Vanilla uses `"vanilla"` here.

#### beacon_tint

**Type:** `BeaconVisualizationTints`



#### requires_beacon_alt_mode

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

