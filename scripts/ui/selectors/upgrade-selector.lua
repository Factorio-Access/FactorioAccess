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

      -- Create the area from the box
      local area = {
         left_top = result.box.left_top,
         right_bottom = result.box.right_bottom,
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