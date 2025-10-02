# on_console_command

Called when someone enters a command-like message regardless of it being a valid command.

## Event Data

### command

**Type:** `string`

The command as typed without the preceding forward slash ('/').

### name

**Type:** `defines.events`

Identifier of the event

### parameters

**Type:** `string`

The parameters provided if any.

### player_index

**Type:** `uint` *(optional)*

The player if any.

### tick

**Type:** `uint`

Tick the event was generated.

