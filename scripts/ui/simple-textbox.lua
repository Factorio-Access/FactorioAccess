---Simple textbox UI that doesn't require an underlying UI stack.
---Used for standalone text input like search pattern entry.
local Speech = require("scripts.speech")
local UiRouter = require("scripts.ui.router")

local mod = {}

---@type fa.ui.UiPanelBase
local simple_textbox_ui = {
   ui_name = "simple_textbox",
   open = nil, -- Defined below
   on_child_result = nil, -- Defined below
}

---Open the simple textbox
---@param pindex number
---@param parameters table Should contain intro_message (LocalisedString) and initial_text (string)
---@param controller fa.ui.RouterController
function simple_textbox_ui:open(pindex, parameters, controller)
   local intro_message = parameters.intro_message or { "fa.simple-textbox-default-intro" }
   local initial_text = parameters.initial_text or ""

   -- Speak the intro message
   Speech.speak(pindex, intro_message)

   -- Open the textbox
   controller:open_textbox(initial_text, "simple_textbox_input")
end

---Handle textbox result
---@param pindex number
---@param result any The text entered by the user
---@param context any The context (should be "simple_textbox_input")
---@param controller fa.ui.RouterController
function simple_textbox_ui:on_child_result(pindex, result, context, controller)
   -- Close and pass result to parent
   controller:close_with_result(result)
end

-- Register the UI
UiRouter.register_ui(simple_textbox_ui)

return mod
