--[[
A data-to-runtime map is our name for a map of information only available in the
data stage, which is able to be read in the runtime stage.  This map holds
string keys and string values only, and both keys and values must be under 200
characters in length.

These maps are defined by their name, which should be unique per mapping.  The
function build() should be called in the data stage.  The function load should
be called at runtime, but only after on_init.

Each key-value pair is shoved into the localised string of a uniquely named item
prototype of the form fa-data-map-mapname-i, where i is some numeric index
(starting at 1, to match lua).  Empty maps are represented with
fa-data-map-empty.  Maps which are not present at all throw.

An example of why this is useful is our resource clustering algorithm, which
needs data not yet exposed on LuaEntityPrototype.
]]

local mod = {}

---@param name string
---@param values table<string, any> Values have tostring called on them for you.
function mod.build(name, values)
   local index = 1
   for k, v in pairs(values) do
      v = tostring(v)

      data:extend({
         {
            type = "item",
            name = string.format("fa-data-map-%s-%i", name, index),
            icon = data.raw.item.accumulator.icon,
            icon_size = 2,
            stack_size = 1,
            localised_description = { k, v },
         },
      })

      index = index + 1
   end

   if index == 1 then
      -- We didn't add anything; instead, record that it was empty.

      data:extend({
         {
            type = "item",
            name = string.format("fa-data-map-%s-empty", name),
            icon = values.raw.item.accumulator.icon,
            icon_size = 2,
            stack_size = 1,
            localised_description = "EMPTY_MAP",
         },
      })
   end
end

--@param name string
---@return table<string, string>
function mod.load(name)
   local res = {}
   local i = 1

   while true do
      local protoname = string.format("fa-data-map-%s-%i", name, i)
      local proto = prototypes.item[protoname]
      if not proto then break end
      local k = proto.localised_description[1]
      local v = proto.localised_description[2]
      assert(k)
      assert(v)
      res[k] = v
      i = i + 1
   end

   if i == 1 then
      -- It is empty. But let us make sure and fail loudly if it doesn't exist
      -- at all.
      assert(prototypes.item[string.format("fa-data-map-%s-empty", name)], "Map " .. name .. " was never declared")
   end

   return res
end

return mod
