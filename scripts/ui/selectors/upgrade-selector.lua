local BoxSelector = require("scripts.ui.box-selector")
local Speech = require("scripts.speech")
local UiRouter = require("scripts.ui.router")

local mod = {}

-- Register box selector for upgrade planner area selection
mod.upgrade_area_selector = BoxSelector.declare_box_selector({
   ui_name = UiRouter.UI_NAMES.UPGRADE_AREA_SELECTOR,
   callback = function(pindex, params, result)
      local p = game.get_player(pindex)
      if not p then return end

      -- Get the planner item
      local planner = p.cursor_stack
      if not planner or not planner.valid_for_read or not planner.is_upgrade_item then
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

      -- Check if alt was held on the second click to determine if we're canceling
      local is_cancel = result.second_click.modifiers.alt

      if is_cancel then
         -- Alt was held - cancel upgrades
         p.surface.cancel_upgrade_area({
            area = area,
            force = p.force,
            player = p,
            item = planner,
         })
         Speech.speak(pindex, { "fa.planner-cancelled-upgrade" })
      else
         -- No alt - mark for upgrade
         p.surface.upgrade_area({
            area = area,
            force = p.force,
            player = p,
            item = planner,
         })
         Speech.speak(pindex, { "fa.planner-marked-for-upgrade" })
      end
   end,
})

UiRouter.register_ui(mod.upgrade_area_selector)

return mod
