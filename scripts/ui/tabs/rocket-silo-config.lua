--[[
Rocket silo configuration tab.

Provides controls for:
- Rocket parts progress (read-only label)
- Automation: send to orbit automatically, or with space travel automatic requests from space platforms
- With space travel, launching by hand to each platform in orbit: delivering the cargo, or riding the rocket
]]

local FormBuilder = require("scripts.ui.form-builder")
local Speech = require("scripts.speech")
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

---The force's platforms the silo can launch to: built and stopped over the silo's planet.
---@param entity LuaEntity
---@return LuaSpacePlatform[]
function mod.platforms_in_orbit(entity)
   local planet = entity.surface.planet
   local result = {}
   if not planet then return result end
   local force = entity.force --[[@as LuaForce]]
   for _, platform in pairs(force.platforms) do
      local location = platform.space_location
      if platform.hub and platform.scheduled_for_deletion == 0 and location and location.name == planet.name then
         table.insert(result, platform)
      end
   end
   return result
end

---Why the game's GUI would refuse a manual launch, if it would.
---@param entity LuaEntity
---@return LocalisedString?
local function launch_refusal(entity)
   if entity.rocket_silo_status ~= defines.rocket_silo_status.rocket_ready then
      return { "gui-rocket-silo.rocket-is-not-ready" }
   end
   return nil
end

---@param entity LuaEntity
---@param platform LuaSpacePlatform
---@param character LuaEntity?
---@param message fa.MessageBuilder
---@return boolean launched
local function launch_to_platform(entity, platform, character, message)
   local destination = { type = defines.cargo_destination.station, station = assert(platform.hub) }
   if not entity.launch_rocket(destination, character) then
      message:fragment({ "fa.not-ready-to-launch" })
      return false
   end
   message:fragment({ character and "fa.rocket-silo-travelling-to" or "fa.rocket-silo-launching-to", platform.name })
   return true
end

---Send the rocket's cargo to a platform, like the game's "Deliver cargo" button.
---@param entity LuaEntity
---@param platform LuaSpacePlatform
---@param message fa.MessageBuilder
---@return boolean launched
function mod.deliver_cargo(entity, platform, message)
   local refusal = launch_refusal(entity)
   if not refusal and assert(entity.get_inventory(defines.inventory.rocket_silo_rocket)).is_empty() then
      refusal = { "gui-rocket-silo.cant-send-empty-rocket" }
   end
   if refusal then
      message:fragment(refusal)
      return false
   end
   return launch_to_platform(entity, platform, nil, message)
end

local CARRIED_INVENTORIES = {
   defines.inventory.character_main,
   defines.inventory.character_trash,
   defines.inventory.character_ammo,
}

---Ride the rocket to a platform, like the game's "Travel to space platform" button: not from remote view, and
---carrying nothing but armor and guns.
---@param entity LuaEntity
---@param platform LuaSpacePlatform
---@param player LuaPlayer
---@param message fa.MessageBuilder
---@return boolean launched
function mod.travel_to_platform(entity, platform, player, message)
   local refusal = launch_refusal(entity)
   local character = player.character
   if not refusal and (player.controller_type ~= defines.controllers.character or not character) then
      refusal = { "gui-rocket-silo.cant-travel-remotely" }
   end
   if not refusal then
      ---@cast character LuaEntity
      local carrying = player.cursor_stack.valid_for_read
      for _, index in ipairs(CARRIED_INVENTORIES) do
         carrying = carrying or not assert(character.get_inventory(index)).is_empty()
      end
      if carrying then refusal = { "fa.rocket-silo-cant-travel-with-items" } end
   end
   if refusal then
      message:fragment(refusal)
      return false
   end
   return launch_to_platform(entity, platform, character, message)
end

---The manual launch key with space travel: deliver the cargo when exactly one platform is in orbit. Choosing among
---several, and riding the rocket, are in the silo's menu.
---@param entity LuaEntity
---@param pindex integer
function mod.launch_by_key(entity, pindex)
   local message = Speech.MessageBuilder.new()
   local platforms = mod.platforms_in_orbit(entity)
   if #platforms == 0 then
      message:fragment({ "gui-rocket-silo.no-valid-destination-platforms" })
   elseif #platforms > 1 then
      message:fragment({ "fa.rocket-silo-choose-platform", #platforms })
   else
      mod.deliver_cargo(entity, platforms[1], message)
   end
   Speech.speak(pindex, message:build())
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

   if script.feature_flags.space_travel then
      local player = assert(game.get_player(ctx.pindex))
      local travel_unlocked = (player.force --[[@as LuaForce]]).unlock_travel_to_space_platforms
      local platforms = mod.platforms_in_orbit(entity)
      if #platforms == 0 then form:add_label("no_platforms", { "gui-rocket-silo.no-valid-destination-platforms" }) end
      for _, platform in ipairs(platforms) do
         local key = "platform_" .. platform.index
         form:start_row(key)
         form:add_action(key .. "_deliver", { "fa.rocket-silo-deliver-cargo-to", platform.name }, function(controller)
            mod.deliver_cargo(entity, platform, controller.message)
         end)
         if travel_unlocked then
            form:add_action(key .. "_travel", { "fa.rocket-silo-travel-to", platform.name }, function(controller)
               if mod.travel_to_platform(entity, platform, player, controller.message) then controller:close() end
            end)
         end
         form:end_row()
      end
   end

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
