--[[
Functionality for managing global state, in particular splitting it up and
typing it.

The main entrypoint to this module is declare_global_module, called as:

```
local module_state = declare_global_module('rulers', {})
```

Where the second argument is either a table or a function taking a pindex, which
acts as a default value.  Afterwords, `module_state[pindex]` invisibly and
magically refers to `global.players[pindex].modulename`, in a slightly more
efficient way than the longer expression, and definitely in a more efficient way
than checking for a player's presence before every use.  Any pindex which is not
present gets a copy of the default value, or if it is a function, whatever the
function returns.

The last point of this module is that it may be used with LuaLS, unlike the
global constant itself.  One may type the global state for a module like this:

```
---@class MyClass
---@field my_field String does cool stuff

---@type table<number, MyClass>
local module_state = ...
```

Enabling both autocomplete and type checks.
]]

local mod = {}

---@param module_name string
---@param default_value any
---@returns any
function mod.declare_global_module(module_name, default_value)
   assert(default_value ~= nil, "Default values of nil can't be put in a table as values")

   local default_fn = default_value
   if type(default_fn) == "table" then
      default_fn = function(_pindex)
         return table.deepcopy(default_value)
      end
   elseif type(default_fn) ~= "function" then
      default_fn = function()
         return default_value
      end
   end

   -- Ensure that the players array itself is present.
   if not global.players then global.players = {} end

   local meta = {}

   function meta:__newindex(pindex, nv)
      -- Gets picked up by `__index` below.
      global.players[pindex][module_name] = nv
   end

   function meta:__index(pindex)
      local possible = global.players[pindex][module_name]
      if not possible then possible = default_fn(pindex) end

      -- Checked by the above assert and also LuaLS, but this isn't a critical
      -- path and it doesn't hurt.
      assert(possible, "Somehow, we got a default value of NIL")

      -- After this, the table no longer calls this metamethod.
      self[pindex] = possible
      global.players[pindex][module_name] = possible
      return possible
   end

   local ret = {}
   setmetatable(ret, meta)
   return ret
end

return mod
