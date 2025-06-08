# LuaModSettingPrototype

Prototype of a mod setting.

**Parent:** `LuaPrototypeBase`

## Attributes

### allow_blank

**Type:** `boolean` _(read-only)_

Whether this string setting allows blank values. `nil` if not a string setting.

### allowed_values

**Type:**  _(read-only)_

The allowed values for this setting. `nil` if this setting doesn't use the a fixed set of values.

### auto_trim

**Type:** `boolean` _(read-only)_

Whether this string setting auto-trims values. `nil` if not a string setting

### default_value

**Type:**  _(read-only)_

The default value of this setting.

### maximum_value

**Type:**  _(read-only)_

The maximum value for this setting. `nil` if this setting type doesn't support a maximum.

### minimum_value

**Type:**  _(read-only)_

The minimum value for this setting. `nil` if this setting type doesn't support a minimum.

### mod

**Type:** `string` _(read-only)_

The mod that owns this setting.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### setting_type

**Type:**  _(read-only)_



### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

