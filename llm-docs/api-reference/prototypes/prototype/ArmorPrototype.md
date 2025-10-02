# ArmorPrototype

Armor to wear on your in-game [character](prototype:CharacterPrototype) for defense and buffs.

**Parent:** [ToolPrototype](ToolPrototype.md)
**Type name:** `armor`

## Properties

### equipment_grid

Name of the [EquipmentGridPrototype](prototype:EquipmentGridPrototype) that this armor has.

**Type:** `EquipmentGridID`

**Optional:** Yes

### resistances

What amount of damage the armor takes on what type of damage is incoming.

**Type:** Array[`Resistance`]

**Optional:** Yes

### inventory_size_bonus

By how many slots the inventory of the player is expanded when the armor is worn.

**Type:** `ItemStackIndex`

**Optional:** Yes

### provides_flight

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### collision_box

**Type:** `BoundingBox`

**Optional:** Yes

### drawing_box

**Type:** `BoundingBox`

**Optional:** Yes

### takeoff_sound

Only loaded if `provides_flight` is `true`.

**Type:** `Sound`

**Optional:** Yes

### flight_sound

Only loaded if `provides_flight` is `true`.

**Type:** `InterruptibleSound`

**Optional:** Yes

### landing_sound

Only loaded if `provides_flight` is `true`.

**Type:** `Sound`

**Optional:** Yes

### steps_sound

**Type:** `Sound`

**Optional:** Yes

### moving_sound

**Type:** `Sound`

**Optional:** Yes

