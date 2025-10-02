# ProcessionPrototype

Describes the duration and visuals of a departure, arrival or an intermezzo while traveling between surfaces. Usually provided inside of a [ProcessionSet](prototype:ProcessionSet).

**Parent:** [Prototype](Prototype.md)
**Type name:** `procession`

## Properties

### timeline

Used when leaving or arriving to a station.

**Type:** `ProcessionTimeline`

**Required:** Yes

### ground_timeline

Used alternatively when landing to ground.

**Type:** `ProcessionTimeline`

**Optional:** Yes

### usage

Arrival and Departure are to be referenced by name. All intermezzos are collected during loading and filled in by `procession_style`.

**Type:** `"departure"` | `"arrival"` | `"intermezzo"`

**Required:** Yes

### procession_style

Indexes used to match transitions from different surfaces together. Only a single intermezzo of a given procession_style may exist.

**Type:** `uint32` | Array[`uint32`]

**Required:** Yes

**Examples:**

```
Going from Surface A -> Surface B
Surface A has departures: [1, 3, 4]
Surface B has arrivals:   [2, 3, 5]
This trip will select:
Departure 3 -> (Intermezzo 3) -> Arrival 3
```

