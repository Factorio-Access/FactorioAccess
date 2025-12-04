local lu = require("luaunit")

local Lexer = require("syntrax.lexer")
local Parser = require("syntrax.parser")
local Ast = require("syntrax.ast")
local TestHelpers = require("syntrax.tests.helpers")

local mod = {}

-- Test the is_chord_string function
function mod.TestIsChordString()
   -- Valid chord strings
   lu.assertTrue(Lexer._is_chord_string("l"))
   lu.assertTrue(Lexer._is_chord_string("r"))
   lu.assertTrue(Lexer._is_chord_string("s"))
   lu.assertTrue(Lexer._is_chord_string("f"))
   lu.assertTrue(Lexer._is_chord_string("m"))
   lu.assertTrue(Lexer._is_chord_string(";"))
   lu.assertTrue(Lexer._is_chord_string("l45"))
   lu.assertTrue(Lexer._is_chord_string("r45"))
   lu.assertTrue(Lexer._is_chord_string("l90"))
   lu.assertTrue(Lexer._is_chord_string("r90"))
   lu.assertTrue(Lexer._is_chord_string("x5"))
   lu.assertTrue(Lexer._is_chord_string("x123"))

   -- Multi-token chord strings
   lu.assertTrue(Lexer._is_chord_string("lrs"))
   lu.assertTrue(Lexer._is_chord_string("lrsx5"))
   lu.assertTrue(Lexer._is_chord_string("l90x2"))
   lu.assertTrue(Lexer._is_chord_string("fx3"))
   lu.assertTrue(Lexer._is_chord_string(";x5"))
   lu.assertTrue(Lexer._is_chord_string("lrsf;"))
   lu.assertTrue(Lexer._is_chord_string("lrsm"))

   -- Invalid chord strings
   lu.assertFalse(Lexer._is_chord_string("flip")) -- Full word, not chord token
   lu.assertFalse(Lexer._is_chord_string("reset"))
   lu.assertFalse(Lexer._is_chord_string("mark")) -- Full word, not chord token
   lu.assertFalse(Lexer._is_chord_string("rpush"))
   lu.assertFalse(Lexer._is_chord_string("rpop"))
   lu.assertFalse(Lexer._is_chord_string("abc"))
   lu.assertFalse(Lexer._is_chord_string("123")) -- Just a number
   lu.assertFalse(Lexer._is_chord_string("x")) -- x without number
end

-- Test the split_chord function
function mod.TestSplitChord()
   local text = "lrsx5"
   local tokens, _ = Lexer.tokenize(text)
   lu.assertNotNil(tokens)
   lu.assertEquals(#tokens, 5)
   lu.assertEquals(tokens[1].type, "l")
   lu.assertEquals(tokens[2].type, "r")
   lu.assertEquals(tokens[3].type, "s")
   lu.assertEquals(tokens[4].type, "x")
   lu.assertEquals(tokens[5].type, "number")
   lu.assertEquals(tokens[5].value, "5")
end

-- Test that l90 is a single token, not l + 90
function mod.TestL90SingleToken()
   local text = "l90"
   local tokens, _ = Lexer.tokenize(text)
   lu.assertNotNil(tokens)
   lu.assertEquals(#tokens, 1)
   lu.assertEquals(tokens[1].type, "l90")
end

-- Test chord with l90
function mod.TestChordWithL90()
   local text = "l90x2"
   local tokens, _ = Lexer.tokenize(text)
   lu.assertNotNil(tokens)
   lu.assertEquals(#tokens, 3)
   lu.assertEquals(tokens[1].type, "l90")
   lu.assertEquals(tokens[2].type, "x")
   lu.assertEquals(tokens[3].type, "number")
   lu.assertEquals(tokens[3].value, "2")
end

-- Test the f alias for flip
function mod.TestFAliasForFlip()
   local text = "f"
   local tokens, _ = Lexer.tokenize(text)
   lu.assertNotNil(tokens)
   lu.assertEquals(#tokens, 1)
   lu.assertEquals(tokens[1].type, "flip")

   -- Also test as part of chord
   text = "lfs"
   tokens, _ = Lexer.tokenize(text)
   lu.assertNotNil(tokens)
   lu.assertEquals(#tokens, 3)
   lu.assertEquals(tokens[1].type, "l")
   lu.assertEquals(tokens[2].type, "flip")
   lu.assertEquals(tokens[3].type, "s")
end

-- Test semicolon alias for reset in chords
function mod.TestSemicolonInChord()
   local text = ";s"
   local tokens, _ = Lexer.tokenize(text)
   lu.assertNotNil(tokens)
   lu.assertEquals(#tokens, 2)
   lu.assertEquals(tokens[1].type, "reset")
   lu.assertEquals(tokens[2].type, "s")
end

-- Test parser: primitive x number creates repetition with implicit sequence
function mod.TestPrimitiveWithMultiplier()
   local ast, err = Parser.parse("sx5")
   lu.assertNil(err)
   lu.assertNotNil(ast)
   lu.assertEquals(ast.type, Ast.NODE_TYPE.SEQUENCE)
   lu.assertEquals(#ast.statements, 1)

   local rep = ast.statements[1]
   lu.assertEquals(rep.type, Ast.NODE_TYPE.REPETITION)
   lu.assertEquals(rep.count, 5)
   lu.assertEquals(rep.body.type, Ast.NODE_TYPE.IMPLICIT_SEQUENCE)
   lu.assertEquals(#rep.body.statements, 1)
   lu.assertEquals(rep.body.statements[1].type, Ast.NODE_TYPE.STRAIGHT)
end

-- Test parser: lrsx5 = l r [s] x 5
function mod.TestChordMultiplierOnlyLastToken()
   local ast, err = Parser.parse("lrsx5")
   lu.assertNil(err)
   lu.assertNotNil(ast)
   lu.assertEquals(ast.type, Ast.NODE_TYPE.SEQUENCE)
   lu.assertEquals(#ast.statements, 3)

   lu.assertEquals(ast.statements[1].type, Ast.NODE_TYPE.LEFT)
   lu.assertEquals(ast.statements[2].type, Ast.NODE_TYPE.RIGHT)

   local rep = ast.statements[3]
   lu.assertEquals(rep.type, Ast.NODE_TYPE.REPETITION)
   lu.assertEquals(rep.count, 5)
end

-- Test end-to-end: spacing equivalence
function mod.TestSpacingEquivalence()
   -- These should all produce the same result
   local sources = {
      "lrsx5",
      "l r s x 5",
      "l r s x5",
      "lrs x5",
      "l rs x 5",
   }

   local reference_rails = TestHelpers.assert_compilation_succeeds(sources[1])

   for i = 2, #sources do
      local rails = TestHelpers.assert_compilation_succeeds(sources[i])
      lu.assertEquals(#rails, #reference_rails, string.format("Source '%s' rail count mismatch", sources[i]))
   end
end

-- Test end-to-end: l90x2 produces 8 rails (l90 = 4 left turns, x2)
function mod.TestL90Repetition()
   local rails = TestHelpers.assert_compilation_succeeds("l90x2")
   -- l90 = 4 lefts, x2 = 8 lefts total
   lu.assertEquals(#rails, 8)
end

-- Test end-to-end: fx3 produces 0 rails (flip doesn't produce rails, but should not error)
function mod.TestFlipRepetition()
   local rails = TestHelpers.assert_compilation_succeeds("fx3")
   lu.assertEquals(#rails, 0) -- flip doesn't produce rails
end

-- Test error: x without preceding bracket or primitive should fail
function mod.TestXWithoutPrimitive()
   TestHelpers.assert_compilation_fails("x5", "unexpected_token")
end

-- Test that non-chord tokens still require spaces
function mod.TestNonChordTokensRequireSpaces()
   -- "flipreset" should be tokenized as a single identifier, which is an error
   TestHelpers.assert_compilation_fails("flipreset", "unexpected_token")
end

-- Test m is a valid chord token (alias for mark)
function mod.TestMIsChordToken()
   lu.assertTrue(Lexer._is_chord_string("m"))
   lu.assertTrue(Lexer._is_chord_string("lrsm"))
   lu.assertTrue(Lexer._is_chord_string("mx3"))
end

-- Test m alias for mark tokenizes correctly
function mod.TestMAliasForMark()
   local text = "m"
   local tokens, _ = Lexer.tokenize(text)
   lu.assertNotNil(tokens)
   lu.assertEquals(#tokens, 1)
   lu.assertEquals(tokens[1].type, "mark")

   -- Also test as part of chord
   text = "lms"
   tokens, _ = Lexer.tokenize(text)
   lu.assertNotNil(tokens)
   lu.assertEquals(#tokens, 3)
   lu.assertEquals(tokens[1].type, "l")
   lu.assertEquals(tokens[2].type, "mark")
   lu.assertEquals(tokens[3].type, "s")
end

-- Test mark in parser
function mod.TestMarkParsing()
   local ast, err = Parser.parse("s mark s")
   lu.assertNil(err)
   lu.assertNotNil(ast)
   lu.assertEquals(#ast.statements, 3)
   lu.assertEquals(ast.statements[1].type, Ast.NODE_TYPE.STRAIGHT)
   lu.assertEquals(ast.statements[2].type, Ast.NODE_TYPE.MARK)
   lu.assertEquals(ast.statements[3].type, Ast.NODE_TYPE.STRAIGHT)
end

-- Test mark and reset work together
function mod.TestMarkAndReset()
   -- s mark l ; r produces:
   -- s: straight from start
   -- mark: set mark
   -- l: left turn
   -- ;: reset to mark
   -- r: right turn (different direction than l, so different rail)
   local rails = TestHelpers.assert_compilation_succeeds("s mark l ; r")
   -- We should get 3 rails: s, l, r (l and r are at same position but different turns)
   lu.assertEquals(#rails, 3)
end

-- Test that mark is also a chord token and works in chords
function mod.TestMarkInChord()
   -- sml;r = s mark l ; r
   local rails = TestHelpers.assert_compilation_succeeds("sml;r")
   lu.assertEquals(#rails, 3)
end

return mod
