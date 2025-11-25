--[[
Train interrupt selector UI.

Allows selecting a train interrupt from existing interrupts or typing a new one.
Returns the selected interrupt name to the parent UI.
]]

local OptionsSelector = require("scripts.ui.selectors.options-selector")
local Router = require("scripts.ui.router")
local TrainHelpers = require("scripts.rails.train-helpers")

local mod = {}

---Get train interrupt options for the selector
---@param pindex number
---@param parameters table
---@return fa.ui.selectors.OptionsResult
local function get_train_interrupt_options(pindex, parameters)
   local player = game.get_player(pindex)
   if not player then return { options = {} } end

   local options = {}

   -- Get existing interrupts and add them
   local interrupts = TrainHelpers.get_train_interrupts(player.force)
   for _, interrupt_name in ipairs(interrupts) do
      table.insert(options, {
         label = interrupt_name,
         value = interrupt_name,
      })
   end

   return { options = options }
end

-- Create and register the train interrupt selector UI
mod.interrupt_selector_ui = OptionsSelector.declare_options_selector({
   ui_name = Router.UI_NAMES.TRAIN_INTERRUPT_SELECTOR,
   title = { "fa.train-select-interrupt" },
   get_options = get_train_interrupt_options,
})

Router.register_ui(mod.interrupt_selector_ui)

return mod
