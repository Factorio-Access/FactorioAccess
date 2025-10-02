# Data

The data table is read by the game to load all prototypes.

At the end of the prototype stage, the data table is loaded by the game engine and the format of the prototypes is validated. Any extra properties are ignored. See [Data Lifecycle](runtime:data-lifecycle) for more information.

The data table and its properties are defined in Lua, so their source code can be viewed in [dataloader.lua](https://github.com/wube/factorio-data/blob/master/core/lualib/dataloader.lua).

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### raw

A dictionary of prototype types to values that themselves are dictionaries of prototype names to specific prototypes.

This means that individual prototypes can be accessed with `local prototype = data.raw["prototype-type"]["internal-name"]`.

**Type:** Dictionary[`string`, Dictionary[`string`, `AnyPrototype`]]

**Required:** Yes

### extend

The primary way to add prototypes to the data table.

**Type:** `DataExtendMethod`

**Required:** Yes

### is_demo

Set by the game based on whether the demo or retail version is running. Should not be used by mods.

**Type:** `boolean`

**Required:** Yes

