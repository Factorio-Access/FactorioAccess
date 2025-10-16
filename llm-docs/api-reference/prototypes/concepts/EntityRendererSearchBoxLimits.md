# EntityRendererSearchBoxLimits

How far (in tiles) entities should be rendered outside the visible area of the screen.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### left

Min value 6, max value 15. Min value 6 to compensate for shadows.

**Type:** `uint8`

**Required:** Yes

### top

Min value 3, max value 15.

**Type:** `uint8`

**Required:** Yes

### right

Min value 3, max value 15.

**Type:** `uint8`

**Required:** Yes

### bottom

Min value 4, max value 15. Min value 4 to compensate for tall entities like electric poles.

**Type:** `uint8`

**Required:** Yes

