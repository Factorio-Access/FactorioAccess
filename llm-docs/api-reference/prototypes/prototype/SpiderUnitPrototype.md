# SpiderUnitPrototype

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `spider-unit`

## Properties

### spider_engine

**Type:** `SpiderEngineSpecification`

**Required:** Yes

### height

The height of the spider affects the shooting height and the drawing of the graphics and lights.

**Type:** `float`

**Required:** Yes

### torso_bob_speed

Cannot be negative.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### torso_rotation_speed

The orientation of the torso of the spider affects the shooting direction and the drawing of the graphics and lights.

**Type:** `float`

**Optional:** Yes

**Default:** 1

### graphics_set

**Type:** `SpiderTorsoGraphicsSet`

**Optional:** Yes

### absorptions_to_join_attack

**Type:** Dictionary[`AirbornePollutantID`, `float`]

**Optional:** Yes

### spawning_time_modifier

**Type:** `double`

**Optional:** Yes

**Default:** 1

### radar_range

In chunks. The radius of how many chunks this spider unit charts around itself.

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### attack_parameters

**Type:** `AttackParameters`

**Required:** Yes

### dying_sound

**Type:** `Sound`

**Optional:** Yes

### warcry

A sound the spider unit makes when it sets out to attack.

**Type:** `Sound`

**Optional:** Yes

### vision_distance

Must be less than or equal to 100.

**Type:** `double`

**Required:** Yes

### distraction_cooldown

**Type:** `uint32`

**Required:** Yes

### min_pursue_time

**Type:** `uint32`

**Optional:** Yes

**Default:** 600

### max_pursue_distance

**Type:** `double`

**Optional:** Yes

**Default:** 50

### ai_settings

**Type:** `UnitAISettings`

**Optional:** Yes

