---UI for entering syntrax code.
---Opens a textbox and executes the syntrax code to place rails.

local UiRouter = require("scripts.ui.router")
local Speech = require("scripts.speech")
local VTD = require("scripts.rails.virtual-train-driving")

local mod = {}

---@type fa.ui.UiPanelBase
local syntrax_input_ui = {
   ui_name = "syntrax_input",
   open = nil, -- Defined below
   on_child_result = nil, -- Defined below
}

---Open the syntrax input
---@param pindex number
---@param parameters {position: MapPosition, direction: defines.direction}
---@param controller fa.ui.RouterController
function syntrax_input_ui:open(pindex, parameters, controller)
   -- Open textbox for syntrax code input
   controller:open_textbox("", "syntrax_input", { "fa.syntrax-enter" })
end

---Handle textbox result
---@param pindex number
---@param result any The syntrax code entered by the user (nil if cancelled)
---@param context any The context (should be "syntrax_input")
---@param controller fa.ui.RouterController
function syntrax_input_ui:on_child_result(pindex, result, context, controller)
   -- If cancelled or empty, just close
   if not result or result == "" then
      controller:close()
      return
   end

   -- Execute syntrax via VTD (which has stored state)
   local entities, err = VTD.execute_syntrax(pindex, result)

   if err then
      Speech.speak(pindex, { "fa.syntrax-error", err })
   elseif entities and #entities > 0 then
      Speech.speak(pindex, { "fa.syntrax-placed", #entities })
   else
      Speech.speak(pindex, { "fa.syntrax-placed", 0 })
   end

   -- Close this UI
   controller:close()
end

-- Register the UI
UiRouter.register_ui(syntrax_input_ui)

return mod
