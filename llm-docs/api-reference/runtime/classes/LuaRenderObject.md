# LuaRenderObject

Reference to a single [LuaRendering](runtime:LuaRendering) object.

## Attributes

### id

Unique identifier of this render object.

**Read type:** `uint64`

### type

Type of this object.

**Read type:** `"text"` | `"line"` | `"circle"` | `"rectangle"` | `"arc"` | `"polygon"` | `"sprite"` | `"light"` | `"animation"`

### surface

Surface this object is rendered on.

**Read type:** `LuaSurface`

### time_to_live

Time to live of this object. This will be 0 if the object does not expire.

**Read type:** `uint`

**Write type:** `uint`

### blink_interval

Blink interval of this object based on the internal "update tick". When zero, blinking is disabled. For other values, the object will be visible the given number of ticks and then invisible for the same duration. Objects with the same blink interval will blink synchronously. Blink interval of game alerts is 30.

For example, when the interval is 60, the object is visible for 60 ticks and hidden for the next 60.

**Read type:** `uint16`

**Write type:** `uint16`

### forces

Forces for which this object is rendered or `nil` if visible to all forces. Writing nil or empty array will make object to be visible to all forces.

**Read type:** Array[`LuaForce`] | `ForceSet`

**Write type:** Array[`LuaForce`] | `ForceSet`

**Optional:** Yes

### players

Players for which this object is visible or `nil` if visible to all players.

**Read type:** Array[`LuaPlayer`] | Array[`PlayerIdentification`]

**Write type:** Array[`LuaPlayer`] | Array[`PlayerIdentification`]

**Optional:** Yes

### visible

If this object is rendered to anyone at all.

**Read type:** `boolean`

**Write type:** `boolean`

### draw_on_ground

If this object is being drawn on the ground, under most entities and sprites.

In [render_mode](runtime:LuaRenderObject::render_mode) == "chart", this value is unused.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** Text, Line, Circle, Rectangle, Arc, Polygon

### only_in_alt_mode

If this object is only rendered in alt-mode.

**Read type:** `boolean`

**Write type:** `boolean`

### render_mode

Whether the object is rendered in game world or on the chart (map view).

When it is changed, the object is pushed to front of its new group.

**Read type:** `ScriptRenderMode`

**Write type:** `ScriptRenderMode`

### use_target_orientation

If this object uses the target orientation.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** Sprite, Polygon, Animation

### color

Color or tint of the object.

**Read type:** `Color`

**Write type:** `Color`

**Subclasses:** Text, Line, Circle, Rectangle, Arc, Polygon, Sprite, Light, Animation

### width

Width of the object. Value is in pixels (32 per tile).

**Read type:** `float`

**Write type:** `float`

**Subclasses:** Line, Circle, Rectangle

### from

Where this line is drawn from.

**Read type:** `ScriptRenderTarget`

**Write type:** `ScriptRenderTarget`

**Subclasses:** Line

### to

Where this line is drawn to.

**Read type:** `ScriptRenderTarget`

**Write type:** `ScriptRenderTarget`

**Subclasses:** Line

### dash_length

Dash length of this line.

**Read type:** `double`

**Write type:** `double`

**Subclasses:** Line

### gap_length

Length of the gaps in this line.

**Read type:** `double`

**Write type:** `double`

**Subclasses:** Line

### dash_offset

Starting offset to apply to dashes of this line. Cannot be greater than dash_length + gap_length.

**Read type:** `double`

**Write type:** `double`

**Subclasses:** Line

### target

Where this object is drawn.

Polygon vertices that are set to an entity will ignore this.

**Read type:** `ScriptRenderTarget`

**Write type:** `ScriptRenderTarget`

**Subclasses:** Text, Circle, Arc, Polygon, Sprite, Light, Animation

### orientation

Orientation of this object.

Polygon vertices that are set to an entity will ignore this.

**Read type:** `RealOrientation`

**Write type:** `RealOrientation`

**Subclasses:** Text, Polygon, Sprite, Light, Animation

### scale

Scale of the text or light.

**Read type:** `double`

**Write type:** `double`

**Subclasses:** Text, Light

### text

Text that is displayed by this text object.

**Read type:** `LocalisedString`

**Write type:** `LocalisedString`

**Subclasses:** Text

### font

Font of this text.

**Read type:** `string`

**Write type:** `string`

**Subclasses:** Text

### alignment

Alignment of this text.

**Read type:** `TextAlign`

**Write type:** `TextAlign`

**Subclasses:** Text

### vertical_alignment

Vertical alignment of this text.

**Read type:** `VerticalTextAlign`

**Write type:** `VerticalTextAlign`

**Subclasses:** Text

### scale_with_zoom

If this text scales with player zoom.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** Text

### use_rich_text

If this text parses rich text tags.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** Text

### filled

If this circle or rectangle is filled.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** Circle, Rectangle

### radius

Radius of this circle.

**Read type:** `double`

**Write type:** `double`

**Subclasses:** Circle

### left_top

Where top left corner of this rectangle is drawn.

**Read type:** `ScriptRenderTarget`

**Write type:** `ScriptRenderTarget`

**Subclasses:** Rectangle

### right_bottom

Where bottom right corner of this rectangle is drawn.

**Read type:** `ScriptRenderTarget`

**Write type:** `ScriptRenderTarget`

**Subclasses:** Rectangle

### max_radius

Radius of the outer edge of this arc.

**Read type:** `double`

**Write type:** `double`

**Subclasses:** Arc

### min_radius

Radius of the inner edge of this arc.

**Read type:** `double`

**Write type:** `double`

**Subclasses:** Arc

### start_angle

Where this arc starts. Angle in radian.

**Read type:** `float`

**Write type:** `float`

**Subclasses:** Arc

### angle

Angle of this arc. Angle in radian.

**Read type:** `float`

**Write type:** `float`

**Subclasses:** Arc

### vertices

Vertices of this polygon.

**Read type:** Array[`ScriptRenderTarget`]

**Write type:** Array[`ScriptRenderTarget`]

**Subclasses:** Polygon

### sprite

Sprite of the sprite or light.

**Read type:** `SpritePath`

**Write type:** `SpritePath`

**Subclasses:** Sprite, Light

### x_scale

Horizontal scale of this sprite or animation.

**Read type:** `double`

**Write type:** `double`

**Subclasses:** Sprite, Animation

### y_scale

Vertical scale of this sprite or animation.

**Read type:** `double`

**Write type:** `double`

**Subclasses:** Sprite, Animation

### render_layer

Render layer of this sprite or animation.

**Read type:** `RenderLayer`

**Write type:** `RenderLayer`

**Subclasses:** Sprite, Animation

### orientation_target

Target to which this object rotates so that it faces the target. Note that `orientation` is still applied to the object. Writing `nil` will clear the orientation_target. `nil` if no target.

Polygon vertices that are set to an entity will ignore this.

**Read type:** `ScriptRenderTarget`

**Write type:** `ScriptRenderTarget`

**Optional:** Yes

**Subclasses:** Polygon, Sprite, Animation

### oriented_offset

Offsets the center of the sprite or animation if `orientation_target` is given. This offset will rotate together with the sprite or animation.

**Read type:** `Vector`

**Write type:** `Vector`

**Subclasses:** Sprite, Animation

### intensity

Intensity of this light.

**Read type:** `float`

**Write type:** `float`

**Subclasses:** Light

### minimum_darkness

Minimum darkness at which this light is rendered.

**Read type:** `float`

**Write type:** `float`

**Subclasses:** Light

### oriented

If this light is rendered with the same orientation as the target entity. Note that `orientation` is still applied to the sprite.

**Read type:** `boolean`

**Write type:** `boolean`

**Subclasses:** Light

### animation

Animation prototype name of this animation.

**Read type:** `string`

**Write type:** `string`

**Subclasses:** Animation

### animation_speed

Animation speed of this animation. Animation speed in frames per tick.

**Read type:** `double`

**Write type:** `double`

**Subclasses:** Animation

### animation_offset

Animation offset of this animation. Animation offset in frames.

**Read type:** `double`

**Write type:** `double`

**Subclasses:** Animation

### valid

Is this object valid? This Lua object holds a reference to an object within the game engine. It is possible that the game-engine object is removed whilst a mod still holds the corresponding Lua object. If that happens, the object becomes invalid, i.e. this attribute will be `false`. Mods are advised to check for object validity if any change to the game state might have occurred between the creation of the Lua object and its access.

**Read type:** `boolean`

### object_name

The class name of this object. Available even when `valid` is false. For LuaStruct objects it may also be suffixed with a dotted path to a member of the struct.

**Read type:** `string`

## Methods

### destroy

Destroys this object. Does not error when the object is invalid.

### bring_to_front

Reorder this object so that it is drawn in front of the already existing objects.

### move_to_back

Reorder this object so that it is drawn in the back of the already existing objects.

### set_dashes

Set the length of the dashes and the length of the gaps in this line.

**Parameters:**

- `dash_length` `double`
- `gap_length` `double`

### set_corners

Set the corners of the rectangle with this id.

**Parameters:**

- `left_top` `ScriptRenderTarget`
- `right_bottom` `ScriptRenderTarget`

