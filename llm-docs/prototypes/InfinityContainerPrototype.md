# InfinityContainerPrototype

A generic container, such as a chest, that can spawn or void items and interact with the logistics network.

**Parent:** `LogisticContainerPrototype`

## Properties

### Mandatory Properties

#### erase_contents_when_mined

**Type:** `boolean`



#### inventory_size

**Type:** `ItemStackIndex`

The number of slots in this container. May not be zero.

### Optional Properties

#### gui_mode

**Type:** 

Controls which players can control what the chest spawns.

**Default:** `{'complex_type': 'literal', 'value': 'all'}`

#### logistic_mode

**Type:** 

The way this chest interacts with the logistic network.

#### preserve_contents_when_created

**Type:** `boolean`

When true, items created inside the infinity chest will not start to spoil until they have been removed from the chest.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### render_not_in_network_icon

**Type:** `boolean`

Whether the "no network" icon should be rendered on this entity if the entity is not within a logistics network.

**Default:** `{'complex_type': 'literal', 'value': False}`

