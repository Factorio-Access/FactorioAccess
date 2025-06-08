# RenderLayer

The render layer specifies the order of the sprite when rendering, most of the objects have it hardcoded in the source, but some are configurable. The union contains valid values from lowest to highest.

Note: `decals` is used as special marker for [DecorativePrototype::render_layer](prototype:DecorativePrototype::render_layer). When used elsewhere, the sprites will draw over the terrain.

