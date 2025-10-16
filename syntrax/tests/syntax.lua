-- Table-driven tests for basic syntax
-- Demonstrates using test cases as data for similar tests

local helpers = require("syntrax.tests.helpers")
local Errors = require("syntrax.errors")

local mod = {}

-- Test cases for basic rail sequences
local rail_sequence_tests = {
   {
      name = "empty_program",
      source = "",
      expected_count = 0,
      expected_kinds = {},
   },
   {
      name = "single_left",
      source = "l",
      expected_count = 1,
      expected_kinds = { "left" },
   },
   {
      name = "all_directions",
      source = "l r s",
      expected_count = 3,
      expected_kinds = { "left", "right", "straight" },
   },
   {
      name = "empty_brackets",
      source = "[]",
      expected_count = 0,
      expected_kinds = {},
   },
   {
      name = "simple_repetition",
      source = "[s] rep 3",
      expected_count = 3,
      expected_kinds = { "straight", "straight", "straight" },
   },
   {
      name = "complex_repetition",
      source = "[l r] rep 2",
      expected_count = 4,
      expected_kinds = { "left", "right", "left", "right" },
   },
   {
      name = "nested_brackets",
      source = "[[l] s] r",
      expected_count = 3,
      expected_kinds = { "left", "straight", "right" },
   },
}

-- Test cases for parse errors
local error_tests = {
   {
      name = "invalid_token",
      source = "x",
      expected_error = Errors.ERROR_CODE.UNEXPECTED_TOKEN,
      error_pattern = "Unexpected token 'x'",
   },
   {
      name = "rep_without_sequence",
      source = "l rep 3",
      expected_error = Errors.ERROR_CODE.UNEXPECTED_TOKEN,
      error_pattern = "Unexpected token 'rep'",
   },
   {
      name = "unclosed_bracket",
      source = "[l r",
      expected_error = Errors.ERROR_CODE.BRACKET_NOT_CLOSED,
      error_pattern = "not closed",
   },
   {
      name = "mismatched_brackets",
      source = "[l r)",
      expected_error = Errors.ERROR_CODE.BRACKET_MISMATCH,
      error_pattern = "Expected ]",
   },
   {
      name = "rep_without_number",
      source = "[l] rep",
      expected_error = Errors.ERROR_CODE.EXPECTED_NUMBER,
      error_pattern = "Expected number",
   },
}

-- Generate test functions from rail sequence data
for _, test_case in ipairs(rail_sequence_tests) do
   mod["test_sequence_" .. test_case.name] = function()
      helpers.run_test_case(test_case)
   end
end

-- Generate test functions from error test data
for _, test_case in ipairs(error_tests) do
   mod["test_error_" .. test_case.name] = function()
      helpers.run_test_case(test_case)
   end
end

return mod
