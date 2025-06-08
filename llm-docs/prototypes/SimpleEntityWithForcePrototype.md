# SimpleEntityWithForcePrototype

By default, this entity will be a priority target for units/turrets, who will choose to attack it even if it does not block their path. Setting [EntityWithOwnerPrototype::is_military_target](prototype:EntityWithOwnerPrototype::is_military_target) to `false` will turn this off, which then makes this type equivalent to [SimpleEntityWithOwnerPrototype](prototype:SimpleEntityWithOwnerPrototype).

**Parent:** `SimpleEntityWithOwnerPrototype`

## Properties

### Optional Properties

#### is_military_target

**Type:** `boolean`

Whether this prototype should be a high priority target for enemy forces. See [Military units and structures](https://wiki.factorio.com/Military_units_and_structures).

**Default:** `{'complex_type': 'literal', 'value': True}`

