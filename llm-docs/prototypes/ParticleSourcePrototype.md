# ParticleSourcePrototype

Creates particles.

**Parent:** `EntityPrototype`

## Properties

### Mandatory Properties

#### height

**Type:** `float`



#### horizontal_speed

**Type:** `float`



#### time_before_start

**Type:** `float`



#### time_to_live

**Type:** `float`



#### vertical_speed

**Type:** `float`



### Optional Properties

#### height_deviation

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### horizontal_speed_deviation

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### particle

**Type:** `ParticleID`

Mandatory if `smoke` is not defined.

#### smoke

**Type:** ``SmokeSource`[]`

Mandatory if `particle` is not defined.

#### time_before_start_deviation

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### time_to_live_deviation

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

#### vertical_speed_deviation

**Type:** `float`



**Default:** `{'complex_type': 'literal', 'value': 0}`

