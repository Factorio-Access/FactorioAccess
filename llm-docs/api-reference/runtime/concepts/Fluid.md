# Fluid

**Type:** Table

## Parameters

### amount

Amount of the fluid.

**Type:** `double`

**Required:** Yes

### name

Fluid prototype name of the fluid.

**Type:** `string`

**Required:** Yes

### temperature

The temperature. When reading from [LuaFluidBox](runtime:LuaFluidBox), this field will always be present. It is not necessary to specify it when writing, however. When not specified, the fluid will be set to the fluid's default temperature as specified in the fluid's prototype.

**Type:** `float`

**Optional:** Yes

