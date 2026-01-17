# UpgradeItemPrototype

An [upgrade planner](https://wiki.factorio.com/Upgrade_planner).

For an entity to be allowed as an upgrade source, it must be minable, may not have "not-upgradable" flag set and may not be [hidden](prototype:PrototypeBase::hidden). Additionally, the source entity's mining result must not be an item product that is [hidden](prototype:ItemPrototype::hidden). Mining results with no item products are allowed.

For an entity to be allowed as an upgrade target, it must have least 1 item that builds it that isn't hidden.

For two entities to be upgrades of each other, the two entities must have the same [fast replaceable group](prototype:EntityPrototype::fast_replaceable_group), the same [collision box](prototype:EntityPrototype::collision_box) and the same [collision mask](prototype:EntityPrototype::collision_mask). Additionally, [underground belts](prototype:UndergroundBeltPrototype) cannot be upgraded to [transport belts](prototype:TransportBeltPrototype) and vice versa.

For an entity to be automatically upgraded to another entity without configuring the upgrade planner, the [next upgrade](prototype:EntityPrototype::next_upgrade) of the upgrade source entity must be set.

**Parent:** [SelectionToolPrototype](SelectionToolPrototype.md)
**Type name:** `upgrade-item`

## Properties

### stack_size

Count of items of the same name that can be stored in one inventory slot. Must be 1 when the `"not-stackable"` flag is set.

**Type:** `1`

**Required:** Yes

**Overrides parent:** Yes

**Examples:**

```
stack_size = 1
```

### draw_label_for_cursor_render

If the item will draw its label when held in the cursor in place of the item count.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

**Overrides parent:** Yes

### select

The [SelectionModeData::mode](prototype:SelectionModeData::mode) is hardcoded to `"upgrade"`.

The filters are parsed, but then ignored and forced to be empty.

**Type:** `SelectionModeData`

**Required:** Yes

**Overrides parent:** Yes

### alt_select

The [SelectionModeData::mode](prototype:SelectionModeData::mode) is hardcoded to `"cancel-upgrade"`.

The filters are parsed, but then ignored and forced to be empty.

**Type:** `SelectionModeData`

**Required:** Yes

**Overrides parent:** Yes

### always_include_tiles

This property is hardcoded to `false`.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

**Overrides parent:** Yes

