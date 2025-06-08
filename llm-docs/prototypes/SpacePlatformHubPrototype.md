# SpacePlatformHubPrototype



**Parent:** `EntityWithOwnerPrototype`

## Properties

### Mandatory Properties

#### cargo_station_parameters

**Type:** `CargoStationParameters`



#### dump_container

**Type:** `EntityID`

Name of a [ContainerPrototype](prototype:ContainerPrototype).

#### inventory_size

**Type:** `ItemStackIndex`



### Optional Properties

#### build_grid_size

**Type:** `256`

Has to be 256 to make blueprints snap to (0, 0) most of the time.

**Default:** `{'complex_type': 'literal', 'value': 256}`

#### circuit_connector

**Type:** `CircuitConnectorDefinition`



#### circuit_wire_max_distance

**Type:** `double`

The maximum circuit wire distance for this entity.

**Default:** `{'complex_type': 'literal', 'value': 0}`

#### default_damage_taken_signal

**Type:** `SignalIDConnector`



#### default_speed_signal

**Type:** `SignalIDConnector`



#### draw_circuit_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### draw_copper_wires

**Type:** `boolean`



**Default:** `{'complex_type': 'literal', 'value': True}`

#### graphics_set

**Type:** `CargoBayConnectableGraphicsSet`



#### persistent_ambient_sounds

**Type:** `PersistentWorldAmbientSoundsDefinition`



#### platform_repair_speed_modifier

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 1}`

#### surface_render_parameters

**Type:** `SurfaceRenderParameters`



#### weight

**Type:** `Weight`



**Default:** `{'complex_type': 'literal', 'value': 0}`

