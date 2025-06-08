# ChainActiveTriggerPrototype

Jumps between targets and applies a [Trigger](prototype:Trigger) to them.

**Parent:** `ActiveTriggerPrototype`

## Properties

### Optional Properties

#### action

**Type:** `Trigger`

The trigger to apply when jumping to a new target.

#### fork_chance

**Type:** `double`

Chance that a new fork will spawn after each jump. `0` for 0% chance and `1` for 100% chance.

Must be between 0 and 1.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### fork_chance_increase_per_quality_level

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 0.1}`

#### jump_delay_ticks

**Type:** `MapTick`

Tick delay between each jump. `0` means that all jumps are instantaneous.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### max_forks

**Type:** `uint32`

Maximum number of forks allowed to spawn for the entire chain.

**Default:** `max uint32`

#### max_forks_per_jump

**Type:** `uint32`

Maximum number of forks that can spawn from a single jump.

**Default:** `{'complex_type': 'literal', 'value': 1}`

#### max_jumps

**Type:** `uint32`

Max number of jumps per trigger.

**Default:** `{'complex_type': 'literal', 'value': 5}`

#### max_range

**Type:** `double`

Max distance jumps are allowed to travel away from the original target.

**Default:** `infinity`

#### max_range_per_jump

**Type:** `double`

Max length of jumps.

**Default:** `{'complex_type': 'literal', 'value': 5}`

