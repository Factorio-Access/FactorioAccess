local BoxSelector = require("scripts.ui.box-selector")
local Speech = require("scripts.speech")
local UiRouter = require("scripts.ui.router")

local mod = {}

-- Register box selector for blueprint area selection
mod.blueprint_area_selector = BoxSelector.declare_box_selector({
   ui_name = UiRouter.UI_NAMES.BLUEPRINT_AREA_SELECTOR,
   callback = function(pindex, params, result)
      local p = game.get_player(pindex)
      if not p then return end

      -- Get the blueprint item
      local blueprint = p.cursor_stack
      if not blueprint or not blueprint.valid_for_read or not blueprint.is_blueprint then
         Speech.speak(pindex, { "fa.planner-wrong-item" })
         return
      end

      -- Create the area from the box
      local area = {
         left_top = result.box.left_top,
         right_bottom = result.box.right_bottom,
      }

      -- Create blueprint from selected area
      blueprint.create_blueprint({
         surface = p.surface,
         force = p.force,
         area = area,
      })

      -- Provide feedback about what was captured
      local entity_count = blueprint.get_blueprint_entity_count()
      if entity_count > 0 then
         Speech.speak(pindex, { "fa.planner-blueprint-created", entity_count })
      else
         Speech.speak(pindex, { "fa.planner-blueprint-created-empty" })
      end
   end,
})

UiRouter.register_ui(mod.blueprint_area_selector)

return mod
