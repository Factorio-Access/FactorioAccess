# LuaSettings

Object containing mod settings of three distinct types: `startup`, `global`, and `player`. An instance of LuaSettings is available through the global object named `settings`.

## Attributes

### startup

The startup mod settings, indexed by prototype name.

**Read type:** LuaCustomTable[`string`, `ModSetting`]

### global

The current global mod settings, indexed by prototype name.

Even though this attribute is marked as read-only, individual settings can be changed by overwriting their [ModSetting](runtime:ModSetting) table. Mods can only change their own settings. Using the in-game console, all player settings can be changed.

**Read type:** LuaCustomTable[`string`, `ModSetting`]

### player_default

The **default** player mod settings for this map, indexed by prototype name. Changing these settings only affects the default settings for future players joining the game.

Individual settings can be changed by overwriting their [ModSetting](runtime:ModSetting) table. Mods can only change their own settings. Using the in-game console, all player settings can be changed.

**Read type:** LuaCustomTable[`string`, `ModSetting`]

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### get_player_settings

Gets the current per-player settings for the given player, indexed by prototype name. Returns the same structure as [LuaPlayer::mod_settings](runtime:LuaPlayer::mod_settings). This table becomes invalid if its associated player does.

Even though this attribute is a getter, individual settings can be changed by overwriting their [ModSetting](runtime:ModSetting) table. Mods can only change their own settings. Using the in-game console, all player settings can be changed.

**Parameters:**

- `player` `PlayerIdentification`

**Returns:**

- LuaCustomTable[`string`, `ModSetting`]

**Examples:**

```
-- Change the value of the "active_lifestyle" setting
settings.get_player_settings(player_index)["active_lifestyle"] = {value = true}
```

