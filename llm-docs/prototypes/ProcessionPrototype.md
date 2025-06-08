# ProcessionPrototype

Describes the duration and visuals of a departure, arrival or an intermezzo while traveling between surfaces. Usually provided inside of a [ProcessionSet](prototype:ProcessionSet).

**Parent:** `Prototype`

## Properties

### Mandatory Properties

#### procession_style

**Type:** 

Indexes used to match transitions from different surfaces together. Only a single intermezzo of a given procession_style may exist.

#### timeline

**Type:** `ProcessionTimeline`

Used when leaving or arriving to a station.

#### usage

**Type:** 

Arrival and Departure are to be referenced by name. All intermezzos are collected during loading and filled in by `procession_style`.

### Optional Properties

#### ground_timeline

**Type:** `ProcessionTimeline`

Used alternatively when landing to ground.

