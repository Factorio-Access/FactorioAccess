local mod = {}

--[[
Return a function wrapping the original function.  When called the first time,
call the original function.  Otherwise, return a cached value.

This exists for a very simple reason: Factorio doesn't give us access to
prototype metadata in the runtime stage until *after* control.lua.  This stops
us from easily making top-level consts in the normal fashion.  Instead, we may:

```
local CONST = cached(computer)

-- To get the value
CONST()
```

This can be extended with support for arguments later should we desire to do so;
that's backward compatible in Lua with functions taking ...
]]
---@param func function(): any
---@returns function(): any
function mod.cached(func)
   local cache = nil
   -- Could actually be nil, so use a flag.
   local did_cache = false

   return function()
      if did_cache then return cache end
      cache = func()
      did_cache = true

      -- Let go of it for gc.
      ---@diagnostic disable-next-line cast-local-type
      func = nil
      return cache
   end
end

-- Given a value, return a function which returns the value.
function mod.functionize(value)
   return function()
      return value
   end
end

return mod
