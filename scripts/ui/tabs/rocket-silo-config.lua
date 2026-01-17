--[[
Rocket silo configuration tab.

Provides controls for:
- Rocket parts progress (read-only label)
- Auto-launch setting
]]

local FormBuilder = require("scripts.ui.form-builder")
local UiKeyGraph = require("scripts.ui.key-graph")

local mod = {}

---Render the rocket silo configuration form
---@param ctx fa.ui.TabContext
---@return fa.ui.graph.Render?
local function render_rocket_silo_config(ctx)
   local entity = ctx.tablist_shared_state.entity
   if not entity or not entity.valid then return nil end

   local form = FormBuilder.FormBuilder.new()

   -- Rocket parts progress label
   form:add_label("rocket_parts", function(ctx)
      local parts = entity.rocket_parts
      local max_parts = entity.prototype.rocket_parts_required
      ctx.message:fragment({ "fa.rocket-silo-parts-progress", parts, max_parts })
   end)

   -- Auto-launch checkbox
   form:add_checkbox("auto_launch", { "fa.rocket-silo-auto-launch" }, function()
      return entity.send_to_orbit_automatically
   end, function(value)
      entity.send_to_orbit_automatically = value
   end)

   return form:build()
end

-- Create the tab descriptor
mod.rocket_silo_config_tab = UiKeyGraph.declare_graph({
   name = "rocket-silo-config",
   title = { "fa.rocket-silo-config-title" },
   render_callback = render_rocket_silo_config,
})

---Check if this tab is available for the given entity
---@param entity LuaEntity
---@return boolean
function mod.is_available(entity)
   return entity.type == "rocket-silo"
end

return mod
