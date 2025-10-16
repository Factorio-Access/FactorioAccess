# ModulePrototype

A [module](https://wiki.factorio.com/Module). They are used to affect the capabilities of existing machines, for example by increasing the crafting speed of a [crafting machine](prototype:CraftingMachinePrototype).

**Parent:** [ItemPrototype](ItemPrototype.md)
**Type name:** `module`

## Properties

### category

Used when upgrading modules: Ctrl + click modules into an entity and it will replace lower tier modules of the same category with higher tier modules.

**Type:** `ModuleCategoryID`

**Required:** Yes

### tier

Tier of the module inside its category. Used when upgrading modules: Ctrl + click modules into an entity and it will replace lower tier modules with higher tier modules if they have the same category.

**Type:** `uint32`

**Required:** Yes

### effect

The effect of the module on the machine it's inserted in, such as increased pollution.

**Type:** `Effect`

**Required:** Yes

### requires_beacon_alt_mode

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### art_style

Chooses with what art style the module is shown inside [beacons](prototype:BeaconPrototype). See [BeaconModuleVisualizations::art_style](prototype:BeaconModuleVisualizations::art_style). Vanilla uses `"vanilla"` here.

**Type:** `string`

**Optional:** Yes

### beacon_tint

**Type:** `BeaconVisualizationTints`

**Optional:** Yes

