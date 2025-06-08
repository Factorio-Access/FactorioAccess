# LuaDecorativePrototype

Prototype of an optimized decorative.

**Parent:** `LuaPrototypeBase`

## Attributes

### autoplace_specification

**Type:** `AutoplaceSpecification` _(read-only)_

Autoplace specification for this decorative prototype, if any.

### collision_box

**Type:** `BoundingBox` _(read-only)_

The bounding box used for collision checking.

### collision_mask

**Type:** `CollisionMask` _(read-only)_

The collision masks this decorative uses

### decal

**Type:** `boolean` _(read-only)_



### grows_through_rail_path

**Type:** `boolean` _(read-only)_



### minimal_separation

**Type:** `double` _(read-only)_



### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### placed_effect

**Type:** ``TriggerEffectItem`[]` _(read-only)_



### render_layer

**Type:** `string` _(read-only)_



### target_count

**Type:** `uint` _(read-only)_



### trigger_effect

**Type:** ``TriggerEffectItem`[]` _(read-only)_



### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

