# Libraries and functions - Auxiliary Docs | Factorio

Factorio.com|Forums|Wiki|Mod Portal|API Docs[Prototype](../index-prototype.html)|[Runtime](../index-runtime.html)|Auxiliary

 Factorio Auxiliary DocsVersion 2.0.55 

[Home](../index-auxiliary.html) / [Libraries and functions](libraries.html)><

Libraries and functions
Factorio adds several functions and libraries to the Lua environment that cannot be found in standard [Lua 5.2.1](https://www.lua.org/manual/5.2/). Furthermore, it modifies several functions to be deterministic, notably `pairs()` and `math.random()`.
Libraries• serpent
Factorio provides the [serpent library](https://github.com/pkulchenko/serpent) as a global variable named `serpent` for all mods to use. Its purpose is to allow for easy printing of Lua tables (using `serpent.block()` for example), which can be useful when debugging. It can't pretty-print LuaObjects such as [LuaEntity](../classes/LuaEntity.html) however.

The serpent library was modified for determinism, e.g. comments are turned off by default to avoid returning table addresses. Furthermore, two options were added: `refcomment` (true/false/maxlevel) and `tablecomment` (true/false/maxlevel), which allow to separately control the self-reference and table value output of the `comment` option.
• string
The `string` library has the functions `pack`, `packsize` and `unpack` backported from [Lua 5.4.6](https://www.lua.org/manual/5.4/) for handling [binary structure format strings](https://www.lua.org/manual/5.4/manual.html#6.4.2).
New functions#### • log(LocalisedString) 

`log()` can print [LocalisedStrings](../concepts/LocalisedString.html) to the Factorio [log file](https://wiki.factorio.com/Log_file). This, in combination with the serpent library, makes debugging in the data stage easier because it allows the inspection of entire prototype tables. For example, printing all properties of the sulfur item prototype can be done like so: `log(serpent.block(data.raw["item"]["sulfur"]))`
#### • localised_print(LocalisedString) 

`localised_print()` allows printing [LocalisedString](../concepts/LocalisedString.html) to stdout without polluting the Factorio [log file](https://wiki.factorio.com/Log_file). This is primarily useful when communicating with external tools that launch Factorio as a child process.
#### • table_size(table) → uint 

Factorio provides the `table_size()` function as a simple way to determine the size of tables with non-continuous keys, as the standard `#` operator does not work correctly for these. The function is a C++ implementation of the following Lua code, which is faster than doing the same in Lua:

local function size(t)
  local count = 0
  for k,v in pairs(t) do
    count = count + 1
  end
  return count
end

Note that `table_size()` does not work correctly for [LuaCustomTable](../classes/LuaCustomTable.html), their size has to be determined with [LuaCustomTable::length_operator](../classes/LuaCustomTable.html#length_operator) instead.
Modified functions
Some modules that are part of standard Lua are not accessible in Factorio's Lua environment, mostly to ensure determinism. These inaccessible modules are: `loadfile()`, `dofile()`, `coroutine`, `io` and `os`. Factorio provides its own versions of `package` and `debug`.
• pairs() / next()
In standard Lua, the order of iteration when using `pairs()` is arbitrary. Because Factorio has to be deterministic, this was changed in Factorio's version of Lua. Factorio's iteration order when using `next()` (which `pairs()` uses for iteration) depends on the insertion order: Keys inserted first are iterated first.

Factorio however also guarantees that the first 1024 numbered keys are iterated from 1 to 1024, regardless of insertion order. This means that for common uses, `pairs()` does not have any drawbacks compared to `ipairs()`.
• require()
Due to the changes to `package`, the functionality of `require()` changes. When using absolute paths, the path starts at the mod root. Additionally, `..` is disabled as a path variable. This means that it is not possible to load arbitrary files from outside the mod directory.

Factorio does however provide two ways to load files from other mods:
The "lualib" directory of the core mod is included in the paths to be checked for files, so it is possible to require files directly from there, such as the "util" file by using `require("util")`.Furthermore, it is possible to require files from other mods by using `require("__mod-name__.file")`.

`require()` can not be used in the console, in event listeners or during a `remote.call()`. The function expects any file to end with the `.lua` extension.
• print()
`print()` outputs to stdout. For Factorio, this means that it does not end up in the log file, so it can only be read when starting Factorio from the command line. Because of this, it is often easier to use `log()` or [LuaGameScript::print](../classes/LuaGameScript.html#print) for debugging.
• math.random()
`math.random()` is reimplemented within Factorio to be deterministic, both in the data stage and during runtime.

In the data stage, it is seeded with a constant number. During runtime, it uses the map's global random generator which is seeded with the map seed. The map's global random generator is shared between all mods and the core game, which all affect the random number that is generated. If this behaviour is not desired, [LuaRandomGenerator](../classes/LuaRandomGenerator.html) can be used to create a random generator that is completely separate from the core game and other mods.

This method can't be used outside of events or during loading. Calling it with non-integer arguments will floor them instead of resulting in an error.
• math.randomseed()
Using `math.randomseed()` in Factorio has no effect on the random generator, the function does nothing. If custom seeding or re-seeding is desired, [LuaRandomGenerator](../classes/LuaRandomGenerator.html) can be used instead of `math.random()`.
• load()
`load()` will not load binary chunks; the `mode` argument has no effect.
• debug
In the `debug` module, only `debug.getinfo()` and `debug.traceback()` are available by default. For advanced debug use, access to the potentially unsafe functions in the rest of the standard Lua debug module can be re-enabled with a command line option.
• debug.getinfo()
`debug.getinfo()` supports an additional flag `p` which fills in `currentpc` with the index of the current instruction within the function at the given stack level, or `-1` for functions not on the call stack. All standard fields are also supported.
• Mathematical functions
All trigonometric, hyperbolic, exponential and logarithmic Lua functions have been replaced by custom implementations to ensure determinism across platforms. For standard uses, they behave equivalently.

Defines|<

## General Topics
[Data Lifecycle](data-lifecycle.html)[Storage](storage.html)[Migrations](migrations.html)Libraries[Prototype Inheritance Tree](prototype-tree.html)[Noise Expressions](noise-expressions.html)[Instrument Mode](instrument.html)[Item Weight](item-weight.html)
## JSON Docs
[Runtime JSON Format](json-docs-runtime.html)[Prototype JSON Format](json-docs-prototype.html)

[ Defines](../defines.html)[alert_type](../defines.html#defines.alert_type)[behavior_result](../defines.html#defines.behavior_result)[build_check_type](../defines.html#defines.build_check_type)[build_mode](../defines.html#defines.build_mode)[cargo_destination](../defines.html#defines.cargo_destination)[chain_signal_state](../defines.html#defines.chain_signal_state)[chunk_generated_status](../defines.html#defines.chunk_generated_status)[command](../defines.html#defines.command)[compound_command](../defines.html#defines.compound_command)[control_behavior](../defines.html#defines.control_behavior)[controllers](../defines.html#defines.controllers)[deconstruction_item](../defines.html#defines.deconstruction_item)[default_icon_size](../defines.html#defines.default_icon_size)[difficulty](../defines.html#defines.difficulty)[direction](../defines.html#defines.direction)[disconnect_reason](../defines.html#defines.disconnect_reason)[distraction](../defines.html#defines.distraction)[entity_status](../defines.html#defines.entity_status)[entity_status_diode](../defines.html#defines.entity_status_diode)[events](../defines.html#defines.events)[flow_precision_index](../defines.html#defines.flow_precision_index)[game_controller_interaction](../defines.html#defines.game_controller_interaction)[group_state](../defines.html#defines.group_state)[gui_type](../defines.html#defines.gui_type)[input_action](../defines.html#defines.input_action)[input_method](../defines.html#defines.input_method)[inventory](../defines.html#defines.inventory)[logistic_member_index](../defines.html#defines.logistic_member_index)[logistic_mode](../defines.html#defines.logistic_mode)[logistic_section_type](../defines.html#defines.logistic_section_type)[mouse_button_type](../defines.html#defines.mouse_button_type)[moving_state](../defines.html#defines.moving_state)[print_skip](../defines.html#defines.print_skip)[print_sound](../defines.html#defines.print_sound)[prototypes](../defines.html#defines.prototypes)[rail_connection_direction](../defines.html#defines.rail_connection_direction)[rail_direction](../defines.html#defines.rail_direction)[rail_layer](../defines.html#defines.rail_layer)[relative_gui_position](../defines.html#defines.relative_gui_position)[relative_gui_type](../defines.html#defines.relative_gui_type)[render_mode](../defines.html#defines.render_mode)[rich_text_setting](../defines.html#defines.rich_text_setting)[riding](../defines.html#defines.riding)[robot_order_type](../defines.html#defines.robot_order_type)[rocket_silo_status](../defines.html#defines.rocket_silo_status)[selection_mode](../defines.html#defines.selection_mode)[shooting](../defines.html#defines.shooting)[signal_state](../defines.html#defines.signal_state)[space_platform_state](../defines.html#defines.space_platform_state)[target_type](../defines.html#defines.target_type)[train_state](../defines.html#defines.train_state)[transport_line](../defines.html#defines.transport_line)[wire_connector_id](../defines.html#defines.wire_connector_id)[wire_origin](../defines.html#defines.wire_origin)[wire_type](../defines.html#defines.wire_type)

>|

 Copyright © Wube Software |[License](../license.html)|[Download](../static/archive.zip)|Feedback