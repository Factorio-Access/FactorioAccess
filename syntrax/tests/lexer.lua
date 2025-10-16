local lu = require("luaunit")

local Lexer = require("syntrax.lexer")
local TestHelpers = require("syntrax.tests.helpers")

local mod = {}
local function strip_tokens_for_test(toks)
   local out = {}
   for i = 1, #toks do
      table.insert(out, toks[i].text)
   end

   return out
end

-- For tests we will drop the spans and check the tokens. We can do spans later.
function mod.TestSplittingPossibles()
   local function check(text, expected_toks)
      local tok = strip_tokens_for_test(Lexer._split_at_possibles(text))
      lu.assertEquals(tok, expected_toks)
   end

   -- Some sequences of ascii come out right...
   check("abc def ghi", { "abc", "def", "ghi" })
   -- Comments are ignored.
   check(
      [[abc
def -- a comment
ghi -- a comment at the end of the file]],
      { "abc", "def", "ghi" }
   )

   -- We break at punctuation.
   check("a$b cde", { "a", "$", "b", "cde" })

   -- weird whitespace is fine
   check(
      [[abc
  def
ghi]],
      { "abc", "def", "ghi" }
   )

   -- We break at punctuation.
   check("a$b cde", { "a", "$", "b", "cde" })

   -- We break at punctuation.
   check("a$b cde", { "a", "$", "b", "cde" })

   -- We break at punctuation.
   check("a$b cde", { "a", "$", "b", "cde" })

   -- We break at punctuation.
   check("a$b cde", { "a", "$", "b", "cde" })

   -- Weird whitespace is okay
   check("abc \t def \n\t ghi", { "abc", "def", "ghi" })

   -- Adjacent punctuation comes apart.
   check("$!@#", { "$", "!", "@", "#" })
end

function mod.TestBasicTokenizing()
   local text = "l s l r s r 5 rep"
   local result, err = Lexer.tokenize(text)
   lu.assertIsNil(err)
   lu.assertEquals(result, {
      { span = { start = 1, stop = 1, text = text }, type = "l", value = "l" },
      { span = { start = 3, stop = 3, text = text }, type = "s", value = "s" },
      { span = { start = 5, stop = 5, text = text }, type = "l", value = "l" },
      { span = { start = 7, stop = 7, text = text }, type = "r", value = "r" },
      { span = { start = 9, stop = 9, text = text }, type = "s", value = "s" },
      { span = { start = 11, stop = 11, text = text }, type = "r", value = "r" },
      {
         span = { start = 13, stop = 13, text = text },
         type = "number",
         value = "5",
      },
      { span = { start = 15, stop = 17, text = text }, type = "rep", value = "rep" },
   })
end

function mod.TestBrackets()
   local text = "l s [ r s ] ( r s [ r s l ]) l s"
   local result, err = Lexer.tokenize(text)
   lu.assertIsNil(err)
   lu.assertEquals(TestHelpers.deepcopy_unrecursive(result), {
      {
         span = { start = 1, stop = 1, text = text },
         type = "l",
         value = "l",
      },
      {
         span = { start = 3, stop = 3, text = text },
         type = "s",
         value = "s",
      },
      {
         bracket_type = "[",
         children = {
            {
               span = { start = 7, stop = 7, text = text },
               type = "r",
               value = "r",
            },
            {
               span = { start = 9, stop = 9, text = text },
               type = "s",
               value = "s",
            },
         },
         close_bracket_span = { start = 11, stop = 11, text = text },
         open_bracket_span = { start = 5, stop = 5, text = text },
         span = { start = 11, stop = 11, text = text },
         type = "tree",
         value = "]",
      },
      {
         bracket_type = "(",
         children = {
            {
               span = { start = 15, stop = 15, text = text },
               type = "r",
               value = "r",
            },
            {
               span = { start = 17, stop = 17, text = text },
               type = "s",
               value = "s",
            },
            {
               bracket_type = "[",
               children = {
                  {
                     span = { start = 21, stop = 21, text = text },
                     type = "r",
                     value = "r",
                  },
                  {
                     span = { start = 23, stop = 23, text = text },
                     type = "s",
                     value = "s",
                  },
                  {
                     span = { start = 25, stop = 25, text = text },
                     type = "l",
                     value = "l",
                  },
               },
               close_bracket_span = { start = 27, stop = 27, text = text },
               open_bracket_span = { start = 19, stop = 19, text = text },
               span = { start = 27, stop = 27, text = text },
               type = "tree",
               value = "]",
            },
         },
         close_bracket_span = { start = 28, stop = 28, text = text },
         open_bracket_span = { start = 13, stop = 13, text = text },
         span = { start = 28, stop = 28, text = text },
         type = "tree",
         value = ")",
      },
      {
         span = { start = 30, stop = 30, text = text },
         type = "l",
         value = "l",
      },
      {
         span = { start = 32, stop = 32, text = text },
         type = "s",
         value = "s",
      },
   })
end

return mod
