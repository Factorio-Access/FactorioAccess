--[[
Schedule stop selectors.

The train stop selector chooses train stops by station name. Supports filtering by surface and force.

Parameters:
- surface: SurfaceIdentification (optional) - Filter to show only stops on this surface
- force: ForceID (optional) - Filter to show only stops owned by this force

The space location selector chooses among the space locations the player's force has unlocked, the stations of a
space platform's schedule.

Both return the selected station name as a string (same shape as textbox results).
]]

local Localising = require("scripts.localising")
local OptionsSelector = require("scripts.ui.selectors.options-selector")
local Router = require("scripts.ui.router")

local mod = {}

---Get unique station names from train stops, sorted alphabetically
---@param force ForceID?
---@param surface SurfaceIdentification?
---@return string[]
local function get_unique_station_names(force, surface)
   local filter = {}
   if force then filter.force = force end
   if surface then filter.surface = surface end

   local stops = game.train_manager.get_train_stops(filter)

   local seen = {}
   local names = {}
   for _, stop in ipairs(stops) do
      local name = stop.backer_name
      if name and name ~= "" and not seen[name] then
         seen[name] = true
         table.insert(names, name)
      end
   end
   table.sort(names)
   return names
end

---Create and return the stop selector UI
mod.stop_selector = OptionsSelector.declare_options_selector({
   ui_name = Router.UI_NAMES.STOP_SELECTOR,
   title = { "fa.stop-selector-title" },
   get_options = function(pindex, parameters)
      local player = game.get_player(pindex)
      if not player then return { options = {} } end

      local force = (parameters and parameters.force) or player.force
      local surface = parameters and parameters.surface

      local names = get_unique_station_names(force, surface)

      local options = {}

      if #names == 0 then
         -- No stations found - add a placeholder that closes without selecting
         table.insert(options, {
            label = { "fa.stop-selector-no-stations" },
            value = nil,
         })
      else
         for _, name in ipairs(names) do
            table.insert(options, {
               label = name,
               value = name,
            })
         end
      end

      return { options = options }
   end,
})

Router.register_ui(mod.stop_selector)

mod.space_location_selector = OptionsSelector.declare_options_selector({
   ui_name = Router.UI_NAMES.SPACE_LOCATION_SELECTOR,
   title = { "fa.space-location-selector-title" },
   get_options = function(pindex)
      local force = game.get_player(pindex).force --[[@as LuaForce]]

      ---@type LuaSpaceLocationPrototype[]
      local locations = {}
      for name, location in pairs(prototypes.space_location) do
         -- The API docs omit this method's boolean return
         local unlocked = force.is_space_location_unlocked(name) --[[@as boolean]]
         if not location.hidden and unlocked then table.insert(locations, location) end
      end
      table.sort(locations, function(a, b)
         return a.order < b.order
      end)

      local options = {}
      for _, location in ipairs(locations) do
         table.insert(options, {
            label = Localising.get_localised_name_with_fallback(location),
            value = location.name,
         })
      end
      return { options = options }
   end,
})

Router.register_ui(mod.space_location_selector)

return mod
