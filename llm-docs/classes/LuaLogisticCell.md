# LuaLogisticCell

Logistic cell of a particular [LuaEntity](runtime:LuaEntity). A "Logistic Cell" is the given name for settings and properties used by what would normally be seen as a "Roboport". A logistic cell however doesn't have to be attached to the roboport entity (the character has one for the personal roboport).

## Methods

### is_in_construction_range

Is a given position within the construction range of this cell?

**Parameters:**

- `position` `MapPosition`: 

**Returns:**

- `boolean`: 

### is_in_logistic_range

Is a given position within the logistic range of this cell?

**Parameters:**

- `position` `MapPosition`: 

**Returns:**

- `boolean`: 

### is_neighbour_with

Are two cells neighbours?

**Parameters:**

- `other` `LuaLogisticCell`: 

**Returns:**

- `boolean`: 

## Attributes

### charge_approach_distance

**Type:** `float` _(read-only)_

Radius at which the robots hover when waiting to be charged.

### charging_robot_count

**Type:** `uint` _(read-only)_

Number of robots currently charging.

### charging_robots

**Type:** ``LuaEntity`[]` _(read-only)_

Robots currently being charged.

### construction_radius

**Type:** `float` _(read-only)_

Construction radius of this cell.

### logistic_network

**Type:** `LuaLogisticNetwork` _(read-only)_

The network that owns this cell, if any.

### logistic_radius

**Type:** `float` _(read-only)_

Logistic radius of this cell.

### logistics_connection_distance

**Type:** `float` _(read-only)_

Logistic connection distance of this cell.

### mobile

**Type:** `boolean` _(read-only)_

`true` if this is a mobile cell. In vanilla, only the logistic cell created by a character's personal roboport is mobile.

### neighbours

**Type:** ``LuaLogisticCell`[]` _(read-only)_

Neighbouring cells.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### owner

**Type:** `LuaEntity` _(read-only)_

This cell's owner.

### stationed_construction_robot_count

**Type:** `uint` _(read-only)_

Number of stationed construction robots in this cell.

### stationed_logistic_robot_count

**Type:** `uint` _(read-only)_

Number of stationed logistic robots in this cell.

### to_charge_robot_count

**Type:** `uint` _(read-only)_

Number of robots waiting to charge.

### to_charge_robots

**Type:** ``LuaEntity`[]` _(read-only)_

Robots waiting to charge.

### transmitting

**Type:** `boolean` _(read-only)_

`true` if this cell is active.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

