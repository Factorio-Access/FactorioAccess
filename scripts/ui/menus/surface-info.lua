--[[
Surface information, from the mod menu: what the surface the player is on (or looks at in remote view) is like.
Read only.
]]

local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local FaUtils = require("scripts.fa-utils")
local Localising = require("scripts.localising")

local mod = {}

-- The game's units for these are symbols ("m/s²", "×") or an abbreviation a screen reader spells out.
local UNIT_OVERRIDES = {
   gravity = "fa.surface-info-gravity",
   pressure = "fa.surface-info-pressure",
   ["robot-energy-usage"] = "fa.surface-info-robot-energy-usage",
}

---@param value number
---@return string
local function format_value(value)
   return string.format("%.6g", value)
end

---@param surface LuaSurface
---@return LocalisedString
local function surface_name(surface)
   if surface.planet then return Localising.get_localised_name_with_fallback(surface.planet.prototype) end
   if surface.platform then return surface.platform.name end
   return Localising.get_localised_name_with_fallback(surface)
end

---"day", "dusk", "night" or "dawn". Daytime 0 is noon; darkness falls from dusk to evening and lifts from morning
---to dawn.
---@param surface LuaSurface
---@return string
local function day_phase(surface)
   local t = surface.daytime
   if t < surface.dusk then return "day" end
   if t < surface.evening then return "dusk" end
   if t < surface.morning then return "night" end
   if t < surface.dawn then return "dawn" end
   return "day"
end

---@param prototype LuaSurfacePropertyPrototype
---@param value number
---@return LocalisedString
local function property_value(prototype, value)
   if prototype.is_time then return FaUtils.format_time(value) end
   return { UNIT_OVERRIDES[prototype.name] or prototype.localised_unit_key, format_value(value) }
end

---@param ctx fa.ui.graph.Ctx
local function build_surface_info(ctx)
   local builder = Menu.MenuBuilder.new()
   local surface = game.get_player(ctx.pindex).surface

   builder:add_label("name", surface_name(surface))

   if surface.always_day then
      builder:add_label("daytime", { "fa.surface-info-always-day" })
   else
      builder:add_label("daytime", { "fa.surface-info-phase-" .. day_phase(surface) })
      builder:add_label("day_length", { "fa.surface-info-day-length", FaUtils.format_time(surface.ticks_per_day) })
   end

   -- Scripts can scale solar power on top of the surface's solar power property.
   if surface.solar_power_multiplier ~= 1 then
      builder:add_label(
         "solar_multiplier",
         { "fa.surface-info-solar-multiplier", format_value(surface.solar_power_multiplier * 100) }
      )
   end

   local properties = {}
   for _, prototype in pairs(prototypes.surface_property) do
      -- The day length above is the surface's live value.
      if prototype.name ~= "day-night-cycle" and not prototype.hidden then table.insert(properties, prototype) end
   end
   table.sort(properties, function(a, b)
      return a.order < b.order
   end)
   for _, prototype in ipairs(properties) do
      builder:add_label("property_" .. prototype.name, {
         "fa.surface-info-property",
         Localising.get_localised_name_with_fallback(prototype),
         property_value(prototype, surface.get_property(prototype.name)),
      })
   end

   local pollutant = surface.pollutant_type
   if pollutant then
      builder:add_label(
         "pollutant",
         { "fa.surface-info-pollutant", Localising.get_localised_name_with_fallback(pollutant) }
      )
   else
      builder:add_label("pollutant", { "fa.surface-info-no-pollution" })
   end

   return builder:build()
end

local surface_info_tab = KeyGraph.declare_graph({
   name = "surface_info",
   render_callback = build_surface_info,
   title = { "fa.surface-info-title" },
})

mod.surface_info = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.SURFACE_INFO,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "surface_info",
            tabs = { surface_info_tab },
         },
      }
   end,
})

UiRouter.register_ui(mod.surface_info)

return mod
