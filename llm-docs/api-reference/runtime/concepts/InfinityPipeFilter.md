# InfinityPipeFilter

A single filter used by an infinity-pipe type entity.

**Type:** Table

## Parameters

### mode

Defaults to `"at-least"`.

**Type:** `"at-least"` | `"at-most"` | `"exactly"` | `"add"` | `"remove"`

**Optional:** Yes

### name

Name of the fluid.

**Type:** `string`

**Required:** Yes

### percentage

The fill percentage the pipe (for example `0.5` for 50%). Can't be negative.

**Type:** `double`

**Optional:** Yes

### temperature

The temperature of the fluid. Defaults to the default/minimum temperature of the fluid.

**Type:** `double`

**Optional:** Yes

