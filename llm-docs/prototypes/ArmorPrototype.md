# ArmorPrototype

Armor to wear on your in-game [character](prototype:CharacterPrototype) for defense and buffs.

**Parent:** `ToolPrototype`

## Properties

### Optional Properties

#### collision_box

**Type:** `BoundingBox`



#### drawing_box

**Type:** `BoundingBox`



#### equipment_grid

**Type:** `EquipmentGridID`

Name of the [EquipmentGridPrototype](prototype:EquipmentGridPrototype) that this armor has.

#### flight_sound

**Type:** `InterruptibleSound`

Only loaded if `provides_flight` is `true`.

#### inventory_size_bonus

**Type:** `ItemStackIndex`

By how many slots the inventory of the player is expanded when the armor is worn.

#### landing_sound

**Type:** `Sound`

Only loaded if `provides_flight` is `true`.

#### moving_sound

**Type:** `Sound`



#### provides_flight

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### resistances

**Type:** ``Resistance`[]`

What amount of damage the armor takes on what type of damage is incoming.

#### steps_sound

**Type:** `Sound`



#### takeoff_sound

**Type:** `Sound`

Only loaded if `provides_flight` is `true`.

