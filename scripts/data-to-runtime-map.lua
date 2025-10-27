--[[
A data-to-runtime map is our name for a map of information only available in the data stage, which is able to be read in
the runtime stage.

These maps are defined by their name, which should be unique per mapping.  The function build() should be called in the
data stage.  The function load should be called at runtime, but only after on_init.

An example of why this is useful is our resource clustering algorithm, which needs data not yet exposed on
LuaEntityPrototype.
]]

local mod = {}

---Build a data-to-runtime map using ModData prototype
---@param name string Unique name for this map (will be prefixed with "fa-")
---@param values table<string, any> Key-value pairs to store. Values can be numbers, strings, booleans, or nested tables.
function mod.build(name, values)
   -- Convert all values to ensure they're serializable
   local converted_data = {}
   for k, v in pairs(values) do
      -- ModData supports AnyBasic, which includes numbers, strings, booleans, and nested tables
      -- No need to convert to string anymore
      converted_data[k] = v
   end

   data:extend({
      {
         type = "mod-data",
         name = "fa-" .. name,
         data = converted_data,
      },
   })
end

---Load a data-to-runtime map from ModData prototype
---@param name string Name of the map (without "fa-" prefix)
---@return table<string, any> The stored data
function mod.load(name)
   local proto_name = "fa-" .. name
   local proto = prototypes.mod_data[proto_name]

   assert(proto, "Map " .. name .. " was never declared (expected prototype: " .. proto_name .. ")")

   return proto.data
end

return mod
