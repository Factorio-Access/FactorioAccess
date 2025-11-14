# LuaEquipmentGrid

An equipment grid is for example the inside of a power armor.

## Attributes

### prototype

**Read type:** `LuaEquipmentGridPrototype`

### width

Width of the equipment grid.

**Read type:** `uint32`

### height

Height of the equipment grid.

**Read type:** `uint32`

### equipment

All the equipment in this grid.

**Read type:** Array[`LuaEquipment`]

### max_solar_energy

Maximum energy per tick that can be created by all solar panels in the equipment grid on the current surface. Actual generated energy varies depending on the daylight levels.

**Read type:** `double`

### available_in_batteries

The total energy stored in all batteries in the equipment grid.

**Read type:** `double`

### battery_capacity

Total energy storage capacity of all batteries in the equipment grid.

**Read type:** `double`

### shield

The amount of shield hitpoints this equipment grid currently has across all shield equipment.

**Read type:** `float`

### max_shield

The maximum amount of shield hitpoints this equipment grid has across all shield equipment.

**Read type:** `float`

### inventory_bonus

The total amount of inventory bonus this equipment grid gives.

**Read type:** `uint32`

### movement_bonus

The total amount of movement bonus this equipment grid gives.

Returns `0` if [LuaEquipmentGrid::inhibit_movement_bonus](runtime:LuaEquipmentGrid::inhibit_movement_bonus) is `true`.

**Read type:** `double`

### inhibit_movement_bonus

Whether this grid's equipment movement bonus is active.

**Read type:** `boolean`

**Write type:** `boolean`

### unique_id

Unique identifier of this equipment grid.

**Read type:** `uint32`

### entity_owner

The entity that this equipment grid is owned by (in some inventory or item stack.)

If the owning entity is a character owned by some player and the player is disconnected this will return `nil`.

**Read type:** `LuaEntity`

**Optional:** Yes

### player_owner

The player that this equipment grid is owned by (in some inventory or item stack.)

**Read type:** `LuaPlayer`

**Optional:** Yes

### itemstack_owner

The item stack that this equipment grid is owned by.

**Read type:** `LuaItemStack`

**Optional:** Yes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### take

Remove an equipment from the grid.

**Parameters:**

- `position` `EquipmentPosition` *(optional)* - Take the equipment that contains this position in the grid.
- `equipment` `LuaEquipment` *(optional)* - Take this exact equipment.
- `by_player` `PlayerIdentification` *(optional)* - If provided the action is done 'as' this player and [on_player_removed_equipment](runtime:on_player_removed_equipment) is triggered.

**Returns:**

- `ItemWithQualityCount` *(optional)* - The removed equipment, or `nil` if no equipment was removed.

### take_all

Remove all equipment from the grid.

**Parameters:**

- `by_player` `PlayerIdentification` *(optional)* - If provided, the action is done 'as' this player and [on_player_removed_equipment](runtime:on_player_removed_equipment) is triggered.

**Returns:**

- `ItemWithQualityCounts` - List of the equipment that has been removed.

### clear

Clear all equipment from the grid, removing it without actually returning it.

**Parameters:**

- `by_player` `PlayerIdentification` *(optional)* - If provided, the action is done 'as' this player and [on_player_removed_equipment](runtime:on_player_removed_equipment) is triggered.

### put

Insert an equipment into the grid.

**Parameters:**

- `name` `EquipmentID` - Equipment prototype name
- `quality` `QualityID` *(optional)* - The quality, `nil` for any or if not provided `normal` is used.
- `position` `EquipmentPosition` *(optional)* - Grid position to put the equipment in.
- `by_player` `PlayerIdentification` *(optional)* - If provided the action is done 'as' this player and [on_player_placed_equipment](runtime:on_player_placed_equipment) is triggered.
- `ghost` `boolean` *(optional)* - If true, place the equipment as a ghost.

**Returns:**

- `LuaEquipment` *(optional)* - The newly-added equipment, or `nil` if the equipment could not be added.

### can_move

Check whether moving an equipment would succeed.

**Parameters:**

- `equipment` `LuaEquipment` - The equipment to move
- `position` `EquipmentPosition` - Where to put it

**Returns:**

- `boolean`

### move

Move an equipment within this grid.

**Parameters:**

- `equipment` `LuaEquipment` - The equipment to move
- `position` `EquipmentPosition` - Where to put it

**Returns:**

- `boolean` - `true` if the equipment was successfully moved.

### get

Find equipment in the Equipment Grid colliding with this position.

**Parameters:**

- `position` `EquipmentPosition` - The position

**Returns:**

- `LuaEquipment` *(optional)* - The found equipment, or `nil` if equipment occupying the given position could not be found.

### get_contents

Get counts of all equipment in this grid.

**Returns:**

- Array[`EquipmentWithQualityCounts`] - List of all equipment in the grid.

### get_generator_energy

Total energy per tick generated by the equipment inside this grid.

**Parameters:**

- `quality` `QualityID` *(optional)* - Defaults to `"normal"`.

**Returns:**

- `double`

### find

Find equipment by name.

**Parameters:**

- `equipment` `EquipmentWithQualityID` - Prototype of the equipment to find.
- `search_ghosts` `boolean` *(optional)* - If ghosts inner equipment should be searched. Defaults to `false`

**Returns:**

- `LuaEquipment` *(optional)* - The first found equipment, or `nil` if equipment could not be found.

### count

Get the number of all or some equipment in this grid.

**Parameters:**

- `equipment` `EquipmentWithQualityID` *(optional)* - The equipment to count. If not specified, count all equipment.

**Returns:**

- `uint32`

### revive

Revives the given equipment ghost if possible.

**Parameters:**

- `equipment` `LuaEquipment` - The equipment ghost to revive.

**Returns:**

- `LuaEquipment`

### order_removal

Marks the given equipment for removal. If the given equipment is a ghost it is removed.

**Parameters:**

- `equipment` `LuaEquipment`

**Returns:**

- `boolean` - If the equipment was successfully marked for removal (or in the case of a ghost; removed.)

### cancel_removal

Cancels removal for the given equipment.

**Parameters:**

- `equipment` `LuaEquipment`

**Returns:**

- `boolean` - If the equipment removal was successfully cancelled.

