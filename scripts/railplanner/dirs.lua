local dirs = defines.direction

--1.0 and 2.0 compatible directions. In 1.0 the new directions will be wrong but not error producing
---@enum dirs16
local dirs16 = {
   north = dirs.north,
   northnortheast = dirs.north + 1,
   northeast = dirs.northeast,
   eastnortheast = dirs.northeast + 1,
   east = dirs.east,
   eastsoutheast = dirs.east + 1,
   southeast = dirs.southeast,
   southsoutheast = dirs.southeast + 1,
   south = dirs.south,
   southsouthwest = dirs.south + 1,
   southwest = dirs.southwest,
   westsouthwest = dirs.southwest + 1,
   west = dirs.west,
   westnorthwest = dirs.west + 1,
   northwest = dirs.northwest,
   northnorthwest = (dirs.northwest + 1) % (2 * dirs.south),
}
return dirs16
