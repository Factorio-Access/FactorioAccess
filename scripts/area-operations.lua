--[[
Area Operations
Provides functionality for area-based mining and clearing operations.
Handles area mining for obstacles, ghosts, and with special tools.
]]

local Consts = require("scripts.consts")
local Localising = require("scripts.localising")
local PlayerMiningTools = require("scripts.player-mining-tools")
local FaUtils = require("scripts.fa-utils")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local Viewpoint = require("scripts.viewpoint")

local mod = {}

---Mine area around cursor or selected entity
---@param pindex number
function mod.mine_area(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()
   local p = game.get_player(pindex)
   local ent = game.get_player(pindex).selected
   local cleared_count = 0
   local cleared_total = 0
   local comment = ""

   --Check if the is within reach or the applicable entity is within reach
   if
      ent ~= nil
      and ent.valid
      and ent.name ~= "entity-ghost"
      and (
         util.distance(game.get_player(pindex).position, ent.position) > game.get_player(pindex).reach_distance
         or util.distance(game.get_player(pindex).position, cursor_pos) > game.get_player(pindex).reach_distance
      )
   then
      game.get_player(pindex).play_sound({ path = "utility/cannot_build" })
      Speech.speak(pindex, { "fa.area-out-of-reach" })
      return
   end

   --Get initial inventory size
   local init_empty_stacks = game.get_player(pindex).get_main_inventory().count_empty_stacks()

   --Begin clearing
   if ent then
      local surf = ent.surface
      local pos = ent.position
      if
         ent.type == "tree"
         or ent.name == "rock-big"
         or ent.name == "rock-huge"
         or ent.name == "sand-rock-big"
         or ent.name == "item-on-ground"
      then
         --Obstacles within 5 tiles: trees and rocks and ground items
         game.get_player(pindex).play_sound({ path = "player-mine" })
         cleared_count, comment = PlayerMiningTools.clear_obstacles_in_circle(pos, 5, pindex)
      elseif ent.name == "entity-ghost" then
         --Ghosts within 10 tiles
         local ghosts = surf.find_entities_filtered({ position = pos, radius = 10, name = { "entity-ghost" } })
         for i, ghost in ipairs(ghosts) do
            game.get_player(pindex).mine_entity(ghost, true)
            cleared_count = cleared_count + 1
         end
         game.get_player(pindex).play_sound({ path = "utility/item_deleted" })
         --Draw the clearing range
         rendering.draw_circle({
            color = { 0, 1, 0 },
            radius = 10,
            width = 2,
            target = pos,
            surface = surf,
            time_to_live = 60,
         })
         Speech.speak(pindex, { "fa.cleared-entity-ghosts", tostring(cleared_count) })
         return
      else
         --Check if it is a remnant ent, clear obstacles
         local ent_is_remnant = false
         local remnant_names = Consts.ENT_NAMES_CLEARED_AS_OBSTACLES
         for i, name in ipairs(remnant_names) do
            if ent.name == name then ent_is_remnant = true end
         end
         if ent_is_remnant then
            game.get_player(pindex).play_sound({ path = "player-mine" })
            cleared_count, comment = PlayerMiningTools.clear_obstacles_in_circle(cursor_pos, 5, pindex)
         end

         --(For other valid ents, do nothing)
      end
   else
      --For empty tiles, clear obstacles
      game.get_player(pindex).play_sound({ path = "player-mine" })
      cleared_count, comment = PlayerMiningTools.clear_obstacles_in_circle(cursor_pos, 5, pindex)
   end
   cleared_total = cleared_total + cleared_count

   --If cut-paste tool in hand, mine every non-resource entity in the area that you can.
   local p = game.get_player(pindex)
   local stack = p.cursor_stack
   if stack and stack.valid_for_read and stack.name == "cut-paste-tool" then
      local all_ents =
         p.surface.find_entities_filtered({ position = p.position, radius = 5, force = { p.force, "neutral" } })
      for i, ent in ipairs(all_ents) do
         if ent and ent.valid then
            local name = ent.name
            game.get_player(pindex).play_sound({ path = "player-mine" })
            if PlayerMiningTools.try_to_mine_with_soun(ent, pindex) then cleared_total = cleared_total + 1 end
         end
      end
   end

   --If the deconstruction planner is in hand, mine every entity marked for deconstruction except for cliffs.
   if stack and stack.valid_for_read and stack.is_deconstruction_item then
      local all_ents =
         p.surface.find_entities_filtered({ position = p.position, radius = 5, force = { p.force, "neutral" } })
      for i, ent in ipairs(all_ents) do
         if ent and ent.valid and ent.is_registered_for_deconstruction(p.force) then
            local name = ent.name
            game.get_player(pindex).play_sound({ path = "player-mine" })
            if PlayerMiningTools.try_to_mine_with_soun(ent, pindex) then cleared_total = cleared_total + 1 end
         end
      end
   end

   --Calculate collected stack count
   local stacks_collected = init_empty_stacks - game.get_player(pindex).get_main_inventory().count_empty_stacks()

   --Print result
   local message = MessageBuilder.new()
   message:fragment({ "fa.cleared-objects", tostring(cleared_total) })
   if stacks_collected >= 0 then message:fragment({ "fa.and-collected-stacks", tostring(stacks_collected) }) end
   Speech.speak(pindex, message:build())
end

---Super mine area for long range ghost clearing
---@param pindex number
function mod.super_mine_area(pindex)
   local ent = game.get_player(pindex).selected
   if not ent or not ent.valid then return end

   local cleared_count = 0

   --Begin clearing
   local surf = ent.surface
   local pos = ent.position
   if ent.name == "entity-ghost" then
      --Ghosts within 100 tiles
      local ghosts = surf.find_entities_filtered({ position = pos, radius = 100, name = { "entity-ghost" } })
      for i, ghost in ipairs(ghosts) do
         game.get_player(pindex).mine_entity(ghost, true)
         cleared_count = cleared_count + 1
      end
      game.get_player(pindex).play_sound({ path = "utility/item_deleted" })
      --Draw the clearing range
      rendering.draw_circle({
         color = { 0, 1, 0 },
         radius = 100,
         width = 10,
         target = pos,
         surface = surf,
         time_to_live = 60,
      })
      Speech.speak(pindex, { "fa.cleared-entity-ghosts-100", tostring(cleared_count) })
      return
   end
end

return mod
