--[[
Syntrax - Main public interface

This is the primary entry point for the Syntrax library.
All other modules are considered internal implementation details.
]]

local Parser = require("syntrax.parser")
local Compiler = require("syntrax.compiler")
local Vm = require("syntrax.vm")

local mod = {}

-- Version information
mod.VERSION = "0.1.0-dev"

---Execute Syntrax source code and return rail placements
---@param source string The Syntrax source code
---@param initial_position fa.Point? Starting position, defaults to {x=0, y=0}
---@param initial_direction number? Starting direction (0-15), defaults to north (0)
---@return syntrax.vm.RailPlacement[]? rails Array of rail placements, or nil on error
---@return syntrax.Error? error Error object if compilation or execution failed
function mod.execute(source, initial_position, initial_direction)
   -- Parse
   local ast, parse_err = Parser.parse(source)
   if parse_err then return nil, parse_err end

   -- Parser should always return an AST on success
   assert(ast, "Parser returned nil without error")

   -- Compile
   local bytecode = Compiler.compile(ast)

   -- Execute
   local vm = Vm.new()
   vm.bytecode = bytecode
   local rails, runtime_err = vm:run(initial_position, initial_direction)

   if runtime_err then return nil, runtime_err end

   return rails, nil
end

-- Document the rail placement structure for API consumers
---@class syntrax.RailPlacement
---@field position fa.Point Position where the rail should be placed
---@field rail_type string "straight-rail", "curved-rail-a", "curved-rail-b", or "half-diagonal-rail"
---@field placement_direction number 0-15 direction for placement
---@field span syntrax.Span? Source span for error reporting

-- Document the error structure for API consumers
-- (actual class defined in errors.lua)

return mod
