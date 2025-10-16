# BoilerPictures

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### structure

**Type:** `Animation`

**Required:** Yes

### patch

Drawn above the `structure`, in the "higher-object-under" [RenderLayer](prototype:RenderLayer). May be useful to correct problems with neighboring pipes overlapping the structure graphics.

**Type:** `Sprite`

**Optional:** Yes

### fire

Animation that is drawn on top of the `structure` when `burning_cooldown` is larger than 1. The animation alpha can be controlled by the energy source light intensity, depending on `fire_flicker_enabled`.

The secondary draw order of this is higher than the secondary draw order of `fire_glow`, so this is drawn above `fire_glow`.

**Type:** `Animation`

**Optional:** Yes

### fire_glow

Animation that is drawn on top of the `structure` when `burning_cooldown` is larger than 1. The animation alpha can be controlled by the energy source light intensity, depending on `fire_glow_flicker_enabled`.

The secondary draw order of this is lower than the secondary draw order of `fire`, so this is drawn below `fire`.

**Type:** `Animation`

**Optional:** Yes

