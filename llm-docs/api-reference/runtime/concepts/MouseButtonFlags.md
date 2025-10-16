# MouseButtonFlags

A set of flags. Active flags are in the dictionary as `true`, while inactive flags aren't present at all.

To write to this, use an array[[string](runtime:string)] of the mouse buttons that should be possible to use with on button. The flag `"left-and-right"` can also be set, which will set `"left"` and `"right"` to `true`.

**Type:** Dictionary[`"left"` | `"right"` | `"middle"` | `"button-4"` | `"button-5"` | `"button-6"` | `"button-7"` | `"button-8"` | `"button-9"`, `True`]

