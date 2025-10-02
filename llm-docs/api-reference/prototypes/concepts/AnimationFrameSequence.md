# AnimationFrameSequence

This is a list of 1-based frame indices into the spritesheet. The actual length of the animation will then be the length of the frame_sequence (times `repeat_count`, plus the length minus two if `run_mode` is `"forward-then-backward"`). There is a limit for (actual) animation length of 255 frames.

Indices can be used in any order, repeated or not used at all. Unused frames are not loaded into VRAM at all, frames referenced multiple times are loaded just once, see [here](https://forums.factorio.com/53202).

**Type:** Array[`uint16`]

## Examples

```
```
-- Trivial example - frame_sequence defines same sequence in which the animation would load by default,
-- so it is useless in this case:
frame_count = 4,
frame_sequence = { 1, 2, 3, 4 }
```
```

```
```
-- Usage example - first five times repeat frame 2, then alternate between 4 and 3 two times. Frame 1 is not used:
frame_count = 4,
frame_sequence = { 2, 2, 2, 2, 2, 4, 3, 4, 3 }
```
```

```
```
-- Complex example - animation contains different layers with different frame counts:
local custom_frame_sequence = { 2, 2, 2, 2, 2, 4, 3, 4, 3 }
layers =
{
  {
    -- Animation with custom frame sequence
    frame_count = 4,
    frame_sequence = custom_frame_sequence,
  },
  {
    -- Single sprite that's repeated
    repeat_count = #custom_frame_sequence,
  },
  {
    -- Other animation with different frame count
    -- Assuming: #custom_frame_sequence < frame_count
    frame_count = #custom_frame_sequence,
  },
}
```
```

