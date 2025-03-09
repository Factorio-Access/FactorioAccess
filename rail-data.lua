local dirs=defines.direction

--This is an attempt to generically describe the rail shapes and connectivity
--In theory this could be used to make a rail planner

--both properties are relative to an enity whose direction maches the first allowed direction
--the positions are specified relative to the entity position
--the directions are the direction a train would pass if moving from entrance to exit
--rail works in both driections but I think the entrance exit terminlogy helps
--if the ends of two rail entitys are at the same position they might join
--if they are one entrance and one exit facing the same direction they join
--or if they are the same type facing opposite direction they also join
--if they're directions are the opposite of the above then they form a fork

--1.0 and 2.0 compatible directions. In 1.0 the new directions will be wrong but not error producing
---@enum dirs16
local dirs16={
   north=dirs.north,
   northnortheast=dirs.north+1,
   northeast=dirs.northeast,
   eastnortheast=dirs.northeast+1,
   east=dirs.east,
   eastsoutheast=dirs.east+1,
   southeast=dirs.southeast,
   southsoutheast=dirs.southeast+1,
   south=dirs.south,
   southsouthwest=dirs.south+1,
   southwest=dirs.southwest,
   westsouthwest=dirs.southwest+1,
   west=dirs.west,
   westnorthwest=dirs.west+1,
   northwest=dirs.northwest,
   northnorthwest=(dirs.northwest+1) % (2*dirs.south)
}



do
   ---@class RailGeometery.ends.end
   ---The postion of this end relative to the entity position while facing the first allowed direction
   ---@field pos MapPosition
   ---The direction a train would be traveling while passing through this end in the forward direction
   ---@field dir dirs16
end

do
---@class RailGeometery.ends
---The entrance to this rail
---@field entrance RailGeometery.ends.end
---The exit to this rail
---@field exit RailGeometery.ends.end
end

do
---@class RailGeometry
---The name to refer to this RailGeometery
---@field name string
---The lua entity type that can have this geometry
---@field proto string 
---The allowed directions where an entity of said prototype will have this geometry
---@field dirs (dirs16)[]
---If mirroring the geometry produces a distinct geometry then the first direction of this list will be a mirror of the first direction of the allowed directions across the y axis.
---If present, the length of this list must match the length of dirs
---@field mirrored_dirs? (defines.direction)[]
---The actual geometry when the enitity is facing the first allowed direction
---@field ends RailGeometery.ends
---The distance a train travels between the entrance and exit 
---@field distance double
---If this Geometry is a ramp such that it's ends are on different levels
---@field ramp? (true|nil)
end

---@type (RailGeometry)[]
local rail_shapes_common={
   {
      name="diagonal",
      dirs={
         dirs16.northeast,
         dirs16.southeast,
         dirs16.southwest,
         dirs16.northwest
      },
      ends={
         entrance={pos={ 0,-1},dir=dirs16.southeast},
         exit={pos={ 1, 0},dir=dirs16.southeast}
      },
      proto="rail",
      distance=math.sqrt(2)
   },
   {
      name="straight",
      dirs={
         dirs16.north,
         dirs16.east
      },
      ends={
         entrance={pos={ 0, 1},dir=dirs16.north},
         exit={pos={ 0, -1},dir=dirs16.north}
      },
      proto="rail",
      distance=2
   }
}
---rail geometries that will stop being allowed to place in 2.0
---@type (RailGeometry)[]
local rail_shapes_1={
   {
      name="curve",
      dirs={
         dirs16.north,
         dirs16.east,
         dirs16.south,
         dirs16.west
      },
      mirrored_dirs={
         dirs16.northeast,
         dirs16.southeast,
         dirs16.southwest,
         dirs16.northwest
      },
      ends={
         entrance={pos={ 1, 4},dir=dirs16.north},
         exit={pos={ -2, -3},dir=dirs16.northwest}
      },
      proto="curved-rail",
      distance=7.842081225095013 --source: https://forums.factorio.com/viewtopic.php?t=109189
   },
}
--rail geometries that will unlock with 2.0
---@type (RailGeometry)[]
local rail_shapes_2={
   {
      name="halfdiag",
      dirs={
         dirs16.north,
         dirs16.east,
         dirs16.south,
         dirs16.west
      },
      mirrored_dirs={
         dirs16.northeast,
         dirs16.southeast,
         dirs16.southwest,
         dirs16.northwest
      },
      ends={
         entrance={pos={ -1,2},dir=dirs16.northnortheast},
         exit={pos={ 1, -2},dir=dirs16.northnortheast}
      },
      proto="half-diagonal-rail",
      distance=math.sqrt(16+4)--4^2 + 2^2
   },
   {
      name="straight_curve_to_half_diag",
      dirs={
         dirs16.north,
         dirs16.south,
         dirs16.east,
         dirs16.west
      },
      mirrored_dirs={
         dirs16.northnortheast,
         dirs16.eastsoutheast,
         dirs16.southsouthwest,
         dirs16.westnorthwest
      },
      ends={
         entrance={pos={ 0,3},dir=dirs16.north},
         exit={pos={ -1, -2},dir=dirs16.northnorthwest}
      },
      proto="curved-a-rail",
      distance= 5.132284556 --source: https://forums.factorio.com/viewtopic.php?p=592880#p592880
   },
   {
      name="diag_curve_to_half_diag",
      dirs={
         dirs16.northeast,
         dirs16.southeast,
         dirs16.southwest,
         dirs16.northwest
      },
      mirror_dirs={ 
         dirs16.northnorthwest,
         dirs16.eastnortheast,
         dirs16.southsoutheast,
         dirs16.westsouthwest
      },
      ends={
         entrance={pos={ -2, 2},dir=dirs16.northeast},
         exit={pos={ 1, -2},dir=dirs16.northnortheast}
      },
      proto="curved-b-rail",
      distance=5.077891568 --source: https://forums.factorio.com/viewtopic.php?p=592880#p592880
   },

}