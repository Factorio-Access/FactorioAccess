# CollisionMask

**Type:** Table

## Parameters

### colliding_with_tiles_only

Any prototype with this collision option will only be checked for collision with other prototype's collision masks if they are a tile. Defaults to `false`.

**Type:** `boolean`

**Optional:** Yes

### consider_tile_transitions

Uses the prototypes position rather than its collision box when doing collision checks with tile prototypes. Allows the prototype to overlap colliding tiles up until its center point. This is only respected for character movement and cars driven by players. Defaults to `false`.

**Type:** `boolean`

**Optional:** Yes

### layers

Every key in the dictionary is the name of one [layer](runtime:LuaCollisionLayerPrototype) the object collides with. The value is meaningless and always `true`. An empty table means that no layers are set.

**Type:** Dictionary[`string`, `True`]

**Required:** Yes

### not_colliding_with_itself

Any two entities that both have this option enabled on their prototype and have an identical collision mask layers list will not collide. Other collision mask options are not included in the identical layer list check. This does mean that two different prototypes with the same collision mask layers and this option enabled will not collide. Defaults to `false`.

**Type:** `boolean`

**Optional:** Yes

## Examples

```
```
-- Most common collision mask of buildings:
collision_mask = {layers = {item = true, meltable = true, object = true, player = true, water_tile = true, is_object = true, is_lower_object = true}}
```
```

