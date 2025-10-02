# on_udp_packet_received

Called when new packets are processed by [LuaHelpers::recv_udp](runtime:LuaHelpers::recv_udp).

## Event Data

### name

**Type:** `defines.events`

Identifier of the event

### payload

**Type:** `string`

The packet data

### player_index

**Type:** `uint`

The player index whose instance received this packet, or 0 if received on the server

### source_port

**Type:** `uint16`

The source port the packet was received from

### tick

**Type:** `uint`

Tick the event was generated.

