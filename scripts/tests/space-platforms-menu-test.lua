--[[
Smoke test for the space platform menus: each renders. Runs only with space travel.
]]

local TestRegistry = require("scripts.test-registry")
local UiRouter = require("scripts.ui.router")
local describe, it = TestRegistry.describe, TestRegistry.it

describe("Space platform menus", function()
   it("open the list, a platform and the new platform form", function(ctx)
      if not script.feature_flags.space_travel then return end
      ---@type LuaSpacePlatform
      local platform

      ctx:init(function()
         local force = game.forces.player
         force.unlock_space_platforms()
         platform =
            assert(force.create_space_platform({ planet = "nauvis", starter_pack = "space-platform-starter-pack" }))
      end)

      ctx:at_tick(2, function()
         local router = UiRouter.get_router(1)
         router:open_ui(UiRouter.UI_NAMES.SPACE_PLATFORMS)
         ctx:assert(router:is_ui_open(UiRouter.UI_NAMES.SPACE_PLATFORMS), "list open")
         router:close_ui()
         router:open_ui(UiRouter.UI_NAMES.SPACE_PLATFORM, { platform = platform })
         ctx:assert(router:is_ui_open(UiRouter.UI_NAMES.SPACE_PLATFORM), "platform open")
         router:close_ui()
         router:open_ui(UiRouter.UI_NAMES.NEW_SPACE_PLATFORM)
         ctx:assert(router:is_ui_open(UiRouter.UI_NAMES.NEW_SPACE_PLATFORM), "new platform open")
         router:close_ui()
         platform.destroy(0)
      end)
   end)
end)
