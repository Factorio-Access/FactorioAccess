# SimpleBoundingBox

An axis aligned bounding box.

SimpleBoundingBoxes are usually specified with the short-hand notation of passing an array of exactly 2 numbers. The first position is left_top, the second position is right_bottom.

Positive x goes towards east, positive y goes towards south. This means that the upper-left point is the least dimension in x and y, and lower-right is the greatest.

**Type:** `Struct` (see below for attributes) | (`MapPosition`, `MapPosition`)

## Properties

*These properties apply when the value is a struct/table.*

### left_top

**Type:** `MapPosition`

**Required:** Yes

### right_bottom

**Type:** `MapPosition`

**Required:** Yes

## Examples

```
```
{{-0.4, -0.4}, {0.4, 0.4}}
```
```

```
```
-- long definition
{left_top = {x = -2, y = -3}, right_bottom = {x = 5, y = 8}}
```
```

