--[[
The lexer.

This is fun because of Lua string processing.  So...

# Overview

We borrow Rust's idea of a token tree.  A token tree is:

- A single token, "l", "foo", "asdfasdf"; or
- A list of tokens surrounded by brackets `( t1, t2, t3 )`.

This means that everything after gets a pre-balanced set of brackets and parsing proceeds recursively: any tree which
isn't a single token has its inner contents partsed, and then moving outward.

The next phase in the pipeline figures out if the stuff here is meaningful.
]]

local Errors = require("syntrax.errors")
local Span = require("syntrax.span")

local mod = {}

local IDENT_PATTERN = "^[%l%u_][%w%d_]*$"
-- No decimals in syntrax for now.
local NUMBER_PATTERN = "^%d+$"

-- For the function below, to split a string up into tokens.
--
-- Order matters. The tuples are { pattern, include_as_token }.
local MUNCHERS = {
   -- Whitepace.
   { "^%s+", false },

   -- A comment, which happens to be at the end of the file.
   { "^%-%-[^\n]*$", false },

   -- A comment not at the end of the file.
   { "^%-%-[^\n]*\n", false },

   -- (possible) identifiers: a set of letters, numbers, _.  Also (possible) numbers: an identifier that happens to be
   -- all digits.
   { "^[%w_]+", true },

   -- Anything else goes to a token by itself.  This includes single-letter identifiers, since the caller cannot know
   -- which way we went.
   { "^.", true },
}

--[[
Infallible function which splits a string at *possible* tokens.

Lua string processing is weird and slow. What we do is split at possible token boundaries and then match them.  It's
possible to do this with patterns instead of substrings etc.  This function never fails (at worst it returns the whole
input string).  After it, one has the list of possible tokens but not yet converted into something meaningful (e.g. not
yet checked for brackets).

This works by matching a set of patterns, taking the closest result toward the beginning, and then moving forward.
qAfterword, we convert that to substrings.

The returned tokens may not be valid, but the string is split such that if they are, it's one token each.

The above patterns match anything. That's the magic of this: we either get one of the tricky subsets, or a single
character, but we always hit at least one.
]]
---@return { text: string, span: syntrax.Span }[]
local function split_at_possibles(text)
   local tokens = {}
   local pos = 1
   local len = #text

   while pos <= len do
      local part, keep

      for i = 1, #MUNCHERS do
         local pat, k = MUNCHERS[i][1], MUNCHERS[i][2]
         local m = string.match(text, pat, pos)
         if m then
            part = m
            keep = k
            break
         end
      end

      assert(part)
      if keep then
         local start = pos
         local stop = pos + #part - 1
         local span = Span.new(text, start, stop)
         table.insert(tokens, { text = part, span = span })
         pos = stop + 1
      else
         -- Doingf it this way means not taking the length twice.
         pos = pos + #part
      end
   end

   return tokens
end
mod._split_at_possibles = split_at_possibles

---@enum syntrax.TOKEN_TYPE
mod.TOKEN_TYPE = {
   L = "l",
   R = "r",
   S = "s",
   IDENTIFIER = "identifier",
   -- This special token is a token tree, some bracketed text.
   TREE = "tree",
   REP = "rep",
   NUMBER = "number",
   RPUSH = "rpush",
   RPOP = "rpop",
   RESET = "reset",
}

---@class syntrax.Token
---@field type syntrax.TOKEN_TYPE
---@field value string
---@field span syntrax.Span
---@field children syntrax.Token[]? Non-null if token is BRACKET.
---@field open_bracket_span syntrax.Span?
---@field close_bracket_span syntrax.Span?
---@field bracket_type ("[" | "(" | "{")?

local BRACKET_INVERSE = {
   ["["] = "]",
   ["{"] = "}",
   ["("] = ")",
   ["]"] = "[",
   [")"] = "(",
   ["}"] = "{",
}

--@param untyped_tokens { text: String, span: syntrax.Span }
---@return syntrax.Token[]?, syntrax.Error?
local function build_tokens(untyped_tokens)
   -- A stack whose bottom-most level is the "top" of the program, and each level thereafter is a bracket plus the items
   -- under that bracket.
   ---@type { expected_bracket: "["|"("|"{", above: syntrax.Token[], start_span: syntrax.Span }
   local stack = {}

   local result = {}

   for i = 1, #untyped_tokens do
      local text = untyped_tokens[i].text
      local span = untyped_tokens[i].span

      ---@type syntrax.Token
      local tok = { span = span, type = mod.TOKEN_TYPE.L, value = text }

      if text == "l" then
         -- Already handled, since we need a default value.
      elseif text == "r" then
         tok.type = mod.TOKEN_TYPE.R
      elseif text == "s" then
         tok.type = mod.TOKEN_TYPE.S
      elseif text == "rep" then
         tok.type = mod.TOKEN_TYPE.REP
      elseif text == "rpush" then
         tok.type = mod.TOKEN_TYPE.RPUSH
      elseif text == "rpop" then
         tok.type = mod.TOKEN_TYPE.RPOP
      elseif text == "reset" then
         tok.type = mod.TOKEN_TYPE.RESET
      elseif string.match(text, IDENT_PATTERN) then
         tok.type = mod.TOKEN_TYPE.IDENTIFIER
      elseif string.match(text, NUMBER_PATTERN) then
         tok.type = mod.TOKEN_TYPE.NUMBER
      elseif text == "[" or text == "{" or text == "(" then
         -- Bracket open. Our current set of results goes on the stack and we start a new one.
         table.insert(stack, {
            span = span,
            expected_bracket = assert(BRACKET_INVERSE[text]),
            above = result,
         })
         result = {}
         goto continue
      elseif text == "]" or text == ")" or text == "}" then
         -- Popping a bracket.
         if not next(stack) then
            return nil,
               Errors.error_builder(Errors.ERROR_CODE.BRACKET_MISMATCH, "No bracket opens this bracket", span)
                  :note(string.format("You need a preceeding %s", BRACKET_INVERSE[text]))
                  :build()
         end

         local top = stack[#stack]
         if text ~= top.expected_bracket then
            local err = Errors.error_builder(
               Errors.ERROR_CODE.BRACKET_MISMATCH,
               string.format("Expected %s but found %s", top.expected_bracket, text),
               span
            )
               :note(string.format("To close %s", BRACKET_INVERSE[text]), top.span)
               :build()
            return nil, err
         end

         tok.type = mod.TOKEN_TYPE.TREE
         tok.children = result
         tok.open_bracket_span = top.span
         tok.close_bracket_span = span
         tok.bracket_type = BRACKET_INVERSE[top.expected_bracket]
         result = top.above
         table.remove(stack, #stack)
      else
         return nil,
            Errors.error_builder(Errors.ERROR_CODE.INVALID_TOKEN, string.format("Unrecognized token %s", text), span)
               :build()
      end

      table.insert(result, tok)

      ::continue::
   end

   if next(stack) then
      return nil,
         Errors.error_builder(
            Errors.ERROR_CODE.BRACKET_NOT_CLOSED,
            string.format("Bracket %s not closed", BRACKET_INVERSE[stack[#stack].expected_bracket]),
            stack[#stack].span
         ):build()
   end

   return result
end
mod._build_tokens = build_tokens

---@param text string
---@return syntrax.Token[]?, syntrax.Error?
function mod.tokenize(text)
   -- The empty program is valid, but does nothing.
   if string.match(text, "^%s*$") then return {} end

   local split = split_at_possibles(text)
   return build_tokens(split)
end

return mod
