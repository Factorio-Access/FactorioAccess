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

   -- Degree turns (l45 = 2 lefts, l90 = 4 lefts, etc.)
   L45 = "l45",
   R45 = "r45",
   L90 = "l90",
   R90 = "r90",

   -- Repetition: [body] x count
   REPETITION = "repetition",

   -- Sequence of commands - implicit grouping, also used at top level
   SEQUENCE = "sequence",

   -- Rail stack manipulation
   RPUSH = "rpush",
   RPOP = "rpop",
   RESET = "reset",

   -- Position manipulation
   FLIP = "flip",

   -- Signal placement commands
   SIGLEFT = "sigleft",
   SIGRIGHT = "sigright",
   CHAINLEFT = "chainleft",
   CHAINRIGHT = "chainright",
   SIG = "sig",
   CHAIN = "chain",
   SIGCHAIN = "sigchain",
   CHAINSIG = "chainsig",
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

---@class syntrax.ast.Flip: syntrax.ast.Node

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

---@param span syntrax.Span
---@return syntrax.ast.Node
function mod.l45(span)
   return {
      type = mod.NODE_TYPE.L45,
      span = span,
   }
end

---@param span syntrax.Span
---@return syntrax.ast.Node
function mod.r45(span)
   return {
      type = mod.NODE_TYPE.R45,
      span = span,
   }
end

---@param span syntrax.Span
---@return syntrax.ast.Node
function mod.l90(span)
   return {
      type = mod.NODE_TYPE.L90,
      span = span,
   }
end

---@param span syntrax.Span
---@return syntrax.ast.Node
function mod.r90(span)
   return {
      type = mod.NODE_TYPE.R90,
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

---@param span syntrax.Span
---@return syntrax.ast.Flip
function mod.flip(span)
   return {
      type = mod.NODE_TYPE.FLIP,
      span = span,
   }
end

-- Signal node factories

---@param span syntrax.Span
---@return syntrax.ast.Node
function mod.sigleft(span)
   return {
      type = mod.NODE_TYPE.SIGLEFT,
      span = span,
   }
end

---@param span syntrax.Span
---@return syntrax.ast.Node
function mod.sigright(span)
   return {
      type = mod.NODE_TYPE.SIGRIGHT,
      span = span,
   }
end

---@param span syntrax.Span
---@return syntrax.ast.Node
function mod.chainleft(span)
   return {
      type = mod.NODE_TYPE.CHAINLEFT,
      span = span,
   }
end

---@param span syntrax.Span
---@return syntrax.ast.Node
function mod.chainright(span)
   return {
      type = mod.NODE_TYPE.CHAINRIGHT,
      span = span,
   }
end

---@param span syntrax.Span
---@return syntrax.ast.Node
function mod.sig(span)
   return {
      type = mod.NODE_TYPE.SIG,
      span = span,
   }
end

---@param span syntrax.Span
---@return syntrax.ast.Node
function mod.chain(span)
   return {
      type = mod.NODE_TYPE.CHAIN,
      span = span,
   }
end

---@param span syntrax.Span
---@return syntrax.ast.Node
function mod.sigchain(span)
   return {
      type = mod.NODE_TYPE.SIGCHAIN,
      span = span,
   }
end

---@param span syntrax.Span
---@return syntrax.ast.Node
function mod.chainsig(span)
   return {
      type = mod.NODE_TYPE.CHAINSIG,
      span = span,
   }
end

return mod
