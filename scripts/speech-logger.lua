--- Speech Logger: Logs all speech messages to a file for debugging
-- This module logs speech messages that are sent to the screen reader
-- for debugging and analysis purposes.

local mod = {}

-- Log file configuration
local LOG_FILE = "factorio-access-speech.log"

--- Initialize the speech logger
local function init_if_needed()
   -- Only init once per save.
   if storage.speech_logger_initialized then return end

   -- Clear the log file on startup
   helpers.write_file(LOG_FILE, "", false)
   storage.speech_logger_initialized = true

   -- Write header
   local header = string.format(
      "=== FactorioAccess Speech Log ===\n"
         .. "Started at tick: %d\n"
         .. "Game Version: %s\n"
         .. "Mod Version: %s\n"
         .. "================================\n\n",
      game.tick,
      helpers.game_version,
      script.active_mods["FactorioAccess"] or "Unknown"
   )
   helpers.write_file(LOG_FILE, header, true)
end

--- Log a speech message
---@param message LocalisedString
---@param pindex number
function mod.log_speech(message, pindex)
   init_if_needed()

   -- Build a localised string with timestamp and player info
   local tick = game and game.tick or 0
   local log_entry = {
      "",
      string.format("[%d] [P%d] ", tick, pindex or 0),
      message,
      "\n",
   }

   -- Write immediately for crash debugging
   helpers.write_file(LOG_FILE, log_entry, true) -- Append mode
end

return mod
