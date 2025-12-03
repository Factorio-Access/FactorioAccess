--[[
Virtual Machine for Syntrax language.

Executes bytecode to produce a list of rail placements with positions.
Uses railutils.Traverser for computing rail geometry.
]]

require("polyfill")

local Directions = require("syntrax.directions")
local Errors = require("syntrax.errors")
local Traverser = require("railutils.traverser")
local RailInfo = require("railutils.rail-info")

local mod = {}

---@enum syntrax.vm.OperandKind
mod.OPERAND_KIND = {
   VALUE = "value",
   REGISTER = "register",
   MATH_OP = "math_op",
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
   FLIP = "flip",
   JNZ = "jnz",
   MATH = "math",
   MOV = "mov",
   RPUSH = "rpush",
   RPOP = "rpop",
   RESET = "reset",
   -- Signal commands
   SIGLEFT = "sigleft",
   SIGRIGHT = "sigright",
   CHAINLEFT = "chainleft",
   CHAINRIGHT = "chainright",
   SIG = "sig",
   CHAIN = "chain",
   SIGCHAIN = "sigchain",
   CHAINSIG = "chainsig",
}

---@enum syntrax.vm.MathOp
mod.MATH_OP = {
   ADD = "+",
   SUB = "-",
   MUL = "*",
   DIV = "/",
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

---@class syntrax.vm.RailPlacement
---@field type "rail" Discriminator for placement type
---@field position fa.Point Position where the rail should be placed
---@field rail_type string "straight-rail", "curved-rail-a", "curved-rail-b", or "half-diagonal-rail"
---@field placement_direction number 0-15 direction for placement
---@field span syntrax.Span? Source span for error reporting

---@class syntrax.vm.SignalPlacement
---@field type "signal" Discriminator for placement type
---@field position fa.Point Position where the signal should be placed
---@field signal_type "rail-signal"|"rail-chain-signal" Type of signal to place
---@field direction number 0-15 direction for placement
---@field span syntrax.Span? Source span for error reporting

---@alias syntrax.vm.Placement syntrax.vm.RailPlacement|syntrax.vm.SignalPlacement
---@alias syntrax.vm.PlacementGroup syntrax.vm.Placement[][] Array of alternatives, each alternative is an array of placements

---@class syntrax.vm.RailStackEntry
---@field traverser railutils.Traverser Cloned traverser state

---@class syntrax.vm.State
---@field registers table<number, syntrax.vm.Operand> Array of registers
---@field bytecode syntrax.vm.Bytecode[] Array of bytecode instructions
---@field placements syntrax.vm.PlacementGroup[] Output list of placement groups (each group has alternatives)
---@field pc number Program counter
---@field traverser railutils.Traverser? Current traverser (nil until first rail)
---@field position_to_index table<string, number> Position key to rail index for dedup
---@field rail_stack syntrax.vm.RailStackEntry[] Stack of saved traverser states
---@field initial_traverser railutils.Traverser? Initial traverser for reset

local VM = {}
local VM_meta = { __index = VM }

---Create a key for deduplication (position + direction + rail type)
---@param pos fa.Point
---@param direction number
---@param rail_type string
---@return string
local function dedup_key(pos, direction, rail_type)
   return string.format("%d,%d,%d,%s", pos.x, pos.y, direction, rail_type)
end

---@return syntrax.vm.State
function mod.new()
   return setmetatable({
      registers = {},
      bytecode = {},
      placements = {},
      pc = 1,
      traverser = nil, -- Initialized on first rail or via run()
      position_to_index = {},
      rail_stack = {},
      initial_traverser = nil,
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
   elseif operand.kind == mod.OPERAND_KIND.MATH_OP then
      -- Operations are not resolved, they're used directly
      return operand
   else
      error("Unknown operand kind: " .. tostring(operand.kind))
   end
end

---Place a rail and update traverser state
---@param kind syntrax.vm.RailKind "left", "right", or "straight"
---@param span syntrax.Span? Source span for error reporting
function VM:place_rail(kind, span)
   -- Move the traverser based on rail kind
   if kind == mod.RAIL_KIND.LEFT then
      self.traverser:move_left()
   elseif kind == mod.RAIL_KIND.RIGHT then
      self.traverser:move_right()
   else -- STRAIGHT
      self.traverser:move_forward()
   end

   -- Get the new rail info from traverser
   local pos = self.traverser:get_position()
   local rail_type = self.traverser:get_rail_kind()
   local placement_dir = self.traverser:get_placement_direction()

   -- Create dedup key including position, direction, and rail type
   local key = dedup_key(pos, placement_dir, rail_type)

   -- Check for deduplication - if we've already placed this exact rail, skip
   if self.position_to_index[key] then
      return -- Already have this exact rail
   end

   local rail = {
      type = "rail",
      position = pos,
      rail_type = rail_type, -- Already a string like "straight-rail"
      placement_direction = placement_dir,
      span = span,
   }

   -- Wrap in new format: one group with one alternative containing one entity
   table.insert(self.placements, { { rail } })
   self.position_to_index[key] = #self.placements
end

---Place a single signal with alternatives for regular/alt positions
---@param side railutils.SignalSide LEFT or RIGHT
---@param signal_type "rail-signal"|"rail-chain-signal"
---@param span syntrax.Span?
function VM:place_signal(side, signal_type, span)
   local alternatives = {}

   -- Regular position (always exists)
   local pos = self.traverser:get_signal_pos(side)
   local dir = self.traverser:get_signal_direction(side)
   table.insert(alternatives, {
      {
         type = "signal",
         position = pos,
         signal_type = signal_type,
         direction = dir,
         span = span,
      },
   })

   -- Alt position (may not exist)
   local alt_pos = self.traverser:get_alt_signal_pos(side)
   if alt_pos then
      table.insert(alternatives, {
         {
            type = "signal",
            position = alt_pos,
            signal_type = signal_type,
            direction = dir, -- Same direction as regular
            span = span,
         },
      })
   end

   table.insert(self.placements, alternatives)
end

---Place a pair of signals with all valid alternative combinations
---@param left_type "rail-signal"|"rail-chain-signal"
---@param right_type "rail-signal"|"rail-chain-signal"
---@param span syntrax.Span?
function VM:place_signal_pair(left_type, right_type, span)
   local left_pos = self.traverser:get_signal_pos(Traverser.SignalSide.LEFT)
   local right_pos = self.traverser:get_signal_pos(Traverser.SignalSide.RIGHT)
   local left_dir = self.traverser:get_signal_direction(Traverser.SignalSide.LEFT)
   local right_dir = self.traverser:get_signal_direction(Traverser.SignalSide.RIGHT)
   local left_alt = self.traverser:get_alt_signal_pos(Traverser.SignalSide.LEFT)
   local right_alt = self.traverser:get_alt_signal_pos(Traverser.SignalSide.RIGHT)

   -- Build list of left positions
   local left_positions = { { pos = left_pos } }
   if left_alt then table.insert(left_positions, { pos = left_alt }) end

   -- Build list of right positions
   local right_positions = { { pos = right_pos } }
   if right_alt then table.insert(right_positions, { pos = right_alt }) end

   -- Generate cartesian product of alternatives
   local alternatives = {}
   for _, lp in ipairs(left_positions) do
      for _, rp in ipairs(right_positions) do
         table.insert(alternatives, {
            {
               type = "signal",
               position = lp.pos,
               signal_type = left_type,
               direction = left_dir,
               span = span,
            },
            {
               type = "signal",
               position = rp.pos,
               signal_type = right_type,
               direction = right_dir,
               span = span,
            },
         })
      end
   end

   table.insert(self.placements, alternatives)
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
   -- Push a clone of the current traverser to the stack
   local entry = {
      traverser = self.traverser:clone(),
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

   -- Pop and restore the traverser
   local entry = table.remove(self.rail_stack)
   self.traverser = entry.traverser
   return nil, nil
end

---@param instr syntrax.vm.Bytecode
---@return nil, syntrax.Error?
function VM:execute_reset(instr)
   -- Clear the rail stack
   self.rail_stack = {}
   -- Return to initial position by restoring from initial_traverser
   if self.initial_traverser then self.traverser = self.initial_traverser:clone() end
   return nil, nil
end

---@param instr syntrax.vm.Bytecode
---@return nil, syntrax.Error?
function VM:execute_flip(instr)
   -- Flip to the other end of the current rail
   self.traverser:flip_ends()
   return nil, nil
end

---@return boolean, syntrax.Error? True if execution should continue, error if runtime error
function VM:execute_instruction()
   if self.pc < 1 or self.pc > #self.bytecode then
      return false -- Program complete
   end

   local instr = self.bytecode[self.pc]

   if instr.kind == mod.BYTECODE_KIND.LEFT then
      self:place_rail(mod.RAIL_KIND.LEFT, instr.span)
      self.pc = self.pc + 1
   elseif instr.kind == mod.BYTECODE_KIND.RIGHT then
      self:place_rail(mod.RAIL_KIND.RIGHT, instr.span)
      self.pc = self.pc + 1
   elseif instr.kind == mod.BYTECODE_KIND.STRAIGHT then
      self:place_rail(mod.RAIL_KIND.STRAIGHT, instr.span)
      self.pc = self.pc + 1
   elseif instr.kind == mod.BYTECODE_KIND.FLIP then
      local _, err = self:execute_flip(instr)
      if err then return false, err end
      self.pc = self.pc + 1
   elseif instr.kind == mod.BYTECODE_KIND.JNZ then
      self:execute_jnz(instr)
   elseif instr.kind == mod.BYTECODE_KIND.MATH then
      self:execute_math(instr)
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
   elseif instr.kind == mod.BYTECODE_KIND.SIGLEFT then
      self:place_signal(Traverser.SignalSide.LEFT, "rail-signal", instr.span)
      self.pc = self.pc + 1
   elseif instr.kind == mod.BYTECODE_KIND.SIGRIGHT then
      self:place_signal(Traverser.SignalSide.RIGHT, "rail-signal", instr.span)
      self.pc = self.pc + 1
   elseif instr.kind == mod.BYTECODE_KIND.CHAINLEFT then
      self:place_signal(Traverser.SignalSide.LEFT, "rail-chain-signal", instr.span)
      self.pc = self.pc + 1
   elseif instr.kind == mod.BYTECODE_KIND.CHAINRIGHT then
      self:place_signal(Traverser.SignalSide.RIGHT, "rail-chain-signal", instr.span)
      self.pc = self.pc + 1
   elseif instr.kind == mod.BYTECODE_KIND.SIG then
      self:place_signal_pair("rail-signal", "rail-signal", instr.span)
      self.pc = self.pc + 1
   elseif instr.kind == mod.BYTECODE_KIND.CHAIN then
      self:place_signal_pair("rail-chain-signal", "rail-chain-signal", instr.span)
      self.pc = self.pc + 1
   elseif instr.kind == mod.BYTECODE_KIND.SIGCHAIN then
      self:place_signal_pair("rail-signal", "rail-chain-signal", instr.span)
      self.pc = self.pc + 1
   elseif instr.kind == mod.BYTECODE_KIND.CHAINSIG then
      self:place_signal_pair("rail-chain-signal", "rail-signal", instr.span)
      self.pc = self.pc + 1
   else
      error("Unknown bytecode kind: " .. tostring(instr.kind))
   end

   return true
end

---Run the VM with the given starting position
---@param initial_position fa.Point? Starting position (default: {x=0, y=0})
---@param initial_direction number? Starting direction 0-15 (default: north/0)
---@return syntrax.vm.PlacementGroup[]?, syntrax.Error?
function VM:run(initial_position, initial_direction)
   -- Default to origin facing north
   local pos = initial_position or { x = 0, y = 0 }
   local dir = initial_direction or Directions.NORTH

   -- Create the initial traverser at a straight rail at the starting position/direction
   -- This represents "standing at the end of a straight rail facing dir"
   self.traverser = Traverser.new(RailInfo.RailType.STRAIGHT, pos, dir)
   self.initial_traverser = self.traverser:clone()

   -- Execute instructions until done or error
   while true do
      local continue, err = self:execute_instruction()
      if err then return nil, err end
      if not continue then break end
   end

   return self.placements, nil
end

-- Pretty printing support
function mod.format_operand(operand)
   if operand.kind == mod.OPERAND_KIND.VALUE then
      return string.format("v(%s)", tostring(operand.argument))
   elseif operand.kind == mod.OPERAND_KIND.REGISTER then
      return string.format("r(%d)", operand.argument)
   elseif operand.kind == mod.OPERAND_KIND.MATH_OP then
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
