# LuaFluidBoxPrototype

A prototype of a fluidbox owned by some [LuaEntityPrototype](runtime:LuaEntityPrototype).

## Attributes

### entity

**Type:** `LuaEntityPrototype` _(read-only)_

The entity that this belongs to.

### filter

**Type:** `LuaFluidPrototype` _(read-only)_

The filter, if any is set.

### index

**Type:** `uint` _(read-only)_

The index of this fluidbox prototype in the owning entity.

### maximum_temperature

**Type:** `double` _(read-only)_

The maximum temperature, if any is set.

### minimum_temperature

**Type:** `double` _(read-only)_

The minimum temperature, if any is set.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### pipe_connections

**Type:** ``PipeConnectionDefinition`[]` _(read-only)_

The pipe connection points.

### production_type

**Type:**  _(read-only)_

The production type.

### render_layer

**Type:** `string` _(read-only)_

The render layer.

### secondary_draw_orders

**Type:** ``int`[]` _(read-only)_

The secondary draw orders for the 4 possible connection directions.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

### volume

**Type:** `double` _(read-only)_



