# SpaceLocationPrototype

A space location, such as a planet or the solar system edge.

**Parent:** [Prototype](Prototype.md)
**Type name:** `space-location`

## Properties

### gravity_pull

A value which modifies platform speed; is subtracted when traveling from this location and added when traveling to this location.

**Type:** `double`

**Optional:** Yes

**Default:** 0

### distance

Distance from the sun in map coordinates.

**Type:** `double`

**Required:** Yes

### orientation

Angle in relation to the sun.

**Type:** `RealOrientation`

**Required:** Yes

### magnitude

The apparent size of the space location in map coordinates.

**Type:** `double`

**Optional:** Yes

**Default:** 1.0

### parked_platforms_orientation

The orientation where parked space platforms will be drawn.

**Type:** `RealOrientation`

**Optional:** Yes

**Default:** "same as orientation"

### label_orientation

The orientation where the location's name will be drawn.

**Type:** `RealOrientation`

**Optional:** Yes

**Default:** 0.25

### draw_orbit

If `false`, the orbital ring around the sun will not be drawn for this location.

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### solar_power_in_space

**Type:** `double`

**Optional:** Yes

**Default:** 1.0

### asteroid_spawn_influence

If greater than 0, `asteroid_spawn_definitions` will be used on space connections of this location, interpolated based on distance. The number specifies the percentage of the route where the location stops spawning its asteroids.

**Type:** `double`

**Optional:** Yes

**Default:** 0.1

### fly_condition

When set to true, it means that this connection offers fly condition rather than wait condition at the destination

**Type:** `boolean`

**Optional:** Yes

**Default:** False

### auto_save_on_first_trip

**Type:** `boolean`

**Optional:** Yes

**Default:** True

### procession_graphic_catalogue

**Type:** `ProcessionGraphicCatalogue`

**Optional:** Yes

### procession_audio_catalogue

**Type:** `ProcessionAudioCatalogue`

**Optional:** Yes

### platform_procession_set

These transitions are used for any platform stopped at this location.

**Type:** `ProcessionSet`

**Optional:** Yes

### planet_procession_set

These transitions are used for anything traveling from the surface associated with this location.

**Type:** `ProcessionSet`

**Optional:** Yes

### icons

Can't be an empty array.

**Type:** Array[`IconData`]

**Optional:** Yes

### icon

Path to the icon file.

Only loaded, and mandatory if `icons` is not defined.

**Type:** `FileName`

**Optional:** Yes

### icon_size

The size of the square icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

### starmap_icons

Can't be an empty array.

**Type:** Array[`IconData`]

**Optional:** Yes

### starmap_icon

Path to the icon file.

Only loaded if `starmap_icons` is not defined.

**Type:** `FileName`

**Optional:** Yes

### starmap_icon_size

The size of the starmap icon, in pixels. E.g. `32` for a 32px by 32px icon. Must be larger than `0`.

Only loaded if `starmap_icons` is not defined.

**Type:** `SpriteSizeType`

**Optional:** Yes

**Default:** 64

### starmap_icon_orientation

Orientation of the starmap icon, defaults to pointing towards the sun.

**Type:** `RealOrientation`

**Optional:** Yes

### asteroid_spawn_definitions

**Type:** Array[`SpaceLocationAsteroidSpawnDefinition`]

**Optional:** Yes

### hidden

Hides the space location from the planet selection lists and the space map.

**Type:** `boolean`

**Optional:** Yes

**Default:** False

**Overrides parent:** Yes

