--Here: Reading tiles and entities at the cursor position

local Consts = require("scripts.consts")
local EntitySelection = require("scripts.entity-selection")
local FaInfo = require("scripts.fa-info")
local FaUtils = require("scripts.fa-utils")
local Graphics = require("scripts.graphics")
local Localising = require("scripts.localising")
local Mouse = require("scripts.mouse")
local PrimaryFinder = require("scripts.rails.primary-finder")
local RailAnnouncer = require("scripts.rails.announcer")
local RailDescriber = require("railutils.rail-describer")
local RailQueries = require("railutils.queries")
local Speech = require("scripts.speech")
local SurfaceHelper = require("scripts.rails.surface-helper")
local Viewpoint = require("scripts.viewpoint")
local MessageBuilder = Speech.MessageBuilder

local mod = {}

---Reads the tile at the cursor position and speaks the result
---@param pindex integer Player index
---@param start_text LocalisedString? Optional text to prepend to the result
function mod.read_tile(pindex, start_text)
   local message = MessageBuilder.new()
   if start_text then message:fragment(start_text) end
   mod.read_tile_inner(pindex, message)
   Speech.speak(pindex, message:build())
end

---Announces all rails at the current cursor position
---@param pindex integer Player index
---@param message fa.MessageBuilder MessageBuilder to append rail information to
function mod.read_tile_rails(pindex, message)
   local player = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()

   local floor_x = math.floor(cursor_pos.x)
   local floor_y = math.floor(cursor_pos.y)
   local search_area = {
      { x = floor_x + 0.001, y = floor_y + 0.001 },
      { x = floor_x + 0.999, y = floor_y + 0.999 },
   }

   -- Query functions for deduplication
   local function query_real_rails(area)
      return player.surface.find_entities_filtered({ area = area, type = Consts.RAIL_TYPES })
   end
   local function query_ghost_rails(area)
      return player.surface.find_entities_filtered({ area = area, ghost_type = Consts.RAIL_TYPES })
   end

   -- Find real and ghost rails
   local rail_entities = query_real_rails(search_area)
   local ghost_entities = query_ghost_rails(search_area)

   if #rail_entities == 0 and #ghost_entities == 0 then return end

   local is_first = true

   -- Announce real rails
   if #rail_entities > 0 then
      rail_entities = PrimaryFinder.deduplicate_secondary_rails(rail_entities, query_real_rails)
      local wrapped_surface = SurfaceHelper.wrap_surface_vanilla(player.surface)

      for _, rail_entity in ipairs(rail_entities) do
         if rail_entity and rail_entity.valid then
            local rail_type = RailQueries.prototype_type_to_rail_type(rail_entity.name)
            if rail_type then
               local pos = { x = rail_entity.position.x, y = rail_entity.position.y }
               local description = RailDescriber.describe_rail(wrapped_surface, rail_type, rail_entity.direction, pos)
               local announcement =
                  RailAnnouncer.announce_rail(description, { prefix_rail = is_first, rail_entity = rail_entity })
               message:list_item_forced_comma(announcement)
               is_first = false
            end
         end
      end
   end

   -- Announce ghost rails
   if #ghost_entities > 0 then
      ghost_entities = PrimaryFinder.deduplicate_secondary_rails(ghost_entities, query_ghost_rails)
      local ghost_surface = SurfaceHelper.wrap_surface_vanilla_ghosts(player.surface)

      for _, ghost_entity in ipairs(ghost_entities) do
         if ghost_entity and ghost_entity.valid then
            local rail_type = RailQueries.prototype_type_to_rail_type(ghost_entity.ghost_name)
            if rail_type then
               local pos = { x = ghost_entity.position.x, y = ghost_entity.position.y }
               local description = RailDescriber.describe_rail(ghost_surface, rail_type, ghost_entity.direction, pos)
               local announcement =
                  RailAnnouncer.announce_rail(description, { prefix_rail = is_first, is_ghost = true })
               message:list_item_forced_comma(announcement)
               is_first = false
            end
         end
      end
   end
end

---Internal function that gathers information about the tile at the cursor position
---@param pindex integer Player index
---@param message fa.MessageBuilder MessageBuilder to append information to
function mod.read_tile_inner(pindex, message)
   local tile_name, tile_object = EntitySelection.get_player_tile(pindex)
   if not tile_name then
      message:fragment({ "fa.tile-uncharted-out-of-range" })
      return
   end

   local ent = EntitySelection.get_first_ent_at_tile(pindex)

   -- Special handling for rails: announce all rails at this position
   local is_rail = ent and ent.valid and Consts.RAIL_TYPES_SET[ent.type]
   local is_ghost_rail = ent and ent.valid and ent.type == "entity-ghost" and Consts.RAIL_TYPES_SET[ent.ghost_type]
   if is_rail or is_ghost_rail then
      mod.read_tile_rails(pindex, message)
      Graphics.draw_cursor_highlight(pindex, ent, nil)
      game.get_player(pindex).selected = ent
   elseif not (ent and ent.valid) then
      --If there is no ent, read the tile instead
      if tile_object then message:fragment(Localising.get_localised_name_with_fallback(tile_object)) end
      if Consts.WATER_TILE_NAMES_SET[tile_name] then
         --Identify shores and crevices and so on for water tiles
         message:fragment(FaUtils.identify_water_shores(pindex))
      end
      Graphics.draw_cursor_highlight(pindex, nil, nil)
      game.get_player(pindex).selected = nil
   else
      --Regular entity handling
      message:fragment(FaInfo.ent_info(pindex, ent))
      Graphics.draw_cursor_highlight(pindex, ent, nil)
      game.get_player(pindex).selected = ent
   end

   --Add info on whether the tile is uncharted or blurred or distant
   message:fragment(Mouse.cursor_visibility_info(pindex))
end

return mod
