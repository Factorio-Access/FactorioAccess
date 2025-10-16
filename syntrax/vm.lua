--[[
Virtual Machine for Syntrax language.

Executes bytecode to produce a graph of rail placements.
]]

local Directions = require("syntrax.directions")
local Errors = require("syntrax.errors")

local mod = {}

---@enum syntrax.vm.OperandKind
mod.OPERAND_KIND = {
   VALUE = "value",
   REGISTER = "register",
   MATH_OP = "math_op",
   CMP_OP = "cmp_op",
}

---@enum syntrax.vm.ValueType
mod.VALUE_TYPE = {
   NUMBER = "number",
}

---@enum syntrax.vm.BytecodeKind
mod.BYTECODE_KIND = {
   LEFT = "left",
   RIGHT = "right",
   STRAIGHT = "straight",
   JNZ = "jnz",
   MATH = "math",
   CMP = "cmp",
   MOV = "mov",
   RPUSH = "rpush",
   RPOP = "rpop",
   RESET = "reset",
}

---@enum syntrax.vm.MathOp
mod.MATH_OP = {
   ADD = "+",
   SUB = "-",
   MUL = "*",
   DIV = "/",
}

---@enum syntrax.vm.CmpOp
mod.CMP_OP = {
   LT = "<",
   LE = "<=",
   EQ = "==",
   GE = ">=",
   GT = ">",
   NE = "!=",
}

---@enum syntrax.vm.RailKind
mod.RAIL_KIND = {
   LEFT = "left",
   RIGHT = "right",
   STRAIGHT = "straight",
}

---@class syntrax.vm.Operand
---@field kind syntrax.vm.OperandKind
---@field type syntrax.vm.ValueType? Only present for values
---@field argument number|string Register index, literal value, or operation string

---@class syntrax.vm.Bytecode
---@field kind syntrax.vm.BytecodeKind
---@field arguments syntrax.vm.Operand[]
---@field span syntrax.Span? Optional span for error reporting

---@class syntrax.vm.Rail
---@field parent number? Index of parent rail (nil for first rail)
---@field kind syntrax.vm.RailKind
---@field incoming_direction number Direction hand was facing when placed
---@field outgoing_direction number Direction hand faces after placement

---@class syntrax.vm.RailStackEntry
---@field rail_index number Index of the rail
---@field hand_direction number Hand direction when rail was pushed

---@class syntrax.vm.State
---@field registers table<number, syntrax.vm.Operand> Array of registers
---@field bytecode syntrax.vm.Bytecode[] Array of bytecode instructions
---@field rails syntrax.vm.Rail[] Output graph of rails
---@field pc number Program counter
---@field hand_direction number Current hand direction (0-15)
---@field parent_rail number? Index of last placed rail
---@field rail_stack syntrax.vm.RailStackEntry[] Stack of saved rail positions
---@field initial_rail number? Initial rail index
---@field initial_hand_direction number Initial hand direction
---@field resolve_operand fun(self: syntrax.vm.State, operand: syntrax.vm.Operand): syntrax.vm.Operand
---@field place_rail fun(self: syntrax.vm.State, kind: syntrax.vm.RailKind)
---@field execute_jnz fun(self: syntrax.vm.State, instr: syntrax.vm.Bytecode)
---@field execute_math fun(self: syntrax.vm.State, instr: syntrax.vm.Bytecode)
---@field execute_cmp fun(self: syntrax.vm.State, instr: syntrax.vm.Bytecode)
---@field execute_mov fun(self: syntrax.vm.State, instr: syntrax.vm.Bytecode)
---@field execute_rpush fun(self: syntrax.vm.State, instr: syntrax.vm.Bytecode): nil, syntrax.Error?
---@field execute_rpop fun(self: syntrax.vm.State, instr: syntrax.vm.Bytecode): nil, syntrax.Error?
---@field execute_reset fun(self: syntrax.vm.State, instr: syntrax.vm.Bytecode): nil, syntrax.Error?
---@field execute_instruction fun(self: syntrax.vm.State): boolean, syntrax.Error?
---@field run fun(self: syntrax.vm.State, initial_rail: number?, initial_hand_direction: number?): syntrax.vm.Rail[]?, syntrax.Error?

local VM = {}
local VM_meta = { __index = VM }

---@return syntrax.vm.State
function mod.new()
   return setmetatable({
      registers = {},
      bytecode = {},
      rails = {},
      pc = 1,
      hand_direction = Directions.NORTH, -- Start facing north
      parent_rail = nil,
      rail_stack = {},
      initial_rail = nil,
      initial_hand_direction = Directions.NORTH,
   }, VM_meta)
end

-- Helper to create operands
function mod.value(type, value)
   return {
      kind = mod.OPERAND_KIND.VALUE,
      type = type,
      argument = value,
   }
end

function mod.register(index)
   return {
      kind = mod.OPERAND_KIND.REGISTER,
      argument = index,
   }
end

function mod.math_op(op)
   return {
      kind = mod.OPERAND_KIND.MATH_OP,
      argument = op,
   }
end

function mod.cmp_op(op)
   return {
      kind = mod.OPERAND_KIND.CMP_OP,
      argument = op,
   }
end

-- Helper to create bytecode
function mod.bytecode(kind, ...)
   return {
      kind = kind,
      arguments = { ... },
   }
end

---@param operand syntrax.vm.Operand
---@return syntrax.vm.Operand
function VM:resolve_operand(operand)
   if operand.kind == mod.OPERAND_KIND.VALUE then
      return operand
   elseif operand.kind == mod.OPERAND_KIND.REGISTER then
      local value = self.registers[operand.argument]
      if not value then error(string.format("Register r%d not initialized", operand.argument)) end
      if value.kind == mod.OPERAND_KIND.REGISTER then error("Register contains another register reference") end
      return value
   elseif operand.kind == mod.OPERAND_KIND.MATH_OP or operand.kind == mod.OPERAND_KIND.CMP_OP then
      -- Operations are not resolved, they're used directly
      return operand
   else
      error("Unknown operand kind: " .. tostring(operand.kind))
   end
end

---@param kind syntrax.vm.RailKind
function VM:place_rail(kind)
   local incoming = self.hand_direction
   local outgoing = incoming

   -- Update direction based on rail type
   if kind == mod.RAIL_KIND.LEFT then
      outgoing = Directions.rotate(incoming, -1)
   elseif kind == mod.RAIL_KIND.RIGHT then
      outgoing = Directions.rotate(incoming, 1)
      -- STRAIGHT doesn't change direction
   end

   local rail = {
      parent = self.parent_rail,
      kind = kind,
      incoming_direction = incoming,
      outgoing_direction = outgoing,
   }

   table.insert(self.rails, rail)
   self.parent_rail = #self.rails
   self.hand_direction = outgoing
end

---@param instr syntrax.vm.Bytecode
function VM:execute_jnz(instr)
   local value = self:resolve_operand(instr.arguments[1])
   local offset = self:resolve_operand(instr.arguments[2])

   if value.argument ~= 0 then
      self.pc = self.pc + offset.argument
   else
      self.pc = self.pc + 1
   end
end

---@param instr syntrax.vm.Bytecode
function VM:execute_math(instr)
   local dest = instr.arguments[1]
   if dest.kind ~= mod.OPERAND_KIND.REGISTER then error("MATH destination must be a register") end

   local left = self:resolve_operand(instr.arguments[2])
   local right = self:resolve_operand(instr.arguments[3])
   local op = instr.arguments[4]

   if op.kind ~= mod.OPERAND_KIND.MATH_OP then error("MATH operation must be a MATH_OP operand") end

   local result
   if op.argument == mod.MATH_OP.ADD then
      result = left.argument + right.argument
   elseif op.argument == mod.MATH_OP.SUB then
      result = left.argument - right.argument
   elseif op.argument == mod.MATH_OP.MUL then
      result = left.argument * right.argument
   elseif op.argument == mod.MATH_OP.DIV then
      result = left.argument / right.argument
   else
      error("Unknown math operation: " .. tostring(op.argument))
   end

   self.registers[dest.argument] = mod.value(mod.VALUE_TYPE.NUMBER, result)
   self.pc = self.pc + 1
end

---@param instr syntrax.vm.Bytecode
function VM:execute_cmp(instr)
   local dest = instr.arguments[1]
   if dest.kind ~= mod.OPERAND_KIND.REGISTER then error("CMP destination must be a register") end

   local val1 = self:resolve_operand(instr.arguments[2])
   local val2 = self:resolve_operand(instr.arguments[3])
   local op = instr.arguments[4]

   if op.kind ~= mod.OPERAND_KIND.CMP_OP then error("CMP operation must be a CMP_OP operand") end

   local result
   if op.argument == mod.CMP_OP.LT then
      result = val1.argument < val2.argument
   elseif op.argument == mod.CMP_OP.LE then
      result = val1.argument <= val2.argument
   elseif op.argument == mod.CMP_OP.EQ then
      result = val1.argument == val2.argument
   elseif op.argument == mod.CMP_OP.GE then
      result = val1.argument >= val2.argument
   elseif op.argument == mod.CMP_OP.GT then
      result = val1.argument > val2.argument
   elseif op.argument == mod.CMP_OP.NE then
      result = val1.argument ~= val2.argument
   else
      error("Unknown comparison operation: " .. tostring(op.argument))
   end

   self.registers[dest.argument] = mod.value(mod.VALUE_TYPE.NUMBER, result and 1 or 0)
   self.pc = self.pc + 1
end

---@param instr syntrax.vm.Bytecode
function VM:execute_mov(instr)
   local dest = instr.arguments[1]
   if dest.kind ~= mod.OPERAND_KIND.REGISTER then error("MOV destination must be a register") end

   local value = self:resolve_operand(instr.arguments[2])
   self.registers[dest.argument] = value
   self.pc = self.pc + 1
end

---@param instr syntrax.vm.Bytecode
---@return nil, syntrax.Error?
function VM:execute_rpush(instr)
   -- Push current rail index and hand direction to the stack
   local entry = {
      rail_index = self.parent_rail or self.initial_rail,
      hand_direction = self.hand_direction,
   }
   table.insert(self.rail_stack, entry)
   return nil, nil
end

---@param instr syntrax.vm.Bytecode
---@return nil, syntrax.Error?
function VM:execute_rpop(instr)
   if #self.rail_stack == 0 then
      -- Runtime error - empty stack
      return nil,
         Errors.error_builder(Errors.ERROR_CODE.RUNTIME_ERROR, "Cannot rpop from empty rail stack", instr.span):build()
   end

   -- Pop the last entry
   local entry = table.remove(self.rail_stack)
   self.parent_rail = entry.rail_index
   self.hand_direction = entry.hand_direction
   return nil, nil
end

---@param instr syntrax.vm.Bytecode
---@return nil, syntrax.Error?
function VM:execute_reset(instr)
   -- Clear the rail stack
   self.rail_stack = {}
   -- Return to initial position
   self.parent_rail = self.initial_rail
   self.hand_direction = self.initial_hand_direction
   return nil, nil
end

---@return boolean, syntrax.Error? True if execution should continue, error if runtime error
function VM:execute_instruction()
   if self.pc < 1 or self.pc > #self.bytecode then
      return false -- Program complete
   end

   local instr = self.bytecode[self.pc]

   if instr.kind == mod.BYTECODE_KIND.LEFT then
      self:place_rail(mod.RAIL_KIND.LEFT)
      self.pc = self.pc + 1
   elseif instr.kind == mod.BYTECODE_KIND.RIGHT then
      self:place_rail(mod.RAIL_KIND.RIGHT)
      self.pc = self.pc + 1
   elseif instr.kind == mod.BYTECODE_KIND.STRAIGHT then
      self:place_rail(mod.RAIL_KIND.STRAIGHT)
      self.pc = self.pc + 1
   elseif instr.kind == mod.BYTECODE_KIND.JNZ then
      self:execute_jnz(instr)
   elseif instr.kind == mod.BYTECODE_KIND.MATH then
      self:execute_math(instr)
   elseif instr.kind == mod.BYTECODE_KIND.CMP then
      self:execute_cmp(instr)
   elseif instr.kind == mod.BYTECODE_KIND.MOV then
      self:execute_mov(instr)
   elseif instr.kind == mod.BYTECODE_KIND.RPUSH then
      local _, err = self:execute_rpush(instr)
      if err then return false, err end
      self.pc = self.pc + 1
   elseif instr.kind == mod.BYTECODE_KIND.RPOP then
      local _, err = self:execute_rpop(instr)
      if err then return false, err end
      self.pc = self.pc + 1
   elseif instr.kind == mod.BYTECODE_KIND.RESET then
      local _, err = self:execute_reset(instr)
      if err then return false, err end
      self.pc = self.pc + 1
   else
      error("Unknown bytecode kind: " .. tostring(instr.kind))
   end

   return true
end

---@param initial_rail number?
---@param initial_hand_direction number?
---@return syntrax.vm.Rail[]?, syntrax.Error?
function VM:run(initial_rail, initial_hand_direction)
   -- Set initial values if provided
   if initial_rail then
      self.initial_rail = initial_rail
      self.parent_rail = initial_rail
   end
   if initial_hand_direction then
      self.initial_hand_direction = initial_hand_direction
      self.hand_direction = initial_hand_direction
   end

   -- Execute instructions until done or error
   while true do
      local continue, err = self:execute_instruction()
      if err then return nil, err end
      if not continue then break end
   end

   return self.rails, nil
end

-- Pretty printing support
function mod.format_operand(operand)
   if operand.kind == mod.OPERAND_KIND.VALUE then
      return string.format("v(%s)", tostring(operand.argument))
   elseif operand.kind == mod.OPERAND_KIND.REGISTER then
      return string.format("r(%d)", operand.argument)
   elseif operand.kind == mod.OPERAND_KIND.MATH_OP then
      return string.format("op(%s)", operand.argument)
   elseif operand.kind == mod.OPERAND_KIND.CMP_OP then
      return string.format("op(%s)", operand.argument)
   else
      return "?"
   end
end

function mod.format_bytecode(bc, index, labels)
   local parts = {}

   -- Add label if present
   if labels and labels[index] then table.insert(parts, labels[index] .. ":") end

   -- Add bytecode kind
   table.insert(parts, string.upper(bc.kind))

   -- Add arguments
   for i, arg in ipairs(bc.arguments) do
      -- Special handling for jump targets
      if bc.kind == mod.BYTECODE_KIND.JNZ and i == 2 and arg.kind == mod.OPERAND_KIND.VALUE then
         -- Try to find label for target
         local target = index + arg.argument
         if labels and labels[target] then
            table.insert(parts, labels[target])
         else
            table.insert(parts, mod.format_operand(arg))
         end
      else
         table.insert(parts, mod.format_operand(arg))
      end
   end

   return table.concat(parts, " ")
end

-- Re-export direction formatting for convenience
mod.format_direction = Directions.to_name

return mod
