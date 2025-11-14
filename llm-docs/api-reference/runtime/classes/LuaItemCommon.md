# LuaItemCommon

Common methods related to usage of item with data. It is useful when LuaItemStack contains item with data or in general with LuaItem as it can only point at an item with data.

**Abstract:** Yes

## Attributes

### is_blueprint

If this is a blueprint item.

**Read type:** `boolean`

### is_blueprint_book

If this is a blueprint book item.

**Read type:** `boolean`

### is_item_with_label

If this is an item with label item.

**Read type:** `boolean`

### is_item_with_inventory

If this is an item with inventory item.

**Read type:** `boolean`

### is_item_with_entity_data

If this is an item with entity data item.

**Read type:** `boolean`

### is_selection_tool

If this is a selection tool item.

**Read type:** `boolean`

### is_item_with_tags

If this is an item with tags item.

**Read type:** `boolean`

### is_deconstruction_item

If this is a deconstruction tool item.

**Read type:** `boolean`

### is_upgrade_item

If this is a upgrade item.

**Read type:** `boolean`

### is_tool

If this is a tool item.

**Read type:** `boolean`

### is_ammo

If this is an ammo item.

**Read type:** `boolean`

### is_armor

If this is an armor item.

**Read type:** `boolean`

### is_repair_tool

If this is a repair tool item.

**Read type:** `boolean`

### item_number

The unique identifier for this item, if any. Note that this ID stays the same no matter where the item is moved to.

**Read type:** `uint64`

**Optional:** Yes

### preview_icons

Icons of this blueprint item, blueprint book, deconstruction item or upgrade planner. An item that doesn't have icons returns `nil` on read and throws error on write.

**Read type:** Array[`BlueprintSignalIcon`]

**Write type:** Array[`BlueprintSignalIcon`]

**Optional:** Yes

### grid

The equipment grid of this item, if any.

**Read type:** `LuaEquipmentGrid`

**Optional:** Yes

### owner_location

The location of this item if it can be found.

**Read type:** `ItemLocationData`

### blueprint_snap_to_grid

The snapping grid size in this blueprint item. `nil` if snapping is not enabled.

**Read type:** `TilePosition`

**Write type:** `TilePosition`

**Optional:** Yes

**Subclasses:** BlueprintItem

### blueprint_position_relative_to_grid

The offset from the absolute grid. `nil` if absolute snapping is not enabled.

**Read type:** `TilePosition`

**Write type:** `TilePosition`

**Optional:** Yes

**Subclasses:** BlueprintItem

### blueprint_absolute_snapping

If absolute snapping is enabled on this blueprint item.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** BlueprintItem

### blueprint_description

The description for this blueprint or blueprint book

**Read type:** `string`

**Write type:** `string`

**Subclasses:** BlueprintItem, BlueprintBookItem

### cost_to_build

List of raw materials required to build this blueprint.

**Read type:** `ItemWithQualityCounts`

**Subclasses:** BlueprintItem

### default_icons

The default icons for a blueprint item.

**Read type:** Array[`BlueprintSignalIcon`]

**Subclasses:** BlueprintItem

### active_index

The active blueprint index for this blueprint book. `nil` if this blueprint book is empty.

**Read type:** `uint32`

**Write type:** `uint32`

**Optional:** Yes

**Subclasses:** BlueprintBookItem

### label

The current label for this item, if any.

**Read type:** `string`

**Write type:** `string`

**Optional:** Yes

**Subclasses:** ItemWithLabel

### label_color

The current label color for this item, if any.

**Read type:** `Color`

**Write type:** `Color`

**Optional:** Yes

**Subclasses:** ItemWithLabel

### allow_manual_label_change

Whether the label for this item can be manually changed. When false the label can only be changed through the API.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** ItemWithLabel

### entity_label

If this is an item with entity data, get the stored entity label.

**Read type:** `string`

**Write type:** `string`

**Optional:** Yes

**Subclasses:** ItemWithEntityData

### entity_color

If this is an item with entity data, get the stored entity color.

**Read type:** `Color`

**Write type:** `Color`

**Optional:** Yes

**Subclasses:** ItemWithEntityData

### entity_logistic_sections

If this is an item with entity data, get the stored logistic filters.

**Read type:** `LogisticSections`

**Write type:** `LogisticSections`

**Subclasses:** ItemWithEntityData

### entity_request_from_buffers

If this is an item with entity data, get the stored request from buffer state.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** ItemWithEntityData

### entity_logistics_enabled

If this is an item with entity data, get the stored vehicle logistics enabled state.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** ItemWithEntityData

### entity_enable_logistics_while_moving

If this is an item with entity data, get the stored enable logistics while moving state.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** ItemWithEntityData

### entity_driver_is_gunner

If this is an item with entity data, get the stored driver is gunner state.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** ItemWithEntityData

### entity_auto_target_without_gunner

If this is an item with entity data, get the stored auto target without gunner state.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** ItemWithEntityData

### entity_auto_target_with_gunner

If this is an item with entity data, get the stored auto target with gunner state.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** ItemWithEntityData

### tags

**Read type:** `Tags`

**Write type:** `Tags`

**Subclasses:** ItemWithTags

### custom_description

The custom description this item-with-tags. This is shown over the normal item description if this is set to a non-empty value.

**Read type:** `LocalisedString`

**Write type:** `LocalisedString`

**Subclasses:** ItemWithTags

### entity_filter_count

The number of entity filters this deconstruction item supports.

**Read type:** `uint32`

**Subclasses:** DeconstructionItem

### entity_filters

The entity filters for this deconstruction item. The attribute is a sparse array with the keys representing the index of the filter. All prototypes in this array must not have the `"not-deconstructable"` flag set and are either a `cliff` or marked as `minable`.

**Read type:** Array[`ItemFilter`]

**Write type:** Array[`ItemFilter`]

**Subclasses:** DeconstructionItem

### tile_filter_count

The number of tile filters this deconstruction item supports.

**Read type:** `uint32`

**Subclasses:** DeconstructionItem

### tile_filters

The tile filters for this deconstruction item. The attribute is a sparse array with the keys representing the index of the filter. Reading filters always returns an array of strings which are the tile prototype names.

**Read type:** Array[`TileID`]

**Write type:** Array[`TileID`]

**Subclasses:** DeconstructionItem

### entity_filter_mode

The blacklist/whitelist entity filter mode for this deconstruction item.

**Read type:** `defines.deconstruction_item.entity_filter_mode`

**Write type:** `defines.deconstruction_item.entity_filter_mode`

**Subclasses:** DeconstructionItem

### tile_filter_mode

The blacklist/whitelist tile filter mode for this deconstruction item.

**Read type:** `defines.deconstruction_item.tile_filter_mode`

**Write type:** `defines.deconstruction_item.tile_filter_mode`

**Subclasses:** DeconstructionItem

### tile_selection_mode

The tile selection mode for this deconstruction item.

**Read type:** `defines.deconstruction_item.tile_selection_mode`

**Write type:** `defines.deconstruction_item.tile_selection_mode`

**Subclasses:** DeconstructionItem

### trees_and_rocks_only

If this deconstruction item is set to allow trees and rocks only.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** DeconstructionItem

### mapper_count

The current count of mappers in the upgrade item.

**Read type:** `uint32`

**Subclasses:** UpgradeItem

### durability

Durability of the contained item. Automatically capped at the item's maximum durability.

**Read type:** `double`

**Write type:** `double`

**Subclasses:** Tool

### ammo

Number of bullets left in the magazine.

**Read type:** `uint32`

**Write type:** `uint32`

**Subclasses:** AmmoItem

## Methods

### get_inventory

Access the inner inventory of an item.

**Parameters:**

- `inventory` `defines.inventory` - Index of the inventory to access, which can only be [defines.inventory.item_main](runtime:defines.inventory.item_main).

**Returns:**

- `LuaInventory` *(optional)* - `nil` if there is no inventory with the given index.

### clear_blueprint

Clears this blueprint item.

### is_blueprint_setup

Is this blueprint item setup? I.e. is it a non-empty blueprint?

**Returns:**

- `boolean`

### build_blueprint

Build this blueprint at the given location.

Built entities can be come invalid between the building of the blueprint and the function returning if by_player or raise_built is used and one of those events invalidates the entity.

**Parameters:**

- `surface` `SurfaceIdentification` - Surface to build on
- `force` `ForceID` - Force to use for the building
- `position` `MapPosition` - The position to build at
- `direction` `defines.direction` *(optional)* - The direction to use when building
- `build_mode` `defines.build_mode` *(optional)* - If `normal`, blueprint will not be built if any one thing can't be built. If `forced`, anything that can be built is built and obstructing nature entities will be deconstructed. If `superforced`, all obstructions will be deconstructed and the blueprint will be built.
- `skip_fog_of_war` `boolean` *(optional)* - If chunks covered by fog-of-war are skipped.
- `by_player` `PlayerIdentification` *(optional)* - The player to use if any. If provided [defines.events.on_built_entity](runtime:defines.events.on_built_entity) will also be fired on successful entity creation.
- `raise_built` `boolean` *(optional)* - If true; [defines.events.script_raised_built](runtime:defines.events.script_raised_built) will be fired on successful entity creation. Note: this is ignored if by_player is provided.

**Returns:**

- Array[`LuaEntity`] - Array of created ghosts

### create_blueprint

Sets up this blueprint using the found blueprintable entities/tiles on the surface.

**Parameters:**

- `surface` `SurfaceIdentification` - Surface to create from
- `force` `ForceID` - Force to use for the creation
- `area` `BoundingBox` - The bounding box
- `always_include_tiles` `boolean` *(optional)* - When true, blueprintable tiles are always included in the blueprint. When false they're only included if no entities exist in the setup area. Defaults to false.
- `include_entities` `boolean` *(optional)* - When true, entities are included in the blueprint. Defaults to true.
- `include_modules` `boolean` *(optional)* - When true, modules are included in the blueprint. Defaults to true.
- `include_station_names` `boolean` *(optional)* - When true, station names are included in the blueprint. Defaults to false.
- `include_trains` `boolean` *(optional)* - When true, trains are included in the blueprint. Defaults to false.
- `include_fuel` `boolean` *(optional)* - When true, train fuel is included in the blueprint, Defaults to true.

**Returns:**

- Dictionary[`uint32`, `LuaEntity`] - The blueprint entity index to source entity mapping.

### get_blueprint_entity_tags

Gets the tags for the given blueprint entity index in this blueprint item.

**Parameters:**

- `index` `uint32`

**Returns:**

- `Tags`

### set_blueprint_entity_tags

Sets the tags on the given blueprint entity index in this blueprint item.

**Parameters:**

- `index` `uint32` - The entity index
- `tags` `Tags`

### get_blueprint_entity_tag

Gets the given tag on the given blueprint entity index in this blueprint item.

**Parameters:**

- `index` `uint32` - The entity index.
- `tag` `string` - The tag to get.

**Returns:**

- `AnyBasic` *(optional)*

### set_blueprint_entity_tag

Sets the given tag on the given blueprint entity index in this blueprint item.

**Parameters:**

- `index` `uint32` - The entity index.
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

Gets the number of entities in this blueprint item.

**Returns:**

- `uint32`

### get_tag

Gets the tag with the given name or returns `nil` if it doesn't exist.

**Parameters:**

- `tag_name` `string`

**Returns:**

- `AnyBasic` *(optional)*

### set_tag

Sets the tag with the given name and value.

**Parameters:**

- `tag_name` `string`
- `tag` `AnyBasic`

### remove_tag

Removes a tag with the given name.

**Parameters:**

- `tag` `string`

**Returns:**

- `boolean` - If the tag existed and was removed.

### get_entity_filter

Gets the entity filter at the given index for this deconstruction item.

**Parameters:**

- `index` `uint32`

**Returns:**

- `ItemFilter` *(optional)*

### set_entity_filter

Sets the entity filter at the given index for this deconstruction item.

**Parameters:**

- `index` `uint32`
- `filter` `ItemFilter` | `nil` - Writing `nil` removes the filter.

**Returns:**

- `boolean` - Whether the new filter was successfully set (meaning it was valid).

### get_tile_filter

Gets the tile filter at the given index for this deconstruction item.

**Parameters:**

- `index` `uint32`

**Returns:**

- `string` *(optional)*

### set_tile_filter

Sets the tile filter at the given index for this deconstruction item.

**Parameters:**

- `index` `uint32`
- `filter` `string` | `LuaTilePrototype` | `LuaTile` | `nil` - Writing `nil` removes the filter.

**Returns:**

- `boolean` - Whether the new filter was successfully set (meaning it was valid).

### deconstruct_area

Deconstruct the given area with this deconstruction item.

**Parameters:**

- `surface` `SurfaceIdentification` - Surface to deconstruct on
- `force` `ForceID` - Force to use for the deconstruction
- `area` `BoundingBox` - The area to deconstruct
- `skip_fog_of_war` `boolean` *(optional)* - If chunks covered by fog-of-war are skipped. Defaults to `false`.
- `by_player` `PlayerIdentification` *(optional)* - The player to use if any.
- `super_forced` `boolean` *(optional)* - If the deconstruction is super-forced. Defaults to `false`.

### cancel_deconstruct_area

Cancel deconstruct the given area with this deconstruction item.

**Parameters:**

- `surface` `SurfaceIdentification` - Surface to cancel deconstruct on
- `force` `ForceID` - Force to use for canceling deconstruction
- `area` `BoundingBox` - The area to deconstruct
- `skip_fog_of_war` `boolean` *(optional)* - If chunks covered by fog-of-war are skipped. Defaults to `false`.
- `by_player` `PlayerIdentification` *(optional)* - The player to use if any.
- `super_forced` `boolean` *(optional)* - If the cancel deconstruction is super-forced. Defaults to `false`.

### clear_deconstruction_item

Clears all settings/filters on this deconstruction item resetting it to default values.

### clear_upgrade_item

Clears all settings/filters on this upgrade item resetting it to default values.

### get_mapper

Gets the filter at the given index for this upgrade item. Note that sources (`"from"` type) that are undefined will read as `{type = "item"}`, while destinations (`"to"` type) that are undefined will read as `nil`.

In contrast to [LuaItemCommon::set_mapper](runtime:LuaItemCommon::set_mapper), indices past the upgrade item's current size are considered to be out of bounds.

**Parameters:**

- `index` `uint32` - The index of the mapper to read.
- `type` `"from"` | `"to"`

**Returns:**

- `UpgradeMapperSource` | `UpgradeMapperDestination` *(optional)*

### set_mapper

Sets the module filter at the given index for this upgrade item.

In contrast to [LuaItemCommon::get_mapper](runtime:LuaItemCommon::get_mapper), indices past the upgrade item's current size are valid and expand the list of mappings accordingly, if within reasonable bounds.

**Parameters:**

- `index` `uint32` - The index of the mapper to set.
- `type` `"from"` | `"to"`
- `mapper` `UpgradeMapperSource` | `UpgradeMapperDestination` | `nil` - The mapper to set. Set `nil` to clear the mapper.

