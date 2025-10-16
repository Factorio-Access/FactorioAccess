# cargo_destination

## Values

### invalid

The default destination type of a cargo pod when created runtime. Setting its destination to any other type will instantly launch it.

### orbit

Cargo pods with orbit destination are destroyed when ascent is completed.

### space_platform

Only used for sending a space platform starter pack to a platform that is waiting for one. Regular deliveries to space platform hubs use [station](runtime:defines.cargo_destination.station) destination type instead.

### station

Any cargo landing pad or space platform hub.

### surface

Cargo pods will switch destination type from surface to station before starting descent if there is a station available and [CargoDestination::position](runtime:CargoDestination::position) has not been specified. Note, setting the destination to "surface" when the surface is the same as the one the pod is on forces it to find and set a landing position.

