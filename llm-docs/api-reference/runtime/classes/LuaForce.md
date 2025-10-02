# LuaForce

`LuaForce` encapsulates data local to each "force" or "faction" of the game. Default forces are player, enemy and neutral. Players and mods can create additional forces (up to 64 total).

## Attributes

### name

Name of the force.

**Read type:** `string`

### technologies

Technologies owned by this force, indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaTechnology`]

### recipes

Recipes available to this force, indexed by `name`.

**Read type:** LuaCustomTable[`string`, `LuaRecipe`]

### manual_mining_speed_modifier

Multiplier of the manual mining speed. Default value is `0`. The actual mining speed will be multiplied by `1 + manual_mining_speed_modifier`.

**Read type:** `double`

**Write type:** `double`

### manual_crafting_speed_modifier

Multiplier of the manual crafting speed. Default value is `0`. The actual crafting speed will be multiplied by `1 + manual_crafting_speed_modifier`.

**Read type:** `double`

**Write type:** `double`

### laboratory_speed_modifier

**Read type:** `double`

**Write type:** `double`

### laboratory_productivity_bonus

**Read type:** `double`

**Write type:** `double`

### worker_robots_speed_modifier

**Read type:** `double`

**Write type:** `double`

### worker_robots_battery_modifier

**Read type:** `double`

**Write type:** `double`

### worker_robots_storage_bonus

**Read type:** `double`

**Write type:** `double`

### current_research

The currently ongoing technology research, if any.

**Read type:** `LuaTechnology`

**Optional:** Yes

### research_progress

Progress of current research, as a number in range `[0, 1]`.

**Read type:** `double`

**Write type:** `double`

### previous_research

The previous research, if any.

**Read type:** `LuaTechnology`

**Write type:** `LuaTechnology`

**Optional:** Yes

### inserter_stack_size_bonus

The inserter stack size bonus for non stack inserters

**Read type:** `double`

**Write type:** `double`

### bulk_inserter_capacity_bonus

Number of items that can be transferred by bulk inserters. When writing to this value, it must be >= 0 and <= 254.

**Read type:** `uint`

**Write type:** `uint`

### belt_stack_size_bonus

Belt stack size bonus.

**Read type:** `uint`

**Write type:** `uint`

### character_trash_slot_count

Number of character trash slots.

**Read type:** `double`

**Write type:** `double`

### maximum_following_robot_count

Maximum number of follower robots.

**Read type:** `uint`

**Write type:** `uint`

### following_robots_lifetime_modifier

Additional lifetime for following robots.

**Read type:** `double`

**Write type:** `double`

### create_ghost_on_entity_death

When an entity dies, a ghost will be placed for automatic reconstruction.

**Read type:** `boolean`

**Write type:** `boolean`

### circuit_network_enabled

**Read type:** `boolean`

**Write type:** `boolean`

### cliff_deconstruction_enabled

When true, cliffs will be marked for deconstruction when trying to force-build things that collide.

**Read type:** `boolean`

**Write type:** `boolean`

### mining_with_fluid

**Read type:** `boolean`

**Write type:** `boolean`

### rail_support_on_deep_oil_ocean

**Read type:** `boolean`

**Write type:** `boolean`

### rail_planner_allow_elevated_rails

**Read type:** `boolean`

**Write type:** `boolean`

### vehicle_logistics

When true, cars/tanks that support logistics will be able to use them.

**Read type:** `boolean`

**Write type:** `boolean`

### players

Players belonging to this force.

**Read type:** Array[`LuaPlayer`]

### ai_controllable

Enables some higher-level AI behaviour for this force. When set to `true`, biters belonging to this force will automatically expand into new territories, build new spawners, and form unit groups. By default, this value is `true` for the enemy force and `false` for all others.

Setting this to `false` does not turn off biters' AI. They will still move around and attack players who come close.

It is necessary for a force to be AI controllable in order to be able to create unit groups or build bases from scripts.

**Read type:** `boolean`

**Write type:** `boolean`

### logistic_networks

List of logistic networks, grouped by surface.

**Read type:** Dictionary[`string`, Array[`LuaLogisticNetwork`]]

### character_running_speed_modifier

Modifies the running speed of all characters in this force by the given value as a percentage. Setting the running modifier to `0.5` makes the character run 50% faster. The minimum value of `-1` reduces the movement speed by 100%, resulting in a speed of `0`.

**Read type:** `double`

**Write type:** `double`

### artillery_range_modifier

**Read type:** `double`

**Write type:** `double`

### beacon_distribution_modifier

**Read type:** `double`

**Write type:** `double`

### character_build_distance_bonus

**Read type:** `uint`

**Write type:** `uint`

### character_item_drop_distance_bonus

**Read type:** `uint`

**Write type:** `uint`

### character_reach_distance_bonus

**Read type:** `uint`

**Write type:** `uint`

### character_resource_reach_distance_bonus

**Read type:** `double`

**Write type:** `double`

### character_item_pickup_distance_bonus

**Read type:** `double`

**Write type:** `double`

### character_loot_pickup_distance_bonus

**Read type:** `double`

**Write type:** `double`

### character_inventory_slots_bonus

The number of additional inventory slots the character main inventory has.

**Read type:** `uint`

**Write type:** `uint`

### deconstruction_time_to_live

The time, in ticks, before a deconstruction order is removed.

**Read type:** `uint`

**Write type:** `uint`

### character_health_bonus

**Read type:** `double`

**Write type:** `double`

### max_successful_attempts_per_tick_per_construction_queue

**Read type:** `uint`

**Write type:** `uint`

### max_failed_attempts_per_tick_per_construction_queue

**Read type:** `uint`

**Write type:** `uint`

### character_logistic_requests

`true` if character requester logistics is enabled.

**Read type:** `boolean`

**Write type:** `boolean`

### rockets_launched

The number of rockets launched.

**Read type:** `uint`

**Write type:** `uint`

### items_launched

All of the items that have been launched in rockets.

**Read type:** Dictionary[`string`, `ItemCountType`]

### connected_players

The connected players belonging to this force.

This is primarily useful when you want to do some action against all online players of this force.

This does *not* index using player index. See [LuaPlayer::index](runtime:LuaPlayer::index) on each player instance for the player index.

**Read type:** Array[`LuaPlayer`]

### mining_drill_productivity_bonus

**Read type:** `double`

**Write type:** `double`

### train_braking_force_bonus

**Read type:** `double`

**Write type:** `double`

### friendly_fire

If friendly fire is enabled for this force.

**Read type:** `boolean`

**Write type:** `boolean`

### share_chart

If sharing chart data is enabled for this force.

**Read type:** `boolean`

**Write type:** `boolean`

### index

This force's index in [LuaGameScript::forces](runtime:LuaGameScript::forces) (unique ID). It is assigned when a force is created, and remains so until it is [merged](runtime:on_forces_merged) (ie. deleted). Indexes of merged forces can be reused.

**Read type:** `uint`

### research_queue

The research queue of this force. The first technology in the array is the currently active one. Reading this attribute gives an array of [LuaTechnology](runtime:LuaTechnology).

To write to this, the entire table must be written. Providing an empty table or `nil` will empty the research queue and cancel the current research.  Writing to this when the research queue is disabled will simply set the last research in the table as the current research.

This only allows mods to queue research that this force is able to research in the first place. As an example, an already researched technology or one whose prerequisites are not fulfilled will not be queued, but dropped silently instead.

**Read type:** Array[`TechnologyID`]

**Write type:** Array[`TechnologyID`]

### research_enabled

Whether research is enabled for this force, see [LuaForce::enable_research](runtime:LuaForce::enable_research) and [LuaForce::disable_research](runtime:LuaForce::disable_research).

**Read type:** `boolean`

### platforms

The space platforms that belong to this force mapped by their index value.

This will include platforms that are pending deletion.

**Read type:** Dictionary[`uint`, `LuaSpacePlatform`]

### custom_color

Custom color for this force. If specified, will take priority over other sources of the force color. Writing `nil` clears custom color. Will return `nil` if it was not specified or if was set to `{0,0,0,0}`.

**Read type:** `Color`

**Write type:** `Color`

**Optional:** Yes

### color

Effective color of this force.

**Read type:** `Color`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### get_entity_count

Count entities of given type.

This function has O(1) time complexity as entity counts are kept and maintained in the game engine.

**Parameters:**

- `name` `EntityID` - Prototype name of the entity.

**Returns:**

- `uint` - Number of entities of given prototype belonging to this force.

### disable_research

Disable research for this force.

### enable_research

Enable research for this force.

### disable_all_prototypes

Disable all recipes and technologies. Only recipes and technologies enabled explicitly will be useable from this point.

### enable_all_prototypes

Enables all recipes and technologies. The opposite of [LuaForce::disable_all_prototypes](runtime:LuaForce::disable_all_prototypes).

### reset_recipes

Load the original version of all recipes from the prototypes.

### enable_all_recipes

Unlock all recipes.

### enable_all_technologies

Unlock all technologies.

### research_all_technologies

Research all technologies.

**Parameters:**

- `include_disabled_prototypes` `boolean` *(optional)* - Whether technologies that are explicitly disabled in the prototype should also be researched. Defaults to `false`.

### reset_technologies

Load the original versions of technologies from prototypes. Preserves research state of technologies.

### reset

Reset everything. All technologies are set to not researched, all modifiers are set to default values.

### reset_technology_effects

Reapplies all possible research effects, including unlocked recipes. Any custom changes are lost. Preserves research state of technologies.

### chart

Chart a portion of the map. The chart for the given area is refreshed; it creates chart for any parts of the given area that haven't been charted yet.

**Parameters:**

- `area` `BoundingBox` - The area on the given surface to chart.
- `surface` `SurfaceIdentification`

**Examples:**

```
-- Charts a 2048x2048 rectangle centered around the origin.
game.player.force.chart(game.player.surface, {{x = -1024, y = -1024}, {x = 1024, y = 1024}})
```

### clear_chart

Erases chart data for this force.

**Parameters:**

- `surface` `SurfaceIdentification` *(optional)* - Which surface to erase chart data for or if not provided all surfaces charts are erased.

### rechart

Force a rechart of the whole chart.

**Parameters:**

- `surface` `SurfaceIdentification` *(optional)* - Which surface to rechart or all if not given.

### chart_all

Chart all generated chunks.

**Parameters:**

- `surface` `SurfaceIdentification` *(optional)* - Which surface to chart or all if not given.

### copy_from

Copies all of the given changeable values (except charts) from the given force to this force.

**Parameters:**

- `force` `ForceID` - The force to copy from.

### copy_chart

Copies the given surface's chart from the given force to this force.

**Parameters:**

- `destination_surface` `SurfaceIdentification` - The surface to copy to.
- `source_force` `ForceID` - The force to copy from
- `source_surface` `SurfaceIdentification` - The surface to copy from.

### is_chunk_charted

Has a chunk been charted?

**Parameters:**

- `position` `ChunkPosition` - Position of the chunk.
- `surface` `SurfaceIdentification`

**Returns:**

- `boolean`

### is_chunk_visible

Is the given chunk currently charted and visible (not covered by fog of war) on the map.

**Parameters:**

- `position` `ChunkPosition`
- `surface` `SurfaceIdentification`

**Returns:**

- `boolean`

### is_chunk_requested_for_charting

Has a chunk been requested for charting?

**Parameters:**

- `position` `ChunkPosition` - Position of the chunk.
- `surface` `SurfaceIdentification`

**Returns:**

- `boolean`

### cancel_charting

Cancels pending chart requests for the given surface or all surfaces.

**Parameters:**

- `surface` `SurfaceIdentification` *(optional)*

### get_ammo_damage_modifier

**Parameters:**

- `ammo` `string` - Ammo category

**Returns:**

- `double`

### set_ammo_damage_modifier

**Parameters:**

- `ammo` `string` - Ammo category
- `modifier` `double`

### get_gun_speed_modifier

**Parameters:**

- `ammo` `string` - Ammo category

**Returns:**

- `double`

### set_gun_speed_modifier

**Parameters:**

- `ammo` `string` - Ammo category
- `modifier` `double`

### get_turret_attack_modifier

**Parameters:**

- `turret` `EntityID` - Turret prototype name

**Returns:**

- `double`

### set_turret_attack_modifier

**Parameters:**

- `modifier` `double`
- `turret` `EntityID` - Turret prototype name

### set_cease_fire

Add `other` force to this force's cease fire list. Forces on the cease fire list won't be targeted for attack.

**Parameters:**

- `cease_fire` `boolean`
- `other` `ForceID`

### get_cease_fire

Is `other` force in this force's cease fire list?

**Parameters:**

- `other` `ForceID`

**Returns:**

- `boolean`

### set_friend

Add `other` force to this force's friends list. Friends have unrestricted access to buildings and turrets won't fire at them.

**Parameters:**

- `friend` `boolean`
- `other` `ForceID`

### get_friend

Is `other` force in this force's friends list.

**Parameters:**

- `other` `ForceID`

**Returns:**

- `boolean`

### is_pathfinder_busy

Is pathfinder busy? When the pathfinder is busy, it won't accept any more pathfinding requests.

**Returns:**

- `boolean`

### kill_all_units

Kill all units and flush the pathfinder.

### find_logistic_network_by_position

**Parameters:**

- `position` `MapPosition` - Position to find a network for
- `surface` `SurfaceIdentification` - Surface to search on

**Returns:**

- `LuaLogisticNetwork` *(optional)* - The found network or `nil`.

### set_spawn_position

**Parameters:**

- `position` `MapPosition` - The new position on the given surface.
- `surface` `SurfaceIdentification` - Surface to set the spawn position for.

### get_spawn_position

**Parameters:**

- `surface` `SurfaceIdentification`

**Returns:**

- `MapPosition`

### set_surface_hidden

**Parameters:**

- `hidden` `boolean` - Whether to hide the surface or not.
- `surface` `SurfaceIdentification` - Surface to set hidden for.

### get_surface_hidden

**Parameters:**

- `surface` `SurfaceIdentification`

**Returns:**

- `boolean`

### unchart_chunk

**Parameters:**

- `position` `ChunkPosition` - The chunk position to unchart.
- `surface` `SurfaceIdentification` - Surface to unchart on.

### get_item_launched

Gets the count of a given item launched in rockets.

**Parameters:**

- `item` `ItemID` - The item to get

**Returns:**

- `uint` - The count of the item that has been launched.

### set_item_launched

Sets the count of a given item launched in rockets.

**Parameters:**

- `count` `uint` - The count to set
- `item` `ItemID` - The item to set

### print

Print text to the chat console of all players on this force.

By default, messages that are identical to a message sent in the last 60 ticks are not printed again.

**Parameters:**

- `message` `LocalisedString`
- `print_settings` `PrintSettings` *(optional)*

### add_chart_tag

Adds a custom chart tag to the given surface and returns the new tag or `nil` if the given position isn't valid for a chart tag.

The chunk must be charted for a tag to be valid at that location.

**Parameters:**

- `surface` `SurfaceIdentification` - Which surface to add the tag to.
- `tag` `ChartTagSpec` - The tag to add.

**Returns:**

- `LuaCustomChartTag` *(optional)*

### find_chart_tags

Finds all custom chart tags within a given area on the given surface. If no area is given all custom chart tags on the surface are returned.

**Parameters:**

- `area` `BoundingBox` *(optional)*
- `surface` `SurfaceIdentification`

**Returns:**

- Array[`LuaCustomChartTag`]

### reset_evolution

Resets evolution for this force to zero.

### play_sound

Play a sound for every player in this force.

The sound is not played if its location is not [charted](runtime:LuaForce::chart) for this force.

**Parameters:**

- `sound_specification` `PlaySoundSpecification` - The sound to play.

### get_hand_crafting_disabled_for_recipe

Gets if the given recipe is explicitly disabled from being hand crafted.

**Parameters:**

- `recipe` `RecipeID`

**Returns:**

- `boolean`

### set_hand_crafting_disabled_for_recipe

Sets if the given recipe can be hand-crafted. This is used to explicitly disable hand crafting a recipe - it won't allow hand-crafting otherwise not hand-craftable recipes.

**Parameters:**

- `hand_crafting_disabled` `boolean`
- `recipe` `RecipeID`

### add_research

Add this technology to the back of the research queue if the queue is enabled. Otherwise, set this technology to be researched now.

**Parameters:**

- `technology` `TechnologyID`

**Returns:**

- `boolean` - Whether the technology was successfully added.

### cancel_current_research

Stop the research currently in progress. This will remove any dependent technologies from the research queue.

### get_linked_inventory

Gets the linked inventory for the given prototype and link ID if it exists or `nil`.

**Parameters:**

- `link_id` `uint`
- `prototype` `EntityID`

**Returns:**

- `LuaInventory` *(optional)*

### is_friend

Is this force a friend? This differs from `get_friend` in that it is always true for neutral force. This is equivalent to checking the `friend` ForceCondition.

**Parameters:**

- `other` `ForceID`

**Returns:**

- `boolean`

### is_enemy

Is this force an enemy? This differs from `get_cease_fire` in that it is always false for neutral force. This is equivalent to checking the `enemy` ForceCondition.

**Parameters:**

- `other` `ForceID`

**Returns:**

- `boolean`

### lock_space_location

Locks the planet to not be accessible to this force.

**Parameters:**

- `name` `SpaceLocationID` - Name of the planet.

### unlock_space_location

Unlocks the planet to be accessible to this force.

**Parameters:**

- `name` `SpaceLocationID` - Name of the planet.

### is_space_location_unlocked

Is the specified planet unlocked for this force?

**Parameters:**

- `name` `SpaceLocationID` - Name of the planet.

### lock_quality

Locks the quality to not be accessible to this force.

**Parameters:**

- `quality` `QualityID` - Name of the quality.

### unlock_quality

Unlocks the quality to be accessible to this force.

**Parameters:**

- `quality` `QualityID` - Name of the quality.

### is_quality_unlocked

Is the specified quality unlocked for this force?

**Parameters:**

- `quality` `QualityID` - Name of the quality.

### lock_space_platforms

Locks the space platforms, which disables the space platforms button

### unlock_space_platforms

Unlocks the space platforms, which enables the space platforms button

### is_space_platforms_unlocked

Are the space platforms unlocked? This basically just controls the availability of the space platforms button.

**Returns:**

- `boolean`

### create_space_platform

Creates a new space platform on this force.

**Parameters:**

- `name` `string` *(optional)* - The platform name. If not provided, a random name will be used.
- `planet` `SpaceLocationID` - The planet that the platform will orbit.
- `starter_pack` `ItemWithQualityID` - The starter pack required to build the platform.

**Returns:**

- `LuaSpacePlatform` *(optional)*

### get_evolution_factor

Fetches the evolution factor of this force on the given surface.

**Parameters:**

- `surface` `SurfaceIdentification` *(optional)* - Defaults to "nauvis".

**Returns:**

- `double`

### get_evolution_factor_by_pollution

Fetches the pollution part of the evolution factor of this force on the given surface.

**Parameters:**

- `surface` `SurfaceIdentification` *(optional)* - Defaults to "nauvis".

**Returns:**

- `double`

### get_evolution_factor_by_time

Fetches the time part of the evolution factor of this force on the given surface.

**Parameters:**

- `surface` `SurfaceIdentification` *(optional)* - Defaults to "nauvis".

**Returns:**

- `double`

### get_evolution_factor_by_killing_spawners

Fetches the spawner kill part of the evolution factor of this force on the given surface.

**Parameters:**

- `surface` `SurfaceIdentification` *(optional)* - Defaults to "nauvis".

**Returns:**

- `double`

### set_evolution_factor

Sets the evolution factor of this force on the given surface.

**Parameters:**

- `factor` `double`
- `surface` `SurfaceIdentification` *(optional)* - Defaults to "nauvis".

### set_evolution_factor_by_pollution

Sets the pollution part of the evolution factor of this force on the given surface.

**Parameters:**

- `factor` `double`
- `surface` `SurfaceIdentification` *(optional)* - Defaults to "nauvis".

### set_evolution_factor_by_time

Sets the time part of the evolution factor of this force on the given surface.

**Parameters:**

- `factor` `double`
- `surface` `SurfaceIdentification` *(optional)* - Defaults to "nauvis".

### set_evolution_factor_by_killing_spawners

Sets the spawner kill part of the evolution factor of this force on the given surface.

**Parameters:**

- `factor` `double`
- `surface` `SurfaceIdentification` *(optional)* - Defaults to "nauvis".

### get_item_production_statistics

The item production statistics for this force for the given surface.

**Parameters:**

- `surface` `SurfaceIdentification`

**Returns:**

- `LuaFlowStatistics`

### get_fluid_production_statistics

The fluid production statistics for this force for the given surface.

**Parameters:**

- `surface` `SurfaceIdentification`

**Returns:**

- `LuaFlowStatistics`

### get_kill_count_statistics

The kill counter statistics for this force for the given surface.

**Parameters:**

- `surface` `SurfaceIdentification`

**Returns:**

- `LuaFlowStatistics`

### get_entity_build_count_statistics

The entity build statistics for this force (built and mined) for the given surface.

**Parameters:**

- `surface` `SurfaceIdentification`

**Returns:**

- `LuaFlowStatistics`

### get_logistic_groups

Gets the names of the current logistic groups.

**Parameters:**

- `type` `defines.logistic_group_type` *(optional)* - Defaults to `defines.logistic_group_type.with_trash`.

**Returns:**

- Array[`string`]

### get_logistic_group

Gets the information about the given logistic group.

**Parameters:**

- `name` `string`
- `type` `defines.logistic_group_type` *(optional)* - Defaults to `defines.logistic_group_type.with_trash`.

**Returns:**

- `LogisticGroup` *(optional)*

### create_logistic_group

Creates the given group if it doesn't already exist.

**Parameters:**

- `name` `string`
- `type` `defines.logistic_group_type` *(optional)* - Defaults to `defines.logistic_group_type.with_trash`.

### delete_logistic_group

Deletes the given logistic group if it exists.

**Parameters:**

- `name` `string`
- `type` `defines.logistic_group_type` *(optional)* - Defaults to `defines.logistic_group_type.with_trash`.

### get_chunk_chart

Gets the raw chart data for a given chunk as a binary string.

The pixel data is returned in RGB565 format (2 bytes per pixel).

Returns `nil` if the chunk has not been charted for this force.

**Parameters:**

- `position` `ChunkPosition`
- `surface` `SurfaceIdentification`

**Returns:**

- `string` *(optional)* - The raw pixel data.

