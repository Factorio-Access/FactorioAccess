# NamedNoiseFunction

Named noise functions are defined in the same way as [NamedNoiseExpression](prototype:NamedNoiseExpression) except that they also have parameters.

Named noise functions are available to be used in [NoiseExpressions](prototype:NoiseExpression).

**Parent:** `Prototype`

## Properties

### Mandatory Properties

#### expression

**Type:** `NoiseExpression`



#### parameters

**Type:** ``string`[]`

The order of the parameters matters because functions can also be called with positional arguments.

A function can't have more than 255 parameters.

### Optional Properties

#### local_expressions

**Type:** `dictionary<`string`, `NoiseExpression`>`

A map of expression name to expression.

Local expressions are meant to store data locally similar to local variables in Lua. Their purpose is to hold noise expressions used multiple times in the named noise expression, or just to tell the reader that the local expression has a specific purpose. Local expressions can access other local definitions and also function parameters, but recursive definitions aren't supported.

#### local_functions

**Type:** `dictionary<`string`, `NoiseFunction`>`

A map of function name to function.

Local functions serve the same purpose as local expressions - they aren't visible outside of the specific prototype and they have access to other local definitions.

