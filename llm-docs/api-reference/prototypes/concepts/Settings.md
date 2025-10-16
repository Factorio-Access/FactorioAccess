# Settings

A struct that provides access to the user-set values of startup [mod settings](https://wiki.factorio.com/Tutorial:Mod_settings). It is accessible through the global object named `settings`.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### startup

All startup mod settings, indexed by the name of the setting.

**Type:** Dictionary[`string`, `ModSetting`]

**Required:** Yes

## Examples

```
```
-- Accessing the value of a mod setting
local val = settings.startup["my-mod-setting-name"].value
```
```

