local lu = require("luaunit")
local serpent = require("serpent")

local Parser = require("syntrax.parser")
local Ast = require("syntrax.ast")
local Errors = require("syntrax.errors")

local mod = {}

-- Helper for successful parse assertions
local function assertParseSuccess(ast, err)
   lu.assertNil(err)
   lu.assertNotNil(ast)
   return ast --[[@as syntrax.ast.Sequence]]
end

-- Helper for error parse assertions
local function assertParseError(ast, err, expected_code)
   lu.assertNil(ast)
   lu.assertNotNil(err)
   assert(err) -- for lua-language-server
   lu.assertEquals(err.code, expected_code)
end

-- Helper to check AST structure without comparing spans
local function check_ast_structure(actual, expected_type, expected_children)
   lu.assertEquals(actual.type, expected_type)
   if expected_children then
      lu.assertEquals(#actual.statements, #expected_children)
      for i, child in ipairs(expected_children) do
         if type(child) == "table" then
            check_ast_structure(actual.statements[i], child.type, child.children)
         else
            lu.assertEquals(actual.statements[i].type, child)
         end
      end
   end
end

function mod.TestParseBasicCommands()
   -- Test single commands
   local ast, err = Parser.parse("l")
   ast = assertParseSuccess(ast, err)
   lu.assertEquals(ast.type, Ast.NODE_TYPE.SEQUENCE)
   lu.assertEquals(#ast.statements, 1)
   lu.assertEquals(ast.statements[1].type, Ast.NODE_TYPE.LEFT)

   ast, err = Parser.parse("r")
   ast = assertParseSuccess(ast, err)
   lu.assertEquals(ast.statements[1].type, Ast.NODE_TYPE.RIGHT)

   ast, err = Parser.parse("s")
   ast = assertParseSuccess(ast, err)
   lu.assertEquals(ast.statements[1].type, Ast.NODE_TYPE.STRAIGHT)
end

function mod.TestParseSequence()
   local ast, err = Parser.parse("l s r")
   ast = assertParseSuccess(ast, err)
   check_ast_structure(ast, Ast.NODE_TYPE.SEQUENCE, {
      Ast.NODE_TYPE.LEFT,
      Ast.NODE_TYPE.STRAIGHT,
      Ast.NODE_TYPE.RIGHT,
   })
end

function mod.TestParseSimpleRepetition()
   local ast, err = Parser.parse("[l s] rep 3")
   ast = assertParseSuccess(ast, err)
   lu.assertEquals(ast.type, Ast.NODE_TYPE.SEQUENCE)
   lu.assertEquals(#ast.statements, 1)

   local rep = ast.statements[1] --[[@as syntrax.ast.Repetition]]
   lu.assertEquals(rep.type, Ast.NODE_TYPE.REPETITION)
   lu.assertEquals(rep.body.type, Ast.NODE_TYPE.SEQUENCE)
   lu.assertEquals(#rep.body.statements, 2)
   lu.assertEquals(rep.body.statements[1].type, Ast.NODE_TYPE.LEFT)
   lu.assertEquals(rep.body.statements[2].type, Ast.NODE_TYPE.STRAIGHT)
end

function mod.TestParseComplexProgram()
   local ast, err = Parser.parse("l l s [r r s] rep 4 s")
   ast = assertParseSuccess(ast, err)

   check_ast_structure(ast, Ast.NODE_TYPE.SEQUENCE, {
      Ast.NODE_TYPE.LEFT,
      Ast.NODE_TYPE.LEFT,
      Ast.NODE_TYPE.STRAIGHT,
      {
         type = Ast.NODE_TYPE.REPETITION,
         -- We'll check the repetition body separately
      },
      Ast.NODE_TYPE.STRAIGHT,
   })

   -- Check the repetition details
   local rep = ast.statements[4] --[[@as syntrax.ast.Repetition]]
   lu.assertEquals(rep.body.type, Ast.NODE_TYPE.SEQUENCE)
   lu.assertEquals(#rep.body.statements, 3)
   lu.assertEquals(rep.body.statements[1].type, Ast.NODE_TYPE.RIGHT)
   lu.assertEquals(rep.body.statements[2].type, Ast.NODE_TYPE.RIGHT)
   lu.assertEquals(rep.body.statements[3].type, Ast.NODE_TYPE.STRAIGHT)
end

function mod.TestParseWithComments()
   -- Comments should be ignored by lexer
   local ast, err = Parser.parse([[
      l s -- turn left then straight
      [r s] rep 2 -- repeat right-straight twice
   ]])
   ast = assertParseSuccess(ast, err)
   lu.assertEquals(#ast.statements, 3)
   lu.assertEquals(ast.statements[3].type, Ast.NODE_TYPE.REPETITION)
end

function mod.TestParseNestedParentheses()
   -- Test that square brackets without rep are handled
   local ast, err = Parser.parse("l [s r] l")
   ast = assertParseSuccess(ast, err)
   check_ast_structure(ast, Ast.NODE_TYPE.SEQUENCE, {
      Ast.NODE_TYPE.LEFT,
      {
         type = Ast.NODE_TYPE.SEQUENCE,
         children = {
            Ast.NODE_TYPE.STRAIGHT,
            Ast.NODE_TYPE.RIGHT,
         },
      },
      Ast.NODE_TYPE.LEFT,
   })
end

function mod.TestSpanMerging()
   -- Test that spans are properly merged
   local ast, err = Parser.parse("l s r")
   ast = assertParseSuccess(ast, err)

   -- The program span should cover from 'l' to 'r'
   local l1, c1, l2, c2 = ast.span:get_printable_range()
   lu.assertEquals(c1, 1) -- starts at 'l'
   lu.assertEquals(c2, 5) -- ends at 'r'

   -- Test repetition span
   ast, err = Parser.parse("[l s] rep 3")
   ast = assertParseSuccess(ast, err)
   local rep = ast.statements[1]
   l1, c1, l2, c2 = rep.span:get_printable_range()
   lu.assertEquals(c1, 1) -- starts at '['
   lu.assertEquals(c2, 11) -- ends at '3'
end

-- Error cases
function mod.TestParseErrors()
   -- Empty program is now allowed
   local ast, err = Parser.parse("")
   ast = assertParseSuccess(ast, err)
   lu.assertEquals(#ast.statements, 0)

   -- Empty brackets are now allowed
   ast, err = Parser.parse("[] rep 3")
   ast = assertParseSuccess(ast, err)
   lu.assertEquals(ast.statements[1].type, Ast.NODE_TYPE.REPETITION)
   local rep = ast.statements[1] --[[@as syntrax.ast.Repetition]]
   lu.assertEquals(#rep.body.statements, 0)

   -- Missing number after rep
   ast, err = Parser.parse("[l s] rep")
   assertParseError(ast, err, Errors.ERROR_CODE.EXPECTED_NUMBER)

   -- Invalid token
   ast, err = Parser.parse("l s foo")
   assertParseError(ast, err, Errors.ERROR_CODE.UNEXPECTED_TOKEN)

   -- Rep without number
   ast, err = Parser.parse("[l s] rep r")
   assertParseError(ast, err, Errors.ERROR_CODE.EXPECTED_NUMBER)

   -- Parentheses not allowed
   ast, err = Parser.parse("(l s) rep 3")
   assertParseError(ast, err, Errors.ERROR_CODE.UNEXPECTED_TOKEN)

   -- Curly braces not allowed
   ast, err = Parser.parse("{l s} rep 3")
   assertParseError(ast, err, Errors.ERROR_CODE.UNEXPECTED_TOKEN)
end

function mod.TestEndToEndParsing()
   -- Test the full pipeline from text to AST
   local test_cases = {
      { input = "", expected_count = 0 }, -- Empty program
      { input = "l", expected_count = 1 },
      { input = "l s r", expected_count = 3 },
      { input = "[l s] rep 5", expected_count = 1 }, -- One repetition node
      { input = "l [s r] rep 2 s", expected_count = 3 }, -- l, rep, s
      { input = "l l s [r r s] rep 4 s", expected_count = 5 },
      { input = "[] rep 10", expected_count = 1 }, -- Empty sequence repetition
   }

   for _, tc in ipairs(test_cases) do
      local ast, err = Parser.parse(tc.input)
      ast = assertParseSuccess(ast, err)
      lu.assertEquals(#ast.statements, tc.expected_count, string.format("Wrong statement count for: %s", tc.input))
   end
end

return mod
