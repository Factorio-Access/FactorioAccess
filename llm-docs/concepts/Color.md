# Color

Red, green, blue and alpha values, all in range [0, 1] or all in range [0, 255] if any value is > 1. All values here are optional. Color channels default to `0`, the alpha channel defaults to `1`.

Similar to [MapPosition](runtime:MapPosition), Color allows the short-hand notation of passing an array of exactly 3 or 4 numbers. The game usually expects colors to be in pre-multiplied form (color channels are pre-multiplied by alpha).

