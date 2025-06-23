--- Logging framework for FactorioAccess
-- Provides module-specific loggers without global injection

local mod = {}

---@enum LogLevel
mod.LEVELS = {
   DEBUG = 1,
   INFO = 2,
   WARN = 3,
   ERROR = 4,
   CRITICAL = 5,
}

-- Level names for output
---@type table<LogLevel, string>
local LEVEL_NAMES = {
   [mod.LEVELS.DEBUG] = "DEBUG",
   [mod.LEVELS.INFO] = "INFO",
   [mod.LEVELS.WARN] = "WARN",
   [mod.LEVELS.ERROR] = "ERROR",
   [mod.LEVELS.CRITICAL] = "CRITICAL",
}

-- Shared state for all loggers
---@class LoggingSharedState
---@field current_level LogLevel
---@field log_file string
---@field test_log_file string
---@field current_log_file string
---@field initialized boolean
local shared_state = {
   current_level = mod.LEVELS.INFO,
   log_file = "factorio-access.log",
   test_log_file = "factorio-access-test.log",
   current_log_file = "factorio-access.log",
   initialized = false,
}

-- Format a log message
---@param level LogLevel
---@param module string
---@param message string
---@return string
local function format_message(level, module, message)
   local tick = game and game.tick or 0
   local timestamp = string.format("[%d]", tick)
   local level_str = LEVEL_NAMES[level] or "UNKNOWN"
   return string.format("%s [%s] %s: %s\n", timestamp, level_str, module or "Unknown", message)
end

-- Write to log (internal)
---@param level LogLevel
---@param module string
---@param message string
local function write_log(level, module, message)
   assert(shared_state.initialized, "Logging system not initialized. You cannot use logging before on_init runs")
   if level < shared_state.current_level then return end

   local formatted = format_message(level, module, message)
   helpers.write_file(shared_state.current_log_file, formatted, true) -- Append mode
   -- Also print to stdout for launcher script
   print(formatted:sub(1, -2)) -- Remove trailing newline since print adds one
end

---@class fa.Logger
---@field module_name string
local Logger = {}
local Logger_meta = { __index = Logger }

-- Log at DEBUG level
---@param message string
function Logger:debug(message)
   write_log(mod.LEVELS.DEBUG, self.module_name, message)
end

-- Log at INFO level
---@param message string
function Logger:info(message)
   write_log(mod.LEVELS.INFO, self.module_name, message)
end

-- Log at WARN level
---@param message string
function Logger:warn(message)
   write_log(mod.LEVELS.WARN, self.module_name, message)
end

-- Log at ERROR level
---@param message string
function Logger:error(message)
   write_log(mod.LEVELS.ERROR, self.module_name, message)
end

-- Log at CRITICAL level
---@param message string
function Logger:critical(message)
   write_log(mod.LEVELS.CRITICAL, self.module_name, message)
end

-- Log a table (useful for debugging)
---@param message string
---@param tbl table
---@param level? LogLevel Default is DEBUG
function Logger:log_table(message, tbl, level)
   level = level or mod.LEVELS.DEBUG
   local serialized = serpent.line(tbl, { comment = false, nocode = true })
   write_log(level, self.module_name, message .. ":\n" .. serialized)
end

-- Logger constructor
---@param module_name string The name of the module creating this logger
---@return fa.Logger
function mod.Logger(module_name)
   local logger = {
      module_name = module_name,
   }
   setmetatable(logger, Logger_meta)
   return logger
end

-- Initialize the logging system (called once by control.lua)
function mod.init()
   -- Clear the log files on startup
   helpers.write_file(shared_state.log_file, "", false)
   helpers.write_file(shared_state.test_log_file, "", false)
   shared_state.initialized = true

   -- Create a temporary logger for init message
   local init_logger = mod.Logger("Logging")
   init_logger:info("Logging system initialized")
end

-- Set the global log level
---@param level LogLevel|string Either a LogLevel enum value or string like "DEBUG", "INFO", etc.
function mod.set_level(level)
   if type(level) == "string" then
      -- Convert string to level
      for k, v in pairs(mod.LEVELS) do
         if k == level:upper() then
            shared_state.current_level = v
            return
         end
      end
      error("Invalid log level: " .. level)
   else
      shared_state.current_level = level
   end
end

-- Switch to test log file
function mod.use_test_log()
   shared_state.current_log_file = shared_state.test_log_file
   helpers.write_file(shared_state.current_log_file, "", false) -- Clear test log
   local logger = mod.Logger("Logging")
   logger:info("Switched to test log file")
end

-- Switch back to main log file
function mod.use_main_log()
   shared_state.current_log_file = shared_state.log_file
   local logger = mod.Logger("Logging")
   logger:info("Switched to main log file")
end

-- Special logger functions that don't belong to a specific module

-- Special logger for printout function
---@param pindex integer Player index
---@param message any Message to log
function mod.log_printout(pindex, message)
   if shared_state.current_level <= mod.LEVELS.DEBUG then
      write_log(mod.LEVELS.DEBUG, "printout", string.format("Player %d: %s", pindex, tostring(message)))
   end
end

-- Special logger for events
---@param event_name string Name of the event
---@param event_data? table Optional event data table
function mod.log_event(event_name, event_data)
   if shared_state.current_level <= mod.LEVELS.DEBUG then
      local message = string.format("Event %s fired", event_name)
      if event_data and type(event_data) == "table" then
         message = message .. " with data: " .. serpent.line(event_data, { comment = false })
      end
      write_log(mod.LEVELS.DEBUG, "EventManager", message)
   end
end

return mod
