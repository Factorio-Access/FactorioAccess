--- Handles cursor stack changes and pipette tool
local mod = {}

local StorageManager = require("scripts.storage-manager")
local Viewpoint = require("scripts.viewpoint")
local Graphics = require("scripts.graphics")
local Blueprints = require("scripts.blueprints")
local BuildDimensions = require("scripts.build-dimensions")
local FaUtils = require("scripts.fa-utils")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")

local dirs = defines.direction

---@class fa.CursorChanges.StorageState
---@field last_pipette_entity_tick number? Tick when we last pipetted an entity with direction

---@type table<number, fa.CursorChanges.StorageState>
local cursor_storage = StorageManager.declare_storage_module("cursor_changes", {
   last_pipette_entity_tick = nil,
})

--- Pipette tool handler for fa-q key
---@param event EventData.CustomInputEvent
function mod.kb_pipette_tool(event)
   local pindex = event.player_index
   local p = game.get_player(pindex)

   if p.is_cursor_empty() then
      local ent = p.selected
      if ent and ent.valid then
         if ent.supports_direction then
            local vp = Viewpoint.get_viewpoint(pindex)
            vp:set_hand_direction(ent.direction)
            cursor_storage[pindex].last_pipette_entity_tick = game.tick
         end
         p.pipette(ent.prototype)
      end
   end
end

---Say the ghost in hand: "transport belt ghost facing north in hand".
---@param pindex integer
function mod.read_cursor_ghost(pindex)
   local item = assert(FaUtils.cursor_item(assert(game.get_player(pindex))))
   local placed = item.place_result
   local facing = placed and placed.supports_direction
   Speech.speak(pindex, {
      "fa.cursor-ghost-description",
      Localising.get_localised_name_with_fallback(item),
      facing and 1 or 0,
      facing
            and { "fa.facing-direction", FaUtils.direction_lookup(Viewpoint.get_viewpoint(pindex):get_hand_direction()) }
         or "",
   })
end

--- Cursor stack changed handler
---@param event EventData.on_player_cursor_stack_changed
---@param pindex integer
---@param read_hand function
function mod.on_cursor_stack_changed(event, pindex, read_hand)
   local vp = Viewpoint.get_viewpoint(pindex)

   local p = assert(game.get_player(pindex))
   local stack = p.cursor_stack
   local holds_ghost = not (stack and stack.valid_for_read) and p.cursor_ghost ~= nil
   local new_item_name = ""
   if holds_ghost then
      new_item_name = assert(FaUtils.cursor_item(p)).name
   elseif stack and stack.valid_for_read then
      new_item_name = stack.name
      if stack.is_blueprint and storage.players[pindex].blueprint_hand_direction ~= dirs.north then
         storage.players[pindex].blueprint_hand_direction = dirs.north
         if game.get_player(pindex).cursor_stack_temporary == false then
            Blueprints.refresh_blueprint_in_hand(pindex)
         end
         local width, height = BuildDimensions.get_stack_build_dimensions(stack, dirs.north)
         if width == nil or height == nil then return end
      end
   end

   if storage.players[pindex].previous_hand_item_name ~= new_item_name then
      storage.players[pindex].previous_hand_item_name = new_item_name

      local pipetted_this_tick = cursor_storage[pindex].last_pipette_entity_tick == game.tick

      if not pipetted_this_tick then
         vp:set_hand_direction(dirs.north)
         vp:set_flipped_horizontal(false)
         vp:set_flipped_vertical(false)
      end

      if holds_ghost then
         mod.read_cursor_ghost(pindex)
      else
         read_hand(pindex)
      end
   end

   storage.players[pindex].bp_selecting = false
   Graphics.sync_build_cursor_graphics(pindex)
end

return mod
