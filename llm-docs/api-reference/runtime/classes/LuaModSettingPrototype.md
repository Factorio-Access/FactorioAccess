# LuaModSettingPrototype

Prototype of a mod setting.

**Parent:** [LuaPrototypeBase](LuaPrototypeBase.md)

## Attributes

### mod

The mod that owns this setting.

**Read type:** `string`

### setting_type

**Read type:** `"startup"` | `"runtime-global"` | `"runtime-per-user"`

### default_value

The default value of this setting.

**Read type:** `boolean` | `double` | `int32` | `string` | `Color`

### minimum_value

The minimum value for this setting. `nil` if this setting type doesn't support a minimum.

**Read type:** `double` | `int32`

**Optional:** Yes

### maximum_value

The maximum value for this setting. `nil` if this setting type doesn't support a maximum.

**Read type:** `double` | `int32`

**Optional:** Yes

### allowed_values

The allowed values for this setting. `nil` if this setting doesn't use the a fixed set of values.

**Read type:** Array[`string`] | Array[`int32`] | Array[`double`]

**Optional:** Yes

### allow_blank

Whether this string setting allows blank values. `nil` if not a string setting.

**Read type:** `boolean`

**Optional:** Yes

### auto_trim

Whether this string setting auto-trims values. `nil` if not a string setting

**Read type:** `boolean`

**Optional:** Yes

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

