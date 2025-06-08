# LuaGameScript

Main toplevel type, provides access to most of the API though its members. An instance of LuaGameScript is available as the global object named `game`.

## Methods

### auto_save

Instruct the game to perform an auto-save.

Only the server will save in multiplayer. In single player a standard auto-save is triggered.

**Parameters:**

- `name` `string` _(optional)_: The autosave name if any. Saves will be named _autosave-*name* when provided.

### ban_player

Bans the given player from this multiplayer game. Does nothing if this is a single player game of if the player running this isn't an admin.

**Parameters:**

- `player` : The player to ban.
- `reason` `string` _(optional)_: The reason given if any.

### check_consistency

Run internal consistency checks. Allegedly prints any errors it finds.

Exists mainly for debugging reasons.

### create_force

Create a new force.

The game currently supports a maximum of 64 forces, including the three built-in forces. This means that a maximum of 61 new forces may be created. Force names must be unique.

**Parameters:**

- `force` `string`: Name of the new force

**Returns:**

- `LuaForce`: The force that was just created

### create_inventory

Creates an inventory that is not owned by any game object.

It can be resized later with [LuaInventory::resize](runtime:LuaInventory::resize).

Make sure to destroy it when you are done with it using [LuaInventory::destroy](runtime:LuaInventory::destroy).

**Parameters:**

- `gui_title` `LocalisedString` _(optional)_: The title of the GUI that is shown when this inventory is opened.
- `size` `uint16`: The number of slots the inventory initially has.

**Returns:**

- `LuaInventory`: 

### create_profiler

Creates a [LuaProfiler](runtime:LuaProfiler), which is used for measuring script performance.

LuaProfiler cannot be serialized.

**Parameters:**

- `stopped` `boolean` _(optional)_: Create the timer stopped

**Returns:**

- `LuaProfiler`: 

### create_random_generator

Creates a deterministic standalone random generator with the given seed or if a seed is not provided the initial map seed is used.

*Make sure* you actually want to use this over math.random(...) as this provides entirely different functionality over math.random(...).

**Parameters:**

- `seed` `uint` _(optional)_: 

**Returns:**

- `LuaRandomGenerator`: 

### create_surface

Create a new surface.

The game currently supports a maximum of 4 294 967 295 surfaces, including the default surface. Surface names must be unique.

**Parameters:**

- `name` `string`: Name of the new surface.
- `settings` `MapGenSettings` _(optional)_: Map generation settings.

**Returns:**

- `LuaSurface`: The surface that was just created.

### delete_surface

Deletes the given surface and all entities on it if possible.

**Parameters:**

- `surface` `SurfaceIdentification`: The surface to be deleted. Currently the primary surface (1, 'nauvis') cannot be deleted.

**Returns:**

- `boolean`: If the surface was queued to be deleted.

### disable_replay

Disables replay saving for the current save file. Once done there's no way to re-enable replay saving for the save file without loading an old save.

### force_crc

Force a CRC check. Tells all peers to calculate their current CRC, which are then compared to each other. If a mismatch is detected, the game desyncs and some peers are forced to reconnect.

### get_entity_by_tag

Gets an entity by its [name tag](runtime:LuaEntity::name_tag). Entity name tags can also be set in the entity "extra settings" GUI in the map editor.

**Parameters:**

- `tag` `string`: 

**Returns:**

- `LuaEntity`: 

### get_entity_by_unit_number

Returns entity with a specified unit number or nil if entity with such number was not found or prototype does not have [EntityPrototypeFlags::get-by-unit-number](prototype:EntityPrototypeFlags::get_by_unit_number) flag set.

**Parameters:**

- `unit_number` `uint`: 

**Returns:**

- `LuaEntity`: 

### get_map_exchange_string

Gets the map exchange string for the map generation settings that were used to create this map.

**Returns:**

- `string`: 

### get_player

Gets the given player or returns `nil` if no player is found.

**Parameters:**

- `player` : The player index or name.

**Returns:**

- `LuaPlayer`: 

### get_pollution_statistics

The pollution statistics for this the given surface.

**Parameters:**

- `surface` `SurfaceIdentification`: 

**Returns:**

- `LuaFlowStatistics`: 

### get_script_inventories

Gets the inventories created through [LuaGameScript::create_inventory](runtime:LuaGameScript::create_inventory).

Inventories created through console commands will be owned by `"core"`.

**Parameters:**

- `mod` `string` _(optional)_: The mod whose inventories to get. If not provided all inventories are returned.

**Returns:**

- `dictionary<`string`, ``LuaInventory`[]`>`: A mapping of mod name to array of inventories owned by that mod.

### get_surface

Gets the given surface or returns `nil` if no surface is found.

This is a shortcut for [LuaGameScript::surfaces](runtime:LuaGameScript::surfaces).

**Parameters:**

- `surface` : The surface index or name.

**Returns:**

- `LuaSurface`: 

### get_vehicles

Returns vehicles in game

**Parameters:**

- `force` `ForceID` _(optional)_: 
- `has_passenger` `boolean` _(optional)_: 
- `is_moving` `boolean` _(optional)_: 
- `surface` `SurfaceIdentification` _(optional)_: )
- `type`  _(optional)_: 
- `unit_number` `uint` _(optional)_: 

**Returns:**

- ``LuaEntity`[]`: 

### is_demo

Is this the demo version of Factorio?

**Returns:**

- `boolean`: 

### is_multiplayer

Whether the save is loaded as a multiplayer map.

**Returns:**

- `boolean`: 

### kick_player

Kicks the given player from this multiplayer game. Does nothing if this is a single player game or if the player running this isn't an admin.

**Parameters:**

- `player` `PlayerIdentification`: The player to kick.
- `reason` `string` _(optional)_: The reason given if any.

### merge_forces

Marks two forces to be merged together. All players and entities in the source force will be reassigned to the target force. The source force will then be destroyed. Importantly, this does not merge technologies or bonuses, which are instead retained from the target force.

The three built-in forces (player, enemy and neutral) can't be destroyed, meaning they can't be used as the source argument to this function.

The source force is not removed until the end of the current tick, or if called during the [on_forces_merging](runtime:on_forces_merging) or [on_forces_merged](runtime:on_forces_merged) event, the end of the next tick.

**Parameters:**

- `destination` `ForceID`: The force to reassign all entities to.
- `source` `ForceID`: The force to remove.

### mute_player

Mutes the given player. Does nothing if the player running this isn't an admin.

**Parameters:**

- `player` `PlayerIdentification`: The player to mute.

### play_sound

Play a sound for every player in the game.

The sound is not played if its location is not [charted](runtime:LuaForce::chart) for that player.

**Parameters:**

- `sound_specification` `PlaySoundSpecification`: The sound to play.

### print

Print text to the chat console all players.

By default, messages that are identical to a message sent in the last 60 ticks are not printed again.

**Parameters:**

- `message` `LocalisedString`: 
- `print_settings` `PrintSettings` _(optional)_: 

### purge_player

Purges the given players messages from the game. Does nothing if the player running this isn't an admin.

**Parameters:**

- `player` `PlayerIdentification`: The player to purge.

### regenerate_entity

Regenerate autoplacement of some entities on all surfaces. This can be used to autoplace newly-added entities.

All specified entity prototypes must be autoplacable.

**Parameters:**

- `entities` : Prototype names of entity or entities to autoplace.

### reload_mods

Forces a reload of all mods.

This will act like saving and loading from the mod(s) perspective.

This will do nothing if run in multiplayer.

This disables the replay if replay is enabled.

### reload_script

Forces a reload of the scenario script from the original scenario location.

This disables the replay if replay is enabled.

### remove_offline_players

Remove players who are currently not connected from the map.

**Parameters:**

- `players` ``PlayerIdentification`[]` _(optional)_: List of players to remove. If not specified, remove all offline players.

### reset_game_state

Reset scenario state (game_finished, player_won, etc.).

### reset_time_played

Resets the amount of time played for this map.

### save_atlas

Saves the current configuration of Atlas to a file. This will result in huge file containing all of the game graphics moved to as small space as possible.

Exists mainly for debugging reasons.

### server_save

Instruct the server to save the map. Only actually saves when in multiplayer.

**Parameters:**

- `name` `string` _(optional)_: Save file name. If not specified, the currently running save is overwritten. If there is no current save, no save is made.

### set_game_state

Set scenario state. Any parameters not provided do not change the current state.

**Parameters:**

- `can_continue` `boolean` _(optional)_: 
- `game_finished` `boolean` _(optional)_: 
- `next_level` `string` _(optional)_: 
- `player_won` `boolean` _(optional)_: 

### set_lose_ending_info

Set losing ending information for the current scenario.

**Parameters:**

- `bullet_points` ``LocalisedString`[]` _(optional)_: 
- `final_message` `LocalisedString` _(optional)_: 
- `image_path` `string` _(optional)_: 
- `message` `LocalisedString` _(optional)_: 
- `title` `LocalisedString`: 

### set_wait_for_screenshots_to_finish

Forces the screenshot saving system to wait until all queued screenshots have been written to disk.

### set_win_ending_info

Set winning ending information for the current scenario.

**Parameters:**

- `bullet_points` ``LocalisedString`[]` _(optional)_: 
- `final_message` `LocalisedString` _(optional)_: 
- `image_path` `string` _(optional)_: 
- `message` `LocalisedString` _(optional)_: 
- `title` `LocalisedString`: 

### show_message_dialog

Show an in-game message dialog.

Can only be used when the map contains exactly one player.

**Parameters:**

- `image` `string` _(optional)_: Path to an image to show on the dialog
- `point_to` `GuiArrowSpecification` _(optional)_: If specified, dialog will show an arrow pointing to this place. When not specified, the arrow will point to the player's position. (Use `point_to={type="nowhere"}` to remove the arrow entirely.) The dialog itself will be placed near the arrow's target.
- `style` `string` _(optional)_: The gui style to use for this speech bubble. Must be of type speech_bubble.
- `text` `LocalisedString`: What the dialog should say
- `wrapper_frame_style` `string` _(optional)_: Must be of type flow_style.

### take_screenshot

Take a screenshot of the game and save it to the `script-output` folder, located in the game's [user data directory](https://wiki.factorio.com/User_data_directory). The name of the image file can be specified via the `path` parameter.

If Factorio is running headless, this function will do nothing.

**Parameters:**

- `allow_in_replay` `boolean` _(optional)_: Whether to save the screenshot even during replay playback. Defaults to `false`.
- `anti_alias` `boolean` _(optional)_: Whether to render in double resolution and downscale the result (including GUI). Defaults to `false`.
- `by_player` `PlayerIdentification` _(optional)_: If defined, the screenshot will only be taken for this player.
- `daytime` `double` _(optional)_: Overrides the current surface daytime for the duration of screenshot rendering.
- `force_render` `boolean` _(optional)_: Screenshot requests are processed in between game update and render. The game may skip rendering (ie. drop frames) if the previous frame has not finished rendering or the game simulation starts to fall below 60 updates per second. If `force_render` is set to `true`, the game won't drop frames and process the screenshot request at the end of the update in which the request was created. This is not honored on multiplayer clients that are catching up to server. Defaults to `false`.
- `hide_clouds` `boolean` _(optional)_: If `true` cloud shadows on ground won't be rendered. Defaults to `false`.
- `hide_fog` `boolean` _(optional)_: If `true` fog effect and foreground space dust effect won't be rendered. Defaults to `false`.
- `path` `string` _(optional)_: The name of the image file. It should include a file extension indicating the desired format. Supports `.png`, `.jpg` /`.jpeg`, `.tga` and `.bmp`. Providing a directory path (ex. `"save/here/screenshot.png"`) will create the necessary folder structure in `script-output`. Defaults to `"screenshot.png"`.
- `player` `PlayerIdentification` _(optional)_: The player to focus on. Defaults to the local player.
- `position` `MapPosition` _(optional)_: If defined, the screenshot will be centered on this position. Otherwise, the screenshot will center on `player`.
- `quality` `int` _(optional)_: The `.jpg` render quality as a percentage (from 0% to 100% inclusive), if used. A lower value means a more compressed image. Defaults to `80`.
- `resolution` `TilePosition` _(optional)_: The maximum allowed resolution is 16384x16384 (8192x8192 when `anti_alias` is `true`), but the maximum recommended resolution is 4096x4096 (resp. 2048x2048). The `x` value of the position is used as the width, the `y` value as the height.
- `show_cursor_building_preview` `boolean` _(optional)_: When `true` and when `player` is specified, the building preview for the item in the player's cursor will also be rendered. Defaults to `false`.
- `show_entity_info` `boolean` _(optional)_: Whether to include entity info ("Alt mode") or not. Defaults to `false`.
- `show_gui` `boolean` _(optional)_: Whether to include GUIs in the screenshot or not. Defaults to `false`.
- `surface` `SurfaceIdentification` _(optional)_: If defined, the screenshot will be taken on this surface.
- `water_tick` `uint` _(optional)_: Overrides the tick of water animation, if animated water is enabled.
- `zoom` `double` _(optional)_: The map zoom to take the screenshot at. Defaults to `1`.

### take_technology_screenshot

Take a screenshot of the technology screen and save it to the `script-output` folder, located in the game's [user data directory](https://wiki.factorio.com/User_data_directory). The name of the image file can be specified via the `path` parameter.

**Parameters:**

- `path` `string` _(optional)_: The name of the image file. It should include a file extension indicating the desired format. Supports `.png`, `.jpg` /`.jpeg`, `.tga` and `.bmp`. Providing a directory path (ex. `"save/here/screenshot.png"`) will create the necessary folder structure in `script-output`. Defaults to `"technology-screenshot.png"`.
- `player` `PlayerIdentification`: The screenshot will be taken for this player.
- `quality` `int` _(optional)_: The `.jpg` render quality as a percentage (from 0% to 100% inclusive), if used. A lower value means a more compressed image. Defaults to `80`.
- `selected_technology` `TechnologyID` _(optional)_: The technology to highlight.
- `skip_disabled` `boolean` _(optional)_: If `true`, disabled technologies will be skipped. Their successors will be attached to the disabled technology's parents. Defaults to `false`.

### unban_player

Unbans the given player from this multiplayer game. Does nothing if this is a single player game of if the player running this isn't an admin.

**Parameters:**

- `player` : The player to unban.

### unmute_player

Unmutes the given player. Does nothing if the player running this isn't an admin.

**Parameters:**

- `player` `PlayerIdentification`: The player to unmute.

## Attributes

### allow_tip_activation

**Type:** `boolean`

If the tips are allowed to be activated in this scenario, it is false by default.

Can't be modified in a simulation (menu screen, tips and tricks simulation, factoriopedia simulation etc.)

### autosave_enabled

**Type:** `boolean`

True by default. Can be used to disable autosaving. Make sure to turn it back on soon after.

### backer_names

**Type:** `LuaCustomTable<`uint`, `string`>` _(read-only)_

Array of the names of all the backers that supported the game development early on. These are used as names for labs, locomotives, radars, roboports, and train stops.

### blueprints

**Type:** ``LuaRecord`[]` _(read-only)_

Records contained in the "game blueprints" tab of the blueprint library.

### connected_players

**Type:** ``LuaPlayer`[]` _(read-only)_

The players that are currently online.

This does *not* index using player index. See [LuaPlayer::index](runtime:LuaPlayer::index) on each player instance for the player index. This is primarily useful when you want to do some action against all online players.

### console_command_used

**Type:** `boolean` _(read-only)_

Whether a console command has been used.

### default_map_gen_settings

**Type:** `MapGenSettings` _(read-only)_

The default map gen settings for this save.

### difficulty

**Type:** `defines.difficulty` _(read-only)_

Current scenario difficulty.

### difficulty_settings

**Type:** `DifficultySettings` _(read-only)_

The currently active set of difficulty settings. Even though this property is marked as read-only, the members of the dictionary that is returned can be modified mid-game.

### draw_resource_selection

**Type:** `boolean`

True by default. Can be used to disable the highlighting of resource patches when they are hovered on the map.

### enemy_has_vision_on_land_mines

**Type:** `boolean`

Determines if enemy land mines are completely invisible or not.

### finished

**Type:** `boolean` _(read-only)_

True while the victory screen is shown.

### finished_but_continuing

**Type:** `boolean` _(read-only)_

True after players finished the game and clicked "continue".

### forces

**Type:** `LuaCustomTable<, `LuaForce`>` _(read-only)_

Get a table of all the forces that currently exist. This sparse table allows you to find forces by indexing it with either their `name` or `index`. Iterating this table with `pairs()` will provide the `name`s as the keys. Iterating with `ipairs()` will not work at all.

### map_settings

**Type:** `MapSettings` _(read-only)_

The currently active set of map settings. Even though this property is marked as read-only, the members of the dictionary that is returned can be modified mid-game.

This does not contain difficulty settings, use [LuaGameScript::difficulty_settings](runtime:LuaGameScript::difficulty_settings) instead.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### permissions

**Type:** `LuaPermissionGroups` _(read-only)_



### planets

**Type:** `LuaCustomTable<`string`, `LuaPlanet`>` _(read-only)_



### player

**Type:** `LuaPlayer` _(read-only)_

This property is only populated inside [custom command](runtime:LuaCommandProcessor) handlers and when writing [Lua console commands](https://wiki.factorio.com/Console#Scripting_and_cheat_commands). Returns the player that is typing the command, `nil` in all other instances.

See [LuaGameScript::players](runtime:LuaGameScript::players) for accessing all players.

### players

**Type:** `LuaCustomTable<, `LuaPlayer`>` _(read-only)_

Get a table of all the players that currently exist. This sparse table allows you to find players by indexing it with either their `name` or `index`. Iterating this table with `pairs()` will provide the `index`es as the keys. Iterating with `ipairs()` will not work at all.

If only a single player is required, [LuaGameScript::get_player](runtime:LuaGameScript::get_player) should be used instead, as it avoids the unnecessary overhead of passing the whole table to Lua.

### simulation

**Type:** `LuaSimulation` _(read-only)_

Simulation-related functions, or `nil` if the current game is not a simulation.

### speed

**Type:** `float`

Speed to update the map at. 1.0 is normal speed -- 60 UPS. Minimum value is 0.01.

### surfaces

**Type:** `LuaCustomTable<, `LuaSurface`>` _(read-only)_

Get a table of all the surfaces that currently exist. This sparse table allows you to find surfaces by indexing it with either their `name` or `index`. Iterating this table with `pairs()` will provide the `name`s as the keys. Iterating with `ipairs()` will not work at all.

### technology_notifications_enabled

**Type:** `boolean`

True by default. Can be used to prevent the game engine from printing certain messages.

### tick

**Type:** `MapTick` _(read-only)_

Current map tick.

### tick_paused

**Type:** `boolean`

If the tick has been paused. This means that entity update has been paused.

### ticks_played

**Type:** `MapTick` _(read-only)_

The number of ticks since this game was created using either "new game" or "new game from scenario". Notably, this number progresses even when the game is [tick_paused](runtime:LuaGameScript::tick_paused).

This differs from [LuaGameScript::tick](runtime:LuaGameScript::tick) in that creating a game from a scenario always starts with this value at `0`, even if the scenario has its own level data where the `tick` has progressed past `0`.

### ticks_to_run

**Type:** `uint`

The number of ticks to be run while the tick is paused.

When [LuaGameScript::tick_paused](runtime:LuaGameScript::tick_paused) is true, ticks_to_run behaves the following way: While this is > 0, the entity update is running normally and this value is decremented every tick. When this reaches 0, the game will pause again.

### train_manager

**Type:** `LuaTrainManager` _(read-only)_



