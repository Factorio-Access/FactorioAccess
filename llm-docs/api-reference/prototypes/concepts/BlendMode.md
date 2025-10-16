# BlendMode

Determines how sprites/animations should blend with the background. The possible values are listed below.

Note that in most of Factorio it is assumed colors are in alpha pre-multiplied format, see [FFF #172 - Blending and Rendering](https://www.factorio.com/blog/post/fff-172). Sprites get pre-multiplied when loaded, unless `premul_alpha` is set to `false` on the sprite/animation itself. Since generating mipmaps doesn't respect `premul_alpha`, lower mipmap levels will be in pre-multiplied format regardless.

**Type:** `"normal"` | `"additive"` | `"additive-soft"` | `"multiplicative"` | `"multiplicative-with-alpha"` | `"overwrite"`

