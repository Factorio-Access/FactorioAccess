# LuaControl

This is an abstract base class containing the common functionality between [LuaPlayer](runtime:LuaPlayer) and entities (see [LuaEntity](runtime:LuaEntity)). When accessing player-related functions through a [LuaEntity](runtime:LuaEntity), it must refer to a character entity.

## Methods

### begin_crafting

Begins crafting the given count of the given recipe.

**Parameters:**

- `count` `uint`: The count to craft.
- `recipe` `RecipeID`: The recipe to craft.
- `silent` `boolean` _(optional)_: If false and the recipe can't be crafted the requested number of times printing the failure is skipped.

**Returns:**

- `uint`: The count that was actually started crafting.

### can_insert

Can at least some items be inserted?

**Parameters:**

- `items` `ItemStackIdentification`: Items that would be inserted.

**Returns:**

- `boolean`: `true` if at least a part of the given items could be inserted into this inventory.

### can_reach_entity

Can a given entity be opened or accessed?

**Parameters:**

- `entity` `LuaEntity`: 

**Returns:**

- `boolean`: 

### cancel_crafting

Cancels crafting the given count of the given crafting queue index.

**Parameters:**

- `count` `uint`: The count to cancel crafting.
- `index` `uint`: The crafting queue index.

### clear_gui_arrow

Removes the arrow created by `set_gui_arrow`.

### clear_items_inside

Remove all items from this entity.

### clear_selected_entity

Unselect any selected entity.

### close_factoriopedia_gui

Closes the Factoriopedia GUI if it's open.

### disable_flashlight

Disable the flashlight.

Applied per controller. Only supported by [defines.controllers.character](runtime:defines.controllers.character) and [defines.controllers.remote](runtime:defines.controllers.remote).

### enable_flashlight

Enable the flashlight.

Applied per controller. Only supported by [defines.controllers.character](runtime:defines.controllers.character) and [defines.controllers.remote](runtime:defines.controllers.remote).

### get_craftable_count

Gets the count of the given recipe that can be crafted.

**Parameters:**

- `recipe` `RecipeID`: The recipe.

**Returns:**

- `uint`: The count that can be crafted.

### get_inventory

Get an inventory belonging to this entity. This can be either the "main" inventory or some auxiliary one, like the module slots or logistic trash slots.

A given [defines.inventory](runtime:defines.inventory) is only meaningful for the corresponding LuaObject type. EG: get_inventory(defines.inventory.character_main) is only meaningful if 'this' is a player character. You may get a value back but if the type of 'this' isn't the type referred to by the [defines.inventory](runtime:defines.inventory) it's almost guaranteed to not be the inventory asked for.

**Parameters:**

- `inventory` `defines.inventory`: 

**Returns:**

- `LuaInventory`: The inventory or `nil` if none with the given index was found.

### get_inventory_name

Get name of inventory. Names match keys of [defines.inventory](runtime:defines.inventory).

**Parameters:**

- `inventory` `defines.inventory`: 

**Returns:**

- `string`: 

### get_item_count

Get the number of all or some items in this entity.

**Parameters:**

- `item` `ItemFilter` _(optional)_: The item to count. If not specified, count all items.

**Returns:**

- `uint`: 

### get_main_inventory

Gets the main inventory for this character or player if this is a character or player.

**Returns:**

- `LuaInventory`: The inventory or `nil` if this entity is not a character or player.

### get_max_inventory_index

The highest index of all inventories this entity can use. Allows iteration over all of them if desired.

**Returns:**

- `defines.inventory`: 

### get_requester_point

Gets the requester logistic point for this entity if it has one.

**Returns:**

- `LuaLogisticPoint`: 

### has_items_inside

Does this entity have any item inside it?

**Returns:**

- `boolean`: 

### insert

Insert items into this entity. This works the same way as inserters or shift-clicking: the "best" inventory is chosen automatically.

**Parameters:**

- `items` `ItemStackIdentification`: The items to insert.

**Returns:**

- `uint`: The number of items that were actually inserted.

### is_cursor_blueprint

Returns whether the player is holding a blueprint. This takes both blueprint items as well as blueprint records from the blueprint library into account.

Note that both this method refers to the currently selected blueprint, which means that a blueprint book with a selected blueprint will return the information as well.

**Returns:**

- `boolean`: 

### is_cursor_empty

Returns whether the player is holding something in the cursor. Takes into account items from the blueprint library, as well as items and ghost cursor.

**Returns:**

- `boolean`: 

### is_flashlight_enabled

Is the flashlight enabled for the current controller. Only supported by [defines.controllers.character](runtime:defines.controllers.character) and [defines.controllers.remote](runtime:defines.controllers.remote).

**Returns:**

- `boolean`: 

### is_player

When `true` control adapter is a LuaPlayer object, `false` for entities including characters with players.

**Returns:**

- `boolean`: 

### mine_entity

Mines the given entity as if this player (or character) mined it.

**Parameters:**

- `entity` `LuaEntity`: The entity to mine
- `force` `boolean` _(optional)_: Forces mining the entity even if the items can't fit in the player.

**Returns:**

- `boolean`: Whether the mining succeeded.

### mine_tile

Mines the given tile as if this player (or character) mined it.

**Parameters:**

- `tile` `LuaTile`: The tile to mine.

**Returns:**

- `boolean`: Whether the mining succeeded.

### open_factoriopedia_gui

Open the Factoriopedia GUI and select a given entry, if any valid ID is given.

**Parameters:**

- `prototype` `FactoriopediaID` _(optional)_: 

### open_technology_gui

Open the technology GUI and select a given technology.

**Parameters:**

- `technology` `TechnologyID` _(optional)_: The technology to select after opening the GUI.

### remove_item

Remove items from this entity.

**Parameters:**

- `items` `ItemStackIdentification`: The items to remove.

**Returns:**

- `uint`: The number of items that were actually removed.

### set_driving

Sets if this character or player is driving. Returns if the player or character is still driving.

**Parameters:**

- `driving` `boolean`: True for enter-vehicle, false for leave.
- `force` `boolean` _(optional)_: If true, the player will be ejected and left at the position of the car if normal "leave" is not possible.

### set_gui_arrow

Create an arrow which points at this entity. This is used in the tutorial. For examples, see `control.lua` in the campaign missions.

**Parameters:**

- `margin` `uint`: 
- `type` `GuiArrowType`: Where to point to. This field determines what other fields are mandatory.

### teleport

Teleport the entity to a given position, possibly on another surface.

Some entities may not be teleported. For instance, transport belts won't allow teleportation and this method will always return `false` when used on any such entity.

You can also pass 1 or 2 numbers as the parameters and they will be used as relative teleport coordinates `'teleport(0, 1)'` to move the entity 1 tile positive y. `'teleport(4)'` to move the entity 4 tiles to the positive x.

`script_raised_teleported` will not be raised if teleporting a player with no character.

**Parameters:**

- `build_check_type` `defines.build_check_type` _(optional)_: The build check type done when teleporting to the destination. Defaults to `script`. This is ignored when teleporting between surfaces.
- `position` `MapPosition`: Where to teleport to.
- `raise_teleported` `boolean` _(optional)_: If true, [defines.events.script_raised_teleported](runtime:defines.events.script_raised_teleported) will be fired on successful entity teleportation.
- `snap_to_grid` `boolean` _(optional)_: If false the exact position given is used to instead of snapping to the normal entity grid. This only applies if the entity normally snaps to the grid.
- `surface` `SurfaceIdentification` _(optional)_: Surface to teleport to. If not given, will teleport to the entity's current surface. Only players, cars, and spidertrons can be teleported cross-surface.

**Returns:**

- `boolean`: `true` if the entity was successfully teleported.

### update_selected_entity

Select an entity, as if by hovering the mouse above it.

**Parameters:**

- `position` `MapPosition`: Position of the entity to select.

## Attributes

### build_distance

**Type:** `uint` _(read-only)_

The build distance of this character or max uint when not a character or player connected to a character.

### cargo_pod

**Type:** `LuaEntity` _(read-only)_

The cargo pod the player is currently sitting in or the cargo pod attached to this rocket silo.

### character_additional_mining_categories

**Type:** ``string`[]`

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

### character_build_distance_bonus

**Type:** `uint`

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

### character_crafting_speed_modifier

**Type:** `double`

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

### character_health_bonus

**Type:** `float`

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

### character_inventory_slots_bonus

**Type:** `uint`

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

### character_item_drop_distance_bonus

**Type:** `uint`

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

### character_item_pickup_distance_bonus

**Type:** `uint`

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

### character_loot_pickup_distance_bonus

**Type:** `uint`

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

### character_maximum_following_robot_count_bonus

**Type:** `uint`

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

### character_mining_progress

**Type:** `double` _(read-only)_

The current mining progress between 0 and 1 of this character, or 0 if they aren't mining.

### character_mining_speed_modifier

**Type:** `double`

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

### character_reach_distance_bonus

**Type:** `uint`

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

### character_resource_reach_distance_bonus

**Type:** `uint`

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

### character_running_speed

**Type:** `double` _(read-only)_

The current movement speed of this character, including effects from exoskeletons, tiles, stickers and shooting.

### character_running_speed_modifier

**Type:** `double`

Modifies the running speed of this character by the given value as a percentage. Setting the running modifier to `0.5` makes the character run 50% faster. The minimum value of `-1` reduces the movement speed by 100%, resulting in a speed of `0`.

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

### character_trash_slot_count_bonus

**Type:** `uint`

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

### cheat_mode

**Type:** `boolean`

When `true` hand crafting is free and instant.

### crafting_queue

**Type:** ``CraftingQueueItem`[]` _(read-only)_

The current crafting queue items.

### crafting_queue_progress

**Type:** `double`

The crafting queue progress in the range `[0-1]`. `0` when no recipe is being crafted.

### crafting_queue_size

**Type:** `uint` _(read-only)_

Size of the crafting queue.

### cursor_ghost

**Type:** `ItemIDAndQualityIDPair`

The ghost prototype in the player's cursor.

Items in the cursor stack will take priority over the cursor ghost.

### cursor_record

**Type:** `LuaRecord` _(read-only)_

The blueprint record in the player's cursor.

### cursor_stack

**Type:** `LuaItemStack` _(read-only)_

The player's cursor stack. `nil` if the player controller is a spectator.

### driving

**Type:** `boolean`

`true` if the player is in a vehicle. Writing to this attribute puts the player in or out of a vehicle.

### drop_item_distance

**Type:** `uint` _(read-only)_

The item drop distance of this character or max uint when not a character or player connected to a character.

### following_robots

**Type:** ``LuaEntity`[]` _(read-only)_

The current combat robots following the character.

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

### force

**Type:** `LuaForce`

The force of this entity. Reading will always give a [LuaForce](runtime:LuaForce), but it is possible to assign either [string](runtime:string), [uint8](runtime:uint8) or [LuaForce](runtime:LuaForce) to this attribute to change the force.

### force_index

**Type:** `uint` _(read-only)_

Unique [index](runtime:LuaForce::index) (ID) associated with the force of this entity.

### hub

**Type:** `LuaEntity` _(read-only)_

The space platform hub the player is currently sitting in.

### in_combat

**Type:** `boolean` _(read-only)_

Whether this character entity is in combat.

### item_pickup_distance

**Type:** `double` _(read-only)_

The item pickup distance of this character or max double when not a character or player connected to a character.

### loot_pickup_distance

**Type:** `double` _(read-only)_

The loot pickup distance of this character or max double when not a character or player connected to a character.

### mining_state

**Type:** `unknown`

Current mining state.

When the player isn't mining tiles the player will mine whatever entity is currently selected. See [LuaControl::selected](runtime:LuaControl::selected) and [LuaControl::update_selected_entity](runtime:LuaControl::update_selected_entity).

### opened

**Type:** 

The GUI the player currently has open.

This is the GUI that will asked to close (by firing the [on_gui_closed](runtime:on_gui_closed) event) when the `Esc` or `E` keys are pressed. If this attribute is non-nil, then writing `nil` or a new GUI to it will ask the existing GUI to close.

Write supports any of the types. Read will return the `entity`, `equipment`, `equipment-grid`, `player`, `element`, `inventory`, `item` or `nil`.

### opened_gui_type

**Type:** `defines.gui_type` _(read-only)_



### picking_state

**Type:** `boolean`

Current item-picking state.

### position

**Type:** `MapPosition` _(read-only)_

The current position of the entity.

### reach_distance

**Type:** `uint` _(read-only)_

The reach distance of this character or max uint when not a character or player connected to a character.

### repair_state

**Type:** `unknown`

Current repair state.

### resource_reach_distance

**Type:** `double` _(read-only)_

The resource reach distance of this character or max double when not a character or player connected to a character.

### riding_state

**Type:** `RidingState`

Current riding state of this car, or of the car this player is riding in.

### selected

**Type:** `LuaEntity`

The currently selected entity. Assigning an entity will select it if is selectable, otherwise the selection is cleared.

### shooting_state

**Type:** `unknown`

Current shooting state.

### surface

**Type:** `LuaSurface` _(read-only)_

The surface this entity is currently on.

### surface_index

**Type:** `uint` _(read-only)_

Unique [index](runtime:LuaSurface::index) (ID) associated with the surface this entity is currently on.

### vehicle

**Type:** `LuaEntity` _(read-only)_

The vehicle the player is currently sitting in.

### walking_state

**Type:** `unknown`

Current walking state of the player, or the spider-vehicle the character is driving.

