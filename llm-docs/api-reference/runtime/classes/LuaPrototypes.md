# LuaPrototypes

Provides read-only access to prototypes. It is accessible through the global object named `prototypes`.

## Attributes

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

### font

A dictionary containing every LuaFontPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaFontPrototype`]

### map_gen_preset

A dictionary containing every MapGenPreset indexed by `name`.

A MapGenPreset is an exact copy of the prototype table provided from the data stage.

**Read type:** LuaCustomTable[`string`, `MapGenPreset`]

### style

A map of styles that [LuaGuiElement](runtime:LuaGuiElement) can use.

Maps from the style's name to its type, as seen on [StyleSpecification](prototype:StyleSpecification).

**Read type:** LuaCustomTable[`string`, `string`]

### utility_constants

All utility constants.

See [UtilityConstants](prototype:UtilityConstants) for possible values.

**Read type:** LuaCustomTable[`string`, `AnyBasic`]

### entity

A dictionary containing every LuaEntityPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaEntityPrototype`]

### item

A dictionary containing every LuaItemPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaItemPrototype`]

### fluid

A dictionary containing every LuaFluidPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaFluidPrototype`]

### tile

A dictionary containing every LuaTilePrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaTilePrototype`]

### equipment

A dictionary containing every LuaEquipmentPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaEquipmentPrototype`]

### damage

A dictionary containing every LuaDamagePrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaDamagePrototype`]

### virtual_signal

A dictionary containing every LuaVirtualSignalPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaVirtualSignalPrototype`]

### equipment_grid

A dictionary containing every LuaEquipmentGridPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaEquipmentGridPrototype`]

### recipe

A dictionary containing every LuaRecipePrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaRecipePrototype`]

### technology

A dictionary containing every [LuaTechnologyPrototype](runtime:LuaTechnologyPrototype) indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaTechnologyPrototype`]

### decorative

A dictionary containing every LuaDecorativePrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaDecorativePrototype`]

### particle

A dictionary containing every LuaParticlePrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaParticlePrototype`]

### autoplace_control

A dictionary containing every LuaAutoplaceControlPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaAutoplaceControlPrototype`]

### mod_setting

A dictionary containing every LuaModSettingPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaModSettingPrototype`]

### custom_input

A dictionary containing every LuaCustomInputPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaCustomInputPrototype`]

### ammo_category

A dictionary containing every LuaAmmoCategoryPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaAmmoCategoryPrototype`]

### named_noise_expression

A dictionary containing every LuaNamedNoiseExpression indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaNamedNoiseExpression`]

### named_noise_function

A dictionary containing every LuaNamedNoiseFunction indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaNamedNoiseFunction`]

### item_subgroup

A dictionary containing every ItemSubgroup indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaGroup`]

### item_group

A dictionary containing every ItemGroup indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaGroup`]

### fuel_category

A dictionary containing every LuaFuelCategoryPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaFuelCategoryPrototype`]

### resource_category

A dictionary containing every LuaResourceCategoryPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaResourceCategoryPrototype`]

### achievement

A dictionary containing every LuaAchievementPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaAchievementPrototype`]

### module_category

A dictionary containing every LuaModuleCategoryPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaModuleCategoryPrototype`]

### equipment_category

A dictionary containing every LuaEquipmentCategoryPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaEquipmentCategoryPrototype`]

### trivial_smoke

A dictionary containing every LuaTrivialSmokePrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaTrivialSmokePrototype`]

### shortcut

A dictionary containing every LuaShortcutPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaShortcutPrototype`]

### recipe_category

A dictionary containing every LuaRecipeCategoryPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaRecipeCategoryPrototype`]

### quality

**Read type:** LuaCustomTable[`string`, `LuaQualityPrototype`]

### surface_property

**Read type:** LuaCustomTable[`string`, `LuaSurfacePropertyPrototype`]

### space_location

**Read type:** LuaCustomTable[`string`, `LuaSpaceLocationPrototype`]

### space_connection

**Read type:** LuaCustomTable[`string`, `LuaSpaceConnectionPrototype`]

### custom_event

A dictionary containing every defined custom event, indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaCustomEventPrototype`]

### active_trigger

A dictionary containing every LuaActiveTriggerPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaActiveTriggerPrototype`]

### asteroid_chunk

A dictionary containing every LuaAsteroidChunkPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaAsteroidChunkPrototype`]

### collision_layer

A dictionary containing every LuaCollisionLayerPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaCollisionLayerPrototype`]

### airborne_pollutant

A dictionary containing every LuaAirbornePollutantPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaAirbornePollutantPrototype`]

### burner_usage

A dictionary containing every LuaBurnerUsagePrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaBurnerUsagePrototype`]

### mod_data

A dictionary containing every LuaModData indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaModData`]

### surface

A dictionary containing every LuaSurfacePrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaSurfacePrototype`]

### procession

A dictionary containing every LuaProcessionPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaProcessionPrototype`]

### procession_layer_inheritance_group

A dictionary containing every LuaProcessionLayerInheritanceGroupPrototype indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaProcessionLayerInheritanceGroupPrototype`]

### max_force_distraction_distance

**Read type:** `double`

### max_force_distraction_chunk_distance

**Read type:** `uint32`

### max_electric_pole_supply_area_distance

**Read type:** `float`

### max_electric_pole_connection_distance

**Read type:** `double`

### max_beacon_supply_area_distance

**Read type:** `uint32`

### max_gate_activation_distance

**Read type:** `double`

### max_inserter_reach_distance

**Read type:** `double`

### max_pipe_to_ground_distance

**Read type:** `uint8`

### max_underground_belt_distance

**Read type:** `uint8`

## Methods

### get_entity_filtered

Returns a dictionary of all LuaEntityPrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` Array[`EntityPrototypeFilter`]

**Returns:**

- LuaCustomTable[`string`, `LuaEntityPrototype`]

**Examples:**

```
-- Get every entity prototype that can craft recipes involving fluids in the way some assembling machines can
local prototypes = prototypes.get_entity_filtered{{filter="crafting-category", crafting_category="crafting-with-fluid"}}
```

### get_item_filtered

Returns a dictionary of all LuaItemPrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` Array[`ItemPrototypeFilter`]

**Returns:**

- LuaCustomTable[`string`, `LuaItemPrototype`]

**Examples:**

```
-- Get every item prototype that has a fuel top speed multiplier larger than 1.
local prototypes = prototypes.get_item_filtered{{filter = "fuel-top-speed-multiplier", comparison = ">", value = 1}}
```

### get_equipment_filtered

Returns a dictionary of all LuaEquipmentPrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` Array[`EquipmentPrototypeFilter`]

**Returns:**

- LuaCustomTable[`string`, `LuaEquipmentPrototype`]

**Examples:**

```
-- Get every equipment prototype that functions as a battery.
local prototypes = prototypes.get_equipment_filtered{{filter="type", type="battery-equipment"}}
```

### get_mod_setting_filtered

Returns a dictionary of all LuaModSettingPrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` Array[`ModSettingPrototypeFilter`]

**Returns:**

- LuaCustomTable[`string`, `LuaModSettingPrototype`]

**Examples:**

```
-- Get every mod setting prototype that belongs to the specified mod.
local prototypes = prototypes.get_mod_setting_filtered{{filter="mod", mod="space-exploration"}}
```

### get_achievement_filtered

Returns a dictionary of all LuaAchievementPrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` Array[`AchievementPrototypeFilter`]

**Returns:**

- LuaCustomTable[`string`, `LuaAchievementPrototype`]

**Examples:**

```
-- Get every achievement prototype that is not allowed to be completed on the peaceful difficulty setting.
local prototypes = prototypes.get_achievement_filtered{{filter="allowed-without-fight", invert=true}}
```

### get_tile_filtered

Returns a dictionary of all LuaTilePrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` Array[`TilePrototypeFilter`]

**Returns:**

- LuaCustomTable[`string`, `LuaTilePrototype`]

**Examples:**

```
-- Get every tile prototype that improves a player's walking speed by at least 50%.
local prototypes = prototypes.get_tile_filtered{{filter="walking-speed-modifier", comparison="≥", value=1.5}}
```

### get_decorative_filtered

Returns a dictionary of all LuaDecorativePrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` Array[`DecorativePrototypeFilter`]

**Returns:**

- LuaCustomTable[`string`, `LuaDecorativePrototype`]

**Examples:**

```
-- Get every decorative prototype that is auto-placed.
local prototypes = prototypes.get_decorative_filtered{{filter="autoplace"}}
```

### get_fluid_filtered

Returns a dictionary of all LuaFluidPrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` Array[`FluidPrototypeFilter`]

**Returns:**

- LuaCustomTable[`string`, `LuaFluidPrototype`]

**Examples:**

```
-- Get every fluid prototype that has a heat capacity of exactly `100`.
local prototypes = prototypes.get_fluid_filtered{{filter="heat-capacity", comparison="=", value=100}}
```

### get_recipe_filtered

Returns a dictionary of all LuaRecipePrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` Array[`RecipePrototypeFilter`]

**Returns:**

- LuaCustomTable[`string`, `LuaRecipePrototype`]

**Examples:**

```
-- Get every recipe prototype that takes less than half a second to craft (at crafting speed `1`).
local prototypes = prototypes.get_recipe_filtered{{filter="energy", comparison="<", value=0.5}}
```

### get_technology_filtered

Returns a dictionary of all LuaTechnologyPrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` Array[`TechnologyPrototypeFilter`]

**Returns:**

- LuaCustomTable[`string`, `LuaTechnologyPrototype`]

**Examples:**

```
-- Get every technology prototype that can be researched at the start of the game.
local prototypes = prototypes.get_technology_filtered{{filter="has-prerequisites", invert=true}}
```

### get_history

Gets the prototype history for the given type and name.

**Parameters:**

- `type` `string`
- `name` `string`

**Returns:**

- `PrototypeHistory`

