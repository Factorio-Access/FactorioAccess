# MouseCursor

Used by [SelectionToolPrototype::mouse_cursor](prototype:SelectionToolPrototype::mouse_cursor).

**Type name:** `mouse-cursor`

## Examples

```
{
  type = "mouse-cursor",
  name = "selection-tool-cursor",
  filename = "__core__/graphics/cross-select-x32.png",
  hot_pixel_x = 16,
  hot_pixel_y = 16
}
```

```
{
  type = "mouse-cursor",
  name = "system-crosshair",
  system_cursor = "crosshair"
}
```

## Properties

### type

**Type:** `"mouse-cursor"`

**Required:** Yes

### name

Name of the prototype.

**Type:** `string`

**Required:** Yes

### system_cursor

Either this or the other three properties have to be present.

**Type:** `"arrow"` | `"i-beam"` | `"crosshair"` | `"wait-arrow"` | `"size-all"` | `"no"` | `"hand"`

**Optional:** Yes

### filename

Mandatory if `system_cursor` is not defined.

**Type:** `FileName`

**Optional:** Yes

### hot_pixel_x

Mandatory if `system_cursor` is not defined.

**Type:** `int16`

**Optional:** Yes

### hot_pixel_y

Mandatory if `system_cursor` is not defined.

**Type:** `int16`

**Optional:** Yes

