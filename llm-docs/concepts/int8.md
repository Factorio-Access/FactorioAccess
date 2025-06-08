# int8

8-bit signed integer. Possible values are `-128` to `127`.

Since Lua 5.2 only uses doubles, any API that asks for `int8` will floor the given double.

