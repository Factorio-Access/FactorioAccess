--[[
Custom console commands, primarily for debugging and internal use.  Docs with
the handlers in this file.

Handlers registered by this file are exported and not announced through our
normal handling.  This is because the launcher cannot handle queueing.  We need
the mod to be silent.
]]
local FaUtils = require("scripts.fa-utils")
local Fluids = require("scripts.fluids")
local Localising = require("scripts.localising")
local TH = require("scripts.table-helpers")
local TransportBelts = require("scripts.transport-belts")
local Wires = require("scripts.wires")
local Speech = require("scripts.speech")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

--[[
/fac <script>

Exactly the same as /c, but accessible without fiddling around. It:

- Captures return values, then speaks them through serpent:
  - Tries to run the code wrapped in a function, with return prepended
  - Otherwise, runs the code directly, and uses whatever the chunk returns.
- Overrides Lua print to go to speech, and concatenates everything up so that we
  don't "trip" over the announcements.
- Makes printout available as a compatibility wrapper that calls Speech.speak
  (for legacy scripts that still use printout).
- Announces errors, with tracebacks, using pcall.

Also due to launcher limitations, "print" here doesn't do newlines.  That'll
cause the launcher to not read right.
]]
---@param cmd CustomCommandData
local function cmd_fac(cmd)
   local pindex = cmd.player_index
   local script = cmd.parameter

   if not cmd.parameter or cmd.parameter == "" then
      Speech.speak(pindex, { "fa.fa-commands-script-required" })
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
   -- Compatibility wrapper for legacy scripts
   environment.printout = function(message, provided_pindex)
      -- Use the command's player index if not provided
      local actual_pindex = provided_pindex or pindex
      Speech.speak(actual_pindex, message)
   end

   environment.FaUtils = FaUtils
   environment.Fluids = Fluids
   environment.Localising = Localising
   environment.TableHelpers = TH
   environment.TH = TH
   environment.TransportBelts = TransportBelts
   environment.Wires = Wires
   environment.Viewpoint = viewpoint

   local chunk, err = load(with_return, "=(load)", "t", environment)
   if not chunk then
      chunk, err = load(cmd.parameter, "=(load)", "t", environment)
      if err then
         Speech.speak(pindex, err)
         print(err)
         return
      end
   end

   local _good, val = pcall(function()
      local r = chunk()
      return serpent.line(r, { nocode = true })
   end)

   print_override(val)

   Speech.speak(pindex, printbuffer)
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
