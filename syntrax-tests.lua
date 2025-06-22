local lu = require("luaunit")

local tests = {
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

local runner = lu.LuaUnit.new()
os.exit(runner:runSuiteByInstances(tests))
