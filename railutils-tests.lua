---@diagnostic disable
local lu = require("luaunit")

local tests = {
   { "queries", require("railutils.tests.queries") },
}

local runner = lu.LuaUnit.new()
os.exit(runner:runSuiteByInstances(tests))
