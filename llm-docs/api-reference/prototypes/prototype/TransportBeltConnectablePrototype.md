# TransportBeltConnectablePrototype

Abstract class that anything that is a belt or can connect to belts uses.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Abstract:** Yes

## Properties

### belt_animation_set

**Type:** `TransportBeltAnimationSet`

**Optional:** Yes

### speed

The speed of the belt: `speed × 480 = x Items/second`.

The raw value is expressed as the number of tiles traveled by each item on the belt per tick, relative to the belt's maximum density - e.g. `x items/second ÷ (4 items/lane × 2 lanes/belt × 60 ticks/second) = <speed> belts/tick` where a "belt" is the size of one tile. See [Transport_belts/Physics](https://wiki.factorio.com/Transport_belts/Physics) for more details.

Must be a positive non-infinite number. The number is a fixed point number with 8 bits reserved for decimal precision, meaning the smallest value step is `1/2^8 = 0.00390625`. In the simple case of a non-curved belt, the rate is multiples of `1.875` items/s, even though the entity tooltip may show a different rate.

**Type:** `double`

**Required:** Yes

### animation_speed_coefficient

**Type:** `double`

**Optional:** Yes

**Default:** 1

### collision_box

Transport belt connectable entities must have [collision_box](prototype:EntityPrototype::collision_box) of an appropriate minimal size, they should occupy more than half of every tile the entity covers.

**Type:** `BoundingBox`

**Optional:** Yes

**Default:** "Empty = `{{0, 0}, {0, 0}}`"

**Overrides parent:** Yes

**Examples:**

```
collision_box = {{-0.4, -0.4}, {0.4, 0.4}}
```

### flags

Transport belt connectable entities cannot have the `"building-direction-8-way"` flag.

**Type:** `EntityPrototypeFlags`

**Optional:** Yes

**Overrides parent:** Yes

