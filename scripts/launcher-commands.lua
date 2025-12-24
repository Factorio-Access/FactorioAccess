---@class LauncherCommands
local mod = {}

-- Generate a delimiter that's unlikely to appear in clipboard content
-- Using a combination of prefix and random-looking hex to avoid collisions
local HEREDOC_DELIMITER = "FA_CLIPBOARD_BOUNDARY_7f3a9c2e1b"

---Copies text to the system clipboard via the launcher.
---@param pindex integer
---@param text string
function mod.copy_to_clipboard(pindex, text)
   assert(not string.find(text, "\n"), "Newlines not supported in copy yet")
   print(string.format("copy %i %s", pindex, text))
end

return mod
