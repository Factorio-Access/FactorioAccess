--[[
Alerts UI tabs for the world menu.

Structure:
- Overview tab: shows count per alert type, click to mute/unmute
- One tab per alert type that has alerts and is not muted
]]

local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local Alerts = require("scripts.alerts")
local Viewpoint = require("scripts.viewpoint")
local TileReader = require("scripts.tile-reader")
local UiSounds = require("scripts.ui.sounds")

local mod = {}

-- Cache for alert type renderers
local renderer_cache = {}

---Build the overview tab showing alert counts per type
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render
local function render_overview(ctx)
   local builder = Menu.MenuBuilder.new()
   local player = game.get_player(ctx.pindex)
   if not player then return builder:add_label("error", { "fa.alerts-error" }):build() end

   local counts = Alerts.get_alert_counts(ctx.pindex)

   -- Get all alert types that have alerts
   local active_types = {}
   for alert_type, count in pairs(counts) do
      if count > 0 then table.insert(active_types, alert_type) end
   end

   if #active_types == 0 then
      builder:add_label("no-alerts", { "fa.alerts-none" })
      return builder:build()
   end

   -- Sort by type name
   table.sort(active_types, function(a, b)
      return Alerts.get_alert_type_name(a) < Alerts.get_alert_type_name(b)
   end)

   for _, alert_type in ipairs(active_types) do
      -- Custom alerts are handled specially - group by message
      if alert_type == defines.alert_type.custom then
         local custom_groups = Alerts.get_custom_alerts_by_message(ctx.pindex)
         for i, group in ipairs(custom_groups) do
            builder:add_clickable("custom-" .. i, function(label_ctx)
               -- Custom alert message with count first
               label_ctx.message:fragment(group.message)
               if group.count > 1 then label_ctx.message:fragment("x " .. group.count) end
               -- Then muted/unmuted state
               if player.is_alert_muted(alert_type) then
                  label_ctx.message:fragment({ "fa.alerts-muted" })
               else
                  label_ctx.message:fragment({ "fa.alerts-unmuted" })
               end
            end, {
               on_click = function(click_ctx)
                  local is_muted = player.is_alert_muted(alert_type)
                  if is_muted then
                     player.unmute_alert(alert_type)
                     click_ctx.message:fragment({ "fa.alerts-unmuted" })
                  else
                     player.mute_alert(alert_type)
                     click_ctx.message:fragment({ "fa.alerts-muted" })
                  end
                  UiSounds.play_menu_move(ctx.pindex)
               end,
            })
         end
      else
         local count = counts[alert_type]
         local type_name = Alerts.get_alert_type_name(alert_type)

         builder:add_clickable("type-" .. type_name, function(label_ctx)
            -- Alert description with count first
            local locale_key = Alerts.get_alert_locale_key(alert_type)
            label_ctx.message:fragment({ "gui-alert-tooltip." .. locale_key, count })
            -- Then muted/unmuted state
            if player.is_alert_muted(alert_type) then
               label_ctx.message:fragment({ "fa.alerts-muted" })
            else
               label_ctx.message:fragment({ "fa.alerts-unmuted" })
            end
         end, {
            on_click = function(click_ctx)
               local is_muted = player.is_alert_muted(alert_type)
               if is_muted then
                  player.unmute_alert(alert_type)
                  click_ctx.message:fragment({ "fa.alerts-unmuted" })
               else
                  player.mute_alert(alert_type)
                  click_ctx.message:fragment({ "fa.alerts-muted" })
               end
               UiSounds.play_menu_move(ctx.pindex)
            end,
         })
      end
   end

   return builder:build()
end

---Get or create a renderer for a specific alert type
---@param alert_type defines.alert_type
---@return fun(ctx: fa.ui.graph.Ctx): fa.ui.graph.Render
local function get_alert_type_renderer(alert_type)
   if renderer_cache[alert_type] then return renderer_cache[alert_type] end

   local renderer = function(ctx)
      local builder = Menu.MenuBuilder.new()
      local player = game.get_player(ctx.pindex)
      if not player then return builder:add_label("error", { "fa.alerts-error" }):build() end

      local alerts_by_type = Alerts.get_alerts_by_type(ctx.pindex)
      local alerts = alerts_by_type[alert_type] or {}

      if #alerts == 0 then
         builder:add_label("no-alerts", { "fa.alerts-none" })
         return builder:build()
      end

      for _, entry in ipairs(alerts) do
         local alert = entry.alert

         builder:add_clickable(entry.dedup_key, function(label_ctx)
            Alerts.read_alert_to_msgbuilder(label_ctx.message, alert, alert_type)
         end, {
            on_click = function(click_ctx)
               local target = Alerts.get_alert_target(alert)
               if not target then
                  click_ctx.message:fragment({ "fa.alerts-no-target" })
                  UiSounds.play_ui_edge(ctx.pindex)
                  return
               end

               -- Get position from target
               local pos
               if Alerts.target_is_entity(target) then
                  ---@cast target LuaEntity
                  if not target.valid then
                     click_ctx.message:fragment({ "fa.alerts-target-invalid" })
                     UiSounds.play_ui_edge(ctx.pindex)
                     return
                  end
                  pos = target.position
               else
                  ---@cast target MapPosition
                  pos = target
               end

               -- Move cursor to target
               local vp = Viewpoint.get_viewpoint(ctx.pindex)
               vp:set_cursor_pos(pos)

               -- Close the UI
               click_ctx.controller:close()

               -- Read the tile
               TileReader.read_tile(ctx.pindex)
            end,
         })
      end

      return builder:build()
   end

   renderer_cache[alert_type] = renderer
   return renderer
end

-- Overview tab declaration
mod.overview_tab = KeyGraph.declare_graph({
   name = "alerts_overview",
   title = { "fa.alerts-overview-title" },
   render_callback = render_overview,
})

---Build tabs for the alerts section dynamically
---@param pindex number
---@return fa.ui.TabDescriptor[]
function mod.build_alert_tabs(pindex)
   local tabs = { mod.overview_tab }

   local player = game.get_player(pindex)
   if not player then return tabs end

   -- Get alert types that have alerts and are not muted
   local active_types = Alerts.get_active_alert_types(pindex, false)

   for _, alert_type in ipairs(active_types) do
      local type_name = Alerts.get_alert_type_name(alert_type)

      -- Create a dynamic tab for this alert type
      local tab = KeyGraph.declare_graph({
         name = "alerts_" .. type_name,
         title = Alerts.get_alert_type_name_localised(alert_type),
         render_callback = get_alert_type_renderer(alert_type),
      })

      table.insert(tabs, tab)
   end

   return tabs
end

return mod
