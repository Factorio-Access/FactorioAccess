require("polyfill")

return {
   ["curved-rail-a"] = {
      [defines.direction.east] = {
         bounding_box = {
            left_top = {
               x = -0.171875,
               y = -2.86328125,
            },
            orientation = 0.21858447790145874,
            right_bottom = {
               x = 1.2265625,
               y = 2.16796875,
            },
         },
         [defines.direction.eastnortheast] = {
            extensions = {
               [defines.direction.east] = {
                  direction = defines.direction.west,
                  goal_direction = defines.direction.east,
                  goal_position = {
                     x = 8,
                     y = -2,
                  },
                  position = {
                     x = 6,
                     y = -2,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.eastnortheast] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.eastnortheast,
                  goal_position = {
                     x = 7,
                     y = -3,
                  },
                  position = {
                     x = 5,
                     y = -2,
                  },
                  prototype = "half-diagonal-rail",
               },
               [defines.direction.northeast] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.northeast,
                  goal_position = {
                     x = 7,
                     y = -4,
                  },
                  position = {
                     x = 5,
                     y = -2,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = 3,
               y = -1,
            },
            signal_locations = {
               alt_in_signal = {
                  direction = defines.direction.eastnortheast,
                  position = {
                     x = 0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.eastnortheast,
                  position = {
                     x = 1.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.westsouthwest,
                  position = {
                     x = 2.5,
                     y = 0.5,
                  },
               },
            },
         },
         grid_offset = {
            x = 0,
            y = 1,
         },
         occupied_tiles = {
            {
               x = -3,
               y = -1,
            },
            {
               x = -2,
               y = -1,
            },
            {
               x = -2,
               y = 0,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 1,
               y = -2,
            },
            {
               x = 1,
               y = -1,
            },
            {
               x = 1,
               y = 0,
            },
            {
               x = 2,
               y = -2,
            },
            {
               x = 2,
               y = -1,
            },
            {
               x = 2,
               y = 0,
            },
            {
               x = 3,
               y = -1,
            },
         },
         [defines.direction.west] = {
            extensions = {
               [defines.direction.west] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.west,
                  goal_position = {
                     x = -4,
                     y = 0,
                  },
                  position = {
                     x = -3,
                     y = 0,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.westnorthwest] = {
                  direction = defines.direction.northwest,
                  goal_direction = defines.direction.westnorthwest,
                  goal_position = {
                     x = -7,
                     y = -1,
                  },
                  position = {
                     x = -4,
                     y = 0,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.westsouthwest] = {
                  direction = defines.direction.west,
                  goal_direction = defines.direction.westsouthwest,
                  goal_position = {
                     x = -7,
                     y = 1,
                  },
                  position = {
                     x = -4,
                     y = 0,
                  },
                  prototype = "curved-rail-a",
               },
            },
            position = {
               x = -2,
               y = 0,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.west,
                  position = {
                     x = -1.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.east,
                  position = {
                     x = -1.5,
                     y = -1.5,
                  },
               },
            },
         },
      },
      [defines.direction.north] = {
         bounding_box = {
            left_top = {
               x = -1.046875,
               y = -3.04296875,
            },
            orientation = 0.96858447790145874,
            right_bottom = {
               x = 0.3515625,
               y = 1.98828125,
            },
         },
         grid_offset = {
            x = 1,
            y = 0,
         },
         [defines.direction.northnorthwest] = {
            extensions = {
               [defines.direction.north] = {
                  direction = defines.direction.south,
                  goal_direction = defines.direction.north,
                  goal_position = {
                     x = -2,
                     y = -8,
                  },
                  position = {
                     x = -2,
                     y = -6,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.northnorthwest] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.northnorthwest,
                  goal_position = {
                     x = -3,
                     y = -7,
                  },
                  position = {
                     x = -2,
                     y = -5,
                  },
                  prototype = "half-diagonal-rail",
               },
               [defines.direction.northwest] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.northwest,
                  goal_position = {
                     x = -4,
                     y = -7,
                  },
                  position = {
                     x = -2,
                     y = -5,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = -1,
               y = -3,
            },
            signal_locations = {
               alt_in_signal = {
                  direction = defines.direction.northnorthwest,
                  position = {
                     x = -0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.northnorthwest,
                  position = {
                     x = -1.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.southsoutheast,
                  position = {
                     x = 0.5,
                     y = -2.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -2,
               y = -3,
            },
            {
               x = -2,
               y = -2,
            },
            {
               x = -2,
               y = -1,
            },
            {
               x = -1,
               y = -4,
            },
            {
               x = -1,
               y = -3,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = -1,
               y = 2,
            },
            {
               x = 0,
               y = -3,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
         },
         [defines.direction.south] = {
            extensions = {
               [defines.direction.south] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.south,
                  goal_position = {
                     x = 0,
                     y = 4,
                  },
                  position = {
                     x = 0,
                     y = 3,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.southsoutheast] = {
                  direction = defines.direction.south,
                  goal_direction = defines.direction.southsoutheast,
                  goal_position = {
                     x = 1,
                     y = 7,
                  },
                  position = {
                     x = 0,
                     y = 4,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.southsouthwest] = {
                  direction = defines.direction.southwest,
                  goal_direction = defines.direction.southsouthwest,
                  goal_position = {
                     x = -1,
                     y = 7,
                  },
                  position = {
                     x = 0,
                     y = 4,
                  },
                  prototype = "curved-rail-a",
               },
            },
            position = {
               x = 0,
               y = 2,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.south,
                  position = {
                     x = 1.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.north,
                  position = {
                     x = -1.5,
                     y = 1.5,
                  },
               },
            },
         },
      },
      [defines.direction.northeast] = {
         bounding_box = {
            left_top = {
               x = -0.3515625,
               y = -3.04296875,
            },
            orientation = 0.031415525823831558,
            right_bottom = {
               x = 1.046875,
               y = 1.98828125,
            },
         },
         grid_offset = {
            x = 1,
            y = 0,
         },
         [defines.direction.northnortheast] = {
            extensions = {
               [defines.direction.north] = {
                  direction = defines.direction.southwest,
                  goal_direction = defines.direction.north,
                  goal_position = {
                     x = 2,
                     y = -8,
                  },
                  position = {
                     x = 2,
                     y = -6,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.northeast] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.northeast,
                  goal_position = {
                     x = 4,
                     y = -7,
                  },
                  position = {
                     x = 2,
                     y = -5,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.northnortheast] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.northnortheast,
                  goal_position = {
                     x = 3,
                     y = -7,
                  },
                  position = {
                     x = 2,
                     y = -5,
                  },
                  prototype = "half-diagonal-rail",
               },
            },
            position = {
               x = 1,
               y = -3,
            },
            signal_locations = {
               alt_out_signal = {
                  direction = defines.direction.southsouthwest,
                  position = {
                     x = 0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.northnortheast,
                  position = {
                     x = -0.5,
                     y = -2.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.southsouthwest,
                  position = {
                     x = 1.5,
                     y = -1.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -1,
               y = -3,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = 0,
               y = -4,
            },
            {
               x = 0,
               y = -3,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 0,
               y = 2,
            },
            {
               x = 1,
               y = -3,
            },
            {
               x = 1,
               y = -2,
            },
            {
               x = 1,
               y = -1,
            },
         },
         [defines.direction.south] = {
            extensions = {
               [defines.direction.south] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.south,
                  goal_position = {
                     x = 0,
                     y = 4,
                  },
                  position = {
                     x = 0,
                     y = 3,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.southsoutheast] = {
                  direction = defines.direction.south,
                  goal_direction = defines.direction.southsoutheast,
                  goal_position = {
                     x = 1,
                     y = 7,
                  },
                  position = {
                     x = 0,
                     y = 4,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.southsouthwest] = {
                  direction = defines.direction.southwest,
                  goal_direction = defines.direction.southsouthwest,
                  goal_position = {
                     x = -1,
                     y = 7,
                  },
                  position = {
                     x = 0,
                     y = 4,
                  },
                  prototype = "curved-rail-a",
               },
            },
            position = {
               x = 0,
               y = 2,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.south,
                  position = {
                     x = 1.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.north,
                  position = {
                     x = -1.5,
                     y = 1.5,
                  },
               },
            },
         },
      },
      [defines.direction.northwest] = {
         bounding_box = {
            left_top = {
               x = -1.2265625,
               y = -2.86328125,
            },
            orientation = 0.78141552209854126,
            right_bottom = {
               x = 0.171875,
               y = 2.16796875,
            },
         },
         [defines.direction.east] = {
            extensions = {
               [defines.direction.east] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.east,
                  goal_position = {
                     x = 4,
                     y = 0,
                  },
                  position = {
                     x = 3,
                     y = 0,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.eastnortheast] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.eastnortheast,
                  goal_position = {
                     x = 7,
                     y = -1,
                  },
                  position = {
                     x = 4,
                     y = 0,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.eastsoutheast] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.eastsoutheast,
                  goal_position = {
                     x = 7,
                     y = 1,
                  },
                  position = {
                     x = 4,
                     y = 0,
                  },
                  prototype = "curved-rail-a",
               },
            },
            position = {
               x = 2,
               y = 0,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.east,
                  position = {
                     x = 1.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.west,
                  position = {
                     x = 1.5,
                     y = 1.5,
                  },
               },
            },
         },
         grid_offset = {
            x = 0,
            y = 1,
         },
         occupied_tiles = {
            {
               x = -4,
               y = -1,
            },
            {
               x = -3,
               y = -2,
            },
            {
               x = -3,
               y = -1,
            },
            {
               x = -3,
               y = 0,
            },
            {
               x = -2,
               y = -2,
            },
            {
               x = -2,
               y = -1,
            },
            {
               x = -2,
               y = 0,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 1,
               y = -1,
            },
            {
               x = 1,
               y = 0,
            },
            {
               x = 2,
               y = -1,
            },
         },
         [defines.direction.westnorthwest] = {
            extensions = {
               [defines.direction.northwest] = {
                  direction = defines.direction.northwest,
                  goal_direction = defines.direction.northwest,
                  goal_position = {
                     x = -7,
                     y = -4,
                  },
                  position = {
                     x = -5,
                     y = -2,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.west] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.west,
                  goal_position = {
                     x = -8,
                     y = -2,
                  },
                  position = {
                     x = -6,
                     y = -2,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.westnorthwest] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.westnorthwest,
                  goal_position = {
                     x = -7,
                     y = -3,
                  },
                  position = {
                     x = -5,
                     y = -2,
                  },
                  prototype = "half-diagonal-rail",
               },
            },
            position = {
               x = -3,
               y = -1,
            },
            signal_locations = {
               alt_out_signal = {
                  direction = defines.direction.eastsoutheast,
                  position = {
                     x = -0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.westnorthwest,
                  position = {
                     x = -2.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.eastsoutheast,
                  position = {
                     x = -1.5,
                     y = -1.5,
                  },
               },
            },
         },
      },
      [defines.direction.south] = {
         bounding_box = {
            left_top = {
               x = -0.3515625,
               y = -1.98828125,
            },
            orientation = 0.46858447790145874,
            right_bottom = {
               x = 1.046875,
               y = 3.04296875,
            },
         },
         grid_offset = {
            x = 1,
            y = 0,
         },
         [defines.direction.north] = {
            extensions = {
               [defines.direction.north] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.north,
                  goal_position = {
                     x = 0,
                     y = -4,
                  },
                  position = {
                     x = 0,
                     y = -3,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.northnortheast] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.northnortheast,
                  goal_position = {
                     x = 1,
                     y = -7,
                  },
                  position = {
                     x = 0,
                     y = -4,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.northnorthwest] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.northnorthwest,
                  goal_position = {
                     x = -1,
                     y = -7,
                  },
                  position = {
                     x = 0,
                     y = -4,
                  },
                  prototype = "curved-rail-a",
               },
            },
            position = {
               x = 0,
               y = -2,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.north,
                  position = {
                     x = -1.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.south,
                  position = {
                     x = 1.5,
                     y = -1.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = -1,
               y = 2,
            },
            {
               x = 0,
               y = -3,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 0,
               y = 2,
            },
            {
               x = 0,
               y = 3,
            },
            {
               x = 1,
               y = 0,
            },
            {
               x = 1,
               y = 1,
            },
            {
               x = 1,
               y = 2,
            },
         },
         [defines.direction.southsoutheast] = {
            extensions = {
               [defines.direction.south] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.south,
                  goal_position = {
                     x = 2,
                     y = 8,
                  },
                  position = {
                     x = 2,
                     y = 6,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.southeast] = {
                  direction = defines.direction.south,
                  goal_direction = defines.direction.southeast,
                  goal_position = {
                     x = 4,
                     y = 7,
                  },
                  position = {
                     x = 2,
                     y = 5,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.southsoutheast] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.southsoutheast,
                  goal_position = {
                     x = 3,
                     y = 7,
                  },
                  position = {
                     x = 2,
                     y = 5,
                  },
                  prototype = "half-diagonal-rail",
               },
            },
            position = {
               x = 1,
               y = 3,
            },
            signal_locations = {
               alt_in_signal = {
                  direction = defines.direction.southsoutheast,
                  position = {
                     x = 0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.southsoutheast,
                  position = {
                     x = 1.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.northnorthwest,
                  position = {
                     x = -0.5,
                     y = 2.5,
                  },
               },
            },
         },
      },
      [defines.direction.southeast] = {
         bounding_box = {
            left_top = {
               x = -0.171875,
               y = -2.16796875,
            },
            orientation = 0.28141552209854126,
            right_bottom = {
               x = 1.2265625,
               y = 2.86328125,
            },
         },
         [defines.direction.eastsoutheast] = {
            extensions = {
               [defines.direction.east] = {
                  direction = defines.direction.northwest,
                  goal_direction = defines.direction.east,
                  goal_position = {
                     x = 8,
                     y = 2,
                  },
                  position = {
                     x = 6,
                     y = 2,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.eastsoutheast] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.eastsoutheast,
                  goal_position = {
                     x = 7,
                     y = 3,
                  },
                  position = {
                     x = 5,
                     y = 2,
                  },
                  prototype = "half-diagonal-rail",
               },
               [defines.direction.southeast] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.southeast,
                  goal_position = {
                     x = 7,
                     y = 4,
                  },
                  position = {
                     x = 5,
                     y = 2,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = 3,
               y = 1,
            },
            signal_locations = {
               alt_out_signal = {
                  direction = defines.direction.westnorthwest,
                  position = {
                     x = 0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.eastsoutheast,
                  position = {
                     x = 2.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.westnorthwest,
                  position = {
                     x = 1.5,
                     y = 1.5,
                  },
               },
            },
         },
         grid_offset = {
            x = 0,
            y = 1,
         },
         occupied_tiles = {
            {
               x = -3,
               y = 0,
            },
            {
               x = -2,
               y = -1,
            },
            {
               x = -2,
               y = 0,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 1,
               y = -1,
            },
            {
               x = 1,
               y = 0,
            },
            {
               x = 1,
               y = 1,
            },
            {
               x = 2,
               y = -1,
            },
            {
               x = 2,
               y = 0,
            },
            {
               x = 2,
               y = 1,
            },
            {
               x = 3,
               y = 0,
            },
         },
         [defines.direction.west] = {
            extensions = {
               [defines.direction.west] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.west,
                  goal_position = {
                     x = -4,
                     y = 0,
                  },
                  position = {
                     x = -3,
                     y = 0,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.westnorthwest] = {
                  direction = defines.direction.northwest,
                  goal_direction = defines.direction.westnorthwest,
                  goal_position = {
                     x = -7,
                     y = -1,
                  },
                  position = {
                     x = -4,
                     y = 0,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.westsouthwest] = {
                  direction = defines.direction.west,
                  goal_direction = defines.direction.westsouthwest,
                  goal_position = {
                     x = -7,
                     y = 1,
                  },
                  position = {
                     x = -4,
                     y = 0,
                  },
                  prototype = "curved-rail-a",
               },
            },
            position = {
               x = -2,
               y = 0,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.west,
                  position = {
                     x = -1.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.east,
                  position = {
                     x = -1.5,
                     y = -1.5,
                  },
               },
            },
         },
      },
      [defines.direction.southwest] = {
         bounding_box = {
            left_top = {
               x = -1.046875,
               y = -1.98828125,
            },
            orientation = 0.53141552209854126,
            right_bottom = {
               x = 0.3515625,
               y = 3.04296875,
            },
         },
         grid_offset = {
            x = 1,
            y = 0,
         },
         [defines.direction.north] = {
            extensions = {
               [defines.direction.north] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.north,
                  goal_position = {
                     x = 0,
                     y = -4,
                  },
                  position = {
                     x = 0,
                     y = -3,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.northnortheast] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.northnortheast,
                  goal_position = {
                     x = 1,
                     y = -7,
                  },
                  position = {
                     x = 0,
                     y = -4,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.northnorthwest] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.northnorthwest,
                  goal_position = {
                     x = -1,
                     y = -7,
                  },
                  position = {
                     x = 0,
                     y = -4,
                  },
                  prototype = "curved-rail-a",
               },
            },
            position = {
               x = 0,
               y = -2,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.north,
                  position = {
                     x = -1.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.south,
                  position = {
                     x = 1.5,
                     y = -1.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -2,
               y = 0,
            },
            {
               x = -2,
               y = 1,
            },
            {
               x = -2,
               y = 2,
            },
            {
               x = -1,
               y = -3,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = -1,
               y = 2,
            },
            {
               x = -1,
               y = 3,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 0,
               y = 2,
            },
         },
         [defines.direction.southsouthwest] = {
            extensions = {
               [defines.direction.south] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.south,
                  goal_position = {
                     x = -2,
                     y = 8,
                  },
                  position = {
                     x = -2,
                     y = 6,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.southsouthwest] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.southsouthwest,
                  goal_position = {
                     x = -3,
                     y = 7,
                  },
                  position = {
                     x = -2,
                     y = 5,
                  },
                  prototype = "half-diagonal-rail",
               },
               [defines.direction.southwest] = {
                  direction = defines.direction.southwest,
                  goal_direction = defines.direction.southwest,
                  goal_position = {
                     x = -4,
                     y = 7,
                  },
                  position = {
                     x = -2,
                     y = 5,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = -1,
               y = 3,
            },
            signal_locations = {
               alt_out_signal = {
                  direction = defines.direction.northnortheast,
                  position = {
                     x = -0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.southsouthwest,
                  position = {
                     x = 0.5,
                     y = 2.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.northnortheast,
                  position = {
                     x = -1.5,
                     y = 1.5,
                  },
               },
            },
         },
      },
      [defines.direction.west] = {
         bounding_box = {
            left_top = {
               x = -1.2265625,
               y = -2.16796875,
            },
            orientation = 0.71858447790145874,
            right_bottom = {
               x = 0.171875,
               y = 2.86328125,
            },
         },
         [defines.direction.east] = {
            extensions = {
               [defines.direction.east] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.east,
                  goal_position = {
                     x = 4,
                     y = 0,
                  },
                  position = {
                     x = 3,
                     y = 0,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.eastnortheast] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.eastnortheast,
                  goal_position = {
                     x = 7,
                     y = -1,
                  },
                  position = {
                     x = 4,
                     y = 0,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.eastsoutheast] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.eastsoutheast,
                  goal_position = {
                     x = 7,
                     y = 1,
                  },
                  position = {
                     x = 4,
                     y = 0,
                  },
                  prototype = "curved-rail-a",
               },
            },
            position = {
               x = 2,
               y = 0,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.east,
                  position = {
                     x = 1.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.west,
                  position = {
                     x = 1.5,
                     y = 1.5,
                  },
               },
            },
         },
         grid_offset = {
            x = 0,
            y = 1,
         },
         occupied_tiles = {
            {
               x = -4,
               y = 0,
            },
            {
               x = -3,
               y = -1,
            },
            {
               x = -3,
               y = 0,
            },
            {
               x = -3,
               y = 1,
            },
            {
               x = -2,
               y = -1,
            },
            {
               x = -2,
               y = 0,
            },
            {
               x = -2,
               y = 1,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 1,
               y = -1,
            },
            {
               x = 1,
               y = 0,
            },
            {
               x = 2,
               y = 0,
            },
         },
         [defines.direction.westsouthwest] = {
            extensions = {
               [defines.direction.southwest] = {
                  direction = defines.direction.west,
                  goal_direction = defines.direction.southwest,
                  goal_position = {
                     x = -7,
                     y = 4,
                  },
                  position = {
                     x = -5,
                     y = 2,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.west] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.west,
                  goal_position = {
                     x = -8,
                     y = 2,
                  },
                  position = {
                     x = -6,
                     y = 2,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.westsouthwest] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.westsouthwest,
                  goal_position = {
                     x = -7,
                     y = 3,
                  },
                  position = {
                     x = -5,
                     y = 2,
                  },
                  prototype = "half-diagonal-rail",
               },
            },
            position = {
               x = -3,
               y = 1,
            },
            signal_locations = {
               alt_in_signal = {
                  direction = defines.direction.westsouthwest,
                  position = {
                     x = -0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.westsouthwest,
                  position = {
                     x = -1.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.eastnortheast,
                  position = {
                     x = -2.5,
                     y = -0.5,
                  },
               },
            },
         },
      },
   },
   ["curved-rail-b"] = {
      [defines.direction.east] = {
         bounding_box = {
            left_top = {
               x = -0.6328125,
               y = -2.8828125,
            },
            orientation = 0.14812374114990234,
            right_bottom = {
               x = 0.765625,
               y = 1.9921875,
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         [defines.direction.northeast] = {
            extensions = {
               [defines.direction.eastnortheast] = {
                  direction = defines.direction.west,
                  goal_direction = defines.direction.eastnortheast,
                  goal_position = {
                     x = 6,
                     y = -5,
                  },
                  position = {
                     x = 4,
                     y = -4,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.northeast] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.northeast,
                  goal_position = {
                     x = 4,
                     y = -4,
                  },
                  position = {
                     x = 3,
                     y = -3,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.northnortheast] = {
                  direction = defines.direction.southwest,
                  goal_direction = defines.direction.northnortheast,
                  goal_position = {
                     x = 5,
                     y = -6,
                  },
                  position = {
                     x = 4,
                     y = -4,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = 2,
               y = -2,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.northeast,
                  position = {
                     x = 0.5,
                     y = -2.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.southwest,
                  position = {
                     x = 2.5,
                     y = -0.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -3,
               y = 0,
            },
            {
               x = -2,
               y = -1,
            },
            {
               x = -2,
               y = 0,
            },
            {
               x = -2,
               y = 1,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = 0,
               y = -3,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 1,
               y = -3,
            },
            {
               x = 1,
               y = -2,
            },
            {
               x = 1,
               y = -1,
            },
            {
               x = 2,
               y = -2,
            },
         },
         [defines.direction.westsouthwest] = {
            extensions = {
               [defines.direction.southwest] = {
                  direction = defines.direction.west,
                  goal_direction = defines.direction.southwest,
                  goal_position = {
                     x = -6,
                     y = 4,
                  },
                  position = {
                     x = -4,
                     y = 2,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.west] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.west,
                  goal_position = {
                     x = -7,
                     y = 2,
                  },
                  position = {
                     x = -5,
                     y = 2,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.westsouthwest] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.westsouthwest,
                  goal_position = {
                     x = -6,
                     y = 3,
                  },
                  position = {
                     x = -4,
                     y = 2,
                  },
                  prototype = "half-diagonal-rail",
               },
            },
            position = {
               x = -2,
               y = 1,
            },
            signal_locations = {
               alt_in_signal = {
                  direction = defines.direction.westsouthwest,
                  position = {
                     x = 0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.westsouthwest,
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.eastnortheast,
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
            },
         },
      },
      [defines.direction.north] = {
         bounding_box = {
            left_top = {
               x = -1.14453125,
               y = -2.50390625,
            },
            orientation = 0.89812374114990234,
            right_bottom = {
               x = 0.25390625,
               y = 2.37109375,
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         [defines.direction.northwest] = {
            extensions = {
               [defines.direction.northnorthwest] = {
                  direction = defines.direction.south,
                  goal_direction = defines.direction.northnorthwest,
                  goal_position = {
                     x = -5,
                     y = -6,
                  },
                  position = {
                     x = -4,
                     y = -4,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.northwest] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.northwest,
                  goal_position = {
                     x = -4,
                     y = -4,
                  },
                  position = {
                     x = -3,
                     y = -3,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.westnorthwest] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.westnorthwest,
                  goal_position = {
                     x = -6,
                     y = -5,
                  },
                  position = {
                     x = -4,
                     y = -4,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = -2,
               y = -2,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.northwest,
                  position = {
                     x = -2.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.southeast,
                  position = {
                     x = -0.5,
                     y = -2.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -3,
               y = -2,
            },
            {
               x = -3,
               y = -1,
            },
            {
               x = -2,
               y = -3,
            },
            {
               x = -2,
               y = -2,
            },
            {
               x = -2,
               y = -1,
            },
            {
               x = -2,
               y = 0,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 0,
               y = 2,
            },
            {
               x = 1,
               y = 0,
            },
            {
               x = 1,
               y = 1,
            },
         },
         [defines.direction.southsoutheast] = {
            extensions = {
               [defines.direction.south] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.south,
                  goal_position = {
                     x = 2,
                     y = 7,
                  },
                  position = {
                     x = 2,
                     y = 5,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.southeast] = {
                  direction = defines.direction.south,
                  goal_direction = defines.direction.southeast,
                  goal_position = {
                     x = 4,
                     y = 6,
                  },
                  position = {
                     x = 2,
                     y = 4,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.southsoutheast] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.southsoutheast,
                  goal_position = {
                     x = 3,
                     y = 6,
                  },
                  position = {
                     x = 2,
                     y = 4,
                  },
                  prototype = "half-diagonal-rail",
               },
            },
            position = {
               x = 1,
               y = 2,
            },
            signal_locations = {
               alt_in_signal = {
                  direction = defines.direction.southsoutheast,
                  position = {
                     x = 0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.southsoutheast,
                  position = {
                     x = 1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.northnorthwest,
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
            },
         },
      },
      [defines.direction.northeast] = {
         bounding_box = {
            left_top = {
               x = -0.25390625,
               y = -2.50390625,
            },
            orientation = 0.10187625885009766,
            right_bottom = {
               x = 1.14453125,
               y = 2.37109375,
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         [defines.direction.northeast] = {
            extensions = {
               [defines.direction.eastnortheast] = {
                  direction = defines.direction.west,
                  goal_direction = defines.direction.eastnortheast,
                  goal_position = {
                     x = 6,
                     y = -5,
                  },
                  position = {
                     x = 4,
                     y = -4,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.northeast] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.northeast,
                  goal_position = {
                     x = 4,
                     y = -4,
                  },
                  position = {
                     x = 3,
                     y = -3,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.northnortheast] = {
                  direction = defines.direction.southwest,
                  goal_direction = defines.direction.northnortheast,
                  goal_position = {
                     x = 5,
                     y = -6,
                  },
                  position = {
                     x = 4,
                     y = -4,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = 2,
               y = -2,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.northeast,
                  position = {
                     x = 0.5,
                     y = -2.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.southwest,
                  position = {
                     x = 2.5,
                     y = -0.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -2,
               y = 0,
            },
            {
               x = -2,
               y = 1,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = -1,
               y = 2,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 1,
               y = -3,
            },
            {
               x = 1,
               y = -2,
            },
            {
               x = 1,
               y = -1,
            },
            {
               x = 1,
               y = 0,
            },
            {
               x = 2,
               y = -2,
            },
            {
               x = 2,
               y = -1,
            },
         },
         [defines.direction.southsouthwest] = {
            extensions = {
               [defines.direction.south] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.south,
                  goal_position = {
                     x = -2,
                     y = 7,
                  },
                  position = {
                     x = -2,
                     y = 5,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.southsouthwest] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.southsouthwest,
                  goal_position = {
                     x = -3,
                     y = 6,
                  },
                  position = {
                     x = -2,
                     y = 4,
                  },
                  prototype = "half-diagonal-rail",
               },
               [defines.direction.southwest] = {
                  direction = defines.direction.southwest,
                  goal_direction = defines.direction.southwest,
                  goal_position = {
                     x = -4,
                     y = 6,
                  },
                  position = {
                     x = -2,
                     y = 4,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = -1,
               y = 2,
            },
            signal_locations = {
               alt_out_signal = {
                  direction = defines.direction.northnortheast,
                  position = {
                     x = -0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.southsouthwest,
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.northnortheast,
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
            },
         },
      },
      [defines.direction.northwest] = {
         bounding_box = {
            left_top = {
               x = -0.765625,
               y = -2.8828125,
            },
            orientation = 0.85187625885009766,
            right_bottom = {
               x = 0.6328125,
               y = 1.9921875,
            },
         },
         [defines.direction.eastsoutheast] = {
            extensions = {
               [defines.direction.east] = {
                  direction = defines.direction.northwest,
                  goal_direction = defines.direction.east,
                  goal_position = {
                     x = 7,
                     y = 2,
                  },
                  position = {
                     x = 5,
                     y = 2,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.eastsoutheast] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.eastsoutheast,
                  goal_position = {
                     x = 6,
                     y = 3,
                  },
                  position = {
                     x = 4,
                     y = 2,
                  },
                  prototype = "half-diagonal-rail",
               },
               [defines.direction.southeast] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.southeast,
                  goal_position = {
                     x = 6,
                     y = 4,
                  },
                  position = {
                     x = 4,
                     y = 2,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = 2,
               y = 1,
            },
            signal_locations = {
               alt_out_signal = {
                  direction = defines.direction.westnorthwest,
                  position = {
                     x = -0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.eastsoutheast,
                  position = {
                     x = 1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.westnorthwest,
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         [defines.direction.northwest] = {
            extensions = {
               [defines.direction.northnorthwest] = {
                  direction = defines.direction.south,
                  goal_direction = defines.direction.northnorthwest,
                  goal_position = {
                     x = -5,
                     y = -6,
                  },
                  position = {
                     x = -4,
                     y = -4,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.northwest] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.northwest,
                  goal_position = {
                     x = -4,
                     y = -4,
                  },
                  position = {
                     x = -3,
                     y = -3,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.westnorthwest] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.westnorthwest,
                  goal_position = {
                     x = -6,
                     y = -5,
                  },
                  position = {
                     x = -4,
                     y = -4,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = -2,
               y = -2,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.northwest,
                  position = {
                     x = -2.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.southeast,
                  position = {
                     x = -0.5,
                     y = -2.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -3,
               y = -2,
            },
            {
               x = -2,
               y = -3,
            },
            {
               x = -2,
               y = -2,
            },
            {
               x = -2,
               y = -1,
            },
            {
               x = -1,
               y = -3,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 1,
               y = -1,
            },
            {
               x = 1,
               y = 0,
            },
            {
               x = 1,
               y = 1,
            },
            {
               x = 2,
               y = 0,
            },
         },
      },
      [defines.direction.south] = {
         bounding_box = {
            left_top = {
               x = -0.25390625,
               y = -2.37109375,
            },
            orientation = 0.39812374114990234,
            right_bottom = {
               x = 1.14453125,
               y = 2.50390625,
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         [defines.direction.northnorthwest] = {
            extensions = {
               [defines.direction.north] = {
                  direction = defines.direction.south,
                  goal_direction = defines.direction.north,
                  goal_position = {
                     x = -2,
                     y = -7,
                  },
                  position = {
                     x = -2,
                     y = -5,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.northnorthwest] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.northnorthwest,
                  goal_position = {
                     x = -3,
                     y = -6,
                  },
                  position = {
                     x = -2,
                     y = -4,
                  },
                  prototype = "half-diagonal-rail",
               },
               [defines.direction.northwest] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.northwest,
                  goal_position = {
                     x = -4,
                     y = -6,
                  },
                  position = {
                     x = -2,
                     y = -4,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = -1,
               y = -2,
            },
            signal_locations = {
               alt_in_signal = {
                  direction = defines.direction.northnorthwest,
                  position = {
                     x = -0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.northnorthwest,
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.southsoutheast,
                  position = {
                     x = 0.5,
                     y = -1.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -2,
               y = -2,
            },
            {
               x = -2,
               y = -1,
            },
            {
               x = -1,
               y = -3,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 1,
               y = -1,
            },
            {
               x = 1,
               y = 0,
            },
            {
               x = 1,
               y = 1,
            },
            {
               x = 1,
               y = 2,
            },
            {
               x = 2,
               y = 0,
            },
            {
               x = 2,
               y = 1,
            },
         },
         [defines.direction.southeast] = {
            extensions = {
               [defines.direction.eastsoutheast] = {
                  direction = defines.direction.northwest,
                  goal_direction = defines.direction.eastsoutheast,
                  goal_position = {
                     x = 6,
                     y = 5,
                  },
                  position = {
                     x = 4,
                     y = 4,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.southeast] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.southeast,
                  goal_position = {
                     x = 4,
                     y = 4,
                  },
                  position = {
                     x = 3,
                     y = 3,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.southsoutheast] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.southsoutheast,
                  goal_position = {
                     x = 5,
                     y = 6,
                  },
                  position = {
                     x = 4,
                     y = 4,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = 2,
               y = 2,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.southeast,
                  position = {
                     x = 2.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.northwest,
                  position = {
                     x = 0.5,
                     y = 2.5,
                  },
               },
            },
         },
      },
      [defines.direction.southeast] = {
         bounding_box = {
            left_top = {
               x = -0.6328125,
               y = -1.9921875,
            },
            orientation = 0.35187625885009766,
            right_bottom = {
               x = 0.765625,
               y = 2.8828125,
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         occupied_tiles = {
            {
               x = -3,
               y = -1,
            },
            {
               x = -2,
               y = -2,
            },
            {
               x = -2,
               y = -1,
            },
            {
               x = -2,
               y = 0,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 0,
               y = 2,
            },
            {
               x = 1,
               y = 0,
            },
            {
               x = 1,
               y = 1,
            },
            {
               x = 1,
               y = 2,
            },
            {
               x = 2,
               y = 1,
            },
         },
         [defines.direction.southeast] = {
            extensions = {
               [defines.direction.eastsoutheast] = {
                  direction = defines.direction.northwest,
                  goal_direction = defines.direction.eastsoutheast,
                  goal_position = {
                     x = 6,
                     y = 5,
                  },
                  position = {
                     x = 4,
                     y = 4,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.southeast] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.southeast,
                  goal_position = {
                     x = 4,
                     y = 4,
                  },
                  position = {
                     x = 3,
                     y = 3,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.southsoutheast] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.southsoutheast,
                  goal_position = {
                     x = 5,
                     y = 6,
                  },
                  position = {
                     x = 4,
                     y = 4,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = 2,
               y = 2,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.southeast,
                  position = {
                     x = 2.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.northwest,
                  position = {
                     x = 0.5,
                     y = 2.5,
                  },
               },
            },
         },
         [defines.direction.westnorthwest] = {
            extensions = {
               [defines.direction.northwest] = {
                  direction = defines.direction.northwest,
                  goal_direction = defines.direction.northwest,
                  goal_position = {
                     x = -6,
                     y = -4,
                  },
                  position = {
                     x = -4,
                     y = -2,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.west] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.west,
                  goal_position = {
                     x = -7,
                     y = -2,
                  },
                  position = {
                     x = -5,
                     y = -2,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.westnorthwest] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.westnorthwest,
                  goal_position = {
                     x = -6,
                     y = -3,
                  },
                  position = {
                     x = -4,
                     y = -2,
                  },
                  prototype = "half-diagonal-rail",
               },
            },
            position = {
               x = -2,
               y = -1,
            },
            signal_locations = {
               alt_out_signal = {
                  direction = defines.direction.eastsoutheast,
                  position = {
                     x = 0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.westnorthwest,
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.eastsoutheast,
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
            },
         },
      },
      [defines.direction.southwest] = {
         bounding_box = {
            left_top = {
               x = -1.14453125,
               y = -2.37109375,
            },
            orientation = 0.60187625885009766,
            right_bottom = {
               x = 0.25390625,
               y = 2.50390625,
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         [defines.direction.northnortheast] = {
            extensions = {
               [defines.direction.north] = {
                  direction = defines.direction.southwest,
                  goal_direction = defines.direction.north,
                  goal_position = {
                     x = 2,
                     y = -7,
                  },
                  position = {
                     x = 2,
                     y = -5,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.northeast] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.northeast,
                  goal_position = {
                     x = 4,
                     y = -6,
                  },
                  position = {
                     x = 2,
                     y = -4,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.northnortheast] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.northnortheast,
                  goal_position = {
                     x = 3,
                     y = -6,
                  },
                  position = {
                     x = 2,
                     y = -4,
                  },
                  prototype = "half-diagonal-rail",
               },
            },
            position = {
               x = 1,
               y = -2,
            },
            signal_locations = {
               alt_out_signal = {
                  direction = defines.direction.southsouthwest,
                  position = {
                     x = 0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.northnortheast,
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.southsouthwest,
                  position = {
                     x = 1.5,
                     y = -0.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -3,
               y = 0,
            },
            {
               x = -3,
               y = 1,
            },
            {
               x = -2,
               y = -1,
            },
            {
               x = -2,
               y = 0,
            },
            {
               x = -2,
               y = 1,
            },
            {
               x = -2,
               y = 2,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = 0,
               y = -3,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 1,
               y = -2,
            },
            {
               x = 1,
               y = -1,
            },
         },
         [defines.direction.southwest] = {
            extensions = {
               [defines.direction.southsouthwest] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.southsouthwest,
                  goal_position = {
                     x = -5,
                     y = 6,
                  },
                  position = {
                     x = -4,
                     y = 4,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.southwest] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.southwest,
                  goal_position = {
                     x = -4,
                     y = 4,
                  },
                  position = {
                     x = -3,
                     y = 3,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.westsouthwest] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.westsouthwest,
                  goal_position = {
                     x = -6,
                     y = 5,
                  },
                  position = {
                     x = -4,
                     y = 4,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = -2,
               y = 2,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.southwest,
                  position = {
                     x = -0.5,
                     y = 2.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.northeast,
                  position = {
                     x = -2.5,
                     y = 0.5,
                  },
               },
            },
         },
      },
      [defines.direction.west] = {
         bounding_box = {
            left_top = {
               x = -0.765625,
               y = -1.9921875,
            },
            orientation = 0.64812374114990234,
            right_bottom = {
               x = 0.6328125,
               y = 2.8828125,
            },
         },
         [defines.direction.eastnortheast] = {
            extensions = {
               [defines.direction.east] = {
                  direction = defines.direction.west,
                  goal_direction = defines.direction.east,
                  goal_position = {
                     x = 7,
                     y = -2,
                  },
                  position = {
                     x = 5,
                     y = -2,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.eastnortheast] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.eastnortheast,
                  goal_position = {
                     x = 6,
                     y = -3,
                  },
                  position = {
                     x = 4,
                     y = -2,
                  },
                  prototype = "half-diagonal-rail",
               },
               [defines.direction.northeast] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.northeast,
                  goal_position = {
                     x = 6,
                     y = -4,
                  },
                  position = {
                     x = 4,
                     y = -2,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = 2,
               y = -1,
            },
            signal_locations = {
               alt_in_signal = {
                  direction = defines.direction.eastnortheast,
                  position = {
                     x = -0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.eastnortheast,
                  position = {
                     x = 0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.westsouthwest,
                  position = {
                     x = 1.5,
                     y = 0.5,
                  },
               },
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         occupied_tiles = {
            {
               x = -3,
               y = 1,
            },
            {
               x = -2,
               y = 0,
            },
            {
               x = -2,
               y = 1,
            },
            {
               x = -2,
               y = 2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = -1,
               y = 2,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 1,
               y = -2,
            },
            {
               x = 1,
               y = -1,
            },
            {
               x = 1,
               y = 0,
            },
            {
               x = 2,
               y = -1,
            },
         },
         [defines.direction.southwest] = {
            extensions = {
               [defines.direction.southsouthwest] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.southsouthwest,
                  goal_position = {
                     x = -5,
                     y = 6,
                  },
                  position = {
                     x = -4,
                     y = 4,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.southwest] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.southwest,
                  goal_position = {
                     x = -4,
                     y = 4,
                  },
                  position = {
                     x = -3,
                     y = 3,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.westsouthwest] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.westsouthwest,
                  goal_position = {
                     x = -6,
                     y = 5,
                  },
                  position = {
                     x = -4,
                     y = 4,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = -2,
               y = 2,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.southwest,
                  position = {
                     x = -0.5,
                     y = 2.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.northeast,
                  position = {
                     x = -2.5,
                     y = 0.5,
                  },
               },
            },
         },
      },
   },
   ["half-diagonal-rail"] = {
      [defines.direction.east] = {
         bounding_box = {
            left_top = {
               x = -0.75,
               y = -1.8984375,
            },
            orientation = 0.17620819807052612,
            right_bottom = {
               x = 0.75,
               y = 1.8984375,
            },
         },
         [defines.direction.eastnortheast] = {
            extensions = {
               [defines.direction.east] = {
                  direction = defines.direction.west,
                  goal_direction = defines.direction.east,
                  goal_position = {
                     x = 7,
                     y = -2,
                  },
                  position = {
                     x = 5,
                     y = -2,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.eastnortheast] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.eastnortheast,
                  goal_position = {
                     x = 6,
                     y = -3,
                  },
                  position = {
                     x = 4,
                     y = -2,
                  },
                  prototype = "half-diagonal-rail",
               },
               [defines.direction.northeast] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.northeast,
                  goal_position = {
                     x = 6,
                     y = -4,
                  },
                  position = {
                     x = 4,
                     y = -2,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = 2,
               y = -1,
            },
            signal_locations = {
               alt_in_signal = {
                  direction = defines.direction.eastnortheast,
                  position = {
                     x = -0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.eastnortheast,
                  position = {
                     x = 0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.westsouthwest,
                  position = {
                     x = 1.5,
                     y = 0.5,
                  },
               },
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         occupied_tiles = {
            {
               x = -3,
               y = 0,
            },
            {
               x = -2,
               y = -1,
            },
            {
               x = -2,
               y = 0,
            },
            {
               x = -2,
               y = 1,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 1,
               y = -2,
            },
            {
               x = 1,
               y = -1,
            },
            {
               x = 1,
               y = 0,
            },
            {
               x = 2,
               y = -1,
            },
         },
         [defines.direction.westsouthwest] = {
            extensions = {
               [defines.direction.southwest] = {
                  direction = defines.direction.west,
                  goal_direction = defines.direction.southwest,
                  goal_position = {
                     x = -6,
                     y = 4,
                  },
                  position = {
                     x = -4,
                     y = 2,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.west] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.west,
                  goal_position = {
                     x = -7,
                     y = 2,
                  },
                  position = {
                     x = -5,
                     y = 2,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.westsouthwest] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.westsouthwest,
                  goal_position = {
                     x = -6,
                     y = 3,
                  },
                  position = {
                     x = -4,
                     y = 2,
                  },
                  prototype = "half-diagonal-rail",
               },
            },
            position = {
               x = -2,
               y = 1,
            },
            signal_locations = {
               alt_in_signal = {
                  direction = defines.direction.westsouthwest,
                  position = {
                     x = 0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.westsouthwest,
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.eastnortheast,
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
            },
         },
      },
      [defines.direction.north] = {
         bounding_box = {
            left_top = {
               x = -0.75,
               y = -1.8984375,
            },
            orientation = 0.92620819807052612,
            right_bottom = {
               x = 0.75,
               y = 1.8984375,
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         [defines.direction.northnorthwest] = {
            extensions = {
               [defines.direction.north] = {
                  direction = defines.direction.south,
                  goal_direction = defines.direction.north,
                  goal_position = {
                     x = -2,
                     y = -7,
                  },
                  position = {
                     x = -2,
                     y = -5,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.northnorthwest] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.northnorthwest,
                  goal_position = {
                     x = -3,
                     y = -6,
                  },
                  position = {
                     x = -2,
                     y = -4,
                  },
                  prototype = "half-diagonal-rail",
               },
               [defines.direction.northwest] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.northwest,
                  goal_position = {
                     x = -4,
                     y = -6,
                  },
                  position = {
                     x = -2,
                     y = -4,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = -1,
               y = -2,
            },
            signal_locations = {
               alt_in_signal = {
                  direction = defines.direction.northnorthwest,
                  position = {
                     x = -0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.northnorthwest,
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.southsoutheast,
                  position = {
                     x = 0.5,
                     y = -1.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -2,
               y = -2,
            },
            {
               x = -2,
               y = -1,
            },
            {
               x = -1,
               y = -3,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 0,
               y = 2,
            },
            {
               x = 1,
               y = 0,
            },
            {
               x = 1,
               y = 1,
            },
         },
         [defines.direction.southsoutheast] = {
            extensions = {
               [defines.direction.south] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.south,
                  goal_position = {
                     x = 2,
                     y = 7,
                  },
                  position = {
                     x = 2,
                     y = 5,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.southeast] = {
                  direction = defines.direction.south,
                  goal_direction = defines.direction.southeast,
                  goal_position = {
                     x = 4,
                     y = 6,
                  },
                  position = {
                     x = 2,
                     y = 4,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.southsoutheast] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.southsoutheast,
                  goal_position = {
                     x = 3,
                     y = 6,
                  },
                  position = {
                     x = 2,
                     y = 4,
                  },
                  prototype = "half-diagonal-rail",
               },
            },
            position = {
               x = 1,
               y = 2,
            },
            signal_locations = {
               alt_in_signal = {
                  direction = defines.direction.southsoutheast,
                  position = {
                     x = 0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.southsoutheast,
                  position = {
                     x = 1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.northnorthwest,
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
            },
         },
      },
      [defines.direction.northeast] = {
         bounding_box = {
            left_top = {
               x = -0.75,
               y = -1.8984375,
            },
            orientation = 0.073791809380054474,
            right_bottom = {
               x = 0.75,
               y = 1.8984375,
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         [defines.direction.northnortheast] = {
            extensions = {
               [defines.direction.north] = {
                  direction = defines.direction.southwest,
                  goal_direction = defines.direction.north,
                  goal_position = {
                     x = 2,
                     y = -7,
                  },
                  position = {
                     x = 2,
                     y = -5,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.northeast] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.northeast,
                  goal_position = {
                     x = 4,
                     y = -6,
                  },
                  position = {
                     x = 2,
                     y = -4,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.northnortheast] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.northnortheast,
                  goal_position = {
                     x = 3,
                     y = -6,
                  },
                  position = {
                     x = 2,
                     y = -4,
                  },
                  prototype = "half-diagonal-rail",
               },
            },
            position = {
               x = 1,
               y = -2,
            },
            signal_locations = {
               alt_out_signal = {
                  direction = defines.direction.southsouthwest,
                  position = {
                     x = 0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.northnortheast,
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.southsouthwest,
                  position = {
                     x = 1.5,
                     y = -0.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -2,
               y = 0,
            },
            {
               x = -2,
               y = 1,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = -1,
               y = 2,
            },
            {
               x = 0,
               y = -3,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 1,
               y = -2,
            },
            {
               x = 1,
               y = -1,
            },
         },
         [defines.direction.southsouthwest] = {
            extensions = {
               [defines.direction.south] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.south,
                  goal_position = {
                     x = -2,
                     y = 7,
                  },
                  position = {
                     x = -2,
                     y = 5,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.southsouthwest] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.southsouthwest,
                  goal_position = {
                     x = -3,
                     y = 6,
                  },
                  position = {
                     x = -2,
                     y = 4,
                  },
                  prototype = "half-diagonal-rail",
               },
               [defines.direction.southwest] = {
                  direction = defines.direction.southwest,
                  goal_direction = defines.direction.southwest,
                  goal_position = {
                     x = -4,
                     y = 6,
                  },
                  position = {
                     x = -2,
                     y = 4,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = -1,
               y = 2,
            },
            signal_locations = {
               alt_out_signal = {
                  direction = defines.direction.northnortheast,
                  position = {
                     x = -0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.southsouthwest,
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.northnortheast,
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
            },
         },
      },
      [defines.direction.northwest] = {
         bounding_box = {
            left_top = {
               x = -0.75,
               y = -1.8984375,
            },
            orientation = 0.32379180192947388,
            right_bottom = {
               x = 0.75,
               y = 1.8984375,
            },
         },
         [defines.direction.eastsoutheast] = {
            extensions = {
               [defines.direction.east] = {
                  direction = defines.direction.northwest,
                  goal_direction = defines.direction.east,
                  goal_position = {
                     x = 7,
                     y = 2,
                  },
                  position = {
                     x = 5,
                     y = 2,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.eastsoutheast] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.eastsoutheast,
                  goal_position = {
                     x = 6,
                     y = 3,
                  },
                  position = {
                     x = 4,
                     y = 2,
                  },
                  prototype = "half-diagonal-rail",
               },
               [defines.direction.southeast] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.southeast,
                  goal_position = {
                     x = 6,
                     y = 4,
                  },
                  position = {
                     x = 4,
                     y = 2,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = 2,
               y = 1,
            },
            signal_locations = {
               alt_out_signal = {
                  direction = defines.direction.westnorthwest,
                  position = {
                     x = -0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.eastsoutheast,
                  position = {
                     x = 1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.westnorthwest,
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         occupied_tiles = {
            {
               x = -3,
               y = -1,
            },
            {
               x = -2,
               y = -2,
            },
            {
               x = -2,
               y = -1,
            },
            {
               x = -2,
               y = 0,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 1,
               y = -1,
            },
            {
               x = 1,
               y = 0,
            },
            {
               x = 1,
               y = 1,
            },
            {
               x = 2,
               y = 0,
            },
         },
         [defines.direction.westnorthwest] = {
            extensions = {
               [defines.direction.northwest] = {
                  direction = defines.direction.northwest,
                  goal_direction = defines.direction.northwest,
                  goal_position = {
                     x = -6,
                     y = -4,
                  },
                  position = {
                     x = -4,
                     y = -2,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.west] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.west,
                  goal_position = {
                     x = -7,
                     y = -2,
                  },
                  position = {
                     x = -5,
                     y = -2,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.westnorthwest] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.westnorthwest,
                  goal_position = {
                     x = -6,
                     y = -3,
                  },
                  position = {
                     x = -4,
                     y = -2,
                  },
                  prototype = "half-diagonal-rail",
               },
            },
            position = {
               x = -2,
               y = -1,
            },
            signal_locations = {
               alt_out_signal = {
                  direction = defines.direction.eastsoutheast,
                  position = {
                     x = 0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.westnorthwest,
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.eastsoutheast,
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
            },
         },
      },
      [defines.direction.south] = {
         bounding_box = {
            left_top = {
               x = -0.75,
               y = -1.8984375,
            },
            orientation = 0.92620819807052612,
            right_bottom = {
               x = 0.75,
               y = 1.8984375,
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         [defines.direction.northnorthwest] = {
            extensions = {
               [defines.direction.north] = {
                  direction = defines.direction.south,
                  goal_direction = defines.direction.north,
                  goal_position = {
                     x = -2,
                     y = -7,
                  },
                  position = {
                     x = -2,
                     y = -5,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.northnorthwest] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.northnorthwest,
                  goal_position = {
                     x = -3,
                     y = -6,
                  },
                  position = {
                     x = -2,
                     y = -4,
                  },
                  prototype = "half-diagonal-rail",
               },
               [defines.direction.northwest] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.northwest,
                  goal_position = {
                     x = -4,
                     y = -6,
                  },
                  position = {
                     x = -2,
                     y = -4,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = -1,
               y = -2,
            },
            signal_locations = {
               alt_in_signal = {
                  direction = defines.direction.northnorthwest,
                  position = {
                     x = -0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.northnorthwest,
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.southsoutheast,
                  position = {
                     x = 0.5,
                     y = -1.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -2,
               y = -2,
            },
            {
               x = -2,
               y = -1,
            },
            {
               x = -1,
               y = -3,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 0,
               y = 2,
            },
            {
               x = 1,
               y = 0,
            },
            {
               x = 1,
               y = 1,
            },
         },
         [defines.direction.southsoutheast] = {
            extensions = {
               [defines.direction.south] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.south,
                  goal_position = {
                     x = 2,
                     y = 7,
                  },
                  position = {
                     x = 2,
                     y = 5,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.southeast] = {
                  direction = defines.direction.south,
                  goal_direction = defines.direction.southeast,
                  goal_position = {
                     x = 4,
                     y = 6,
                  },
                  position = {
                     x = 2,
                     y = 4,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.southsoutheast] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.southsoutheast,
                  goal_position = {
                     x = 3,
                     y = 6,
                  },
                  position = {
                     x = 2,
                     y = 4,
                  },
                  prototype = "half-diagonal-rail",
               },
            },
            position = {
               x = 1,
               y = 2,
            },
            signal_locations = {
               alt_in_signal = {
                  direction = defines.direction.southsoutheast,
                  position = {
                     x = 0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.southsoutheast,
                  position = {
                     x = 1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.northnorthwest,
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
            },
         },
      },
      [defines.direction.southeast] = {
         bounding_box = {
            left_top = {
               x = -0.75,
               y = -1.8984375,
            },
            orientation = 0.32379180192947388,
            right_bottom = {
               x = 0.75,
               y = 1.8984375,
            },
         },
         [defines.direction.eastsoutheast] = {
            extensions = {
               [defines.direction.east] = {
                  direction = defines.direction.northwest,
                  goal_direction = defines.direction.east,
                  goal_position = {
                     x = 7,
                     y = 2,
                  },
                  position = {
                     x = 5,
                     y = 2,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.eastsoutheast] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.eastsoutheast,
                  goal_position = {
                     x = 6,
                     y = 3,
                  },
                  position = {
                     x = 4,
                     y = 2,
                  },
                  prototype = "half-diagonal-rail",
               },
               [defines.direction.southeast] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.southeast,
                  goal_position = {
                     x = 6,
                     y = 4,
                  },
                  position = {
                     x = 4,
                     y = 2,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = 2,
               y = 1,
            },
            signal_locations = {
               alt_out_signal = {
                  direction = defines.direction.westnorthwest,
                  position = {
                     x = -0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.eastsoutheast,
                  position = {
                     x = 1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.westnorthwest,
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         occupied_tiles = {
            {
               x = -3,
               y = -1,
            },
            {
               x = -2,
               y = -2,
            },
            {
               x = -2,
               y = -1,
            },
            {
               x = -2,
               y = 0,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 1,
               y = -1,
            },
            {
               x = 1,
               y = 0,
            },
            {
               x = 1,
               y = 1,
            },
            {
               x = 2,
               y = 0,
            },
         },
         [defines.direction.westnorthwest] = {
            extensions = {
               [defines.direction.northwest] = {
                  direction = defines.direction.northwest,
                  goal_direction = defines.direction.northwest,
                  goal_position = {
                     x = -6,
                     y = -4,
                  },
                  position = {
                     x = -4,
                     y = -2,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.west] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.west,
                  goal_position = {
                     x = -7,
                     y = -2,
                  },
                  position = {
                     x = -5,
                     y = -2,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.westnorthwest] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.westnorthwest,
                  goal_position = {
                     x = -6,
                     y = -3,
                  },
                  position = {
                     x = -4,
                     y = -2,
                  },
                  prototype = "half-diagonal-rail",
               },
            },
            position = {
               x = -2,
               y = -1,
            },
            signal_locations = {
               alt_out_signal = {
                  direction = defines.direction.eastsoutheast,
                  position = {
                     x = 0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.westnorthwest,
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.eastsoutheast,
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
            },
         },
      },
      [defines.direction.southwest] = {
         bounding_box = {
            left_top = {
               x = -0.75,
               y = -1.8984375,
            },
            orientation = 0.073791809380054474,
            right_bottom = {
               x = 0.75,
               y = 1.8984375,
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         [defines.direction.northnortheast] = {
            extensions = {
               [defines.direction.north] = {
                  direction = defines.direction.southwest,
                  goal_direction = defines.direction.north,
                  goal_position = {
                     x = 2,
                     y = -7,
                  },
                  position = {
                     x = 2,
                     y = -5,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.northeast] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.northeast,
                  goal_position = {
                     x = 4,
                     y = -6,
                  },
                  position = {
                     x = 2,
                     y = -4,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.northnortheast] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.northnortheast,
                  goal_position = {
                     x = 3,
                     y = -6,
                  },
                  position = {
                     x = 2,
                     y = -4,
                  },
                  prototype = "half-diagonal-rail",
               },
            },
            position = {
               x = 1,
               y = -2,
            },
            signal_locations = {
               alt_out_signal = {
                  direction = defines.direction.southsouthwest,
                  position = {
                     x = 0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.northnortheast,
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.southsouthwest,
                  position = {
                     x = 1.5,
                     y = -0.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -2,
               y = 0,
            },
            {
               x = -2,
               y = 1,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = -1,
               y = 2,
            },
            {
               x = 0,
               y = -3,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 1,
               y = -2,
            },
            {
               x = 1,
               y = -1,
            },
         },
         [defines.direction.southsouthwest] = {
            extensions = {
               [defines.direction.south] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.south,
                  goal_position = {
                     x = -2,
                     y = 7,
                  },
                  position = {
                     x = -2,
                     y = 5,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.southsouthwest] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.southsouthwest,
                  goal_position = {
                     x = -3,
                     y = 6,
                  },
                  position = {
                     x = -2,
                     y = 4,
                  },
                  prototype = "half-diagonal-rail",
               },
               [defines.direction.southwest] = {
                  direction = defines.direction.southwest,
                  goal_direction = defines.direction.southwest,
                  goal_position = {
                     x = -4,
                     y = 6,
                  },
                  position = {
                     x = -2,
                     y = 4,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = -1,
               y = 2,
            },
            signal_locations = {
               alt_out_signal = {
                  direction = defines.direction.northnortheast,
                  position = {
                     x = -0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.southsouthwest,
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.northnortheast,
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
            },
         },
      },
      [defines.direction.west] = {
         bounding_box = {
            left_top = {
               x = -0.75,
               y = -1.8984375,
            },
            orientation = 0.17620819807052612,
            right_bottom = {
               x = 0.75,
               y = 1.8984375,
            },
         },
         [defines.direction.eastnortheast] = {
            extensions = {
               [defines.direction.east] = {
                  direction = defines.direction.west,
                  goal_direction = defines.direction.east,
                  goal_position = {
                     x = 7,
                     y = -2,
                  },
                  position = {
                     x = 5,
                     y = -2,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.eastnortheast] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.eastnortheast,
                  goal_position = {
                     x = 6,
                     y = -3,
                  },
                  position = {
                     x = 4,
                     y = -2,
                  },
                  prototype = "half-diagonal-rail",
               },
               [defines.direction.northeast] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.northeast,
                  goal_position = {
                     x = 6,
                     y = -4,
                  },
                  position = {
                     x = 4,
                     y = -2,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = 2,
               y = -1,
            },
            signal_locations = {
               alt_in_signal = {
                  direction = defines.direction.eastnortheast,
                  position = {
                     x = -0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.eastnortheast,
                  position = {
                     x = 0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.westsouthwest,
                  position = {
                     x = 1.5,
                     y = 0.5,
                  },
               },
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         occupied_tiles = {
            {
               x = -3,
               y = 0,
            },
            {
               x = -2,
               y = -1,
            },
            {
               x = -2,
               y = 0,
            },
            {
               x = -2,
               y = 1,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 1,
               y = -2,
            },
            {
               x = 1,
               y = -1,
            },
            {
               x = 1,
               y = 0,
            },
            {
               x = 2,
               y = -1,
            },
         },
         [defines.direction.westsouthwest] = {
            extensions = {
               [defines.direction.southwest] = {
                  direction = defines.direction.west,
                  goal_direction = defines.direction.southwest,
                  goal_position = {
                     x = -6,
                     y = 4,
                  },
                  position = {
                     x = -4,
                     y = 2,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.west] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.west,
                  goal_position = {
                     x = -7,
                     y = 2,
                  },
                  position = {
                     x = -5,
                     y = 2,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.westsouthwest] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.westsouthwest,
                  goal_position = {
                     x = -6,
                     y = 3,
                  },
                  position = {
                     x = -4,
                     y = 2,
                  },
                  prototype = "half-diagonal-rail",
               },
            },
            position = {
               x = -2,
               y = 1,
            },
            signal_locations = {
               alt_in_signal = {
                  direction = defines.direction.westsouthwest,
                  position = {
                     x = 0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = defines.direction.westsouthwest,
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.eastnortheast,
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
            },
         },
      },
   },
   ["straight-rail"] = {
      [defines.direction.east] = {
         bounding_box = {
            left_top = {
               x = -0.69921875,
               y = -0.98828125,
            },
            orientation = 0.25,
            right_bottom = {
               x = 0.69921875,
               y = 0.98828125,
            },
         },
         [defines.direction.east] = {
            extensions = {
               [defines.direction.east] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.east,
                  goal_position = {
                     x = 3,
                     y = 0,
                  },
                  position = {
                     x = 2,
                     y = 0,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.eastnortheast] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.eastnortheast,
                  goal_position = {
                     x = 6,
                     y = -1,
                  },
                  position = {
                     x = 3,
                     y = 0,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.eastsoutheast] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.eastsoutheast,
                  goal_position = {
                     x = 6,
                     y = 1,
                  },
                  position = {
                     x = 3,
                     y = 0,
                  },
                  prototype = "curved-rail-a",
               },
            },
            position = {
               x = 1,
               y = 0,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.east,
                  position = {
                     x = 0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.west,
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         occupied_tiles = {
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
         },
         [defines.direction.west] = {
            extensions = {
               [defines.direction.west] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.west,
                  goal_position = {
                     x = -3,
                     y = 0,
                  },
                  position = {
                     x = -2,
                     y = 0,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.westnorthwest] = {
                  direction = defines.direction.northwest,
                  goal_direction = defines.direction.westnorthwest,
                  goal_position = {
                     x = -6,
                     y = -1,
                  },
                  position = {
                     x = -3,
                     y = 0,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.westsouthwest] = {
                  direction = defines.direction.west,
                  goal_direction = defines.direction.westsouthwest,
                  goal_position = {
                     x = -6,
                     y = 1,
                  },
                  position = {
                     x = -3,
                     y = 0,
                  },
                  prototype = "curved-rail-a",
               },
            },
            position = {
               x = -1,
               y = 0,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.west,
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.east,
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
            },
         },
      },
      [defines.direction.north] = {
         bounding_box = {
            left_top = {
               x = -0.69921875,
               y = -0.98828125,
            },
            right_bottom = {
               x = 0.69921875,
               y = 0.98828125,
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         [defines.direction.north] = {
            extensions = {
               [defines.direction.north] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.north,
                  goal_position = {
                     x = 0,
                     y = -3,
                  },
                  position = {
                     x = 0,
                     y = -2,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.northnortheast] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.northnortheast,
                  goal_position = {
                     x = 1,
                     y = -6,
                  },
                  position = {
                     x = 0,
                     y = -3,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.northnorthwest] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.northnorthwest,
                  goal_position = {
                     x = -1,
                     y = -6,
                  },
                  position = {
                     x = 0,
                     y = -3,
                  },
                  prototype = "curved-rail-a",
               },
            },
            position = {
               x = 0,
               y = -1,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.north,
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.south,
                  position = {
                     x = 1.5,
                     y = -0.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
         },
         [defines.direction.south] = {
            extensions = {
               [defines.direction.south] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.south,
                  goal_position = {
                     x = 0,
                     y = 3,
                  },
                  position = {
                     x = 0,
                     y = 2,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.southsoutheast] = {
                  direction = defines.direction.south,
                  goal_direction = defines.direction.southsoutheast,
                  goal_position = {
                     x = 1,
                     y = 6,
                  },
                  position = {
                     x = 0,
                     y = 3,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.southsouthwest] = {
                  direction = defines.direction.southwest,
                  goal_direction = defines.direction.southsouthwest,
                  goal_position = {
                     x = -1,
                     y = 6,
                  },
                  position = {
                     x = 0,
                     y = 3,
                  },
                  prototype = "curved-rail-a",
               },
            },
            position = {
               x = 0,
               y = 1,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.south,
                  position = {
                     x = 1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.north,
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
            },
         },
      },
      [defines.direction.northeast] = {
         bounding_box = {
            left_top = {
               x = -0.69921875,
               y = -1.34765625,
            },
            orientation = 0.125,
            right_bottom = {
               x = 0.69921875,
               y = 1.34765625,
            },
         },
         grid_offset = {
            x = 0,
            y = 0,
         },
         [defines.direction.northeast] = {
            extensions = {
               [defines.direction.eastnortheast] = {
                  direction = defines.direction.west,
                  goal_direction = defines.direction.eastnortheast,
                  goal_position = {
                     x = 5,
                     y = -4,
                  },
                  position = {
                     x = 3,
                     y = -3,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.northeast] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.northeast,
                  goal_position = {
                     x = 3,
                     y = -3,
                  },
                  position = {
                     x = 2,
                     y = -2,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.northnortheast] = {
                  direction = defines.direction.southwest,
                  goal_direction = defines.direction.northnortheast,
                  goal_position = {
                     x = 4,
                     y = -5,
                  },
                  position = {
                     x = 3,
                     y = -3,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = 1,
               y = -1,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.northeast,
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.southwest,
                  position = {
                     x = 1.5,
                     y = 0.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -2,
               y = 0,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 1,
               y = -1,
            },
         },
         [defines.direction.southwest] = {
            extensions = {
               [defines.direction.southsouthwest] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.southsouthwest,
                  goal_position = {
                     x = -4,
                     y = 5,
                  },
                  position = {
                     x = -3,
                     y = 3,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.southwest] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.southwest,
                  goal_position = {
                     x = -3,
                     y = 3,
                  },
                  position = {
                     x = -2,
                     y = 2,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.westsouthwest] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.westsouthwest,
                  goal_position = {
                     x = -5,
                     y = 4,
                  },
                  position = {
                     x = -3,
                     y = 3,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = -1,
               y = 1,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.southwest,
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.northeast,
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
            },
         },
      },
      [defines.direction.northwest] = {
         bounding_box = {
            left_top = {
               x = -0.69921875,
               y = -1.34765625,
            },
            orientation = 0.375,
            right_bottom = {
               x = 0.69921875,
               y = 1.34765625,
            },
         },
         grid_offset = {
            x = 0,
            y = 0,
         },
         [defines.direction.northwest] = {
            extensions = {
               [defines.direction.northnorthwest] = {
                  direction = defines.direction.south,
                  goal_direction = defines.direction.northnorthwest,
                  goal_position = {
                     x = -4,
                     y = -5,
                  },
                  position = {
                     x = -3,
                     y = -3,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.northwest] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.northwest,
                  goal_position = {
                     x = -3,
                     y = -3,
                  },
                  position = {
                     x = -2,
                     y = -2,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.westnorthwest] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.westnorthwest,
                  goal_position = {
                     x = -5,
                     y = -4,
                  },
                  position = {
                     x = -3,
                     y = -3,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = -1,
               y = -1,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.northwest,
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.southeast,
                  position = {
                     x = 0.5,
                     y = -1.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -2,
               y = -1,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 1,
               y = 0,
            },
         },
         [defines.direction.southeast] = {
            extensions = {
               [defines.direction.eastsoutheast] = {
                  direction = defines.direction.northwest,
                  goal_direction = defines.direction.eastsoutheast,
                  goal_position = {
                     x = 5,
                     y = 4,
                  },
                  position = {
                     x = 3,
                     y = 3,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.southeast] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.southeast,
                  goal_position = {
                     x = 3,
                     y = 3,
                  },
                  position = {
                     x = 2,
                     y = 2,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.southsoutheast] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.southsoutheast,
                  goal_position = {
                     x = 4,
                     y = 5,
                  },
                  position = {
                     x = 3,
                     y = 3,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = 1,
               y = 1,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.southeast,
                  position = {
                     x = 1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.northwest,
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
            },
         },
      },
      [defines.direction.south] = {
         bounding_box = {
            left_top = {
               x = -0.69921875,
               y = -0.98828125,
            },
            right_bottom = {
               x = 0.69921875,
               y = 0.98828125,
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         [defines.direction.north] = {
            extensions = {
               [defines.direction.north] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.north,
                  goal_position = {
                     x = 0,
                     y = -3,
                  },
                  position = {
                     x = 0,
                     y = -2,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.northnortheast] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.northnortheast,
                  goal_position = {
                     x = 1,
                     y = -6,
                  },
                  position = {
                     x = 0,
                     y = -3,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.northnorthwest] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.northnorthwest,
                  goal_position = {
                     x = -1,
                     y = -6,
                  },
                  position = {
                     x = 0,
                     y = -3,
                  },
                  prototype = "curved-rail-a",
               },
            },
            position = {
               x = 0,
               y = -1,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.north,
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.south,
                  position = {
                     x = 1.5,
                     y = -0.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
         },
         [defines.direction.south] = {
            extensions = {
               [defines.direction.south] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.south,
                  goal_position = {
                     x = 0,
                     y = 3,
                  },
                  position = {
                     x = 0,
                     y = 2,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.southsoutheast] = {
                  direction = defines.direction.south,
                  goal_direction = defines.direction.southsoutheast,
                  goal_position = {
                     x = 1,
                     y = 6,
                  },
                  position = {
                     x = 0,
                     y = 3,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.southsouthwest] = {
                  direction = defines.direction.southwest,
                  goal_direction = defines.direction.southsouthwest,
                  goal_position = {
                     x = -1,
                     y = 6,
                  },
                  position = {
                     x = 0,
                     y = 3,
                  },
                  prototype = "curved-rail-a",
               },
            },
            position = {
               x = 0,
               y = 1,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.south,
                  position = {
                     x = 1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.north,
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
            },
         },
      },
      [defines.direction.southeast] = {
         bounding_box = {
            left_top = {
               x = -0.69921875,
               y = -1.34765625,
            },
            orientation = 0.375,
            right_bottom = {
               x = 0.69921875,
               y = 1.34765625,
            },
         },
         grid_offset = {
            x = 0,
            y = 0,
         },
         [defines.direction.northwest] = {
            extensions = {
               [defines.direction.northnorthwest] = {
                  direction = defines.direction.south,
                  goal_direction = defines.direction.northnorthwest,
                  goal_position = {
                     x = -4,
                     y = -5,
                  },
                  position = {
                     x = -3,
                     y = -3,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.northwest] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.northwest,
                  goal_position = {
                     x = -3,
                     y = -3,
                  },
                  position = {
                     x = -2,
                     y = -2,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.westnorthwest] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.westnorthwest,
                  goal_position = {
                     x = -5,
                     y = -4,
                  },
                  position = {
                     x = -3,
                     y = -3,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = -1,
               y = -1,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.northwest,
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.southeast,
                  position = {
                     x = 0.5,
                     y = -1.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -2,
               y = -1,
            },
            {
               x = -1,
               y = -2,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 0,
               y = 1,
            },
            {
               x = 1,
               y = 0,
            },
         },
         [defines.direction.southeast] = {
            extensions = {
               [defines.direction.eastsoutheast] = {
                  direction = defines.direction.northwest,
                  goal_direction = defines.direction.eastsoutheast,
                  goal_position = {
                     x = 5,
                     y = 4,
                  },
                  position = {
                     x = 3,
                     y = 3,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.southeast] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.southeast,
                  goal_position = {
                     x = 3,
                     y = 3,
                  },
                  position = {
                     x = 2,
                     y = 2,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.southsoutheast] = {
                  direction = defines.direction.north,
                  goal_direction = defines.direction.southsoutheast,
                  goal_position = {
                     x = 4,
                     y = 5,
                  },
                  position = {
                     x = 3,
                     y = 3,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = 1,
               y = 1,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.southeast,
                  position = {
                     x = 1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.northwest,
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
            },
         },
      },
      [defines.direction.southwest] = {
         bounding_box = {
            left_top = {
               x = -0.69921875,
               y = -1.34765625,
            },
            orientation = 0.125,
            right_bottom = {
               x = 0.69921875,
               y = 1.34765625,
            },
         },
         grid_offset = {
            x = 0,
            y = 0,
         },
         [defines.direction.northeast] = {
            extensions = {
               [defines.direction.eastnortheast] = {
                  direction = defines.direction.west,
                  goal_direction = defines.direction.eastnortheast,
                  goal_position = {
                     x = 5,
                     y = -4,
                  },
                  position = {
                     x = 3,
                     y = -3,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.northeast] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.northeast,
                  goal_position = {
                     x = 3,
                     y = -3,
                  },
                  position = {
                     x = 2,
                     y = -2,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.northnortheast] = {
                  direction = defines.direction.southwest,
                  goal_direction = defines.direction.northnortheast,
                  goal_position = {
                     x = 4,
                     y = -5,
                  },
                  position = {
                     x = 3,
                     y = -3,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = 1,
               y = -1,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.northeast,
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.southwest,
                  position = {
                     x = 1.5,
                     y = 0.5,
                  },
               },
            },
         },
         occupied_tiles = {
            {
               x = -2,
               y = 0,
            },
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = -1,
               y = 1,
            },
            {
               x = 0,
               y = -2,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
            {
               x = 1,
               y = -1,
            },
         },
         [defines.direction.southwest] = {
            extensions = {
               [defines.direction.southsouthwest] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.southsouthwest,
                  goal_position = {
                     x = -4,
                     y = 5,
                  },
                  position = {
                     x = -3,
                     y = 3,
                  },
                  prototype = "curved-rail-b",
               },
               [defines.direction.southwest] = {
                  direction = defines.direction.northeast,
                  goal_direction = defines.direction.southwest,
                  goal_position = {
                     x = -3,
                     y = 3,
                  },
                  position = {
                     x = -2,
                     y = 2,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.westsouthwest] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.westsouthwest,
                  goal_position = {
                     x = -5,
                     y = 4,
                  },
                  position = {
                     x = -3,
                     y = 3,
                  },
                  prototype = "curved-rail-b",
               },
            },
            position = {
               x = -1,
               y = 1,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.southwest,
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.northeast,
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
            },
         },
      },
      [defines.direction.west] = {
         bounding_box = {
            left_top = {
               x = -0.69921875,
               y = -0.98828125,
            },
            orientation = 0.25,
            right_bottom = {
               x = 0.69921875,
               y = 0.98828125,
            },
         },
         [defines.direction.east] = {
            extensions = {
               [defines.direction.east] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.east,
                  goal_position = {
                     x = 3,
                     y = 0,
                  },
                  position = {
                     x = 2,
                     y = 0,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.eastnortheast] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.eastnortheast,
                  goal_position = {
                     x = 6,
                     y = -1,
                  },
                  position = {
                     x = 3,
                     y = 0,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.eastsoutheast] = {
                  direction = defines.direction.southeast,
                  goal_direction = defines.direction.eastsoutheast,
                  goal_position = {
                     x = 6,
                     y = 1,
                  },
                  position = {
                     x = 3,
                     y = 0,
                  },
                  prototype = "curved-rail-a",
               },
            },
            position = {
               x = 1,
               y = 0,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.east,
                  position = {
                     x = 0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.west,
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
            },
         },
         grid_offset = {
            x = 1,
            y = 1,
         },
         occupied_tiles = {
            {
               x = -1,
               y = -1,
            },
            {
               x = -1,
               y = 0,
            },
            {
               x = 0,
               y = -1,
            },
            {
               x = 0,
               y = 0,
            },
         },
         [defines.direction.west] = {
            extensions = {
               [defines.direction.west] = {
                  direction = defines.direction.east,
                  goal_direction = defines.direction.west,
                  goal_position = {
                     x = -3,
                     y = 0,
                  },
                  position = {
                     x = -2,
                     y = 0,
                  },
                  prototype = "straight-rail",
               },
               [defines.direction.westnorthwest] = {
                  direction = defines.direction.northwest,
                  goal_direction = defines.direction.westnorthwest,
                  goal_position = {
                     x = -6,
                     y = -1,
                  },
                  position = {
                     x = -3,
                     y = 0,
                  },
                  prototype = "curved-rail-a",
               },
               [defines.direction.westsouthwest] = {
                  direction = defines.direction.west,
                  goal_direction = defines.direction.westsouthwest,
                  goal_position = {
                     x = -6,
                     y = 1,
                  },
                  position = {
                     x = -3,
                     y = 0,
                  },
                  prototype = "curved-rail-a",
               },
            },
            position = {
               x = -1,
               y = 0,
            },
            signal_locations = {
               in_signal = {
                  direction = defines.direction.west,
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = defines.direction.east,
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
            },
         },
      },
   },
}
