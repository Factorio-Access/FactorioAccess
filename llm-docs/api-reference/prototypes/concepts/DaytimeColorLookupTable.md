# DaytimeColorLookupTable

The first member of the tuple states at which time of the day the LUT should be used. If the current game time is between two values defined in the color lookup that have different LUTs, the color is interpolated to create a smooth transition. (Sharp transition can be achieved by having the two values differing only by a small fraction.)

If there is only one tuple, it means that the LUT will be used all the time, regardless of the value of the first member of the tuple.

The second member of the tuple is a lookup table (LUT) for the color which maps the original color to a position in the sprite where the replacement color is found.

**Type:** Array[(`double`, `ColorLookupTable`)]

## Examples

```
```
color_lookup = {{1, "identity"}}
```
```

```
```
color_lookup = {{0.5, "__core__/graphics/color_luts/nightvision.png"}}
```
```

```
```
zoom_to_world_daytime_color_lookup =
{
  {0.25, "identity"},
  {0.45, "__core__/graphics/color_luts/night.png"},
  {0.55, "__core__/graphics/color_luts/night.png"},
  {0.75, "identity"},
}
```
```

