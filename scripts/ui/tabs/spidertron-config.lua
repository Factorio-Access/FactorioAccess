--[[
Spidertron configuration tab.

Provides controls for:
- Renaming the spidertron
- Setting autopilot destinations
- Autotarget without gunner
- Autotarget with gunner
]]

local FormBuilder = require("scripts.ui.form-builder")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")
local UiSounds = require("scripts.ui.sounds")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

---Render the spidertron configuration form
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_spidertron_config(ctx)
   local entity = ctx.tablist_shared_state.entity
   if not entity or not entity.valid then return nil end

   local form = FormBuilder.FormBuilder.new()

   -- Row 1: Spidertron name (clickable to rename)
   form:add_textfield("name", {
      label = { "fa.spidertron-name" },
      get_value = function()
         return entity.entity_label or ""
      end,
      set_value = function(value)
         if value and value ~= "" then
            entity.entity_label = value
         else
            entity.entity_label = nil
         end
      end,
      on_clear = function(ctx)
         entity.entity_label = nil
         ctx.controller.message:fragment({ "fa.spidertron-name-cleared" })
      end,
   })

   -- Row 2: Autopilot destination selector
   form:add_item("autopilot", {
      label = function(ctx)
         local destinations = entity.autopilot_destinations
         if destinations and #destinations > 0 then
            local first = destinations[1]
            ctx.message:fragment({ "fa.spidertron-autopilot-destination" })
            ctx.message:fragment(tostring(math.floor(first.x)))
            ctx.message:fragment(tostring(math.floor(first.y)))
            if #destinations > 1 then
               ctx.message:fragment({ "fa.spidertron-autopilot-plus-more", tostring(#destinations - 1) })
            end
            ctx.message:fragment({ "fa.spidertron-autopilot-click-to-change" })
         else
            ctx.message:fragment({ "fa.spidertron-autopilot-none" })
         end
      end,
      on_click = function(ctx)
         ctx.controller:open_child_ui(UiRouter.UI_NAMES.SPIDERTRON_AUTOPILOT, { spidertron = entity }, "autopilot")
      end,
      on_clear = function(ctx)
         entity.autopilot_destination = nil
         ctx.controller.message:fragment({ "fa.spidertron-autopilot-cleared" })
      end,
   })

   -- Row 3: Autotarget without gunner
   local targeting = entity.vehicle_automatic_targeting_parameters
   form:add_checkbox("autotarget_without_gunner", { "fa.spidertron-autotarget-without-gunner" }, function()
      return entity.vehicle_automatic_targeting_parameters.auto_target_without_gunner
   end, function(value)
      local params = entity.vehicle_automatic_targeting_parameters
      params.auto_target_without_gunner = value
      entity.vehicle_automatic_targeting_parameters = params
   end)

   -- Row 4: Autotarget with gunner
   form:add_checkbox("autotarget_with_gunner", { "fa.spidertron-autotarget-with-gunner" }, function()
      return entity.vehicle_automatic_targeting_parameters.auto_target_with_gunner
   end, function(value)
      local params = entity.vehicle_automatic_targeting_parameters
      params.auto_target_with_gunner = value
      entity.vehicle_automatic_targeting_parameters = params
   end)

   return form:build()
end

-- Create the tab descriptor
mod.spidertron_config_tab = UiKeyGraph.declare_graph({
   name = "spidertron-config",
   title = { "fa.spidertron-config-title" },
   render_callback = render_spidertron_config,
})

---Check if this tab is available for the given entity
---@param entity LuaEntity
---@return boolean
function mod.is_available(entity)
   return entity.type == "spider-vehicle"
end

return mod
