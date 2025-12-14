--[[
Splitter configuration tab.

Provides controls for:
- Output priority (left/right/unset) with filter support
- Input priority (left/right/unset)

Key bindings within this tab:
- M: Set priority to left
- Comma: Clear (clears filter and priority for output, just priority for input)
- Dot: Set priority to right
- Click on output priority: Open item chooser to set filter (only if output priority is set)
- Backspace on output priority: Clear filter
]]

local ItemInfo = require("scripts.item-info")
local Localising = require("scripts.localising")
local Menu = require("scripts.ui.menu")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")
local UiSounds = require("scripts.ui.sounds")

local mod = {}

---Get the display text for a priority value
---@param priority "left"|"none"|"right"
---@return LocalisedString
local function priority_to_text(priority)
   if priority == "left" then
      return { "fa.splitter-priority-left" }
   elseif priority == "right" then
      return { "fa.splitter-priority-right" }
   else
      return { "fa.splitter-priority-none" }
   end
end

---Render the splitter configuration form
---@param ctx fa.ui.TabContext
---@return fa.ui.graph.Render?
local function render_splitter_config(ctx)
   -- Belt analyzer uses global_parameters.entity, entity-ui uses tablist_shared_state.entity
   local entity = (ctx.global_parameters and ctx.global_parameters.entity)
      or (ctx.tablist_shared_state and ctx.tablist_shared_state.entity)
   if not entity or not entity.valid then return nil end

   local builder = Menu.MenuBuilder.new()

   -- Output priority row
   builder:add_item("output_priority", {
      label = function(label_ctx)
         local priority = entity.splitter_output_priority
         local filter = entity.splitter_filter

         label_ctx.message:fragment(priority_to_text(priority))
         label_ctx.message:fragment({ "fa.splitter-output-priority-label" })

         if filter and filter.name then
            local item_name = Localising.get_localised_name_with_fallback(prototypes.item[filter.name])
            label_ctx.message:fragment({ "fa.splitter-filter-label", item_name })
         end

         label_ctx.message:fragment({ "fa.splitter-output-help" })
      end,
      on_click = function(click_ctx)
         -- Only allow setting filter if output priority is set
         local priority = entity.splitter_output_priority
         if priority == "none" then
            UiSounds.play_ui_edge(click_ctx.pindex)
            click_ctx.controller.message:fragment({ "fa.splitter-set-priority-first" })
            return
         end

         -- Open item chooser
         click_ctx.controller:open_child_ui(UiRouter.UI_NAMES.ITEM_CHOOSER, {}, { node = "output_priority" })
      end,
      on_child_result = function(result_ctx, result)
         if result then
            entity.splitter_filter = { name = result }
            local item_name = Localising.get_localised_name_with_fallback(prototypes.item[result])
            result_ctx.controller.message:fragment({ "fa.splitter-filter-set-to", item_name })
         end
      end,
      on_clear = function(clear_ctx)
         -- Clear filter only
         entity.splitter_filter = nil
         clear_ctx.controller.message:fragment({ "fa.splitter-filter-cleared" })
      end,
      -- M key: set to left
      on_action1 = function(action_ctx)
         entity.splitter_output_priority = "left"
         UiSounds.play_menu_move(action_ctx.pindex)
         action_ctx.controller.message:fragment(priority_to_text("left"))
      end,
      -- Comma key: clear both filter and priority
      on_action2 = function(action_ctx)
         entity.splitter_output_priority = "none"
         entity.splitter_filter = nil
         UiSounds.play_menu_move(action_ctx.pindex)
         action_ctx.controller.message:fragment({ "fa.splitter-output-cleared" })
      end,
      -- Dot key: set to right
      on_action3 = function(action_ctx)
         entity.splitter_output_priority = "right"
         UiSounds.play_menu_move(action_ctx.pindex)
         action_ctx.controller.message:fragment(priority_to_text("right"))
      end,
   })

   -- Input priority row
   builder:add_item("input_priority", {
      label = function(label_ctx)
         local priority = entity.splitter_input_priority

         label_ctx.message:fragment(priority_to_text(priority))
         label_ctx.message:fragment({ "fa.splitter-input-priority-label" })
         label_ctx.message:fragment({ "fa.splitter-input-help" })
      end,
      -- M key: set to left
      on_action1 = function(action_ctx)
         entity.splitter_input_priority = "left"
         UiSounds.play_menu_move(action_ctx.pindex)
         action_ctx.controller.message:fragment(priority_to_text("left"))
      end,
      -- Comma key: clear priority
      on_action2 = function(action_ctx)
         entity.splitter_input_priority = "none"
         UiSounds.play_menu_move(action_ctx.pindex)
         action_ctx.controller.message:fragment(priority_to_text("none"))
      end,
      -- Dot key: set to right
      on_action3 = function(action_ctx)
         entity.splitter_input_priority = "right"
         UiSounds.play_menu_move(action_ctx.pindex)
         action_ctx.controller.message:fragment(priority_to_text("right"))
      end,
   })

   return builder:build()
end

-- Create the tab descriptor
mod.splitter_config_tab = UiKeyGraph.declare_graph({
   name = "splitter-config",
   title = { "fa.splitter-config-title" },
   render_callback = render_splitter_config,
})

---Check if this tab is available for the given entity
---@param entity LuaEntity
---@return boolean
function mod.is_available(entity)
   return entity.type == "splitter" or entity.type == "lane-splitter"
end

return mod
