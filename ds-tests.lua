---@diagnostic disable
local lu = require("luaunit")

local tests = {
   { "deque", require("ds.tests.deque") },
   { "sparse-bitset", require("ds.tests.sparse-bitset") },
   { "fixed-ringbuffer", require("ds.tests.fixed-ringbuffer") },
}

local runner = lu.LuaUnit.new()
os.exit(runner:runSuiteByInstances(tests))
