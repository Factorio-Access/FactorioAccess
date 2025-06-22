local lu = require("luaunit")

local Ast = require("syntrax.ast")
local Span = require("syntrax.span")

local mod = {}

-- Helper to create dummy spans for testing
local function test_span(text)
   return Span.new(text or "test", 1, 1)
end

function mod.TestBasicNodes()
   -- Test creating basic direction nodes
   local left = Ast.left(test_span("l"))
   lu.assertEquals(left.type, Ast.NODE_TYPE.LEFT)
   lu.assertNotNil(left.span)

   local right = Ast.right(test_span("r"))
   lu.assertEquals(right.type, Ast.NODE_TYPE.RIGHT)
   lu.assertNotNil(right.span)

   local straight = Ast.straight(test_span("s"))
   lu.assertEquals(straight.type, Ast.NODE_TYPE.STRAIGHT)
   lu.assertNotNil(straight.span)
end

function mod.TestSequenceNode()
   local s1 = Ast.left(test_span("l"))
   local s2 = Ast.right(test_span("r"))
   local s3 = Ast.straight(test_span("s"))

   local seq = Ast.sequence({ s1, s2, s3 }, test_span("l r s"))
   lu.assertEquals(seq.type, Ast.NODE_TYPE.SEQUENCE)
   lu.assertEquals(#seq.statements, 3)
   lu.assertEquals(seq.statements[1].type, Ast.NODE_TYPE.LEFT)
   lu.assertEquals(seq.statements[2].type, Ast.NODE_TYPE.RIGHT)
   lu.assertEquals(seq.statements[3].type, Ast.NODE_TYPE.STRAIGHT)
end

function mod.TestRepetitionNode()
   local body = Ast.sequence({
      Ast.left(test_span("l")),
      Ast.straight(test_span("s")),
   }, test_span("l s"))

   local rep = Ast.repetition(body, 5, test_span("(l s) rep 5"))
   lu.assertEquals(rep.type, Ast.NODE_TYPE.REPETITION)
   lu.assertEquals(rep.count, 5)
   lu.assertEquals(#rep.body.statements, 2)
   lu.assertEquals(rep.body.type, Ast.NODE_TYPE.SEQUENCE)
end

function mod.TestComplexAST()
   -- Test representing: l l s (r r s) rep 4 s
   local ast = Ast.sequence({
      Ast.left(test_span("l")),
      Ast.left(test_span("l")),
      Ast.straight(test_span("s")),
      Ast.repetition(
         Ast.sequence({
            Ast.right(test_span("r")),
            Ast.right(test_span("r")),
            Ast.straight(test_span("s")),
         }, test_span("r r s")),
         4,
         test_span("(r r s) rep 4")
      ),
      Ast.straight(test_span("s")),
   }, test_span("l l s (r r s) rep 4 s"))

   lu.assertEquals(ast.type, Ast.NODE_TYPE.SEQUENCE)
   lu.assertEquals(#ast.statements, 5)

   -- Check the repetition node
   ---@type syntrax.ast.Repetition
   local rep = ast.statements[4] --[[@as syntrax.ast.Repetition]]
   lu.assertEquals(rep.type, Ast.NODE_TYPE.REPETITION)
   lu.assertEquals(rep.body.type, Ast.NODE_TYPE.SEQUENCE)
   lu.assertEquals(#rep.body.statements, 3)
end

return mod
