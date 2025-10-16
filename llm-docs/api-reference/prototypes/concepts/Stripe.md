# Stripe

Used as an alternative way to specify animations.

**Type:** `Struct`

## Properties

*These properties apply when the value is a struct/table.*

### width_in_frames

**Type:** `uint32`

**Required:** Yes

### height_in_frames

Mandatory when Stripe is used in [Animation](prototype:Animation).

Optional when it is used in [RotatedAnimation](prototype:RotatedAnimation), where it defaults to [RotatedAnimation::direction_count](prototype:RotatedAnimation::direction_count).

**Type:** `uint32`

**Required:** Yes

### filename

**Type:** `FileName`

**Required:** Yes

### x

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

### y

**Type:** `uint32`

**Optional:** Yes

**Default:** 0

