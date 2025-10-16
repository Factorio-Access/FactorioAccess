# ScriptedTechnologyTrigger

Triggered only by calling [LuaForce::script_trigger_research](runtime:LuaForce::script_trigger_research). Can be used to show custom scripted triggers in the technology GUI.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### type

**Type:** `"scripted"`

**Required:** Yes

### trigger_description

**Type:** `LocalisedString`

**Optional:** Yes

### icons

Can't be an empty array.

**Type:** Array[`IconData`]

**Optional:** Yes

### icon

Path to the icon file.

Only loaded if `icons` is not defined.

**Type:** `FileName`

**Optional:** Yes

### icon_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

