# uint64

64-bit unsigned integer. Possible values are `0` to `18 446 744 073 709 551 615`.

Since Lua 5.2 only uses doubles, any API that asks for `uint64` will floor the given double.

**Type:** `builtin`

