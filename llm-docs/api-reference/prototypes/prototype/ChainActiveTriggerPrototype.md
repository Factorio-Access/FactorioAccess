# ChainActiveTriggerPrototype

Jumps between targets and applies a [Trigger](prototype:Trigger) to them.

**Parent:** [ActiveTriggerPrototype](ActiveTriggerPrototype.md)
**Type name:** `chain-active-trigger`

## Properties

### action

The trigger to apply when jumping to a new target.

**Type:** `Trigger`

**Optional:** Yes

### max_jumps

Max number of jumps per trigger.

**Type:** `uint32`

**Optional:** Yes

**Default:** 5

### max_range_per_jump

Max length of jumps.

**Type:** `double`

**Optional:** Yes

**Default:** 5

### max_range

Max distance jumps are allowed to travel away from the original target.

**Type:** `double`

**Optional:** Yes

**Default:** "infinity"

### jump_delay_ticks

Tick delay between each jump. `0` means that all jumps are instantaneous.

**Type:** `MapTick`

**Optional:** Yes

**Default:** 0

### fork_chance

Chance that a new fork will spawn after each jump. `0` for 0% chance and `1` for 100% chance.

Must be between 0 and 1.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### fork_chance_increase_per_quality_level

**Type:** `double`

**Optional:** Yes

**Default:** 0.1

### max_forks_per_jump

Maximum number of forks that can spawn from a single jump.

**Type:** `uint32`

**Optional:** Yes

**Default:** 1

### max_forks

Maximum number of forks allowed to spawn for the entire chain.

**Type:** `uint32`

**Optional:** Yes

**Default:** "max uint32"

