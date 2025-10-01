---UI for setting the search pattern.
---Opens a simple textbox and stores the result in the router's search state.
local UiRouter = require("scripts.ui.router")
local Speech = require("scripts.speech")

local mod = {}

---@type fa.ui.UiPanelBase
local search_setter_ui = {
   ui_name = "search_setter",
   open = nil, -- Defined below
   on_child_result = nil, -- Defined below
}

---Open the search setter
---@param pindex number
---@param parameters table
---@param controller fa.ui.RouterController
function search_setter_ui:open(pindex, parameters, controller)
   -- Get current search pattern
   local current_pattern = controller:get_search_pattern() or ""

   -- Open simple textbox with current pattern
   controller:open_child_ui(UiRouter.UI_NAMES.SIMPLE_TEXTBOX, {
      intro_message = { "fa.search-enter-pattern" },
      initial_text = current_pattern,
   }, "search_pattern_input")
end

---Handle textbox result
---@param pindex number
---@param result any The search pattern entered by the user
---@param context any The context (should be "search_pattern_input")
---@param controller fa.ui.RouterController
function search_setter_ui:on_child_result(pindex, result, context, controller)
   -- Set the search pattern (empty string clears it)
   if result and result ~= "" then
      controller:set_search_pattern(result)
      Speech.speak(pindex, { "fa.search-pattern-set", result })
   else
      controller:clear_search_pattern()
      Speech.speak(pindex, { "fa.search-pattern-cleared" })
   end

   -- Close this UI
   controller:close()
end

-- Register the UI
UiRouter.register_ui(search_setter_ui)

return mod
