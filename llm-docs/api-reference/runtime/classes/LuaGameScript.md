# LuaGameScript

Main toplevel type, provides access to most of the API though its members. An instance of LuaGameScript is available as the global object named `game`.

## Attributes

### allow_debug_settings

Whether players who are not [admins](runtime:LuaPlayer::admin) can access all debug settings. Set this to false to disallow access to most debug settings for non-admins.

The following debug settings are always available to all players: `"show-fps"`, `"show-clock"`, `"show-time-to-next-autosave"`, `"show-detailed-info"`, `"show-time-usage"`, `"show-entity-time-usage"`, `"show-gpu-time-usage"`, `"show-sprite-counts"`, `"show-particle-counts"`, `"show-collector-navmesh-time-usage"`, `"show-lua-object-statistics"`, `"show-heat-buffer-info"`, `"show-multiplayer-waiting-icon"`, `"show-multiplayer-statistics"`, `"show-multiplayer-server-name"`, `"show-debug-info-in-tooltips"`, `"show-resistances-in-tooltips-always"`, `"hide-mod-guis"`, `"show-tile-grid"`, `"show-blueprint-grid"`, `"show-intermediate-volume-of-working-sounds"`, `"show-decorative-names"`, `"allow-increased-zoom"`, `"show-train-no-path-details"`, `"show-entity-tick"`, `"show-update-tick"`

**Read type:** `boolean`

**Write type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

### player

This property is only populated inside [custom command](runtime:LuaCommandProcessor) handlers and when writing [Lua console commands](https://wiki.factorio.com/Console#Scripting_and_cheat_commands). Returns the player that is typing the command, `nil` in all other instances.

See [LuaGameScript::players](runtime:LuaGameScript::players) for accessing all players.

**Read type:** `LuaPlayer`

**Optional:** Yes

### players

Get a table of all the players that currently exist. This sparse table allows you to find players by indexing it with either their `name` or `index`. Iterating this table with `pairs()` will provide the `index`es as the keys. Iterating with `ipairs()` will not work at all.

If only a single player is required, [LuaGameScript::get_player](runtime:LuaGameScript::get_player) should be used instead, as it avoids the unnecessary overhead of passing the whole table to Lua.

**Read type:** LuaCustomTable[`uint32` | `string`, `LuaPlayer`]

### map_settings

The currently active set of map settings. Even though this property is marked as read-only, the members of the dictionary that is returned can be modified mid-game.

This does not contain difficulty settings, use [LuaGameScript::difficulty_settings](runtime:LuaGameScript::difficulty_settings) instead.

**Read type:** `MapSettings`

### difficulty_settings

The currently active set of difficulty settings. Even though this property is marked as read-only, the members of the dictionary that is returned can be modified mid-game.

**Read type:** `DifficultySettings`

### difficulty

Current scenario difficulty.

**Read type:** `defines.difficulty`

### forces

Get a table of all the forces that currently exist. This sparse table allows you to find forces by indexing it with either their `name` or `index`. Iterating this table with `pairs()` will provide the `name`s as the keys. Iterating with `ipairs()` will not work at all.

**Read type:** LuaCustomTable[`uint32` | `string`, `LuaForce`]

### console_command_used

Whether a console command has been used.

**Read type:** `boolean`

### simulation

Simulation-related functions, or `nil` if the current game is not a simulation.

**Read type:** `LuaSimulation`

### tick

Current map tick.

**Read type:** `MapTick`

### ticks_played

The number of ticks since this game was created using either "new game" or "new game from scenario". Notably, this number progresses even when the game is [tick_paused](runtime:LuaGameScript::tick_paused).

This differs from [LuaGameScript::tick](runtime:LuaGameScript::tick) in that creating a game from a scenario always starts with this value at `0`, even if the scenario has its own level data where the `tick` has progressed past `0`.

**Read type:** `MapTick`

### tick_paused

If the tick has been paused. This means that entity update has been paused.

**Read type:** `boolean`

**Write type:** `boolean`

### ticks_to_run

The number of ticks to be run while the tick is paused.

When [LuaGameScript::tick_paused](runtime:LuaGameScript::tick_paused) is true, ticks_to_run behaves the following way: While this is > 0, the entity update is running normally and this value is decremented every tick. When this reaches 0, the game will pause again.

**Read type:** `uint32`

**Write type:** `uint32`

### finished

True while the victory screen is shown.

**Read type:** `boolean`

### finished_but_continuing

True after players finished the game and clicked "continue".

**Read type:** `boolean`

### speed

Speed to update the map at. 1.0 is normal speed -- 60 UPS. Minimum value is 0.01.

**Read type:** `float`

**Write type:** `float`

### surfaces

Get a table of all the surfaces that currently exist. This sparse table allows you to find surfaces by indexing it with either their `name` or `index`. Iterating this table with `pairs()` will provide the `name`s as the keys. Iterating with `ipairs()` will not work at all.

**Read type:** LuaCustomTable[`uint32` | `string`, `LuaSurface`]

### planets

**Read type:** LuaCustomTable[`string`, `LuaPlanet`]

### connected_players

The players that are currently online.

This does *not* index using player index. See [LuaPlayer::index](runtime:LuaPlayer::index) on each player instance for the player index. This is primarily useful when you want to do some action against all online players.

**Read type:** Array[`LuaPlayer`]

### permissions

**Read type:** `LuaPermissionGroups`

### backer_names

Array of the names of all the backers that supported the game development early on. These are used as names for labs, locomotives, radars, roboports, and train stops.

**Read type:** LuaCustomTable[`uint32`, `string`]

### default_map_gen_settings

The default map gen settings for this save.

**Read type:** `MapGenSettings`

### enemy_has_vision_on_land_mines

Determines if enemy land mines are completely invisible or not.

**Read type:** `boolean`

**Write type:** `boolean`

### autosave_enabled

True by default. Can be used to disable autosaving. Make sure to turn it back on soon after.

**Read type:** `boolean`

**Write type:** `boolean`

### draw_resource_selection

True by default. Can be used to disable the highlighting of resource patches when they are hovered on the map.

**Read type:** `boolean`

**Write type:** `boolean`

### train_manager

**Read type:** `LuaTrainManager`

### blueprints

Records contained in the "game blueprints" tab of the blueprint library.

**Read type:** Array[`LuaRecord`]

### technology_notifications_enabled

True by default. Can be used to prevent the game engine from printing certain messages.

**Read type:** `boolean`

**Write type:** `boolean`

### allow_tip_activation

If the tips are allowed to be activated in this scenario, it is false by default.

Can't be modified in a simulation (menu screen, tips and tricks simulation, factoriopedia simulation etc.)

**Read type:** `boolean`

**Write type:** `boolean`

## Methods

### set_game_state

Set scenario state. Any parameters not provided do not change the current state.

**Parameters:**

- `can_continue` `boolean` *(optional)*
- `game_finished` `boolean` *(optional)*
- `next_level` `string` *(optional)*
- `player_won` `boolean` *(optional)*

### reset_game_state

Reset scenario state (game_finished, player_won, etc.).

### set_win_ending_info

Set winning ending information for the current scenario.

**Parameters:**

- `bullet_points` Array[`LocalisedString`] *(optional)*
- `final_message` `LocalisedString` *(optional)*
- `image_path` `string` *(optional)*
- `message` `LocalisedString` *(optional)*
- `title` `LocalisedString`

### set_lose_ending_info

Set losing ending information for the current scenario.

**Parameters:**

- `bullet_points` Array[`LocalisedString`] *(optional)*
- `final_message` `LocalisedString` *(optional)*
- `image_path` `string` *(optional)*
- `message` `LocalisedString` *(optional)*
- `title` `LocalisedString`

### get_entity_by_tag

Gets an entity by its [name tag](runtime:LuaEntity::name_tag). Entity name tags can also be set in the entity "extra settings" GUI in the map editor.

**Parameters:**

- `tag` `string`

**Returns:**

- `LuaEntity` *(optional)*

### show_message_dialog

Show an in-game message dialog.

Can only be used when the map contains exactly one player.

**Parameters:**

- `image` `string` *(optional)* - Path to an image to show on the dialog
- `point_to` `GuiArrowSpecification` *(optional)* - If specified, dialog will show an arrow pointing to this place. When not specified, the arrow will point to the player's position. (Use `point_to={type="nowhere"}` to remove the arrow entirely.) The dialog itself will be placed near the arrow's target.
- `style` `string` *(optional)* - The gui style to use for this speech bubble. Must be of type speech_bubble.
- `text` `LocalisedString` - What the dialog should say
- `wrapper_frame_style` `string` *(optional)* - Must be of type flow_style.

### is_demo

Is this the demo version of Factorio?

**Returns:**

- `boolean`

### reload_script

Forces a reload of the scenario script from the original scenario location.

This disables the replay if replay is enabled.

### reload_mods

Forces a reload of all mods.

This will act like saving and loading from the mod(s) perspective.

This will do nothing if run in multiplayer.

This disables the replay if replay is enabled.

### save_atlas

Saves the current configuration of Atlas to a file. This will result in huge file containing all of the game graphics moved to as small space as possible.

Exists mainly for debugging reasons.

### check_consistency

Run internal consistency checks. Allegedly prints any errors it finds.

Exists mainly for debugging reasons.

### regenerate_entity

Regenerate autoplacement of some entities on all surfaces. This can be used to autoplace newly-added entities.

All specified entity prototypes must be autoplacable.

**Parameters:**

- `entities` `string` | Array[`string`] - Prototype names of entity or entities to autoplace.

### take_screenshot

Take a screenshot of the game and save it to the `script-output` folder, located in the game's [user data directory](https://wiki.factorio.com/User_data_directory). The name of the image file can be specified via the `path` parameter.

If Factorio is running headless, this function will do nothing.

**Parameters:**

- `allow_in_replay` `boolean` *(optional)* - Whether to save the screenshot even during replay playback. Defaults to `false`.
- `anti_alias` `boolean` *(optional)* - Whether to render in double resolution and downscale the result (including GUI). Defaults to `false`.
- `by_player` `PlayerIdentification` *(optional)* - If defined, the screenshot will only be taken for this player.
- `daytime` `double` *(optional)* - Overrides the current surface daytime for the duration of screenshot rendering.
- `force_render` `boolean` *(optional)* - Screenshot requests are processed in between game update and render. The game may skip rendering (ie. drop frames) if the previous frame has not finished rendering or the game simulation starts to fall below 60 updates per second. If `force_render` is set to `true`, the game won't drop frames and process the screenshot request at the end of the update in which the request was created. This is not honored on multiplayer clients that are catching up to server. Defaults to `false`.
- `hide_clouds` `boolean` *(optional)* - If `true` cloud shadows on ground won't be rendered. Defaults to `false`.
- `hide_fog` `boolean` *(optional)* - If `true` fog effect and foreground space dust effect won't be rendered. Defaults to `false`.
- `path` `string` *(optional)* - The name of the image file. It should include a file extension indicating the desired format. Supports `.png`, `.jpg` /`.jpeg`, `.tga` and `.bmp`. Providing a directory path (ex. `"save/here/screenshot.png"`) will create the necessary folder structure in `script-output`. Defaults to `"screenshot.png"`.
- `player` `PlayerIdentification` *(optional)* - The player to focus on. Defaults to the local player.
- `position` `MapPosition` *(optional)* - If defined, the screenshot will be centered on this position. Otherwise, the screenshot will center on `player`.
- `quality` `int32` *(optional)* - The `.jpg` render quality as a percentage (from 0% to 100% inclusive), if used. A lower value means a more compressed image. Defaults to `80`.
- `resolution` `TilePosition` *(optional)* - The maximum allowed resolution is 16384x16384 (8192x8192 when `anti_alias` is `true`), but the maximum recommended resolution is 4096x4096 (resp. 2048x2048). The `x` value of the position is used as the width, the `y` value as the height.
- `show_cursor_building_preview` `boolean` *(optional)* - When `true` and when `player` is specified, the building preview for the item in the player's cursor will also be rendered. Defaults to `false`.
- `show_entity_info` `boolean` *(optional)* - Whether to include entity info ("Alt mode") or not. Defaults to `false`.
- `show_gui` `boolean` *(optional)* - Whether to include GUIs in the screenshot or not. Defaults to `false`.
- `surface` `SurfaceIdentification` *(optional)* - If defined, the screenshot will be taken on this surface.
- `water_tick` `uint32` *(optional)* - Overrides the tick of water animation, if animated water is enabled.
- `zoom` `double` *(optional)* - The map zoom to take the screenshot at. Defaults to `1`.

### set_wait_for_screenshots_to_finish

Forces the screenshot saving system to wait until all queued screenshots have been written to disk.

### take_technology_screenshot

Take a screenshot of the technology screen and save it to the `script-output` folder, located in the game's [user data directory](https://wiki.factorio.com/User_data_directory). The name of the image file can be specified via the `path` parameter.

**Parameters:**

- `path` `string` *(optional)* - The name of the image file. It should include a file extension indicating the desired format. Supports `.png`, `.jpg` /`.jpeg`, `.tga` and `.bmp`. Providing a directory path (ex. `"save/here/screenshot.png"`) will create the necessary folder structure in `script-output`. Defaults to `"technology-screenshot.png"`.
- `player` `PlayerIdentification` - The screenshot will be taken for this player.
- `quality` `int32` *(optional)* - The `.jpg` render quality as a percentage (from 0% to 100% inclusive), if used. A lower value means a more compressed image. Defaults to `80`.
- `selected_technology` `TechnologyID` *(optional)* - The technology to highlight.
- `skip_disabled` `boolean` *(optional)* - If `true`, disabled technologies will be skipped. Their successors will be attached to the disabled technology's parents. Defaults to `false`.

### remove_offline_players

Remove players who are currently not connected from the map.

**Parameters:**

- `players` Array[`PlayerIdentification`] *(optional)* - List of players to remove. If not specified, remove all offline players.

### force_crc

Force a CRC check. Tells all peers to calculate their current CRC, which are then compared to each other. If a mismatch is detected, the game desyncs and some peers are forced to reconnect.

### create_force

Create a new force.

The game currently supports a maximum of 64 forces, including the three built-in forces. This means that a maximum of 61 new forces may be created. Force names must be unique.

**Parameters:**

- `force` `string` - Name of the new force

**Returns:**

- `LuaForce` - The force that was just created

### merge_forces

Marks two forces to be merged together. All players and entities in the source force will be reassigned to the target force. The source force will then be destroyed. Importantly, this does not merge technologies or bonuses, which are instead retained from the target force.

The three built-in forces (player, enemy and neutral) can't be destroyed, meaning they can't be used as the source argument to this function.

The source force is not removed until the end of the current tick, or if called during the [on_forces_merging](runtime:on_forces_merging) or [on_forces_merged](runtime:on_forces_merged) event, the end of the next tick.

**Parameters:**

- `destination` `ForceID` - The force to reassign all entities to.
- `source` `ForceID` - The force to remove.

### create_surface

Create a new surface.

The game currently supports a maximum of 4 294 967 295 surfaces, including the default surface. Surface names must be unique.

**Parameters:**

- `name` `string` - Name of the new surface.
- `settings` `MapGenSettings` *(optional)* - Map generation settings.

**Returns:**

- `LuaSurface` - The surface that was just created.

### server_save

Instruct the server to save the map. Only actually saves when in multiplayer.

**Parameters:**

- `name` `string` *(optional)* - Save file name. If not specified, the currently running save is overwritten. If there is no current save, no save is made.

### auto_save

Instruct the game to perform an auto-save.

Only the server will save in multiplayer. In single player a standard auto-save is triggered.

**Parameters:**

- `name` `string` *(optional)* - The autosave name if any. Saves will be named _autosave-*name* when provided.

### delete_surface

Deletes the given surface and all entities on it if possible.

**Parameters:**

- `surface` `SurfaceIdentification` - The surface to be deleted. Currently the primary surface (1, 'nauvis') cannot be deleted.

**Returns:**

- `boolean` - If the surface was queued to be deleted.

### disable_replay

Disables replay saving for the current save file. Once done there's no way to re-enable replay saving for the save file without loading an old save.

### print

Print text to the chat console all players.

By default, messages that are identical to a message sent in the last 60 ticks are not printed again.

**Parameters:**

- `message` `LocalisedString`
- `print_settings` `PrintSettings` *(optional)*

### create_random_generator

Creates a deterministic standalone random generator with the given seed or if a seed is not provided the initial map seed is used.

*Make sure* you actually want to use this over math.random(...) as this provides entirely different functionality over math.random(...).

**Parameters:**

- `seed` `uint32` *(optional)*

**Returns:**

- `LuaRandomGenerator`

### play_sound

Play a sound for every player in the game.

The sound is not played if its location is not [charted](runtime:LuaForce::chart) for that player.

**Parameters:**

- `sound_specification` `PlaySoundSpecification` - The sound to play.

### kick_player

Kicks the given player from this multiplayer game. Does nothing if this is a single player game or if the player running this isn't an admin.

**Parameters:**

- `player` `PlayerIdentification` - The player to kick.
- `reason` `string` *(optional)* - The reason given if any.

### ban_player

Bans the given player from this multiplayer game. Does nothing if this is a single player game of if the player running this isn't an admin.

**Parameters:**

- `player` `PlayerIdentification` | `string` - The player to ban.
- `reason` `string` *(optional)* - The reason given if any.

### unban_player

Unbans the given player from this multiplayer game. Does nothing if this is a single player game of if the player running this isn't an admin.

**Parameters:**

- `player` `PlayerIdentification` | `string` - The player to unban.

### purge_player

Purges the given players messages from the game. Does nothing if the player running this isn't an admin.

**Parameters:**

- `player` `PlayerIdentification` - The player to purge.

### mute_player

Mutes the given player. Does nothing if the player running this isn't an admin.

**Parameters:**

- `player` `PlayerIdentification` - The player to mute.

### unmute_player

Unmutes the given player. Does nothing if the player running this isn't an admin.

**Parameters:**

- `player` `PlayerIdentification` - The player to unmute.

### is_multiplayer

Whether the save is loaded as a multiplayer map.

**Returns:**

- `boolean`

### get_map_exchange_string

Gets the map exchange string for the map generation settings that were used to create this map.

**Returns:**

- `string`

### get_player

Gets the given player or returns `nil` if no player is found.

**Parameters:**

- `player` `uint32` | `string` - The player index or name.

**Returns:**

- `LuaPlayer` *(optional)*

### get_surface

Gets the given surface or returns `nil` if no surface is found.

This is a shortcut for [LuaGameScript::surfaces](runtime:LuaGameScript::surfaces).

**Parameters:**

- `surface` `uint32` | `string` - The surface index or name.

**Returns:**

- `LuaSurface` *(optional)*

### create_profiler

Creates a [LuaProfiler](runtime:LuaProfiler), which is used for measuring script performance.

LuaProfiler cannot be serialized.

**Parameters:**

- `stopped` `boolean` *(optional)* - Create the timer stopped

**Returns:**

- `LuaProfiler`

### create_inventory

Creates an inventory that is not owned by any game object.

It can be resized later with [LuaInventory::resize](runtime:LuaInventory::resize).

Make sure to destroy it when you are done with it using [LuaInventory::destroy](runtime:LuaInventory::destroy).

**Parameters:**

- `gui_title` `LocalisedString` *(optional)* - The title of the GUI that is shown when this inventory is opened.
- `size` `uint16` - The number of slots the inventory initially has.

**Returns:**

- `LuaInventory`

### get_script_inventories

Gets the inventories created through [LuaGameScript::create_inventory](runtime:LuaGameScript::create_inventory).

Inventories created through console commands will be owned by `"core"`.

**Parameters:**

- `mod` `string` *(optional)* - The mod whose inventories to get. If not provided all inventories are returned.

**Returns:**

- Dictionary[`string`, Array[`LuaInventory`]] - A mapping of mod name to array of inventories owned by that mod.

### reset_time_played

Resets the amount of time played for this map.

### get_pollution_statistics

The pollution statistics for this the given surface.

**Parameters:**

- `surface` `SurfaceIdentification`

**Returns:**

- `LuaFlowStatistics`

### get_vehicles

Returns vehicles in game.

**Parameters:**

- `force` `ForceID` *(optional)*
- `has_passenger` `boolean` *(optional)*
- `is_moving` `boolean` *(optional)*
- `surface` `SurfaceIdentification` *(optional)*
- `type` `EntityID` | Array[`EntityID`] *(optional)*
- `unit_number` `uint32` *(optional)*

**Returns:**

- Array[`LuaEntity`]

### get_entity_by_unit_number

Returns entity with a specified unit number or nil if entity with such number was not found or prototype does not have [EntityPrototypeFlags::get-by-unit-number](prototype:EntityPrototypeFlags::get_by_unit_number) flag set.

**Parameters:**

- `unit_number` `uint32`

**Returns:**

- `LuaEntity` *(optional)*

