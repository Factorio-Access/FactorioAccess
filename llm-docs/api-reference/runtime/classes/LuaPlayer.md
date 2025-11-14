# LuaPlayer

A player in the game. Pay attention that a player may or may not have a character, which is the [LuaEntity](runtime:LuaEntity) of the little guy running around the world doing things.

**Parent:** [LuaControl](LuaControl.md)

## Attributes

### physical_surface

The surface this player's physical controller is on.

**Read type:** `LuaSurface`

### physical_surface_index

Unique ID associated with the surface this player's physical controller is currently on.

**Read type:** `uint32`

### physical_position

The current position of this player's physical controller.

**Read type:** `MapPosition`

### physical_vehicle

The current vehicle of this player's physical controller.

**Read type:** `LuaEntity`

**Optional:** Yes

### character

The character attached to this player, if any. Returns `nil` when the player is disconnected (see [LuaPlayer::connected](runtime:LuaPlayer::connected)).

**Read type:** `LuaEntity`

**Write type:** `LuaEntity`

**Optional:** Yes

### cutscene_character

When in a cutscene; the character this player would be using once the cutscene is over, if any. Returns `nil` when the player is disconnected (see [LuaPlayer::connected](runtime:LuaPlayer::connected)).

**Read type:** `LuaEntity`

**Optional:** Yes

### index

This player's index in [LuaGameScript::players](runtime:LuaGameScript::players) (unique ID). It is assigned when a player is created, and remains so (even when the player is not [connected](runtime:LuaPlayer::connected)) until the player is irreversibly [removed](runtime:on_player_removed). Indexes of removed players can be reused.

**Read type:** `uint32`

### gui

**Read type:** `LuaGui`

### opened_self

`true` if the player opened itself. I.e. if they opened the character or god-controller GUI.

**Read type:** `boolean`

### controller_type

**Read type:** `defines.controllers`

### physical_controller_type

The player's "physical" controller. When a player is in the remote controller, this specifies the controller they will return to. When the player is not in the remote controller, this is equivalent to [LuaPlayer::controller_type](runtime:LuaPlayer::controller_type).

**Read type:** `defines.controllers`

### stashed_controller_type

The stashed controller type, if any. This is mainly useful when a player is in the map editor.

**Read type:** `defines.controllers`

**Optional:** Yes

### spidertron_remote_selection

All SpiderVehicles currently selected by the player, if they are holding a spidertron remote.

**Read type:** Array[`LuaEntity`]

**Write type:** Array[`LuaEntity`]

**Optional:** Yes

### zoom

The current player controller's zoom level. Must be positive. The baseline zoom level is 1. Values greater than 1 will zoom in closer to the world and values between 0 and 1 will zoom out away from the world.

Writing values outside the current zoom limits is always valid, but read values will always be clamped to the range defined by [LuaPlayer::zoom_limits](runtime:LuaPlayer::zoom_limits).

**Read type:** `double`

**Write type:** `double`

### zoom_limits

The player's current controller's zoom limits.

Reading this field creates a copy, so modifying the returned table's fields directly will not alter the player's zoom limits. To change the zoom limits for the player's current controller, set the entire field to the desired [ZoomLimits](runtime:ZoomLimits) table.

Zoom limits are defined and remembered per controller type. If you set the zoom limits of the character controller, then every time the player uses the character controller, it will remember and use the zoom limits previously set. However, other controller types will not use the character controller zoom limits; each controller type must have its zoom limits defined separately.

To set the zoom limits of ANY controller type, not just the currently active one, use [LuaPlayer::set_zoom_limits](runtime:LuaPlayer::set_zoom_limits).

**Read type:** `ZoomLimits`

**Write type:** `ZoomLimits`

### centered_on

The entity being centered on in remote view.

When writing, the player will be switched to remote view (if not already in it) and centered on the given entity.

**Read type:** `LuaEntity`

**Write type:** `LuaEntity`

**Optional:** Yes

### game_view_settings

The player's game view settings.

**Read type:** `GameViewSettings`

**Write type:** `GameViewSettings`

### minimap_enabled

`true` if the minimap is visible.

**Read type:** `boolean`

**Write type:** `boolean`

### color

The color associated with the player. This will be used to tint the player's character as well as their buildings and vehicles.

**Read type:** `Color`

**Write type:** `Color`

### chat_color

The color used when this player talks in game.

**Read type:** `Color`

**Write type:** `Color`

### name

The player's username.

**Read type:** `string`

### tag

The tag that is shown after the player in chat, on the map and above multiplayer selection rectangles.

**Read type:** `string`

**Write type:** `string`

### connected

`true` if the player is currently connected to the game.

**Read type:** `boolean`

### admin

`true` if the player is an admin.

Trying to change player admin status from the console when you aren't an admin does nothing.

**Read type:** `boolean`

**Write type:** `boolean`

### entity_copy_source

The source entity used during entity settings copy-paste, if any.

**Read type:** `LuaEntity`

**Optional:** Yes

### afk_time

How many ticks since the last action of this player.

**Read type:** `uint32`

### online_time

How many ticks did this player spend playing this save (all sessions combined).

**Read type:** `uint32`

### last_online

At what tick this player was last online.

**Read type:** `uint32`

### permission_group

The permission group this player is part of, if any.

**Read type:** `LuaPermissionGroup`

**Write type:** `LuaPermissionGroup`

**Optional:** Yes

### mod_settings

The current per-player settings for the this player, indexed by prototype name. Returns the same structure as [LuaSettings::get_player_settings](runtime:LuaSettings::get_player_settings). This table becomes invalid if its associated player does.

Even though this attribute is marked as read-only, individual settings can be changed by overwriting their [ModSetting](runtime:ModSetting) table. Mods can only change their own settings. Using the in-game console, all player settings can be changed.

**Read type:** LuaCustomTable[`string`, `ModSetting`]

### ticks_to_respawn

The number of ticks until this player will respawn. `nil` if this player is not waiting to respawn.

Set to `nil` to immediately respawn the player.

Set to any positive value to trigger the respawn state for this player.

**Read type:** `uint32`

**Write type:** `uint32`

**Optional:** Yes

### display_resolution

The display resolution for this player.

During [on_player_created](runtime:on_player_created), this attribute will always return a resolution of `{width=1920, height=1080}`. To get the actual resolution, listen to the [on_player_display_resolution_changed](runtime:on_player_display_resolution_changed) event raised shortly afterwards.

**Read type:** `DisplayResolution`

### display_scale

The display scale for this player.

During [on_player_created](runtime:on_player_created), this attribute will always return a scale of `1`. To get the actual scale, listen to the [on_player_display_scale_changed](runtime:on_player_display_scale_changed) event raised shortly afterwards.

**Read type:** `double`

### display_density_scale

The display density scale for this player. The display density scale is the factor of [LuaPlayer::display_scale](runtime:LuaPlayer::display_scale) that is determined by the physical DPI of the screen that Factorio is running on. In most cases, the default value is 1. If the player is playing on a high-density display, this value may be 2 or greater.

During [on_player_created](runtime:on_player_created), this attribute will always return a scale of `1`. To get the actual scale, listen to the [on_player_display_density_scale_changed](runtime:on_player_display_density_scale_changed) event raised shortly afterwards.

**Read type:** `double`

### locale

The active locale for this player.

During [on_player_created](runtime:on_player_created), this attribute will be `en`. To get the actual value, listen to the [on_player_locale_changed](runtime:on_player_locale_changed) event raised shortly afterwards.

**Read type:** `string`

### blueprint_to_setup

The item stack containing a blueprint to be setup.

**Read type:** `LuaItemStack`

### blueprints

Records contained in the player's blueprint library.

**Read type:** Array[`LuaRecord`]

### render_mode

The render mode of the player, like map or zoom to world.

**Read type:** `defines.render_mode`

### input_method

The input method of the player, mouse and keyboard or game controller

**Read type:** `defines.input_method`

### spectator

If `true`, zoom-to-world noise effect will be disabled and environmental sounds will be based on zoom-to-world view instead of position of player's character.

**Read type:** `boolean`

**Write type:** `boolean`

### show_on_map

If `true`, circle and name of given player is rendered on the map/chart.

**Read type:** `boolean`

**Write type:** `boolean`

### remove_unfiltered_items

If items not included in this map editor infinity inventory filters should be removed.

**Read type:** `boolean`

**Write type:** `boolean`

### infinity_inventory_filters

The filters for this map editor infinity inventory settings.

**Read type:** Array[`InfinityInventoryFilter`]

**Write type:** Array[`InfinityInventoryFilter`]

### auto_sort_main_inventory

If the main inventory will be auto sorted.

**Read type:** `boolean`

### hand_location

The original location of the item in the cursor, marked with a hand. `nil` if the cursor stack is empty. When writing, the specified inventory slot must be empty and the cursor stack must not be empty.

**Read type:** `ItemStackLocation`

**Write type:** `ItemStackLocation`

**Optional:** Yes

### cursor_stack_temporary

Returns true if the current item stack in cursor will be destroyed after clearing the cursor. Manually putting it into inventory still preserves the item. If the cursor stack is not one of the supported types (blueprint, blueprint-book, deconstruction-planner, upgrade-planner), write operation will be silently ignored.

**Read type:** `boolean`

**Write type:** `boolean`

### undo_redo_stack

The undo and redo stack for this player.

**Read type:** `LuaUndoRedoStack`

### drag_target

The wire drag target for this player, if any.

**Read type:** `DragTarget`

**Optional:** Yes

### map_view_settings

The player's map view settings. To write to this, use a table containing the fields that should be changed.

**Write type:** `MapViewSettings`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### set_ending_screen_data

Setup the screen to be shown when the game is finished.

**Parameters:**

- `message` `LocalisedString` - Message to be shown.
- `file` `string` *(optional)* - Path to image to be shown.

### print

Print text to the chat console.

By default, messages that are identical to a message sent in the last 60 ticks are not printed again.

**Parameters:**

- `message` `LocalisedString`
- `print_settings` `PrintSettings` *(optional)*

### clear_console

Clear the chat console.

### get_goal_description

Get the current goal description, as a localised string.

**Returns:**

- `LocalisedString`

### set_goal_description

Set the text in the goal window (top left).

**Parameters:**

- `text` `LocalisedString` *(optional)* - The text to display. Lines can be delimited with `\n`. Passing an empty string or omitting this parameter entirely will make the goal window disappear.
- `only_update` `boolean` *(optional)* - When `true`, won't play the "goal updated" sound.

### set_controller

Set the controller type of the player.

Setting a player to [defines.controllers.editor](runtime:defines.controllers.editor) auto promotes the player to admin and enables cheat mode. Setting a player to [defines.controllers.editor](runtime:defines.controllers.editor) also requires the calling player be an admin.

**Parameters:**

- `type` `defines.controllers` - Which controller to use.
- `character` `LuaEntity` *(optional)* - Entity to control. Mandatory when `type` is [defines.controllers.character](runtime:defines.controllers.character), ignored otherwise.
- `waypoints` Array[`CutsceneWaypoint`] *(optional)* - List of waypoints for the cutscene controller. This parameter is mandatory when `type` is [defines.controllers.cutscene](runtime:defines.controllers.cutscene).
- `start_position` `MapPosition` *(optional)* - If specified and `type` is [defines.controllers.cutscene](runtime:defines.controllers.cutscene), the cutscene will start at this position. If not given the start position will be the player position.
- `start_zoom` `double` *(optional)* - If specified and `type` is [defines.controllers.cutscene](runtime:defines.controllers.cutscene), the cutscene will start at this zoom level. If not given the start zoom will be the player's zoom.
- `final_transition_time` `uint32` *(optional)* - If specified and `type` is [defines.controllers.cutscene](runtime:defines.controllers.cutscene), it is the time in ticks it will take for the camera to pan from the final waypoint back to the starting position. If not given the camera will not pan back to the start position/zoom.
- `chart_mode_cutoff` `double` *(optional)* - If specified and `type` is [defines.controllers.cutscene](runtime:defines.controllers.cutscene), the game will switch to chart-mode (map zoomed out) rendering when the zoom level is less than this value.
- `position` `MapPosition` *(optional)* - If specified and `type` is [defines.controllers.remote](runtime:defines.controllers.remote), the position the remote controller will be centered on.
- `surface` `SurfaceIdentification` *(optional)* - If specified and `type` is [defines.controllers.remote](runtime:defines.controllers.remote), the surface the remote controller will be put on.

### drag_wire

Start/end wire dragging at the specified location, wire type is based on the cursor contents

**Parameters:**

- `position` `MapPosition` - Position at which cursor was clicked. Used only to decide which side of arithmetic combinator, decider combinator or power switch is to be connected. Entity itself to be connected is based on the player's selected entity.

**Returns:**

- `boolean` - `true` if the action did something

### disable_recipe_groups

Disable recipe groups.

### enable_recipe_groups

Enable recipe groups.

### disable_recipe_subgroups

Disable recipe subgroups.

### enable_recipe_subgroups

Enable recipe subgroups.

### print_entity_statistics

Print entity statistics to the player's console.

**Parameters:**

- `entities` Array[`EntityWithQualityID`] *(optional)* - Entity prototypes to get statistics for. If not specified or empty, display statistics for all entities.

### print_robot_jobs

Print construction robot job counts to the player's console.

### print_lua_object_statistics

Print LuaObject counts per mod.

### unlock_achievement

Unlock the achievements of the given player. This has any effect only when this is the local player, the achievement isn't unlocked so far and the achievement is of the type "achievement".

**Parameters:**

- `name` `string` - name of the achievement to unlock

### clear_cursor

Invokes the "clear cursor" action on the player as if the user pressed it.

**Returns:**

- `boolean` - Whether the cursor is now empty.

### create_character

Creates and attaches a character entity to this player.

The player must not have a character already connected and must be online (see [LuaPlayer::connected](runtime:LuaPlayer::connected)).

**Parameters:**

- `character` `EntityWithQualityID` *(optional)* - The character to create else the default is used.

**Returns:**

- `boolean` - Whether the character was created.

### add_alert

Adds an alert to this player for the given entity of the given alert type.

**Parameters:**

- `entity` `LuaEntity`
- `type` `defines.alert_type`

### add_custom_alert

Adds a custom alert to this player.

**Parameters:**

- `entity` `LuaEntity` - If the alert is clicked, the map will open at the position of this entity.
- `icon` `SignalID`
- `message` `LocalisedString`
- `show_on_map` `boolean`

### remove_alert

Removes all alerts matching the given filters or if an empty filters table is given all alerts are removed.

**Parameters:**

- `entity` `LuaEntity` *(optional)*
- `prototype` `EntityID` *(optional)*
- `position` `MapPosition` *(optional)*
- `type` `defines.alert_type` *(optional)*
- `surface` `SurfaceIdentification` *(optional)*
- `icon` `SignalID` *(optional)*
- `message` `LocalisedString` *(optional)*

### get_alerts

Get all alerts matching the given filters, or all alerts if no filters are given.

**Parameters:**

- `entity` `LuaEntity` *(optional)*
- `prototype` `LuaEntityPrototype` *(optional)*
- `position` `MapPosition` *(optional)*
- `type` `defines.alert_type` *(optional)*
- `surface` `SurfaceIdentification` *(optional)*

**Returns:**

- Dictionary[`uint32`, Dictionary[`defines.alert_type`, Array[`Alert`]]] - A mapping of surface index to an array of arrays of [alerts](runtime:Alert) indexed by the [alert type](runtime:defines.alert_type).

### mute_alert

Mutes alerts for the given alert category.

**Parameters:**

- `alert_type` `defines.alert_type`

**Returns:**

- `boolean` - Whether the alert type was muted (false if it was already muted).

### unmute_alert

Unmutes alerts for the given alert category.

**Parameters:**

- `alert_type` `defines.alert_type`

**Returns:**

- `boolean` - Whether the alert type was unmuted (false if it was wasn't muted).

### is_alert_muted

If the given alert type is currently muted.

**Parameters:**

- `alert_type` `defines.alert_type`

**Returns:**

- `boolean`

### enable_alert

Enables alerts for the given alert category.

**Parameters:**

- `alert_type` `defines.alert_type`

**Returns:**

- `boolean` - Whether the alert type was enabled (false if it was already enabled).

### disable_alert

Disables alerts for the given alert category.

**Parameters:**

- `alert_type` `defines.alert_type`

**Returns:**

- `boolean` - Whether the alert type was disabled (false if it was already disabled).

### is_alert_enabled

If the given alert type is currently enabled.

**Parameters:**

- `alert_type` `defines.alert_type`

**Returns:**

- `boolean`

### add_pin

Adds a pin to this player for the given pin specification. Either entity, player, or surface and position must be defined.

**Parameters:**

- `label` `string` *(optional)*
- `preview_distance` `uint16` *(optional)* - Defaults to `16`.
- `always_visible` `boolean` *(optional)* - Defaults to `true`.
- `entity` `LuaEntity` *(optional)* - The entity to pin.
- `player` `PlayerIdentification` *(optional)* - The player to pin.
- `surface` `SurfaceIdentification` *(optional)* - The surface to create the pin on.
- `position` `MapPosition` *(optional)* - Where to create the pin. Required when surface is defined.

### pipette_entity

Invokes the "smart pipette" action on the player as if the user pressed it. This method is deprecated in favor of [LuaPlayer::pipette](runtime:LuaPlayer::pipette) and should not be used.

**Parameters:**

- `entity` `EntityWithQualityID`
- `allow_ghost` `boolean` *(optional)* - Defaults to false.

**Returns:**

- `boolean` - Whether the smart pipette found something to place.

### pipette

Invokes the "smart pipette" action on the player as if the user pressed it.

**Parameters:**

- `id` `PipetteID`
- `quality` `QualityID` *(optional)*
- `allow_ghost` `boolean` *(optional)* - Defaults to false.

**Returns:**

- `boolean` - Whether the smart pipette found something to put into the cursor.

### can_build_from_cursor

Checks if this player can build what ever is in the cursor on the surface the player is on.

**Parameters:**

- `position` `MapPosition` - Where the entity would be placed
- `direction` `defines.direction` *(optional)* - Direction the entity would be placed
- `flip_horizontal` `boolean` *(optional)* - Whether to flip the blueprint horizontally. Defaults to `false`.
- `flip_vertical` `boolean` *(optional)* - Whether to flip the blueprint vertically. Defaults to `false`.
- `build_mode` `defines.build_mode` *(optional)* - Which build mode should be used instead of normal build. Defaults to `defines.build_mode.normal`.
- `terrain_building_size` `uint32` *(optional)* - The size for building terrain if building terrain. Defaults to `2`.
- `skip_fog_of_war` `boolean` *(optional)* - If chunks covered by fog-of-war are skipped. Defaults to `false`.

**Returns:**

- `boolean`

### build_from_cursor

Builds whatever is in the cursor on the surface the player is on. The cursor stack will automatically be reduced as if the player built normally.

**Parameters:**

- `position` `MapPosition` - Where the entity would be placed
- `direction` `defines.direction` *(optional)* - Direction the entity would be placed
- `mirror` `boolean` *(optional)* - Whether to mirror the entity
- `flip_horizontal` `boolean` *(optional)* - Whether to flip the blueprint horizontally. Defaults to `false`.
- `flip_vertical` `boolean` *(optional)* - Whether to flip the blueprint vertically. Defaults to `false`.
- `build_mode` `defines.build_mode` *(optional)* - Which build mode should be used instead of normal build. Defaults to `defines.build_mode.normal`.
- `terrain_building_size` `uint32` *(optional)* - The size for building terrain if building terrain. Defaults to `2`.
- `skip_fog_of_war` `boolean` *(optional)* - If chunks covered by fog-of-war are skipped. Defaults to `false`.

### clear_inventory_highlights

Clears the blinking of the inventory based on insertion of items

### use_from_cursor

Uses the current item in the cursor if it's a capsule or does nothing if not.

**Parameters:**

- `position` `MapPosition` - Where the item would be used.

### play_sound

Play a sound for this player.

The sound is not played if its location is not [charted](runtime:LuaForce::chart) for this player.

**Parameters:**

- `sound_specification` `PlaySoundSpecification` - The sound to play.

### get_associated_characters

The characters associated with this player.

The array will always be empty when the player is disconnected (see [LuaPlayer::connected](runtime:LuaPlayer::connected)) regardless of there being associated characters.

Characters associated with this player will be logged off when this player disconnects but are not controlled by any player.

**Returns:**

- Array[`LuaEntity`]

### associate_character

Associates a character with this player.

The character must not be connected to any controller.

If this player is currently disconnected (see [LuaPlayer::connected](runtime:LuaPlayer::connected)) the character will be immediately "logged off".

See [LuaPlayer::get_associated_characters](runtime:LuaPlayer::get_associated_characters) for more information.

**Parameters:**

- `character` `LuaEntity` - The character entity.

### disassociate_character

Disassociates a character from this player. This is functionally the same as setting [LuaEntity::associated_player](runtime:LuaEntity::associated_player) to `nil`.

See [LuaPlayer::get_associated_characters](runtime:LuaPlayer::get_associated_characters) for more information.

**Parameters:**

- `character` `LuaEntity` - The character entity

### swap_characters

Swaps this player's character with another player's character.

**Parameters:**

- `player` `PlayerIdentification` - The player to swap characters with.

**Returns:**

- `boolean` - `true` if the swap was successful.

### create_local_flying_text

Spawn flying text that is only visible to this player. Either `position` or `create_at_cursor` are required. When `create_at_cursor` is `true`, all parameters other than `text` are ignored.

If no custom `speed` is set and the text is longer than 25 characters, its `time_to_live` and `speed` are dynamically adjusted to give the player more time to read it.

Local flying text is not saved, which means it will disappear after a save/load-cycle.

**Parameters:**

- `text` `LocalisedString` - The flying text to show.
- `position` `MapPosition` *(optional)* - The location on the map at which to show the flying text.
- `surface` `SurfaceIdentification` *(optional)* - The surface which this text will be shown on. Defaults to player surface.
- `create_at_cursor` `boolean` *(optional)* - If `true`, the flying text is created at the player's cursor. Defaults to `false`.
- `color` `Color` *(optional)* - The color of the flying text. Defaults to white text.
- `time_to_live` `uint32` *(optional)* - The amount of ticks that the flying text will be shown for. Defaults to `80`.
- `speed` `double` *(optional)* - The speed at which the text rises upwards in tiles/second. Can't be a negative value.

### clear_local_flying_texts

Clear any active flying texts for this player.

### get_quick_bar_slot

Gets the quick bar filter for the given slot or `nil`.

**Parameters:**

- `index` `uint32` - The slot index. 1 for the first slot of page one, 2 for slot two of page one, 11 for the first slot of page 2, etc.

**Returns:**

- `ItemFilter` *(optional)*

### set_quick_bar_slot

Sets the quick bar filter for the given slot. If a [LuaItemStack](runtime:LuaItemStack) is provided, the slot will be set to that particular item instance if it has extra data, for example a specific blueprint or spidertron remote. Otherwise, it will be set to all items of that prototype, for example iron plates.

**Parameters:**

- `index` `uint32` - The slot index. 1 for the first slot of page one, 2 for slot two of page one, 11 for the first slot of page 2, etc.
- `filter` `LuaItemStack` | `ItemWithQualityID` | `nil` - The filter or `nil` to clear it.

### get_active_quick_bar_page

Gets which quick bar page is being used for the given screen page or `nil` if not known.

**Parameters:**

- `index` `uint32` - The screen page. Index 1 is the top row in the gui. Index can go beyond the visible number of bars on the screen to account for the interface config setting change.

**Returns:**

- `uint8` *(optional)*

### set_active_quick_bar_page

Sets which quick bar page is being used for the given screen page.

**Parameters:**

- `screen_index` `uint32` - The screen page. Index 1 is the top row in the gui. Index can go beyond the visible number of bars on the screen to account for the interface config setting change.
- `page_index` `uint32` - The new quick bar page.

### jump_to_cutscene_waypoint

Jump to the specified cutscene waypoint. Only works when the player is viewing a cutscene.

**Parameters:**

- `waypoint_index` `uint32`

### exit_cutscene

Exit the current cutscene. Errors if not in a cutscene.

### exit_remote_view

Exit remote view if possible. Exiting will fail if the player is in a rocket or in a platform.

### is_shortcut_toggled

Is a custom Lua shortcut currently toggled?

**Parameters:**

- `prototype_name` `string` - Prototype name of the custom shortcut.

**Returns:**

- `boolean`

### is_shortcut_available

Is a custom Lua shortcut currently available?

**Parameters:**

- `prototype_name` `string` - Prototype name of the custom shortcut.

**Returns:**

- `boolean`

### set_shortcut_toggled

Toggle or untoggle a custom Lua shortcut

**Parameters:**

- `prototype_name` `string` - Prototype name of the custom shortcut.
- `toggled` `boolean`

### set_shortcut_available

Make a custom Lua shortcut available or unavailable.

**Parameters:**

- `prototype_name` `string` - Prototype name of the custom shortcut.
- `available` `boolean`

### connect_to_server

Asks the player if they would like to connect to the given server.

This only does anything when used on a multiplayer peer. Single player and server hosts will ignore the prompt.

**Parameters:**

- `address` `string` - The server (address:port) if port is not given the default Factorio port is used.
- `name` `LocalisedString` *(optional)* - The name of the server.
- `description` `LocalisedString` *(optional)*
- `password` `string` *(optional)* - The password if different from the one used to join this game. Note, if the current password is not empty but the one required to join the new server is an empty string should be given for this field.

### toggle_map_editor

Toggles this player into or out of the map editor. Does nothing if this player isn't an admin or if the player doesn't have permission to use the map editor.

### request_translation

Requests a translation for the given localised string. If the request is successful, the [on_string_translated](runtime:on_string_translated) event will be fired with the results.

Does nothing if this player is not connected (see [LuaPlayer::connected](runtime:LuaPlayer::connected)).

**Parameters:**

- `localised_string` `LocalisedString`

**Returns:**

- `uint32` *(optional)* - The unique ID for the requested translation.

### request_translations

Requests translation for the given set of localised strings. If the request is successful, a [on_string_translated](runtime:on_string_translated) event will be fired for each string with the results.

Does nothing if this player is not connected (see [LuaPlayer::connected](runtime:LuaPlayer::connected)).

**Parameters:**

- `localised_strings` Array[`LocalisedString`]

**Returns:**

- Array[`uint32`] *(optional)* - The unique IDs for the requested translations.

### get_infinity_inventory_filter

Gets the filter for this map editor infinity filters at the given index or `nil` if the filter index doesn't exist or is empty.

**Parameters:**

- `index` `uint32` - The index to get.

**Returns:**

- `InfinityInventoryFilter` *(optional)*

### set_infinity_inventory_filter

Sets the filter for this map editor infinity filters at the given index.

**Parameters:**

- `index` `uint32` - The index to set.
- `filter` `InfinityInventoryFilter` | `nil` - The new filter or `nil` to clear the filter.

### clear_recipe_notifications

Clears all recipe notifications for this player.

### add_recipe_notification

Adds the given recipe to the list of recipe notifications for this player.

**Parameters:**

- `recipe` `RecipeID` - Recipe to add.

### clear_recipe_notification

Clears the given recipe from the list of recipe notifications for this player.

**Parameters:**

- `recipe` `RecipeID` - Recipe to clear.

### get_recipe_notifications

Get all recipes that currently have recipe notifications for this player.

**Returns:**

- Array[`LuaRecipePrototype`]

### add_to_clipboard

Adds the given blueprint to this player's clipboard queue.

**Parameters:**

- `blueprint` `LuaItemStack` - The blueprint to add.

### activate_paste

Gets a copy of the currently selected blueprint in the clipboard queue into the player's cursor, as if the player activated Paste.

### start_selection

Starts selection with selection tool from the specified position. Does nothing if the player's cursor is not a selection tool.

**Parameters:**

- `position` `MapPosition` - The position to start selection from.
- `selection_mode` `defines.selection_mode` - The type of selection to start.

### clear_selection

Clears the player's selection tool selection position.

### enter_space_platform

Enters the given space platform if possible.

**Parameters:**

- `space_platform` `LuaSpacePlatform`

**Returns:**

- `boolean` - If the player entered the platform.

### leave_space_platform

Ejects this player from the current space platform if in a platform. The player is left on the platform at the position of the hub.

### land_on_planet

Ejects this player from the current space platform and lands on the current planet.

**Returns:**

- `boolean` - If the player successfully landed on the planet.

### set_zoom_limits

Sets the zoom limits for a specific controller type. To reset a controller's zoom limits to default, pass an empty table for `zoom_limits`.

**Parameters:**

- `controller_type` `defines.controllers` - The type of the controller to set the zoom limits for.
- `zoom_limits` `ZoomLimits` - The new zoom limits. See [LuaPlayer::zoom_limits](runtime:LuaPlayer::zoom_limits) for usage information.

