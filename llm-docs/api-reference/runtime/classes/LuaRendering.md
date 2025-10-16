# LuaRendering

Allows rendering of geometric shapes, text and sprites in the game world through the global object named `rendering`. Each render object is identified by an id that is universally unique for the lifetime of a whole game.

If an entity target of an object is destroyed or changes surface, then the object is also destroyed.

## Attributes

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### draw_line

Create a line.

**Parameters:**

- `blink_interval` `uint16` *(optional)* - In ticks. Defaults to 0 (no blinking). Game alerts use 30.
- `color` `Color`
- `dash_length` `double` *(optional)* - Length of the dashes that this line has. Used only if gap_length > 0. Default is 0.
- `dash_offset` `double` *(optional)* - Starting offset to apply to dashes. Cannot be greater than dash_length + gap_length. Default is 0.
- `draw_on_ground` `boolean` *(optional)* - If this should be drawn below sprites and entities. Defaults to false.
- `forces` `ForceSet` *(optional)* - The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `from` `ScriptRenderTarget`
- `gap_length` `double` *(optional)* - Length of the gaps that this line has, in tiles. Default is 0.
- `only_in_alt_mode` `boolean` *(optional)* - If this should only be rendered in alt mode. Defaults to false.
- `players` Array[`PlayerIdentification`] *(optional)* - The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `render_mode` `ScriptRenderMode` *(optional)* - Mode which this object should render in. Defaults to "game".
- `surface` `SurfaceIdentification`
- `time_to_live` `uint32` *(optional)* - In ticks. Defaults to living forever.
- `to` `ScriptRenderTarget`
- `visible` `boolean` *(optional)* - If this is rendered to anyone at all. Defaults to true.
- `width` `float` - In pixels (32 per tile).

**Returns:**

- `LuaRenderObject`

**Examples:**

```
-- Draw a white and 2 pixel wide line from {0, 0} to {2, 2}.
rendering.draw_line{surface = game.player.surface, from = {0, 0}, to = {2, 2}, color = {1, 1, 1}, width = 2}
```

```
-- Draw a red and 3 pixel wide line from {0, 0} to {0, 5}. The line has 1 tile long dashes and gaps.
rendering.draw_line{surface = game.player.surface, from = {0, 0}, to = {0, 5}, color = {r = 1}, width = 3, gap_length = 1, dash_length = 1}
```

### draw_text

Create a text.

Not all fonts support scaling.

**Parameters:**

- `alignment` `TextAlign` *(optional)* - Defaults to "left".
- `blink_interval` `uint16` *(optional)* - In ticks. Defaults to 0 (no blinking). Game alerts use 30.
- `color` `Color`
- `draw_on_ground` `boolean` *(optional)* - If this should be drawn below sprites and entities. Rich text does not support this option. Defaults to false.
- `font` `string` *(optional)* - Name of font to use. Defaults to the same font as flying-text.
- `forces` `ForceSet` *(optional)* - The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `only_in_alt_mode` `boolean` *(optional)* - If this should only be rendered in alt mode. Defaults to false.
- `orientation` `RealOrientation` *(optional)* - The orientation of the text. Default is 0.
- `players` Array[`PlayerIdentification`] *(optional)* - The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `render_mode` `ScriptRenderMode` *(optional)* - Mode which this object should render in. Defaults to "game".
- `scale` `double` *(optional)*
- `scale_with_zoom` `boolean` *(optional)* - Defaults to false. If true, the text scales with player zoom, resulting in it always being the same size on screen, and the size compared to the game world changes.
- `surface` `SurfaceIdentification`
- `target` `ScriptRenderTarget`
- `text` `LocalisedString` - The text to display.
- `time_to_live` `uint32` *(optional)* - In ticks. Defaults to living forever.
- `use_rich_text` `boolean` *(optional)* - If rich text rendering is enabled. Defaults to false.
- `vertical_alignment` `VerticalTextAlign` *(optional)* - Defaults to "top".
- `visible` `boolean` *(optional)* - If this is rendered to anyone at all. Defaults to true.

**Returns:**

- `LuaRenderObject`

### draw_circle

Create a circle.

**Parameters:**

- `blink_interval` `uint16` *(optional)* - In ticks. Defaults to 0 (no blinking). Game alerts use 30.
- `color` `Color`
- `draw_on_ground` `boolean` *(optional)* - If this should be drawn below sprites and entities. Defaults to false.
- `filled` `boolean` *(optional)* - If the circle should be filled. Defaults to false.
- `forces` `ForceSet` *(optional)* - The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `only_in_alt_mode` `boolean` *(optional)* - If this should only be rendered in alt mode. Defaults to false.
- `players` Array[`PlayerIdentification`] *(optional)* - The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `radius` `double` - In tiles.
- `render_mode` `ScriptRenderMode` *(optional)* - Mode which this object should render in. Defaults to "game".
- `surface` `SurfaceIdentification`
- `target` `ScriptRenderTarget`
- `time_to_live` `uint32` *(optional)* - In ticks. Defaults to living forever.
- `visible` `boolean` *(optional)* - If this is rendered to anyone at all. Defaults to true.
- `width` `float` *(optional)* - Width of the outline, used only if filled = false. Value is in pixels (32 per tile). Defaults to 1.

**Returns:**

- `LuaRenderObject`

### draw_rectangle

Create a rectangle.

**Parameters:**

- `blink_interval` `uint16` *(optional)* - In ticks. Defaults to 0 (no blinking). Game alerts use 30.
- `color` `Color`
- `draw_on_ground` `boolean` *(optional)* - If this should be drawn below sprites and entities. Defaults to false.
- `filled` `boolean` *(optional)* - If the rectangle should be filled. Defaults to false.
- `forces` `ForceSet` *(optional)* - The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `left_top` `ScriptRenderTarget`
- `only_in_alt_mode` `boolean` *(optional)* - If this should only be rendered in alt mode. Defaults to false.
- `players` Array[`PlayerIdentification`] *(optional)* - The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `render_mode` `ScriptRenderMode` *(optional)* - Mode which this object should render in. Defaults to "game".
- `right_bottom` `ScriptRenderTarget`
- `surface` `SurfaceIdentification`
- `time_to_live` `uint32` *(optional)* - In ticks. Defaults to living forever.
- `visible` `boolean` *(optional)* - If this is rendered to anyone at all. Defaults to true.
- `width` `float` *(optional)* - Width of the outline, used only if filled = false. Value is in pixels (32 per tile). Defaults to 1.

**Returns:**

- `LuaRenderObject`

**Examples:**

```
-- Draw a white and 1 pixel wide square outline with the corners {0, 0} and {2, 2}.
rendering.draw_rectangle{surface = game.player.surface, left_top = {0, 0}, right_bottom = {2, 2}, color = {1, 1, 1}}
```

### draw_arc

Create an arc.

**Parameters:**

- `angle` `float` - The angle of the arc, in radian.
- `blink_interval` `uint16` *(optional)* - In ticks. Defaults to 0 (no blinking). Game alerts use 30.
- `color` `Color`
- `draw_on_ground` `boolean` *(optional)* - If this should be drawn below sprites and entities. Defaults to false.
- `forces` `ForceSet` *(optional)* - The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `max_radius` `double` - The radius of the outer edge of the arc, in tiles.
- `min_radius` `double` - The radius of the inner edge of the arc, in tiles.
- `only_in_alt_mode` `boolean` *(optional)* - If this should only be rendered in alt mode. Defaults to false.
- `players` Array[`PlayerIdentification`] *(optional)* - The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `render_mode` `ScriptRenderMode` *(optional)* - Mode which this object should render in. Defaults to "game".
- `start_angle` `float` - Where the arc starts, in radian.
- `surface` `SurfaceIdentification`
- `target` `ScriptRenderTarget`
- `time_to_live` `uint32` *(optional)* - In ticks. Defaults to living forever.
- `visible` `boolean` *(optional)* - If this is rendered to anyone at all. Defaults to true.

**Returns:**

- `LuaRenderObject`

### draw_polygon

Create a triangle mesh defined by a triangle strip.

**Parameters:**

- `blink_interval` `uint16` *(optional)* - In ticks. Defaults to 0 (no blinking). Game alerts use 30.
- `color` `Color`
- `draw_on_ground` `boolean` *(optional)* - If this should be drawn below sprites and entities. Defaults to false.
- `forces` `ForceSet` *(optional)* - The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `only_in_alt_mode` `boolean` *(optional)* - If this should only be rendered in alt mode. Defaults to false.
- `orientation` `RealOrientation` *(optional)* - The orientation applied to all vertices. Default is 0.
- `orientation_target` `ScriptRenderTarget` *(optional)* - If given, the vertices (that are not set to an entity) rotate so that it faces this target. Note that `orientation` is still applied.
- `players` Array[`PlayerIdentification`] *(optional)* - The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `render_mode` `ScriptRenderMode` *(optional)* - Mode which this object should render in. Defaults to "game".
- `surface` `SurfaceIdentification`
- `target` `ScriptRenderTarget` *(optional)* - Acts like an offset applied to all vertices that are not set to an entity.
- `time_to_live` `uint32` *(optional)* - In ticks. Defaults to living forever.
- `use_target_orientation` `boolean` *(optional)* - Only used if `orientation_target` is a LuaEntity.
- `vertices` Array[`ScriptRenderTarget`]
- `visible` `boolean` *(optional)* - If this is rendered to anyone at all. Defaults to true.

**Returns:**

- `LuaRenderObject`

### draw_sprite

Create a sprite.

**Parameters:**

- `blink_interval` `uint16` *(optional)* - In ticks. Defaults to 0 (no blinking). Game alerts use 30.
- `forces` `ForceSet` *(optional)* - The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `only_in_alt_mode` `boolean` *(optional)* - If this should only be rendered in alt mode. Defaults to false.
- `orientation` `RealOrientation` *(optional)* - The orientation of the sprite. Default is 0.
- `orientation_target` `ScriptRenderTarget` *(optional)* - If given, the sprite rotates so that it faces this target. Note that `orientation` is still applied to the sprite.
- `oriented_offset` `Vector` *(optional)* - Offsets the center of the sprite if `orientation_target` is given. This offset will rotate together with the sprite.
- `players` Array[`PlayerIdentification`] *(optional)* - The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `render_layer` `RenderLayer` *(optional)* - Render layer of the sprite. Defaults to `"arrow"`.
- `render_mode` `ScriptRenderMode` *(optional)* - Mode which this object should render in. Defaults to "game".
- `sprite` `SpritePath`
- `surface` `SurfaceIdentification`
- `target` `ScriptRenderTarget` - Center of the sprite.
- `time_to_live` `uint32` *(optional)* - In ticks. Defaults to living forever.
- `tint` `Color` *(optional)*
- `use_target_orientation` `boolean` *(optional)* - Only used if `orientation_target` is a LuaEntity.
- `visible` `boolean` *(optional)* - If this is rendered to anyone at all. Defaults to true.
- `x_scale` `double` *(optional)* - Horizontal scale of the sprite. Default is 1.
- `y_scale` `double` *(optional)* - Vertical scale of the sprite. Default is 1.

**Returns:**

- `LuaRenderObject`

**Examples:**

```
-- This will draw an iron plate icon at the character's feet. The sprite will move together with the character.
rendering.draw_sprite{sprite = "item.iron-plate", target = game.player.character, surface = game.player.surface}
```

```
-- This will draw an iron plate icon at the character's head. The sprite will move together with the character.
rendering.draw_sprite{sprite = "item.iron-plate", target = {entity = game.player.character, offset = {0, -2}}, surface = game.player.surface}
```

### draw_light

Create a light.

The base game uses the utility sprites `light_medium` and `light_small` for lights.

**Parameters:**

- `blink_interval` `uint16` *(optional)* - In ticks. Defaults to 0 (no blinking). Game alerts use 30.
- `color` `Color` *(optional)* - Defaults to white (no tint).
- `forces` `ForceSet` *(optional)* - The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `intensity` `float` *(optional)* - Default is 1.
- `minimum_darkness` `float` *(optional)* - The minimum darkness at which this light is rendered. Default is 0.
- `only_in_alt_mode` `boolean` *(optional)* - If this should only be rendered in alt mode. Defaults to false.
- `orientation` `RealOrientation` *(optional)* - The orientation of the light. Default is 0.
- `oriented` `boolean` *(optional)* - If this light has the same orientation as the entity target, default is false. Note that `orientation` is still applied to the sprite.
- `players` Array[`PlayerIdentification`] *(optional)* - The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `render_mode` `ScriptRenderMode` *(optional)* - Mode which this object should render in. Defaults to "game".
- `scale` `float` *(optional)* - Default is 1.
- `sprite` `SpritePath`
- `surface` `SurfaceIdentification`
- `target` `ScriptRenderTarget` - Center of the light.
- `time_to_live` `uint32` *(optional)* - In ticks. Defaults to living forever.
- `visible` `boolean` *(optional)* - If this is rendered to anyone at all. Defaults to true.

**Returns:**

- `LuaRenderObject`

### draw_animation

Create an animation.

**Parameters:**

- `animation` `string` - Name of an [AnimationPrototype](prototype:AnimationPrototype).
- `animation_offset` `double` *(optional)* - Offset of the animation in frames. Default is 0.
- `animation_speed` `double` *(optional)* - How many frames the animation goes forward per tick. Default is 1.
- `blink_interval` `uint16` *(optional)* - In ticks. Defaults to 0 (no blinking). Game alerts use 30.
- `forces` `ForceSet` *(optional)* - The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `only_in_alt_mode` `boolean` *(optional)* - If this should only be rendered in alt mode. Defaults to false.
- `orientation` `RealOrientation` *(optional)* - The orientation of the animation. Default is 0.
- `orientation_target` `ScriptRenderTarget` *(optional)* - If given, the animation rotates so that it faces this target. Note that `orientation` is still applied to the animation.
- `oriented_offset` `Vector` *(optional)* - Offsets the center of the animation if `orientation_target` is given. This offset will rotate together with the animation.
- `players` Array[`PlayerIdentification`] *(optional)* - The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `render_layer` `RenderLayer` *(optional)* - Render layer of the animation. Defaults to `"arrow"`.
- `render_mode` `ScriptRenderMode` *(optional)* - Mode which this object should render in. Defaults to "game".
- `surface` `SurfaceIdentification`
- `target` `ScriptRenderTarget` - Center of the animation.
- `time_to_live` `uint32` *(optional)* - In ticks. Defaults to living forever.
- `tint` `Color` *(optional)*
- `use_target_orientation` `boolean` *(optional)* - Only used if `orientation_target` is a LuaEntity.
- `visible` `boolean` *(optional)* - If this is rendered to anyone at all. Defaults to true.
- `x_scale` `double` *(optional)* - Horizontal scale of the animation. Default is 1.
- `y_scale` `double` *(optional)* - Vertical scale of the animation. Default is 1.

**Returns:**

- `LuaRenderObject`

### get_all_objects

Gets an array of all valid objects.

**Parameters:**

- `mod_name` `string` *(optional)* - If provided, get only the render objects created by this mod. An empty string (`""`) refers to all objects not belonging to a mod, such as those created using console commands.

**Returns:**

- Array[`LuaRenderObject`]

### clear

Destroys all render objects.

**Parameters:**

- `mod_name` `string` *(optional)* - If provided, only the render objects created by this mod are destroyed. An empty string (`""`) refers to all objects not belonging to a mod, such as those created using console commands.

### get_object_by_id

Gives LuaRenderObject for given object ID. May return nil if object does not exist or is invalid.

**Parameters:**

- `object_id` `uint64`

**Returns:**

- `LuaRenderObject` *(optional)*

