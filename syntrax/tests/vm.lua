local lu = require("luaunit")
local serpent = require("serpent")

local Vm = require("syntrax.vm")
local Directions = require("syntrax.directions")

local mod = {}

-- Helper to create bytecode sequences
local function bc(...)
   return Vm.bytecode(...)
end

-- Helper to create values
local function val(n)
   return Vm.value(Vm.VALUE_TYPE.NUMBER, n)
end

-- Helper to create registers
local function reg(n)
   return Vm.register(n)
end

function mod.TestBasicRailPlacement()
   local vm = Vm.new()

   -- Place left, straight, right
   vm.bytecode = {
      bc(Vm.BYTECODE_KIND.LEFT),
      bc(Vm.BYTECODE_KIND.STRAIGHT),
      bc(Vm.BYTECODE_KIND.RIGHT),
   }

   local rails = vm:run()
   assert(rails)

   lu.assertEquals(#rails, 3)

   -- First rail: left turn from north
   lu.assertEquals(rails[1].kind, Vm.RAIL_KIND.LEFT)
   lu.assertNil(rails[1].parent)
   lu.assertEquals(rails[1].incoming_direction, Directions.NORTH)
   lu.assertEquals(rails[1].outgoing_direction, Directions.NORTH_NORTHWEST)

   -- Second rail: straight
   lu.assertEquals(rails[2].kind, Vm.RAIL_KIND.STRAIGHT)
   lu.assertEquals(rails[2].parent, 1)
   lu.assertEquals(rails[2].incoming_direction, Directions.NORTH_NORTHWEST)
   lu.assertEquals(rails[2].outgoing_direction, Directions.NORTH_NORTHWEST)

   -- Third rail: right turn
   lu.assertEquals(rails[3].kind, Vm.RAIL_KIND.RIGHT)
   lu.assertEquals(rails[3].parent, 2)
   lu.assertEquals(rails[3].incoming_direction, Directions.NORTH_NORTHWEST)
   lu.assertEquals(rails[3].outgoing_direction, Directions.NORTH) -- back to north
end

function mod.TestMOVInstruction()
   local vm = Vm.new()

   -- MOV r1, 42
   vm.bytecode = {
      bc(Vm.BYTECODE_KIND.MOV, reg(1), val(42)),
   }

   vm:run()

   lu.assertNotNil(vm.registers[1])
   lu.assertEquals(vm.registers[1].kind, Vm.OPERAND_KIND.VALUE)
   lu.assertEquals(vm.registers[1].argument, 42)
end

function mod.TestMATHInstructions()
   local vm = Vm.new()

   vm.bytecode = {
      -- r1 = 10
      bc(Vm.BYTECODE_KIND.MOV, reg(1), val(10)),
      -- r2 = 5
      bc(Vm.BYTECODE_KIND.MOV, reg(2), val(5)),
      -- r3 = r1 + r2
      bc(Vm.BYTECODE_KIND.MATH, reg(3), reg(1), reg(2), Vm.math_op(Vm.MATH_OP.ADD)),
      -- r4 = r1 - r2
      bc(Vm.BYTECODE_KIND.MATH, reg(4), reg(1), reg(2), Vm.math_op(Vm.MATH_OP.SUB)),
      -- r5 = r1 * r2
      bc(Vm.BYTECODE_KIND.MATH, reg(5), reg(1), reg(2), Vm.math_op(Vm.MATH_OP.MUL)),
      -- r6 = r1 / r2
      bc(Vm.BYTECODE_KIND.MATH, reg(6), reg(1), reg(2), Vm.math_op(Vm.MATH_OP.DIV)),
   }

   vm:run()

   lu.assertEquals(vm.registers[3].argument, 15) -- 10 + 5
   lu.assertEquals(vm.registers[4].argument, 5) -- 10 - 5
   lu.assertEquals(vm.registers[5].argument, 50) -- 10 * 5
   lu.assertEquals(vm.registers[6].argument, 2) -- 10 / 5
end

function mod.TestCMPInstructions()
   local vm = Vm.new()

   vm.bytecode = {
      -- r1 = 10
      bc(Vm.BYTECODE_KIND.MOV, reg(1), val(10)),
      -- r2 = 5
      bc(Vm.BYTECODE_KIND.MOV, reg(2), val(5)),
      -- r3 = (r1 < r2)
      bc(Vm.BYTECODE_KIND.CMP, reg(3), reg(1), reg(2), Vm.cmp_op(Vm.CMP_OP.LT)),
      -- r4 = (r1 > r2)
      bc(Vm.BYTECODE_KIND.CMP, reg(4), reg(1), reg(2), Vm.cmp_op(Vm.CMP_OP.GT)),
      -- r5 = (r1 == r1)
      bc(Vm.BYTECODE_KIND.CMP, reg(5), reg(1), reg(1), Vm.cmp_op(Vm.CMP_OP.EQ)),
      -- r6 = (r1 != r2)
      bc(Vm.BYTECODE_KIND.CMP, reg(6), reg(1), reg(2), Vm.cmp_op(Vm.CMP_OP.NE)),
   }

   vm:run()

   lu.assertEquals(vm.registers[3].argument, 0) -- 10 < 5 is false
   lu.assertEquals(vm.registers[4].argument, 1) -- 10 > 5 is true
   lu.assertEquals(vm.registers[5].argument, 1) -- 10 == 10 is true
   lu.assertEquals(vm.registers[6].argument, 1) -- 10 != 5 is true
end

function mod.TestJNZInstruction()
   local vm = Vm.new()

   vm.bytecode = {
      -- r1 = 1
      bc(Vm.BYTECODE_KIND.MOV, reg(1), val(1)),
      -- JNZ r1, 2 (skip next instruction)
      bc(Vm.BYTECODE_KIND.JNZ, reg(1), val(2)),
      -- This should be skipped
      bc(Vm.BYTECODE_KIND.LEFT),
      -- This should execute
      bc(Vm.BYTECODE_KIND.RIGHT),
   }

   local rails = vm:run()
   assert(rails)

   -- Only one rail should be placed (the right)
   lu.assertEquals(#rails, 1)
   lu.assertEquals(rails[1].kind, Vm.RAIL_KIND.RIGHT)
end

function mod.TestJNZLoop()
   local vm = Vm.new()

   vm.bytecode = {
      -- r1 = 3 (loop counter)
      bc(Vm.BYTECODE_KIND.MOV, reg(1), val(3)),
      -- loop start (index 2)
      bc(Vm.BYTECODE_KIND.LEFT),
      -- r1 = r1 - 1
      bc(Vm.BYTECODE_KIND.MATH, reg(1), reg(1), val(1), Vm.math_op(Vm.MATH_OP.SUB)),
      -- JNZ r1, -2 (jump back to loop start)
      bc(Vm.BYTECODE_KIND.JNZ, reg(1), val(-2)),
   }

   local rails = vm:run()
   assert(rails)

   -- Should place 3 left rails
   lu.assertEquals(#rails, 3)
   for i = 1, 3 do
      lu.assertEquals(rails[i].kind, Vm.RAIL_KIND.LEFT)
   end
end

function mod.TestCompleteCircle()
   -- Test that 16 left turns make a complete circle
   local vm = Vm.new()

   vm.bytecode = {
      -- r1 = 16
      bc(Vm.BYTECODE_KIND.MOV, reg(1), val(16)),
      -- loop: place left
      bc(Vm.BYTECODE_KIND.LEFT),
      -- r1 = r1 - 1
      bc(Vm.BYTECODE_KIND.MATH, reg(1), reg(1), val(1), Vm.math_op(Vm.MATH_OP.SUB)),
      -- JNZ r1, -2
      bc(Vm.BYTECODE_KIND.JNZ, reg(1), val(-2)),
   }

   local rails = vm:run()
   assert(rails)

   lu.assertEquals(#rails, 16)

   -- After 16 left turns, we should be back to north
   lu.assertEquals(rails[16].outgoing_direction, Directions.NORTH)
end

function mod.TestFormatOperand()
   lu.assertEquals(Vm.format_operand(val(42)), "v(42)")
   lu.assertEquals(Vm.format_operand(reg(3)), "r(3)")
end

function mod.TestFormatBytecode()
   -- Test basic instruction
   local left = bc(Vm.BYTECODE_KIND.LEFT)
   lu.assertEquals(Vm.format_bytecode(left, 1), "LEFT")

   -- Test MOV instruction
   local mov = bc(Vm.BYTECODE_KIND.MOV, reg(1), val(42))
   lu.assertEquals(Vm.format_bytecode(mov, 1), "MOV r(1) v(42)")

   -- Test MATH instruction
   local math = bc(Vm.BYTECODE_KIND.MATH, reg(1), reg(2), val(3), Vm.math_op(Vm.MATH_OP.ADD))
   lu.assertEquals(Vm.format_bytecode(math, 1), "MATH r(1) r(2) v(3) op(+)")

   -- Test with labels
   local labels = { [1] = "start", [3] = "loop" }
   lu.assertEquals(Vm.format_bytecode(left, 1, labels), "start: LEFT")

   -- Test JNZ with label reference
   local jnz = bc(Vm.BYTECODE_KIND.JNZ, reg(1), val(2))
   lu.assertEquals(Vm.format_bytecode(jnz, 1, labels), "start: JNZ r(1) loop")
end

function mod.TestErrorHandling()
   local vm = Vm.new()

   -- Test uninitialized register
   vm.bytecode = {
      bc(Vm.BYTECODE_KIND.MATH, reg(1), reg(2), val(1), Vm.math_op(Vm.MATH_OP.ADD)),
   }

   lu.assertError(function()
      vm:run()
   end, "Register r2 not initialized")

   -- Test invalid destination for MATH
   vm = Vm.new()
   vm.bytecode = {
      bc(Vm.BYTECODE_KIND.MATH, val(1), val(2), val(3), Vm.math_op(Vm.MATH_OP.ADD)),
   }

   lu.assertError(function()
      vm:run()
   end, "MATH destination must be a register")
end

function mod.TestFormatDirection()
   -- Test all 16 directions using constants
   lu.assertEquals(Vm.format_direction(Directions.NORTH), "N")
   lu.assertEquals(Vm.format_direction(Directions.NORTH_NORTHEAST), "NNE")
   lu.assertEquals(Vm.format_direction(Directions.NORTHEAST), "NE")
   lu.assertEquals(Vm.format_direction(Directions.EAST_NORTHEAST), "ENE")
   lu.assertEquals(Vm.format_direction(Directions.EAST), "E")
   lu.assertEquals(Vm.format_direction(Directions.EAST_SOUTHEAST), "ESE")
   lu.assertEquals(Vm.format_direction(Directions.SOUTHEAST), "SE")
   lu.assertEquals(Vm.format_direction(Directions.SOUTH_SOUTHEAST), "SSE")
   lu.assertEquals(Vm.format_direction(Directions.SOUTH), "S")
   lu.assertEquals(Vm.format_direction(Directions.SOUTH_SOUTHWEST), "SSW")
   lu.assertEquals(Vm.format_direction(Directions.SOUTHWEST), "SW")
   lu.assertEquals(Vm.format_direction(Directions.WEST_SOUTHWEST), "WSW")
   lu.assertEquals(Vm.format_direction(Directions.WEST), "W")
   lu.assertEquals(Vm.format_direction(Directions.WEST_NORTHWEST), "WNW")
   lu.assertEquals(Vm.format_direction(Directions.NORTHWEST), "NW")
   lu.assertEquals(Vm.format_direction(Directions.NORTH_NORTHWEST), "NNW")

   -- Test invalid direction
   lu.assertEquals(Vm.format_direction(16), "16")
   lu.assertEquals(Vm.format_direction(-1), "-1")
end

return mod
