---@diagnostic disable
local lu = require("luaunit")

local tests = {
   { "queries", require("railutils.tests.queries") },
   { "traverser", require("railutils.tests.traverser") },
   { "rail-describer", require("railutils.tests.rail-describer") },
   { "grid-alignment", require("railutils.tests.grid-alignment") },
}

local runner = lu.LuaUnit.new()
os.exit(runner:runSuiteByInstances(tests))
