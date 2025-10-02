# TrainPathAllGoalsResult

**Type:** Table

## Parameters

### accessible

Array of the same length as requested goals: each field will tell if related goal is accessible for the train.

**Type:** Array[`boolean`]

**Required:** Yes

### amount_accessible

Amount of goals that are accessible.

**Type:** `uint`

**Required:** Yes

### penalties

Array of the same length as requested goals. Only present if request type was `"all-goals-penalties"`.

**Type:** Array[`double`]

**Optional:** Yes

### steps_count

Amount of steps pathfinder performed. This is a measure of how expensive this search was.

**Type:** `uint`

**Required:** Yes

