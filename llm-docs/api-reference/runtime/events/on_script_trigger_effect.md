# on_script_trigger_effect

Called when a script trigger effect is triggered.

## Event Data

### cause_entity

**Type:** `LuaEntity` *(optional)*

The entity that originally caused the sequence of triggers

### effect_id

**Type:** `string`

The effect_id specified in the trigger effect.

### name

**Type:** `defines.events`

Identifier of the event

### quality

**Type:** `string` *(optional)*

### source_entity

**Type:** `LuaEntity` *(optional)*

### source_position

**Type:** `MapPosition` *(optional)*

### surface_index

**Type:** `uint`

The surface the effect happened on.

### target_entity

**Type:** `LuaEntity` *(optional)*

### target_position

**Type:** `MapPosition` *(optional)*

### tick

**Type:** `uint`

Tick the event was generated.

