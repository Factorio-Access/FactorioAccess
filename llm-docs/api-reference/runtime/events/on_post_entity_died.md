# on_post_entity_died

Called after an entity dies.

## Event Data

### corpses

**Type:** Array[`LuaEntity`]

The corpses created by the entity dying if any.

### damage_type

**Type:** `LuaDamagePrototype` *(optional)*

The damage type if any.

### force

**Type:** `LuaForce` *(optional)*

The force that did the killing if any.

### ghost

**Type:** `LuaEntity` *(optional)*

The ghost created by the entity dying if any.

### name

**Type:** `defines.events`

Identifier of the event

### position

**Type:** `MapPosition`

Position where the entity died.

### prototype

**Type:** `LuaEntityPrototype`

The entity prototype of the entity that died.

### quality

**Type:** `LuaQualityPrototype`

The quality of the entity that died.

### surface_index

**Type:** `uint`

The surface the entity was on.

### tick

**Type:** `uint`

Tick the event was generated.

### unit_number

**Type:** `uint` *(optional)*

The unit number the entity had if any.

