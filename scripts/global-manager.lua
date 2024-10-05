--[[
Functionality for managing global state, in particular splitting it up and
typing it.

The main entrypoint to this module is declare_global_module, called as:

```
local module_state = declare_global_module('rulers', {}, opts)
```

Where the second argument is either a table or a function taking a table key,
which acts as a default value.  Afterwords, `module_state[index]` invisibly and
by default magically refers to `global.players[pindex].modulename`.  Any index
which is not present gets a copy of the default value, or if it is a function,
whatever the function returns.

If opts contains 'root_field', this will instead use global.root_field[index].
opts may be nil.

You can do:

```
---@class MyClass
---@field my_field String does cool stuff

---@type table<any, MyClass>
local module_state = ...
```

Enabling both autocomplete and type checks.
]]

local mod = {}

---@class fa.GlobalManagerOpts
---@field root_field string

---@param module_name string
---@param default_value any
---@param opts? fa.GlobalManagerOpts
---@returns any
function mod.declare_global_module(module_name, default_value, opts)
   assert(default_value ~= nil, "Default values of nil can't be put in a table as values")

   opts = opts or {
      root_field = "players",
   }

   local default_fn = default_value
   if type(default_fn) == "table" then
      default_fn = function(_key)
         return table.deepcopy(default_value)
      end
   elseif type(default_fn) ~= "function" then
      default_fn = function()
         return default_value
      end
   end

   local meta = {}

   function meta:__newindex(index, nv)
      if not global[opts.root_field] then global[opts.root_field] = {} end
      if not global[opts.root_field][index] then global[opts.root_field][index] = {} end

      global[opts.root_field][index][module_name] = nv
   end

   function meta:__index(index)
      global[opts.root_field] = global[opts.root_field] or {}
      global[opts.root_field][index] = global[opts.root_field][index] or {}

      local possible = global[opts.root_field][index][module_name]

      if not possible then
         possible = default_fn(index)
         global[opts.root_field][index][module_name] = possible
      end

      -- Checked by the above assert and also LuaLS, but this isn't a critical
      -- path and it doesn't hurt.
      assert(possible, "Somehow, we got a default value of nil")

      return possible
   end

   local function wrapped_iter(is_ipairs)
      local last = nil
      local function ret()
         if not global[opts.root_field] then return nil end
         while true do
            last = next(global[opts.root_field], last)
            if not last then return nil end
            if global[opts.root_field][last][module_name] then
               if not is_ipairs or type(last) == "number" then
                  return last, global[opts.root_field][last][module_name]
               end
            end
         end
      end

      return ret
   end

   function meta:__ipairs()
      return wrapped_iter(true)
   end
   function meta:__pairs()
      return wrapped_iter(false)
   end

   ret = {}
   setmetatable(ret, meta)
   return ret
end

return mod
