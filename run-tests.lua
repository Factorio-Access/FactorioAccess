#!/usr/bin/env lua

-- General test runner for FactorioAccess
-- Usage: lua run-tests.lua [suite]
-- Where suite is one of: syntrax, ds, all (default)

local lu = require("luaunit")

local function load_test_suite(suite_name, test_specs)
   local tests = {}
   for _, spec in ipairs(test_specs) do
      table.insert(tests, { spec[1], spec[2] })
   end
   return tests
end

local syntrax_tests = {
   { "span", require("syntrax.tests.span") },
   { "lexer", require("syntrax.tests.lexer") },
   { "ast", require("syntrax.tests.ast") },
   { "parser", require("syntrax.tests.parser") },
   { "directions", require("syntrax.tests.directions") },
   { "vm", require("syntrax.tests.vm") },
   { "compiler", require("syntrax.tests.compiler") },
   { "syntrax", require("syntrax.tests.syntrax") },
   { "syntax", require("syntrax.tests.syntax") },
   { "rail-stack", require("syntrax.tests.rail-stack") },
}

local ds_tests = {
   { "deque", require("ds.tests.deque") },
   { "circular-options-list", require("ds.tests.circular-options-list") },
   { "sparse-bitset", require("ds.tests.sparse-bitset") },
}

-- Parse command line arguments
local suite = arg and arg[1] or "all"

local tests = {}

if suite == "syntrax" then
   tests = syntrax_tests
elseif suite == "ds" then
   tests = ds_tests
elseif suite == "all" then
   -- Combine both test suites
   for _, test in ipairs(syntrax_tests) do
      table.insert(tests, test)
   end
   for _, test in ipairs(ds_tests) do
      table.insert(tests, test)
   end
else
   print("Unknown test suite: " .. suite)
   print("Usage: lua run-tests.lua [syntrax|ds|all]")
   os.exit(1)
end

-- Run the tests
local runner = lu.LuaUnit.new()
os.exit(runner:runSuiteByInstances(tests))