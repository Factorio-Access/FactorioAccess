# SpaceLocationPrototype

A space location, such as a planet.

**Parent:** `Prototype`

## Properties

### Mandatory Properties

#### distance

**Type:** `double`

Distance from the location's parent body in map coordinates.

#### orientation

**Type:** `RealOrientation`

Angle in relation to the parent body.

### Optional Properties

#### asteroid_spawn_definitions

**Type:** ``SpaceLocationAsteroidSpawnDefinition`[]`



#### asteroid_spawn_influence

**Type:** `double`

If greater than 0, `asteroid_spawn_definitions` will be used on space connections of this location, interpolated based on distance. The number specifies the percentage of the route where the location stops spawning its asteroids.

**Default:** `{'complex_type': 'literal', 'value': 0.1}`

#### auto_save_on_first_trip

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_orbit

**Type:** `boolean`

If `false`, an orbital ring will not be drawn for this location.

**Default:** `{'complex_type': 'literal', 'value': True}`

#### fly_condition

**Type:** `boolean`

When set to true, it means that this connection offers fly condition rather than wait condition at the destination

**Default:** `{'complex_type': 'literal', 'value': False}`

#### gravity_pull

**Type:** `double`

A value which modifies platform speed; is subtracted when traveling from this location and added when traveling to this location.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### icon

**Type:** `FileName`

Path to the icon file.

Mandatory if `icons` is not defined.

#### icon_size

**Type:** `SpriteSizeType`

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 64}`

#### icons

**Type:** ``IconData`[]`

Can't be an empty array.

#### label_orientation

**Type:** `RealOrientation`

The orientation where the location's name will be drawn.

**Default:** `{'complex_type': 'literal', 'value': 0.25}`

#### magnitude

**Type:** `double`

The apparent size of the space location in map coordinates.

**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### parked_platforms_orientation

**Type:** `RealOrientation`

The orientation where parked space platforms will be drawn.

**Default:** `same as orientation`

#### planet_procession_set

**Type:** `ProcessionSet`

These transitions are used for anything traveling from the surface associated with this location.

#### platform_procession_set

**Type:** `ProcessionSet`

These transitions are used for any platform stopped at this location.

#### procession_audio_catalogue

**Type:** `ProcessionAudioCatalogue`



#### procession_graphic_catalogue

**Type:** `ProcessionGraphicCatalogue`



#### solar_power_in_space

**Type:** `double`



**Default:** `{'complex_type': 'literal', 'value': 1.0}`

#### starmap_icon

**Type:** `FileName`

Path to the icon file.

Only loaded if `starmap_icons` is not defined.

#### starmap_icon_size

**Type:** `SpriteSizeType`

The size of the starmap icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `starmap_icons` is not defined.

**Default:** `{'complex_type': 'literal', 'value': 64}`

#### starmap_icons

**Type:** ``IconData`[]`

Can't be an empty array.

