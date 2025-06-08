# ElectricEnergyInterfacePrototype

Entity with electric energy source with that can have some of its values changed runtime. Useful for modding in energy consumers/producers.

**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### energy_source

**Type:** `ElectricEnergySource`



### Optional Properties

#### allow_copy_paste

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': False}`

#### animation

**Type:** `Animation`

Only loaded if both `picture` and `pictures` are not defined.

#### animations

**Type:** `Animation4Way`

Only loaded if `picture`, `pictures`, and `animation` are not defined.

#### continuous_animation

**Type:** `boolean`

Whether the electric energy interface animation always runs instead of being scaled to activity.

**Default:** `{'complex_type': 'literal', 'value': False}`

#### energy_production

**Type:** `Energy`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### energy_usage

**Type:** `Energy`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### gui_mode

**Type:** 



**Default:** `{'complex_type': 'literal', 'value': 'none'}`

#### light

**Type:** `LightDefinition`

The light that this electric energy interface emits.

#### picture

**Type:** `Sprite`



#### pictures

**Type:** `Sprite4Way`

Only loaded if `picture` is not defined.

#### render_layer

**Type:** `RenderLayer`



**Default:** `{'complex_type': 'literal', 'value': 'object'}`

