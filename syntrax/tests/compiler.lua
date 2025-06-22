local lu = require("luaunit")

local Compiler = require("syntrax.compiler")
local Parser = require("syntrax.parser")
local Vm = require("syntrax.vm")
local Directions = require("syntrax.directions")

local mod = {}

-- Helper to compile from source
local function compile_source(source)
   local ast, err = Parser.parse(source)
   if err then error("Parse error: " .. err.message) end
   assert(ast, "Parser returned nil AST without error")
   return Compiler.compile(ast)
end

-- Helper to run compiled bytecode
local function run_bytecode(bytecode)
   local vm = Vm.new()
   vm.bytecode = bytecode
   return vm:run()
end

-- Helper to compile and run
local function compile_and_run(source)
   return run_bytecode(compile_source(source))
end

function mod.TestSimpleCommands()
   -- Test single commands
   local bytecode = compile_source("l")
   lu.assertEquals(#bytecode, 1)
   lu.assertEquals(bytecode[1].kind, Vm.BYTECODE_KIND.LEFT)

   bytecode = compile_source("r")
   lu.assertEquals(#bytecode, 1)
   lu.assertEquals(bytecode[1].kind, Vm.BYTECODE_KIND.RIGHT)

   bytecode = compile_source("s")
   lu.assertEquals(#bytecode, 1)
   lu.assertEquals(bytecode[1].kind, Vm.BYTECODE_KIND.STRAIGHT)
end

function mod.TestSequence()
   local bytecode = compile_source("l r s")
   lu.assertEquals(#bytecode, 3)
   lu.assertEquals(bytecode[1].kind, Vm.BYTECODE_KIND.LEFT)
   lu.assertEquals(bytecode[2].kind, Vm.BYTECODE_KIND.RIGHT)
   lu.assertEquals(bytecode[3].kind, Vm.BYTECODE_KIND.STRAIGHT)
end

function mod.TestEmptySequence()
   local bytecode = compile_source("[]")
   lu.assertEquals(#bytecode, 0)
end

function mod.TestNestedSequence()
   local bytecode = compile_source("[l [r s] l]")
   lu.assertEquals(#bytecode, 4)
   lu.assertEquals(bytecode[1].kind, Vm.BYTECODE_KIND.LEFT)
   lu.assertEquals(bytecode[2].kind, Vm.BYTECODE_KIND.RIGHT)
   lu.assertEquals(bytecode[3].kind, Vm.BYTECODE_KIND.STRAIGHT)
   lu.assertEquals(bytecode[4].kind, Vm.BYTECODE_KIND.LEFT)
end

function mod.TestSimpleRepetition()
   local bytecode = compile_source("[l] rep 3")

   -- Should generate:
   -- MOV r1, 3
   -- L2: LEFT
   -- MATH r1, r1, 1, -
   -- JNZ r1, -2

   lu.assertEquals(#bytecode, 4)

   -- MOV instruction
   lu.assertEquals(bytecode[1].kind, Vm.BYTECODE_KIND.MOV)
   lu.assertEquals(bytecode[1].arguments[1].kind, Vm.OPERAND_KIND.REGISTER)
   lu.assertEquals(bytecode[1].arguments[2].kind, Vm.OPERAND_KIND.VALUE)
   lu.assertEquals(bytecode[1].arguments[2].argument, 3)

   -- LEFT instruction
   lu.assertEquals(bytecode[2].kind, Vm.BYTECODE_KIND.LEFT)

   -- MATH instruction (decrement)
   lu.assertEquals(bytecode[3].kind, Vm.BYTECODE_KIND.MATH)
   lu.assertEquals(bytecode[3].arguments[4].argument, Vm.MATH_OP.SUB)

   -- JNZ instruction
   lu.assertEquals(bytecode[4].kind, Vm.BYTECODE_KIND.JNZ)
   lu.assertEquals(bytecode[4].arguments[2].argument, -2) -- Jump back to LEFT
end

function mod.TestSequenceRepetition()
   local bytecode = compile_source("[l r] rep 2")

   -- Should generate:
   -- MOV r1, 2
   -- L2: LEFT
   -- RIGHT
   -- MATH r1, r1, 1, -
   -- JNZ r1, -3

   lu.assertEquals(#bytecode, 5)
   lu.assertEquals(bytecode[1].kind, Vm.BYTECODE_KIND.MOV)
   lu.assertEquals(bytecode[2].kind, Vm.BYTECODE_KIND.LEFT)
   lu.assertEquals(bytecode[3].kind, Vm.BYTECODE_KIND.RIGHT)
   lu.assertEquals(bytecode[4].kind, Vm.BYTECODE_KIND.MATH)
   lu.assertEquals(bytecode[5].kind, Vm.BYTECODE_KIND.JNZ)
   lu.assertEquals(bytecode[5].arguments[2].argument, -3) -- Jump back to LEFT
end

function mod.TestNestedRepetition()
   local bytecode = compile_source("[[l] rep 2] rep 3")

   -- This should use two different registers for the two loops
   lu.assertEquals(bytecode[1].kind, Vm.BYTECODE_KIND.MOV) -- Outer loop counter
   lu.assertEquals(bytecode[1].arguments[2].argument, 3)

   lu.assertEquals(bytecode[2].kind, Vm.BYTECODE_KIND.MOV) -- Inner loop counter
   lu.assertEquals(bytecode[2].arguments[2].argument, 2)

   -- Make sure different registers are used
   local outer_reg = bytecode[1].arguments[1].argument
   local inner_reg = bytecode[2].arguments[1].argument
   lu.assertNotEquals(outer_reg, inner_reg)
end

function mod.TestExecutionSimple()
   local rails = compile_and_run("l r s")
   lu.assertEquals(#rails, 3)
   lu.assertEquals(rails[1].kind, Vm.RAIL_KIND.LEFT)
   lu.assertEquals(rails[2].kind, Vm.RAIL_KIND.RIGHT)
   lu.assertEquals(rails[3].kind, Vm.RAIL_KIND.STRAIGHT)
end

function mod.TestExecutionRepetition()
   local rails = compile_and_run("[l] rep 4")
   lu.assertEquals(#rails, 4)
   for i = 1, 4 do
      lu.assertEquals(rails[i].kind, Vm.RAIL_KIND.LEFT)
   end
end

function mod.TestExecutionCompleteCircle()
   -- 16 left turns should make a complete circle
   local rails = compile_and_run("[l] rep 16")
   lu.assertEquals(#rails, 16)
   lu.assertEquals(rails[16].outgoing_direction, Directions.NORTH)
end

function mod.TestExecutionSquare()
   -- Four sides with right turns
   local rails = compile_and_run("[[s s s s] [r r r r]] rep 4")
   lu.assertEquals(#rails, 32) -- 8 rails per side * 4 sides

   -- Should end up back at north
   lu.assertEquals(rails[32].outgoing_direction, Directions.NORTH)
end

function mod.TestBytecodeListing()
   local bytecode = compile_source("[l r] rep 3")
   local listing = Compiler.format_bytecode_listing(bytecode)

   -- Check that it includes line numbers and labels
   lu.assertStrContains(listing, "1:")
   lu.assertStrContains(listing, "L2:")
   lu.assertStrContains(listing, "JNZ")
end

function mod.TestEmptyProgram()
   local bytecode = compile_source("")
   lu.assertEquals(#bytecode, 0)

   local rails = compile_and_run("")
   lu.assertEquals(#rails, 0)
end

function mod.TestComplexProgram()
   -- Test from the original example
   local source = [[
l s r
[l l s] rep 8
l [s r] rep 2 s
[]
[] rep 5
]]

   local bytecode = compile_source(source)
   lu.assertTrue(#bytecode > 0)

   local rails = compile_and_run(source)
   lu.assertTrue(#rails > 0)

   -- Verify it runs without errors
   local listing = Compiler.format_bytecode_listing(bytecode)
   lu.assertNotNil(listing)
end

return mod
