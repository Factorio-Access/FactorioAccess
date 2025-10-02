# ZoomSpecification

A table specifying a fixed or dynamically-computed zoom level using one of the supported methods. Used by [ZoomLimits](runtime:ZoomLimits).

Method 1 only uses the `zoom` field. The zoom level is fixed and will not change at runtime. Directly correlates to the perceived size of objects in the game world.

Method 2 only uses `distance` and optionally `max_distance`. The zoom level is computed dynamically based on the player's window dimensions and aspect ratio. This method is ideal for limiting how far the player can see.

If there is ambiguity in which method should be used (i.e. both `zoom` and `distance` fields are provided), an error will be thrown during parsing.

**Type:** Table

## Parameters

### distance

The number of game tiles across the horizontal axis at the game's default 16:9 aspect ratio. Must be a positive number. This specification is designed to comfortably accommodate displays with extreme aspect ratios such as ultra-wide monitors. The exact zoom level is calculated dynamically as follows. For aspect ratios between 16:9 and 9:16, the zoom level is computed so that `distance` number of tiles are visible along the game window's longer axis. For aspect ratios between 16:9 and 1:1, this is the window's width. For aspect ratios between 1:1 and 9:16, this is the window's height. For aspect ratios greater than 16:9 or smaller than 9:16, then the zoom level is actually computed so that `distance * 9 / 16` number of tiles are visible along the game window's shorter axis. So for aspect ratios greater than 16:9, this is the window's height. For aspect ratios smaller than 9:16, this is the window's height. Mutually exclusive with `zoom`. Used with `max_distance`.

**Type:** `double`

**Optional:** Yes

### max_distance

The absolute maximum number of game tiles permitted along the window's longest axis, setting a hard limit on how far a player can see by simply manipulating the game window. Must be a positive number. Values greater than the default may allow players to see un-generated chunks while exploring. The "closest" zoom level calculated from `distance` and `max_distance` is always used. Optionally used with `distance`. Defaults to `500`.

**Type:** `double`

**Optional:** Yes

### zoom

A fixed zoom level. Must be a positive value. 1.0 is the default zoom level. Mutually exclusive with `distance`.

**Type:** `double`

**Optional:** Yes

## Examples

```
```
-- Method 1: Specify a fixed zoom level.
{ zoom = 3.0 }

-- Method 2: Specify a dynamic zoom level based on the window dimensions.
{ distance = 200, max_distance = 500 }
```
```

