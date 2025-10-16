# InfinityContainerPrototype

A generic container, such as a chest, that can spawn or void items and interact with the logistics network.

**Parent:** [LogisticContainerPrototype](LogisticContainerPrototype.md)
**Type name:** `infinity-container`

## Properties

### erase_contents_when_mined

**Type:** `boolean`

**Required:** Yes

### preserve_contents_when_created

When true, items created inside the infinity chest will not start to spoil until they have been removed from the chest.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### gui_mode

Controls which players can control what the chest spawns.

**Type:** `"all"` | `"none"` | `"admins"`

**Optional:** Yes

**Default:** "all"

### logistic_mode

The way this chest interacts with the logistic network.

**Type:** `"active-provider"` | `"passive-provider"` | `"requester"` | `"storage"` | `"buffer"`

**Optional:** Yes

**Overrides parent:** Yes

### render_not_in_network_icon

Whether the "no network" icon should be rendered on this entity if the entity is not within a logistics network.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

**Overrides parent:** Yes

### inventory_size

The number of slots in this container. May not be zero.

**Type:** `ItemStackIndex`

**Required:** Yes

**Overrides parent:** Yes

