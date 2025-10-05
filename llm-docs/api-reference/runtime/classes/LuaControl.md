# LuaControl

This is an abstract base class containing the common functionality between [LuaPlayer](runtime:LuaPlayer) and entities (see [LuaEntity](runtime:LuaEntity)). When accessing player-related functions through a [LuaEntity](runtime:LuaEntity), it must refer to a character entity.

**Abstract:** Yes

## Attributes

### surface

The surface this entity is currently on.

**Read type:** `LuaSurface`

### surface_index

Unique [index](runtime:LuaSurface::index) (ID) associated with the surface this entity is currently on.

**Read type:** `uint32`

### position

The current position of the entity.

**Read type:** `MapPosition`

### render_position

The current render position of the entity.

**Read type:** `MapPosition`

### is_flying

If this player or character entity is flying.

When called on an entity, only valid if this entity is a character.

**Read type:** `boolean`

### flight_height

The current flight height for this player or character entity.

When called on an entity, only valid if this entity is a character.

**Read type:** `double`

### vehicle

The vehicle the player is currently sitting in.

**Read type:** `LuaEntity`

**Optional:** Yes

### cargo_pod

The cargo pod the player is currently sitting in or the cargo pod attached to this rocket silo.

**Read type:** `LuaEntity`

**Optional:** Yes

### hub

The space platform hub the player is currently sitting in.

**Read type:** `LuaEntity`

**Optional:** Yes

### force

The force of this entity. Reading will always give a [LuaForce](runtime:LuaForce), but it is possible to assign either [string](runtime:string), [uint8](runtime:uint8) or [LuaForce](runtime:LuaForce) to this attribute to change the force.

**Read type:** `LuaForce`

**Write type:** `ForceID`

### force_index

Unique [index](runtime:LuaForce::index) (ID) associated with the force of this entity.

**Read type:** `uint32`

### selected

The currently selected entity. Assigning an entity will select it if is selectable, otherwise the selection is cleared.

**Read type:** `LuaEntity`

**Write type:** `LuaEntity`

**Optional:** Yes

### opened

The GUI the player currently has open.

This is the GUI that will asked to close (by firing the [on_gui_closed](runtime:on_gui_closed) event) when the `Esc` or `E` keys are pressed. If this attribute is non-nil, then writing `nil` or a new GUI to it will ask the existing GUI to close.

Write supports any of the types. Read will return the `entity`, `equipment`, `equipment-grid`, `player`, `element`, `inventory`, `item` or `nil`.

**Read type:** `LuaEntity` | `LuaItemStack` | `LuaEquipment` | `LuaEquipmentGrid` | `LuaPlayer` | `LuaGuiElement` | `LuaInventory` | `LuaLogisticNetwork` | `LuaItemStack` | `defines.gui_type`

**Write type:** `LuaEntity` | `LuaItemStack` | `LuaEquipment` | `LuaEquipmentGrid` | `LuaPlayer` | `LuaGuiElement` | `LuaInventory` | `LuaLogisticNetwork` | `LuaItemStack` | `defines.gui_type`

**Optional:** Yes

### crafting_queue_size

Size of the crafting queue.

**Read type:** `uint32`

### crafting_queue_progress

The crafting queue progress in the range `[0-1]`. `0` when no recipe is being crafted.

**Read type:** `double`

**Write type:** `double`

### walking_state

Current walking state of the player, or the spider-vehicle the character is driving.

**Read type:** Table (see below for parameters)

**Write type:** Table (see below for parameters)

### riding_state

Current riding state of this car, or of the car this player is riding in.

**Read type:** `RidingState`

**Write type:** `RidingState`

### mining_state

Current mining state.

When the player isn't mining tiles the player will mine whatever entity is currently selected. See [LuaControl::selected](runtime:LuaControl::selected) and [LuaControl::update_selected_entity](runtime:LuaControl::update_selected_entity).

**Read type:** Table (see below for parameters)

**Write type:** Table (see below for parameters)

### shooting_state

Current shooting state.

**Read type:** Table (see below for parameters)

**Write type:** Table (see below for parameters)

### picking_state

Current item-picking state.

**Read type:** `boolean`

**Write type:** `boolean`

### repair_state

Current repair state.

**Read type:** Table (see below for parameters)

**Write type:** Table (see below for parameters)

### cursor_stack

The player's cursor stack. `nil` if the player controller is a spectator.

**Read type:** `LuaItemStack`

**Optional:** Yes

### cursor_ghost

The ghost prototype in the player's cursor.

Items in the cursor stack will take priority over the cursor ghost.

**Read type:** `ItemIDAndQualityIDPair`

**Write type:** `ItemWithQualityID`

**Optional:** Yes

### cursor_record

The blueprint record in the player's cursor.

**Read type:** `LuaRecord`

**Optional:** Yes

### driving

`true` if the player is in a vehicle. Writing to this attribute puts the player in or out of a vehicle.

**Read type:** `boolean`

**Write type:** `boolean`

### crafting_queue

The current crafting queue items.

**Read type:** Array[`CraftingQueueItem`]

### following_robots

The current combat robots following the character.

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

**Read type:** Array[`LuaEntity`]

### cheat_mode

When `true` hand crafting is free and instant.

**Read type:** `boolean`

**Write type:** `boolean`

### character_crafting_speed_modifier

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

**Read type:** `double`

**Write type:** `double`

### character_mining_speed_modifier

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

**Read type:** `double`

**Write type:** `double`

### character_additional_mining_categories

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

**Read type:** Array[`string`]

**Write type:** Array[`string`]

### character_running_speed_modifier

Modifies the running speed of this character by the given value as a percentage. Setting the running modifier to `0.5` makes the character run 50% faster. The minimum value of `-1` reduces the movement speed by 100%, resulting in a speed of `0`.

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

**Read type:** `double`

**Write type:** `double`

### character_build_distance_bonus

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

**Read type:** `uint32`

**Write type:** `uint32`

### character_item_drop_distance_bonus

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

**Read type:** `uint32`

**Write type:** `uint32`

### character_reach_distance_bonus

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

**Read type:** `uint32`

**Write type:** `uint32`

### character_resource_reach_distance_bonus

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

**Read type:** `uint32`

**Write type:** `uint32`

### character_item_pickup_distance_bonus

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

**Read type:** `uint32`

**Write type:** `uint32`

### character_loot_pickup_distance_bonus

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

**Read type:** `uint32`

**Write type:** `uint32`

### character_inventory_slots_bonus

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

**Read type:** `uint32`

**Write type:** `uint32`

### character_trash_slot_count_bonus

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

**Read type:** `uint32`

**Write type:** `uint32`

### character_maximum_following_robot_count_bonus

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

**Read type:** `uint32`

**Write type:** `uint32`

### character_health_bonus

When called on a [LuaPlayer](runtime:LuaPlayer), it must be associated with a character (see [LuaPlayer::character](runtime:LuaPlayer::character)).

**Read type:** `float`

**Write type:** `float`

### opened_gui_type

**Read type:** `defines.gui_type`

**Optional:** Yes

### build_distance

The build distance of this character or max uint when not a character or player connected to a character.

**Read type:** `uint32`

### drop_item_distance

The item drop distance of this character or max uint when not a character or player connected to a character.

**Read type:** `uint32`

### reach_distance

The reach distance of this character or max uint when not a character or player connected to a character.

**Read type:** `uint32`

### item_pickup_distance

The item pickup distance of this character or max double when not a character or player connected to a character.

**Read type:** `double`

### loot_pickup_distance

The loot pickup distance of this character or max double when not a character or player connected to a character.

**Read type:** `double`

### resource_reach_distance

The resource reach distance of this character or max double when not a character or player connected to a character.

**Read type:** `double`

### in_combat

Whether this character entity is in combat.

**Read type:** `boolean`

### character_running_speed

The current movement speed of this character, including effects from exoskeletons, tiles, stickers and shooting.

**Read type:** `double`

### character_mining_progress

The current mining progress between 0 and 1 of this character, or 0 if they aren't mining.

**Read type:** `double`

## Methods

### get_inventory

Get an inventory belonging to this entity. This can be either the "main" inventory or some auxiliary one, like the module slots or logistic trash slots.

A given [defines.inventory](runtime:defines.inventory) is only meaningful for the corresponding LuaObject type. EG: get_inventory(defines.inventory.character_main) is only meaningful if 'this' is a player character. You may get a value back but if the type of 'this' isn't the type referred to by the [defines.inventory](runtime:defines.inventory) it's almost guaranteed to not be the inventory asked for.

**Parameters:**

- `inventory` `defines.inventory`

**Returns:**

- `LuaInventory` *(optional)* - The inventory or `nil` if none with the given index was found.

### get_inventory_name

Get name of inventory. Names match keys of [defines.inventory](runtime:defines.inventory).

**Parameters:**

- `inventory` `defines.inventory`

**Returns:**

- `string` *(optional)*

### get_max_inventory_index

The highest index of all inventories this entity can use. Allows iteration over all of them if desired.

**Returns:**

- `defines.inventory`

**Examples:**

```
for k = 1, entity.get_max_inventory_index() do [...] end
```

### get_main_inventory

Gets the main inventory for this character or player if this is a character or player.

**Returns:**

- `LuaInventory` *(optional)* - The inventory or `nil` if this entity is not a character or player.

### can_insert

Can at least some items be inserted?

**Parameters:**

- `items` `ItemStackIdentification` - Items that would be inserted.

**Returns:**

- `boolean` - `true` if at least a part of the given items could be inserted into this inventory.

### insert

Insert items into this entity. This works the same way as inserters or shift-clicking: the "best" inventory is chosen automatically.

**Parameters:**

- `items` `ItemStackIdentification` - The items to insert.

**Returns:**

- `uint32` - The number of items that were actually inserted.

### set_gui_arrow

Create an arrow which points at this entity. This is used in the tutorial. For examples, see `control.lua` in the campaign missions.

**Parameters:**

- `margin` `uint32`
- `type` `GuiArrowType` - Where to point to. This field determines what other fields are mandatory.

### clear_gui_arrow

Removes the arrow created by `set_gui_arrow`.

### get_item_count

Get the number of all or some items in this entity.

**Parameters:**

- `item` `ItemFilter` *(optional)* - The item to count. If not specified, count all items.

**Returns:**

- `uint32`

### has_items_inside

Does this entity have any item inside it?

**Returns:**

- `boolean`

### can_reach_entity

Can a given entity be opened or accessed?

**Parameters:**

- `entity` `LuaEntity`

**Returns:**

- `boolean`

### clear_items_inside

Remove all items from this entity.

### remove_item

Remove items from this entity.

**Parameters:**

- `items` `ItemStackIdentification` - The items to remove.

**Returns:**

- `uint32` - The number of items that were actually removed.

### teleport

Teleport the entity to a given position, possibly on another surface.

Some entities may not be teleported. For instance, transport belts won't allow teleportation and this method will always return `false` when used on any such entity.

You can also pass 1 or 2 numbers as the parameters and they will be used as relative teleport coordinates `'teleport(0, 1)'` to move the entity 1 tile positive y. `'teleport(4)'` to move the entity 4 tiles to the positive x.

`script_raised_teleported` will not be raised if teleporting a player with no character.

**Parameters:**

- `build_check_type` `defines.build_check_type` *(optional)* - The build check type done when teleporting to the destination. Defaults to `script`. This is ignored when teleporting between surfaces.
- `position` `MapPosition` - Where to teleport to.
- `raise_teleported` `boolean` *(optional)* - If true, [defines.events.script_raised_teleported](runtime:defines.events.script_raised_teleported) will be fired on successful entity teleportation.
- `snap_to_grid` `boolean` *(optional)* - If false the exact position given is used to instead of snapping to the normal entity grid. This only applies if the entity normally snaps to the grid.
- `surface` `SurfaceIdentification` *(optional)* - Surface to teleport to. If not given, will teleport to the entity's current surface. Only players, cars, and spidertrons can be teleported cross-surface.

**Returns:**

- `boolean` - `true` if the entity was successfully teleported.

### update_selected_entity

Select an entity, as if by hovering the mouse above it.

**Parameters:**

- `position` `MapPosition` - Position of the entity to select.

### clear_selected_entity

Unselect any selected entity.

### disable_flashlight

Disable the flashlight.

Applied per controller. Only supported by [defines.controllers.character](runtime:defines.controllers.character) and [defines.controllers.remote](runtime:defines.controllers.remote).

### enable_flashlight

Enable the flashlight.

Applied per controller. Only supported by [defines.controllers.character](runtime:defines.controllers.character) and [defines.controllers.remote](runtime:defines.controllers.remote).

### is_flashlight_enabled

Is the flashlight enabled for the current controller. Only supported by [defines.controllers.character](runtime:defines.controllers.character) and [defines.controllers.remote](runtime:defines.controllers.remote).

**Returns:**

- `boolean`

### get_craftable_count

Gets the count of the given recipe that can be crafted.

**Parameters:**

- `recipe` `RecipeID` - The recipe.

**Returns:**

- `uint32` - The count that can be crafted.

### begin_crafting

Begins crafting the given count of the given recipe.

**Parameters:**

- `count` `uint32` - The count to craft.
- `recipe` `RecipeID` - The recipe to craft.
- `silent` `boolean` *(optional)* - If false and the recipe can't be crafted the requested number of times printing the failure is skipped.

**Returns:**

- `uint32` - The count that was actually started crafting.

### cancel_crafting

Cancels crafting the given count of the given crafting queue index.

**Parameters:**

- `count` `uint32` - The count to cancel crafting.
- `index` `uint32` - The crafting queue index.

### mine_entity

Mines the given entity as if this player (or character) mined it.

**Parameters:**

- `entity` `LuaEntity` - The entity to mine
- `force` `boolean` *(optional)* - Forces mining the entity even if the items can't fit in the player.

**Returns:**

- `boolean` - Whether the mining succeeded.

### mine_tile

Mines the given tile as if this player (or character) mined it.

**Parameters:**

- `tile` `LuaTile` - The tile to mine.

**Returns:**

- `boolean` - Whether the mining succeeded.

### is_player

When `true` control adapter is a LuaPlayer object, `false` for entities including characters with players.

**Returns:**

- `boolean`

### open_technology_gui

Open the technology GUI and select a given technology.

**Parameters:**

- `technology` `TechnologyID` *(optional)* - The technology to select after opening the GUI.

### open_factoriopedia_gui

Open the Factoriopedia GUI and select a given entry, if any valid ID is given.

**Parameters:**

- `prototype` `FactoriopediaID` *(optional)*

### close_factoriopedia_gui

Closes the Factoriopedia GUI if it's open.

### is_cursor_blueprint

Returns whether the player is holding a blueprint. This takes both blueprint items as well as blueprint records from the blueprint library into account.

Note that both this method refers to the currently selected blueprint, which means that a blueprint book with a selected blueprint will return the information as well.

**Returns:**

- `boolean`

### is_cursor_empty

Returns whether the player is holding something in the cursor. Takes into account items from the blueprint library, as well as items and ghost cursor.

**Returns:**

- `boolean`

### get_requester_point

Gets the requester logistic point for this entity if it has one.

**Returns:**

- `LuaLogisticPoint` *(optional)*

### set_driving

Sets if this character or player is driving. Returns if the player or character is still driving.

**Parameters:**

- `driving` `boolean` - True for enter-vehicle, false for leave.
- `force` `boolean` *(optional)* - If true, the player will be ejected and left at the position of the car if normal "leave" is not possible.

### can_place_entity

Checks if this character or player can build the given entity at the given location on the surface the character or player is on.

**Parameters:**

- `direction` `defines.direction` *(optional)* - Direction the entity would be facing. Defaults to `north`.
- `name` `EntityID` - Name of the entity that would be built.
- `position` `MapPosition` - Where the entity would be placed.

**Returns:**

- `boolean`

