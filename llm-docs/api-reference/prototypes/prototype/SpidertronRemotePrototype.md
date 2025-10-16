# SpidertronRemotePrototype

The [spidertron remote](https://wiki.factorio.com/Spidertron_remote). This remote can only be used for entities of type [SpiderVehiclePrototype](prototype:SpiderVehiclePrototype).

**Parent:** [SelectionToolPrototype](SelectionToolPrototype.md)
**Type name:** `spidertron-remote`

## Properties

### icon_color_indicator_mask

Color mask for the icon. This is used to show the color of the spidertron remote LEDS in the GUI.

**Type:** `FileName`

**Optional:** Yes

### stack_size

Count of items of the same name that can be stored in one inventory slot. Must be 1 when the `"not-stackable"` flag is set.

**Type:** `1`

**Required:** Yes

**Overrides parent:** Yes

**Examples:**

```
stack_size = 1
```

