local TestRegistry = require("scripts.test-registry")
local RemoteView = require("scripts.remote-view")
local Speech = require("scripts.speech")
local Viewpoint = require("scripts.viewpoint")
local describe, it = TestRegistry.describe, TestRegistry.it

---@param messages { message: LocalisedString }[]
---@return string
local function keys(messages)
   local out = {}
   for _, m in ipairs(messages) do
      table.insert(out, type(m.message) == "table" and m.message[1] or tostring(m.message))
   end
   return table.concat(out, ",")
end

describe("Remote view", function()
   it("toggles at the cursor and says so, unless told to be quiet", function(ctx)
      ---@type LuaPlayer
      local player
      ---@type MapPosition.struct
      local start
      ctx:init(function()
         player = assert(game.get_player(1))
         start = player.position --[[@as MapPosition.struct]]
         Viewpoint.get_viewpoint(1):set_cursor_pos({ x = start.x + 12, y = start.y })
         Speech.start_capture()
         RemoteView.toggle(1)
      end)
      ctx:at_tick(2, function()
         ctx:assert_equals(defines.controllers.remote, player.controller_type, "in remote view")
         ctx:assert_equals(start.x + 12, player.position.x, "at the cursor")
         RemoteView.toggle(1)
      end)
      ctx:at_tick(4, function()
         ctx:assert_equals(defines.controllers.character, player.controller_type, "back")
         ctx:assert_equals(start.x, Viewpoint.get_viewpoint(1):get_cursor_pos().x, "the cursor is on the character")
         ctx:assert_equals("fa.remote-view-entered,fa.remote-view-left", keys(Speech.stop_capture()), "announced")
         Speech.start_capture()
         RemoteView.quietly(1, function()
            player.set_controller({ type = defines.controllers.remote, surface = player.surface, position = start })
         end)
      end)
      ctx:at_tick(6, function()
         ctx:assert_equals("", keys(Speech.stop_capture()), "quiet")
         player.exit_remote_view()
      end)
   end)
end)
