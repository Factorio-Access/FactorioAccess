# LuaRenderObject

Reference to a single LuaRendering object.

## Methods

### bring_to_front

Reorder this object so that it is drawn in front of the already existing objects.

### destroy

Destroys this object. Does not error when the object is invalid.

### move_to_back

Reorder this object so that it is drawn in the back of the already existing objects.

### set_corners

Set the corners of the rectangle with this id.

**Parameters:**

- `left_top` `ScriptRenderTarget`: 
- `right_bottom` `ScriptRenderTarget`: 

### set_dashes

Set the length of the dashes and the length of the gaps in this line.

**Parameters:**

- `dash_length` `double`: 
- `gap_length` `double`: 

## Attributes

### alignment

**Type:** `TextAlign`

Alignment of this text.

### angle

**Type:** `float`

Angle of this arc. Angle in radian.

### animation

**Type:** `string`

Animation prototype name of this animation.

### animation_offset

**Type:** `double`

Animation offset of this animation. Animation offset in frames.

### animation_speed

**Type:** `double`

Animation speed of this animation. Animation speed in frames per tick.

### color

**Type:** `Color`

Color or tint of the object.

### dash_length

**Type:** `double`

Dash length of this line.

### draw_on_ground

**Type:** `boolean`

If this object is being drawn on the ground, under most entities and sprites.

### filled

**Type:** `boolean`

If this circle or rectangle is filled.

### font

**Type:** `string`

Font of this text.

### forces

**Type:** 

Forces for which this object is rendered or `nil` if visible to all forces. Writing nil or empty array will make object to be visible to all forces.

### from

**Type:** `ScriptRenderTarget`

Where this line is drawn from.

### gap_length

**Type:** `double`

Length of the gaps in this line.

### id

**Type:** `uint64` _(read-only)_

Unique identifier of this render object.

### intensity

**Type:** `float`

Intensity of this light.

### left_top

**Type:** `ScriptRenderTarget`

Where top left corner of this rectangle is drawn.

### max_radius

**Type:** `double`

Radius of the outer edge of this arc.

### min_radius

**Type:** `double`

Radius of the inner edge of this arc.

### minimum_darkness

**Type:** `float`

Minimum darkness at which this light is rendered.

### object_name

**Type:** `string` _(read-only)_

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

### only_in_alt_mode

**Type:** `boolean`

If this object is only rendered in alt-mode.

### orientation

**Type:** `RealOrientation`

Orientation of this object.

Polygon vertices that are set to an entity will ignore this.

### orientation_target

**Type:** `ScriptRenderTarget`

Target to which this object rotates so that it faces the target. Note that `orientation` is still applied to the object. Writing `nil` will clear the orientation_target. `nil` if no target.

Polygon vertices that are set to an entity will ignore this.

### oriented

**Type:** `boolean`

If this light is rendered with the same orientation as the target entity. Note that `orientation` is still applied to the sprite.

### oriented_offset

**Type:** `Vector`

Offsets the center of the sprite or animation if `orientation_target` is given. This offset will rotate together with the sprite or animation.

### players

**Type:** 

Players for which this object is visible or `nil` if visible to all players.

### radius

**Type:** `double`

Radius of this circle.

### render_layer

**Type:** `RenderLayer`

Render layer of this sprite or animation.

### right_bottom

**Type:** `ScriptRenderTarget`

Where bottom right corner of this rectangle is drawn.

### scale

**Type:** `double`

Scale of the text or light.

### scale_with_zoom

**Type:** `boolean`

If this text scales with player zoom.

### sprite

**Type:** `SpritePath`

Sprite of the sprite or light.

### start_angle

**Type:** `float`

Where this arc starts. Angle in radian.

### surface

**Type:** `LuaSurface` _(read-only)_

Surface this object is rendered on.

### target

**Type:** `ScriptRenderTarget`

Where this object is drawn.

Polygon vertices that are set to an entity will ignore this.

### text

**Type:** `LocalisedString`

Text that is displayed by this text object.

### time_to_live

**Type:** `uint`

Time to live of this object. This will be 0 if the object does not expire.

### to

**Type:** `ScriptRenderTarget`

Where this line is drawn to.

### type

**Type:**  _(read-only)_

Type of this object.

### use_rich_text

**Type:** `boolean`

If this text parses rich text tags.

### use_target_orientation

**Type:** `boolean`

If this object uses the target orientation.

### valid

**Type:** `boolean` _(read-only)_

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

### vertical_alignment

**Type:** `VerticalTextAlign`

Vertical alignment of this text.

### vertices

**Type:** ``ScriptRenderTarget`[]`

Vertices of this polygon.

### visible

**Type:** `boolean`

If this object is rendered to anyone at all.

### width

**Type:** `float`

Width of the object. Value is in pixels (32 per tile).

### x_scale

**Type:** `double`

Horizontal scale of this sprite or animation.

### y_scale

**Type:** `double`

Vertical scale of this sprite or animation.

