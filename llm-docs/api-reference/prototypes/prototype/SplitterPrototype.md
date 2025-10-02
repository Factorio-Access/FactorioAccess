# SplitterPrototype

A [splitter](https://wiki.factorio.com/Splitter).

**Parent:** [TransportBeltConnectablePrototype](TransportBeltConnectablePrototype.md)
**Type name:** `splitter`

## Properties

### structure

**Type:** `Animation4Way`

**Optional:** Yes

### structure_patch

Drawn 1 tile north of `structure` when the splitter is facing east or west.

**Type:** `Animation4Way`

**Optional:** Yes

### frozen_patch

**Type:** `Sprite4Way`

**Optional:** Yes

### structure_animation_speed_coefficient

**Type:** `double`

**Optional:** Yes

**Default:** 1

### structure_animation_movement_cooldown

**Type:** `uint32`

**Optional:** Yes

**Default:** 10

### related_transport_belt

The name of the [TransportBeltPrototype](prototype:TransportBeltPrototype) which is used for the sound of the underlying belt.

**Type:** `EntityID`

**Optional:** Yes

