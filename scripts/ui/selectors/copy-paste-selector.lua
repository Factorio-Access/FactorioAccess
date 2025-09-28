local BoxSelector = require("scripts.ui.box-selector")
local Speech = require("scripts.speech")
local UiRouter = require("scripts.ui.router")

local mod = {}

-- Register box selector for copy area selection
mod.copy_paste_area_selector = BoxSelector.declare_box_selector({
   ui_name = UiRouter.UI_NAMES.COPY_PASTE_AREA_SELECTOR,
   callback = function(pindex, params, result)
      local p = game.get_player(pindex)
      if not p then return end

      -- Get the copy tool item
      local tool = p.cursor_stack
      if not tool or not tool.valid_for_read or tool.name ~= "copy-paste-tool" then
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

      -- Clear the copy tool and create a blueprint from the selected area
      p.clear_cursor()
      p.cursor_stack.set_stack({ name = "blueprint" })
      p.cursor_stack.create_blueprint({
         surface = p.surface,
         force = p.force,
         area = area,
      })

      -- Check if anything was captured
      if
         not (
            p.cursor_stack
            and p.cursor_stack.valid_for_read
            and p.cursor_stack.is_blueprint
            and p.cursor_stack.is_blueprint_setup()
         )
      then
         p.clear_cursor()
         p.cursor_stack.set_stack({ name = "copy-paste-tool" })
         Speech.speak(pindex, { "fa.planner-copy-empty" })
         return
      end

      -- Add to clipboard
      p.add_to_clipboard(p.cursor_stack)

      p.clear_cursor()
      p.activate_paste()

      -- Get entity count for feedback.  Needs to be after so that the blueprint is really in the cursor.
      local entity_count = p.cursor_stack.get_blueprint_entity_count()

      -- Provide feedback about what was captured
      if entity_count > 0 then
         Speech.speak(pindex, { "fa.planner-copy-created", entity_count })
      else
         Speech.speak(pindex, { "fa.planner-copy-created-empty" })
      end
   end,
})

UiRouter.register_ui(mod.copy_paste_area_selector)

return mod
