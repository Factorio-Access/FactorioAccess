local Consts = require("scripts.consts")
local DataToRuntimeMap = require("scripts.data-to-runtime-map")

--[[
See https://forums.factorio.com/viewtopic.php?f=28&t=114820

We need resource_patch_search_radius to write the scanner algorithm, though
hopefully in future we can just ask the engine.  The problem of today is that we
don't have it at runtime.  We use ModData prototypes to pass this data from
data stage to runtime. Parsed back out in scripts.scanner.resource-patches.lua.

If nil we default to 3.
]]

local resource_search_radiuses = {}

for name, proto in pairs(data.raw["resource"]) do
   if proto.type == "resource" then resource_search_radiuses[name] = proto.resource_patch_search_radius or 3 end
end

DataToRuntimeMap.build(Consts.RESOURCE_SEARCH_RADIUSES_MAP_NAME, resource_search_radiuses)

--[[
For now, it turns out that we cannot get the amount of items one must craft at
runtime.  This is probably an API oversight:
https://forums.factorio.com/viewtopic.php?f=65&t=118491&p=628236#p628236

As a workaround we create a map containing a list of all technologies that have
a craft-item trigger.  Each of these points at a second map which contains the
names and values.  When we see craft-item at runtime, we can match them up.  The
other half is near the top of research.lua: ctrl+f cached.
]]

local research_craft_map_outer = {}

for name, r in pairs(data.raw.technology) do
   local t = r.research_trigger or {}
   if t.type == "craft-item" then
      local count = t.count or 1

      local mapname = string.format("%s-%s", name, Consts.RESEARCH_CRAFT_ITEM_TRIGGER_MAPNAME_SUFFIX)
      DataToRuntimeMap.build(mapname, {
         [t.item] = count,
      })
      research_craft_map_outer[name] = mapname
   end
end

DataToRuntimeMap.build(Consts.RESEARCH_CRAFT_ITEMS_MAP_OUTER, research_craft_map_outer)

--[[
Combinator bounding boxes for wire connections.

Combinators have separate input and output connection points, and the drag_wire API uses
position to determine which side to connect to. We need the bounding box data from prototypes
to calculate the correct positions for each side.
]]

local CombinatorBoundingBoxes = require("scripts.combinator-bounding-boxes")
CombinatorBoundingBoxes.build_map()
