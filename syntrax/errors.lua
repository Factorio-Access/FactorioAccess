--[[
AN error consists of:

- A location: where did it happen?
- A message: why?
- A set of notes: What and (optionally) where do we think things screwed up.
- An  error code: a programatic way of saying what the error is, defined by an enum and useful for localisation.
]]
local mod = {}

---@enum syntrax.ERROR_CODE
mod.ERROR_CODE = {
   INVALID_TOKEN = "invalid_token",

   -- There's a bracket still open.  Shows up at EOF, essentially.
   BRACKET_NOT_CLOSED = "bracket_not_closed",

   -- You tried to close a bracket, but it was opened by a different kind, e.g. (].
   BRACKET_MISMATCH = "bracket_mismatch",

   -- Parser errors
   UNEXPECTED_TOKEN = "unexpected_token",
   EXPECTED_NUMBER = "expected_number",

   -- Runtime errors
   RUNTIME_ERROR = "runtime_error",
}

---@class syntrax.Error
---@field code syntrax.ERROR_CODE
---@field message string
---@field span syntrax.Span
---@field notes syntrax.ErrorNote[]

---@class syntrax.ErrorNote
---@field span syntrax.Span?
---@field message string

---@class syntrax.ErrorBuilder
---@field error syntrax.Error
local ErrorBuilder = {}
local ErrorBuilder_meta = { __index = ErrorBuilder }

---@param message string
---@param opt_span syntrax.Span?
---@return syntrax.ErrorBuilder
function ErrorBuilder:note(message, opt_span)
   table.insert(self.error.notes, { span = opt_span, message = message })
   return self
end

---@return syntrax.Error
function ErrorBuilder:build()
   return self.error
end

---@param code syntrax.ERROR_CODE
---@param message string
---@param span syntrax.Span?
---@return syntrax.ErrorBuilder
function mod.error_builder(code, message, span)
   local err = { code = code, message = message, span = span, notes = {} }
   return setmetatable({ error = err }, ErrorBuilder_meta)
end

return mod
