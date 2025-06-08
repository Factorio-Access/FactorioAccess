# AnimationFrameSequence

This is a list of 1-based frame indices into the spritesheet. The actual length of the animation will then be the length of the frame_sequence (times `repeat_count`, plus the length minus two if `run_mode` is `"forward-then-backward"`). There is a limit for (actual) animation length of 255 frames.

Indices can be used in any order, repeated or not used at all. Unused frames are not loaded into VRAM at all, frames referenced multiple times are loaded just once, see [here](https://forums.factorio.com/53202).

