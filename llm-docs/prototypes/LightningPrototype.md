# LightningPrototype



**Parent:** `EntityPrototype`

## Properties

### Mandatory Properties

#### effect_duration

**Type:** `uint16`



### Optional Properties

#### attracted_volume_modifier

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### damage

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 100}`

#### energy

**Type:** `Energy`



**Default:** `Max double`

#### graphics_set

**Type:** `LightningGraphicsSet`



#### sound

**Type:** `Sound`



#### source_offset

**Type:** `Vector`



#### source_variance

**Type:** `Vector`



#### strike_effect

**Type:** `Trigger`



#### time_to_damage

**Type:** `uint16`

Must be less than or equal to `effect_duration`.

**Default:** `{'complex_type': 'literal', 'value': 0}`

