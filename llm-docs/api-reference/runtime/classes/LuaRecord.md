# LuaRecord

A reference to a record in the blueprint library. Records in the "my blueprints" shelf are read-only, but records in the "game blueprints" shelf are read/write.

## Attributes

### valid_for_write

Is this record valid for writing? A record is invalid for write if it is a BlueprintRecord preview or if it is in the "My blueprints" shelf.

**Read type:** `boolean`

### type

The type of this blueprint record.

**Read type:** `"blueprint"` | `"blueprint-book"` | `"deconstruction-planner"` | `"upgrade-planner"`

### preview_icons

The preview icons for this record.

**Read type:** Array[`BlueprintSignalIcon`]

**Write type:** Array[`BlueprintSignalIcon`]

### is_preview

Checks if this record is in a preview state.

**Read type:** `boolean`

### is_blueprint_preview

Is this blueprint record a preview? A preview record must be synced by the player before entity and tile data can be read.

**Read type:** `boolean`

**Subclasses:** BlueprintRecord

### blueprint_snap_to_grid

The snapping grid size in this blueprint. `nil` if snapping is not enabled.

**Read type:** `TilePosition`

**Write type:** `TilePosition`

**Optional:** Yes

**Subclasses:** BlueprintRecord

### blueprint_position_relative_to_grid

The offset from the absolute grid. `nil` if absolute snapping is not enabled.

**Read type:** `TilePosition`

**Write type:** `TilePosition`

**Optional:** Yes

**Subclasses:** BlueprintRecord

### blueprint_absolute_snapping

If absolute snapping is enabled on this blueprint.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** BlueprintRecord

### blueprint_description

The description for this blueprint or blueprint book

**Read type:** `string`

**Write type:** `string`

**Subclasses:** BlueprintRecord, BlueprintBookRecord

### cost_to_build

List of raw materials required to build this blueprint.

**Read type:** `ItemWithQualityCounts`

**Subclasses:** BlueprintRecord

### default_icons

The default icons for a blueprint blueprint.

**Read type:** Array[`BlueprintSignalIcon`]

**Subclasses:** BlueprintRecord

### contents

The contents of this BlueprintBookRecord. This is sparse array - it may have gaps, so using `#` will not be reliable. Use [LuaRecord::contents_size](runtime:LuaRecord::contents_size) or `pairs()` to iterate this table.

**Read type:** Dictionary[`ItemStackIndex`, `LuaRecord`]

**Subclasses:** BlueprintBookRecord

### contents_size

The highest populated index in the contents of this BlueprintBookRecord.

**Read type:** `ItemStackIndex`

**Subclasses:** BlueprintBookRecord

### entity_filters

The entity filters for this deconstruction planner. The attribute is a sparse array with the keys representing the index of the filter. All prototypes in this array must not have the `"not-deconstructable"` flag set and are either a `cliff` or marked as `minable`.

**Read type:** Array[`ItemFilter`]

**Write type:** Array[`ItemFilter`]

**Subclasses:** DeconstructionRecord

### tile_filters

The tile filters for this deconstruction planner. The attribute is a sparse array with the keys representing the index of the filter. Reading filters always returns an array of strings which are the tile prototype names.

**Read type:** Array[`TileID`]

**Write type:** Array[`TileID`]

**Subclasses:** DeconstructionRecord

### entity_filter_mode

The blacklist/whitelist entity filter mode for this deconstruction planner.

**Read type:** `defines.deconstruction_item.entity_filter_mode`

**Write type:** `defines.deconstruction_item.entity_filter_mode`

**Subclasses:** DeconstructionRecord

### tile_filter_mode

The blacklist/whitelist tile filter mode for this deconstruction planner.

**Read type:** `defines.deconstruction_item.tile_filter_mode`

**Write type:** `defines.deconstruction_item.tile_filter_mode`

**Subclasses:** DeconstructionRecord

### tile_selection_mode

The tile selection mode for this deconstruction planner.

**Read type:** `defines.deconstruction_item.tile_selection_mode`

**Write type:** `defines.deconstruction_item.tile_selection_mode`

**Subclasses:** DeconstructionRecord

### trees_and_rocks_only

If this deconstruction planner, is set to allow trees and rocks only.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** DeconstructionRecord

### entity_filter_count

The number of entity filters this deconstruction planner supports.

**Read type:** `uint`

**Subclasses:** DeconstructionRecord

### tile_filter_count

The number of tile filters this deconstruction planner supports.

**Read type:** `uint`

**Subclasses:** DeconstructionRecord

### mapper_count

The current count of mappers in the upgrade item.

**Read type:** `uint`

**Subclasses:** UpgradeRecord

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### clear_blueprint

Clears this blueprint.

### is_blueprint_setup

Is this blueprint setup? I.e. is it a non-empty blueprint?

**Returns:**

- `boolean`

### build_blueprint

Build this blueprint at the given location.

Built entities can be come invalid between the building of the blueprint and the function returning if by_player or raise_built is used and one of those events invalidates the entity.

**Parameters:**

- `build_mode` `defines.build_mode` *(optional)* - If `normal`, blueprint will not be built if any one thing can't be built. If `forced`, anything that can be built is built and obstructing nature entities will be deconstructed. If `superforced`, all obstructions will be deconstructed and the blueprint will be built.
- `by_player` `PlayerIdentification` *(optional)* - The player to use if any. If provided [defines.events.on_built_entity](runtime:defines.events.on_built_entity) will also be fired on successful entity creation.
- `direction` `defines.direction` *(optional)* - The direction to use when building
- `force` `ForceID` - Force to use for the building
- `position` `MapPosition` - The position to build at
- `raise_built` `boolean` *(optional)* - If true; [defines.events.script_raised_built](runtime:defines.events.script_raised_built) will be fired on successful entity creation. Note: this is ignored if by_player is provided.
- `skip_fog_of_war` `boolean` *(optional)* - If chunks covered by fog-of-war are skipped.
- `surface` `SurfaceIdentification` - Surface to build on

**Returns:**

- Array[`LuaEntity`] - Array of created ghosts

### create_blueprint

Sets up this blueprint using the found blueprintable entities/tiles on the surface.

**Parameters:**

- `always_include_tiles` `boolean` *(optional)* - When true, blueprintable tiles are always included in the blueprint. When false they're only included if no entities exist in the setup area. Defaults to false.
- `area` `BoundingBox` - The bounding box
- `force` `ForceID` - Force to use for the creation
- `include_entities` `boolean` *(optional)* - When true, entities are included in the blueprint. Defaults to true.
- `include_fuel` `boolean` *(optional)* - When true, train fuel is included in the blueprint, Defaults to true.
- `include_modules` `boolean` *(optional)* - When true, modules are included in the blueprint. Defaults to true.
- `include_station_names` `boolean` *(optional)* - When true, station names are included in the blueprint. Defaults to false.
- `include_trains` `boolean` *(optional)* - When true, trains are included in the blueprint. Defaults to false.
- `surface` `SurfaceIdentification` - Surface to create from

**Returns:**

- Dictionary[`uint`, `LuaEntity`] - The blueprint entity index to source entity mapping.

### get_blueprint_entity_tags

Gets the tags for the given blueprint entity index in this blueprint.

**Parameters:**

- `index` `uint`

**Returns:**

- `Tags`

### set_blueprint_entity_tags

Sets the tags on the given blueprint entity index in this blueprint.

**Parameters:**

- `index` `uint` - The entity index
- `tags` `Tags`

### get_blueprint_entity_tag

Gets the given tag on the given blueprint entity index in this blueprint blueprint.

**Parameters:**

- `index` `uint` - The entity index.
- `tag` `string` - The tag to get.

**Returns:**

- `AnyBasic` *(optional)*

### set_blueprint_entity_tag

Sets the given tag on the given blueprint entity index in this blueprint blueprint.

**Parameters:**

- `index` `uint` - The entity index.
- `tag` `string` - The tag to set.
- `value` `AnyBasic` - The tag value to set or `nil` to clear the tag.

### get_blueprint_entities

The entities in this blueprint.

**Returns:**

- Array[`BlueprintEntity`] *(optional)*

### set_blueprint_entities

Set new entities to be a part of this blueprint.

**Parameters:**

- `entities` Array[`BlueprintEntity`] - The new blueprint entities.

### get_blueprint_tiles

A list of the tiles in this blueprint.

**Returns:**

- Array[`Tile`] *(optional)*

### set_blueprint_tiles

Set specific tiles in this blueprint.

**Parameters:**

- `tiles` Array[`Tile`] - Tiles to be a part of the blueprint.

### get_blueprint_entity_count

Gets the number of entities in this blueprint blueprint.

**Returns:**

- `uint`

### get_active_index

The active index of this BlueprintBookRecord. For records in "my blueprints", the result will be the same regardless of the player, but records in "game blueprints" may have different active indices per player.

**Parameters:**

- `player` `PlayerIdentification`

**Returns:**

- `uint`

### get_entity_filter

Gets the entity filter at the given index for this deconstruction planner.

**Parameters:**

- `index` `uint`

**Returns:**

- `ItemFilter` *(optional)*

### set_entity_filter

Sets the entity filter at the given index for this deconstruction planner.

**Parameters:**

- `filter` `ItemFilter` | `nil` - Writing `nil` removes the filter.
- `index` `uint`

**Returns:**

- `boolean` - Whether the new filter was successfully set (ie. was valid).

### get_tile_filter

Gets the tile filter at the given index for this deconstruction planner.

**Parameters:**

- `index` `uint`

**Returns:**

- `string` *(optional)*

### set_tile_filter

Sets the tile filter at the given index for this deconstruction planner.

**Parameters:**

- `filter` `string` | `LuaTilePrototype` | `LuaTile` - Setting to nil erases the filter.
- `index` `uint`

**Returns:**

- `boolean` - Whether the new filter was successfully set (ie. was valid).

### deconstruct_area

Deconstruct the given area with this deconstruction planner.

**Parameters:**

- `area` `BoundingBox` - The area to deconstruct
- `by_player` `PlayerIdentification` *(optional)* - The player to use if any.
- `force` `ForceID` - Force to use for the deconstruction
- `skip_fog_of_war` `boolean` *(optional)* - If chunks covered by fog-of-war are skipped. Defaults to `false`.
- `super_forced` `boolean` *(optional)* - If the deconstruction is super-forced. Defaults to `false`.
- `surface` `SurfaceIdentification` - Surface to deconstruct on

### cancel_deconstruct_area

Cancel deconstruct the given area with this deconstruction planner.

**Parameters:**

- `area` `BoundingBox` - The area to deconstruct
- `by_player` `PlayerIdentification` *(optional)* - The player to use if any.
- `force` `ForceID` - Force to use for canceling deconstruction
- `skip_fog_of_war` `boolean` *(optional)* - If chunks covered by fog-of-war are skipped. Defaults to `false`.
- `super_forced` `boolean` *(optional)* - If the cancel deconstruction is super-forced. Defaults to `false`.
- `surface` `SurfaceIdentification` - Surface to cancel deconstruct on

### clear_deconstruction_data

Clears all settings/filters on this deconstruction planner, resetting it to default values.

### clear_upgrade_data

Clears all settings/filters on this upgrade planner, resetting it to default values.

### get_mapper

Gets the filter at the given index for this upgrade item. Note that sources (`"from"` type) that are undefined will read as `{type = "item"}`, while destinations (`"to"` type) that are undefined will read as `nil`.

In contrast to [LuaRecord::set_mapper](runtime:LuaRecord::set_mapper), indices past the upgrade item's current size are considered to be out of bounds.

**Parameters:**

- `index` `uint` - The index of the mapper to read.
- `type` `"from"` | `"to"`

**Returns:**

- `UpgradeMapperSource` | `UpgradeMapperDestination`

### set_mapper

Sets the module filter at the given index for this upgrade item.

In contrast to [LuaRecord::get_mapper](runtime:LuaRecord::get_mapper), indices past the upgrade item's current size are valid and expand the list of mappings accordingly, if within reasonable bounds.

**Parameters:**

- `index` `uint` - The index of the mapper to set.
- `mapper` `UpgradeMapperSource` | `UpgradeMapperDestination` | `nil` - The mapper to set. Set `nil` to clear the mapper.
- `type` `"from"` | `"to"`

