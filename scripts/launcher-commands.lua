local Native = require("scripts.native")
local VanillaMode = require("scripts.vanilla-mode")

---@class LauncherCommands
local mod = {}

---Copies text to the system clipboard: the native code's in single player, else the launcher's.
---@param pindex integer
---@param text string
---@return boolean copied False when the text has line breaks and only the launcher is there to copy it
function mod.copy_to_clipboard(pindex, text)
   if VanillaMode.is_enabled(pindex) then return true end
   if Native.is_available() then
      Native.set_clipboard(text)
      return true
   end
   -- The launcher reads one line per command
   if string.find(text, "\n") then return false end
   print(string.format("copy %i %s", pindex, text))
   return true
end

return mod
