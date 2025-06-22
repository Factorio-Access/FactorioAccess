--[[
Abstract Syntax Tree definitions for Syntrax.

The AST represents the structure of a Syntrax program after parsing but before
compilation to VM bytecode. Each node carries span information for error reporting.
]]

local mod = {}

---@enum syntrax.NODE_TYPE
mod.NODE_TYPE = {
   -- Basic rail placement commands
   LEFT = "left",
   RIGHT = "right",
   STRAIGHT = "straight",

   -- Repetition: (body) rep count
   REPETITION = "repetition",

   -- Sequence of commands - implicit grouping, also used at top level
   SEQUENCE = "sequence",

   -- Rail stack manipulation
   RPUSH = "rpush",
   RPOP = "rpop",
   RESET = "reset",
}

---@class syntrax.ast.Node Base class for all AST nodes
---@field type syntrax.NODE_TYPE
---@field span syntrax.Span

---@class syntrax.ast.Left: syntrax.ast.Node

---@class syntrax.ast.Right: syntrax.ast.Node

---@class syntrax.ast.Straight: syntrax.ast.Node

---@class syntrax.ast.Sequence: syntrax.ast.Node
---@field statements syntrax.ast.Node[]

---@class syntrax.ast.Repetition: syntrax.ast.Node
---@field body syntrax.ast.Sequence The statement(s) to repeat
---@field count number How many times to repeat

---@class syntrax.ast.Rpush: syntrax.ast.Node

---@class syntrax.ast.Rpop: syntrax.ast.Node

---@class syntrax.ast.Reset: syntrax.ast.Node

-- Factory functions for creating AST nodes

---@param span syntrax.Span
---@return syntrax.ast.Left
function mod.left(span)
   return {
      type = mod.NODE_TYPE.LEFT,
      span = span,
   }
end

---@param span syntrax.Span
---@return syntrax.ast.Right
function mod.right(span)
   return {
      type = mod.NODE_TYPE.RIGHT,
      span = span,
   }
end

---@param span syntrax.Span
---@return syntrax.ast.Straight
function mod.straight(span)
   return {
      type = mod.NODE_TYPE.STRAIGHT,
      span = span,
   }
end

---@param statements syntrax.ast.Node[]
---@param span syntrax.Span
---@return syntrax.ast.Sequence
function mod.sequence(statements, span)
   return {
      type = mod.NODE_TYPE.SEQUENCE,
      statements = statements,
      span = span,
   }
end

---@param body syntrax.ast.Sequence
---@param count number
---@param span syntrax.Span
---@return syntrax.ast.Repetition
function mod.repetition(body, count, span)
   return {
      type = mod.NODE_TYPE.REPETITION,
      body = body,
      count = count,
      span = span,
   }
end

---@param span syntrax.Span
---@return syntrax.ast.Rpush
function mod.rpush(span)
   return {
      type = mod.NODE_TYPE.RPUSH,
      span = span,
   }
end

---@param span syntrax.Span
---@return syntrax.ast.Rpop
function mod.rpop(span)
   return {
      type = mod.NODE_TYPE.RPOP,
      span = span,
   }
end

---@param span syntrax.Span
---@return syntrax.ast.Reset
function mod.reset(span)
   return {
      type = mod.NODE_TYPE.RESET,
      span = span,
   }
end

return mod
