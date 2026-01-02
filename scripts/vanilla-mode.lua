--[[
Vanilla mode makes the mod behave more like standard Factorio for sighted players.
When enabled:
- Hides the FA cursor
- Re-enables mouse entity selection
- Silences TTS output
]]

local StorageManager = require("scripts.storage-manager")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

---@class fa.VanillaModeState
---@field enabled boolean

---@type table<integer, fa.VanillaModeState>
local vanilla_state = StorageManager.declare_storage_module("vanilla_mode", {
   enabled = false,
}, {
   ephemeral_state_version = 1,
})

---@param pindex integer
---@return boolean
function mod.is_enabled(pindex)
   return vanilla_state[pindex].enabled
end

---@param pindex integer
function mod.toggle(pindex)
   local p = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   local state = vanilla_state[pindex]

   if not state.enabled then
      p.print("Vanilla mode : ON")
      vp:set_cursor_hidden(true)
      state.enabled = true
   else
      p.print("Vanilla mode : OFF")
      vp:set_cursor_hidden(false)
      state.enabled = false
   end
end

return mod
