--[[
Train group selector UI.

Allows selecting a train group from existing groups or typing a new one.
Returns the selected group name to the parent UI.
]]

local OptionsSelector = require("scripts.ui.selectors.options-selector")
local Router = require("scripts.ui.router")
local TrainHelpers = require("scripts.rails.train-helpers")

local mod = {}

---Get train group options for the selector
---@param pindex number
---@param parameters table
---@return fa.ui.selectors.OptionsResult
local function get_train_group_options(pindex, parameters)
   local player = game.get_player(pindex)
   if not player then return { options = {} } end

   local options = {}

   -- Add "no group" option first
   table.insert(options, {
      label = { "fa.train-no-group" },
      value = "",
   })

   -- Get existing groups and add them
   local groups = TrainHelpers.get_train_groups(player.force)
   for _, group_name in ipairs(groups) do
      table.insert(options, {
         label = group_name,
         value = group_name,
      })
   end

   return { options = options }
end

-- Create and register the train group selector UI
mod.group_selector_ui = OptionsSelector.declare_options_selector({
   ui_name = Router.UI_NAMES.TRAIN_GROUP_SELECTOR,
   title = { "fa.train-select-group" },
   get_options = get_train_group_options,
})

Router.register_ui(mod.group_selector_ui)

return mod
