local TestRegistry = require("scripts.test-registry")
local BuildingTools = require("scripts.building-tools")
local Viewpoint = require("scripts.viewpoint")
local describe, it = TestRegistry.describe, TestRegistry.it

---@param s LocalisedString
---@return boolean
local function mentions_out_of_reach(s)
   if type(s) ~= "table" then return false end
   for _, part in pairs(s) do
      if part == "fa.connection-cursor-out-of-reach" or mentions_out_of_reach(part) then return true end
   end
   return false
end

describe("Building preview reach", function()
   it("measures reach to the nearest edge of the building", function(ctx)
      ctx:init(function()
         local player = assert(game.get_player(1))
         local vp = Viewpoint.get_viewpoint(1)
         local player_pos = player.position --[[@as MapPosition.struct]]
         local px = math.floor(player_pos.x)
         local py = math.floor(player_pos.y)
         local cursor = assert(player.cursor_stack)
         -- The cursor is the building's top-left corner. East of the player the near edge is the cursor column; west
         -- of the player it is the building's east side.
         local cases = {
            { "assembling-machine", 10, false },
            { "assembling-machine", 11, true },
            { "assembling-machine", -13, false },
            { "assembling-machine", -14, true },
            { "oil-refinery", 10, false },
            { "oil-refinery", 11, true },
            { "oil-refinery", -15, false },
            { "oil-refinery", -16, true },
         }
         for _, c in ipairs(cases) do
            local item = c[1] == "assembling-machine" and "assembling-machine-1" or c[1]
            cursor.set_stack({ name = item, count = 1 })
            vp:set_cursor_pos({ x = px + c[2], y = py })
            local out = mentions_out_of_reach(BuildingTools.build_preview_checks_info(cursor, 1))
            ctx:assert_equals(c[3], out, string.format("%s with the cursor %d tiles east", item, c[2]))
         end
         cursor.clear()
      end)
   end)
end)
