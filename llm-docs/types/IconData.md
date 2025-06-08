# IconData

One layer of an icon. Icon layering follows the following rules:

- The rendering order of the individual icon layers follows the array order: Later added icon layers (higher index) are drawn on top of previously added icon layers (lower index).

- By default the first icon layer will draw an outline (or shadow in GUI), other layers will draw it only if they have `draw_background` explicitly set to `true`. There are caveats to this though. See [the doc](prototype:IconData::draw_background).

- When the final icon is displayed with transparency (e.g. a faded out alert), the icon layer overlap may look [undesirable](https://forums.factorio.com/viewtopic.php?p=575844#p575844).

- When the final icon is displayed with a shadow (e.g. an item on the ground or on a belt when item shadows are turned on), each icon layer will [cast a shadow](https://forums.factorio.com/84888) and the shadow is cast on the layer below it.

- The final icon will always be resized and centered in GUI so that all its layers (except the [`floating`](prototype:IconData::floating) ones) fit the target slot, but won't be resized when displayed on machines in alt-mode. For example: recipe first icon layer is size 128, scale 1, the icon group will be displayed at resolution /4 to fit the 32px GUI boxes, but will be displayed 4 times as large on buildings.

- Shift values are based on [`expected_icon_size / 2`](prototype:IconData::scale).

The game automatically generates [icon mipmaps](https://factorio.com/blog/post/fff-291) for all icons. However, icons can have custom mipmaps defined. Custom mipmaps may help to achieve clearer icons at reduced size (e.g. when zooming out) than auto-generated mipmaps. If an icon file contains mipmaps then the game will automatically infer the icon's mipmap count. Icon files for custom mipmaps must contain half-size images with a geometric-ratio, for each mipmap level. Each next level is aligned to the upper-left corner, with no extra padding. Example sequence: `128x128@(0,0)`, `64x64@(128,0)`, `32x32@(192,0)` is three mipmaps.

