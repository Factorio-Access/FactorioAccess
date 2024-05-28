--[[
Quickly create a vtable which knows how to forward all events to something.

This works as follows.  Write a function which can find the child vtable off the
first 3 params of an event, the pindex, vtable, and global state. It must return
the vtable and global state of the child.  Call forwarding_vtab with that.
Afterwords, all events which are received are forwarded to the child control,
unless the current control overwrites it.  If finder returns nil, do nothing and
return the second argument.  
]]
local ustate = require("scripts.ui.global-state")

local mod = {}

---@returns table
function mod.forwarding_vtable(finder, or_else)
   local ret = {}

   for _unused, name in ipairs(ustate.all_event_names) do
      ret[name] = function(pindex, v, g, ...)
         local v, f_g = finder(pindex, g, v)
         if not v or not v[name] then return or_else end
         return v[name](pindex, v, f_g, ...)
      end
   end
end

return mod
