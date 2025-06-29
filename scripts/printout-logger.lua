--- Printout Logger: Logs all printout messages to a file for debugging
-- This module intercepts printout messages and writes them to a log file
-- in addition to sending them to the screen reader.

local mod = {}

-- Log file configuration
local LOG_FILE = "factorio-access-printout.log"

--- Initialize the printout logger
function mod.init()
   -- Only init once per save.
   if storage.printout_logger_initialized then return end

   -- Clear the log file on startup
   helpers.write_file(LOG_FILE, "", false)
   storage.printout_logger_initialized = true

   -- Write header
   local header = string.format(
      "=== FactorioAccess Printout Log ===\n"
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

--- Log a printout message
---@param message LocalisedString
---@param pindex number
function mod.log_printout(message, pindex)
   if not storage.printout_logger_initialized then return end

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
