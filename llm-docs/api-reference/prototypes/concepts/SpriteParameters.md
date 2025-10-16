# SpriteParameters

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### priority

**Type:** `SpritePriority`

**Optional:** Yes

**Default:** "medium"

### flags

**Type:** `SpriteFlags`

**Optional:** Yes

### shift

The shift in tiles. `util.by_pixel()` can be used to divide the shift by 32 which is the usual pixel height/width of 1 tile in normal resolution. Note that 32 pixel tile height/width is not enforced anywhere - any other tile height or width is also possible.

**Type:** `Vector`

**Optional:** Yes

**Default:** "`{0, 0}`"

### rotate_shift

Whether to rotate the `shift` alongside the sprite's rotation. This only applies to sprites which are procedurally rotated by the game engine (like projectiles, wires, inserter hands, etc).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### apply_special_effect

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### scale

Values other than `1` specify the scale of the sprite on default zoom. A scale of `2` means that the picture will be two times bigger on screen (and thus more pixelated).

**Type:** `double`

**Optional:** Yes

**Default:** 1

### draw_as_shadow

Only one of `draw_as_shadow`, `draw_as_glow` and `draw_as_light` can be true. This takes precedence over `draw_as_glow` and `draw_as_light`.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### draw_as_glow

Only one of `draw_as_shadow`, `draw_as_glow` and `draw_as_light` can be true. This takes precedence over `draw_as_light`.

Draws first as a normal sprite, then again as a light layer. See [https://forums.factorio.com/91682](https://forums.factorio.com/91682).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### draw_as_light

Only one of `draw_as_shadow`, `draw_as_glow` and `draw_as_light` can be true.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### occludes_light

Loaded only if `draw_as_shadow`, `draw_as_glow` and `draw_as_light` are `false`, and only by sprites used by tile renderer (decals and underwater patches). The purpose of setting this to `false` is to preserve water mask from sprites that are supposed to be drawn under the water.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### mipmap_count

Only loaded if this is an icon, that is it has the flag `"group=icon"` or `"group=gui"`. Will be clamped to range `[0, 5]`.

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### apply_runtime_tint

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### tint_as_overlay

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### invert_colors

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### tint

**Type:** `Color`

**Optional:** Yes

**Default:** "`{r=1, g=1, b=1, a=1}`"

### blend_mode

**Type:** `BlendMode`

**Optional:** Yes

**Default:** "normal"

### generate_sdf

This property is only used by sprites used in [UtilitySprites](prototype:UtilitySprites) that have the `"icon"` flag set.

If this is set to `true`, the game will generate an icon shadow (using signed distance fields) for the sprite.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### surface

Provides hint to sprite atlas system, so it can try to put sprites that are intended to be used at the same locations to the same sprite atlas.

**Type:** `SpriteUsageSurfaceHint`

**Optional:** Yes

**Default:** "any"

### usage

Provides hint to sprite atlas system, so it can pack sprites that are related to each other to the same sprite atlas.

**Type:** `SpriteUsageHint`

**Optional:** Yes

**Default:** "any"

