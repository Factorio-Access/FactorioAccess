# LuaParticlePrototype

Prototype of an optimized particle.

**Parent:** `LuaPrototypeBase`

## Attributes

### ended_in_water_trigger_effect

**Type:** `TriggerEffectItem` _(read-only)_



### ended_on_ground_trigger_effect

**Type:** `TriggerEffectItem` _(read-only)_



### fade_out_time

**Type:** `uint` _(read-only)_



### life_time

**Type:** `uint` _(read-only)_



### mining_particle_frame_speed

**Type:** `float` _(read-only)_



### movement_modifier

**Type:** `float` _(read-only)_



### movement_modifier_when_on_ground

**Type:** `float` _(read-only)_



### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### regular_trigger_effect

**Type:** `TriggerEffectItem` _(read-only)_



### regular_trigger_effect_frequency

**Type:** `uint` _(read-only)_



### render_layer

**Type:** `RenderLayer` _(read-only)_



### render_layer_when_on_ground

**Type:** `RenderLayer` _(read-only)_



### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

### vertical_acceleration

**Type:** `float` _(read-only)_



