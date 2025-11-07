return {
   ["curved-rail-a"] = {
      east = {
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
         eastnortheast = {
            extensions = {
               east = {
                  direction = "west",
                  goal_direction = "east",
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
               eastnortheast = {
                  direction = "east",
                  goal_direction = "eastnortheast",
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
               northeast = {
                  direction = "east",
                  goal_direction = "northeast",
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
            signal_locations = {
               alt_in_signal = {
                  direction = "eastnortheast",
                  position = {
                     x = 0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = "eastnortheast",
                  position = {
                     x = 1.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = "westsouthwest",
                  position = {
                     x = 2.5,
                     y = 0.5,
                  },
               },
            },
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
         shift = {
            x = 0,
            y = 1,
         },
         west = {
            extensions = {
               west = {
                  direction = "east",
                  goal_direction = "west",
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
               westnorthwest = {
                  direction = "northwest",
                  goal_direction = "westnorthwest",
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
               westsouthwest = {
                  direction = "west",
                  goal_direction = "westsouthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "west",
                  position = {
                     x = -1.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = "east",
                  position = {
                     x = -1.5,
                     y = -1.5,
                  },
               },
            },
         },
      },
      north = {
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
         northnorthwest = {
            extensions = {
               north = {
                  direction = "south",
                  goal_direction = "north",
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
               northnorthwest = {
                  direction = "north",
                  goal_direction = "northnorthwest",
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
               northwest = {
                  direction = "north",
                  goal_direction = "northwest",
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
            signal_locations = {
               alt_in_signal = {
                  direction = "northnorthwest",
                  position = {
                     x = -0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = "northnorthwest",
                  position = {
                     x = -1.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = "southsoutheast",
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
         shift = {
            x = 1,
            y = 0,
         },
         south = {
            extensions = {
               south = {
                  direction = "north",
                  goal_direction = "south",
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
               southsoutheast = {
                  direction = "south",
                  goal_direction = "southsoutheast",
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
               southsouthwest = {
                  direction = "southwest",
                  goal_direction = "southsouthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "south",
                  position = {
                     x = 1.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = "north",
                  position = {
                     x = -1.5,
                     y = 1.5,
                  },
               },
            },
         },
      },
      northeast = {
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
         northnortheast = {
            extensions = {
               north = {
                  direction = "southwest",
                  goal_direction = "north",
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
               northeast = {
                  direction = "northeast",
                  goal_direction = "northeast",
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
               northnortheast = {
                  direction = "northeast",
                  goal_direction = "northnortheast",
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
            signal_locations = {
               alt_out_signal = {
                  direction = "southsouthwest",
                  position = {
                     x = 0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = "northnortheast",
                  position = {
                     x = -0.5,
                     y = -2.5,
                  },
               },
               out_signal = {
                  direction = "southsouthwest",
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
         shift = {
            x = 1,
            y = 0,
         },
         south = {
            extensions = {
               south = {
                  direction = "north",
                  goal_direction = "south",
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
               southsoutheast = {
                  direction = "south",
                  goal_direction = "southsoutheast",
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
               southsouthwest = {
                  direction = "southwest",
                  goal_direction = "southsouthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "south",
                  position = {
                     x = 1.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = "north",
                  position = {
                     x = -1.5,
                     y = 1.5,
                  },
               },
            },
         },
      },
      northwest = {
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
         east = {
            extensions = {
               east = {
                  direction = "east",
                  goal_direction = "east",
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
               eastnortheast = {
                  direction = "east",
                  goal_direction = "eastnortheast",
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
               eastsoutheast = {
                  direction = "southeast",
                  goal_direction = "eastsoutheast",
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
            signal_locations = {
               in_signal = {
                  direction = "east",
                  position = {
                     x = 1.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = "west",
                  position = {
                     x = 1.5,
                     y = 1.5,
                  },
               },
            },
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
         shift = {
            x = 0,
            y = 1,
         },
         westnorthwest = {
            extensions = {
               northwest = {
                  direction = "northwest",
                  goal_direction = "northwest",
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
               west = {
                  direction = "southeast",
                  goal_direction = "west",
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
               westnorthwest = {
                  direction = "southeast",
                  goal_direction = "westnorthwest",
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
            signal_locations = {
               alt_out_signal = {
                  direction = "eastsoutheast",
                  position = {
                     x = -0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = "westnorthwest",
                  position = {
                     x = -2.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = "eastsoutheast",
                  position = {
                     x = -1.5,
                     y = -1.5,
                  },
               },
            },
         },
      },
      south = {
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
         north = {
            extensions = {
               north = {
                  direction = "north",
                  goal_direction = "north",
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
               northnortheast = {
                  direction = "northeast",
                  goal_direction = "northnortheast",
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
               northnorthwest = {
                  direction = "north",
                  goal_direction = "northnorthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "north",
                  position = {
                     x = -1.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = "south",
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
         shift = {
            x = 1,
            y = 0,
         },
         southsoutheast = {
            extensions = {
               south = {
                  direction = "north",
                  goal_direction = "south",
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
               southeast = {
                  direction = "south",
                  goal_direction = "southeast",
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
               southsoutheast = {
                  direction = "north",
                  goal_direction = "southsoutheast",
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
            signal_locations = {
               alt_in_signal = {
                  direction = "southsoutheast",
                  position = {
                     x = 0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = "southsoutheast",
                  position = {
                     x = 1.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = "northnorthwest",
                  position = {
                     x = -0.5,
                     y = 2.5,
                  },
               },
            },
         },
      },
      southeast = {
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
         eastsoutheast = {
            extensions = {
               east = {
                  direction = "northwest",
                  goal_direction = "east",
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
               eastsoutheast = {
                  direction = "southeast",
                  goal_direction = "eastsoutheast",
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
               southeast = {
                  direction = "southeast",
                  goal_direction = "southeast",
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
            signal_locations = {
               alt_out_signal = {
                  direction = "westnorthwest",
                  position = {
                     x = 0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = "eastsoutheast",
                  position = {
                     x = 2.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = "westnorthwest",
                  position = {
                     x = 1.5,
                     y = 1.5,
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
         shift = {
            x = 0,
            y = 1,
         },
         west = {
            extensions = {
               west = {
                  direction = "east",
                  goal_direction = "west",
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
               westnorthwest = {
                  direction = "northwest",
                  goal_direction = "westnorthwest",
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
               westsouthwest = {
                  direction = "west",
                  goal_direction = "westsouthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "west",
                  position = {
                     x = -1.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = "east",
                  position = {
                     x = -1.5,
                     y = -1.5,
                  },
               },
            },
         },
      },
      southwest = {
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
         north = {
            extensions = {
               north = {
                  direction = "north",
                  goal_direction = "north",
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
               northnortheast = {
                  direction = "northeast",
                  goal_direction = "northnortheast",
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
               northnorthwest = {
                  direction = "north",
                  goal_direction = "northnorthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "north",
                  position = {
                     x = -1.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = "south",
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
         shift = {
            x = 1,
            y = 0,
         },
         southsouthwest = {
            extensions = {
               south = {
                  direction = "northeast",
                  goal_direction = "south",
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
               southsouthwest = {
                  direction = "northeast",
                  goal_direction = "southsouthwest",
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
               southwest = {
                  direction = "southwest",
                  goal_direction = "southwest",
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
            signal_locations = {
               alt_out_signal = {
                  direction = "northnortheast",
                  position = {
                     x = -0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = "southsouthwest",
                  position = {
                     x = 0.5,
                     y = 2.5,
                  },
               },
               out_signal = {
                  direction = "northnortheast",
                  position = {
                     x = -1.5,
                     y = 1.5,
                  },
               },
            },
         },
      },
      west = {
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
         east = {
            extensions = {
               east = {
                  direction = "east",
                  goal_direction = "east",
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
               eastnortheast = {
                  direction = "east",
                  goal_direction = "eastnortheast",
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
               eastsoutheast = {
                  direction = "southeast",
                  goal_direction = "eastsoutheast",
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
            signal_locations = {
               in_signal = {
                  direction = "east",
                  position = {
                     x = 1.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = "west",
                  position = {
                     x = 1.5,
                     y = 1.5,
                  },
               },
            },
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
         shift = {
            x = 0,
            y = 1,
         },
         westsouthwest = {
            extensions = {
               southwest = {
                  direction = "west",
                  goal_direction = "southwest",
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
               west = {
                  direction = "east",
                  goal_direction = "west",
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
               westsouthwest = {
                  direction = "east",
                  goal_direction = "westsouthwest",
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
            signal_locations = {
               alt_in_signal = {
                  direction = "westsouthwest",
                  position = {
                     x = -0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = "westsouthwest",
                  position = {
                     x = -1.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = "eastnortheast",
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
      east = {
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
         northeast = {
            extensions = {
               eastnortheast = {
                  direction = "west",
                  goal_direction = "eastnortheast",
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
               northeast = {
                  direction = "northeast",
                  goal_direction = "northeast",
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
               northnortheast = {
                  direction = "southwest",
                  goal_direction = "northnortheast",
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
            signal_locations = {
               in_signal = {
                  direction = "northeast",
                  position = {
                     x = 0.5,
                     y = -2.5,
                  },
               },
               out_signal = {
                  direction = "southwest",
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
         shift = {
            x = 1,
            y = 1,
         },
         westsouthwest = {
            extensions = {
               southwest = {
                  direction = "west",
                  goal_direction = "southwest",
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
               west = {
                  direction = "east",
                  goal_direction = "west",
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
               westsouthwest = {
                  direction = "east",
                  goal_direction = "westsouthwest",
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
            signal_locations = {
               alt_in_signal = {
                  direction = "westsouthwest",
                  position = {
                     x = 0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = "westsouthwest",
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = "eastnortheast",
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
            },
         },
      },
      north = {
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
         northwest = {
            extensions = {
               northnorthwest = {
                  direction = "south",
                  goal_direction = "northnorthwest",
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
               northwest = {
                  direction = "southeast",
                  goal_direction = "northwest",
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
               westnorthwest = {
                  direction = "southeast",
                  goal_direction = "westnorthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "northwest",
                  position = {
                     x = -2.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = "southeast",
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
         shift = {
            x = 1,
            y = 1,
         },
         southsoutheast = {
            extensions = {
               south = {
                  direction = "north",
                  goal_direction = "south",
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
               southeast = {
                  direction = "south",
                  goal_direction = "southeast",
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
               southsoutheast = {
                  direction = "north",
                  goal_direction = "southsoutheast",
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
            signal_locations = {
               alt_in_signal = {
                  direction = "southsoutheast",
                  position = {
                     x = 0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = "southsoutheast",
                  position = {
                     x = 1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = "northnorthwest",
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
            },
         },
      },
      northeast = {
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
         northeast = {
            extensions = {
               eastnortheast = {
                  direction = "west",
                  goal_direction = "eastnortheast",
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
               northeast = {
                  direction = "northeast",
                  goal_direction = "northeast",
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
               northnortheast = {
                  direction = "southwest",
                  goal_direction = "northnortheast",
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
            signal_locations = {
               in_signal = {
                  direction = "northeast",
                  position = {
                     x = 0.5,
                     y = -2.5,
                  },
               },
               out_signal = {
                  direction = "southwest",
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
         shift = {
            x = 1,
            y = 1,
         },
         southsouthwest = {
            extensions = {
               south = {
                  direction = "northeast",
                  goal_direction = "south",
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
               southsouthwest = {
                  direction = "northeast",
                  goal_direction = "southsouthwest",
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
               southwest = {
                  direction = "southwest",
                  goal_direction = "southwest",
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
            signal_locations = {
               alt_out_signal = {
                  direction = "northnortheast",
                  position = {
                     x = -0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = "southsouthwest",
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = "northnortheast",
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
            },
         },
      },
      northwest = {
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
         eastsoutheast = {
            extensions = {
               east = {
                  direction = "northwest",
                  goal_direction = "east",
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
               eastsoutheast = {
                  direction = "southeast",
                  goal_direction = "eastsoutheast",
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
               southeast = {
                  direction = "southeast",
                  goal_direction = "southeast",
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
            signal_locations = {
               alt_out_signal = {
                  direction = "westnorthwest",
                  position = {
                     x = -0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = "eastsoutheast",
                  position = {
                     x = 1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = "westnorthwest",
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
            },
         },
         northwest = {
            extensions = {
               northnorthwest = {
                  direction = "south",
                  goal_direction = "northnorthwest",
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
               northwest = {
                  direction = "southeast",
                  goal_direction = "northwest",
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
               westnorthwest = {
                  direction = "southeast",
                  goal_direction = "westnorthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "northwest",
                  position = {
                     x = -2.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = "southeast",
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
         shift = {
            x = 1,
            y = 1,
         },
      },
      south = {
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
         northnorthwest = {
            extensions = {
               north = {
                  direction = "south",
                  goal_direction = "north",
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
               northnorthwest = {
                  direction = "north",
                  goal_direction = "northnorthwest",
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
               northwest = {
                  direction = "north",
                  goal_direction = "northwest",
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
            signal_locations = {
               alt_in_signal = {
                  direction = "northnorthwest",
                  position = {
                     x = -0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = "northnorthwest",
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = "southsoutheast",
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
         shift = {
            x = 1,
            y = 1,
         },
         southeast = {
            extensions = {
               eastsoutheast = {
                  direction = "northwest",
                  goal_direction = "eastsoutheast",
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
               southeast = {
                  direction = "southeast",
                  goal_direction = "southeast",
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
               southsoutheast = {
                  direction = "north",
                  goal_direction = "southsoutheast",
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
            signal_locations = {
               in_signal = {
                  direction = "southeast",
                  position = {
                     x = 2.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = "northwest",
                  position = {
                     x = 0.5,
                     y = 2.5,
                  },
               },
            },
         },
      },
      southeast = {
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
         shift = {
            x = 1,
            y = 1,
         },
         southeast = {
            extensions = {
               eastsoutheast = {
                  direction = "northwest",
                  goal_direction = "eastsoutheast",
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
               southeast = {
                  direction = "southeast",
                  goal_direction = "southeast",
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
               southsoutheast = {
                  direction = "north",
                  goal_direction = "southsoutheast",
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
            signal_locations = {
               in_signal = {
                  direction = "southeast",
                  position = {
                     x = 2.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = "northwest",
                  position = {
                     x = 0.5,
                     y = 2.5,
                  },
               },
            },
         },
         westnorthwest = {
            extensions = {
               northwest = {
                  direction = "northwest",
                  goal_direction = "northwest",
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
               west = {
                  direction = "southeast",
                  goal_direction = "west",
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
               westnorthwest = {
                  direction = "southeast",
                  goal_direction = "westnorthwest",
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
            signal_locations = {
               alt_out_signal = {
                  direction = "eastsoutheast",
                  position = {
                     x = 0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = "westnorthwest",
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = "eastsoutheast",
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
            },
         },
      },
      southwest = {
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
         northnortheast = {
            extensions = {
               north = {
                  direction = "southwest",
                  goal_direction = "north",
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
               northeast = {
                  direction = "northeast",
                  goal_direction = "northeast",
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
               northnortheast = {
                  direction = "northeast",
                  goal_direction = "northnortheast",
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
            signal_locations = {
               alt_out_signal = {
                  direction = "southsouthwest",
                  position = {
                     x = 0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = "northnortheast",
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = "southsouthwest",
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
         shift = {
            x = 1,
            y = 1,
         },
         southwest = {
            extensions = {
               southsouthwest = {
                  direction = "northeast",
                  goal_direction = "southsouthwest",
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
               southwest = {
                  direction = "northeast",
                  goal_direction = "southwest",
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
               westsouthwest = {
                  direction = "east",
                  goal_direction = "westsouthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "southwest",
                  position = {
                     x = -0.5,
                     y = 2.5,
                  },
               },
               out_signal = {
                  direction = "northeast",
                  position = {
                     x = -2.5,
                     y = 0.5,
                  },
               },
            },
         },
      },
      west = {
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
         eastnortheast = {
            extensions = {
               east = {
                  direction = "west",
                  goal_direction = "east",
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
               eastnortheast = {
                  direction = "east",
                  goal_direction = "eastnortheast",
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
               northeast = {
                  direction = "east",
                  goal_direction = "northeast",
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
            signal_locations = {
               alt_in_signal = {
                  direction = "eastnortheast",
                  position = {
                     x = -0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = "eastnortheast",
                  position = {
                     x = 0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = "westsouthwest",
                  position = {
                     x = 1.5,
                     y = 0.5,
                  },
               },
            },
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
         shift = {
            x = 1,
            y = 1,
         },
         southwest = {
            extensions = {
               southsouthwest = {
                  direction = "northeast",
                  goal_direction = "southsouthwest",
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
               southwest = {
                  direction = "northeast",
                  goal_direction = "southwest",
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
               westsouthwest = {
                  direction = "east",
                  goal_direction = "westsouthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "southwest",
                  position = {
                     x = -0.5,
                     y = 2.5,
                  },
               },
               out_signal = {
                  direction = "northeast",
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
      east = {
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
         eastnortheast = {
            extensions = {
               east = {
                  direction = "west",
                  goal_direction = "east",
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
               eastnortheast = {
                  direction = "east",
                  goal_direction = "eastnortheast",
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
               northeast = {
                  direction = "east",
                  goal_direction = "northeast",
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
            signal_locations = {
               alt_in_signal = {
                  direction = "eastnortheast",
                  position = {
                     x = -0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = "eastnortheast",
                  position = {
                     x = 0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = "westsouthwest",
                  position = {
                     x = 1.5,
                     y = 0.5,
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
         shift = {
            x = 1,
            y = 1,
         },
         westsouthwest = {
            extensions = {
               southwest = {
                  direction = "west",
                  goal_direction = "southwest",
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
               west = {
                  direction = "east",
                  goal_direction = "west",
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
               westsouthwest = {
                  direction = "east",
                  goal_direction = "westsouthwest",
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
            signal_locations = {
               alt_in_signal = {
                  direction = "westsouthwest",
                  position = {
                     x = 0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = "westsouthwest",
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = "eastnortheast",
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
            },
         },
      },
      north = {
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
         northnorthwest = {
            extensions = {
               north = {
                  direction = "south",
                  goal_direction = "north",
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
               northnorthwest = {
                  direction = "north",
                  goal_direction = "northnorthwest",
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
               northwest = {
                  direction = "north",
                  goal_direction = "northwest",
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
            signal_locations = {
               alt_in_signal = {
                  direction = "northnorthwest",
                  position = {
                     x = -0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = "northnorthwest",
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = "southsoutheast",
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
         shift = {
            x = 1,
            y = 1,
         },
         southsoutheast = {
            extensions = {
               south = {
                  direction = "north",
                  goal_direction = "south",
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
               southeast = {
                  direction = "south",
                  goal_direction = "southeast",
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
               southsoutheast = {
                  direction = "north",
                  goal_direction = "southsoutheast",
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
            signal_locations = {
               alt_in_signal = {
                  direction = "southsoutheast",
                  position = {
                     x = 0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = "southsoutheast",
                  position = {
                     x = 1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = "northnorthwest",
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
            },
         },
      },
      northeast = {
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
         northnortheast = {
            extensions = {
               north = {
                  direction = "southwest",
                  goal_direction = "north",
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
               northeast = {
                  direction = "northeast",
                  goal_direction = "northeast",
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
               northnortheast = {
                  direction = "northeast",
                  goal_direction = "northnortheast",
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
            signal_locations = {
               alt_out_signal = {
                  direction = "southsouthwest",
                  position = {
                     x = 0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = "northnortheast",
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = "southsouthwest",
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
         shift = {
            x = 1,
            y = 1,
         },
         southsouthwest = {
            extensions = {
               south = {
                  direction = "northeast",
                  goal_direction = "south",
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
               southsouthwest = {
                  direction = "northeast",
                  goal_direction = "southsouthwest",
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
               southwest = {
                  direction = "southwest",
                  goal_direction = "southwest",
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
            signal_locations = {
               alt_out_signal = {
                  direction = "northnortheast",
                  position = {
                     x = -0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = "southsouthwest",
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = "northnortheast",
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
            },
         },
      },
      northwest = {
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
         eastsoutheast = {
            extensions = {
               east = {
                  direction = "northwest",
                  goal_direction = "east",
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
               eastsoutheast = {
                  direction = "southeast",
                  goal_direction = "eastsoutheast",
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
               southeast = {
                  direction = "southeast",
                  goal_direction = "southeast",
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
            signal_locations = {
               alt_out_signal = {
                  direction = "westnorthwest",
                  position = {
                     x = -0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = "eastsoutheast",
                  position = {
                     x = 1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = "westnorthwest",
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
            },
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
         shift = {
            x = 1,
            y = 1,
         },
         westnorthwest = {
            extensions = {
               northwest = {
                  direction = "northwest",
                  goal_direction = "northwest",
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
               west = {
                  direction = "southeast",
                  goal_direction = "west",
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
               westnorthwest = {
                  direction = "southeast",
                  goal_direction = "westnorthwest",
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
            signal_locations = {
               alt_out_signal = {
                  direction = "eastsoutheast",
                  position = {
                     x = 0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = "westnorthwest",
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = "eastsoutheast",
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
            },
         },
      },
      south = {
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
         northnorthwest = {
            extensions = {
               north = {
                  direction = "south",
                  goal_direction = "north",
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
               northnorthwest = {
                  direction = "north",
                  goal_direction = "northnorthwest",
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
               northwest = {
                  direction = "north",
                  goal_direction = "northwest",
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
            signal_locations = {
               alt_in_signal = {
                  direction = "northnorthwest",
                  position = {
                     x = -0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = "northnorthwest",
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = "southsoutheast",
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
         shift = {
            x = 1,
            y = 1,
         },
         southsoutheast = {
            extensions = {
               south = {
                  direction = "north",
                  goal_direction = "south",
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
               southeast = {
                  direction = "south",
                  goal_direction = "southeast",
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
               southsoutheast = {
                  direction = "north",
                  goal_direction = "southsoutheast",
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
            signal_locations = {
               alt_in_signal = {
                  direction = "southsoutheast",
                  position = {
                     x = 0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = "southsoutheast",
                  position = {
                     x = 1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = "northnorthwest",
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
            },
         },
      },
      southeast = {
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
         eastsoutheast = {
            extensions = {
               east = {
                  direction = "northwest",
                  goal_direction = "east",
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
               eastsoutheast = {
                  direction = "southeast",
                  goal_direction = "eastsoutheast",
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
               southeast = {
                  direction = "southeast",
                  goal_direction = "southeast",
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
            signal_locations = {
               alt_out_signal = {
                  direction = "westnorthwest",
                  position = {
                     x = -0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = "eastsoutheast",
                  position = {
                     x = 1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = "westnorthwest",
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
            },
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
         shift = {
            x = 1,
            y = 1,
         },
         westnorthwest = {
            extensions = {
               northwest = {
                  direction = "northwest",
                  goal_direction = "northwest",
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
               west = {
                  direction = "southeast",
                  goal_direction = "west",
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
               westnorthwest = {
                  direction = "southeast",
                  goal_direction = "westnorthwest",
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
            signal_locations = {
               alt_out_signal = {
                  direction = "eastsoutheast",
                  position = {
                     x = 0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = "westnorthwest",
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = "eastsoutheast",
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
            },
         },
      },
      southwest = {
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
         northnortheast = {
            extensions = {
               north = {
                  direction = "southwest",
                  goal_direction = "north",
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
               northeast = {
                  direction = "northeast",
                  goal_direction = "northeast",
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
               northnortheast = {
                  direction = "northeast",
                  goal_direction = "northnortheast",
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
            signal_locations = {
               alt_out_signal = {
                  direction = "southsouthwest",
                  position = {
                     x = 0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = "northnortheast",
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = "southsouthwest",
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
         shift = {
            x = 1,
            y = 1,
         },
         southsouthwest = {
            extensions = {
               south = {
                  direction = "northeast",
                  goal_direction = "south",
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
               southsouthwest = {
                  direction = "northeast",
                  goal_direction = "southsouthwest",
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
               southwest = {
                  direction = "southwest",
                  goal_direction = "southwest",
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
            signal_locations = {
               alt_out_signal = {
                  direction = "northnortheast",
                  position = {
                     x = -0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = "southsouthwest",
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = "northnortheast",
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
            },
         },
      },
      west = {
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
         eastnortheast = {
            extensions = {
               east = {
                  direction = "west",
                  goal_direction = "east",
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
               eastnortheast = {
                  direction = "east",
                  goal_direction = "eastnortheast",
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
               northeast = {
                  direction = "east",
                  goal_direction = "northeast",
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
            signal_locations = {
               alt_in_signal = {
                  direction = "eastnortheast",
                  position = {
                     x = -0.5,
                     y = -0.5,
                  },
               },
               in_signal = {
                  direction = "eastnortheast",
                  position = {
                     x = 0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = "westsouthwest",
                  position = {
                     x = 1.5,
                     y = 0.5,
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
         shift = {
            x = 1,
            y = 1,
         },
         westsouthwest = {
            extensions = {
               southwest = {
                  direction = "west",
                  goal_direction = "southwest",
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
               west = {
                  direction = "east",
                  goal_direction = "west",
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
               westsouthwest = {
                  direction = "east",
                  goal_direction = "westsouthwest",
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
            signal_locations = {
               alt_in_signal = {
                  direction = "westsouthwest",
                  position = {
                     x = 0.5,
                     y = 0.5,
                  },
               },
               in_signal = {
                  direction = "westsouthwest",
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = "eastnortheast",
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
      east = {
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
         east = {
            extensions = {
               east = {
                  direction = "east",
                  goal_direction = "east",
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
               eastnortheast = {
                  direction = "east",
                  goal_direction = "eastnortheast",
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
               eastsoutheast = {
                  direction = "southeast",
                  goal_direction = "eastsoutheast",
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
            signal_locations = {
               in_signal = {
                  direction = "east",
                  position = {
                     x = 0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = "west",
                  position = {
                     x = 0.5,
                     y = 1.5,
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
         shift = {
            x = 1,
            y = 1,
         },
         west = {
            extensions = {
               west = {
                  direction = "east",
                  goal_direction = "west",
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
               westnorthwest = {
                  direction = "northwest",
                  goal_direction = "westnorthwest",
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
               westsouthwest = {
                  direction = "west",
                  goal_direction = "westsouthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "west",
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = "east",
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
            },
         },
      },
      north = {
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
         north = {
            extensions = {
               north = {
                  direction = "north",
                  goal_direction = "north",
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
               northnortheast = {
                  direction = "northeast",
                  goal_direction = "northnortheast",
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
               northnorthwest = {
                  direction = "north",
                  goal_direction = "northnorthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "north",
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = "south",
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
         shift = {
            x = 1,
            y = 1,
         },
         south = {
            extensions = {
               south = {
                  direction = "north",
                  goal_direction = "south",
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
               southsoutheast = {
                  direction = "south",
                  goal_direction = "southsoutheast",
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
               southsouthwest = {
                  direction = "southwest",
                  goal_direction = "southsouthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "south",
                  position = {
                     x = 1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = "north",
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
            },
         },
      },
      northeast = {
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
         northeast = {
            extensions = {
               eastnortheast = {
                  direction = "west",
                  goal_direction = "eastnortheast",
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
               northeast = {
                  direction = "northeast",
                  goal_direction = "northeast",
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
               northnortheast = {
                  direction = "southwest",
                  goal_direction = "northnortheast",
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
            signal_locations = {
               in_signal = {
                  direction = "northeast",
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = "southwest",
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
         shift = {
            x = 0,
            y = 0,
         },
         southwest = {
            extensions = {
               southsouthwest = {
                  direction = "northeast",
                  goal_direction = "southsouthwest",
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
               southwest = {
                  direction = "northeast",
                  goal_direction = "southwest",
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
               westsouthwest = {
                  direction = "east",
                  goal_direction = "westsouthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "southwest",
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = "northeast",
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
            },
         },
      },
      northwest = {
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
         northwest = {
            extensions = {
               northnorthwest = {
                  direction = "south",
                  goal_direction = "northnorthwest",
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
               northwest = {
                  direction = "southeast",
                  goal_direction = "northwest",
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
               westnorthwest = {
                  direction = "southeast",
                  goal_direction = "westnorthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "northwest",
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = "southeast",
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
         shift = {
            x = 0,
            y = 0,
         },
         southeast = {
            extensions = {
               eastsoutheast = {
                  direction = "northwest",
                  goal_direction = "eastsoutheast",
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
               southeast = {
                  direction = "southeast",
                  goal_direction = "southeast",
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
               southsoutheast = {
                  direction = "north",
                  goal_direction = "southsoutheast",
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
            signal_locations = {
               in_signal = {
                  direction = "southeast",
                  position = {
                     x = 1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = "northwest",
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
            },
         },
      },
      south = {
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
         north = {
            extensions = {
               north = {
                  direction = "north",
                  goal_direction = "north",
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
               northnortheast = {
                  direction = "northeast",
                  goal_direction = "northnortheast",
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
               northnorthwest = {
                  direction = "north",
                  goal_direction = "northnorthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "north",
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = "south",
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
         shift = {
            x = 1,
            y = 1,
         },
         south = {
            extensions = {
               south = {
                  direction = "north",
                  goal_direction = "south",
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
               southsoutheast = {
                  direction = "south",
                  goal_direction = "southsoutheast",
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
               southsouthwest = {
                  direction = "southwest",
                  goal_direction = "southsouthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "south",
                  position = {
                     x = 1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = "north",
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
            },
         },
      },
      southeast = {
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
         northwest = {
            extensions = {
               northnorthwest = {
                  direction = "south",
                  goal_direction = "northnorthwest",
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
               northwest = {
                  direction = "southeast",
                  goal_direction = "northwest",
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
               westnorthwest = {
                  direction = "southeast",
                  goal_direction = "westnorthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "northwest",
                  position = {
                     x = -1.5,
                     y = 0.5,
                  },
               },
               out_signal = {
                  direction = "southeast",
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
         shift = {
            x = 0,
            y = 0,
         },
         southeast = {
            extensions = {
               eastsoutheast = {
                  direction = "northwest",
                  goal_direction = "eastsoutheast",
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
               southeast = {
                  direction = "southeast",
                  goal_direction = "southeast",
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
               southsoutheast = {
                  direction = "north",
                  goal_direction = "southsoutheast",
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
            signal_locations = {
               in_signal = {
                  direction = "southeast",
                  position = {
                     x = 1.5,
                     y = -0.5,
                  },
               },
               out_signal = {
                  direction = "northwest",
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
            },
         },
      },
      southwest = {
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
         northeast = {
            extensions = {
               eastnortheast = {
                  direction = "west",
                  goal_direction = "eastnortheast",
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
               northeast = {
                  direction = "northeast",
                  goal_direction = "northeast",
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
               northnortheast = {
                  direction = "southwest",
                  goal_direction = "northnortheast",
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
            signal_locations = {
               in_signal = {
                  direction = "northeast",
                  position = {
                     x = -0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = "southwest",
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
         shift = {
            x = 0,
            y = 0,
         },
         southwest = {
            extensions = {
               southsouthwest = {
                  direction = "northeast",
                  goal_direction = "southsouthwest",
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
               southwest = {
                  direction = "northeast",
                  goal_direction = "southwest",
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
               westsouthwest = {
                  direction = "east",
                  goal_direction = "westsouthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "southwest",
                  position = {
                     x = 0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = "northeast",
                  position = {
                     x = -1.5,
                     y = -0.5,
                  },
               },
            },
         },
      },
      west = {
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
         east = {
            extensions = {
               east = {
                  direction = "east",
                  goal_direction = "east",
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
               eastnortheast = {
                  direction = "east",
                  goal_direction = "eastnortheast",
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
               eastsoutheast = {
                  direction = "southeast",
                  goal_direction = "eastsoutheast",
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
            signal_locations = {
               in_signal = {
                  direction = "east",
                  position = {
                     x = 0.5,
                     y = -1.5,
                  },
               },
               out_signal = {
                  direction = "west",
                  position = {
                     x = 0.5,
                     y = 1.5,
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
         shift = {
            x = 1,
            y = 1,
         },
         west = {
            extensions = {
               west = {
                  direction = "east",
                  goal_direction = "west",
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
               westnorthwest = {
                  direction = "northwest",
                  goal_direction = "westnorthwest",
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
               westsouthwest = {
                  direction = "west",
                  goal_direction = "westsouthwest",
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
            signal_locations = {
               in_signal = {
                  direction = "west",
                  position = {
                     x = -0.5,
                     y = 1.5,
                  },
               },
               out_signal = {
                  direction = "east",
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
