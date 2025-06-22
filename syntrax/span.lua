--[[
Text spans.

A text span consists of a block of text, and the start and stop indices covering a range (inclusive).  This is the "line
x column y" part of errors, but unlike you'd expect we do it off characters and resolve lines on request.

Spans are immutable.  All operations which mutate return new spans.

The lowest level spans are made from tokens by the lexer.  Then, as larger constructs are built, spans are merged to
cover them.  Note that the span of a token tree covers all of the spans in the tree, plus the outer brackets (in other
words, don't merge the children of a tree--it's already there).

The fundamental operation is `merge` which takes a span and combines with another so that the resulting span covers all
of the text between the spans.  This will include gaps: spans are always a range of only two endpoints.  We don't need
to be fancier than that here.

IMPORTANT: spans which have out of range indices will crash when computing lines and columns.  The lexer should always
produce valid spans, and save perhaps for very, very special cases, all spans after that should be merges.
]]

local mod = {}
---@class syntrax.Span
---@field text string
---@field start number
---@field stop number
---@field human_range [ number, number, number, number ]?
local Span = {}
local Span_meta = { __index = Span }
mod.Span = Span

function Span.new(text, start, stop)
   assert(start >= 1)
   assert(start <= stop)
   assert(stop <= string.len(text))

   return setmetatable({
      text = text,
      start = start,
      stop = stop,
   }, Span_meta)
end
mod.new = Span.new

---@param other syntrax.Span
---@nodiscard
---@return syntrax.Span
function Span:merge(other)
   local s1, s2 = self.start, other.start
   local e1, e2 = self.stop, other.stop
   return Span.new(self.text, math.min(s1, s2), math.max(e1, e2))
end

---@private
function Span:_resolve()
   -- Fill out the cache.
   assert(not self.human_range)

   -- To resolve a span, we grab all lines.  A line is all text before \n, *or* the end of the string.  But this is Lua
   -- which never makes anything easy.  We can get all but the last line using a pattern, but there is no or for
   -- patternes, and so we can't get the last line of the string if it doesn't end in \n.  To fix this, add a \n then
   -- resolve.  O(N) on text length, but we cache and this is why.
   local text = self.text .. "\n"

   local function find_lc(index)
      local line = 1
      for s, t, e in string.gmatch(text, "()([^\n]*)()") do
         -- The pattern captures *"" in t on newlines, because we allow 0 chars there. This seemed the easiest
         -- way to handle counting the lines up themselves.
         if s <= index and e >= index then
            local char = index - s + 1
            return line, char
         end
         if t == "" then line = line + 1 end
      end

      assert(false, "unreachable!")
   end

   local l1, c1 = find_lc(self.start)
   local l2, c2 = find_lc(self.stop)
   self.human_range = { l1, c1, l2, c2 }
end

-- Get a range which can be printed in the form (line_start, col_start, line_end, col_end). Returns the 4 values as
-- multiple return values.
---@return number, number, number, number
function Span:get_printable_range()
   local hr = self.human_range
   if not hr then
      self:_resolve()
      hr = self.human_range
   end
   assert(hr) -- _resolve always sets human_range
   return hr[1], hr[2], hr[3], hr[4]
end

return mod
