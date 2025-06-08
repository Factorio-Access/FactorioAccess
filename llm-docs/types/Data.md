# Data

The data table is read by the game to load all prototypes.

At the end of the prototype stage, the data table is loaded by the game engine and the format of the prototypes is validated. Any extra properties are ignored. See [Data Lifecycle](runtime:data-lifecycle) for more information.

The data table and its properties are defined in Lua, so their source code can be viewed in [dataloader.lua](https://github.com/wube/factorio-data/blob/master/core/lualib/dataloader.lua).

