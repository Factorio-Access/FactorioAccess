# CollisionMaskConnector

The base game provides common collision mask functions in a Lua file in the core [lualib](https://github.com/wube/factorio-data/blob/master/core/lualib/collision-mask-util.lua).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### layers

Every key in the dictionary is the name of one [layer](prototype:CollisionLayerPrototype) the object collides with. The value is meaningless and always `true`. An empty table means that no layers are set.

**Type:** Dictionary[`CollisionLayerID`, `True`]

**Required:** Yes

### not_colliding_with_itself

Any two entities that both have this option enabled on their prototype and have an identical collision mask layers list will not collide. Other collision mask options are not included in the identical layer list check. This does mean that two different prototypes with the same collision mask layers and this option enabled will not collide.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### consider_tile_transitions

Uses the prototypes position rather than its collision box when doing collision checks with tile prototypes. Allows the prototype to overlap colliding tiles up until its center point. This is only respected for character movement and cars driven by players.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### colliding_with_tiles_only

Any prototype with this collision option will only be checked for collision with other prototype's collision masks if they are a tile.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

## Examples

```
```
-- Most common collision mask of buildings:
collision_mask = {layers = {item = true, meltable = true, object = true, player = true, water_tile = true, is_object = true, is_lower_object = true}}
```
```

