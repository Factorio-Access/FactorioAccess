---UI for entering syntrax code.
---Opens a textbox and executes the syntrax code to place rails.

local UiRouter = require("scripts.ui.router")
local Speech = require("scripts.speech")
local StorageManager = require("scripts.storage-manager")
local SyntraxRunner = require("scripts.rails.syntrax-runner")

local mod = {}

---@class syntrax_input.State
---@field position MapPosition? Position to start building from
---@field direction defines.direction? Direction to start building

---@return syntrax_input.State
local function init_state()
   return {}
end

local syntrax_state = StorageManager.declare_storage_module("syntrax_input", init_state)

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
   -- Store parameters for use after textbox completes
   local state = syntrax_state[pindex]
   state.position = parameters.position
   state.direction = parameters.direction

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

   -- Get stored parameters
   local state = syntrax_state[pindex]
   if not state.position or not state.direction then
      Speech.speak(pindex, { "fa.syntrax-error", "no position" })
      controller:close()
      return
   end

   -- Execute syntrax
   local entities, err = SyntraxRunner.execute(pindex, result, state.position, state.direction)

   if err then
      Speech.speak(pindex, { "fa.syntrax-error", err })
   elseif entities and #entities > 0 then
      Speech.speak(pindex, { "fa.syntrax-placed", #entities })
   else
      Speech.speak(pindex, { "fa.syntrax-placed", 0 })
   end

   -- Clear stored state
   state.position = nil
   state.direction = nil

   -- Close this UI
   controller:close()
end

-- Register the UI
UiRouter.register_ui(syntrax_input_ui)

return mod
