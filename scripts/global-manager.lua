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

For testing, one may set persistent=false in opts.  If so, the global state will
be reset on first access.

Some state such as that for the scanner is ephemeral.  If this is the case, one
may set ephemeral_state_version to an integer.  When set for the first time or
incremented, the state will be cleared before access for the first time the game
starts with the mod updated.  This is useful for example to let the scanner
pickup backend changes, but comes at the cost of throwing out state.  Use
carefully.
]]

local mod = {}

---@class fa.GlobalManagerOpts
---@field root_field string?
---@field persistent boolean?
---@field ephemeral_state_version number?

---@param module_name string
---@param default_value any
---@param opts? fa.GlobalManagerOpts
---@returns any
function mod.declare_global_module(module_name, default_value, opts)
   assert(default_value ~= nil, "Default values of nil can't be put in a table as values")

   opts = opts or {
      root_field = "players",
      persistent = true,
   }

   local tried_clear = false

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

   local function do_clear_if_needed()
      if tried_clear then return end
      tried_clear = true

      local version_changed = false
      if opts.ephemeral_state_version then
         local ver_state = global.global_manager
         if not ver_state then
            ver_state = {}
            global.global_manager = {}
         end
         local ver_state = ver_state.versions
         if not ver_state then
            ver_state = {}
            global.global_manager.versions = ver_state
         end

         if not ver_state[opts.root_field] then ver_state[opts.root_field] = {} end
         local ver = ver_state[opts.root_field][module_name]
         version_changed = ver ~= opts.ephemeral_state_version
         ver_state[opts.root_field][module_name] = opts.ephemeral_state_version
      end

      if version_changed or opts.persistent == false then
         if not global[opts.root_field] then return end
         for k, e in pairs(global[opts.root_field]) do
            e[module_name] = nil
         end
      end
   end

   local meta = {}

   function meta:__newindex(index, nv)
      do_clear_if_needed()

      if not global[opts.root_field] then global[opts.root_field] = {} end
      if not global[opts.root_field][index] then global[opts.root_field][index] = {} end

      global[opts.root_field][index][module_name] = nv
   end

   function meta:__index(index)
      do_clear_if_needed()

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
      do_clear_if_needed()
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
