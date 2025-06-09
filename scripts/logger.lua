--- mod: A minimal logging framework for FactorioAccess
-- Logs to files using Factorio's write_file API

local mod = {}

-- Log levels
mod.LEVELS = {
   DEBUG = 1,
   INFO = 2,
   WARN = 3,
   ERROR = 4,
   CRITICAL = 5,
}

-- Level names for output
local LEVEL_NAMES = {
   [mod.LEVELS.DEBUG] = "DEBUG",
   [mod.LEVELS.INFO] = "INFO",
   [mod.LEVELS.WARN] = "WARN",
   [mod.LEVELS.ERROR] = "ERROR",
   [mod.LEVELS.CRITICAL] = "CRITICAL",
}

-- Current log level (can be changed at runtime)
mod.current_level = mod.LEVELS.INFO

-- Log file path
local LOG_FILE = "factorio-access.log"

-- Test log file (separate to avoid cluttering main log)
local TEST_LOG_FILE = "factorio-access-test.log"

-- Current log target
local current_log_file = LOG_FILE

-- Initialize the logger
function mod.init()
   -- Clear the log file on startup
   helpers.write_file(LOG_FILE, "", false)
   helpers.write_file(TEST_LOG_FILE, "", false)
   mod.info("mod", "mod initialized")
end

-- Set the log level
function mod.set_level(level)
   if type(level) == "string" then
      -- Convert string to level
      for k, v in pairs(mod.LEVELS) do
         if k == level:upper() then
            mod.current_level = v
            return
         end
      end
      error("Invalid log level: " .. level)
   else
      mod.current_level = level
   end
end

-- Switch to test log file
function mod.use_test_log()
   current_log_file = TEST_LOG_FILE
   helpers.write_file(current_log_file, "", false) -- Clear test log
   mod.info("mod", "Switched to test log file")
end

-- Switch back to main log file
function mod.use_main_log()
   current_log_file = LOG_FILE
   mod.info("mod", "Switched to main log file")
end

-- Format a log message
local function format_message(level, module, message)
   local tick = game and game.tick or 0
   local timestamp = string.format("[%d]", tick)
   local level_str = LEVEL_NAMES[level] or "UNKNOWN"
   return string.format("%s [%s] %s: %s\n", timestamp, level_str, module or "Unknown", message)
end

-- Write to log (internal)
local function write_log(level, module, message)
   if level < mod.current_level then return end

   local formatted = format_message(level, module, message)
   helpers.write_file(current_log_file, formatted, true) -- Append mode
end

-- Log at DEBUG level
function mod.debug(module, message)
   write_log(mod.LEVELS.DEBUG, module, message)
end

-- Log at INFO level
function mod.info(module, message)
   write_log(mod.LEVELS.INFO, module, message)
end

-- Log at WARN level
function mod.warn(module, message)
   write_log(mod.LEVELS.WARN, module, message)
end

-- Log at ERROR level
function mod.error(module, message)
   write_log(mod.LEVELS.ERROR, module, message)
end

-- Log at CRITICAL level
function mod.critical(module, message)
   write_log(mod.LEVELS.CRITICAL, module, message)
end

-- Log a table (useful for debugging)
function mod.log_table(module, message, tbl, level)
   level = level or mod.LEVELS.DEBUG
   local serialized = serpent.block(tbl, { comment = false, numformat = "%.8g" })
   write_log(level, module, message .. ":\n" .. serialized)
end

-- Special logger for printout function
function mod.log_printout(pindex, message)
   if mod.current_level <= mod.LEVELS.DEBUG then
      write_log(mod.LEVELS.DEBUG, "printout", string.format("Player %d: %s", pindex, tostring(message)))
   end
end

-- Special logger for events
function mod.log_event(event_name, event_data)
   if mod.current_level <= mod.LEVELS.DEBUG then
      local message = string.format("Event %s fired", event_name)
      if event_data and type(event_data) == "table" then
         message = message .. " with data: " .. serpent.line(event_data, { comment = false })
      end
      write_log(mod.LEVELS.DEBUG, "EventManager", message)
   end
end

-- Make Logger globally available
_G.Logger = mod

return mod
