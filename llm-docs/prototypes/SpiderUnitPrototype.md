# SpiderUnitPrototype



**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### attack_parameters

**Type:** `AttackParameters`



#### distraction_cooldown

**Type:** `uint32`



#### height

**Type:** `float`

The height of the spider affects the shooting height and the drawing of the graphics and lights.

#### spider_engine

**Type:** `SpiderEngineSpecification`



#### vision_distance

**Type:** `double`

Must be less than or equal to 100.

### Optional Properties

#### absorptions_to_join_attack

**Type:** `dictionary<`AirbornePollutantID`, `float`>`



#### ai_settings

**Type:** `UnitAISettings`



#### dying_sound

**Type:** `Sound`



#### graphics_set

**Type:** `SpiderTorsoGraphicsSet`



#### max_pursue_distance

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 50}`

#### min_pursue_time

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 600}`

#### radar_range

**Type:** `uint32`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### spawning_time_modifier

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### torso_bob_speed

**Type:** `float`

Cannot be negative.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### torso_rotation_speed

**Type:** `float`

The orientation of the torso of the spider affects the shooting direction and the drawing of the graphics and lights.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### warcry

**Type:** `Sound`

A sound the spider unit makes when it sets out to attack.

