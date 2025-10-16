# CustomCommandData

**Type:** Table

## Parameters

### name

The name of the command.

**Type:** `string`

**Required:** Yes

### parameter

The parameter passed after the command, if there is one.

**Type:** `string`

**Optional:** Yes

### player_index

The player who issued the command, or `nil` if it was issued from the server console.

**Type:** `uint32`

**Optional:** Yes

### tick

The tick the command was used in.

**Type:** `uint32`

**Required:** Yes

