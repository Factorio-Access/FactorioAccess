# MapPosition

Coordinates on a surface, for example of an entity. MapPositions may be specified either as a dictionary with `x`, `y` as keys, or simply as an array with two elements.

The coordinates are saved as a fixed-size 32 bit integer, with 8 bits reserved for decimal precision, meaning the smallest value step is `1/2^8 = 0.00390625` tiles.

**Type:** Table (see below for parameters) | (`double`, `double`)

## Examples

```
```
-- Explicit definition
{x = 5.5, y = 2}
{y = 2.25, x = 5.125}
```
```

```
```
-- Shorthand
{1.625, 2.375}
```
```

