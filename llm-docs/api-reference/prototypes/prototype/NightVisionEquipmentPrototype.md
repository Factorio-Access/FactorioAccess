# NightVisionEquipmentPrototype

Used by [nightvision](https://wiki.factorio.com/Nightvision).

**Parent:** [EquipmentPrototype](EquipmentPrototype.md)
**Type name:** `night-vision-equipment`

## Properties

### energy_input

**Type:** `Energy`

**Required:** Yes

### color_lookup

**Type:** `DaytimeColorLookupTable`

**Required:** Yes

### darkness_to_turn_on

Must be >= 0 and <= 1. By default, this equipment turns on when `surface_darkness >= darkness_to_turn_on`.

**Type:** `float`

**Optional:** Yes

**Default:** 0.5

### sunglasses

If `true`, this equipment turns on when `surface_darkness <= darkness_to_turn_on`.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### activate_sound

**Type:** `Sound`

**Optional:** Yes

### deactivate_sound

**Type:** `Sound`

**Optional:** Yes

