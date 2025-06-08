# LuaSurface

A "domain" of the world. Surfaces can only be created and deleted through the API. Surfaces are uniquely identified by their name. Every game contains at least the surface "nauvis".

## Methods

### add_script_area

Adds the given script area.

**Parameters:**

- `area` `ScriptArea`: 

**Returns:**

- `uint`: The id of the created area.

### add_script_position

Adds the given script position.

**Parameters:**

- `position` `ScriptPosition`: 

**Returns:**

- `uint`: The id of the created position.

### build_checkerboard

Sets the given area to the checkerboard lab tiles.

**Parameters:**

- `area` `BoundingBox`: The tile area.

### build_enemy_base

Send a group to build a new base.

The specified force must be AI-controlled; i.e. `force.ai_controllable` must be `true`.

**Parameters:**

- `force` `ForceID` _(optional)_: Force the new base will belong to. Defaults to enemy.
- `position` `MapPosition`: Location of the new base.
- `unit_count` `uint`: Number of biters to send for the base-building task.

### calculate_tile_properties

Calculate values for a list of tile properties at a list of positions. Requests for unrecognized properties will be ignored, so this can also be used to test whether those properties exist.

**Parameters:**

- `positions` ``MapPosition`[]`: Positions for which to calculate property values.
- `property_names` ``string`[]`: Names of properties (`"elevation"`, etc) to calculate.

**Returns:**

- `dictionary<`string`, ``double`[]`>`: Table of property value lists, keyed by property name.

### can_fast_replace

If there exists an entity at the given location that can be fast-replaced with the given entity parameters.

**Parameters:**

- `direction` `defines.direction` _(optional)_: Direction the entity would be placed. Defaults to `north`.
- `force` `ForceID` _(optional)_: The force that would place the entity. Defaults to the `"neutral"` force.
- `name` `EntityID`: Name of the entity to check.
- `position` `MapPosition`: Where the entity would be placed.

**Returns:**

- `boolean`: 

### can_place_entity

Check for collisions with terrain or other entities.

**Parameters:**

- `build_check_type` `defines.build_check_type` _(optional)_: Which type of check should be carried out. Defaults to `ghost_revive`.
- `direction` `defines.direction` _(optional)_: Direction of the placed entity. Defaults to `north`.
- `force` `ForceID` _(optional)_: The force that would place the entity. Defaults to the `"neutral"` force.
- `forced` `boolean` _(optional)_: If `true`, entities that can be marked for deconstruction are ignored. Only used if `build_check_type` is either `manual_ghost`, `script_ghost` or `blueprint_ghost`. Defaults to `false`.
- `inner_name` `string` _(optional)_: The prototype name of the entity contained in the ghost. Only used if `name` is `entity-ghost`.
- `name` `EntityID`: Name of the entity prototype to check.
- `position` `MapPosition`: Where the entity would be placed.

**Returns:**

- `boolean`: 

### cancel_deconstruct_area

Cancel a deconstruction order.

**Parameters:**

- `area` `BoundingBox`: The area to cancel deconstruction orders in.
- `force` `ForceID`: The force whose deconstruction orders to cancel.
- `item` `LuaItemStack` _(optional)_: The deconstruction item to use if any.
- `item_index` `uint` _(optional)_: The index of the undo item to add this action to. An index of `0` creates a new undo item for it. Defaults to putting it into the appropriate undo item automatically if not specified.
- `player` `PlayerIdentification` _(optional)_: The player to set the last_user to, if any.  Also the player whose undo queue this action should be added to.
- `skip_fog_of_war` `boolean` _(optional)_: If chunks covered by fog-of-war are skipped. Defaults to `false`.
- `super_forced` `boolean` _(optional)_: If the cancel deconstruction is super-forced. Defaults to `false`.

### cancel_upgrade_area

Cancel a upgrade order.

**Parameters:**

- `area` `BoundingBox`: The area to cancel upgrade orders in.
- `force` `ForceID`: The force whose upgrade orders to cancel.
- `item` `LuaItemStack`: The upgrade item to use.
- `player` `PlayerIdentification` _(optional)_: The player to set the last_user to if any.
- `skip_fog_of_war` `boolean` _(optional)_: If chunks covered by fog-of-war are skipped.

### clear

Clears this surface deleting all entities and chunks on it.

**Parameters:**

- `ignore_characters` `boolean` _(optional)_: Whether characters on this surface that are connected to or associated with players should be ignored (not destroyed). Defaults to `false`.

### clear_hidden_tiles

Completely removes hidden and double hidden tiles data on this surface.

### clear_pollution

Clears all pollution on this surface.

### clone_area

Clones the given area.

Entities are cloned in an order such that they can always be created, eg rails before trains.

**Parameters:**

- `clear_destination_decoratives` `boolean` _(optional)_: If the destination decoratives should be cleared
- `clear_destination_entities` `boolean` _(optional)_: If the destination entities should be cleared
- `clone_decoratives` `boolean` _(optional)_: If decoratives should be cloned
- `clone_entities` `boolean` _(optional)_: If entities should be cloned
- `clone_tiles` `boolean` _(optional)_: If tiles should be cloned
- `create_build_effect_smoke` `boolean` _(optional)_: If true, the building effect smoke will be shown around the new entities. Defaults to `false`.
- `destination_area` `BoundingBox`: 
- `destination_force` `ForceID` _(optional)_: 
- `destination_surface` `SurfaceIdentification` _(optional)_: 
- `expand_map` `boolean` _(optional)_: If the destination surface should be expanded when destination_area is outside current bounds. Defaults to `false`.
- `source_area` `BoundingBox`: 

### clone_brush

Clones the given area.

[defines.events.on_entity_cloned](runtime:defines.events.on_entity_cloned) is raised for each entity, and then [defines.events.on_area_cloned](runtime:defines.events.on_area_cloned) is raised.

Entities are cloned in an order such that they can always be created, eg rails before trains.

**Parameters:**

- `clear_destination_decoratives` `boolean` _(optional)_: If the destination decoratives should be cleared
- `clear_destination_entities` `boolean` _(optional)_: If the destination entities should be cleared
- `clone_decoratives` `boolean` _(optional)_: If decoratives should be cloned
- `clone_entities` `boolean` _(optional)_: If entities should be cloned
- `clone_tiles` `boolean` _(optional)_: If tiles should be cloned
- `create_build_effect_smoke` `boolean` _(optional)_: If true, the building effect smoke will be shown around the new entities.
- `destination_force`  _(optional)_: 
- `destination_offset` `TilePosition`: 
- `destination_surface` `SurfaceIdentification` _(optional)_: 
- `expand_map` `boolean` _(optional)_: If the destination surface should be expanded when destination_area is outside current bounds. Defaults to `false`.
- `manual_collision_mode` `boolean` _(optional)_: If manual-style collision checks should be done.
- `source_offset` `TilePosition`: 
- `source_positions` ``TilePosition`[]`: 

### clone_entities

Clones the given entities.

Entities are cloned in an order such that they can always be created, eg rails before trains.

**Parameters:**

- `create_build_effect_smoke` `boolean` _(optional)_: If true, the building effect smoke will be shown around the new entities.
- `destination_force` `ForceID` _(optional)_: 
- `destination_offset` `Vector`: 
- `destination_surface` `SurfaceIdentification` _(optional)_: 
- `entities` ``LuaEntity`[]`: 
- `snap_to_grid` `boolean` _(optional)_: 

### count_entities_filtered

Count entities of given type or name in a given area. Works just like [LuaSurface::find_entities_filtered](runtime:LuaSurface::find_entities_filtered), except this only returns the count. As it doesn't construct all the wrapper objects, this is more efficient if one is only interested in the number of entities.

- If no `area` or `position` are given, the entire surface is searched.

- If `position` is given, this returns the entities colliding with that position (i.e the given position is within the entity's collision box).

- If `position` and `radius` are given, this returns entities in the radius of the position.

- If `area` is specified, this returns entities colliding with that area.

**Parameters:**

- `filter` `EntitySearchFilters`: 

**Returns:**

- `uint`: 

### count_tiles_filtered

Count tiles of a given name in a given area. Works just like [LuaSurface::find_tiles_filtered](runtime:LuaSurface::find_tiles_filtered), except this only returns the count. As it doesn't construct all the wrapper objects, this is more efficient if one is only interested in the number of tiles.

If no `area` or `position` and `radius` is given, the entire surface is searched. If `position` and `radius` are given, only tiles within the radius of the position are included.

**Parameters:**

- `filter` `TileSearchFilters`: 

**Returns:**

- `uint`: 

### create_decoratives

Adds the given decoratives to the surface.

This will merge decoratives of the same type that already exist effectively increasing the "amount" field.

**Parameters:**

- `check_collision` `boolean` _(optional)_: If collision should be checked against entities/tiles.
- `decoratives` ``Decorative`[]`: 

### create_entities_from_blueprint_string

This method only works when used in simulations.

Places entities via the given blueprint string. These entities are force-built.

**Parameters:**

- `by_player` `PlayerIdentification` _(optional)_: The player that placed the blueprint. Defaults to `nil`.
- `direction` `defines.direction` _(optional)_: The direction to place the blueprint in. Defaults to north.
- `flip_horizontal` `boolean` _(optional)_: Whether to flip the blueprint horizontally. Defaults to `false`.
- `flip_vertical` `boolean` _(optional)_: Whether to flip the blueprint vertically. Defaults to `false`.
- `force` `ForceID` _(optional)_: The force to place the blueprint for. Defaults to the player force.
- `position` `MapPosition`: The position to place the blueprint at.
- `string` `string`: The blueprint string to import.

**Returns:**

- `int`: If the blueprint string was invalid, `1` is returned. Otherwise, `nil` is returned.

### create_entity

Create an entity on this surface.

**Parameters:**

- `cause`  _(optional)_: Cause entity / force. The entity or force that triggered the chain of events that led to this entity being created. Used for beams, projectiles, stickers, etc. so that the damage receiver can know which entity or force to retaliate against.
- `character` `LuaEntity` _(optional)_: If fast_replace is true simulate fast replace using this character.
- `create_build_effect_smoke` `boolean` _(optional)_: If false, the building effect smoke will not be shown around the new entity. Defaults to `true`.
- `direction` `defines.direction` _(optional)_: Desired orientation of the entity after creation.
- `fast_replace` `boolean` _(optional)_: If true, building will attempt to simulate fast-replace building. Defaults to `false`.
- `force` `ForceID` _(optional)_: Force of the entity, default is enemy.
- `item` `LuaItemStack` _(optional)_: If provided, the entity will attempt to pull stored values from this item (for example; creating a spidertron from a previously named and mined spidertron)
- `item_index` `uint` _(optional)_: The index of the undo item to add this action to. An index of `0` creates a new undo item for it. Defaults to putting it into the appropriate undo item automatically if not specified.
- `move_stuck_players` `boolean` _(optional)_: If true, any characters that are in the way of the entity are teleported out of the way.
- `name` `EntityID`: The entity prototype name to create.
- `player` `PlayerIdentification` _(optional)_: If given set the last_user to this player. If fast_replace is true simulate fast replace using this player. Also the player whose undo queue this action should be added to.
- `position` `MapPosition`: Where to create the entity.
- `preserve_ghosts_and_corpses` `boolean` _(optional)_: If true, colliding ghosts and corpses will not be removed by the creation of some entity types. Defaults to `false`.
- `quality` `QualityID` _(optional)_: Quality of the entity to be created. Defaults to `normal`.
- `raise_built` `boolean` _(optional)_: If true; [defines.events.script_raised_built](runtime:defines.events.script_raised_built) will be fired on successful entity creation. Defaults to `false`.
- `snap_to_grid` `boolean` _(optional)_: If false the exact position given is used to instead of snapping to the normal entity grid. This only applies if the entity normally snaps to the grid.
- `source`  _(optional)_: Source entity. Used for beams, projectiles, and highlight-boxes.
- `spawn_decorations` `boolean` _(optional)_: If true, entity types that have [spawn_decoration](runtime:LuaEntityPrototype::spawn_decorations) property will apply triggers defined in the property. Defaults to `false`.
- `spill` `boolean` _(optional)_: If false while fast_replace is true and player is nil any items from fast-replacing will be deleted instead of dropped on the ground. Defaults to `true`.
- `target`  _(optional)_: Entity with health for the new entity to target.

**Returns:**

- `LuaEntity`: The created entity or `nil` if the creation failed.

### create_global_electric_network

Creates a global electric network for this surface, if one doesn't exist already.

### create_particle

Creates a particle at the given location

**Parameters:**

- `frame_speed` `float`: 
- `height` `float`: 
- `movement` `Vector`: 
- `name` `ParticleID`: The particle name.
- `position` `MapPosition`: Where to create the particle.
- `vertical_speed` `float`: 

### create_trivial_smoke



**Parameters:**

- `name` `TrivialSmokeID`: The smoke prototype name to create.
- `position` `MapPosition`: Where to create the smoke.

### create_unit_group

Create a new unit group at a given position.

**Parameters:**

- `force` `ForceID` _(optional)_: Force of the new unit group. Defaults to `"enemy"`.
- `position` `MapPosition`: Initial position of the new unit group.

**Returns:**

- `LuaCommandable`: 

### deconstruct_area

Place a deconstruction request.

**Parameters:**

- `area` `BoundingBox`: The area to mark for deconstruction.
- `force` `ForceID`: The force whose bots should perform the deconstruction.
- `item` `LuaItemStack` _(optional)_: The deconstruction item to use if any.
- `player` `PlayerIdentification` _(optional)_: The player to set the last_user to if any.
- `skip_fog_of_war` `boolean` _(optional)_: If chunks covered by fog-of-war are skipped. Defaults to `false`.
- `super_forced` `boolean` _(optional)_: If the deconstruction is super-forced. Defaults to `false`.

### decorative_prototype_collides

Whether the given decorative prototype collides at the given position and direction.

**Parameters:**

- `position` `MapPosition`: The position to check.
- `prototype` `DecorativeID`: The decorative prototype to check.

**Returns:**

- `boolean`: 

### delete_chunk



**Parameters:**

- `position` `ChunkPosition`: The chunk position to delete

### destroy_decoratives

Removes all decoratives from the given area. If no area and no position are given, then the entire surface is searched.

**Parameters:**

- `area` `BoundingBox` _(optional)_: 
- `collision_mask`  _(optional)_: 
- `exclude_soft` `boolean` _(optional)_: Soft decoratives can be drawn over rails.
- `from_layer` `string` _(optional)_: 
- `invert` `boolean` _(optional)_: If the filters should be inverted.
- `limit` `uint` _(optional)_: 
- `name`  _(optional)_: 
- `position` `TilePosition` _(optional)_: 
- `to_layer` `string` _(optional)_: 

### destroy_global_electric_network

Destroys the global electric network for this surface, if it exists.

### edit_script_area

Sets the given script area to the new values.

**Parameters:**

- `area` `ScriptArea`: 
- `id` `uint`: The area to edit.

### edit_script_position

Sets the given script position to the new values.

**Parameters:**

- `id` `uint`: The position to edit.
- `position` `ScriptPosition`: 

### entity_prototype_collides

Whether the given entity prototype collides at the given position and direction.

**Parameters:**

- `direction` `defines.direction` _(optional)_: 
- `position` `MapPosition`: The position to check.
- `prototype` `EntityID`: The entity prototype to check.
- `use_map_generation_bounding_box` `boolean`: If the map generation bounding box should be used instead of the collision bounding box.

**Returns:**

- `boolean`: 

### execute_lightning

Creates lightning. If other entities which can be lightning targets are nearby, the final position will be adjusted.

**Parameters:**

- `name` `EntityID`: 
- `position` `MapPosition`: 

### find_closest_logistic_network_by_position

Find the logistic network with a cell closest to a given position.

**Parameters:**

- `force` `ForceID`: Force the logistic network should belong to.
- `position` `MapPosition`: 

**Returns:**

- `LuaLogisticNetwork`: The found network or `nil` if no such network was found.

### find_decoratives_filtered

Find decoratives of a given name in a given area.

If no filters are given, returns all decoratives in the search area. If multiple filters are specified, returns only decoratives matching every given filter. If no area and no position are given, the entire surface is searched.

**Parameters:**

- `area` `BoundingBox` _(optional)_: 
- `collision_mask`  _(optional)_: 
- `exclude_soft` `boolean` _(optional)_: Soft decoratives can be drawn over rails.
- `from_layer` `string` _(optional)_: 
- `invert` `boolean` _(optional)_: If the filters should be inverted.
- `limit` `uint` _(optional)_: 
- `name`  _(optional)_: 
- `position` `TilePosition` _(optional)_: 
- `to_layer` `string` _(optional)_: 

**Returns:**

- ``DecorativeResult`[]`: 

### find_enemy_units

Find enemy units (entities with type "unit") of a given force within an area.

This is more efficient than [LuaSurface::find_entities](runtime:LuaSurface::find_entities).

**Parameters:**

- `center` `MapPosition`: Center of the search area
- `force` `ForceID` _(optional)_: Force to find enemies of. If not given, uses the player force.
- `radius` `double`: Radius of the circular search area

**Returns:**

- ``LuaEntity`[]`: 

### find_entities

Find entities in a given area.

If no area is given all entities on the surface are returned.

**Parameters:**

- `area` `BoundingBox` _(optional)_: 

**Returns:**

- ``LuaEntity`[]`: 

### find_entities_filtered

Find all entities of the given type or name in the given area.

If no filters (`name`, `type`, `force`, etc.) are given, this returns all entities in the search area. If multiple filters are specified, only entities matching all given filters are returned.

- If no `area` or `position` are given, the entire surface is searched.

- If `position` is given, this returns the entities colliding with that position (i.e the given position is within the entity's collision box).

- If `position` and `radius` are given, this returns the entities within the radius of the position. Looks for the center of entities.

- If `area` is specified, this returns the entities colliding with that area.

**Parameters:**

- `filter` `EntitySearchFilters`: 

**Returns:**

- ``LuaEntity`[]`: 

### find_entity

Find an entity of the given name at the given position. This checks both the exact position and the bounding box of the entity.

**Parameters:**

- `entity` `EntityWithQualityID`: Name of the entity to look for.
- `position` `MapPosition`: Coordinates to look at.

**Returns:**

- `LuaEntity`: `nil` if no such entity is found.

### find_logistic_network_by_position

Find the logistic network that covers a given position.

**Parameters:**

- `force` `ForceID`: Force the logistic network should belong to.
- `position` `MapPosition`: 

**Returns:**

- `LuaLogisticNetwork`: The found network or `nil` if no such network was found.

### find_logistic_networks_by_construction_area

Finds all of the logistics networks whose construction area intersects with the given position.

**Parameters:**

- `force` `ForceID`: Force the logistic networks should belong to.
- `position` `MapPosition`: 

**Returns:**

- ``LuaLogisticNetwork`[]`: 

### find_nearest_enemy

Find the enemy military target ([military entity](https://wiki.factorio.com/Military_units_and_structures)) closest to the given position.

**Parameters:**

- `force` `ForceID` _(optional)_: The force the result will be an enemy of. Uses the player force if not specified.
- `max_distance` `double`: Radius of the circular search area.
- `position` `MapPosition`: Center of the search area.

**Returns:**

- `LuaEntity`: The nearest enemy military target or `nil` if no enemy could be found within the given area.

### find_nearest_enemy_entity_with_owner

Find the enemy entity-with-owner closest to the given position.

**Parameters:**

- `force` `ForceID` _(optional)_: The force the result will be an enemy of. Uses the player force if not specified.
- `max_distance` `double`: Radius of the circular search area.
- `position` `MapPosition`: Center of the search area.

**Returns:**

- `LuaEntity`: The nearest enemy entity-with-owner or `nil` if no enemy could be found within the given area.

### find_non_colliding_position

Find a non-colliding position within a given radius.

Special care needs to be taken when using a radius of `0`. The game will not stop searching until it finds a suitable position, so it is important to make sure such a position exists. One particular case where it would not be able to find a solution is running it before any chunks have been generated.

**Parameters:**

- `center` `MapPosition`: Center of the search area.
- `force_to_tile_center` `boolean` _(optional)_: Will only check tile centers. This can be useful when your intent is to place a building at the resulting position, as they must generally be placed at tile centers. Defaults to `false`.
- `name` `EntityID`: Prototype name of the entity to find a position for. (The bounding box for the collision checking is taken from this prototype.)
- `precision` `double`: The step length from the given position as it searches, in tiles. Minimum value is `0.01`.
- `radius` `double`: Max distance from `center` to search in. A radius of `0` means an infinitely-large search area.

**Returns:**

- `MapPosition`: The non-colliding position. May be `nil` if no suitable position was found.

### find_non_colliding_position_in_box

Find a non-colliding position within a given rectangle.

**Parameters:**

- `force_to_tile_center` `boolean` _(optional)_: Will only check tile centers. This can be useful when your intent is to place a building at the resulting position, as they must generally be placed at tile centers. Defaults to `false`.
- `name` `EntityID`: Prototype name of the entity to find a position for. (The bounding box for the collision checking is taken from this prototype.)
- `precision` `double`: The step length from the given position as it searches, in tiles. Minimum value is 0.01.
- `search_space` `BoundingBox`: The rectangle to search inside.

**Returns:**

- `MapPosition`: The non-colliding position. May be `nil` if no suitable position was found.

### find_tiles_filtered

Find all tiles of the given name in the given area.

If no filters are given, this returns all tiles in the search area.

If no `area` or `position` and `radius` is given, the entire surface is searched. If `position` and `radius` are given, only tiles within the radius of the position are included.

**Parameters:**

- `filter` `TileSearchFilters`: 

**Returns:**

- ``LuaTile`[]`: 

### find_units

Find units (entities with type "unit") of a given force and force condition within a given area.

This is more efficient than [LuaSurface::find_entities](runtime:LuaSurface::find_entities).

**Parameters:**

- `area` `BoundingBox`: Box to find units within.
- `condition` `ForceCondition`: Only forces which meet the condition will be included in the search.
- `force` `ForceID`: Force performing the search.

**Returns:**

- ``LuaEntity`[]`: 

### force_generate_chunk_requests

Blocks and generates all chunks that have been requested using all available threads.

### get_chunks

Get an iterator going over every chunk on this surface.

**Returns:**

- `LuaChunkIterator`: 

### get_closest

Gets the closest entity in the list to this position.

**Parameters:**

- `entities` ``LuaEntity`[]`: The Entities to check.
- `position` `MapPosition`: 

**Returns:**

- `LuaEntity`: 

### get_connected_tiles

Gets all tiles of the given types that are connected horizontally or vertically to the given tile position including the given tile position.

This won't find tiles in non-generated chunks.

**Parameters:**

- `area` `BoundingBox` _(optional)_: The area to find connected tiles in. If provided the start position must be in this area.
- `include_diagonal` `boolean` _(optional)_: Include tiles that are connected diagonally.
- `position` `TilePosition`: The tile position to start at.
- `tiles` ``TileID`[]`: The tiles to search for.

**Returns:**

- ``TilePosition`[]`: The resulting set of tiles.

### get_double_hidden_tile

The double hidden tile name or `nil` if there isn't one for the given position.

**Parameters:**

- `position` `TilePosition`: The tile position.

**Returns:**

- `string`: 

### get_entities_with_force

Returns all the military targets (entities with force) on this chunk for the given force.

**Parameters:**

- `force` `ForceID`: Entities of this force will be returned.
- `position` `ChunkPosition`: The chunk's position.

**Returns:**

- ``LuaEntity`[]`: 

### get_hidden_tile

The hidden tile name.

**Parameters:**

- `position` `TilePosition`: The tile position.

**Returns:**

- `string`: `nil` if there isn't one for the given position.

### get_map_exchange_string

Gets the map exchange string for the current map generation settings of this surface.

**Returns:**

- `string`: 

### get_pollution

Get the pollution for a given position.

Pollution is stored per chunk, so this will return the same value for all positions in one chunk.

**Parameters:**

- `position` `MapPosition`: The position to poll the chunk's pollution

**Returns:**

- `double`: 

### get_property

Gets the value of surface property on this surface.

**Parameters:**

- `property` `SurfacePropertyID`: Property to read.

**Returns:**

- `double`: Value of the property.

### get_random_chunk

Gets a random generated chunk position or 0,0 if no chunks have been generated on this surface.

**Returns:**

- `ChunkPosition`: 

### get_resource_counts

Gets the resource amount of all resources on this surface

**Returns:**

- `dictionary<`string`, `uint`>`: 

### get_script_area

Gets the first script area by name or id.

**Parameters:**

- `key`  _(optional)_: The name or id of the area to get.

**Returns:**

- `ScriptArea`: 

### get_script_areas

Gets the script areas that match the given name or if no name is given all areas are returned.

**Parameters:**

- `name` `string` _(optional)_: 

**Returns:**

- ``ScriptArea`[]`: 

### get_script_position

Gets the first script position by name or id.

**Parameters:**

- `key`  _(optional)_: The name or id of the position to get.

**Returns:**

- `ScriptPosition`: 

### get_script_positions

Gets the script positions that match the given name or if no name is given all positions are returned.

**Parameters:**

- `name` `string` _(optional)_: 

**Returns:**

- ``ScriptPosition`[]`: 

### get_starting_area_radius

Gets the starting area radius of this surface.

**Returns:**

- `double`: 

### get_tile

Get the tile at a given position. An alternative call signature for this method is passing it a single [TilePosition](runtime:TilePosition).

Non-integer values will result in them being rounded down.

**Parameters:**

- `x` `int`: 
- `y` `int`: 

**Returns:**

- `LuaTile`: 

### get_total_pollution

Gets the total amount of pollution on the surface by iterating over all the chunks containing pollution.

**Returns:**

- `double`: 

### is_chunk_generated

Is a given chunk generated?

**Parameters:**

- `position` `ChunkPosition`: The chunk's position.

**Returns:**

- `boolean`: 

### play_sound

Play a sound for every player on this surface.

The sound is not played if its location is not [charted](runtime:LuaForce::chart) for that player.

**Parameters:**

- `sound_specification` `PlaySoundSpecification`: The sound to play.

### pollute

Spawn pollution at the given position.

**Parameters:**

- `amount` `double`: How much pollution to add.
- `prototype` `EntityID` _(optional)_: The entity prototype to attribute the pollution change to in statistics. If not defined, the pollution change will not show up in statistics.
- `source` `MapPosition`: Where to spawn the pollution.

### print

Print text to the chat console of all players on this surface.

By default, messages that are identical to a message sent in the last 60 ticks are not printed again.

**Parameters:**

- `message` `LocalisedString`: 
- `print_settings` `PrintSettings` _(optional)_: 

### regenerate_decorative

Regenerate autoplacement of some decoratives on this surface. This can be used to autoplace newly-added decoratives.

All specified decorative prototypes must be autoplacable. If nothing is given all decoratives are generated on all chunks.

**Parameters:**

- `chunks` ``ChunkPosition`[]` _(optional)_: The chunk positions to regenerate the decoratives on. If not given all chunks are regenerated. Note chunks with status < entities are ignored.
- `decoratives`  _(optional)_: Prototype names of decorative or decoratives to autoplace. When `nil` all decoratives with an autoplace are used.

### regenerate_entity

Regenerate autoplacement of some entities on this surface. This can be used to autoplace newly-added entities.

All specified entity prototypes must be autoplacable. If nothing is given all entities are generated on all chunks.

**Parameters:**

- `chunks` ``ChunkPosition`[]` _(optional)_: The chunk positions to regenerate the entities on. If not given all chunks are regenerated. Note chunks with status < entities are ignored.
- `entities`  _(optional)_: Prototype names of entity or entities to autoplace. When `nil` all entities with an autoplace are used.

### remove_script_area

Removes the given script area.

**Parameters:**

- `id` `uint`: 

**Returns:**

- `boolean`: If the area was actually removed. False when it didn't exist.

### remove_script_position

Removes the given script position.

**Parameters:**

- `id` `uint`: 

**Returns:**

- `boolean`: If the position was actually removed. False when it didn't exist.

### request_path

Generates a path with the specified constraints (as an array of [PathfinderWaypoints](runtime:PathfinderWaypoint)) using the unit pathfinding algorithm. This path can be used to emulate pathing behavior by script for non-unit entities, such as vehicles. If you want to command actual units (such as biters or spitters) to move, use [LuaCommandable::set_command](runtime:LuaCommandable::set_command) via [LuaEntity::commandable](runtime:LuaEntity::commandable) instead.

The resulting path is ultimately returned asynchronously via [on_script_path_request_finished](runtime:on_script_path_request_finished).

**Parameters:**

- `bounding_box` `BoundingBox`: The dimensions of the object that's supposed to travel the path.
- `can_open_gates` `boolean` _(optional)_: Whether the path request can open gates. Defaults to `false`.
- `collision_mask` `CollisionMask`: The collision mask the `bounding_box` collides with.
- `entity_to_ignore` `LuaEntity` _(optional)_: Makes the pathfinder ignore collisions with this entity if it is given.
- `force` `ForceID`: The force for which to generate the path, determining which gates can be opened for example.
- `goal` `MapPosition`: The position to find a path to.
- `max_attack_distance` `double` _(optional)_: Defines the maximum allowed distance between the last traversable path waypoint and an obstacle entity to be destroyed. Only used when finding a discontiguous path, i.e. when `max_gap_size` > 0. This field filters out paths that are blocked by obstacles that are outside the entity's attack range. Allowed values are `0` or greater. Defaults to `max_gap_size`.
- `max_gap_size` `int` _(optional)_: Defines the maximum allowed distance between path waypoints. 0 means that paths must be contiguous (as they are for biters). Values greater than 0 will produce paths with "gaps" that are suitable for spiders. Allowed values are from `0` to `31`. Defaults to `0`.
- `path_resolution_modifier` `int` _(optional)_: Defines how coarse the pathfinder's grid is, where smaller values mean a coarser grid. Defaults to `0`, which equals a resolution of `1x1` tiles, centered on tile centers. Values range from `-8` to `8` inclusive, where each integer increment doubles/halves the resolution. So, a resolution of `-8` equals a grid of `256x256` tiles, and a resolution of `8` equals `1/256` of a tile.
- `pathfind_flags` `PathfinderFlags` _(optional)_: Flags that affect pathfinder behavior.
- `radius` `double` _(optional)_: How close the pathfinder needs to get to its `goal` (in tiles). Defaults to `1`.
- `start` `MapPosition`: The position from which to start pathfinding.

**Returns:**

- `uint`: A unique handle to identify this call when [on_script_path_request_finished](runtime:on_script_path_request_finished) fires.

### request_to_generate_chunks

Request that the game's map generator generate chunks at the given position for the given radius on this surface. If the radius is `0`, then only the chunk at the given position is generated.

**Parameters:**

- `position` `MapPosition`: Where to generate the new chunks.
- `radius` `uint` _(optional)_: The chunk radius from `position` to generate new chunks in. Defaults to `0`.

### set_chunk_generated_status

Set generated status of a chunk. Useful when copying chunks.

**Parameters:**

- `position` `ChunkPosition`: The chunk's position.
- `status` `defines.chunk_generated_status`: The chunk's new status.

### set_double_hidden_tile

Set double hidden tile for the specified position. During normal gameplay, only [non-mineable](runtime:LuaTilePrototype::mineable_properties) tiles can become double hidden.

Does nothing if hidden tile at specified position does not exist.

**Parameters:**

- `position` `TilePosition`: The tile position.
- `tile` `TileID` _(optional)_: The new double hidden tile or `nil` to clear the double hidden tile.

### set_hidden_tile

Set the hidden tile for the specified position. While during normal gameplay only [non-mineable](runtime:LuaTilePrototype::mineable_properties) or [foundation](runtime:LuaTilePrototype::is_foundation) tiles can become hidden, this method allows any kind of tile to be set as the hidden one.

**Parameters:**

- `position` `TilePosition`: The tile position.
- `tile` `TileID` _(optional)_: The new hidden tile or `nil` to clear the hidden tile.

### set_multi_command

Give a command to multiple units. This will automatically select suitable units for the task.

**Parameters:**

- `command` `Command`: 
- `force` `ForceID` _(optional)_: Force of the units this command is to be given to. If not specified, uses the enemy force.
- `unit_count` `uint`: Number of units to give the command to.
- `unit_search_distance` `uint` _(optional)_: Radius to search for units. The search area is centered on the destination of the command. If not specified uses default value of 150.

**Returns:**

- `uint`: Number of units actually sent. May be less than `count` if not enough units were available.

### set_pollution

Set the pollution for a given position.

Pollution changes by this are not included in pollution statistics and do not affect evolution factors (as opposed to [LuaSurface::pollute](runtime:LuaSurface::pollute)).

**Parameters:**

- `amount` `double`: New amount of pollution to be set on the chunk. Must be >= 0.
- `position` `MapPosition`: The position to set the chunk's pollution

### set_property

Sets the value of surface property on this surface.

**Parameters:**

- `property` `SurfacePropertyID`: Property to change.
- `value` `double`: The wanted value of the property.

### set_tiles

Set tiles at specified locations. Can automatically correct the edges around modified tiles.

Placing a [mineable](runtime:LuaTilePrototype::mineable_properties) tile on top of a non-mineable or [foundation](runtime:LuaTilePrototype::is_foundation) one will turn the latter into the [LuaTile::hidden_tile](runtime:LuaTile::hidden_tile) for that tile. Placing a mineable non-foundation tile on a mineable non-foundation one or a mineable foundation tile on a mineable foundation one will not modify the hidden tile. This restriction can however be circumvented by using [LuaSurface::set_hidden_tile](runtime:LuaSurface::set_hidden_tile). Placing a non-foundation tile on top of a foundation one when there already exists a hidden tile will push hidden tile to [double hidden](runtime:LuaTile::double_hidden_tile), and foundation tile will turn into hidden. Placing a mineable foundation tile over a mineable non-foundation tile with hidden mineable foundation tile, the hidden tile will be replaced by previously double hidden tile and double hidden tile will be erased. Placing a non-mineable tile will erase hidden and double hidden tiles.

It is recommended to call this method once for all the tiles you want to change rather than calling it individually for every tile. As the tile correction is used after every step, calling it one by one could cause the tile correction logic to redo some of the changes. Also, many small API calls are generally more performance intensive than one big one.

**Parameters:**

- `correct_tiles` `boolean` _(optional)_: If `false`, the correction logic is not applied to the changed tiles. Defaults to `true`.
- `player` `PlayerIdentification` _(optional)_: The player whose undo queue to add these actions to.
- `raise_event` `boolean` _(optional)_: Defaults to `false`.
- `remove_colliding_decoratives` `boolean` _(optional)_: Defaults to `true`.
- `remove_colliding_entities`  _(optional)_: Defaults to `true`.
- `tiles` ``Tile`[]`: 
- `undo_index` `uint` _(optional)_: The index of the undo item to add this action to. An index of `0` creates a new undo item for it. Defaults to putting it into the appropriate undo item automatically if not specified.

### spill_inventory

Spill inventory on the ground centered at a given location.

**Parameters:**

- `allow_belts` `boolean` _(optional)_: Whether items can be spilled onto belts. Defaults to `true`.
- `drop_full_stack` `boolean` _(optional)_: If item on ground should be made out of an entire provided stack. Defaults to `false`.
- `enable_looted` `boolean` _(optional)_: When true, each created item will be flagged with the [LuaEntity::to_be_looted](runtime:LuaEntity::to_be_looted) flag. Defaults to `false`.
- `force` `ForceID` _(optional)_: When provided (and not `nil`) the items will be marked for deconstruction by this force.
- `inventory` `LuaInventory`: Inventory to spill
- `max_radius` `double` _(optional)_: Max radius from the specified `position` to spill items.
- `position` `MapPosition`: Center of the spillage
- `use_start_position_on_failure` `boolean` _(optional)_: Allow spilling items at `position` if no non-colliding position is found. Note: Setting to false might cause some items not to be spilled. Defaults to `true`.

**Returns:**

- ``LuaEntity`[]`: The created item-on-ground entities.

### spill_item_stack

Spill items on the ground centered at a given location.

**Parameters:**

- `allow_belts` `boolean` _(optional)_: Whether items can be spilled onto belts. Defaults to `true`.
- `drop_full_stack` `boolean` _(optional)_: If item on ground should be made out of an entire provided stack. Defaults to `false`.
- `enable_looted` `boolean` _(optional)_: When true, each created item will be flagged with the [LuaEntity::to_be_looted](runtime:LuaEntity::to_be_looted) flag. Defaults to `false`.
- `force` `ForceID` _(optional)_: When provided (and not `nil`) the items will be marked for deconstruction by this force.
- `max_radius` `double` _(optional)_: Max radius from the specified `position` to spill items.
- `position` `MapPosition`: Center of the spillage
- `stack` `ItemStackIdentification`: Stack of items to spill
- `use_start_position_on_failure` `boolean` _(optional)_: Allow spilling items at `position` if no non-colliding position is found. Note: Setting to false might cause some items not to be spilled. Defaults to `true`.

**Returns:**

- ``LuaEntity`[]`: The created item-on-ground entities.

### upgrade_area

Place an upgrade request.

**Parameters:**

- `area` `BoundingBox`: The area to mark for upgrade.
- `force` `ForceID`: The force whose bots should perform the upgrade.
- `item` `LuaItemStack`: The upgrade item to use.
- `player` `PlayerIdentification` _(optional)_: The player to set the last_user to if any.
- `skip_fog_of_war` `boolean` _(optional)_: If chunks covered by fog-of-war are skipped.

## Attributes

### always_day

**Type:** `boolean`

When set to true, the sun will always shine.

### brightness_visual_weights

**Type:** `ColorModifier`

Defines how surface daytime brightness influences each color channel of the current color lookup table (LUT).

The LUT is multiplied by `((1 - weight) + brightness * weight)` and result is clamped to range `[0, 1]`.

Default is `{0, 0, 0}`, which means no influence.

### darkness

**Type:** `float` _(read-only)_

Amount of darkness at the current time, as a number in range `[0, 1]`.

### dawn

**Type:** `double`

The daytime when dawn starts.

### daytime

**Type:** `double`

Current time of day, as a number in range `[0, 1)`.

### daytime_parameters

**Type:** `unknown`

Parameters of daytime. Equivalent as reading [dusk](runtime:LuaSurface::dusk), [evening](runtime:LuaSurface::evening), [morning](runtime:LuaSurface::morning) and [dawn](runtime:LuaSurface::dawn) at the same time.

In order for a write to take place, a new table needs to be written in one go: changing individual members of the returned table has no effect as those are value copies.

### deletable

**Type:** `boolean` _(read-only)_

If this surface can be deleted.

### dusk

**Type:** `double`

The daytime when dusk starts.

### evening

**Type:** `double`

The daytime when evening starts.

### freeze_daytime

**Type:** `boolean`

True if daytime is currently frozen.

### generate_with_lab_tiles

**Type:** `boolean`

When set to true, new chunks will be generated with lab tiles, instead of using the surface's map generation settings.

### global_effect

**Type:** `ModuleEffects`

Surface-wide effects applied to entities with effect receivers. `nil` if this surface is not using surface-wide effect source.

### global_electric_network_statistics

**Type:** `LuaFlowStatistics` _(read-only)_

The global electric network statistics for this surface.

### has_global_electric_network

**Type:** `boolean` _(read-only)_

Whether this surface currently has a global electric network.

### ignore_surface_conditions

**Type:** `boolean`

If surface condition checks should not be performed on this surface.

### index

**Type:** `uint` _(read-only)_

This surface's index in [LuaGameScript::surfaces](runtime:LuaGameScript::surfaces) (unique ID). It is assigned when a surface is created, and remains so until it is [deleted](runtime:on_surface_deleted). Indexes of deleted surfaces can be reused.

### localised_name

**Type:** `LocalisedString`

Localised name of this surface. When set, will replace the internal surface name in places where a player sees surface name.

Value may be ignored if a surface has a SpacePlatform or Planet object attached to it, which take the precedence.

### map_gen_settings

**Type:** `MapGenSettings`

The generation settings for this surface. These can be modified after surface generation, but note that this will not retroactively update the surface. To manually regenerate it, [LuaSurface::regenerate_entity](runtime:LuaSurface::regenerate_entity), [LuaSurface::regenerate_decorative](runtime:LuaSurface::regenerate_decorative), and [LuaSurface::delete_chunk](runtime:LuaSurface::delete_chunk) can be used.

### min_brightness

**Type:** `double`

The minimal brightness during the night. Defaults to `0.15`. This has an effect on both rendering and game mechanics such as biter spawns and solar power.

### morning

**Type:** `double`

The daytime when morning starts.

### name

**Type:** `string`

The name of this surface. Names are unique among surfaces.

The default surface can't be renamed.

### no_enemies_mode

**Type:** `boolean`

Is no-enemies mode enabled on this surface?

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### peaceful_mode

**Type:** `boolean`

Is peaceful mode enabled on this surface?

### planet

**Type:** `LuaPlanet` _(read-only)_

The planet associated with this surface, if there is one.

Use [LuaPlanet::associate_surface](runtime:LuaPlanet::associate_surface) to create a new association with a planet.

### platform

**Type:** `LuaSpacePlatform` _(read-only)_



### pollutant_type

**Type:** `LuaAirbornePollutantPrototype` _(read-only)_

The type of pollutant enabled on the surface, or `nil` if no pollutant is enabled.

### pollution_statistics

**Type:** `LuaFlowStatistics` _(read-only)_

The pollution statistics for this surface.

### show_clouds

**Type:** `boolean`

If clouds are shown on this surface. If false, clouds are never shown. If true the player must also have clouds enabled in graphics settings for them to be shown.

### solar_power_multiplier

**Type:** `double`

The multiplier of solar power on this surface. Cannot be less than 0.

### ticks_per_day

**Type:** `uint`

The number of ticks per day for this surface.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

### wind_orientation

**Type:** `RealOrientation`

Current wind direction.

### wind_orientation_change

**Type:** `double`

Change in wind orientation per tick.

### wind_speed

**Type:** `double`

Current wind speed in tiles per tick.

