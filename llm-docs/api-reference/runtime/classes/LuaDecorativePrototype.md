# LuaDecorativePrototype

Prototype of an optimized decorative.

**Parent:** [LuaPrototypeBase](LuaPrototypeBase.md)

## Attributes

### collision_box

The bounding box used for collision checking.

**Read type:** `BoundingBox`

### collision_mask

The collision masks this decorative uses

**Read type:** `CollisionMask`

### autoplace_specification

Autoplace specification for this decorative prototype, if any.

**Read type:** `AutoplaceSpecification`

**Optional:** Yes

### render_layer

**Read type:** `RenderLayer`

### decal

**Read type:** `boolean`

### grows_through_rail_path

**Read type:** `boolean`

### trigger_effect

**Read type:** Array[`TriggerEffectItem`]

**Optional:** Yes

### placed_effect

**Read type:** Array[`TriggerEffectItem`]

**Optional:** Yes

### minimal_separation

**Read type:** `double`

### target_count

**Read type:** `uint`

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

