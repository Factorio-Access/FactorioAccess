# SurfacePrototype

**Parent:** [Prototype](Prototype.md)
**Type name:** `surface`

## Properties

### surface_properties

**Type:** Dictionary[`SurfacePropertyID`, `double`]

**Optional:** Yes

### icon

Path to the icon file.

Only loaded, and mandatory if `icons` is not defined.

**Type:** `FileName`

**Optional:** Yes

### icon_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

