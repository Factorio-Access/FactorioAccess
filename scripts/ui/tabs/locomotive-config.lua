--[[
Locomotive configuration tab.

Provides a configuration form for locomotives with:
- Manual/automatic mode toggle
- Train name
]]

local FormBuilder = require("scripts.ui.form-builder")
local TrainHelpers = require("scripts.rails.train-helpers")
local UiKeyGraph = require("scripts.ui.key-graph")

local mod = {}

---@class fa.ui.LocomotiveTabContext: fa.ui.TabContext
---@field tablist_shared_state fa.ui.EntityUI.SharedState

---Render the locomotive configuration form
---@param ctx fa.ui.LocomotiveTabContext
---@return fa.ui.graph.Render?
local function render_locomotive_config(ctx)
   local entity = ctx.tablist_shared_state.entity
   if not entity or not entity.valid then return nil end
   assert(entity.type == "locomotive", "render: entity is not a locomotive")

   local train = entity.train
   if not train then return nil end

   local builder = FormBuilder.FormBuilder.new()

   -- Manual/automatic mode checkbox
   builder:add_checkbox("manual_mode", { "fa.locomotive-manual-mode" }, function()
      return train.manual_mode
   end, function(value)
      train.manual_mode = value
   end)

   -- Train name field
   builder:add_textfield("name", {
      label = { "fa.locomotive-train-name" },
      get_value = function()
         return TrainHelpers.get_name(entity)
      end,
      set_value = function(value)
         TrainHelpers.set_name(entity, value)
      end,
   })

   return builder:build()
end

-- Create the tab descriptor
mod.locomotive_config_tab = UiKeyGraph.declare_graph({
   name = "locomotive-config",
   title = { "fa.locomotive-config-title" },
   render_callback = render_locomotive_config,
})

return mod
