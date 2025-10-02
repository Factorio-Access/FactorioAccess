# MathExpression

A string that represents a math expression. The expression parser recognizes four basic token types (with their regex):

- Whitespace: `[ \n\r\t]*`

- Number: `(0x[0-9a-f]+|([0-9]+\.?[0-9]*|\.[0-9]+)(e-?[0-9]+)?)` (e.g. `3.2`, `100`, `.6`, `4.2e-5`, `0x2a5f`). Supports hexadecimal input and scientific notation for decimal numbers.

- Operator: `+`, `-`, `*`, `/`, `^`, and `()` for brackets, which may be nested.

- Identifier: The functions listed below and any variables listed where the expression is used.

Identifiers are used to name functions and variables, which result in or represent numbers. The following functions are always available:

- `abs(value)`: Returns absolute value of the given argument; i.e. if the argument is negative, it is inverted.

- `log2(value)`: Returns a binary logarithm of the given value.

- `sign(value)`: Returns `-1` for negative numbers, `0` for zero (regardless of sign), `1` for positive numbers

- `max(value1, value2, ...)`: Returns the greater of the given values. Supports between 2 and 255 arguments.

- `min(value1, value2, ...)`: Returns the smaller of the given values. Supports between 2 and 255 arguments.

The property where the expression is used may provide variables. For example in [TechnologyUnit::count_formula](prototype:TechnologyUnit::count_formula) `L` and `l` may be used for the technology level.

The formula is executed following the [BODMAS](https://en.wikipedia.org/wiki/Order_of_operations#Conventional_order) order (also known as PEMDAS).

**Type:** `string`

## Examples

```
```
"2500 * (L - 3)"
```
```

```
```
"(4e5 * (abs(speed) + 10.5)) / weight"
```
```

