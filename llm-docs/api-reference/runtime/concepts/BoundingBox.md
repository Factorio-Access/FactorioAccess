# BoundingBox

Two positions, specifying the top-left and bottom-right corner of the box respectively. Like with [MapPosition](runtime:MapPosition), the names of the members may be omitted. When read from the game, the third member `orientation` is present if it is non-zero.

**Type:** Table (see below for parameters) | (`MapPosition`, `MapPosition`)

## Examples

```
```
-- Explicit definition
{left_top = {x = -2, y = -3}, right_bottom = {x = 5, y = 8}}
```
```

```
```
-- Shorthand
{{-2, -3}, {5, 8}}
```
```

