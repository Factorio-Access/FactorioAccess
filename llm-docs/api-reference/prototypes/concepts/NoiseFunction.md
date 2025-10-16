# NoiseFunction

The advantage of noise functions over [noise expressions](prototype:NoiseExpression) is that they have parameters.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### parameters

The order of the parameters matters because functions can also be called with positional arguments.

A function can't have more than 255 parameters.

**Type:** Array[`string`]

**Required:** Yes

### expression

**Type:** `NoiseExpression`

**Required:** Yes

### local_expressions

A map of expression name to expression.

Local expressions are meant to store data locally similar to local variables in Lua. Their purpose is to hold noise expressions used multiple times in the named noise expression, or just to tell the reader that the local expression has a specific purpose. Local expressions can access other local definitions and also function parameters, but recursive definitions aren't supported.

**Type:** Dictionary[`string`, `NoiseExpression`]

**Optional:** Yes

### local_functions

A map of function name to function.

Local functions serve the same purpose as local expressions - they aren't visible outside of the specific prototype and they have access to other local definitions.

**Type:** Dictionary[`string`, `NoiseFunction`]

**Optional:** Yes

