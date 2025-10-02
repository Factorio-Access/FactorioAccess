# on_console_chat

Called when a message is sent to the in-game console, either by a player or through the server interface.

This event only fires for plain messages, not for any commands (including `/shout` or `/whisper`).

## Event Data

### message

**Type:** `string`

The chat message that was sent.

### name

**Type:** `defines.events`

Identifier of the event

### player_index

**Type:** `uint` *(optional)*

The player doing the chatting, if any.

### tick

**Type:** `uint`

Tick the event was generated.

