# NoiseExpression

A boolean or double as simple values or a string that represents a math expression. The expression parser recognizes five basic token types (with their regex):

- **Whitespace:** `[ \n\r\t]*`

- **Identifier:** `[a-zA-Z_][a-zA-Z0-9_:]*` (e.g. cat_bar123)

- **Number:** `(0x[0-9a-f]+|([0-9]+\.?[0-9]*|\.[0-9]+)(e-?[0-9]+)?)` (e.g. `3.2`, `100`, `.6`, `4.2e-5`, `0x2a5f`). Supports hexadecimal input and scientific notation for decimal numbers.

- **String:** `("[^"]*"|'[^']*')` (e.g. `"cat bar 123"`, `'control-setting:copper-ore'`)

- **Operator:** See the list below

Identifiers are used to name functions and variables. The built-in functions and variables are documented in the [auxiliary docs](runtime:noise-expressions). Mods can define their own noise expressions which can be used as variables and functions. The entry points for this are [NamedNoiseFunction](prototype:NamedNoiseFunction) and [NamedNoiseExpression](prototype:NamedNoiseExpression) as well as local functions and expressions.

All functions accept both named and positional arguments. To differentiate between these function calls, positional arguments start/end with `(`/`)` and named arguments with `{`/`}`, e.g. `clamp(x, -1, 1)` and `clamp{min = -1, max = 1, value = x}` are the same function call. Because of this, positional arguments can't be mixed with named arguments. A function can't have more than 255 parameters.

The following operators are available, ordered by precedence:

- `x^y`: Exponentiation (fast, inaccurate), equivalent to the built-in `pow(x, y)` noise function

- `+x`, `-x`, `~x`: Unary plus and minus and unary bitwise not

- `x*y`, `x/y`, `x%y`, `x%%y`: Multiplication and division, modulo and remainder.

- `x+y`, `x-y`: Addition and subtraction

- `x<y`, `x<=y`, `x>y`, `x>=y`: Less than, less than or equal, greater than, greater than or equal

- `x==y`, `x~=y`, `x!=y`: Equal to and not equal to (Lua and C++ syntax)

- `x&y`: Bitwise and

- `x~y`: Bitwise xor

- `x|y`: Bitwise or

Modulo is implemented as `x - floor(x / y) * y` and remainder uses C++ [`fmod(x, y)`](https://en.cppreference.com/w/cpp/numeric/math/fmod) function.

The boolean operators (less than, less than or equal, equal, not equal, greater than, greater than or equal) take two numbers and return 0 for false or 1 for true.

The bitwise operators convert single-precision floating-point numbers to signed 32-bit integers before computing the result.

**Type:** `string` | `boolean` | `double`

## Examples

```
```
"distance_from_nearest_point{x = x, y = y, points = starting_positions}"
```
```

```
```
"clamp(x, -1, 1)"
```
```

