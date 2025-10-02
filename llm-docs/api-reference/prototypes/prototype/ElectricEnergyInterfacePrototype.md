# ElectricEnergyInterfacePrototype

Entity with electric energy source with that can have some of its values changed runtime. Useful for modding in energy consumers/producers.

**Parent:** [EntityWithOwnerPrototype](EntityWithOwnerPrototype.md)
**Type name:** `electric-energy-interface`

## Properties

### energy_source

**Type:** `ElectricEnergySource`

**Required:** Yes

### energy_production

**Type:** `Energy`

**Optional:** Yes

**Default:** 0

**Examples:**

```
energy_production = "500GW"
```

### energy_usage

**Type:** `Energy`

**Optional:** Yes

**Default:** 0

**Examples:**

```
energy_usage = "10kW"
```

### gui_mode

**Type:** `"all"` | `"none"` | `"admins"`

**Optional:** Yes

**Default:** "none"

### continuous_animation

Whether the electric energy interface animation always runs instead of being scaled to activity.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### render_layer

**Type:** `RenderLayer`

**Optional:** Yes

**Default:** "object"

### light

The light that this electric energy interface emits.

**Type:** `LightDefinition`

**Optional:** Yes

### picture

**Type:** `Sprite`

**Optional:** Yes

### pictures

Only loaded if `picture` is not defined.

**Type:** `Sprite4Way`

**Optional:** Yes

### animation

Only loaded if both `picture` and `pictures` are not defined.

**Type:** `Animation`

**Optional:** Yes

### animations

Only loaded if `picture`, `pictures`, and `animation` are not defined.

**Type:** `Animation4Way`

**Optional:** Yes

### allow_copy_paste

**Type:** `boolean`

**Optional:** Yes

**Default:** False

**Overrides parent:** Yes

