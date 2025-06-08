# LuaItemCommon

Common methods related to usage of item with data. It is useful when LuaItemStack contains item with data or in general with LuaItem as it can only point at an item with data.

## Methods

### build_blueprint

Build this blueprint at the given location.

Built entities can be come invalid between the building of the blueprint and the function returning if by_player or raise_built is used and one of those events invalidates the entity.

**Parameters:**

- `build_mode` `defines.build_mode` _(optional)_: If `normal`, blueprint will not be built if any one thing can't be built. If `forced`, anything that can be built is built and obstructing nature entities will be deconstructed. If `superforced`, all obstructions will be deconstructed and the blueprint will be built.
- `by_player` `PlayerIdentification` _(optional)_: The player to use if any. If provided [defines.events.on_built_entity](runtime:defines.events.on_built_entity) will also be fired on successful entity creation.
- `direction` `defines.direction` _(optional)_: The direction to use when building
- `force` `ForceID`: Force to use for the building
- `position` `MapPosition`: The position to build at
- `raise_built` `boolean` _(optional)_: If true; [defines.events.script_raised_built](runtime:defines.events.script_raised_built) will be fired on successful entity creation. Note: this is ignored if by_player is provided.
- `skip_fog_of_war` `boolean` _(optional)_: If chunks covered by fog-of-war are skipped.
- `surface` `SurfaceIdentification`: Surface to build on

**Returns:**

- ``LuaEntity`[]`: Array of created ghosts

### cancel_deconstruct_area

Cancel deconstruct the given area with this deconstruction item.

**Parameters:**

- `area` `BoundingBox`: The area to deconstruct
- `by_player` `PlayerIdentification` _(optional)_: The player to use if any.
- `force` `ForceID`: Force to use for canceling deconstruction
- `skip_fog_of_war` `boolean` _(optional)_: If chunks covered by fog-of-war are skipped. Defaults to `false`.
- `super_forced` `boolean` _(optional)_: If the cancel deconstruction is super-forced. Defaults to `false`.
- `surface` `SurfaceIdentification`: Surface to cancel deconstruct on

### clear_blueprint

Clears this blueprint item.

### clear_deconstruction_item

Clears all settings/filters on this deconstruction item resetting it to default values.

### clear_upgrade_item

Clears all settings/filters on this upgrade item resetting it to default values.

### create_blueprint

Sets up this blueprint using the found blueprintable entities/tiles on the surface.

**Parameters:**

- `always_include_tiles` `boolean` _(optional)_: When true, blueprintable tiles are always included in the blueprint. When false they're only included if no entities exist in the setup area. Defaults to false.
- `area` `BoundingBox`: The bounding box
- `force` `ForceID`: Force to use for the creation
- `include_entities` `boolean` _(optional)_: When true, entities are included in the blueprint. Defaults to true.
- `include_fuel` `boolean` _(optional)_: When true, train fuel is included in the blueprint, Defaults to true.
- `include_modules` `boolean` _(optional)_: When true, modules are included in the blueprint. Defaults to true.
- `include_station_names` `boolean` _(optional)_: When true, station names are included in the blueprint. Defaults to false.
- `include_trains` `boolean` _(optional)_: When true, trains are included in the blueprint. Defaults to false.
- `surface` `SurfaceIdentification`: Surface to create from

**Returns:**

- `dictionary<`uint`, `LuaEntity`>`: The blueprint entity index to source entity mapping.

### deconstruct_area

Deconstruct the given area with this deconstruction item.

**Parameters:**

- `area` `BoundingBox`: The area to deconstruct
- `by_player` `PlayerIdentification` _(optional)_: The player to use if any.
- `force` `ForceID`: Force to use for the deconstruction
- `skip_fog_of_war` `boolean` _(optional)_: If chunks covered by fog-of-war are skipped. Defaults to `false`.
- `super_forced` `boolean` _(optional)_: If the deconstruction is super-forced. Defaults to `false`.
- `surface` `SurfaceIdentification`: Surface to deconstruct on

### get_blueprint_entities

The entities in this blueprint.

**Returns:**

- ``BlueprintEntity`[]`: 

### get_blueprint_entity_count

Gets the number of entities in this blueprint item.

**Returns:**

- `uint`: 

### get_blueprint_entity_tag

Gets the given tag on the given blueprint entity index in this blueprint item.

**Parameters:**

- `index` `uint`: The entity index.
- `tag` `string`: The tag to get.

**Returns:**

- `AnyBasic`: 

### get_blueprint_entity_tags

Gets the tags for the given blueprint entity index in this blueprint item.

**Parameters:**

- `index` `uint`: 

**Returns:**

- `Tags`: 

### get_blueprint_tiles

A list of the tiles in this blueprint.

**Returns:**

- ``Tile`[]`: 

### get_entity_filter

Gets the entity filter at the given index for this deconstruction item.

**Parameters:**

- `index` `uint`: 

**Returns:**

- `ItemFilter`: 

### get_inventory

Access the inner inventory of an item.

**Parameters:**

- `inventory` `defines.inventory`: Index of the inventory to access, which can only be [defines.inventory.item_main](runtime:defines.inventory.item_main).

**Returns:**

- `LuaInventory`: `nil` if there is no inventory with the given index.

### get_mapper

Gets the filter at the given index for this upgrade item. Note that sources (`"from"` type) that are undefined will read as `{type = "item"}`, while destinations (`"to"` type) that are undefined will read as `nil`.

In contrast to [LuaItemCommon::set_mapper](runtime:LuaItemCommon::set_mapper), indices past the upgrade item's current size are considered to be out of bounds.

**Parameters:**

- `index` `uint`: The index of the mapper to read.
- `type` : 

**Returns:**

- : 

### get_tag

Gets the tag with the given name or returns `nil` if it doesn't exist.

**Parameters:**

- `tag_name` `string`: 

**Returns:**

- `AnyBasic`: 

### get_tile_filter

Gets the tile filter at the given index for this deconstruction item.

**Parameters:**

- `index` `uint`: 

**Returns:**

- `string`: 

### is_blueprint_setup

Is this blueprint item setup? I.e. is it a non-empty blueprint?

**Returns:**

- `boolean`: 

### remove_tag

Removes a tag with the given name.

**Parameters:**

- `tag` `string`: 

**Returns:**

- `boolean`: If the tag existed and was removed.

### set_blueprint_entities

Set new entities to be a part of this blueprint.

**Parameters:**

- `entities` ``BlueprintEntity`[]`: The new blueprint entities.

### set_blueprint_entity_tag

Sets the given tag on the given blueprint entity index in this blueprint item.

**Parameters:**

- `index` `uint`: The entity index.
- `tag` `string`: The tag to set.
- `value` `AnyBasic`: The tag value to set or `nil` to clear the tag.

### set_blueprint_entity_tags

Sets the tags on the given blueprint entity index in this blueprint item.

**Parameters:**

- `index` `uint`: The entity index
- `tags` `Tags`: 

### set_blueprint_tiles

Set specific tiles in this blueprint.

**Parameters:**

- `tiles` ``Tile`[]`: Tiles to be a part of the blueprint.

### set_entity_filter

Sets the entity filter at the given index for this deconstruction item.

**Parameters:**

- `filter` : Writing `nil` removes the filter.
- `index` `uint`: 

**Returns:**

- `boolean`: Whether the new filter was successfully set (meaning it was valid).

### set_mapper

Sets the module filter at the given index for this upgrade item.

In contrast to [LuaItemCommon::get_mapper](runtime:LuaItemCommon::get_mapper), indices past the upgrade item's current size are valid and expand the list of mappings accordingly, if within reasonable bounds.

**Parameters:**

- `index` `uint`: The index of the mapper to set.
- `mapper` : The mapper to set. Set `nil` to clear the mapper.
- `type` : 

### set_tag

Sets the tag with the given name and value.

**Parameters:**

- `tag` `AnyBasic`: 
- `tag_name` `string`: 

### set_tile_filter

Sets the tile filter at the given index for this deconstruction item.

**Parameters:**

- `filter` : Writing `nil` removes the filter.
- `index` `uint`: 

**Returns:**

- `boolean`: Whether the new filter was successfully set (meaning it was valid).

## Attributes

### active_index

**Type:** `uint`

The active blueprint index for this blueprint book. `nil` if this blueprint book is empty.

### allow_manual_label_change

**Type:** `boolean`

Whether the label for this item can be manually changed. When false the label can only be changed through the API.

### ammo

**Type:** `uint`

Number of bullets left in the magazine.

### blueprint_absolute_snapping

**Type:** `boolean`

If absolute snapping is enabled on this blueprint item.

### blueprint_position_relative_to_grid

**Type:** `TilePosition`

The offset from the absolute grid. `nil` if absolute snapping is not enabled.

### blueprint_snap_to_grid

**Type:** `TilePosition`

The snapping grid size in this blueprint item. `nil` if snapping is not enabled.

### cost_to_build

**Type:** ``ItemWithQualityCounts`[]` _(read-only)_

List of raw materials required to build this blueprint.

### custom_description

**Type:** `LocalisedString`

The custom description this item-with-tags. This is shown over the normal item description if this is set to a non-empty value.

### default_icons

**Type:** ``BlueprintSignalIcon`[]` _(read-only)_

The default icons for a blueprint item.

### durability

**Type:** `double`

Durability of the contained item. Automatically capped at the item's maximum durability.

### entity_color

**Type:** `Color`

If this is an item with entity data, get the stored entity color.

### entity_filter_count

**Type:** `uint` _(read-only)_

The number of entity filters this deconstruction item supports.

### entity_filter_mode

**Type:** `defines.deconstruction_item.entity_filter_mode`

The blacklist/whitelist entity filter mode for this deconstruction item.

### entity_filters

**Type:** ``ItemFilter`[]`

The entity filters for this deconstruction item. The attribute is a sparse array with the keys representing the index of the filter. All prototypes in this array must not have the `"not-deconstructable"` flag set and are either a `cliff` or marked as `minable`.

### entity_label

**Type:** `string`

If this is an item with entity data, get the stored entity label.

### grid

**Type:** `LuaEquipmentGrid` _(read-only)_

The equipment grid of this item, if any.

### is_ammo

**Type:** `boolean` _(read-only)_

If this is an ammo item.

### is_armor

**Type:** `boolean` _(read-only)_

If this is an armor item.

### is_blueprint

**Type:** `boolean` _(read-only)_

If this is a blueprint item.

### is_blueprint_book

**Type:** `boolean` _(read-only)_

If this is a blueprint book item.

### is_deconstruction_item

**Type:** `boolean` _(read-only)_

If this is a deconstruction tool item.

### is_item_with_entity_data

**Type:** `boolean` _(read-only)_

If this is an item with entity data item.

### is_item_with_inventory

**Type:** `boolean` _(read-only)_

If this is an item with inventory item.

### is_item_with_label

**Type:** `boolean` _(read-only)_

If this is an item with label item.

### is_item_with_tags

**Type:** `boolean` _(read-only)_

If this is an item with tags item.

### is_repair_tool

**Type:** `boolean` _(read-only)_

If this is a repair tool item.

### is_selection_tool

**Type:** `boolean` _(read-only)_

If this is a selection tool item.

### is_tool

**Type:** `boolean` _(read-only)_

If this is a tool item.

### is_upgrade_item

**Type:** `boolean` _(read-only)_

If this is a upgrade item.

### item_number

**Type:** `uint64` _(read-only)_

The unique identifier for this item, if any. Note that this ID stays the same no matter where the item is moved to.

### label

**Type:** `string`

The current label for this item, if any.

### label_color

**Type:** `Color`

The current label color for this item, if any.

### mapper_count

**Type:** `uint` _(read-only)_

The current count of mappers in the upgrade item.

### owner_location

**Type:** `ItemLocationData` _(read-only)_

The location of this item if it can be found.

### preview_icons

**Type:** ``BlueprintSignalIcon`[]`

Icons of this blueprint item, blueprint book, deconstruction item or upgrade planner. An item that doesn't have icons returns `nil` on read and throws error on write.

### tags

**Type:** `Tags`



### tile_filter_count

**Type:** `uint` _(read-only)_

The number of tile filters this deconstruction item supports.

### tile_filter_mode

**Type:** `defines.deconstruction_item.tile_filter_mode`

The blacklist/whitelist tile filter mode for this deconstruction item.

### tile_filters

**Type:** ``TileID`[]`

The tile filters for this deconstruction item. The attribute is a sparse array with the keys representing the index of the filter. Reading filters always returns an array of strings which are the tile prototype names.

### tile_selection_mode

**Type:** `defines.deconstruction_item.tile_selection_mode`

The tile selection mode for this deconstruction item.

### trees_and_rocks_only

**Type:** `boolean`

If this deconstruction item is set to allow trees and rocks only.

