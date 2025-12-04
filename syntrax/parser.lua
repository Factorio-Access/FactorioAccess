--[[
Parser for Syntrax language.

Converts a token tree from the lexer into an Ast. The parser is recursive descent,
taking advantage of the pre-parsed bracket structure from the lexer.
]]

local Ast = require("syntrax.ast")
local Errors = require("syntrax.errors")
local Lexer = require("syntrax.lexer")
local Span = require("syntrax.span")

local mod = {}

---@class syntrax.ParserState
---@field tokens syntrax.Token[]
---@field pos number Current position in tokens array
---@field error syntrax.Error?
local ParserState = {}
local ParserState_meta = { __index = ParserState }

---@param tokens syntrax.Token[]
---@return syntrax.ParserState
local function new_state(tokens)
   return setmetatable({
      tokens = tokens,
      pos = 1,
      error = nil,
   }, ParserState_meta)
end

---@return syntrax.Token?
function ParserState:current_token()
   if self.pos <= #self.tokens then return self.tokens[self.pos] end
   return nil
end

function ParserState:advance()
   self.pos = self.pos + 1
end

---@param expected_type syntrax.TOKEN_TYPE
---@return boolean
function ParserState:check_token(expected_type)
   local tok = self:current_token()
   return tok ~= nil and tok.type == expected_type
end

---@param expected_type syntrax.TOKEN_TYPE
---@return syntrax.Token?
function ParserState:consume_token(expected_type)
   if self:check_token(expected_type) then
      local tok = self:current_token()
      self:advance()
      return tok
   end
   return nil
end

-- Forward declaration
local parse_statement

--- Checks if the next token is 'x' followed by a number, and if so,
--- wraps the node in a repetition with an implicit sequence.
--- This enables chord syntax like `sx5` to mean `[s] x 5`.
---@param state syntrax.ParserState
---@param node syntrax.ast.Node The primitive node to potentially wrap
---@param start_span syntrax.Span The span of the primitive token
---@return syntrax.ast.Node? node The original node or a repetition wrapping it
---@return syntrax.Error? err
local function try_wrap_repetition(state, node, start_span)
   local x_tok = state:consume_token(Lexer.TOKEN_TYPE.X)
   if not x_tok then return node, nil end

   -- Expect a number after 'x'
   local num_tok = state:current_token()
   if not num_tok or num_tok.type ~= Lexer.TOKEN_TYPE.NUMBER then
      return nil,
         Errors.error_builder(Errors.ERROR_CODE.EXPECTED_NUMBER, "Expected number after 'x'", x_tok.span):build()
   end
   state:advance()

   local count = tonumber(num_tok.value)
   if not count or count < 1 then
      return nil,
         Errors.error_builder(
            Errors.ERROR_CODE.EXPECTED_NUMBER,
            "Repetition count must be a positive integer",
            num_tok.span
         )
            :build()
   end

   -- Wrap the primitive in an implicit sequence
   local body = Ast.implicit_sequence({ node }, start_span)
   local span = start_span:merge(num_tok.span)

   return Ast.repetition(body, count, span), nil
end

---@param state syntrax.ParserState
---@param tree_token syntrax.Token
---@return syntrax.ast.Sequence?, syntrax.Error?
local function parse_tree_contents(state, tree_token)
   -- Create a new parser state for the tree's children
   local tree_state = new_state(tree_token.children)

   local statements = {}

   while tree_state:current_token() do
      local stmt, err = parse_statement(tree_state)
      if err then return nil, err end
      if stmt then table.insert(statements, stmt) end
   end

   -- Empty sequences are allowed

   -- Merge spans from open bracket to close bracket
   local span = tree_token.open_bracket_span:merge(tree_token.close_bracket_span)

   return Ast.sequence(statements, span), nil
end

---@param state syntrax.ParserState
---@return syntrax.ast.Node?, syntrax.Error?
function parse_statement(state)
   local tok = state:current_token()
   if not tok then
      return nil, nil -- End of input
   end

   -- Handle chord primitives (can be followed by x for repetition)
   if tok.type == Lexer.TOKEN_TYPE.L then
      state:advance()
      return try_wrap_repetition(state, Ast.left(tok.span), tok.span)
   elseif tok.type == Lexer.TOKEN_TYPE.R then
      state:advance()
      return try_wrap_repetition(state, Ast.right(tok.span), tok.span)
   elseif tok.type == Lexer.TOKEN_TYPE.S then
      state:advance()
      return try_wrap_repetition(state, Ast.straight(tok.span), tok.span)
   elseif tok.type == Lexer.TOKEN_TYPE.L45 then
      state:advance()
      return try_wrap_repetition(state, Ast.l45(tok.span), tok.span)
   elseif tok.type == Lexer.TOKEN_TYPE.R45 then
      state:advance()
      return try_wrap_repetition(state, Ast.r45(tok.span), tok.span)
   elseif tok.type == Lexer.TOKEN_TYPE.L90 then
      state:advance()
      return try_wrap_repetition(state, Ast.l90(tok.span), tok.span)
   elseif tok.type == Lexer.TOKEN_TYPE.R90 then
      state:advance()
      return try_wrap_repetition(state, Ast.r90(tok.span), tok.span)
   elseif tok.type == Lexer.TOKEN_TYPE.RESET then
      state:advance()
      return try_wrap_repetition(state, Ast.reset(tok.span), tok.span)
   elseif tok.type == Lexer.TOKEN_TYPE.MARK then
      state:advance()
      return try_wrap_repetition(state, Ast.mark(tok.span), tok.span)
   elseif tok.type == Lexer.TOKEN_TYPE.FLIP then
      state:advance()
      return try_wrap_repetition(state, Ast.flip(tok.span), tok.span)
   -- Non-chord primitives (no repetition support)
   elseif tok.type == Lexer.TOKEN_TYPE.RPUSH then
      state:advance()
      return Ast.rpush(tok.span), nil
   elseif tok.type == Lexer.TOKEN_TYPE.RPOP then
      state:advance()
      return Ast.rpop(tok.span), nil
   elseif tok.type == Lexer.TOKEN_TYPE.SIGLEFT then
      state:advance()
      return Ast.sigleft(tok.span), nil
   elseif tok.type == Lexer.TOKEN_TYPE.SIGRIGHT then
      state:advance()
      return Ast.sigright(tok.span), nil
   elseif tok.type == Lexer.TOKEN_TYPE.CHAINLEFT then
      state:advance()
      return Ast.chainleft(tok.span), nil
   elseif tok.type == Lexer.TOKEN_TYPE.CHAINRIGHT then
      state:advance()
      return Ast.chainright(tok.span), nil
   elseif tok.type == Lexer.TOKEN_TYPE.SIG then
      state:advance()
      return Ast.sig(tok.span), nil
   elseif tok.type == Lexer.TOKEN_TYPE.CHAIN then
      state:advance()
      return Ast.chain(tok.span), nil
   elseif tok.type == Lexer.TOKEN_TYPE.SIGCHAIN then
      state:advance()
      return Ast.sigchain(tok.span), nil
   elseif tok.type == Lexer.TOKEN_TYPE.CHAINSIG then
      state:advance()
      return Ast.chainsig(tok.span), nil
   elseif tok.type == Lexer.TOKEN_TYPE.TREE then
      -- Only square brackets are allowed for sequences
      if tok.bracket_type ~= "[" then
         return nil,
            Errors.error_builder(
               Errors.ERROR_CODE.UNEXPECTED_TOKEN,
               string.format(
                  "Only square brackets [] are allowed for sequences, found %s%s",
                  tok.bracket_type,
                  tok.bracket_type == "(" and ")" or tok.bracket_type == "{" and "}" or "]"
               ),
               tok.open_bracket_span
            ):build()
      end

      state:advance()

      -- Parse the contents of the tree
      local body, err = parse_tree_contents(state, tok)
      if err then return nil, err end
      assert(body) -- parse_tree_contents always returns a sequence when successful

      -- Check if this is followed by 'x' (repetition)
      local x_tok = state:consume_token(Lexer.TOKEN_TYPE.X)
      if x_tok then
         -- Expect a number after 'x'
         local num_tok = state:current_token()
         if not num_tok or num_tok.type ~= Lexer.TOKEN_TYPE.NUMBER then
            return nil,
               Errors.error_builder(Errors.ERROR_CODE.EXPECTED_NUMBER, "Expected number after 'x'", x_tok.span):build()
         end
         state:advance()

         local count = tonumber(num_tok.value)
         if not count or count < 1 then
            return nil,
               Errors.error_builder(
                  Errors.ERROR_CODE.EXPECTED_NUMBER,
                  "Repetition count must be a positive integer",
                  num_tok.span
               )
                  :build()
         end

         -- Merge span from opening bracket to the number
         local span = tok.open_bracket_span:merge(num_tok.span)

         return Ast.repetition(body, count, span), nil
      else
         -- Just square brackets without repetition - return the sequence
         return body, nil
      end
   else
      return nil,
         Errors.error_builder(
            Errors.ERROR_CODE.UNEXPECTED_TOKEN,
            string.format("Unexpected token '%s'", tok.value),
            tok.span
         )
            :build()
   end
end

---@param tokens syntrax.Token[]
---@param text string Original source text for empty program spans
---@return syntrax.ast.Sequence?, syntrax.Error?
local function parse_tokens(tokens, text)
   local state = new_state(tokens)
   local statements = {}

   while state:current_token() do
      local stmt, err = parse_statement(state)
      if err then return nil, err end
      if stmt then table.insert(statements, stmt) end
   end

   -- Create program span by merging first and last statement spans
   local span
   if #statements == 0 then
      -- Empty program - create a dummy span
      -- For empty text, we need a valid span
      local dummy_text = text == "" and " " or text
      span = Span.new(dummy_text, 1, 1)
   elseif #statements == 1 then
      span = statements[1].span
   else
      span = statements[1].span:merge(statements[#statements].span)
   end

   return Ast.sequence(statements, span), nil
end

---@param text string
---@return syntrax.ast.Sequence?, syntrax.Error?
function mod.parse(text)
   -- First tokenize
   local tokens, err = Lexer.tokenize(text)
   if err then return nil, err end

   -- Then parse
   return parse_tokens(tokens --[[@as syntrax.Token[] ]], text)
end

-- Export for testing
mod._parse_tokens = parse_tokens

return mod
