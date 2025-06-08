# SpaceTileEffectParameters

Nebulae are rendered only behind tiles with the effect, but stars are rendered behind entire terrain. For that reason using two or more tile types with different space effect on one surface is not supported. The game will allow this to happen, but rendering will chose one star configuration for entire screen.

Zoom is recalculated using formula `max(1/1024, pow(max(0, zoom * base_factor + base_offset), exponent) * factor + offset)`.

