local Native = require("scripts.native")
local VanillaMode = require("scripts.vanilla-mode")

---@class LauncherCommands
local mod = {}

---Copies text to the system clipboard: the native code's in single player, else the launcher's.
---@param pindex integer
---@param text string
function mod.copy_to_clipboard(pindex, text)
   if VanillaMode.is_enabled(pindex) then return end
   if Native.is_available() then
      Native.set_clipboard(text)
      return
   end
   -- The launcher reads one line per command
   assert(not string.find(text, "\n"), "Newlines not supported in copy yet")
   print(string.format("copy %i %s", pindex, text))
end

return mod
