local TestRegistry = require("scripts.test-registry")
local describe, it = TestRegistry.describe, TestRegistry.it

local FaInfo = require("scripts.fa-info")
local TileBodiesBackend = require("scripts.scanner.backends.tile-bodies")

describe("Scanner tile bodies", function()
   it("reads a water patch as one entry with its size", function(ctx)
      ctx:init(function()
         local player = assert(game.get_player(1))
         local surface = player.surface
         -- Chunk 20, 20, away from anything else the tests build.
         local chunk_area = { left_top = { x = 640, y = 640 }, right_bottom = { x = 672, y = 672 } }
         surface.request_to_generate_chunks({ 656, 656 }, 0)
         surface.force_generate_chunk_requests()

         local tiles = {}
         for x = 640, 671 do
            for y = 640, 671 do
               local water = x >= 650 and x < 655 and y >= 650 and y < 653
               table.insert(tiles, { name = water and "water" or "grass-1", position = { x, y } })
            end
         end
         surface.set_tiles(tiles)

         local backend = TileBodiesBackend.TileBodiesBackend.new(surface)
         backend:on_new_chunk({ x = 20, y = 20, area = chunk_area })

         local entries = {}
         backend:dump_entries_to_callback(player, function(e)
            table.insert(entries, e)
         end)

         ctx:assert_equals(1, #entries, "one water body")
         ctx:assert_equals("water", entries[1].subcategory)
         ctx:assert_table_equals(
            { "fa.scanner-tile-body", { "tile-name.water" }, 5, 3 },
            backend:readout_entry(player, entries[1])
         )

         local summary = FaInfo.area_scan_summary_info(1, { x = 650, y = 650 }, { x = 660, y = 660 })
         ctx:assert(serpent.line(summary):find("tile-name.water", 1, true) ~= nil, serpent.line(summary))
      end)
   end)
end)
