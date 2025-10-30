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

      -- Create the area from the box Careful! Positive y is south, and additionally if we grab the edges of the tiles
      -- sometimes this grabs entities outside the blueprint. SO, offset to the center of tiles.
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

      -- Create blueprint from selected area
      blueprint.create_blueprint({
         surface = p.surface,
         force = p.force,
         area = area,
      })

      -- If permanent param is set, mark the blueprint as permanent
      if params and params.permanent then p.cursor_stack_temporary = false end

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
