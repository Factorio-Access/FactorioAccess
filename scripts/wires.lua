--[[
Helpers for wires.

After 2.0 the wire-related APIs were unified, so now we may ask questions like
"get all entities connected" regardless of the type.  This file contains the
common code for circuit and electric networks in that regard.
]]
local mod = {}

---@param ent LuaEntity
---@param network defines.wire_type
---@return WireConnection[]
function mod.get_connectors(ent, network)
   local res = {}

   mod.call_on_connectors(ent, network, function(_unused, c)
      table.insert(res, c)
      return true
   end)
   return res
end

--[[
Same as get_connectors, but taking a callback and stopping when that callback
returns false.

useful to avoid making tables or succinctly represent recursion, e.g. "all poles
in the network".

Only guaranteed to be called on connectors with connections already. In order to
get them all, it is required that they be permanently created, and we don't want
to do that.
]]
---@param ent LuaEntity
---@param network defines.wire_type
---@param callback fun(LuaWireConnector, WireConnection): boolean
function mod.call_on_connectors(ent, network, callback)
   for _, c in pairs(ent.get_wire_connectors(false)) do
      if c.wire_type == network then
         for _, conn in pairs(c.connections) do
            if not callback(c, conn) then return end
         end
      end
   end
end

return mod
