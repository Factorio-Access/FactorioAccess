--[[
Train stop configuration tab.

Provides a configuration form for train stops with:
- Name (backer_name)
- Train limit (trains_limit)
- Priority (train_stop_priority)
- Trains count (read-only, informational)
]]

local FormBuilder = require("scripts.ui.form-builder")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiSounds = require("scripts.ui.sounds")

local mod = {}

---@class fa.ui.TrainStopTabContext: fa.ui.TabContext
---@field tablist_shared_state fa.ui.EntityUI.SharedState

---Render the train stop configuration form
---@param ctx fa.ui.TrainStopTabContext
---@return fa.ui.graph.Render?
local function render_train_stop_config(ctx)
   local entity = ctx.tablist_shared_state.entity
   if not entity or not entity.valid then return nil end
   assert(entity.type == "train-stop", "render: entity is not a train-stop")

   local builder = FormBuilder.FormBuilder.new()

   -- Name field with rich text support
   builder:add_rich_textfield("name", {
      label = { "fa.train-stop-name" },
      get_value = function()
         return entity.backer_name or ""
      end,
      set_value = function(value)
         entity.backer_name = value
      end,
      validate = function(value)
         if not value or value == "" then return false, { "fa.train-stop-name-cannot-be-empty" } end
         return true
      end,
   })

   -- Priority field
   builder:add_item("priority", {
      label = function(ctx)
         local priority = entity.train_stop_priority or 50
         ctx.message:fragment({ "fa.train-stop-priority" })
         ctx.message:fragment(tostring(priority))
      end,
      on_click = function(ctx)
         ctx.controller:open_textbox("", "priority")
      end,
      on_child_result = function(ctx, result)
         local num = tonumber(result)
         if num and num >= 0 and num <= 255 and math.floor(num) == num then
            entity.train_stop_priority = num
            ctx.controller.message:fragment(tostring(num))
         else
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.train-stop-priority-invalid" })
         end
      end,
      on_clear = function(ctx)
         entity.train_stop_priority = 50
         ctx.controller.message:fragment("50")
      end,
   })

   -- Train limit field
   builder:add_item("limit", {
      label = function(ctx)
         local limit = entity.trains_limit
         ctx.message:fragment({ "fa.train-stop-limit" })
         -- 4294967295 is the max uint32 value, used to represent "unlimited"
         if not limit or limit == 4294967295 then
            ctx.message:fragment({ "fa.train-stop-limit-disabled" })
         else
            ctx.message:fragment(tostring(limit))
         end
      end,
      on_click = function(ctx)
         ctx.controller:open_textbox("", "limit")
      end,
      on_child_result = function(ctx, result)
         local num = tonumber(result)
         if num and num >= 0 and math.floor(num) == num then
            entity.trains_limit = num
            ctx.controller.message:fragment(tostring(num))
         else
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.train-stop-limit-invalid" })
         end
      end,
      on_clear = function(ctx)
         -- Set to max uint32 value to represent "unlimited"
         entity.trains_limit = 4294967295
         ctx.controller.message:fragment({ "fa.train-stop-limit-disabled" })
      end,
   })

   -- Trains count (read-only informational field)
   builder:add_label("trains_count", function(ctx)
      local count = entity.trains_count or 0
      ctx.message:fragment({ "fa.train-stop-trains-incoming" })
      ctx.message:fragment(tostring(count))
   end)

   return builder:build()
end

-- Create the tab descriptor
mod.train_stop_tab = UiKeyGraph.declare_graph({
   name = "train-stop-config",
   title = { "fa.train-stop-config-title" },
   render_callback = render_train_stop_config,
})

return mod
