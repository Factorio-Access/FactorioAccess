--[[
Artillery configuration tab.

Provides controls for:
- Auto-targeting (fire automatically at enemies)
]]

local FormBuilder = require("scripts.ui.form-builder")
local UiKeyGraph = require("scripts.ui.key-graph")

local mod = {}

---Render the artillery configuration form
---@param ctx fa.ui.TabContext
---@return fa.ui.graph.Render?
local function render_artillery_config(ctx)
   local entity = ctx.tablist_shared_state.entity
   if not entity or not entity.valid then return nil end

   local form = FormBuilder.FormBuilder.new()

   -- Auto-targeting checkbox
   form:add_checkbox("auto_target", { "fa.artillery-auto-target" }, function()
      return entity.artillery_auto_targeting
   end, function(value)
      entity.artillery_auto_targeting = value
   end)

   return form:build()
end

-- Create the tab descriptor
mod.artillery_config_tab = UiKeyGraph.declare_graph({
   name = "artillery-config",
   title = { "fa.artillery-config-title" },
   render_callback = render_artillery_config,
})

---Check if this tab is available for the given entity
---@param entity LuaEntity
---@return boolean
function mod.is_available(entity)
   return entity.type == "artillery-turret" or entity.type == "artillery-wagon"
end

return mod
