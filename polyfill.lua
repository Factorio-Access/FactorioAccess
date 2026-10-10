---Polyfill for Factorio API when running outside the game engine
---This file provides defines and other global API constructs for standalone Lua execution
---When running in the game (script exists), this file does nothing

-- script is nil under plain Lua, outside Factorio
---@diagnostic disable-next-line: unnecessary-if
if script then return end

---@diagnostic disable: missing-fields
---@diagnostic disable: inject-field

-- intentionally global
-- We use rawset to avoid LuaLS seeing the assignment and overriding Factorio's type definitions
rawset(_G, "defines", rawget(_G, "defines") or {})

local dirdefs = {
   north = 0,
   northnortheast = 1,
   northeast = 2,
   eastnortheast = 3,
   east = 4,
   eastsoutheast = 5,
   southeast = 6,
   southsoutheast = 7,
   south = 8,
   southsouthwest = 9,
   southwest = 10,
   westsouthwest = 11,
   west = 12,
   westnorthwest = 13,
   northwest = 14,
   northnorthwest = 15,
}

rawset(defines, "direction", dirdefs)
