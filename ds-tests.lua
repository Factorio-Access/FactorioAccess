---@diagnostic disable
local lu = require("luaunit")

local tests = {
   { "deque", require("ds.tests.deque") },
   { "circular-options-list", require("ds.tests.circular-options-list") },
   { "sparse-bitset", require("ds.tests.sparse-bitset") },
   { "fixed-ringbuffer", require("ds.tests.fixed-ringbuffer") },
}

local runner = lu.LuaUnit.new()
os.exit(runner:runSuiteByInstances(tests))
