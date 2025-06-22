local lu = require("luaunit")
local Span = require("syntrax.span")

local mod = {}

function mod.TestResolveSimple()
   local text = [[a
bcd
ef]]
   lu.assertEquals(table.pack(Span.new(text, 1, 1):get_printable_range()), { 1, 1, 1, 1, n = 4 })
end

function mod.TestResolveSimpleL2()
   local text = [[a
bcd
ef]]
   lu.assertEquals(table.pack(Span.new(text, 3, 5):get_printable_range()), { 2, 1, 2, 3, n = 4 })
end

function mod.TestResolveSimpleL3()
   local text = [[a
bcd
ef]]
   lu.assertEquals(table.pack(Span.new(text, 7, 8):get_printable_range()), { 3, 1, 3, 2, n = 4 })
end

return mod
