# LogisticContainerPrototype

A generic container, such as a chest, that interacts with the logistics network.

**Parent:** [ContainerPrototype](ContainerPrototype.md)
**Type name:** `logistic-container`

## Properties

### logistic_mode

The way this chest interacts with the logistic network.

**Type:** `"active-provider"` | `"passive-provider"` | `"requester"` | `"storage"` | `"buffer"`

**Required:** Yes

### max_logistic_slots

The number of request slots this logistics container has. Requester-type containers must have > 0 slots and can have a maximum of [UtilityConstants::max_logistic_filter_count](prototype:UtilityConstants::max_logistic_filter_count) slots. Storage-type containers must have <= 1 slot.

**Type:** `uint16`

**Optional:** Yes

### trash_inventory_size

**Type:** `ItemStackIndex`

**Optional:** Yes

**Default:** 0

### render_not_in_network_icon

Whether the "no network" icon should be rendered on this entity if the entity is not within a logistics network.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### opened_duration

**Type:** `uint8`

**Optional:** Yes

**Default:** 0

### animation

Drawn when a robot brings/takes items from this container.

**Type:** `Animation`

**Optional:** Yes

### landing_location_offset

The offset from the center of this container where a robot visually brings/takes items.

**Type:** `Vector`

**Optional:** Yes

### use_exact_mode

Whether logistic robots have to deliver the exact amount of items requested to this logistic container instead of over-delivering (within their cargo size).

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### animation_sound

Played when a robot brings/takes items from this container. Only loaded if `animation` is defined.

**Type:** `Sound`

**Optional:** Yes

