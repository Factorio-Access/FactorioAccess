--[[
Schedule interrupt selector UI.

Selects an interrupt from the names the opener passes (parameter interrupt_names: string[]), those of the force's
trains or of its space platforms.
Returns the selected interrupt name to the parent UI.
]]

local OptionsSelector = require("scripts.ui.selectors.options-selector")
local Router = require("scripts.ui.router")

local mod = {}

---Get interrupt options for the selector
---@param pindex integer
---@param parameters { interrupt_names: string[] }
---@return fa.ui.selectors.OptionsResult
local function get_train_interrupt_options(pindex, parameters)
   local options = {}

   for _, interrupt_name in ipairs(parameters.interrupt_names) do
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
