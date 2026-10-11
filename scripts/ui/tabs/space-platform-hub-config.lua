--[[
Space platform hub configuration tab.

Provides controls for:
- Auto requesting missing construction materials
- Providing materials to other platforms
]]

local FormBuilder = require("scripts.ui.form-builder")
local UiKeyGraph = require("scripts.ui.key-graph")

local mod = {}

---Render the space platform hub configuration form
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_hub_config(ctx)
   local entity = ctx.tablist_shared_state.entity
   if not entity or not entity.valid then return nil end

   local form = FormBuilder.FormBuilder.new()

   form:add_checkbox(
      "request_missing_construction_materials",
      { "gui-space.request-missing-construction-materials" },
      function()
         return entity.request_missing_construction_materials
      end,
      function(value)
         entity.request_missing_construction_materials = value
      end
   )

   form:add_checkbox("providing_to_other_platforms", { "gui-space.allow-providing-to-other-platforms" }, function()
      return entity.providing_to_other_platforms
   end, function(value)
      entity.providing_to_other_platforms = value
   end)

   return form:build()
end

mod.space_platform_hub_config_tab = UiKeyGraph.declare_graph({
   name = "space-platform-hub-config",
   title = { "fa.space-platform-hub-config-title" },
   render_callback = render_hub_config,
})

---Check if this tab is available for the given entity
---@param entity LuaEntity
---@return boolean
function mod.is_available(entity)
   return entity.type == "space-platform-hub"
end

return mod
