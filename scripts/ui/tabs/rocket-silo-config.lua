--[[
Rocket silo configuration tab.

Provides controls for:
- Rocket parts progress (read-only label)
- Automation: send to orbit automatically, or with space travel automatic requests from space platforms
]]

local FormBuilder = require("scripts.ui.form-builder")
local UiKeyGraph = require("scripts.ui.key-graph")

local mod = {}

---@class fa.ui.RocketSiloAutomation
---@field label LocalisedString
---@field get fun(): boolean
---@field set fun(value: boolean)

---The silo's automation checkbox, as the game's GUI shows it: with space travel the silo fulfils platform
---requests and the checkbox is automatic requests; otherwise it is sending to orbit automatically.
---@param entity LuaEntity
---@return fa.ui.RocketSiloAutomation
function mod.automation_setting(entity)
   if script.feature_flags.space_travel then
      return {
         label = { "gui.controlled-by-transitional-requests" },
         get = function()
            return entity.use_transitional_requests
         end,
         set = function(value)
            entity.use_transitional_requests = value
         end,
      }
   end
   return {
      label = { "gui-rocket-silo.send-to-orbit-automatically" },
      get = function()
         return entity.send_to_orbit_automatically
      end,
      set = function(value)
         entity.send_to_orbit_automatically = value
      end,
   }
end

---Render the rocket silo configuration form
---@param ctx fa.ui.graph.Ctx
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

   local automation = mod.automation_setting(entity)
   form:add_checkbox("automation", automation.label, automation.get, automation.set)

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
