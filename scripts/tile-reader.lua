--Here: Reading tiles and entities at the cursor position

local EntitySelection = require("scripts.entity-selection")
local FaInfo = require("scripts.fa-info")
local FaUtils = require("scripts.fa-utils")
local Graphics = require("scripts.graphics")
local Localising = require("scripts.localising")
local Mouse = require("scripts.mouse")
local Speech = require("scripts.speech")

local mod = {}

---Reads the tile at the cursor position and speaks the result
---@param pindex integer Player index
---@param start_text string? Optional text to prepend to the result
function mod.read_tile(pindex, start_text)
   local res = mod.read_tile_inner(pindex)
   if start_text then table.insert(res, 1, start_text) end
   Speech.speak(pindex, FaUtils.localise_cat_table(res))
end

---Internal function that gathers information about the tile at the cursor position
---@param pindex integer Player index
---@return table Array of localized strings describing the tile
function mod.read_tile_inner(pindex)
   local result = {}

   local tile_name, tile_object = EntitySelection.get_player_tile(pindex)
   if not tile_name then return { "Tile uncharted and out of range" } end

   local ent = EntitySelection.get_first_ent_at_tile(pindex)
   if not (ent and ent.valid) then
      --If there is no ent, read the tile instead
      table.insert(result, Localising.get_localised_name_with_fallback(tile_object))
      if
         tile_name == "water"
         or tile_name == "deepwater"
         or tile_name == "water-green"
         or tile_name == "deepwater-green"
         or tile_name == "water-shallow"
         or tile_name == "water-mud"
         or tile_name == "water-wube"
      then
         --Identify shores and crevices and so on for water tiles
         table.insert(result, FaUtils.identify_water_shores(pindex))
      end
      Graphics.draw_cursor_highlight(pindex, nil, nil)
      game.get_player(pindex).selected = nil
   else --laterdo tackle the issue here where entities such as tree stumps block preview info
      -- Special handling for rails: announce all rails at this position
      if ent.type == "straight-rail" then
         local player = game.get_player(pindex)
         if player then
            local floor_x = math.floor(ent.position.x)
            local floor_y = math.floor(ent.position.y)
            local search_area = {
               { x = floor_x + 0.001, y = floor_y + 0.001 },
               { x = floor_x + 0.999, y = floor_y + 0.999 },
            }

            -- Find all rail entities at this position
            local rail_entities = player.surface.find_entities_filtered({
               area = search_area,
               type = { "straight-rail", "curved-rail-a", "curved-rail-b", "half-diagonal-rail" },
            })

            -- Announce each rail
            if #rail_entities > 0 then
               for _, rail_entity in ipairs(rail_entities) do
                  if rail_entity and rail_entity.valid then
                     table.insert(result, FaInfo.ent_info(pindex, rail_entity))
                  end
               end
            end
         end
      else
         table.insert(result, FaInfo.ent_info(pindex, ent))
      end
      Graphics.draw_cursor_highlight(pindex, ent, nil)
      game.get_player(pindex).selected = ent
   end

   --Add info on whether the tile is uncharted or blurred or distant
   table.insert(result, Mouse.cursor_visibility_info(pindex))
   return result
end

return mod
