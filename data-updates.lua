local Consts = require("scripts.consts")
local DataToRuntimeMap = require("scripts.data-to-runtime-map")

for name, proto in pairs(data.raw.container) do
   proto.open_sound = proto.open_sound or { filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.43 }
   proto.close_sound = proto.close_sound or { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 }
end

---Apply universal belt immunity
data.raw.character.character.has_belt_immunity = true

---Make the character unlikely to be selected by the mouse pointer when overlapping with entities
data.raw.character.character.selection_priority = 2

-- Modifications to Kruise Kontrol inputs (no longer needed)
-- We will handle Kruise Kontrol driving through the remote API.  It binds
-- everything to the mouse, which we don't use.  The exception is enter, which
-- cancels.  We also cancel on enter, but double-cancel doesn't do anything.
-- This file used to modify those inputs, but we don't need to since things
-- already work.  If we do need to revisit that, note that we will need to move
-- KK inputs to a dummy key, or alternatively try setting [alt]_key_sequence to
-- the empty string.  Other solutions (e.g. removal, setting them to disabled)
-- break KK because Factorio will not let KK register events.

--Modifications to Pavement Driving Assist Continued inputs
data:extend({
   {
      type = "custom-input",
      name = "toggle_drive_assistant",
      key_sequence = "L",
      consuming = "game-only",
   },
   {
      type = "custom-input",
      name = "toggle_cruise_control",
      key_sequence = "O",
      consuming = "game-only",
   },
   {
      type = "custom-input",
      name = "set_cruise_control_limit",
      key_sequence = "CONTROL + O",
      consuming = "game-only",
   },
   {
      type = "custom-input",
      name = "confirm_set_cruise_control_limit",
      key_sequence = "",
      linked_game_control = "confirm-gui",
   },
})

--Modify base prototypes to remove their default descriptions
for name, pack in pairs(data.raw.tool) do
   if pack.localised_description and pack.localised_description[1] == "item-description.science-pack" then
      pack.localised_description = nil
   end
end

for name, mod in pairs(data.raw.module) do
   if
      mod.localised_description and mod.localised_description[1] == "item-description.effectivity-module"
      or mod.localised_description and mod.localised_description[1] == "item-description.productivity-module"
      or mod.localised_description and mod.localised_description[1] == "item-description.speed-module"
   then
      mod.localised_description = nil
   end
end

---Make selected vanilla objects not collide with players
local function remove_player_collision(ent_p)
   (ent_p.collision_mask or {})["player"] = nil
end
for _, ent_type in pairs({ "pipe", "pipe-to-ground", "constant-combinator", "inserter" }) do
   for _, ent_p in pairs(data.raw[ent_type]) do
      remove_player_collision(ent_p)
   end
end
--TODO:should probably just filter electric poles by their collision_box size...
remove_player_collision(data.raw["electric-pole"]["small-electric-pole"])
remove_player_collision(data.raw["electric-pole"]["medium-electric-pole"])

--[[
We will now inject a trigger on entity creation, which will send control.lua an
event on the creation of any map-placed entity.  This is slow, and it should
also be possible to tone it back in future if that ever becomes problematic. The
purpose is being able to scan efficiently, rather than trying to scan surfaces
every time we get a request.  See scripts.scanner.entrypoint.

A trigger is either a single trigger or an array of triggers.  To be compatible
with other mods, we convert these to arrays, then tack ours on at the end.
]]

local function augment_with_trigger(proto)
   -- Issue #298, we found a crash in the game which cannot be worked around on our side.
   do
      return
   end
   -- our trigger.
   ---@type data.Trigger
   local nt = {

      type = "direct",
      action_delivery = {
         type = "instant",
         source_effects = {
            type = "script",
            effect_id = Consts.NEW_ENTITY_SUBSCRIBER_TRIGGER_ID,
         },
      },
   }

   if not proto.created_effect then
      proto.created_effect = {}
   elseif not proto.created_effect[1] then
      -- This is how we ask lua if something is an array.
      proto.created_effect = { proto.created_effect }
   end

   table.insert(proto.created_effect, nt)
end

for ty, children in pairs(data.raw) do
   if not defines.prototypes.entity[ty] then goto continue end

   for _name, proto in pairs(children) do
      augment_with_trigger(proto)
   end
   ::continue::
end

--[[
See https://forums.factorio.com/viewtopic.php?f=28&t=114820

We need resource_patch_search_radius to write the scanner algorithm, though
hopefully in future we can just ask the engine.  The problem of today is that we
don't have it at runtime.  We therefore make a dummy item, and smuggle it
across in the localised_description.  The format is:

prototype-name=5
other-prototype-name=10

So on.  Parsed back out in scripts.scanner.resource-patches.lua.

If nil we just don't write anything after the =.
]]

local resource_search_radiuses = {}

for name, proto in pairs(data.raw["resource"]) do
   if proto.type == "resource" then resource_search_radiuses[name] = proto.resource_patch_search_radius or 3 end
end

local DataToRuntimeMap = require("scripts.data-to-runtime-map")
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
