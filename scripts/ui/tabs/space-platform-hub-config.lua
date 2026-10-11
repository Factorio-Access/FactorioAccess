--[[
Space platform hub configuration tab.

Reads the platform's status, and provides controls for:
- Auto requesting missing construction materials
- Providing materials to other platforms
- Editing the platform's schedule
- Dropping to the planet below, for a player in this hub
]]

local FormBuilder = require("scripts.ui.form-builder")
local Localising = require("scripts.localising")
local PlatformTravel = require("scripts.platform-travel")
local Router = require("scripts.ui.router")
local UiKeyGraph = require("scripts.ui.key-graph")

local mod = {}

---Render the space platform hub configuration form
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_hub_config(ctx)
   local entity = ctx.tablist_shared_state.entity
   if not entity or not entity.valid then return nil end

   local form = FormBuilder.FormBuilder.new()
   local platform = assert(entity.surface.platform)

   form:add_label("status", function(label_ctx)
      PlatformTravel.describe(platform, label_ctx.message)
   end)

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

   form:add_action("edit_schedule", { "fa.locomotive-edit-schedule" }, function(controller)
      controller:open_child_ui(Router.UI_NAMES.SCHEDULE_EDITOR, { entity = entity })
   end)

   local player = assert(game.get_player(ctx.pindex))
   if player.hub == entity then
      local planet = PlatformTravel.orbited_planet(platform)
      local label = planet and { "fa.platform-drop-to", Localising.get_localised_name_with_fallback(planet) }
         or { "fa.platform-drop-to-a-planet" }
      form:add_action("drop_to_planet", label, function(controller)
         if PlatformTravel.drop_to_planet(player, controller.message) then controller:close() end
      end)
   end

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
