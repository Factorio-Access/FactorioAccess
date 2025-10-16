# LuaLogisticCell

Logistic cell of a particular [LuaEntity](runtime:LuaEntity). A "Logistic Cell" is the given name for settings and properties used by what would normally be seen as a "Roboport". A logistic cell however doesn't have to be attached to the roboport entity (the character has one for the personal roboport).

## Attributes

### logistic_radius

Logistic radius of this cell.

**Read type:** `float`

### logistics_connection_distance

Logistic connection distance of this cell.

**Read type:** `float`

### construction_radius

Construction radius of this cell.

**Read type:** `float`

### stationed_logistic_robot_count

Number of stationed logistic robots in this cell.

**Read type:** `uint32`

### stationed_construction_robot_count

Number of stationed construction robots in this cell.

**Read type:** `uint32`

### mobile

`true` if this is a mobile cell. The logistic cell created by roboport equipment considered is mobile.

**Read type:** `boolean`

### transmitting

`true` if this cell is active.

**Read type:** `boolean`

### charge_approach_distance

Radius at which the robots hover when waiting to be charged.

**Read type:** `float`

### charging_robot_count

Number of robots currently charging.

**Read type:** `uint32`

### to_charge_robot_count

Number of robots waiting to charge.

**Read type:** `uint32`

### owner

This cell's owner.

**Read type:** `LuaEntity`

### logistic_network

The network that owns this cell, if any.

**Read type:** `LuaLogisticNetwork`

**Optional:** Yes

### neighbours

Neighbouring cells.

**Read type:** Array[`LuaLogisticCell`]

### charging_robots

Robots currently being charged.

**Read type:** Array[`LuaEntity`]

### to_charge_robots

Robots waiting to charge.

**Read type:** Array[`LuaEntity`]

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### is_in_logistic_range

Is a given position within the logistic range of this cell?

**Parameters:**

- `position` `MapPosition`

**Returns:**

- `boolean`

### is_in_construction_range

Is a given position within the construction range of this cell?

**Parameters:**

- `position` `MapPosition`

**Returns:**

- `boolean`

### is_neighbour_with

Are two cells neighbours?

**Parameters:**

- `other` `LuaLogisticCell`

**Returns:**

- `boolean`

