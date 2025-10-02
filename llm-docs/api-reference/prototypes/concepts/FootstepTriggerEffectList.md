# FootstepTriggerEffectList

**Type:** Array[`FootstepTriggerEffectItem`]

## Examples

```
```
footstep_particle_triggers =
{
  {
    tiles = { "water", "water-shallow" },
    type = "create-particle",
    particle_name = "water-particle",
    [...]
  },
  {
    tiles = { "grass-1", "grass-2" },
    type = "create-particle",
    particle_name = "grass-particle",
    [...]
  },
  [...]
}
```
```

```
```
footstep_particle_triggers =
{
  {
    tiles = { "water", "water-shallow" },
    actions =
    {
      {
        type = "create-particle",
        particle_name = "water-particle-1",
        [...]
      },
      {
        type = "create-particle",
        particle_name = "water-particle-2",
        [...]
      },
      [...]
    }
  },
  {
    tiles = { "grass-1", "grass-2" },
    actions =
    {
      {
        type = "create-particle",
        particle_name = "grass-particle-1",
        [...]
      },
      {
        type = "create-particle",
        particle_name = "grass-particle-2",
        [...]
      },
      [...]
    }
  }
}
```
```

