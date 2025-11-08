---Polyfill for Factorio API when running outside the game engine
---This file provides defines and other global API constructs for standalone Lua execution
---When running in the game (script exists), this file does nothing

if script then return end

---@diagnostic disable: lowercase-global

-- intentionally global
defines = {}

---@type defines.direction
local dirdefs = {
   north = 0 --[[@as defines.direction.north ]],
   northnortheast = 1 --[[@as defines.direction.northnortheast ]],
   northeast = 2 --[[@as defines.direction.northeast ]],
   eastnortheast = 3 --[[@as defines.direction.eastnortheast ]],
   east = 4 --[[@as defines.direction.east ]],
   eastsoutheast = 5 --[[@as defines.direction.eastsoutheast ]],
   southeast = 6 --[[@as defines.direction.southeast ]],
   southsoutheast = 7 --[[@as defines.direction.southsoutheast ]],
   south = 8 --[[@as defines.direction.south ]],
   southsouthwest = 9 --[[@as defines.direction.southsouthwest ]],
   southwest = 10 --[[@as defines.direction.southwest ]],
   westsouthwest = 11 --[[@as defines.direction.westsouthwest ]],
   west = 12 --[[@as defines.direction.west ]],
   westnorthwest = 13 --[[@as defines.direction.westnorthwest ]],
   northwest = 14 --[[@as defines.direction.northwest ]],
   northnorthwest = 15 --[[@as defines.direction.northnorthwest ]],
}

defines.direction = dirdefs

defines.rail_direction = {
   front = 0,
   back = 1,
}

---Polyfill for Factorio's table_size function
---Counts the number of keys in a table (both array and hash parts)
---@param tbl table
---@return number
function table_size(tbl)
   local count = 0
   for _ in pairs(tbl) do
      count = count + 1
   end
   return count
end
