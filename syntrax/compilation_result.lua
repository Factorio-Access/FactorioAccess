--[[
The outcome of compiling some Syntrax.

This holds the final result and communicates errors.
]]

local mod = {}

---@class syntrax.CompilationResult
---@field error syntrax.Error?
---@field result any?
local CompilationResult = {}
mod.CompilationResult = CompilationResult
local CompilationResult_meta = { __index = CompilationResult }
mod.new = CompilationResult.new

---@return syntrax.CompilationResult
function CompilationResult.new()
   return setmetatable({}, CompilationResult_meta)
end

---@param error syntrax.Error
---@return syntrax.CompilationResult
function CompilationResult:add_error(error)
   self.error = error
   return self
end

---@param result any
---@return syntrax.CompilationResult
function CompilationResult:set_result(result)
   self.result = result
   return self
end

---@return any?
function CompilationResult:get_result()
   if self.error then return nil end
   return self.result
end

---@return syntrax.Error?
function CompilationResult:get_error()
   return self.error
end

return mod
