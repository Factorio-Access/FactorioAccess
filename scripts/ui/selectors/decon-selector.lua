local BoxSelector = require("scripts.ui.box-selector")
local Speech = require("scripts.speech")
local UiRouter = require("scripts.ui.router")
local PlannerUtils = require("scripts.planner-utils")

local mod = {}

-- Register box selector for deconstruction planner area selection
mod.decon_area_selector = BoxSelector.declare_box_selector({
   ui_name = UiRouter.UI_NAMES.DECON_AREA_SELECTOR,
   get_binds = function(pindex, parameters)
      return { { kind = UiRouter.BIND_KIND.HAND_CONTENTS } }
   end,
   callback = function(pindex, params, result)
      local p = game.get_player(pindex)
      if not p then return end

      -- Get the planner item (direct or in book)
      local planner = PlannerUtils.get_decon_planner(pindex)
      if not planner then
         Speech.speak(pindex, { "fa.planner-wrong-item" })
         return
      end

      -- Create the area from the box. Careful! Positive y is south, and additionally if we grab the edges of the tiles
      -- sometimes this grabs entities outside the area. So, offset to the center of tiles.
      local area = {
         left_top = {
            x = math.floor(result.box.left_top.x) + 0.5,
            y = math.floor(result.box.left_top.y) + 0.5,
         },
         right_bottom = {
            x = math.ceil(result.box.right_bottom.x + 0.5) - 0.5,
            y = math.ceil(result.box.right_bottom.y + 0.5) - 0.5,
         },
      }

      -- Check if shift was held on the second click to determine if we're canceling
      local is_cancel = result.second_click.modifiers.shift

      if is_cancel then
         -- Alt was held - cancel deconstruction
         p.surface.cancel_deconstruct_area({
            area = area,
            force = p.force,
            player = p,
            item = planner,
         })
         Speech.speak(pindex, { "fa.planner-cancelled-deconstruction" })
      else
         -- No alt - mark for deconstruction
         p.surface.deconstruct_area({
            area = area,
            force = p.force,
            player = p,
            item = planner,
         })
         Speech.speak(pindex, { "fa.planner-marked-for-deconstruction" })
      end
   end,
})

UiRouter.register_ui(mod.decon_area_selector)

return mod
