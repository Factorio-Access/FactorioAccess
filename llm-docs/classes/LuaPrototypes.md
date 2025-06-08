# LuaPrototypes

Provides read-only access to prototypes. It is accessible through the global object named `prototypes`.

## Methods

### get_achievement_filtered

Returns a dictionary of all LuaAchievementPrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` ``AchievementPrototypeFilter`[]`: 

**Returns:**

- `LuaCustomTable<`string`, `LuaAchievementPrototype`>`: 

### get_decorative_filtered

Returns a dictionary of all LuaDecorativePrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` ``DecorativePrototypeFilter`[]`: 

**Returns:**

- `LuaCustomTable<`string`, `LuaDecorativePrototype`>`: 

### get_entity_filtered

Returns a dictionary of all LuaEntityPrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` ``EntityPrototypeFilter`[]`: 

**Returns:**

- `LuaCustomTable<`string`, `LuaEntityPrototype`>`: 

### get_equipment_filtered

Returns a dictionary of all LuaEquipmentPrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` ``EquipmentPrototypeFilter`[]`: 

**Returns:**

- `LuaCustomTable<`string`, `LuaEquipmentPrototype`>`: 

### get_fluid_filtered

Returns a dictionary of all LuaFluidPrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` ``FluidPrototypeFilter`[]`: 

**Returns:**

- `LuaCustomTable<`string`, `LuaFluidPrototype`>`: 

### get_history

Gets the prototype history for the given type and name.

**Parameters:**

- `name` `string`: 
- `type` `string`: 

**Returns:**

- `PrototypeHistory`: 

### get_item_filtered

Returns a dictionary of all LuaItemPrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` ``ItemPrototypeFilter`[]`: 

**Returns:**

- `LuaCustomTable<`string`, `LuaItemPrototype`>`: 

### get_mod_setting_filtered

Returns a dictionary of all LuaModSettingPrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` ``ModSettingPrototypeFilter`[]`: 

**Returns:**

- `LuaCustomTable<`string`, `LuaModSettingPrototype`>`: 

### get_recipe_filtered

Returns a dictionary of all LuaRecipePrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` ``RecipePrototypeFilter`[]`: 

**Returns:**

- `LuaCustomTable<`string`, `LuaRecipePrototype`>`: 

### get_technology_filtered

Returns a dictionary of all LuaTechnologyPrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` ``TechnologyPrototypeFilter`[]`: 

**Returns:**

- `LuaCustomTable<`string`, `LuaTechnologyPrototype`>`: 

### get_tile_filtered

Returns a dictionary of all LuaTilePrototypes that fit the given filters. The prototypes are indexed by `name`.

**Parameters:**

- `filters` ``TilePrototypeFilter`[]`: 

**Returns:**

- `LuaCustomTable<`string`, `LuaTilePrototype`>`: 

## Attributes

### achievement

**Type:** `LuaCustomTable<`string`, `LuaAchievementPrototype`>` _(read-only)_

A dictionary containing every LuaAchievementPrototype indexed by `name`.

### active_trigger

**Type:** `LuaCustomTable<`string`, `LuaActiveTriggerPrototype`>` _(read-only)_

A dictionary containing every LuaActiveTriggerPrototype indexed by `name`.

### airborne_pollutant

**Type:** `LuaCustomTable<`string`, `LuaAirbornePollutantPrototype`>` _(read-only)_

A dictionary containing every LuaAirbornePollutantPrototype indexed by `name`.

### ammo_category

**Type:** `LuaCustomTable<`string`, `LuaAmmoCategoryPrototype`>` _(read-only)_

A dictionary containing every LuaAmmoCategoryPrototype indexed by `name`.

### asteroid_chunk

**Type:** `LuaCustomTable<`string`, `LuaAsteroidChunkPrototype`>` _(read-only)_

A dictionary containing every LuaAsteroidChunkPrototype indexed by `name`.

### autoplace_control

**Type:** `LuaCustomTable<`string`, `LuaAutoplaceControlPrototype`>` _(read-only)_

A dictionary containing every LuaAutoplaceControlPrototype indexed by `name`.

### burner_usage

**Type:** `LuaCustomTable<`string`, `LuaBurnerUsagePrototype`>` _(read-only)_

A dictionary containing every LuaBurnerUsagePrototype indexed by `name`.

### collision_layer

**Type:** `LuaCustomTable<`string`, `LuaCollisionLayerPrototype`>` _(read-only)_

A dictionary containing every LuaCollisionLayerPrototype indexed by `name`.

### custom_event

**Type:** `LuaCustomTable<`string`, `LuaCustomEventPrototype`>` _(read-only)_

A dictionary containing every defined custom event, indexed by `name`.

### custom_input

**Type:** `LuaCustomTable<`string`, `LuaCustomInputPrototype`>` _(read-only)_

A dictionary containing every LuaCustomInputPrototype indexed by `name`.

### damage

**Type:** `LuaCustomTable<`string`, `LuaDamagePrototype`>` _(read-only)_

A dictionary containing every LuaDamagePrototype indexed by `name`.

### decorative

**Type:** `LuaCustomTable<`string`, `LuaDecorativePrototype`>` _(read-only)_

A dictionary containing every LuaDecorativePrototype indexed by `name`.

### entity

**Type:** `LuaCustomTable<`string`, `LuaEntityPrototype`>` _(read-only)_

A dictionary containing every LuaEntityPrototype indexed by `name`.

### equipment

**Type:** `LuaCustomTable<`string`, `LuaEquipmentPrototype`>` _(read-only)_

A dictionary containing every LuaEquipmentPrototype indexed by `name`.

### equipment_category

**Type:** `LuaCustomTable<`string`, `LuaEquipmentCategoryPrototype`>` _(read-only)_

A dictionary containing every LuaEquipmentCategoryPrototype indexed by `name`.

### equipment_grid

**Type:** `LuaCustomTable<`string`, `LuaEquipmentGridPrototype`>` _(read-only)_

A dictionary containing every LuaEquipmentGridPrototype indexed by `name`.

### fluid

**Type:** `LuaCustomTable<`string`, `LuaFluidPrototype`>` _(read-only)_

A dictionary containing every LuaFluidPrototype indexed by `name`.

### font

**Type:** `LuaCustomTable<`string`, `LuaFontPrototype`>` _(read-only)_

A dictionary containing every LuaFontPrototype indexed by `name`.

### fuel_category

**Type:** `LuaCustomTable<`string`, `LuaFuelCategoryPrototype`>` _(read-only)_

A dictionary containing every LuaFuelCategoryPrototype indexed by `name`.

### item

**Type:** `LuaCustomTable<`string`, `LuaItemPrototype`>` _(read-only)_

A dictionary containing every LuaItemPrototype indexed by `name`.

### item_group

**Type:** `LuaCustomTable<`string`, `LuaGroup`>` _(read-only)_

A dictionary containing every ItemGroup indexed by `name`.

### item_subgroup

**Type:** `LuaCustomTable<`string`, `LuaGroup`>` _(read-only)_

A dictionary containing every ItemSubgroup indexed by `name`.

### map_gen_preset

**Type:** `LuaCustomTable<`string`, `MapGenPreset`>` _(read-only)_

A dictionary containing every MapGenPreset indexed by `name`.

A MapGenPreset is an exact copy of the prototype table provided from the data stage.

### max_beacon_supply_area_distance

**Type:** `uint` _(read-only)_



### max_electric_pole_connection_distance

**Type:** `double` _(read-only)_



### max_electric_pole_supply_area_distance

**Type:** `float` _(read-only)_



### max_force_distraction_chunk_distance

**Type:** `uint` _(read-only)_



### max_force_distraction_distance

**Type:** `double` _(read-only)_



### max_gate_activation_distance

**Type:** `double` _(read-only)_



### max_inserter_reach_distance

**Type:** `double` _(read-only)_



### max_pipe_to_ground_distance

**Type:** `uint8` _(read-only)_



### max_underground_belt_distance

**Type:** `uint8` _(read-only)_



### mod_setting

**Type:** `LuaCustomTable<`string`, `LuaModSettingPrototype`>` _(read-only)_

A dictionary containing every LuaModSettingPrototype indexed by `name`.

### module_category

**Type:** `LuaCustomTable<`string`, `LuaModuleCategoryPrototype`>` _(read-only)_

A dictionary containing every LuaModuleCategoryPrototype indexed by `name`.

### named_noise_expression

**Type:** `LuaCustomTable<`string`, `LuaNamedNoiseExpression`>` _(read-only)_

A dictionary containing every LuaNamedNoiseExpression indexed by `name`.

### named_noise_function

**Type:** `LuaCustomTable<`string`, `LuaNamedNoiseFunction`>` _(read-only)_

A dictionary containing every LuaNamedNoiseFunction indexed by `name`.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### particle

**Type:** `LuaCustomTable<`string`, `LuaParticlePrototype`>` _(read-only)_

A dictionary containing every LuaParticlePrototype indexed by `name`.

### procession

**Type:** `LuaCustomTable<`string`, `LuaProcessionPrototype`>` _(read-only)_

A dictionary containing every LuaProcessionPrototype indexed by `name`.

### procession_layer_inheritance_group

**Type:** `LuaCustomTable<`string`, `LuaProcessionLayerInheritanceGroupPrototype`>` _(read-only)_

A dictionary containing every LuaProcessionLayerInheritanceGroupPrototype indexed by `name`.

### quality

**Type:** `LuaCustomTable<`string`, `LuaQualityPrototype`>` _(read-only)_



### recipe

**Type:** `LuaCustomTable<`string`, `LuaRecipePrototype`>` _(read-only)_

A dictionary containing every LuaRecipePrototype indexed by `name`.

### recipe_category

**Type:** `LuaCustomTable<`string`, `LuaRecipeCategoryPrototype`>` _(read-only)_

A dictionary containing every LuaRecipeCategoryPrototype indexed by `name`.

### resource_category

**Type:** `LuaCustomTable<`string`, `LuaResourceCategoryPrototype`>` _(read-only)_

A dictionary containing every LuaResourceCategoryPrototype indexed by `name`.

### shortcut

**Type:** `LuaCustomTable<`string`, `LuaShortcutPrototype`>` _(read-only)_

A dictionary containing every LuaShortcutPrototype indexed by `name`.

### space_connection

**Type:** `LuaCustomTable<`string`, `LuaSpaceConnectionPrototype`>` _(read-only)_



### space_location

**Type:** `LuaCustomTable<`string`, `LuaSpaceLocationPrototype`>` _(read-only)_



### style

**Type:** `LuaCustomTable<`string`, `string`>` _(read-only)_

A map of styles that [LuaGuiElement](runtime:LuaGuiElement) can use.

Maps from the style's name to its type, as seen on [StyleSpecification](prototype:StyleSpecification).

### surface

**Type:** `LuaCustomTable<`string`, `LuaSurfacePrototype`>` _(read-only)_

A dictionary containing every LuaSurfacePrototype indexed by `name`.

### surface_property

**Type:** `LuaCustomTable<`string`, `LuaSurfacePropertyPrototype`>` _(read-only)_



### technology

**Type:** `LuaCustomTable<`string`, `LuaTechnologyPrototype`>` _(read-only)_

A dictionary containing every [LuaTechnologyPrototype](runtime:LuaTechnologyPrototype) indexed by `name`.

### tile

**Type:** `LuaCustomTable<`string`, `LuaTilePrototype`>` _(read-only)_

A dictionary containing every LuaTilePrototype indexed by `name`.

### trivial_smoke

**Type:** `LuaCustomTable<`string`, `LuaTrivialSmokePrototype`>` _(read-only)_

A dictionary containing every LuaTrivialSmokePrototype indexed by `name`.

### virtual_signal

**Type:** `LuaCustomTable<`string`, `LuaVirtualSignalPrototype`>` _(read-only)_

A dictionary containing every LuaVirtualSignalPrototype indexed by `name`.

