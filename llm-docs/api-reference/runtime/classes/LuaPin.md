# LuaPin

A pin owned by a player.

## Attributes

### index

The index of this pin (unique to this player).

Note that this index has no correlation to the position of the pin within [LuaPlayer::get_pins](runtime:LuaPlayer::get_pins)

**Read type:** `uint32`

### owner

The player that this pin belongs to.

**Read type:** `LuaPlayer`

### player

The player that this pin is bound to.

**Read type:** `LuaPlayer`

**Write type:** `LuaPlayer`

**Optional:** Yes

### targets

The targets of this pin - if any.

**Read type:** Array[`LuaEntity`]

**Write type:** Array[`LuaEntity`]

### surface_index

The surface index if this pin specifically binds to a surface and position.

If writing, and this pin was not bound to a specific surface and position, the default position of (0,0) is used.

**Read type:** `uint32`

**Write type:** `uint32`

**Optional:** Yes

### position

The position if this pin specifically binds to a surface and position.

If writing, and this pin was not bound to a specific surface and position, the default surface of nauvis is used.

**Read type:** `MapPosition`

**Write type:** `MapPosition`

**Optional:** Yes

### chart_tag

The custom chart tag - if this pin specifically binds to a chart tag.

The chart tag must be on the same force as the owning player.

**Read type:** `LuaCustomChartTag`

**Write type:** `LuaCustomChartTag`

**Optional:** Yes

### label

The label for this pin - if any. This will be an empty string if there is no label set.

**Read type:** `string`

**Write type:** `string`

### always_visible

**Read type:** `boolean`

**Write type:** `boolean`

### preview_distance

The radius (in tiles) that is shown in the tooltip for this pin.

**Read type:** `uint16`

**Write type:** `uint16`

### alert_type

The type of alert this pin is for (if configured to be about alerts).

**Read type:** `defines.alert_type`

**Write type:** `defines.alert_type`

**Optional:** Yes

### alert_positions

The alert positions if this pin is configured to show alert data.

**Read type:** Array[`MapPosition`]

**Write type:** Array[`MapPosition`]

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### destroy

Destroys this pin.

### get_pin_center

The center of this pin if it can be computed.

**Returns:**

- `MapPosition` *(optional)*

