# LuaRendering

Allows rendering of geometric shapes, text and sprites in the game world through the global object named `rendering`. Each render object is identified by an id that is universally unique for the lifetime of a whole game.

If an entity target of an object is destroyed or changes surface, then the object is also destroyed.

## Methods

### clear

Destroys all render objects.

**Parameters:**

- `mod_name` `string` _(optional)_: If provided, only the render objects created by this mod are destroyed. An empty string (`""`) refers to all objects not belonging to a mod, such as those created using console commands.

### draw_animation

Create an animation.

**Parameters:**

- `animation` `string`: Name of an [AnimationPrototype](prototype:AnimationPrototype).
- `animation_offset` `double` _(optional)_: Offset of the animation in frames. Default is 0.
- `animation_speed` `double` _(optional)_: How many frames the animation goes forward per tick. Default is 1.
- `forces` `ForceSet` _(optional)_: The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `only_in_alt_mode` `boolean` _(optional)_: If this should only be rendered in alt mode. Defaults to false.
- `orientation` `RealOrientation` _(optional)_: The orientation of the animation. Default is 0.
- `orientation_target` `ScriptRenderTarget` _(optional)_: If given, the animation rotates so that it faces this target. Note that `orientation` is still applied to the animation.
- `oriented_offset` `Vector` _(optional)_: Offsets the center of the animation if `orientation_target` is given. This offset will rotate together with the animation.
- `players` ``PlayerIdentification`[]` _(optional)_: The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `render_layer` `RenderLayer` _(optional)_: Render layer of the animation. Defaults to `"arrow"`.
- `surface` `SurfaceIdentification`: 
- `target` `ScriptRenderTarget`: Center of the animation.
- `time_to_live` `uint` _(optional)_: In ticks. Defaults to living forever.
- `tint` `Color` _(optional)_: 
- `use_target_orientation` `boolean` _(optional)_: Only used if `orientation_target` is a LuaEntity.
- `visible` `boolean` _(optional)_: If this is rendered to anyone at all. Defaults to true.
- `x_scale` `double` _(optional)_: Horizontal scale of the animation. Default is 1.
- `y_scale` `double` _(optional)_: Vertical scale of the animation. Default is 1.

**Returns:**

- `LuaRenderObject`: 

### draw_arc

Create an arc.

**Parameters:**

- `angle` `float`: The angle of the arc, in radian.
- `color` `Color`: 
- `draw_on_ground` `boolean` _(optional)_: If this should be drawn below sprites and entities. Defaults to false.
- `forces` `ForceSet` _(optional)_: The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `max_radius` `double`: The radius of the outer edge of the arc, in tiles.
- `min_radius` `double`: The radius of the inner edge of the arc, in tiles.
- `only_in_alt_mode` `boolean` _(optional)_: If this should only be rendered in alt mode. Defaults to false.
- `players` ``PlayerIdentification`[]` _(optional)_: The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `start_angle` `float`: Where the arc starts, in radian.
- `surface` `SurfaceIdentification`: 
- `target` `ScriptRenderTarget`: 
- `time_to_live` `uint` _(optional)_: In ticks. Defaults to living forever.
- `visible` `boolean` _(optional)_: If this is rendered to anyone at all. Defaults to true.

**Returns:**

- `LuaRenderObject`: 

### draw_circle

Create a circle.

**Parameters:**

- `color` `Color`: 
- `draw_on_ground` `boolean` _(optional)_: If this should be drawn below sprites and entities. Defaults to false.
- `filled` `boolean` _(optional)_: If the circle should be filled. Defaults to false.
- `forces` `ForceSet` _(optional)_: The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `only_in_alt_mode` `boolean` _(optional)_: If this should only be rendered in alt mode. Defaults to false.
- `players` ``PlayerIdentification`[]` _(optional)_: The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `radius` `double`: In tiles.
- `surface` `SurfaceIdentification`: 
- `target` `ScriptRenderTarget`: 
- `time_to_live` `uint` _(optional)_: In ticks. Defaults to living forever.
- `visible` `boolean` _(optional)_: If this is rendered to anyone at all. Defaults to true.
- `width` `float` _(optional)_: Width of the outline, used only if filled = false. Value is in pixels (32 per tile). Defaults to 1.

**Returns:**

- `LuaRenderObject`: 

### draw_light

Create a light.

The base game uses the utility sprites `light_medium` and `light_small` for lights.

**Parameters:**

- `color` `Color` _(optional)_: Defaults to white (no tint).
- `forces` `ForceSet` _(optional)_: The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `intensity` `float` _(optional)_: Default is 1.
- `minimum_darkness` `float` _(optional)_: The minimum darkness at which this light is rendered. Default is 0.
- `only_in_alt_mode` `boolean` _(optional)_: If this should only be rendered in alt mode. Defaults to false.
- `orientation` `RealOrientation` _(optional)_: The orientation of the light. Default is 0.
- `oriented` `boolean` _(optional)_: If this light has the same orientation as the entity target, default is false. Note that `orientation` is still applied to the sprite.
- `players` ``PlayerIdentification`[]` _(optional)_: The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `scale` `float` _(optional)_: Default is 1.
- `sprite` `SpritePath`: 
- `surface` `SurfaceIdentification`: 
- `target` `ScriptRenderTarget`: Center of the light.
- `time_to_live` `uint` _(optional)_: In ticks. Defaults to living forever.
- `visible` `boolean` _(optional)_: If this is rendered to anyone at all. Defaults to true.

**Returns:**

- `LuaRenderObject`: 

### draw_line

Create a line.

**Parameters:**

- `color` `Color`: 
- `dash_length` `double` _(optional)_: Length of the dashes that this line has. Used only if gap_length > 0. Default is 0.
- `dash_offset` `double` _(optional)_: Starting offset to apply to dashes. Cannot be greater than dash_length + gap_length. Default is 0.
- `draw_on_ground` `boolean` _(optional)_: If this should be drawn below sprites and entities. Defaults to false.
- `forces` `ForceSet` _(optional)_: The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `from` `ScriptRenderTarget`: 
- `gap_length` `double` _(optional)_: Length of the gaps that this line has, in tiles. Default is 0.
- `only_in_alt_mode` `boolean` _(optional)_: If this should only be rendered in alt mode. Defaults to false.
- `players` ``PlayerIdentification`[]` _(optional)_: The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `surface` `SurfaceIdentification`: 
- `time_to_live` `uint` _(optional)_: In ticks. Defaults to living forever.
- `to` `ScriptRenderTarget`: 
- `visible` `boolean` _(optional)_: If this is rendered to anyone at all. Defaults to true.
- `width` `float`: In pixels (32 per tile).

**Returns:**

- `LuaRenderObject`: 

### draw_polygon

Create a triangle mesh defined by a triangle strip.

**Parameters:**

- `color` `Color`: 
- `draw_on_ground` `boolean` _(optional)_: If this should be drawn below sprites and entities. Defaults to false.
- `forces` `ForceSet` _(optional)_: The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `only_in_alt_mode` `boolean` _(optional)_: If this should only be rendered in alt mode. Defaults to false.
- `orientation` `RealOrientation` _(optional)_: The orientation applied to all vertices. Default is 0.
- `orientation_target` `ScriptRenderTarget` _(optional)_: If given, the vertices (that are not set to an entity) rotate so that it faces this target. Note that `orientation` is still applied.
- `players` ``PlayerIdentification`[]` _(optional)_: The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `surface` `SurfaceIdentification`: 
- `target` `ScriptRenderTarget` _(optional)_: Acts like an offset applied to all vertices that are not set to an entity.
- `time_to_live` `uint` _(optional)_: In ticks. Defaults to living forever.
- `use_target_orientation` `boolean` _(optional)_: Only used if `orientation_target` is a LuaEntity.
- `vertices` ``ScriptRenderTarget`[]`: 
- `visible` `boolean` _(optional)_: If this is rendered to anyone at all. Defaults to true.

**Returns:**

- `LuaRenderObject`: 

### draw_rectangle

Create a rectangle.

**Parameters:**

- `color` `Color`: 
- `draw_on_ground` `boolean` _(optional)_: If this should be drawn below sprites and entities. Defaults to false.
- `filled` `boolean` _(optional)_: If the rectangle should be filled. Defaults to false.
- `forces` `ForceSet` _(optional)_: The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `left_top` `ScriptRenderTarget`: 
- `only_in_alt_mode` `boolean` _(optional)_: If this should only be rendered in alt mode. Defaults to false.
- `players` ``PlayerIdentification`[]` _(optional)_: The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `right_bottom` `ScriptRenderTarget`: 
- `surface` `SurfaceIdentification`: 
- `time_to_live` `uint` _(optional)_: In ticks. Defaults to living forever.
- `visible` `boolean` _(optional)_: If this is rendered to anyone at all. Defaults to true.
- `width` `float` _(optional)_: Width of the outline, used only if filled = false. Value is in pixels (32 per tile). Defaults to 1.

**Returns:**

- `LuaRenderObject`: 

### draw_sprite

Create a sprite.

**Parameters:**

- `forces` `ForceSet` _(optional)_: The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `only_in_alt_mode` `boolean` _(optional)_: If this should only be rendered in alt mode. Defaults to false.
- `orientation` `RealOrientation` _(optional)_: The orientation of the sprite. Default is 0.
- `orientation_target` `ScriptRenderTarget` _(optional)_: If given, the sprite rotates so that it faces this target. Note that `orientation` is still applied to the sprite.
- `oriented_offset` `Vector` _(optional)_: Offsets the center of the sprite if `orientation_target` is given. This offset will rotate together with the sprite.
- `players` ``PlayerIdentification`[]` _(optional)_: The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `render_layer` `RenderLayer` _(optional)_: Render layer of the sprite. Defaults to `"arrow"`.
- `sprite` `SpritePath`: 
- `surface` `SurfaceIdentification`: 
- `target` `ScriptRenderTarget`: Center of the sprite.
- `time_to_live` `uint` _(optional)_: In ticks. Defaults to living forever.
- `tint` `Color` _(optional)_: 
- `use_target_orientation` `boolean` _(optional)_: Only used if `orientation_target` is a LuaEntity.
- `visible` `boolean` _(optional)_: If this is rendered to anyone at all. Defaults to true.
- `x_scale` `double` _(optional)_: Horizontal scale of the sprite. Default is 1.
- `y_scale` `double` _(optional)_: Vertical scale of the sprite. Default is 1.

**Returns:**

- `LuaRenderObject`: 

### draw_text

Create a text.

Not all fonts support scaling.

**Parameters:**

- `alignment` `TextAlign` _(optional)_: Defaults to "left".
- `color` `Color`: 
- `draw_on_ground` `boolean` _(optional)_: If this should be drawn below sprites and entities. Rich text does not support this option. Defaults to false.
- `font` `string` _(optional)_: Name of font to use. Defaults to the same font as flying-text.
- `forces` `ForceSet` _(optional)_: The forces that this object is rendered to. Passing `nil` or an empty table will render it to all forces.
- `only_in_alt_mode` `boolean` _(optional)_: If this should only be rendered in alt mode. Defaults to false.
- `orientation` `RealOrientation` _(optional)_: The orientation of the text. Default is 0.
- `players` ``PlayerIdentification`[]` _(optional)_: The players that this object is rendered to. Passing `nil` or an empty table will render it to all players.
- `scale` `double` _(optional)_: 
- `scale_with_zoom` `boolean` _(optional)_: Defaults to false. If true, the text scales with player zoom, resulting in it always being the same size on screen, and the size compared to the game world changes.
- `surface` `SurfaceIdentification`: 
- `target` `ScriptRenderTarget`: 
- `text` `LocalisedString`: The text to display.
- `time_to_live` `uint` _(optional)_: In ticks. Defaults to living forever.
- `use_rich_text` `boolean` _(optional)_: If rich text rendering is enabled. Defaults to false.
- `vertical_alignment` `VerticalTextAlign` _(optional)_: Defaults to "top".
- `visible` `boolean` _(optional)_: If this is rendered to anyone at all. Defaults to true.

**Returns:**

- `LuaRenderObject`: 

### get_all_objects

Gets an array of all valid objects.

**Parameters:**

- `mod_name` `string` _(optional)_: If provided, get only the render objects created by this mod. An empty string (`""`) refers to all objects not belonging to a mod, such as those created using console commands.

**Returns:**

- ``LuaRenderObject`[]`: 

### get_object_by_id

Gives LuaRenderObject for given object ID. May return nil if object does not exist or is invalid.

**Parameters:**

- `object_id` `uint64`: 

**Returns:**

- `LuaRenderObject`: 

## Attributes

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

