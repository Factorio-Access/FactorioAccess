--[[
Custom console commands, primarily for debugging and internal use.  Docs with
the handlers in this file.

Handlers registered by this file are exported and not announced through our
normal handling.  This is because the launcher cannot handle queueing.  We need
the mod to be silent.
]]
local Fluids = require("scripts.fluids")
local FaUtils = require("scripts.fa-utils")

local mod = {}

--[[
/fac <script>

Exactrly the same as /c, but accessible without fiddling around. It:

- Captures return values, then speaks them through serpent:
  - Tries to run the code wrapped in a function, with return prepended
  - Otherwise, runs the code directly, and uses whatever the chunk returns.
- Overrides Lua print to go to speech, and concatenates everything up so that we
  don't "trip" over the announcements.
- Makes printout available, as a mocked version that will just call to print
  (IMPORTANT: only works on the current player; pindex is ignored).
- Announces errors, with tracebacks, using pcall.

Also due to launcher limitations, "print" here doesn't do newlines.  That'll
cause the launcher to not read right.
]]
---@param cmd CustomCommandData
function cmd_fac(cmd)
   local pindex = cmd.player_index
   local script = cmd.parameter

   if not cmd.parameter or cmd.parameter == "" then
      printout("A script is required", pindex)
      return
   end

   local printbuffer = ""

   local function print_override(...)
      -- Send a copy to launcher stdout for debugging.
      print(...)

      local args = table.pack(...)
      for i = 1, args.n do
         printbuffer = printbuffer .. tostring(args[i]) .. " "
      end
   end

   local with_return = "return " .. script

   local environment = {}

   for k, v in pairs(_ENV) do
      environment[k] = v
   end
   environment.print = print_override
   environment.printout = function(arg, pindex)
      print_override(arg, "for pindex", pindex)
   end
   environment.Fluids = Fluids
   environment.FaUtils = FaUtils

   local chunk, err = load(with_return, "=(load)", "t", environment)
   if not chunk then
      chunk, err = load(cmd.parameter, "=(load)", "t", environment)
      if err then
         printout(err, pindex)
         print(err)
         return
      end
   end

   local _good, val = pcall(function()
      local r = chunk()
      return serpent.line(r, { nocode = true })
   end)

   print_override(val)

   printout(printbuffer, pindex)
end

mod.COMMANDS = {
   fac = {
      help = "See commands.lua",
      handler = cmd_fac,
   },
}

for name, args in pairs(mod.COMMANDS) do
   commands.add_command(name, args.help, args.handler)
end

return mod
