# CoverGraphicProcessionLayer

Draws a layer of cloud texture covering the screen. It can fade in an out based on opacity and using the picture mask as gradient of areas which fade in soon or later.

There are two important concepts to understand:

- `mask` refers to something like a depth texture. It is applied across the whole screen and determines how the entire graphic fades in and out.

- `effect` in this context refers to clipping out portion of the cover graphic. It can use an effect_graphic. `is_cloud_effect_advanced` makes the `effect` modify opacity threshold of the `mask` rather than multiplying alpha.

Additionally an area can be masked out by range or effect mask.

