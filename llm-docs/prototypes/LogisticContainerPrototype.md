# LogisticContainerPrototype

A generic container, such as a chest, that interacts with the logistics network.

**Parent:** `ContainerPrototype`

## Properties

### Mandatory Properties

#### logistic_mode

**Type:** 

The way this chest interacts with the logistic network.

### Optional Properties

#### animation

**Type:** `Animation`

Drawn when a robot brings/takes items from this container.

#### animation_sound

**Type:** `Sound`

Played when a robot brings/takes items from this container. Ignored if `animation` is not defined.

#### landing_location_offset

**Type:** `Vector`

The offset from the center of this container where a robot visually brings/takes items.

#### max_logistic_slots

**Type:** `uint16`

The number of request slots this logistics container has. Requester-type containers must have > 0 slots and can have a maximum of [UtilityConstants::max_logistic_filter_count](prototype:UtilityConstants::max_logistic_filter_count) slots. Storage-type containers must have <= 1 slot.

#### opened_duration

**Type:** `uint8`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### render_not_in_network_icon

**Type:** `boolean`

Whether the "no network" icon should be rendered on this entity if the entity is not within a logistics network.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### trash_inventory_size

**Type:** `ItemStackIndex`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### use_exact_mode

**Type:** `boolean`

Whether logistic robots have to deliver the exact amount of items requested to this logistic container instead of over-delivering (within their cargo size).

**Default:** `{'complex_type': 'literal', 'value': False}`

