---@diagnostic disable
local lu = require("luaunit")

local tests = {
   { "deque", require("ds.tests.deque") },
   { "sparse-bitset", require("ds.tests.sparse-bitset") },
   { "fixed-ringbuffer", require("ds.tests.fixed-ringbuffer") },
   { "lru-cache", require("ds.tests.lru-cache") },
   { "localised-string-cache", require("ds.tests.localised-string-cache") },
   { "block-clusterer", require("ds.tests.block-clusterer") },
}

local runner = lu.LuaUnit.new()
os.exit(runner:runSuiteByInstances(tests))
